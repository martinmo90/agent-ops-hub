# Local ChatOps Desk

Run a small local UI to chat with Claude and run GitHub tasks.

## Quick start
```bash
cd local-chatops
cp .env.example .env     # fill ANTHROPIC_API_KEY; (optional) GITHUB_PAT/OWNER/REPO
npm i
npm start
# open http://localhost:3000
```

## Features

- **Chat with Claude** (Anthropic API)
- **Create PR → main** (squash) and delete head (best-effort)
- **Live task log** (SSE), pause with "missing permission/secret" reason
- **No secrets are committed**. Keep `.env` local.
