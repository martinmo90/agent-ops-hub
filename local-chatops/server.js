import 'dotenv/config';
import express from 'express';
import fetch from 'node-fetch';
import { Octokit } from '@octokit/rest';
import path from 'path';
import { fileURLToPath } from 'url';

const __dirname = path.dirname(fileURLToPath(import.meta.url));
const app = express();
app.use(express.json());

// ==== simple in-memory task/log store + SSE ====
const tasks = new Map();      // id -> task
const clients = new Set();    // SSE connections

function send(evt) {
  const data = typeof evt === 'string' ? evt : JSON.stringify(evt);
  for (const res of clients) res.write(`data: ${data}\n\n`);
}

function makeTask(type, payload = {}) {
  const id = `t_${Date.now()}_${Math.random().toString(36).slice(2,8)}`;
  const t = { id, type, payload, status: 'queued', createdAt: new Date().toISOString(), logs: [] };
  tasks.set(id, t);
  send({ kind: 'new', id: t.id, task: t });
  setTimeout(() => run(t), 5);
  return t;
}

function log(t, level, msg, meta = {}) {
  const line = { ts: new Date().toISOString(), level, msg, meta };
  t.logs.push(line); send({ kind: 'log', id: t.id, line });
}
function setStatus(t, status, meta = {}) {
  t.status = status; t.meta = { ...(t.meta || {}), ...meta };
  send({ kind: 'status', id: t.id, status, meta: t.meta });
}

// ==== Claude ====
async function askClaude({ prompt }) {
  const key = process.env.ANTHROPIC_API_KEY;
  if (!key) throw Object.assign(new Error('Missing ANTHROPIC_API_KEY'), { code: 'NO_ANTHROPIC' });

  const body = {
    model: 'claude-3-opus-20240229',
    max_tokens: 800,
    messages: [{ role: 'user', content: prompt }]
  };

  const r = await fetch('https://api.anthropic.com/v1/messages', {
    method: 'POST',
    headers: {
      'x-api-key': key,
      'content-type': 'application/json',
      'anthropic-version': '2023-06-01'
    },
    body: JSON.stringify(body)
  });
  if (!r.ok) {
    const txt = await r.text();
    throw Object.assign(new Error(`Anthropic HTTP ${r.status}: ${txt}`), { code: 'ANTHROPIC_HTTP' });
  }
  const j = await r.json();
  return j?.content?.[0]?.text ?? '(no content)';
}

// ==== GitHub PR->main ====
async function prToMain(t, { head, base = 'main' }) {
  const token = process.env.GITHUB_PAT;
  const owner = process.env.GITHUB_OWNER;
  const repo  = process.env.GITHUB_REPO;

  if (!token || !owner || !repo) {
    const missing = [
      !token && 'GITHUB_PAT (repo scope)',
      !owner && 'GITHUB_OWNER',
      !repo  && 'GITHUB_REPO'
    ].filter(Boolean);
    setStatus(t, 'paused', { reason: 'missing-secret', required: missing });
    throw Object.assign(new Error(`Missing: ${missing.join(', ')}`), { code: 'MISSING_SECRET' });
  }

  const octo = new Octokit({ auth: token });

  log(t, 'info', 'Checking open PR');
  const open = await octo.pulls.list({ owner, repo, state: 'open', head: `${owner}:${head}`, base });
  let pr = open.data[0];

  if (!pr) {
    log(t, 'info', 'Creating PR');
    pr = (await octo.pulls.create({
      owner, repo, head, base,
      title: 'chore: auto PR to main',
      body: 'Automated PR from Local ChatOps Desk'
    })).data;
  } else {
    log(t, 'info', `Reusing PR #${pr.number}`);
  }

  // try merge (squash)
  log(t, 'info', `Squash-merge PR #${pr.number}`);
  try {
    await octo.pulls.merge({
      owner, repo, pull_number: pr.number,
      merge_method: 'squash',
      commit_title: 'chore: auto-merge via Local ChatOps'
    });
    log(t, 'ok', `Merged PR #${pr.number}`);
  } catch (e) {
    if (e.status === 401 || e.status === 403) {
      setStatus(t, 'paused', { reason: 'insufficient-scope', required: ['GITHUB_PAT: repo scope'] });
    }
    throw e;
  }

  // best-effort delete head
  try {
    await octo.git.deleteRef({ owner, repo, ref: `heads/${head}` });
    log(t, 'ok', `Deleted branch ${head}`);
  } catch {
    log(t, 'warn', `Could not delete branch ${head} (protected?)`);
  }

  return { prNumber: pr.number, url: pr.html_url };
}

// ==== runner ====
async function run(t) {
  setStatus(t, 'running');
  try {
    if (t.type === 'chat') {
      log(t, 'info', 'Sending prompt to Claude');
      const text = await askClaude({ prompt: t.payload.prompt });
      log(t, 'ok', 'Claude replied', { preview: text.slice(0,160) });
      setStatus(t, 'done', { result: text });
    } else if (t.type === 'pr-to-main') {
      const res = await prToMain(t, t.payload);
      setStatus(t, 'done', res);
    } else {
      throw new Error(`Unknown task type: ${t.type}`);
    }
  } catch (e) {
    if (t.status !== 'paused') {
      log(t, 'error', e.message);
      setStatus(t, 'failed', { code: e.code || 'ERR' });
    }
  }
}

// ==== routes/SSE ====
app.get('/api/events', (req, res) => {
  res.setHeader('Content-Type', 'text/event-stream');
  res.setHeader('Cache-Control', 'no-cache');
  res.setHeader('Connection', 'keep-alive');
  res.flushHeaders();
  clients.add(res);
  req.on('close', () => clients.delete(res));
});

app.get('/api/tasks', (req, res) => res.json([...tasks.values()]));
app.post('/api/tasks/chat', (req, res) => res.json(makeTask('chat', { prompt: req.body?.prompt || '' })));
app.post('/api/tasks/pr-to-main', (req, res) => res.json(makeTask('pr-to-main', { head: req.body?.head, base: req.body?.base })));

app.use('/', express.static(path.join(__dirname, 'web')));

const PORT = 3000;
app.listen(PORT, () => console.log(`Local ChatOps Desk at http://localhost:${PORT}`));
