import { createClient } from 'npm:@supabase/supabase-js@2.57.4';
import { finishDeletion } from '../_shared/delete_account.ts';

// Invoke from a server scheduler with a dedicated secret, never from the app.
Deno.serve(async (request) => {
  const secret = Deno.env.get('DELETION_WORKER_SECRET');
  if (!secret || request.headers.get('authorization') !== `Bearer ${secret}`) {
    return Response.json({ error: 'Unauthorized' }, { status: 401 });
  }
  if (request.method !== 'POST') return new Response(null, { status: 405 });
  const client = createClient(Deno.env.get('SUPABASE_URL')!, Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!);
  const { error: pruning } = await client.rpc('prune_sms_usage');
  if (pruning) return Response.json({ error: 'Maintenance unavailable' }, { status: 503 });
  const { data, error } = await client.from('account_deletions').select('user_id')
    .neq('status', 'complete').order('requested_at').limit(20);
  if (error) return Response.json({ error: 'Unavailable' }, { status: 503 });
  let completed = 0;
  for (const row of data) {
    try { if (await finishDeletion(client, row.user_id)) completed++; }
    catch (_) { /* Tombstone remains. Retry next scheduled run. */ }
  }
  return Response.json({ examined: data.length, completed });
});
