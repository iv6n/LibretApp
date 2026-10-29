import { createClient } from 'npm:@supabase/supabase-js@2.57.4';
import { Webhook } from 'npm:standardwebhooks@1.0.0';
import { parseSmsEvent } from '../_shared/security.ts';

const reply = (status: number, message: string) => Response.json(
  { error: { http_code: status, message } }, { status });

export async function handleSms(request: Request): Promise<Response> {
  if (request.method !== 'POST') return reply(405, 'Method not allowed');
  const raw = await request.text();
  let payload: unknown;
  try {
    // Standard Webhooks validates HMAC, timestamp and replay window.
    const secret = Deno.env.get('SEND_SMS_HOOK_SECRET')!.replace(/^v1,whsec_/, '');
    payload = new Webhook(secret).verify(raw, Object.fromEntries(request.headers));
  } catch (_) { return reply(401, 'Invalid hook signature'); }
  // Fail closed until actual Twilio pricing and the trial configuration are approved.
  if (Deno.env.get('SMS_BILLING_ENABLED') !== 'true') return reply(503, 'SMS sending is not activated');
  try {
    const event = parseSmsEvent(payload);
    const phone = event.user.phone;
    if (!/^\d{6}$/.test(event.sms?.otp)) return reply(400, 'Invalid OTP');
    const client = createClient(Deno.env.get('SUPABASE_URL')!, Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!);
    const { data: deleting, error: deleteError } = await client.from('account_deletions')
      .select('user_id').eq('user_id', event.user.id).maybeSingle();
    if (deleteError || deleting) return reply(403, 'Account unavailable');
    const key = await crypto.subtle.importKey('raw', new TextEncoder().encode(Deno.env.get('SMS_QUOTA_PEPPER')!),
      { name: 'HMAC', hash: 'SHA-256' }, false, ['sign']);
    const digest = await crypto.subtle.sign('HMAC', key, new TextEncoder().encode(phone));
    const hash = [...new Uint8Array(digest)].map((b) => b.toString(16).padStart(2, '0')).join('');
    const requestId = request.headers.get('webhook-id');
    if (!requestId) return reply(400, 'Missing hook ID');
    const { data: quota, error } = await client.rpc('reserve_sms', { p_request_id: requestId, p_phone_hash: hash });
    if (error) return reply(503, 'Quota service unavailable');
    if (!quota.allowed) {
      return quota.duplicate && quota.status === 'sent' ? Response.json({}) : reply(429, 'SMS quota or resend limit reached');
    }
    if (quota.warning) console.warn('SMS quota reached 80%; inspect sms_quota_alerts');
    const sid = Deno.env.get('TWILIO_ACCOUNT_SID')!;
    const form = new URLSearchParams({ To: phone,
      MessagingServiceSid: Deno.env.get('TWILIO_MESSAGING_SERVICE_SID')!,
      Body: `LibretApp: tu codigo es ${event.sms.otp}. Vence en 5 minutos. No lo compartas.` });
    let status = 'unknown';
    try {
      // No automatic retry: a lost provider response may already be billable.
      const response = await fetch(`https://api.twilio.com/2010-04-01/Accounts/${sid}/Messages.json`, {
        method: 'POST', headers: { Authorization: 'Basic ' + btoa(`${sid}:${Deno.env.get('TWILIO_AUTH_TOKEN')!}`) },
        body: form, signal: AbortSignal.timeout(3500),
      });
      status = response.ok ? 'sent' : 'failed';
    } catch (_) { /* Unknown acceptance consumes its quota conservatively. */ }
    const { error: saved } = await client.from('sms_send_attempts').update({ status }).eq('request_id', requestId);
    if (saved || status !== 'sent') return reply(503, 'SMS delivery could not be confirmed');
    return Response.json({});
  } catch (_) { return reply(503, 'SMS service unavailable'); }
}
if (import.meta.main) Deno.serve(handleSms);
