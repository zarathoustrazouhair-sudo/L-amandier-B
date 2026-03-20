// supabase/functions/verify-document/index.ts
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'

const supabase = createClient(
  Deno.env.get('SUPABASE_URL')!,
  Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!
)

Deno.serve(async (req) => {
  try {
    if (req.method !== 'GET') return new Response('Method not allowed', { status: 405 });

    const url = new URL(req.url);
    const uuid = url.searchParams.get('uuid');

    if (!uuid) return new Response(JSON.stringify({ error: 'Missing UUID parameter' }), { status: 400 });

    const { data: document, error } = await supabase
      .from('documents')
      .select('serial_id, type, date_generation, sha256_hash, metadata, storage_path')
      .eq('serial_id', uuid)
      .single();

    if (error || !document) {
      return new Response(JSON.stringify({ valid: false, error: 'Document not found or altered' }), { status: 404 });
    }

    return new Response(JSON.stringify({
      valid: true,
      document: {
        serial_id: document.serial_id,
        type: document.type,
        date_generation: document.date_generation,
        hash: document.sha256_hash,
        storage_path: document.storage_path
      }
    }), {
      status: 200, headers: { 'Content-Type': 'application/json' }
    });

  } catch (err) {
    console.error('[CRITICAL EDGE ERROR] verify-document:', err);
    return new Response(JSON.stringify({ error: err.message }), { status: 500 });
  }
})
