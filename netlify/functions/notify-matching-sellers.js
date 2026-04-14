// ============================================================
// GrailISO — Notify Matching Sellers on New ISO Post
// netlify/functions/notify-matching-sellers.js
// ============================================================
// Called when a buyer submits a new ISO listing.
// Queries Supabase for sellers whose preferences match
// the ISO sport/card type. Sends email via Supabase or
// a transactional email provider.
//
// SETUP: SUPABASE_SERVICE_KEY in Netlify env vars
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

  // ── Auth: verify the caller is a logged-in user ──
  const authedUser = await verifyAuth(event);
  if (!authedUser) {
    return { statusCode: 401, headers, body: JSON.stringify({ error: 'Unauthorized' }) };
  }

  try {
    const {
      isoId,
      sport,
      playerName,
      cardYear,
      cardBrand,
      parallel,
      grade,
      maxPrice,
    } = JSON.parse(event.body || '{}');

    const supabaseUrl = process.env.SUPABASE_URL || 'https://jyfaegmnzkarlcximxjo.supabase.co';
    const supabaseServiceKey = process.env.SUPABASE_SERVICE_KEY;

    // Query seller_preferences where sport overlaps
    // Match: identity verified sellers or both roles, sport matches
    const matchQuery = await fetch(
      `${supabaseUrl}/rest/v1/seller_preferences` +
      `?sports=cs.{${sport}}` +
      `&select=user_id,notify_email,profiles(first_name,email,identity_verified,role)`,
      {
        headers: {
          'apikey': supabaseServiceKey,
          'Authorization': `Bearer ${supabaseServiceKey}`,
        },
      }
    );

    const sellers = await matchQuery.json();

    // Filter: must be identity verified, role must be seller or both
    const eligibleSellers = (sellers || []).filter(s => {
      const p = s.profiles;
      return p &&
        p.identity_verified === true &&
        (p.role === 'seller' || p.role === 'both') &&
        s.notify_email === true;
    });

    // Log the ISO notification event in Supabase
    await fetch(`${supabaseUrl}/rest/v1/seller_notifications`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'apikey': supabaseServiceKey,
        'Authorization': `Bearer ${supabaseServiceKey}`,
      },
      body: JSON.stringify({
        iso_id: isoId,
        notified_count: eligibleSellers.length,
        sport,
        player_name: playerName,
        notified_at: new Date().toISOString(),
      }),
    });

    // -------------------------------------------------------
    // EMAIL DELIVERY
    // Plug in your email provider here. Options:
    // - Resend (recommended): https://resend.com — simple, generous free tier
    // - Postmark: reliable transactional
    // - SendGrid: enterprise
    //
    // For now: emails are logged. Wire in provider post-Kickstarter or when
    // first transactions go live. The seller list is ready.
    // -------------------------------------------------------

    console.log(`ISO ${isoId} — notifying ${eligibleSellers.length} sellers for ${sport} / ${playerName}`);

    // Placeholder email loop — replace with real provider SDK
    for (const seller of eligibleSellers) {
      console.log(`NOTIFY → ${seller.profiles.email} (${seller.profiles.first_name}) about ISO: ${playerName} ${parallel}`);
      // await resend.emails.send({ to: seller.profiles.email, ... });
    }

    return {
      statusCode: 200,
      headers,
      body: JSON.stringify({
        success: true,
        notified: eligibleSellers.length,
      }),
    };
  } catch (err) {
    console.error('Seller notification error:', err);
    return {
      statusCode: 500,
      headers,
      body: JSON.stringify({ error: err.message }),
    };
  }
};
