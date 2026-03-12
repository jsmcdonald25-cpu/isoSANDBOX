// ============================================================
// GrailISO — Stripe Identity Verification Session
// netlify/functions/create-verification-session.js
// ============================================================
// SETUP: Set STRIPE_SECRET_KEY in Netlify environment variables
// Dashboard → Site → Environment variables → Add:
//   STRIPE_SECRET_KEY = sk_live_XXXXXXXXXXXX  (or sk_test_XX for testing)
// ============================================================

const Stripe = require('stripe');

exports.handler = async (event) => {
  const headers = {
    'Access-Control-Allow-Origin': 'https://grailiso.com',
    'Access-Control-Allow-Headers': 'Content-Type',
    'Access-Control-Allow-Methods': 'POST, OPTIONS',
    'Content-Type': 'application/json',
  };

  if (event.httpMethod === 'OPTIONS') {
    return { statusCode: 200, headers, body: '' };
  }

  if (event.httpMethod !== 'POST') {
    return { statusCode: 405, headers, body: JSON.stringify({ error: 'Method not allowed' }) };
  }

  try {
    const stripe = Stripe(process.env.STRIPE_SECRET_KEY);
    const { userId, email } = JSON.parse(event.body || '{}');

    if (!userId || !email) {
      return {
        statusCode: 400,
        headers,
        body: JSON.stringify({ error: 'userId and email are required' }),
      };
    }

    // Create a Stripe Identity verification session
    const verificationSession = await stripe.identity.verificationSessions.create({
      type: 'document',
      metadata: {
        grailiso_user_id: userId,
        email: email,
      },
      options: {
        document: {
          // Accept driver's license, passport, ID card
          allowed_types: ['driving_license', 'passport', 'id_card'],
          require_id_number: false,
          require_live_capture: true,
          require_matching_selfie: true,
        },
      },
    });

    return {
      statusCode: 200,
      headers,
      body: JSON.stringify({
        client_secret: verificationSession.client_secret,
        session_id: verificationSession.id,
      }),
    };
  } catch (err) {
    console.error('Stripe Identity error:', err);
    return {
      statusCode: 500,
      headers,
      body: JSON.stringify({ error: err.message }),
    };
  }
};
