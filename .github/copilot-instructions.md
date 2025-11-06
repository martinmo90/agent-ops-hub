# Copilot Instructions for Agent Ops Hub

## Project Overview

Agent Ops Hub is a unified dashboard and tooling suite for AI agent operations. It provides monitoring, management, and interaction tools for AI agent workflows.

### Key Components

- **Ops Dashboard** (`apps/ops-dashboard/`) - Next.js-based monitoring dashboard (port 4000)
- **shadcn-chatbot-kit** (`apps/shadcn-chatbot-kit/`) - Git submodule for chat interface with Claude integration (port 3333)
- **Baseline Guard** - CI workflow for baseline file verification
- **Automation Scripts** - Helper scripts for CI/CD and workflow automation

## Repository Structure

This is a monorepo with the following structure:

```
agent-ops-hub/
├── .github/               # GitHub configuration, workflows, templates
├── apps/
│   ├── ops-dashboard/     # Next.js dashboard (TypeScript, React 18)
│   └── shadcn-chatbot-kit/ # Git submodule (separate repo)
├── config/                # Configuration templates
├── docs/                  # Project documentation
├── scripts/               # Automation scripts (Bash, Python)
├── tests/                 # Playwright E2E tests
├── package.json           # Root workspace configuration
└── Makefile              # Build automation targets
```

## Technology Stack

### Ops Dashboard
- **Framework:** Next.js 14 (App Router)
- **Language:** TypeScript 5.6+
- **UI Library:** React 18
- **Styling:** Tailwind CSS, shadcn/ui components
- **Testing:** Playwright (smoke tests)
- **Package Manager:** npm

### shadcn-chatbot-kit (Submodule)
- **Package Manager:** pnpm
- **Framework:** Next.js
- **Integration:** Anthropic Claude API

### Testing
- **E2E Testing:** Playwright
- **Test Files:** `tests/*.spec.ts`

## Build and Test Commands

### Root Level
```bash
# Install dependencies
npm install

# Ops Dashboard
npm run ops:install     # Install dependencies
npm run ops:dev         # Start dev server (http://localhost:4000)
npm run ops:build       # Build for production
npm run ops:start       # Start production server
npm run ops:test        # Run Playwright smoke tests

# shadcn-chatbot-kit
npm run shadcn:install  # Install dependencies (uses pnpm)
npm run shadcn:dev      # Start dev server (http://localhost:3333)
npm run shadcn:test:hi  # Run greeting test
```

### PowerShell Scripts (Windows, Ops Dashboard)
```powershell
cd apps/ops-dashboard
./start.ps1    # Start dev server
./test.ps1     # Run tests
./package.ps1  # Build and package
```

## Coding Standards

### General Principles
- **Minimize Changes:** Make the smallest possible modifications to achieve the goal
- **Preserve Working Code:** Never delete/modify working code unless absolutely necessary
- **Focus on Task:** Ignore unrelated bugs or broken tests
- **Use Existing Tools:** Prefer ecosystem tools (npm, linters) over manual changes

### TypeScript/JavaScript
- Use TypeScript for all new code in ops-dashboard
- Follow existing code style and patterns
- Use functional components with React hooks
- Prefer `const` over `let`, avoid `var`
- Use meaningful variable names (camelCase)
- Keep functions small and focused

### React/Next.js
- Use Next.js App Router conventions (app directory)
- Place UI components in `components/ui/`
- Use shadcn/ui component patterns
- Leverage server components where appropriate
- Follow Next.js file-based routing

### Styling
- Use Tailwind CSS utility classes
- Follow existing dark theme patterns
- Use CSS variables for theme customization
- Maintain responsive design

### Comments
- Add comments only when they match existing style or explain complex logic
- Prefer self-documenting code over excessive comments
- Update JSDoc comments when modifying function signatures

## Commit Message Format

Use **Conventional Commits** format:

```
<type>: <description>

[optional body]

Evidence: <paths/hashes>
```

### Types
- `feat:` - New feature
- `fix:` - Bug fix
- `docs:` - Documentation changes
- `refactor:` - Code refactoring
- `test:` - Test additions/changes
- `chore:` - Maintenance tasks
- `ci:` - CI/CD changes

### Examples
```
feat: add task filtering to dashboard

docs: update setup instructions for Windows

fix: resolve port conflict in dev server

test: add smoke test for approvals page
```

## PR Workflow and Policies

### Branch Naming
- Use `claude/` prefix for agent-created branches: `claude/feature-name-<session-id>`
- These branches can be auto-merged when checks pass

### PR Requirements
- ✅ CI must pass (all workflows)
- ✅ Required artifacts attached (if applicable)
- ✅ Results JSON present (if required by policy)
- ✅ Documentation updated (if behavior changes)
- ✅ Tests pass (if test infrastructure exists)
- ✅ No security vulnerabilities introduced

### PR Template
The repository includes a PR template (`.github/pull_request_template.md`) - use it for all PRs.

### Auto-Merge
- PRs from `claude/*` branches auto-merge when all checks pass
- Use `scripts/auto_merge_claude.sh` for automation

## Important Project Files

### Governance Documents
- **PROJECT_CHARTER.md** - Project objectives, scope, guardrails, and success criteria
- **AGENT_RESPONSE_POLICY.md** - Strict reply format, confidence checks, and quality gates
- **AGENT_RESPONSE_POLICY.md specifies:**
  - Maximum 6 iterations per task
  - 90-minute time limit
  - Evidence-only responses (no chain-of-thought in outputs)
  - Required sections: Plan, Actions, Artifacts, Results JSON, Risks, Next Step

### Key Requirements from Policy
1. **Never loosen gates** or modify policy/thresholds without human approval
2. **YOLO only in sandbox** - experimental changes allowed only in test environments
3. **Two consecutive no-progress iterations** → WAIT with reason
4. **Update CHANGELOG.md** when user-visible behavior changes
5. **Update docs/** when CLI/behavior changes

## Baseline Files (Protected)

These files are protected by the Baseline Guard CI workflow:
- `PROJECT_CHARTER.md`
- `AGENT_RESPONSE_POLICY.md`
- Files listed in `.baseline-manifest.json`

Do not modify these without human review and approval.

## Testing Strategy

### Current State
- Ops Dashboard: Uses **mock data** from JSON files (`apps/ops-dashboard/data/`)
- No backend integration implemented yet
- Smoke tests verify basic functionality

### Test Locations
- E2E tests: `tests/*.spec.ts`
- Run with Playwright: `npm run ops:test` or `npm run shadcn:test:hi`

### Adding Tests
- Create focused tests that validate specific changes
- Use Playwright for E2E testing
- Follow existing test patterns in `tests/` directory
- If no test infrastructure exists for a feature, skip tests per minimal-change policy

## Libraries and Dependencies

### Adding Dependencies
- **Prefer existing libraries** over adding new ones
- Only add new libraries if absolutely necessary
- Use npm for ops-dashboard dependencies
- Use pnpm for shadcn-chatbot-kit dependencies

### Updating Dependencies
- Avoid updating library versions unless required for a fix
- Test thoroughly after dependency updates

## Linting and Code Quality

### Linters
```bash
# Ops Dashboard
cd apps/ops-dashboard
npm run lint
```

### Pre-PR Checklist
- [ ] Code linted (no errors)
- [ ] Tests pass
- [ ] Build succeeds
- [ ] Documentation updated (if needed)
- [ ] Commit messages follow conventions

## Security

- **Never commit secrets** or API keys
- **Use environment variables** for sensitive configuration
- **Template files** available in `config/` for environment setup
- **.gitignore** properly excludes `.env.local` files
- **Validate all changes** don't introduce security vulnerabilities

## Git Submodules

The `shadcn-chatbot-kit` is a git submodule:
```bash
# Initialize and update submodules
git submodule update --init --recursive

# Working with submodule
cd apps/shadcn-chatbot-kit
git checkout main
git pull
```

## Environment Setup

### Ops Dashboard
No special environment setup required for development.

### shadcn-chatbot-kit
1. Copy environment template:
   ```bash
   cp config/shadcn-templates/.env.local.example apps/shadcn-chatbot-kit/apps/www/.env.local
   ```
2. Add your `ANTHROPIC_API_KEY` to `.env.local`
3. Apply Claude patch (optional):
   ```bash
   npm run shadcn:anthropic:patch
   ```

## Additional Resources

- **Documentation:** See `docs/` directory
  - `ai-governance-handbook.md` - AI governance guidelines
  - `shadcn-local-run.md` - Detailed shadcn setup
- **Scripts:** See `scripts/` directory for automation tools
- **Workflows:** See `.github/workflows/` for CI/CD pipelines

## Special Notes

### Working with Ops Dashboard
- The dashboard currently displays **mock data only**
- Data loaded from JSON files in `apps/ops-dashboard/data/`
- Backend integration is planned but not yet implemented

### Port Assignments
- Ops Dashboard: `http://localhost:4000`
- shadcn-chatbot-kit: `http://localhost:3333`

### Platform-Specific Tooling
- PowerShell scripts (`.ps1`) are available for Windows users
- Cross-platform npm scripts work on all platforms
- Prefer npm scripts for CI/CD environments

## Best Practices Summary

1. **Minimal Changes** - Only modify what's necessary
2. **Follow Existing Patterns** - Match the style and structure of existing code
3. **Test Early and Often** - Validate changes incrementally
4. **Document Changes** - Update docs when behavior changes
5. **Respect Governance** - Follow PROJECT_CHARTER.md and AGENT_RESPONSE_POLICY.md
6. **Security First** - Never commit secrets, always validate for vulnerabilities
7. **Use Ecosystem Tools** - Leverage npm, linters, formatters over manual changes
8. **Conventional Commits** - Follow commit message standards
9. **Evidence-Based** - Provide concrete evidence for all changes (test results, artifacts)
10. **Human Checkpoints** - Wait for human approval at plan, first green, and merge stages
