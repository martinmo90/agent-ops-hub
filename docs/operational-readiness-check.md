# Operational Readiness Check

Comprehensive sanity check script that verifies the operational status of the agent-ops-hub repository using GitHub REST API.

## Overview

The Operational Readiness Check performs a full end-to-end verification of the repository's health by:

1. **Dispatching key workflows** on the main branch via GitHub API
2. **Monitoring workflow execution** until completion
3. **Creating a smoke test PR** to verify the PR workflow end-to-end
4. **Generating a comprehensive report** as a GitHub Issue

## Features

### Workflow Verification

The script dispatches and monitors the following workflows:

- **Required Checks Audit** (`required-checks-audit.yml`) - Verifies branch protection and required checks consistency
- **Operational Status Scan** (`operational-status-scan.yml`) - Evaluates repository operational status
- **Repo Tidy Scan** (`repo-tidy-scan.yml`) - Scans for stale branches and cleanup opportunities
- **Ops Dashboard Build** (`ops-build-zip.yml`) - Verifies the dashboard builds successfully
- **Benchmark Zip Check** (`benchmark-zip-exact-check.yml`) - Validates benchmark artifacts

### Smoke Test PR

Creates an automated PR to verify:
- Branch creation works
- File commits work
- PR creation works
- CI workflows trigger correctly

The smoke test PR is safe to close after verification (no need to merge).

### Report Generation

Generates a markdown report containing:
- Overall operational status (PASS/FAIL)
- Individual workflow results with links
- Smoke test PR status
- Next steps and recommendations

The report is:
- Saved locally to `/tmp/operational-readiness-report.md`
- Posted as a GitHub Issue with title format: `Operational Readiness — Sanity Check (YYYY-MM-DD)`

## Usage

### Prerequisites

- Python 3.6 or higher
- GitHub Personal Access Token with appropriate permissions:
  - `repo` (full control of private repositories)
  - `workflow` (update GitHub Action workflows)
  - `write:packages` (optional, if using packages)

### Running the Check

#### Option 1: Using the wrapper script (recommended)

```bash
# Set your GitHub token
export GITHUB_TOKEN=your_token_here

# Run the check
./scripts/run-operational-readiness-check.sh
```

#### Option 2: Running Python script directly

```bash
# Install dependencies
pip install requests

# Set your GitHub token
export GITHUB_TOKEN=your_token_here

# Run the script
python3 scripts/operational-readiness-check.py
```

### From GitHub Actions

You can also trigger this check from a GitHub Actions workflow:

```yaml
name: Operational Readiness Check

on:
  workflow_dispatch:
  schedule:
    - cron: '0 0 * * 0'  # Weekly on Sunday

jobs:
  check:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      
      - name: Setup Python
        uses: actions/setup-python@v4
        with:
          python-version: '3.10'
      
      - name: Install dependencies
        run: pip install requests
      
      - name: Run operational readiness check
        env:
          GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
        run: python3 scripts/operational-readiness-check.py
```

## Output

### Console Output

The script provides real-time progress updates:

```
============================================================
OPERATIONAL READINESS CHECK
============================================================
Repository: martinmo90/agent-ops-hub

Step 1: Resolving default branch...
  ✓ Default branch: main

Step 2: Dispatching workflows on main branch...
  Dispatching: Required Checks Audit...
    ✓ Dispatched successfully
    → Monitoring run #123456789...
    ✅ Status: completed, Conclusion: success

  Dispatching: Operational Status Scan...
    ✓ Dispatched successfully
    → Monitoring run #123456790...
    ✅ Status: completed, Conclusion: success

...

Step 3: Creating smoke test PR...
  Creating branch: chore/smoke-ops-readiness...
    ✓ Branch created/exists
  Creating smoke test file...
    ✓ File created: docs/SMOKE_TEST_2025-11-09_11-00-00.md
  Creating pull request...
    ✓ PR created: #42

Step 4: Generating report...
  ✓ Report saved: /tmp/operational-readiness-report.md
  Creating GitHub Issue...
    ✓ Issue created: #43
    → https://github.com/martinmo90/agent-ops-hub/issues/43

============================================================
OPERATIONAL READINESS CHECK COMPLETE
============================================================

Report available at: /tmp/operational-readiness-report.md
GitHub Issue: https://github.com/martinmo90/agent-ops-hub/issues/43
```

### Report Format

The generated report includes:

```markdown
# Operational Readiness — Sanity Check (2025-11-09)

**Generated:** 2025-11-09 11:00:00 UTC
**Repository:** martinmo90/agent-ops-hub
**Base Branch:** main

## Executive Summary

**Overall Status:** ✅ PASS

## Workflow Execution Results

| Workflow | Status | Conclusion | Run URL |
|----------|--------|------------|---------|
| Required Checks Audit | ✅ completed | success | [View](https://...) |
| Operational Status Scan | ✅ completed | success | [View](https://...) |
| ... | ... | ... | ... |

## Smoke Test PR

✅ **Smoke PR Created:** #42
- **URL:** https://github.com/martinmo90/agent-ops-hub/pull/42
- **Status:** created

## Branch Protection & Required Checks

✅ See `required-checks-audit.yml` results above for detailed consistency check.

## Next Steps

✅ **All checks passed!** The repository is operational and ready for use.

**Recommended actions:**
- Continue with planned backend integration
- Address any minor issues identified in workflow logs
- Monitor ongoing CI/CD pipeline performance
```

## Troubleshooting

### Common Issues

**Issue:** Script fails with authentication error
```
ERROR: 401 Unauthorized
```
**Solution:** Verify your GitHub token has the required permissions (`repo`, `workflow`)

---

**Issue:** Workflows don't dispatch
```
Warning: Failed to dispatch workflow: 404
```
**Solution:** Check that the workflow files exist and have `workflow_dispatch` trigger configured

---

**Issue:** Workflow polling times out
```
Status: timeout, Conclusion: timeout
```
**Solution:** Increase the timeout value in the script or check if workflows are stuck

---

**Issue:** Cannot create smoke test branch
```
Failed to create branch
```
**Solution:** Check if branch already exists or if token has write permissions

## Maintenance

### Adding New Workflows

To add a new workflow to be checked, edit `operational-readiness-check.py`:

```python
workflows = [
    # ... existing workflows ...
    {
        "file": "your-workflow.yml",
        "name": "Your Workflow Name",
        "inputs": {"key": "value"}  # workflow inputs if any
    }
]
```

### Adjusting Timeouts

Default workflow timeout is 600 seconds (10 minutes). To adjust:

```python
status, conclusion = client.wait_for_workflow_completion(run_id, timeout=900)  # 15 minutes
```

## Security Considerations

- **Never commit GitHub tokens** to the repository
- Use environment variables or GitHub Actions secrets
- Limit token scope to minimum required permissions
- Rotate tokens regularly
- Review smoke test PRs before closing to ensure no unexpected changes

## Related Documentation

- [GitHub REST API - Actions](https://docs.github.com/en/rest/actions)
- [GitHub Actions - workflow_dispatch](https://docs.github.com/en/actions/using-workflows/events-that-trigger-workflows#workflow_dispatch)
- [Repository Governance](../PROJECT_CHARTER.md)
- [Agent Response Policy](../AGENT_RESPONSE_POLICY.md)

## Support

For issues or questions:
1. Check the troubleshooting section above
2. Review workflow logs for detailed error messages
3. Open a GitHub Issue with the `operations` label
4. Include the generated report and relevant log excerpts
