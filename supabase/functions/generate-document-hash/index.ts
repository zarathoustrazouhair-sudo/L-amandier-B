// supabase/functions/generate-document-hash/index.ts
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'
import { crypto } from "https://deno.land/std@0.208.0/crypto/mod.ts";
import { encodeHex } from "https://deno.land/std@0.208.0/encoding/hex.ts";

const supabase = createClient(
  Deno.env.get('SUPABASE_URL')!,
  Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!
)

Deno.serve(async (req) => {
  try {
    if (req.method !== 'POST') return new Response('Method not allowed', { status: 405 });

    const payload = await req.json();
    const { serial_id, resident_id, appartement_id, periode, montant, date_paiement, timestamp_generation, document_type, reference_id } = payload;

    // LAW-01 Server-Side Enforcement for Receipts
    if (document_type === 'recu_paiement' && Number(montant) !== 250.00) {
      return new Response(JSON.stringify({ error: 'LAW-01 Violation: Montant must be 250.00' }), { status: 400 });
    }

    // Fetch trusted data from DB to prevent client spoofing
    const { data: profile } = await supabase.from('profiles').select('nom, prenom').eq('id', resident_id).single();
    const { data: apt } = await supabase.from('appartements').select('numero').eq('id', appartement_id).single();

    if (!profile || !apt) throw new Error("Invalid resident or apartment ID");

    const residentFullName = `${profile.nom} ${profile.prenom}`.trim();

    // Canonical String Construction (LAW-07)
    // Format: serial_id|resident_full_name|appartement_numero|periode|montant|date_paiement|timestamp_generation
    const canonicalString = `${serial_id}|${residentFullName}|${apt.numero}|${periode}|${Number(montant).toFixed(2)}|${date_paiement}|${timestamp_generation}`;

    // Compute SHA-256
    const messageBuffer = new TextEncoder().encode(canonicalString);
    const hashBuffer = await crypto.subtle.digest("SHA-256", messageBuffer);
    const sha256Hash = encodeHex(hashBuffer);

    // Insert frozen record into documents table
    const { error: insertError } = await supabase.from('documents').insert({
      serial_id,
      type: document_type,
      genere_par: resident_id, // The user triggering the generation
      date_generation: timestamp_generation,
      reference_id: reference_id,
      sha256_hash: sha256Hash,
      metadata: { canonical_string: canonicalString }
    });

    if (insertError) throw insertError;

    const qrPayloadUrl = `https://api.amandier-b.ma/verify/${serial_id}?h=${sha256Hash.substring(0, 16)}`;

    return new Response(JSON.stringify({
      success: true,
      serial_id,
      sha256_hash: sha256Hash,
      qr_payload_url: qrPayloadUrl
    }), {
      status: 200, headers: { 'Content-Type': 'application/json' }
    });

  } catch (err) {
    console.error('[CRITICAL EDGE ERROR] generate-document-hash:', err);
    return new Response(JSON.stringify({ error: err.message }), { status: 500 });
  }
})
