# Merge Queue Policy

- **Strategy**: Squash merge.
- **Required checks**: Baseline Guard / verify, PR Size Gate / size-gate, Branch Protection Scan / scan.
- **Up-to-date**: Require branches to be up to date before merging.
- **Auto-merge**: Allowed for Dependabot PRs and PRs labeled `automerge`.
- **Protected branch names**: main, master, develop, dev, release, stable, prod, production.
