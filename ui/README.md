# UI (Vite)

This folder must contain the actual app source (e.g. Base44 UI):

- `package.json` with scripts: `dev`, `build`, `preview`
- `src/` with your components and routes
- `index.html`
- Optionally: `vite.config.js`, `tailwind.config.js`

Vercel is configured (via the root vercel.json) to:
- install with `npm ci`
- build with `npm run build`
- publish the `dist/` folder
- rewrite all routes to `index.html` for SPA routing
