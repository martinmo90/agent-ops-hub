# Merge Queue Policy

This repository uses a lightweight merge queue policy to keep `main` green and stable.

## Rules

1. **Required checks must pass**
   - Baseline Guard / verify
   - Branch Protection Scan / scan
   - PR Size Gate / size-gate
   - Conventional Commits / lint
   - Any additional project checks you mark as required

2. **PR size limits**
   - The PR Size Gate rejects unusually large changes (lines/files) unless explicitly exempted.

3. **Conventional Commits**
   - PR titles must follow `<type>(optional-scope): subject`, e.g. `feat(ui): add quick actions`.

4. **Auto-merge usage**
   - Auto-merge (squash) may be used when all required checks are green.
   - Dependabot PRs are auto-approved and auto-merged once checks are green.

5. **Branch hygiene**
   - Stale and merged branches are periodically scanned and cleaned via the Repo Tidy workflow (dry-run by default).

## Maintainer Quick Checklist

- Ensure required checks in **Settings → Branches → Branch protection rules** include the checks above.
- Use labels or the "Enable auto-merge" button when applicable.
- Re-run failed checks only after addressing the root cause (do not force-merge).
