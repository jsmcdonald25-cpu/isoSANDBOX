// ============================================================
// GrailISO — Grant ISO Credits + Finalize Profile
// netlify/functions/grant-iso-credits.js
// ============================================================
// Called after card is successfully saved on file.
// Grants 5 free ISO credits. Updates profile in Supabase.
// SETUP: Set STRIPE_SECRET_KEY + SUPABASE_SERVICE_KEY in Netlify env vars
// ============================================================

const Stripe = require('stripe');

const FREE_ISO_CREDITS = 5;

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
    const {
      userId,
      setupIntentId,
      stripeCustomerId,
      paymentMethodId,
    } = JSON.parse(event.body || '{}');

    if (!userId || !setupIntentId || !stripeCustomerId) {
      return {
        statusCode: 400,
        headers,
        body: JSON.stringify({ error: 'Missing required fields' }),
      };
    }

    // Verify the SetupIntent actually succeeded with Stripe
    const setupIntent = await stripe.setupIntents.retrieve(setupIntentId);
    if (setupIntent.status !== 'succeeded') {
      return {
        statusCode: 400,
        headers,
        body: JSON.stringify({ error: 'SetupIntent not confirmed — card not saved' }),
      };
    }

    // Attach payment method to customer as default
    const pmId = paymentMethodId || setupIntent.payment_method;
    await stripe.customers.update(stripeCustomerId, {
      invoice_settings: { default_payment_method: pmId },
    });

    // Update Supabase profile using service key (bypasses RLS)
    // SUPABASE_SERVICE_KEY is the service_role key — NOT the anon key
    // Get it from Supabase Dashboard → Settings → API → service_role
    const supabaseUrl = 'https://wqorfvumiljrbpjwsmal.supabase.co';
    const supabaseServiceKey = process.env.SUPABASE_SERVICE_KEY;

    const profileUpdate = await fetch(
      `${supabaseUrl}/rest/v1/profiles?id=eq.${userId}`,
      {
        method: 'PATCH',
        headers: {
          'Content-Type': 'application/json',
          'apikey': supabaseServiceKey,
          'Authorization': `Bearer ${supabaseServiceKey}`,
          'Prefer': 'return=representation',
        },
        body: JSON.stringify({
          stripe_customer_id: stripeCustomerId,
          stripe_payment_method_id: pmId,
          iso_credits: FREE_ISO_CREDITS,
          card_on_file: true,
          onboarding_complete: true,
        }),
      }
    );

    if (!profileUpdate.ok) {
      const err = await profileUpdate.text();
      throw new Error(`Supabase update failed: ${err}`);
    }

    return {
      statusCode: 200,
      headers,
      body: JSON.stringify({
        success: true,
        iso_credits: FREE_ISO_CREDITS,
        message: `${FREE_ISO_CREDITS} ISO credits granted.`,
      }),
    };
  } catch (err) {
    console.error('Grant credits error:', err);
    return {
      statusCode: 500,
      headers,
      body: JSON.stringify({ error: err.message }),
    };
  }
};
