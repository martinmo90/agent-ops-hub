# Cursor Check File

## Overview

This file (`docs/cursor-check.md`) serves a dual purpose:
1. **Self-documenting**: It documents the cursor check file concept
2. **Verification Artifact**: Its existence proves Cursor AI agent has write access to the repository

This file is a lightweight verification mechanism that confirms the Cursor AI agent can successfully create documentation files. It serves as a canary for CI/CD workflows that depend on agent-generated content.

## Purpose

This file verifies:
- **Write Access**: Cursor AI agent can create and modify files in the `docs/` directory
- **CI Integration**: The file passes through the Baseline Guard workflow validation
- **Documentation Standards**: Agent-generated files follow repository documentation conventions

## Relation to Baseline Guard Workflow

The Baseline Guard workflow (`baseline-guard.yml`) automatically verifies the presence and validity of critical repository files on every pull request. While the cursor check file is not a protected baseline artifact, it demonstrates that:

1. **Agent Operations Work**: The Cursor agent can successfully create documentation
2. **CI Pipeline Intact**: Files created by agents pass through workflow validation
3. **File System Access**: No permission or access issues prevent agent file creation

### How Baseline Guard Works

The Baseline Guard workflow:
1. Checks out the repository
2. Reads `manifest.json` to get the list of protected baseline files
3. Verifies each baseline file exists
4. Fails the check if any baseline files are missing

Protected baseline files include:
- `PROJECT_CHARTER.md`
- `AGENT_RESPONSE_POLICY.md`
- `.claude/commands/pr-review.md`
- And others listed in `manifest.json`

## Verification

To verify the cursor check file is working correctly:

```bash
# Check the file exists
ls -l docs/cursor-check.md

# Verify Baseline Guard workflow passes
# (This runs automatically on PRs, or can be triggered manually via workflow_dispatch)
```

## Testing

When making changes that affect agent file creation or documentation:

1. Create or modify the cursor check file
2. Push changes to a feature branch
3. Open a pull request
4. Verify the "Baseline Guard / verifyExpected" workflow passes
5. Confirm no file access errors in CI logs

## Troubleshooting

### Cursor Agent Write Access Issues

If you suspect the Cursor agent cannot write to the repository:
- Check repository permissions for the agent
- Verify file system permissions on the `docs/` directory
- Test by asking the agent to create or modify a test file
- Check CI logs for permission-related errors

If this documentation file is missing or corrupted:
- It indicates a problem with agent file creation capabilities
- Recreate it in `docs/cursor-check.md` with proper markdown content
- Verify the agent has write access before continuing work

### CI Workflow Failures

If the Baseline Guard workflow fails:
- Check `manifest.json` is present and valid JSON
- Verify all baseline files listed in manifest exist
- Review workflow logs for specific missing files
- Ensure file paths are correct (case-sensitive on Linux)

## Related Files

- `.github/workflows/baseline-guard.yml` - Baseline verification workflow
- `manifest.json` - List of protected baseline artifacts
- `.cursor/rules.md` - Cursor agent behavior rules
- `docs/ai-governance-handbook.md` - Agent governance policies

## Version History

- v1.0 (2025-11-06): Initial documentation for cursor check file
