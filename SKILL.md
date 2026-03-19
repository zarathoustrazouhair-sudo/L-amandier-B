# SKILL.md — EDGE FUNCTIONS & INFRASTRUCTURE PROTOCOLS
# Reference for Jules when implementing Server-Side Logic

## WEBHOOK SETUP PATTERN
Each database webhook must target a specific table event and call an isolated Edge Function.
Rule: Do not bundle multiple triggers into a single Edge Function. One webhook = One Function.

## EDGE FUNCTION BOILERPLATE (STRICT TEMPLATE)
```typescript
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'

// Service Role Key is MANDATORY here. Never use anon key for webhook processing.
const supabase = createClient(
  Deno.env.get('SUPABASE_URL')!,
  Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!
)

Deno.serve(async (req) => {
  try {
    const payload = await req.json()
    const record = payload.record // The new/updated record from the DB webhook

    // --- ENFORCE ATOMIC BUSINESS LOGIC HERE ---
    // Example: FCM Dispatch, Audit Logging, Data Aggregation

    return new Response(JSON.stringify({ success: true }), {
      status: 200,
      headers: { 'Content-Type': 'application/json' }
    })
  } catch (err) {
    console.error('[CRITICAL EDGE ERROR]', err)
    return new Response(JSON.stringify({ error: err.message }), { status: 500 })
  }
})
```

FCM TOKEN LIFECYCLE (FLUTTER CLIENT PROTOCOL)
The client handles token registration ONLY.
// Execute ONCE at app startup
FirebaseMessaging.instance.onTokenRefresh.listen((newToken) {
  ref.read(fcmTokenRepositoryProvider).upsertToken(newToken);
});
final token = await FirebaseMessaging.instance.getToken();
if (token != null) ref.read(fcmTokenRepositoryProvider).upsertToken(token);

Target: Upsert to fcm_tokens table.
ENVIRONMENT VARIABLES (SECRETS)
You must ensure these exist in the Supabase local/remote secrets before testing:
 * SUPABASE_URL
 * SUPABASE_SERVICE_ROLE_KEY
 * GOOGLE_SERVICE_ACCOUNT_JSON
 * FCM_PROJECT_ID
