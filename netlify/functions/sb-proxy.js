// ============================================================
// GrailISO — Supabase REST Proxy
// netlify/functions/sb-proxy.js
// ============================================================
// Proxies Supabase REST API calls so the anon key stays
// server-side. Client sends its JWT; this function validates
// it and forwards the request with proper auth.
//
// SETUP: SUPABASE_URL + SUPABASE_ANON_KEY in Netlify env vars
// ============================================================

exports.handler = async (event) => {
  const headers = {
    'Access-Control-Allow-Origin': 'https://grailiso.com',
    'Access-Control-Allow-Headers': 'Content-Type, Authorization, X-SB-Route, X-SB-Method, Prefer',
    'Access-Control-Allow-Methods': 'POST, OPTIONS',
    'Content-Type': 'application/json',
  };

  if (event.httpMethod === 'OPTIONS') {
    return { statusCode: 200, headers, body: '' };
  }

  if (event.httpMethod !== 'POST') {
    return { statusCode: 405, headers, body: JSON.stringify({ error: 'Method not allowed' }) };
  }

  // Extract the user's JWT from Authorization header
  const authHeader = event.headers['authorization'] || event.headers['Authorization'] || '';
  const userToken = authHeader.replace(/^Bearer\s+/i, '');

  if (!userToken) {
    return { statusCode: 401, headers, body: JSON.stringify({ error: 'Missing authorization token' }) };
  }

  const supabaseUrl = process.env.SUPABASE_URL || 'https://jyfaegmnzkarlcximxjo.supabase.co';
  const supabaseAnonKey = process.env.SUPABASE_ANON_KEY;

  if (!supabaseAnonKey) {
    return { statusCode: 500, headers, body: JSON.stringify({ error: 'Server configuration error' }) };
  }

  try {
    const { route, method, body: reqBody, prefer } = JSON.parse(event.body || '{}');

    if (!route) {
      return { statusCode: 400, headers, body: JSON.stringify({ error: 'Missing route' }) };
    }

    // Sanitize: route must start with /rest/v1/ and not contain path traversal
    if (!route.startsWith('/rest/v1/') || route.includes('..')) {
      return { statusCode: 400, headers, body: JSON.stringify({ error: 'Invalid route' }) };
    }

    const fetchMethod = (method || 'GET').toUpperCase();
    if (!['GET', 'POST', 'PATCH', 'DELETE'].includes(fetchMethod)) {
      return { statusCode: 400, headers, body: JSON.stringify({ error: 'Invalid method' }) };
    }

    const fetchHeaders = {
      'apikey': supabaseAnonKey,
      'Authorization': `Bearer ${userToken}`,
      'Content-Type': 'application/json',
    };
    if (prefer) fetchHeaders['Prefer'] = prefer;

    const fetchOpts = {
      method: fetchMethod,
      headers: fetchHeaders,
    };
    if (reqBody && (fetchMethod === 'POST' || fetchMethod === 'PATCH')) {
      fetchOpts.body = JSON.stringify(reqBody);
    }

    const res = await fetch(`${supabaseUrl}${route}`, fetchOpts);

    // Forward the response
    const contentType = res.headers.get('content-type') || '';
    let responseBody;
    if (contentType.includes('application/json')) {
      responseBody = JSON.stringify(await res.json());
    } else {
      responseBody = await res.text();
    }

    return {
      statusCode: res.status,
      headers: { ...headers, 'Content-Type': contentType || 'application/json' },
      body: responseBody,
    };
  } catch (err) {
    console.error('SB proxy error:', err);
    return {
      statusCode: 500,
      headers,
      body: JSON.stringify({ error: err.message }),
    };
  }
};
