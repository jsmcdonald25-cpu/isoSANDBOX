// ============================================================
// GrailISO — Auth Verification Utility for Netlify Functions
// netlify/functions/utils/verify-auth.js
// ============================================================
// Verifies the Supabase JWT from the Authorization header.
// Returns the authenticated user or null.
// ============================================================

async function verifyAuth(event) {
  const authHeader = event.headers['authorization'] || event.headers['Authorization'] || '';
  const token = authHeader.replace(/^Bearer\s+/i, '');

  if (!token) return null;

  const supabaseUrl = process.env.SUPABASE_URL || 'https://jyfaegmnzkarlcximxjo.supabase.co';
  const supabaseServiceKey = process.env.SUPABASE_SERVICE_KEY;

  if (!supabaseServiceKey) return null;

  try {
    // Verify the token by calling Supabase's auth API
    const res = await fetch(`${supabaseUrl}/auth/v1/user`, {
      headers: {
        'apikey': supabaseServiceKey,
        'Authorization': `Bearer ${token}`,
      },
    });

    if (!res.ok) return null;

    const user = await res.json();
    if (!user || !user.id) return null;

    return user;
  } catch (e) {
    return null;
  }
}

module.exports = { verifyAuth };
