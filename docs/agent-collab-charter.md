# Agent Collaboration Charter & Diary

**Repo:** martinmo90/agent-ops-hub  
**Timezone:** Australia/Perth (AWST)  
**Purpose:** Define roles, guardrails, and daily operating cadence for ChatGPT (Atlas, PM), Claude (engineer/tester), and Cursor (repo implementer), converging toward one interface while keeping changes auditable via GitHub.

## Roles & Responsibilities
- **Owner (JinLin):**
  - Sets priorities & acceptance criteria; owns secrets and repo settings; approves merges/releases.
- **Atlas (ChatGPT) — Project/Product Manager:**
  - Breaks goals into tasks; writes acceptance criteria; enforces guardrails; runs post-mortems; summarizes status to Owner.
- **Claude — Engineer/Tester:**
  - Designs & drafts code; proposes minimal patch sets; writes/updates tests; produces HTML/exec summaries.
- **Cursor — Implementer/PR Hygiene:**
  - Applies small diffs; runs tests/lint; pushes commits; updates PRs; triggers Bugbot reviews.
- **GitHub Actions (Buttons):**
  - **Open PR (manual)** and **Merge on green (manual)** are the default PR/merge path; no app/PAT required.
- **Bugbot (optional):**
  - PR review bot; triggered with comment `bugbot run`.

## Operating Protocol
1. **Ticket (GitHub Issue)** includes: Goal; “Done when”; Test Plan (commands + expected).
2. **Claude (design):** Propose minimal patch; list files; add/adjust tests; supply Conventional Commit message.
3. **Cursor (apply):** Work on branch; preview planned files; keep diffs ≤10 files/≤500 LOC; commit; update PR body.
4. **Review:** Run tests; trigger **Bugbot**; address comments.
5. **Merge:** Use **Merge on green (manual)** when checks are clean.

## Guardrails
- Diff >10 files or >500 LOC → stop and ask.
- Any behavior change **requires tests**.
- PR body ≤12 lines: **Summary, Test Plan (exact commands + expected), Risks**.
- No secrets in code; use repo secrets/env.
- Evidence rule: numbers/data without source → **WAIT**.

## Tooling & Integrations
- Default PR/merge via **Actions buttons** for stability.
- Cursor GitHub App is “best effort”; if PR creation fails, use Actions/Open PR and continue.

## Diary (daily)
Template for each entry:
- **Date (YYYY-MM-DD AWST):**
- **Tickets:** #… 
- **What shipped (links):**
- **Decisions:** …
- **Risks/blocks:** …
- **Next 24h:** …
- **KPIs:** lead time, CI first-pass rate, Bugbot findings, avg diff size, governance pass.

### Example
- **Date:** 2025-11-04 (AWST)
- **Tickets:** #13
- **What shipped:** Added CI to build/upload zipped artifact for dashboard (PR #13).
- **Decisions:** Use Actions buttons as default PR path.
- **Risks/blocks:** Cursor App PR perms flaky (bypassed).
- **Next 24h:** Add exec summary to HTML; wire daily PCS summary.
- **KPIs:** Lead time 1d; CI green on 2nd run; Bugbot flagged 1 minor.

## Change Log
- 2025-11-04: Initial charter & diary created.
