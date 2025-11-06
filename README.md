# Agent Ops Hub

Unified dashboard and tooling for AI agent operations.

## Overview

Agent Ops Hub is a collection of tools and dashboards designed to help manage, monitor, and interact with AI agent workflows. It includes:

- **Ops Dashboard** - UI-first monitoring dashboard for agent operations
- **shadcn-chatbot-kit** - Chat interface with Claude integration
- **Baseline Guard** - CI workflow for baseline file verification

## Getting Started

### Prerequisites

- Node.js 18+ and npm
- For shadcn-chatbot-kit: pnpm
- (Optional) PowerShell for Windows-specific scripts

### Quick Start

```bash
# Clone the repository
git clone https://github.com/martinmo90/agent-ops-hub.git
cd agent-ops-hub

# Install root dependencies
npm install
```

## Ops Dashboard

A dark-themed Next.js dashboard for monitoring agent operations, tasks, approvals, and runs.

### Features

- **Overview** - KPIs, recommended actions, and recent activity
- **Tasks** - Task management with status tracking
- **Approvals** - Review and approve agent requests
- **Artifacts** - Browse build outputs and generated files
- **Runs & Logs** - CI/CD pipeline history and execution logs
- **Settings** - Configure dashboard preferences

### Running Locally

**Option 1: Using npm scripts (cross-platform)**

```bash
# Install dependencies
npm run ops:install

# Start dev server (http://localhost:4000)
npm run ops:dev

# Build for production
npm run ops:build

# Start production server
npm run ops:start
```

**Option 2: Using PowerShell scripts (Windows)**

```powershell
cd apps/ops-dashboard

# Start dev server
./start.ps1

# Run tests
./test.ps1

# Build and package
./package.ps1
```

### Testing

```bash
# Run smoke tests
npm run ops:test
```

### Current Status

The Ops Dashboard is currently a **UI shell with mock data**. All data is loaded from JSON files in `apps/ops-dashboard/data/`. No backend integration is implemented yet.

## shadcn-chatbot-kit

A modern chat interface with support for Claude (Anthropic) and other AI providers.

### Running Locally

See [docs/shadcn-local-run.md](docs/shadcn-local-run.md) for detailed setup instructions.

**Quick start:**

```bash
# Install dependencies
npm run shadcn:install

# Apply Anthropic/Claude patch (optional)
npm run shadcn:anthropic:patch

# Copy environment template
cp config/shadcn-templates/.env.local.example apps/shadcn-chatbot-kit/apps/www/.env.local
# Edit .env.local and add your ANTHROPIC_API_KEY

# Start dev server (http://localhost:3333)
npm run shadcn:dev

# Run smoke test
npm run shadcn:test:hi
```

## Project Structure

```
agent-ops-hub/
├── apps/
│   ├── ops-dashboard/          # Next.js dashboard (port 4000)
│   │   ├── app/                # App Router pages
│   │   ├── components/ui/      # shadcn/ui components
│   │   ├── data/               # Mock JSON data
│   │   └── *.ps1               # PowerShell helper scripts
│   └── shadcn-chatbot-kit/     # Git submodule (port 3333)
├── config/
│   └── shadcn-templates/       # Templates for shadcn app
├── docs/                       # Documentation
├── scripts/                    # Automation scripts
├── tests/                      # Playwright tests
└── package.json                # Root workspace config
```

## Baseline Guard

Automated CI workflow that verifies the presence and validity of baseline files on every PR.

### Baseline Files

The following files are protected:

- `PROJECT_CHARTER.md`
- `AGENT_RESPONSE_POLICY.md`
- `baseline/ARTIFACT_COLLECTION.md`
- `baseline/CHANGE_LOG_PROTOCOL.md`
- `baseline/PR_REVIEW_PROTOCOL.md`
- `baseline/README.md`
- And others (see `.baseline-manifest.json`)

## Contributing

1. Create a feature branch with `claude/` prefix: `git checkout -b claude/feature-name-<session-id>`
2. Make your changes
3. Run tests: `npm run ops:test` and/or `npm run shadcn:test:hi`
4. Commit and push
5. Create a pull request

Branches with `claude/` prefix can be auto-merged by the auto-merge script when all checks pass.

## Scripts

### Root-level scripts

- `npm run ops:dev` - Start Ops Dashboard dev server
- `npm run ops:build` - Build Ops Dashboard
- `npm run ops:test` - Run Ops Dashboard smoke tests
- `npm run shadcn:dev` - Start shadcn-chatbot-kit dev server
- `npm run shadcn:test:hi` - Run shadcn greeting test
- `npm run shadcn:anthropic:patch` - Apply Claude patch to shadcn app

### Automation scripts

- `scripts/auto_merge_claude.sh` - Auto-merge claude/* PRs when checks pass

## License

Private repository - all rights reserved.
