# Base44 UI Verification and Build

This document describes the Base44 UI verification and build system for the Agent Ops Hub repository.

## Overview

The Base44 UI verification system ensures that Base44 ZIP files are properly uploaded to PRs and can be successfully built into UI artifacts. The system includes:

1. A GitHub Actions workflow that builds Base44 UI from a ZIP file
2. A verification script that checks for the ZIP file and orchestrates the build
3. Automated PR comments with build status and artifact details

## Components

### 1. Build Workflow: `.github/workflows/build-base44-ui.yml`

This workflow performs the following steps:

1. **Checkout** - Checks out the repository
2. **Assert vendor zip exists** - Verifies `vendor/base44-ui.zip` is present
3. **Unzip to apps/base44-ui** - Extracts the ZIP to the apps directory
4. **Setup Node** - Installs Node.js 20 with npm caching
5. **Inject Base44 app id** - Configures the Base44 app ID from inputs or secrets
6. **Install & Build** - Runs `npm ci` and `npm run build`
7. **Upload artifact** - Uploads the build output as a GitHub artifact

#### Workflow Inputs

- `app_id` (optional): Base44 APP_ID. Falls back to the repository secret `BASE44_APP_ID` if not provided.

#### Triggering the Workflow

The workflow is manually triggered via `workflow_dispatch`:

```bash
# Using GitHub CLI
gh workflow run build-base44-ui.yml --ref <branch-name> -f app_id="your-app-id"

# Via GitHub UI
# Go to Actions → Build Base44 UI → Run workflow
```

### 2. Verification Script: `scripts/verify-base44-zip.sh`

This script automates the verification process for a PR:

#### Usage

```bash
./scripts/verify-base44-zip.sh <pr_number> [github_token]
```

**Parameters:**
- `pr_number` (required): The PR number to verify
- `github_token` (optional): GitHub token with repo access (can also be set via `GITHUB_TOKEN` env var)

**Example:**

```bash
export GITHUB_TOKEN="ghp_your_token_here"
./scripts/verify-base44-zip.sh 61
```

#### What the Script Does

1. **Resolves PR head branch** - Gets the branch name and SHA from PR #N
2. **Checks for vendor/base44-ui.zip** - Verifies the ZIP exists on the branch
   - If missing: Posts a failure comment and exits
   - If > 90 MB: Includes a warning about GitHub's 100 MB limit
3. **Ensures workflow exists** - Checks that `build-base44-ui.yml` is present
4. **Dispatches the build** - Triggers the workflow on the PR branch
5. **Waits for completion** - Monitors the workflow run (max 10 minutes)
6. **Posts status comment** - Adds a detailed report to the PR with:
   - Build status (success/failure)
   - ZIP size and SHA
   - Artifact download link
   - File tree preview (first 15 files)
   - Build log highlights (first and last 40 lines)

#### Exit Codes

- `0` - Verification passed and build succeeded
- `1` - Verification failed or build failed

## ZIP File Requirements

The Base44 ZIP file must:

- Be located at exactly `vendor/base44-ui.zip` in the PR branch
- Be under 100 MB (recommended < 90 MB to leave safety margin)
- Contain a valid Base44 UI application structure with:
  - `package.json` and `package-lock.json`
  - Source code in expected directories
  - A `npm run build` script that produces output in `dist/`

## Expected Directory Structure

After unzipping, the structure should look like:

```
apps/base44-ui/
├── package.json
├── package-lock.json
├── src/
│   ├── api/
│   │   └── base44Client.js  (optional, for app ID injection)
│   └── ...
├── dist/  (created by build)
└── ...
```

## PR Comment Format

When the verification runs, it posts a comment to the PR with this structure:

### Success Example

```markdown
✅ Base44 UI Build Status: success

### Build Details
- **Workflow Run:** [#1234567](https://github.com/.../runs/1234567)
- **Branch:** `chore/add-base44-zip` (`89f1836`)
- **ZIP Size:** 12.34 MB
- **ZIP SHA:** `abc123...`

### Artifact
- **Name:** `base44-ui-dist`
- **Size:** 5.67 MB
- **Download:** [Click here](https://github.com/.../artifacts/1234)

### Tree After Unzip (first 15 files)
[File listing...]

### Build Log Highlights
[Expandable sections with first/last 40 lines]

---
NOTE: Base44 output is a UI shell (Vite + React + Tailwind + shadcn/ui) 
that uses the Base44 SDK. It does not replace your repo workflows/guardrails.
```

### Failure Examples

**Missing ZIP:**
```markdown
❌ vendor/base44-ui.zip is missing on `branch-name`.

Please upload your Base44 zip at exactly `vendor/base44-ui.zip` in this branch.
```

**Size Warning:**
```markdown
⚠️ Warning: The zip file is 95.5 MB. GitHub enforces a 100 MB file limit. 
Please keep the zip < 90 MB to avoid issues.
```

## Integration with CI/CD

The Base44 verification can be integrated into your CI/CD pipeline:

### Option 1: Manual Trigger

Add a comment on PRs instructing users to upload the ZIP, then manually run:

```bash
./scripts/verify-base44-zip.sh <pr_number>
```

### Option 2: GitHub Actions Workflow

Create a workflow that triggers on PR labels or comments:

```yaml
name: Verify Base44 UI
on:
  pull_request:
    types: [labeled]

jobs:
  verify:
    if: contains(github.event.pull_request.labels.*.name, 'verify-base44')
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - name: Run verification
        env:
          GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
        run: |
          ./scripts/verify-base44-zip.sh ${{ github.event.pull_request.number }}
```

### Option 3: Webhook/Bot

Set up a webhook or bot that automatically runs verification when:
- A PR is opened or updated
- A specific file path is modified (`vendor/base44-ui.zip`)
- A specific label is added

## Troubleshooting

### "vendor/base44-ui.zip missing" Error

**Cause:** The ZIP file is not at the expected path.

**Solution:** Upload the file to exactly `vendor/base44-ui.zip` in your branch:

```bash
git checkout your-branch
# Copy your ZIP file to vendor/base44-ui.zip
git add vendor/base44-ui.zip
git commit -m "Add Base44 UI zip"
git push
```

### Build Fails with "npm ci" Error

**Cause:** The ZIP doesn't contain valid `package.json` and `package-lock.json`.

**Solution:** Ensure your Base44 UI project is properly structured with all dependencies defined.

### Build Fails with "npm run build" Error

**Cause:** The build script is missing or the build fails.

**Solution:** Test the build locally:

```bash
unzip vendor/base44-ui.zip -d /tmp/test-base44
cd /tmp/test-base44
npm ci
npm run build
```

Fix any errors, re-zip, and upload.

### Artifact Not Found

**Cause:** The build didn't produce output in `dist/` directory.

**Solution:** Check the build logs to see where output is generated and adjust the workflow if needed.

### "Workflow file is missing" Error

**Cause:** The `build-base44-ui.yml` workflow doesn't exist on your branch.

**Solution:** Merge from main or manually add the workflow file to your branch.

## Security Considerations

1. **Secrets:** The `BASE44_APP_ID` secret is optional. If not provided, the build will use a placeholder "CHANGE_ME".

2. **ZIP Validation:** The workflow only validates the ZIP exists, not its contents. Ensure you trust the source of ZIP files.

3. **Token Permissions:** The verification script requires a GitHub token with `repo` scope to:
   - Read PR details
   - Check file existence
   - Dispatch workflows
   - Post comments

4. **Build Environment:** The build runs in an isolated GitHub Actions runner with no access to production systems.

## Advanced Usage

### Custom App ID

Provide a custom Base44 app ID when dispatching:

```bash
gh workflow run build-base44-ui.yml --ref my-branch -f app_id="my-custom-id"
```

### Extract Build Artifacts Programmatically

After the build completes, you can download artifacts via API:

```bash
RUN_ID="1234567"
ARTIFACT_ID="7654321"

curl -L \
  -H "Authorization: Bearer $GITHUB_TOKEN" \
  -H "Accept: application/vnd.github+json" \
  "https://api.github.com/repos/martinmo90/agent-ops-hub/actions/artifacts/$ARTIFACT_ID/zip" \
  -o base44-ui-dist.zip
```

### Modify Build Steps

To customize the build process, edit `.github/workflows/build-base44-ui.yml`:

- Add additional build steps (linting, testing, etc.)
- Change Node.js version
- Modify caching strategy
- Add environment variables

## Related Documentation

- [GitHub Actions Workflow Syntax](https://docs.github.com/en/actions/using-workflows/workflow-syntax-for-github-actions)
- [GitHub Actions Artifacts](https://docs.github.com/en/actions/using-workflows/storing-workflow-data-as-artifacts)
- [GitHub REST API](https://docs.github.com/en/rest)

## Support

For issues or questions:
1. Check the workflow logs in the Actions tab
2. Review the PR comments for specific error messages
3. Consult this documentation for troubleshooting steps
4. Open an issue with details of the error
