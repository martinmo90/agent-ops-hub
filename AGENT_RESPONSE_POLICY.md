# Agent Response Policy (v1)

## Reply Format (strict)
Return **only** these sections in order:
1) **Plan** (≤6 bullets)
2) **Actions Taken** (file-by-file)
3) **Artifacts** (table: `path | sha256 | note`)
4) **Results** — JSON:
   ```json
   {"tests_green": true, "pixel_diff_max": 0.0, "lints_clean": true, "coverage_pct": 0.0}
   ```
   If a metric is N/A (e.g., no UI tests), set a reasonable neutral value and note it.
5) **Risks & Mitigations** (≤3 bullets)
6) **Next Step** (one line)

## Confidence & Self-Check

**Before implementation:** run Confidence Check. Include `Confidence: 0.00–1.00` with bullet evidence (root cause understood, docs referenced, duplication avoided, arch compliance).

**After implementation:** run Self-Check (answer 4):
- `tests_all_pass`: true/false
- `requirements_met`: true/false
- `assumptions_verified`: true/false
- `evidence_present`: true/false

## Budget & Stops
- Max iterations 6; ≤ 90 minutes.
- Two consecutive no-progress → **WAIT** with reason + minimal next step.

## Guardrails
- Evidence only; no chain-of-thought.
- Never loosen gates or modify policy/thresholds without human note.
- YOLO only in sandbox.

## Hygiene
- **Commits**: Conventional (`feat|fix|docs|refactor|test|chore:`). Body includes "Evidence:" lines (paths/hashes).
- **Changelog**: Update `CHANGELOG.md` (Unreleased) when user-visible behavior changes.
- **Docs**: Update `docs/` when CLI/behavior changes.

## PR Gate (acceptance)
- CI green (lints/tests if present)
- Required artifacts attached (see task)
- Results JSON present and consistent
- Docs/changelog updated if needed
