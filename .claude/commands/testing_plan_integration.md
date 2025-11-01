# /testing_plan_integration
Goal: Plan-first → (tests if present) → implement → integrate → evidence.

Steps:
1) Plan (≤6 bullets) with smallest slice to green.
2) If tests exist/are appropriate, add failing tests → implement → green.
3) Produce artifacts (junit.xml, coverage.txt if tests; logs otherwise) with sha256.
4) Update docs if behavior changed.
5) Return regulated reply sections only.

Stop when Results JSON shows CI green and required artifacts present. Otherwise **WAIT** with minimal next step.
