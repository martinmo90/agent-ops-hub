# shadcn-chatbot-kit (local run)

## Prerequisites
- Node 18+ (LTS)
- pnpm (npm install -g pnpm)
- Your Anthropic API key (or Groq API key for current upstream version)

## Important Note
The current upstream shadcn-chatbot-kit uses Groq (Llama models) by default. To use Anthropic/Claude, you'll need a modified `apps/www/app/api/chat/route.ts` that supports the Anthropic provider.

## First Run
```bash
# 1. Install submodule dependencies
npm run shadcn:install

# 2. Copy environment template
cp config/shadcn-templates/.env.local.example apps/shadcn-chatbot-kit/apps/www/.env.local

# 3. Edit apps/shadcn-chatbot-kit/apps/www/.env.local
# Add your ANTHROPIC_API_KEY (or GROQ_API_KEY for default setup)

# 4. Start the dev server
npm run shadcn:dev
```

The app will start on **http://localhost:3333** (note: port 3333, not 3000)

## Sanity Test (automated)
In another terminal (from repo root):

```bash
# Install Playwright browsers (first time only)
npx playwright install chromium

# Run the automated greeting test
npm run shadcn:test:hi
```

This test:
- Opens the chat UI
- Types "Say hi to me, please."
- Waits for a response containing "hi", "hello", or "hey"
- Passes if the chatbot responds appropriately

## Custom Port
If you change the port in `apps/shadcn-chatbot-kit/apps/www/package.json`, update the test:

```bash
SHADCN_URL=http://localhost:3001 npm run shadcn:test:hi
```

## Troubleshooting

### No response from chatbot
- Check that `.env.local` exists and has your API key
- Verify the API key is valid
- Check browser console (F12) for errors

### Port already in use
The app uses port 3333 by default. If this port is busy:
1. Stop other services on 3333, or
2. Edit `apps/shadcn-chatbot-kit/apps/www/package.json` and change the port in the `dev` script
