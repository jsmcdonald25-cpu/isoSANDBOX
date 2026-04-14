// ============================================================
// GrailISO — Send Alpha Invite (Magic Link)
// netlify/functions/send-alpha-invite.js
// ============================================================
// Called from admin.html when approving an alpha signup.
// Uses Supabase Admin API to invite user by email — sends a
// magic link they can click to create their account instantly.
//
// SETUP: Set SUPABASE_SERVICE_KEY in Netlify env vars
//        (Dashboard → Settings → API → service_role key)
// ============================================================

const { verifyAuth } = require('./utils/verify-auth');

exports.handler = async (event) => {
  const headers = {
    'Access-Control-Allow-Origin': 'https://grailiso.com',
    'Access-Control-Allow-Headers': 'Content-Type, Authorization',
    'Access-Control-Allow-Methods': 'POST, OPTIONS',
    'Content-Type': 'application/json',
  };

  if (event.httpMethod === 'OPTIONS') {
    return { statusCode: 200, headers, body: '' };
  }

  if (event.httpMethod !== 'POST') {
    return { statusCode: 405, headers, body: JSON.stringify({ error: 'Method not allowed' }) };
  }

  // ── Auth: verify the caller is a logged-in admin ──
  const authedUser = await verifyAuth(event);
  if (!authedUser) {
    return { statusCode: 401, headers, body: JSON.stringify({ error: 'Unauthorized' }) };
  }

  // Check admin status via profile
  const supabaseUrl = process.env.SUPABASE_URL || 'https://jyfaegmnzkarlcximxjo.supabase.co';
  const supabaseServiceKey = process.env.SUPABASE_SERVICE_KEY;
  if (supabaseServiceKey) {
    const profRes = await fetch(`${supabaseUrl}/rest/v1/profiles?id=eq.${authedUser.id}&select=is_admin,role&limit=1`, {
      headers: { 'apikey': supabaseServiceKey, 'Authorization': `Bearer ${supabaseServiceKey}` },
    });
    const profiles = await profRes.json();
    const p = profiles && profiles[0];
    if (!p || (p.is_admin !== true && p.role !== 'owner')) {
      return { statusCode: 403, headers, body: JSON.stringify({ error: 'Admin access required' }) };
    }
  }

  try {
    const { email, signupId } = JSON.parse(event.body || '{}');

    if (!email) {
      return {
        statusCode: 400,
        headers,
        body: JSON.stringify({ error: 'Missing email address' }),
      };
    }

    const supabaseUrl = process.env.SUPABASE_URL || 'https://jyfaegmnzkarlcximxjo.supabase.co';
    const supabaseServiceKey = process.env.SUPABASE_SERVICE_KEY;

    if (!supabaseServiceKey) {
      return {
        statusCode: 500,
        headers,
        body: JSON.stringify({ error: 'SUPABASE_SERVICE_KEY not configured in Netlify env vars' }),
      };
    }

    // ── Send Magic Link via Supabase Auth Admin API ──
    // This creates the user (if they don't exist) and sends them
    // an email with a magic link to sign in.
    const inviteRes = await fetch(`${supabaseUrl}/auth/v1/invite`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'apikey': supabaseServiceKey,
        'Authorization': `Bearer ${supabaseServiceKey}`,
      },
      body: JSON.stringify({
        email: email.toLowerCase(),
      }),
    });

    const inviteData = await inviteRes.json();

    if (!inviteRes.ok) {
      // If user already exists, try sending a magic link instead
      if (inviteRes.status === 422 || (inviteData.msg || '').includes('already been registered')) {
        const magicRes = await fetch(`${supabaseUrl}/auth/v1/magiclink`, {
          method: 'POST',
          headers: {
            'Content-Type': 'application/json',
            'apikey': supabaseServiceKey,
            'Authorization': `Bearer ${supabaseServiceKey}`,
          },
          body: JSON.stringify({ email: email.toLowerCase() }),
        });

        if (!magicRes.ok) {
          const magicErr = await magicRes.json().catch(() => ({}));
          throw new Error(magicErr.msg || magicErr.message || `Magic link failed: ${magicRes.status}`);
        }
      } else {
        throw new Error(inviteData.msg || inviteData.message || `Invite failed: ${inviteRes.status}`);
      }
    }

    // ── Update alpha_signups record ──
    if (signupId) {
      await fetch(`${supabaseUrl}/rest/v1/alpha_signups?id=eq.${signupId}`, {
        method: 'PATCH',
        headers: {
          'Content-Type': 'application/json',
          'apikey': supabaseServiceKey,
          'Authorization': `Bearer ${supabaseServiceKey}`,
        },
        body: JSON.stringify({
          status: 'invited',
          invite_sent_at: new Date().toISOString(),
        }),
      });
    }

    return {
      statusCode: 200,
      headers,
      body: JSON.stringify({
        success: true,
        message: `Magic link sent to ${email}`,
      }),
    };
  } catch (err) {
    console.error('Alpha invite error:', err);
    return {
      statusCode: 500,
      headers,
      body: JSON.stringify({ error: err.message }),
    };
  }
};
