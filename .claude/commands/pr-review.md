# /pr-review
Goal: Perform a governed PR review using Charter & Policy.

Steps:
- Read `PROJECT_CHARTER.md` and `AGENT_RESPONSE_POLICY.md`.
- Validate presence & consistency of:
  - Results JSON, required artifacts (paths + sha256)
  - CI status, lint/test results (if present)
  - Docs/changelog if behavior changed
- Report:
  - **Acceptance**: yes/no + blockers
  - **Findings**: bullets
  - **Requested changes**: bullets (precise)
- Evidence only. No chain-of-thought.
