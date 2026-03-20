// supabase/functions/send-relance-batch/index.ts
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'
import { dispatchToUser } from '../_shared/fcm.ts'

const supabase = createClient(
  Deno.env.get('SUPABASE_URL')!,
  Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!
)

Deno.serve(async (req) => {
  try {
    // Check for manual dry-run testing
    let isDryRun = false;
    if (req.method === 'POST') {
      const body = await req.json().catch(() => ({}));
      isDryRun = body.dry_run === true;
    }

    // 1. Get Settings (Grace period & frequency)
    const { data: settings } = await supabase.from('settings').select('key, value');
    const getSetting = (k: string, def: number) =>
      Number(settings?.find(s => s.key === k)?.value) || def;

    const gracePeriodDays = getSetting('relance_grace_period_days', 10);
    const frequencyDays = getSetting('relance_frequency_days', 7);

    // Time calculations
    const now = new Date();
    // Assuming Casablanca timezone (UTC+1 roughly)
    const currentPeriod = `${now.getFullYear()}-${String(now.getMonth() + 1).padStart(2, '0')}`;
    const dayOfMonth = now.getDate();

    if (dayOfMonth <= gracePeriodDays && !isDryRun) {
      return new Response('Grace period active. No action taken.', { status: 200 });
    }

    // 2. Query overdue apartments (occupied only, no validated payment for current period)
    const { data: overdueApts, error: aptError } = await supabase
      .from('appartements')
      .select(`
        id,
        numero,
        residents!inner(user_id),
        paiements(id, statut, periode)
      `)
      .neq('statut_occupation', 'vacant')
      .eq('residents.actif', true);

    if (aptError) throw aptError;

    const apartmentsToNotify = [];

    for (const apt of overdueApts || []) {
      const hasPaid = apt.paiements.some((p: any) => p.periode === currentPeriod && p.statut === 'validated');
      if (hasPaid) continue;

      const userId = apt.residents[0]?.user_id;
      if (!userId) continue;

      // 3. Check last notification to respect frequency
      const { data: lastNotif } = await supabase
        .from('audit_log') // using audit_log as proxy for notifications_log in this schema
        .select('created_at')
        .eq('action', 'relance_sent')
        .eq('acteur_id', userId)
        .order('created_at', { ascending: false })
        .limit(1)
        .single();

      let shouldSend = true;
      if (lastNotif) {
        const lastSentDate = new Date(lastNotif.created_at);
        const diffDays = (now.getTime() - lastSentDate.getTime()) / (1000 * 3600 * 24);
        if (diffDays < frequencyDays) shouldSend = false;
      }

      if (shouldSend) apartmentsToNotify.push({ aptId: apt.id, numero: apt.numero, userId });
    }

    if (isDryRun) {
      return new Response(JSON.stringify({ dry_run: true, targets: apartmentsToNotify }), {
        status: 200, headers: { 'Content-Type': 'application/json' }
      });
    }

    // 4. Dispatch FCM (LAW-08: Friendly tone)
    const title = '📋 Petit rappel amical';
    const body = `Votre participation du mois (${currentPeriod}) est en attente. Merci de régulariser à votre convenance pour le bon fonctionnement de notre résidence.`;

    for (const target of apartmentsToNotify) {
      await dispatchToUser(supabase, target.userId, title, body, { type: 'relance' });

      // Log it
      await supabase.from('audit_log').insert({
        action: 'relance_sent',
        acteur_id: target.userId,
        objet_type: 'appartement',
        objet_id: target.aptId,
        details: { periode: currentPeriod, tone: 'amiable' }
      });
    }

    return new Response(JSON.stringify({ success: true, notified_count: apartmentsToNotify.length }), {
      status: 200, headers: { 'Content-Type': 'application/json' }
    });

  } catch (err) {
    console.error('[CRITICAL EDGE ERROR] send-relance-batch:', err);
    return new Response(JSON.stringify({ error: err.message }), { status: 500 });
  }
})
