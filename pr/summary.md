# PR Summary

**Title:** chore: reapply agent-ops baseline

**Branch:** `claude/reapply-baseline-pr-011CUhCgFMAyJ8dgrZZHzByx`

**Base Branch:** `main`

**PR URL:** To be created

## Files Added

- `PROJECT_CHARTER.md` — Governance charter with objectives, success criteria, scope, guardrails, budget limits
- `AGENT_RESPONSE_POLICY.md` — Response policy with strict reply format, confidence/self-check gates, hygiene rules
- `.github/pull_request_template.md` — PR template requiring evidence, Results JSON, confidence scores
- `.github/workflows/claude_pr_review.yml` — Automated PR review workflow using Claude Code action
- `.claude/commands/pr-review.md` — Command for governed PR review
- `.claude/commands/testing_plan_integration.md` — Command for test-driven implementation workflow
- `.claude/commands/update-docs.md` — Command for minimal documentation updates
- `.claude/agents/context-manager.md` — Preflight agent for context assembly
- `artifacts/checks/context_report.json` — Context loading report
- `artifacts/checks/budget_plan.json` — Budget planning and tracking
- `manifest.json` — Task metadata and deliverable manifest
- `agentops_step01_baseline_20251101-0320.zip` — Deliverable archive

## Summary

This PR reapplies the agent-ops baseline configuration from commit `dfeed2c`, restoring:
- Governance documents (PROJECT_CHARTER.md, AGENT_RESPONSE_POLICY.md)
- Claude commands for PR review, testing, and documentation
- GitHub workflow for automated PR review
- Baseline artifacts and manifest

## How to Review

- Verify all governance documents (PROJECT_CHARTER.md, AGENT_RESPONSE_POLICY.md) define clear objectives, gates, and evidence requirements
- Confirm .claude/commands/ and .claude/agents/ provide reusable workflows for PR review, testing, docs, and context management
- Check that all baseline files from the original commit are present and correct
