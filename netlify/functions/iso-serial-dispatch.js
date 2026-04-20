// ============================================================
// ISOSerial — manual crawl trigger
// netlify/functions/iso-serial-dispatch.js
// ============================================================
// Admin clicks "Run crawl now" in the Serial Queue panel → this
// function hits GitHub's workflow_dispatch endpoint to kick off
// iso-serial.yml immediately (instead of waiting for the next
// 30-min cron tick).
//
// Requires Netlify env var:
//   GITHUB_DISPATCH_TOKEN  — fine-grained PAT with Actions:write
//                            on jsmcdonald25-cpu/isoSANDBOX
// ============================================================

const https = require('https');

const SB_URL = process.env.SUPABASE_URL || 'https://jyfaegmnzkarlcximxjo.supabase.co';
const SB_SERVICE = process.env.SUPABASE_SERVICE_ROLE_KEY || process.env.SUPABASE_SERVICE_KEY;
const GH_TOKEN = process.env.GITHUB_DISPATCH_TOKEN;

const REPO_OWNER = 'jsmcdonald25-cpu';
const REPO_NAME  = 'isoSANDBOX';
const WORKFLOW   = 'iso-serial.yml';

function httpJson(url, opts = {}) {
  return new Promise((resolve, reject) => {
    const u = new URL(url);
    const req = https.request({
      hostname: u.hostname,
      path: u.pathname + u.search,
      method: opts.method || 'GET',
      headers: opts.headers || {},
    }, (res) => {
      let data = '';
      res.on('data', c => data += c);
      res.on('end', () => {
        let parsed = null;
        try { parsed = data ? JSON.parse(data) : null; } catch (_) {}
        resolve({ status: res.statusCode, json: parsed, raw: data });
      });
    });
    req.on('error', reject);
    if (opts.body) req.write(opts.body);
    req.end();
  });
}

async function verifyAdmin(authHeader) {
  if (!authHeader || !authHeader.startsWith('Bearer ')) return null;
  const token = authHeader.slice(7);
  const me = await httpJson(`${SB_URL}/auth/v1/user`, {
    headers: { 'apikey': SB_SERVICE, 'Authorization': `Bearer ${token}` },
  });
  if (me.status !== 200 || !me.json?.id) return null;
  const prof = await httpJson(
    `${SB_URL}/rest/v1/profiles?id=eq.${me.json.id}&select=role,is_admin,is_provenance_admin&limit=1`,
    { headers: { 'apikey': SB_SERVICE, 'Authorization': `Bearer ${SB_SERVICE}` } }
  );
  const p = prof.json?.[0];
  if (!p) return null;
  if (p.role !== 'owner' && p.is_admin !== true) return null;
  return { ...me.json, ...p };
}

exports.handler = async (event) => {
  const cors = {
    'Access-Control-Allow-Origin': '*',
    'Access-Control-Allow-Headers': 'Content-Type, Authorization',
    'Access-Control-Allow-Methods': 'POST, OPTIONS',
  };
  if (event.httpMethod === 'OPTIONS') return { statusCode: 204, headers: cors, body: '' };
  if (event.httpMethod !== 'POST')   return { statusCode: 405, headers: cors, body: 'Method not allowed' };

  if (!GH_TOKEN)  return { statusCode: 500, headers: cors, body: JSON.stringify({ error: 'GITHUB_DISPATCH_TOKEN not set in Netlify env' }) };
  if (!SB_SERVICE) return { statusCode: 500, headers: cors, body: JSON.stringify({ error: 'SUPABASE_SERVICE_ROLE_KEY not set' }) };

  const admin = await verifyAdmin(event.headers.authorization || event.headers.Authorization);
  if (!admin) return { statusCode: 403, headers: cors, body: JSON.stringify({ error: 'Admin auth required' }) };

  // Fire the workflow_dispatch event.
  const res = await httpJson(
    `https://api.github.com/repos/${REPO_OWNER}/${REPO_NAME}/actions/workflows/${WORKFLOW}/dispatches`,
    {
      method: 'POST',
      headers: {
        'Authorization': `Bearer ${GH_TOKEN}`,
        'Accept': 'application/vnd.github+json',
        'X-GitHub-Api-Version': '2022-11-28',
        'User-Agent': 'isosandbox-admin',
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({ ref: 'main' }),
    }
  );

  // GitHub returns 204 No Content on success.
  if (res.status === 204) {
    return {
      statusCode: 200,
      headers: { ...cors, 'Content-Type': 'application/json' },
      body: JSON.stringify({
        ok: true,
        message: 'Crawl queued. GitHub Actions picks it up within ~30s.',
        workflow_url: `https://github.com/${REPO_OWNER}/${REPO_NAME}/actions/workflows/${WORKFLOW}`,
        triggered_by: admin.username || admin.email || 'admin',
        triggered_at: new Date().toISOString(),
      }),
    };
  }

  return {
    statusCode: 502,
    headers: { ...cors, 'Content-Type': 'application/json' },
    body: JSON.stringify({
      ok: false,
      error: 'GitHub dispatch failed',
      gh_status: res.status,
      gh_response: res.json || res.raw?.slice(0, 500),
    }),
  };
};
