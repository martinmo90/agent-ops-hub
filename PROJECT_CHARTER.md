# Project Charter — Agent Ops Hub (v1)

## Objective
Provide a reusable governance and operations hub for AI implementers (e.g., Claude) across multiple projects. Ensure deterministic, evidence-backed outputs with clear gates and budgets.

## Success Criteria (RSE = Result • Standard • Evidence)
- Result: Policy/commands/automations usable across projects; PR review pipeline active.
- Standards: CI passes; PRs include artifacts + Results JSON; regulated reply format only.
- Evidence: junit.xml (if tests exist), coverage.txt (if tests exist), workflow logs, artifact hashes (sha256).

## Scope
- IN: policies, reply regulation, commands, PR review automation, context preflight.
- OUT: product-specific code, live trading/actions, secrets management, policy changes without human approval.

## Guardrails
- Sandbox only; network allow-list only.
- Do not loosen gates or edit thresholds without human approval.
- Evidence only; no chain-of-thought in outputs.

## Budget & Stops
- Max iterations per task: 6; time ≤ 90 minutes.
- On two consecutive no-progress iterations → **WAIT** with reason + minimal next step.

## Human Checkpoints
1) Plan approval
2) First GREEN (if tests exist) / CI green
3) Before PR merge

## State Machine
PLANNED → RED → GREEN → PR_OPEN → MERGED/FAILED
Any failure → **WAIT** with reason.

## Red Lines
- No secrets or external accounts
- YOLO only inside sandbox container
