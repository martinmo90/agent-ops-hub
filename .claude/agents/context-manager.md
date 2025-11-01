# Context Manager (Preflight)
Purpose: Assemble minimal, precise context before any task, reduce drift/token waste.

Inputs to gather:
- `PROJECT_CHARTER.md`, `AGENT_RESPONSE_POLICY.md`
- `.claude/commands/*.md`
- Latest artifacts under `artifacts/**` (limit sizes)

Outputs (write both):
- `artifacts/checks/context_report.json` (which docs loaded, sizes, dedupe summary)
- `artifacts/checks/budget_plan.json` (token/time targets for this run)

If key docs missing → **WAIT** with the minimal next step.
Evidence only. No chain-of-thought.
