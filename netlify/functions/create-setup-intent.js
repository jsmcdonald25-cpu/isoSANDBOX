// ============================================================
// GrailISO — Stripe SetupIntent (Save Card on File)
// netlify/functions/create-setup-intent.js
// ============================================================
// SETUP: Set STRIPE_SECRET_KEY in Netlify environment variables
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
    const { userId, email, firstName, lastName } = JSON.parse(event.body || '{}');

    if (!userId || !email) {
      return {
        statusCode: 400,
        headers,
        body: JSON.stringify({ error: 'userId and email are required' }),
      };
    }

    // Create or retrieve Stripe customer
    let customer;
    const existing = await stripe.customers.list({ email, limit: 1 });

    if (existing.data.length > 0) {
      customer = existing.data[0];
    } else {
      customer = await stripe.customers.create({
        email,
        name: `${firstName} ${lastName}`.trim(),
        metadata: { grailiso_user_id: userId },
      });
    }

    // Create a SetupIntent — saves card without charging
    const setupIntent = await stripe.setupIntents.create({
      customer: customer.id,
      payment_method_types: ['card'],
      metadata: {
        grailiso_user_id: userId,
        purpose: 'iso_posting',
      },
    });

    return {
      statusCode: 200,
      headers,
      body: JSON.stringify({
        client_secret: setupIntent.client_secret,
        customer_id: customer.id,
      }),
    };
  } catch (err) {
    console.error('Stripe SetupIntent error:', err);
    return {
      statusCode: 500,
      headers,
      body: JSON.stringify({ error: err.message }),
    };
  }
};
