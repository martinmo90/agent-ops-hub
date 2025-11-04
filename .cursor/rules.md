# Cursor Rules (enforced by policy)
- Work only on selected branch (announce it).
- Before editing: print planned file list and rationale.
- Keep diffs ≤10 files and ≤500 changed lines; else STOP and ask.
- Use Conventional Commits.
- Update PR body to include: Summary / Test Plan (commands + expected) / Risks (≤12 lines).
- Prefer Actions buttons for PR/merge. If PR create fails, return the `/pull/new/<branch>` link—do **not** retry endlessly.
- Never add secrets/PATs. Use repo secrets/env only.
- On failures: print exact command, observed vs expected, and minimal fix plan.
