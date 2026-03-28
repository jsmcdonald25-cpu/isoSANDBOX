// ============================================================
// GrailISO — Capture Payment (Finalize Authorization)
// netlify/functions/capture-payment.js
// ============================================================
// Called when card is verified + delivered to buyer.
// Captures the previously held PaymentIntent.
//
// SETUP: Set STRIPE_SECRET_KEY + SUPABASE_SERVICE_KEY in Netlify env vars
// ============================================================

const Stripe = require('stripe');

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

  try {
    const stripe = Stripe(process.env.STRIPE_SECRET_KEY);
    const { transactionId, paymentIntentId, amountToCapture } = JSON.parse(event.body || '{}');

    if (!paymentIntentId) {
      return { statusCode: 400, headers, body: JSON.stringify({ error: 'paymentIntentId required' }) };
    }

    // Capture — optionally with a different amount (e.g., if grading fee was added)
    const captureParams = {};
    if (amountToCapture) {
      captureParams.amount_to_capture = Math.round(amountToCapture * 100);
    }

    const paymentIntent = await stripe.paymentIntents.capture(paymentIntentId, captureParams);

    // Update Supabase records
    const supabaseUrl = process.env.SUPABASE_URL || 'https://jyfaegmnzkarlcximxjo.supabase.co';
    const supabaseServiceKey = process.env.SUPABASE_SERVICE_KEY;

    if (supabaseServiceKey && transactionId) {
      const capturedAmount = paymentIntent.amount_received / 100;

      await fetch(`${supabaseUrl}/rest/v1/payments?stripe_payment_intent_id=eq.${paymentIntentId}`, {
        method: 'PATCH',
        headers: {
          'Content-Type': 'application/json',
          'apikey': supabaseServiceKey,
          'Authorization': `Bearer ${supabaseServiceKey}`,
          'Prefer': 'return=minimal',
        },
        body: JSON.stringify({
          status: 'captured',
          amount_captured: capturedAmount,
          captured_at: new Date().toISOString(),
        }),
      });

      await fetch(`${supabaseUrl}/rest/v1/transactions?id=eq.${transactionId}`, {
        method: 'PATCH',
        headers: {
          'Content-Type': 'application/json',
          'apikey': supabaseServiceKey,
          'Authorization': `Bearer ${supabaseServiceKey}`,
          'Prefer': 'return=minimal',
        },
        body: JSON.stringify({
          status: 'completed',
          updated_at: new Date().toISOString(),
        }),
      });
    }

    return {
      statusCode: 200,
      headers,
      body: JSON.stringify({
        success: true,
        status: paymentIntent.status,
        amountCaptured: paymentIntent.amount_received / 100,
      }),
    };
  } catch (err) {
    console.error('Capture error:', err);
    return {
      statusCode: 500,
      headers,
      body: JSON.stringify({ error: err.message }),
    };
  }
};
