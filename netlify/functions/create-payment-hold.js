// ============================================================
// GrailISO — Create Payment Hold (Stripe Authorization)
// netlify/functions/create-payment-hold.js
// ============================================================
// Creates a PaymentIntent with capture_method='manual' to hold
// funds on the buyer's card without actually charging.
// The hold is captured later when the card is verified/delivered.
//
// SETUP: Set STRIPE_SECRET_KEY + SUPABASE_SERVICE_KEY in Netlify env vars
// ============================================================

const Stripe = require('stripe');
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
    const stripe = Stripe(process.env.STRIPE_SECRET_KEY);
    const {
      transactionId,
      buyerId,
      amount,          // total amount in dollars (agreed + fees)
      description,     // e.g. "GrailISO: Griffey #139 PSA 10 — Transaction #42"
      stripeCustomerId,
      paymentMethodId,
    } = JSON.parse(event.body || '{}');

    if (!transactionId || !buyerId || !amount) {
      return {
        statusCode: 400,
        headers,
        body: JSON.stringify({ error: 'Missing required fields: transactionId, buyerId, amount' }),
      };
    }

    // ── Ensure the buyerId matches the authenticated user ──
    if (buyerId !== authedUser.id) {
      return { statusCode: 403, headers, body: JSON.stringify({ error: 'User mismatch' }) };
    }

    if (amount < 1) {
      return {
        statusCode: 400,
        headers,
        body: JSON.stringify({ error: 'Amount must be at least $1.00' }),
      };
    }

    const amountCents = Math.round(amount * 100);

    // Create PaymentIntent with manual capture — holds funds without charging
    const paymentIntentParams = {
      amount: amountCents,
      currency: 'usd',
      capture_method: 'manual',  // KEY: authorize only, capture later
      description: description || `GrailISO Transaction #${transactionId}`,
      metadata: {
        transaction_id: String(transactionId),
        buyer_id: buyerId,
        platform: 'grailiso',
      },
    };

    // If buyer has a saved payment method, attach it
    if (stripeCustomerId) {
      paymentIntentParams.customer = stripeCustomerId;
    }
    if (paymentMethodId) {
      paymentIntentParams.payment_method = paymentMethodId;
      paymentIntentParams.confirm = true;  // auto-confirm if payment method provided
    }

    const paymentIntent = await stripe.paymentIntents.create(paymentIntentParams);

    // Write payment record to Supabase
    const supabaseUrl = process.env.SUPABASE_URL || 'https://jyfaegmnzkarlcximxjo.supabase.co';
    const supabaseServiceKey = process.env.SUPABASE_SERVICE_KEY;

    if (supabaseServiceKey) {
      // Insert payment record
      await fetch(`${supabaseUrl}/rest/v1/payments`, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'apikey': supabaseServiceKey,
          'Authorization': `Bearer ${supabaseServiceKey}`,
          'Prefer': 'return=minimal',
        },
        body: JSON.stringify({
          transaction_id: transactionId,
          stripe_payment_intent_id: paymentIntent.id,
          stripe_customer_id: stripeCustomerId || null,
          amount_held: amount,
          currency: 'usd',
          status: paymentIntent.status === 'requires_capture' ? 'held' : 'pending',
          held_at: paymentIntent.status === 'requires_capture' ? new Date().toISOString() : null,
          created_at: new Date().toISOString(),
        }),
      });

      // Update transaction status
      await fetch(`${supabaseUrl}/rest/v1/transactions?id=eq.${transactionId}`, {
        method: 'PATCH',
        headers: {
          'Content-Type': 'application/json',
          'apikey': supabaseServiceKey,
          'Authorization': `Bearer ${supabaseServiceKey}`,
          'Prefer': 'return=minimal',
        },
        body: JSON.stringify({
          status: paymentIntent.status === 'requires_capture' ? 'payment_held' : 'payment_pending',
          updated_at: new Date().toISOString(),
        }),
      });
    }

    return {
      statusCode: 200,
      headers,
      body: JSON.stringify({
        success: true,
        paymentIntentId: paymentIntent.id,
        clientSecret: paymentIntent.client_secret,
        status: paymentIntent.status,
        amountHeld: amount,
      }),
    };
  } catch (err) {
    console.error('Payment hold error:', err);
    return {
      statusCode: 500,
      headers,
      body: JSON.stringify({ error: err.message }),
    };
  }
};
