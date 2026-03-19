// supabase/functions/notify-payment-validated/index.ts
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'
import { dispatchToUser } from '../_shared/fcm.ts'

const supabase = createClient(
  Deno.env.get('SUPABASE_URL')!,
  Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!
)

Deno.serve(async (req) => {
  try {
    const payload = await req.json()
    const record = payload.record // Triggered by UPDATE on paiements

    if (!record || record.statut !== 'validated') {
      return new Response('Ignored: Status not validated', { status: 200 })
    }

    // Retrieve the active resident(s) for this apartment
    const { data: residents, error } = await supabase
      .from('residents')
      .select('user_id')
      .eq('appartement_id', record.appartement_id)
      .eq('actif', true);

    if (error) throw error;

    if (residents && residents.length > 0) {
      const title = '✅ Cotisation enregistrée';
      const body = 'Votre cotisation de 250 MAD a bien été reçue. Merci pour votre ponctualité !'; // Complies with LAW-08

      for (const r of residents) {
        await dispatchToUser(supabase, r.user_id, title, body, {
          type: 'payment_validated',
          payment_id: record.id
        });
      }
    }

    return new Response(JSON.stringify({ success: true }), {
      status: 200,
      headers: { 'Content-Type': 'application/json' }
    })
  } catch (err) {
    console.error('[CRITICAL EDGE ERROR] notify-payment-validated:', err)
    return new Response(JSON.stringify({ error: err.message }), { status: 500 })
  }
})
