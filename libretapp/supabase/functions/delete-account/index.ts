import { createClient } from 'npm:@supabase/supabase-js@2.57.4';
import { recentPhoneOtp } from '../_shared/security.ts';
import { finishDeletion } from '../_shared/delete_account.ts';

Deno.serve(async (request) => {
  const allowedOrigin = Deno.env.get('PUBLIC_SITE_ORIGIN');
  const origin = request.headers.get('origin');
  const cors: Record<string, string> = { 'Vary': 'Origin', 'Access-Control-Allow-Headers': 'authorization, apikey, content-type, x-client-info',
    'Access-Control-Allow-Methods': 'POST, OPTIONS' };
  if (origin && origin === allowedOrigin) cors['Access-Control-Allow-Origin'] = origin;
  const reply = (body: unknown, status = 200) => Response.json(body, { status, headers: cors });
  if (origin && origin !== allowedOrigin) return reply({ error: 'Origin denied' }, 403);
  if (request.method === 'OPTIONS') return new Response(null, { status: 204, headers: cors });
  if (request.method !== 'POST') return reply({ error: 'Method not allowed' }, 405);
  try {
    // No target user, phone, or other identity is accepted in the request body.
    const body = await request.text();
    if (body && body !== '{}') return reply({ error: 'Request body must be empty' }, 400);
    const token = request.headers.get('authorization')?.replace(/^Bearer /i, '');
    if (!token) return reply({ error: 'Authentication required' }, 401);
    const client = createClient(Deno.env.get('SUPABASE_URL')!, Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!);
    const { data: verified, error: claimsError } = await client.auth.getClaims(token);
    if (claimsError || !verified?.claims || verified.claims.role !== 'authenticated') {
      return reply({ error: 'Authentication required' }, 401);
    }
    const claims = verified.claims;
    const owner = claims.sub;
    if (!owner || !claims.session_id) return reply({ error: 'Session required' }, 401);
    const { data: pending, error: pendingError } = await client.from('account_deletions')
      .select('session_id,status').eq('user_id', owner).maybeSingle();
    if (pendingError) throw pendingError;
    if (pending) {
      if (pending.session_id !== claims.session_id) return reply({ error: 'Deletion belongs to another session; contact support' }, 403);
      if (pending.status === 'complete') return reply({ status: 'complete' });
    } else {
      const { data, error } = await client.auth.getUser(token);
      if (error || !data.user?.phone_confirmed_at ||
          !recentPhoneOtp(claims, data.user.phone)) {
        return reply({ error: 'Recent SMS verification required', code: 'reauth_required' }, 403);
      }
      const { error: blocked } = await client.from('account_deletions').insert({ user_id: owner, session_id: claims.session_id });
      if (blocked) throw blocked;
    }
    // Existing requests resume without another SMS (the hook blocks deleting users).
    const complete = await finishDeletion(client, owner);
    return reply({ status: complete ? 'complete' : 'pending' }, complete ? 200 : 202);
  } catch (_) {
    return reply({ status: 'pending', error: 'Deletion interrupted; retry or contact support' }, 503);
  }
});
