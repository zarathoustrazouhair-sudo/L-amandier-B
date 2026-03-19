// supabase/functions/notify-incident-assigned/index.ts
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'
import { dispatchToUser } from '../_shared/fcm.ts'

const supabase = createClient(
  Deno.env.get('SUPABASE_URL')!,
  Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!
)

Deno.serve(async (req) => {
  try {
    const payload = await req.json()
    const record = payload.record // Triggered by UPDATE on incidents

    if (!record || record.statut !== 'assigne' || !record.assigne_a) {
      return new Response('Ignored: Not assigned or missing assignee', { status: 200 })
    }

    const title = '🔧 Nouvelle intervention assignée';
    const body = 'Un incident vous a été assigné à la résidence. Merci de le traiter dès que possible.'; // Complies with LAW-08

    await dispatchToUser(supabase, record.assigne_a, title, body, {
      type: 'incident_assigned',
      incident_id: record.id
    });

    return new Response(JSON.stringify({ success: true }), {
      status: 200,
      headers: { 'Content-Type': 'application/json' }
    })
  } catch (err) {
    console.error('[CRITICAL EDGE ERROR] notify-incident-assigned:', err)
    return new Response(JSON.stringify({ error: err.message }), { status: 500 })
  }
})
