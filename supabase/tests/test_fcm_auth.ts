import { getFCMAccessToken } from '../functions/_shared/fcm.ts';

// We bypass execution if GOOGLE_SERVICE_ACCOUNT_JSON is missing
// to allow the script to pass in a clean CI/CD or local test environment.
if (!Deno.env.get('GOOGLE_SERVICE_ACCOUNT_JSON')) {
  console.log('[WARN] Skipping FCM Token test (GOOGLE_SERVICE_ACCOUNT_JSON missing). Module compiled successfully.');
  Deno.exit(0);
}

try {
  const token = await getFCMAccessToken();
  console.log(`[OK] FCM Token generated: ${token.substring(0, 15)}...`);
} catch (e) {
  console.error('[ERROR]', e);
  Deno.exit(1);
}
