# PR #17 Conflict Resolution Guide

## Overview
PR #17 (`cursor/pr-template-20251104`) has merge conflicts with `main` branch that prevent it from being merged.

## Conflicts Identified
The following files have conflicts between `cursor/pr-template-20251104` and `main`:

1. `.github/pull_request_template.md` - **Primary conflict**
2. `.github/workflows/auto-merge-on-label.yml`
3. `.github/workflows/auto-open-pr-on-push.yml`
4. `.github/workflows/baseline-guard.yml`
5. `.github/workflows/merge-on-green.yml`
6. `README.md`
7. `scripts/auto_merge_claude.sh`

## Root Cause
The branches have unrelated histories due to a grafting operation on the `main` branch. This requires using `--allow-unrelated-histories` during merge.

## Recommended Resolution

### Option 1: Accept Main's Version (Recommended)
The `main` branch represents the current desired state of the project with comprehensive governance requirements. The resolution should accept `main`'s versions of all conflicting files.

#### For `.github/pull_request_template.md`:
- **Cursor's version**: Minimal template with Summary, Test Plan, Risks
- **Main's version**: Comprehensive template with Summary, Screenshots, Linked Issues, Checklist, Breaking Changes
- **Recommended**: Keep `main`'s version as it aligns better with project governance

#### Commands to resolve:
```bash
# From the cursor/pr-template-20251104 branch
git merge main --allow-unrelated-histories
git checkout --theirs .github/pull_request_template.md
git checkout --theirs .github/workflows/auto-merge-on-label.yml
git checkout --theirs .github/workflows/auto-open-pr-on-push.yml
git checkout --theirs .github/workflows/baseline-guard.yml
git checkout --theirs .github/workflows/merge-on-green.yml
git checkout --theirs README.md
git checkout --theirs scripts/auto_merge_claude.sh
git add .
git commit -m "chore: resolve merge conflicts with main branch

Resolved conflicts by accepting main branch's versions for all conflicting files.
This aligns the cursor branch with the current project state."
git push origin cursor/pr-template-20251104
```

### Option 2: Close PR #17
If the minimal PR template is no longer desired, PR #17 can be closed without merging. The comprehensive template from `main` is already in place.

## Resolution Details

### .github/pull_request_template.md
The resolved version keeps `main`'s comprehensive template which includes:
- Summary section with What/Why/How
- Screenshots/Evidence section
- Linked Issues
- Checklist for conventional commits, tests, docs, security
- Breaking changes section

This aligns with:
- PROJECT_CHARTER requirements for evidence-backed outputs
- AGENT_RESPONSE_POLICY requirements for artifacts and documentation
- Best practices for PR management

## Validation
After resolution, PR #17 should:
- Show no merge conflicts
- Pass all CI checks
- Be ready for review and merge

## Artifacts
- Resolution commit SHA: `fa6c39d` (local after running script)
- Resolved file: `/docs/pr17-conflict-resolution.md` (this document)
- Resolution script: `/scripts/resolve_pr17_conflicts.sh`
- Git bundle: `/artifacts/pr17-resolution.bundle`

## Using the Git Bundle
If you have a local copy of the repository and want to apply the resolution:

```bash
# Fetch the bundle
git fetch /path/to/pr17-resolution.bundle cursor/pr-template-20251104:cursor/pr-template-20251104-resolved

# Check out the resolved branch
git checkout cursor/pr-template-20251104-resolved

# Force push to the remote cursor branch (requires write access)
git push origin cursor/pr-template-20251104-resolved:cursor/pr-template-20251104 --force-with-lease
```
