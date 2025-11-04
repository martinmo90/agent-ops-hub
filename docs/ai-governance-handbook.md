# AI Governance Handbook — Agent Ops Hub

**Scope:** Rules for Atlas (ChatGPT, PM), Claude (engineer/tester), and Cursor (implementer), and GitHub automations.
**Default PR path:** GitHub Actions buttons (auto-open PR on push → policy gate → auto-merge).
**Timezone:** Australia/Perth (AWST).

## Roles
- **Owner (JinLin):** Priorities, acceptance, secrets/repo settings, final merge rights.
- **Atlas (PM):** Breaks goals → tasks; acceptance criteria; guardrails; daily summary.
- **Claude (Engineer/Tester):** Design & draft minimal patch + tests; write docs/exec summaries.
- **Cursor (Implementer):** Small, scoped diffs; run tests/lint; push; update PR; trigger Bugbot.

## Guardrails (must follow)
- Diff limit: ≤10 files and ≤500 changed lines. Exceed → STOP and ask.
- Any behavior change → add/adjust tests.
- PR body ≤12 lines and include **Summary / Test Plan (exact commands + expected) / Risks**.
- No secrets, PATs, or tokens in code or chat; use repo secrets or env.
- Evidence rule: numbers or claims without source → **WAIT** (don’t proceed).

## PR & Merge Procedure
1) Create branch `cursor/<task>-YYYYMMDD` from `main`.
2) Commit using Conventional Commits (feat/fix/docs/ci/chore).
3) Push: **Auto Open PR on push** creates PR to `main`.
4) Policy gate applies `automerge` for small, templated PRs; Bugbot runs on demand (`bugbot run`).
5) Checks green → auto-merge (or “Merge on green (manual)” button).
6) If stuck: run **Auto-merge Doctor** with `pr=<num>, fix=true`.

## When NOT to auto-merge
- Diff too large, risky migrations, config matrix changes, or any missing tests → remove `automerge` and request Owner review.

## Incident & Recovery
- If an automation fails (app token, queue), use Actions buttons:
  - **Open PR (manual)**, **Merge on green (manual)**.
- If policy blocks: add missing template lines or split the PR.

## Files of record
- `.github/workflows/*`: auto-open PR, policy, auto-merge, doctor, manual open/merge.
- `.cursor/rules.md`: agent behavior rules.
- `docs/agent-collab-charter.md`: roles & diary.
- `docs/ai-governance-handbook.md` (this).

## Versioning
- v1 (2025-11-04): Initial governance.
