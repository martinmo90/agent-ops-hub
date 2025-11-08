#!/bin/bash
set -euo pipefail

# Verify Base44 ZIP and build UI artifact
# Usage: ./scripts/verify-base44-zip.sh <pr_number> [github_token]
#
# This script:
# 1. Resolves the PR head branch
# 2. Checks if vendor/base44-ui.zip exists on the branch
# 3. Creates the build workflow if missing
# 4. Dispatches the build workflow
# 5. Waits for completion and posts a status comment

REPO_OWNER="martinmo90"
REPO_NAME="agent-ops-hub"
PR_NUMBER="${1:-}"
GITHUB_TOKEN="${2:-${GITHUB_TOKEN:-}}"

if [ -z "$PR_NUMBER" ]; then
  echo "Usage: $0 <pr_number> [github_token]"
  exit 1
fi

if [ -z "$GITHUB_TOKEN" ]; then
  echo "Error: GITHUB_TOKEN is required (set env var or pass as second argument)"
  exit 1
fi

API_BASE="https://api.github.com"
REPO_API="$API_BASE/repos/$REPO_OWNER/$REPO_NAME"

# Helper function to call GitHub API
gh_api() {
  local method="$1"
  local endpoint="$2"
  shift 2
  curl -s -X "$method" \
    -H "Authorization: Bearer $GITHUB_TOKEN" \
    -H "Accept: application/vnd.github+json" \
    -H "X-GitHub-Api-Version: 2022-11-28" \
    "$@" \
    "$REPO_API/$endpoint"
}

# Helper function to post PR comment
post_comment() {
  local body="$1"
  gh_api POST "issues/$PR_NUMBER/comments" \
    -d "$(jq -n --arg body "$body" '{body: $body}')"
}

echo "=== Step 1: Resolve PR head branch ==="
PR_DATA=$(gh_api GET "pulls/$PR_NUMBER")
HEAD_REF=$(echo "$PR_DATA" | jq -r '.head.ref')
HEAD_SHA=$(echo "$PR_DATA" | jq -r '.head.sha')

if [ -z "$HEAD_REF" ] || [ "$HEAD_REF" = "null" ]; then
  echo "Error: Could not resolve head ref for PR #$PR_NUMBER"
  exit 1
fi

echo "HEAD_REF: $HEAD_REF"
echo "HEAD_SHA: $HEAD_SHA"

echo ""
echo "=== Step 2: Check if vendor/base44-ui.zip exists on $HEAD_REF ==="
ZIP_RESPONSE=$(curl -s -w "\n%{http_code}" \
  -H "Authorization: Bearer $GITHUB_TOKEN" \
  -H "Accept: application/vnd.github+json" \
  "$REPO_API/contents/vendor/base44-ui.zip?ref=$HEAD_REF")

HTTP_CODE=$(echo "$ZIP_RESPONSE" | tail -n1)
ZIP_DATA=$(echo "$ZIP_RESPONSE" | sed '$d')

if [ "$HTTP_CODE" = "404" ]; then
  echo "❌ vendor/base44-ui.zip is missing on branch $HEAD_REF"
  COMMENT="❌ **vendor/base44-ui.zip is missing** on \`$HEAD_REF\`.

Please upload your Base44 zip at exactly \`vendor/base44-ui.zip\` in this branch, then re-run this verification."
  post_comment "$COMMENT"
  echo "Posted failure comment to PR #$PR_NUMBER"
  exit 1
fi

if [ "$HTTP_CODE" != "200" ]; then
  echo "Error: Unexpected HTTP code $HTTP_CODE when checking zip"
  echo "$ZIP_DATA"
  exit 1
fi

ZIP_SIZE=$(echo "$ZIP_DATA" | jq -r '.size')
ZIP_SHA=$(echo "$ZIP_DATA" | jq -r '.sha')
ZIP_SIZE_MB=$(echo "scale=2; $ZIP_SIZE / 1024 / 1024" | bc)

echo "✅ Found vendor/base44-ui.zip"
echo "  - Size: $ZIP_SIZE bytes ($ZIP_SIZE_MB MB)"
echo "  - SHA: $ZIP_SHA"

# Check if size exceeds warning threshold (90 MB = 94371840 bytes)
SIZE_WARNING=""
if [ "$ZIP_SIZE" -gt 94371840 ]; then
  SIZE_WARNING="⚠️ **Warning:** The zip file is ${ZIP_SIZE_MB} MB. GitHub enforces a 100 MB file limit. Please keep the zip < 90 MB to avoid issues.

"
  echo "⚠️ Warning: ZIP size ${ZIP_SIZE_MB} MB exceeds recommended 90 MB limit"
fi

echo ""
echo "=== Step 3: Ensure build workflow exists ==="
WORKFLOW_FILE=".github/workflows/build-base44-ui.yml"
WORKFLOW_CHECK=$(curl -s -w "\n%{http_code}" \
  -H "Authorization: Bearer $GITHUB_TOKEN" \
  -H "Accept: application/vnd.github+json" \
  "$REPO_API/contents/$WORKFLOW_FILE?ref=$HEAD_REF")

WORKFLOW_HTTP_CODE=$(echo "$WORKFLOW_CHECK" | tail -n1)

if [ "$WORKFLOW_HTTP_CODE" = "404" ]; then
  echo "⚠️ Workflow file $WORKFLOW_FILE is missing on $HEAD_REF"
  echo "The workflow should be created in the repository first."
  COMMENT="⚠️ **Build workflow is missing**

The required workflow file \`$WORKFLOW_FILE\` does not exist on branch \`$HEAD_REF\`.

Please ensure this workflow is present in your repository before running the build."
  post_comment "$COMMENT"
  exit 1
else
  echo "✅ Workflow file exists: $WORKFLOW_FILE"
fi

echo ""
echo "=== Step 4: Dispatch the build workflow ==="
# Dispatch workflow on the head ref
gh_api POST "actions/workflows/build-base44-ui.yml/dispatches" \
  -d "$(jq -n --arg ref "$HEAD_REF" '{ref: $ref, inputs: {app_id: "CHANGE_ME"}}')" > /dev/null

echo "Workflow dispatched on branch $HEAD_REF"
echo "Waiting 5 seconds for workflow to start..."
sleep 5

echo ""
echo "=== Step 5: Wait for completion and compile report ==="
# Find the most recent workflow run for this branch
MAX_WAIT=600  # 10 minutes
ELAPSED=0
RUN_ID=""

while [ $ELAPSED -lt $MAX_WAIT ]; do
  RUNS=$(gh_api GET "actions/workflows/build-base44-ui.yml/runs?branch=$HEAD_REF&per_page=5")
  RUN_ID=$(echo "$RUNS" | jq -r '.workflow_runs[0].id // empty')
  
  if [ -n "$RUN_ID" ]; then
    echo "Found workflow run ID: $RUN_ID"
    break
  fi
  
  echo "Waiting for workflow run to appear... (${ELAPSED}s elapsed)"
  sleep 10
  ELAPSED=$((ELAPSED + 10))
done

if [ -z "$RUN_ID" ]; then
  echo "Error: Could not find workflow run after ${ELAPSED}s"
  COMMENT="❌ **Build workflow dispatch failed**

Could not find the workflow run after dispatching. Please check the Actions tab manually."
  post_comment "$COMMENT"
  exit 1
fi

# Wait for the run to complete
echo "Waiting for workflow run $RUN_ID to complete..."
while [ $ELAPSED -lt $MAX_WAIT ]; do
  RUN_DATA=$(gh_api GET "actions/runs/$RUN_ID")
  STATUS=$(echo "$RUN_DATA" | jq -r '.status')
  CONCLUSION=$(echo "$RUN_DATA" | jq -r '.conclusion // "pending"')
  
  echo "  Status: $STATUS, Conclusion: $CONCLUSION (${ELAPSED}s elapsed)"
  
  if [ "$STATUS" = "completed" ]; then
    echo "Workflow completed with conclusion: $CONCLUSION"
    break
  fi
  
  sleep 15
  ELAPSED=$((ELAPSED + 15))
done

if [ "$STATUS" != "completed" ]; then
  echo "Error: Workflow did not complete within ${MAX_WAIT}s"
  COMMENT="⚠️ **Build workflow timed out**

The workflow run did not complete within the expected time. Please check the run manually:
https://github.com/$REPO_OWNER/$REPO_NAME/actions/runs/$RUN_ID"
  post_comment "$COMMENT"
  exit 1
fi

# Get workflow run details
RUN_URL=$(echo "$RUN_DATA" | jq -r '.html_url')
RUN_CONCLUSION=$(echo "$RUN_DATA" | jq -r '.conclusion')

# Get jobs for this run
JOBS_DATA=$(gh_api GET "actions/runs/$RUN_ID/jobs")
BUILD_JOB=$(echo "$JOBS_DATA" | jq -r '.jobs[0]')
JOB_ID=$(echo "$BUILD_JOB" | jq -r '.id')

# Get logs for the Install & Build step
echo "Fetching job logs..."
LOGS=$(gh_api GET "actions/jobs/$JOB_ID/logs" || echo "")

# Extract Install & Build log section
BUILD_LOG=$(echo "$LOGS" | sed -n '/Install & Build/,/Upload artifact/p' | head -n 80 || echo "Log extraction failed")
BUILD_LOG_FIRST=$(echo "$BUILD_LOG" | head -n 40)
BUILD_LOG_LAST=$(echo "$BUILD_LOG" | tail -n 40)

# Extract Unzip tree section
TREE_LOG=$(echo "$LOGS" | sed -n '/Tree after unzip:/,/Setup Node/p' | head -n 20 || echo "Tree not found")
TREE_PREVIEW=$(echo "$TREE_LOG" | head -n 15)

# Get artifacts
ARTIFACTS=$(gh_api GET "actions/runs/$RUN_ID/artifacts")
ARTIFACT_NAME=$(echo "$ARTIFACTS" | jq -r '.artifacts[0].name // "none"')
ARTIFACT_ID=$(echo "$ARTIFACTS" | jq -r '.artifacts[0].id // ""')
ARTIFACT_SIZE=$(echo "$ARTIFACTS" | jq -r '.artifacts[0].size_in_bytes // 0')
ARTIFACT_SIZE_MB=$(echo "scale=2; $ARTIFACT_SIZE / 1024 / 1024" | bc)

ARTIFACT_URL=""
if [ -n "$ARTIFACT_ID" ] && [ "$ARTIFACT_ID" != "null" ]; then
  ARTIFACT_URL="https://github.com/$REPO_OWNER/$REPO_NAME/actions/runs/$RUN_ID/artifacts/$ARTIFACT_ID"
fi

# Build status emoji
STATUS_EMOJI="✅"
if [ "$RUN_CONCLUSION" != "success" ]; then
  STATUS_EMOJI="❌"
fi

# Compile the final comment
COMMENT="${SIZE_WARNING}${STATUS_EMOJI} **Base44 UI Build Status: ${RUN_CONCLUSION}**

### Build Details
- **Workflow Run:** [#$RUN_ID]($RUN_URL)
- **Branch:** \`$HEAD_REF\` (\`${HEAD_SHA:0:7}\`)
- **ZIP Size:** $ZIP_SIZE_MB MB
- **ZIP SHA:** \`$ZIP_SHA\`

### Artifact
"

if [ -n "$ARTIFACT_URL" ]; then
  COMMENT+="- **Name:** \`$ARTIFACT_NAME\`
- **Size:** $ARTIFACT_SIZE_MB MB
- **Download:** [Click here]($ARTIFACT_URL)
"
else
  COMMENT+="No artifacts were produced (check logs for details).
"
fi

COMMENT+="
### Tree After Unzip (first 15 files)
\`\`\`
$TREE_PREVIEW
\`\`\`

### Build Log Highlights
<details>
<summary>First 40 lines of Install & Build</summary>

\`\`\`
$BUILD_LOG_FIRST
\`\`\`
</details>

<details>
<summary>Last 40 lines of Install & Build</summary>

\`\`\`
$BUILD_LOG_LAST
\`\`\`
</details>

---

**NOTE:** Base44 output is a UI shell (Vite + React + Tailwind + shadcn/ui) that uses the Base44 SDK. It does not replace your repo workflows/guardrails."

# Post the comment
echo ""
echo "Posting status comment to PR #$PR_NUMBER..."
post_comment "$COMMENT"

echo ""
echo "✅ Verification complete!"
echo "   - Workflow: $RUN_CONCLUSION"
echo "   - Comment posted to PR #$PR_NUMBER"

if [ "$RUN_CONCLUSION" = "success" ]; then
  exit 0
else
  exit 1
fi
