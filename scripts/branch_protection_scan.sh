#!/usr/bin/env bash
set -euo pipefail

if ! command -v gh >/dev/null; then
  echo "gh not found"; exit 1
fi

REPO="${REPO:-$GITHUB_REPOSITORY}"
OWNER="${REPO%/*}"
NAME="${REPO#*/}"
BRANCH="main"

# Fetch repo settings (e.g., allow_auto_merge)
REPO_JSON="$(gh api "repos/${OWNER}/${NAME}")"
ALLOW_AUTO_MERGE="$(echo "$REPO_JSON" | jq -r '.allow_auto_merge // false')"

# Branch protection (may require repository settings visibility)
PROT_JSON="$(gh api "repos/${OWNER}/${NAME}/branches/${BRANCH}/protection" 2>/dev/null || true)"
if [ -z "$PROT_JSON" ]; then PROT_JSON='{}'; fi

REQUIRE_PR="$(echo "$PROT_JSON" | jq -r 'has("required_pull_request_reviews")')"
STRICT_UP_TO_DATE="$(echo "$PROT_JSON" | jq -r '.required_status_checks.strict // false')"
REQUIRED_CONTEXTS="$(echo "$PROT_JSON" | jq -r '.required_status_checks.contexts // [] | join(", ")')"

# Expected checks (adjust names to match your jobs if needed)
NEED_BG="Baseline Guard / verifyExpected"
NEED_SIZE="pr-size-gate"
NEED_SMOKE="os-smoke"  # job name from os-smoke-artifact workflow; change if different

HAS_BG="no";   [[ ",${REQUIRED_CONTEXTS}," == *",${NEED_BG},"* ]] && HAS_BG="yes"
HAS_SIZE="no"; [[ ",${REQUIRED_CONTEXTS}," == *",${NEED_SIZE},"* ]] && HAS_SIZE="yes"
HAS_SMOKE="no"; [[ ",${REQUIRED_CONTEXTS}," == *",${NEED_SMOKE},"* ]] && HAS_SMOKE="yes"

# Merge queue hint (rulesets API is best-effort and plan-dependent)
MQ_HINT="unknown"
RULESETS="$(gh api -H "Accept: application/vnd.github+json" "repos/${OWNER}/${NAME}/rulesets" 2>/dev/null || echo '[]')"
if echo "$RULESETS" | jq -e '.[] | select(.enforcement=="active")' >/dev/null 2>&1; then
  MQ_HINT="verify-in-UI"
fi

CAT_REQ_CTX=$(if [[ -n "$REQUIRED_CONTEXTS" ]]; then echo "$REQUIRED_CONTEXTS"; else echo "(none)"; fi)

read -r -d '' REPORT <<EOF
### Branch Protection Scan for \`${BRANCH}\`

**Require PR:** \`$([[ "$REQUIRE_PR" == "true" ]] && echo yes || echo no)\`  
**Require status checks:** \`$([[ "$REQUIRED_CONTEXTS" != "" ]] && echo yes || echo no)\`  
**Require branches up-to-date (strict):** \`$([[ "$STRICT_UP_TO_DATE" == "true" ]] && echo yes || echo no)\`  
**Required checks configured:** \`${CAT_REQ_CTX}\`

**Expected checks present?**
- Baseline Guard / verifyExpected: \`$HAS_BG\`
- PR size gate (pr-size-gate): \`$HAS_SIZE\`
- OS smoke job (os-smoke): \`$HAS_SMOKE\`

**Allow auto-merge:** \`$ALLOW_AUTO_MERGE\`  
**Merge queue:** \`$MQ_HINT\` (if \`verify-in-UI\`, enable **Settings → Branches → Merge queue** and require a merge queue on \`${BRANCH}\`)

---

#### Next steps (if any are **no**):
1. **Settings → Branches → main (rule)**  
   - Enable **Require a pull request**  
   - Enable **Require status checks to pass** and **Require branches to be up to date**  
   - Add required checks: \`${NEED_BG}\`, \`${NEED_SIZE}\`, \`${NEED_SMOKE}\`  
   - After enabling merge queue repo-wide: **Require a merge queue**
2. **Settings → General → Pull Requests → Allow auto-merge** → ON

> If a check is missing from the picker, run a PR so the job appears, then add it.
EOF

echo "$REPORT"

if [[ -n "${PR_NUMBER:-}" ]]; then
  gh pr comment "$PR_NUMBER" --body "$REPORT" || true
else
  # Fallback: create/update an issue if no PR context
  gh issue list --limit 100 --search "Branch Protection Scan" --json number | jq -e '.[0]' >/dev/null 2>&1 || \
    gh issue create --title "Branch Protection Scan" --body "$REPORT" || true
fi
