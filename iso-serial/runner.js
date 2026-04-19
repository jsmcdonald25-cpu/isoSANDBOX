#!/usr/bin/env node
/**
 * ISOSerial Runner — steady-state cron execution.
 *
 * Invoked every 30 min by GitHub Actions (see .github/workflows/iso-serial.yml).
 *
 * Same crawler logic as bootstrap.js, tagged with run_environment = 'github_actions'
 * for the audit log.
 *
 * All env vars come from GH Actions secrets at runtime:
 *   EBAY_CLIENT_ID, EBAY_CLIENT_SECRET
 *   SUPABASE_URL, SUPABASE_SERVICE_ROLE_KEY
 */

const { crawl } = require('./crawler');

crawl({ runEnvironment: 'github_actions' })
  .then(() => process.exit(0))
  .catch((err) => {
    console.error('\nFATAL:', err);
    process.exit(1);
  });
