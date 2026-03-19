// supabase/functions/jwt-hook/index.ts
// Registered as: Auth Hook → Custom Access Token
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'

Deno.serve(async (req) => {
  try {
    const payload = await req.json()
    const user_id = payload.user?.id || payload.record?.id;

    if (!user_id) {
       return new Response(JSON.stringify(payload), { headers: { 'Content-Type': 'application/json' } });
    }

    const supabase = createClient(
      Deno.env.get('SUPABASE_URL')!,
      Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!
    )

    const { data: profile, error } = await supabase
      .from('profiles')
      .select('role')
      .eq('id', user_id)
      .single()

    if (error) {
       console.error("Profile fetch error:", error);
    }

    // Mutate the incoming payload to inject the role
    if (!payload.claims) payload.claims = {};
    if (!payload.claims.app_metadata) payload.claims.app_metadata = {};

    payload.claims.app_metadata.role = profile?.role ?? 'resident';

    return new Response(JSON.stringify(payload), {
        headers: { 'Content-Type': 'application/json' }
    })
  } catch (err) {
    console.error('[CRITICAL JWT HOOK ERROR]', err);
    return new Response(JSON.stringify({ error: err.message }), { status: 500 })
  }
})
