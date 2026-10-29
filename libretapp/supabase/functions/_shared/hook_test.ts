import { Webhook } from 'npm:standardwebhooks@1.0.0';
import { handleSms } from '../send-sms/index.ts';

Deno.test('forged hooks fail before quota or billable provider access', async () => {
  const response = await handleSms(new Request('http://localhost/send-sms', { method:'POST', body:'{}' }));
  if (response.status !== 401) throw new Error('Invalid signature was accepted');
});
Deno.test('valid signed hooks still fail closed until billing is enabled', async () => {
  const secret = btoa('non-production-test-secret-32bytes');
  Deno.env.set('SEND_SMS_HOOK_SECRET', `v1,whsec_${secret}`);
  Deno.env.set('SMS_BILLING_ENABLED', 'false');
  const id = 'test-hook-id'; const date = new Date();
  const body = JSON.stringify({user:{id:'22000000-0000-0000-0000-000000000001',phone:'+525555123456'},sms:{otp:'123456'}});
  const signature = new Webhook(secret).sign(id,date,body);
  const response = await handleSms(new Request('http://localhost/send-sms',{method:'POST',body,
    headers:{'webhook-id':id,'webhook-timestamp':String(Math.floor(date.getTime()/1000)),'webhook-signature':signature}}));
  if (response.status !== 503) throw new Error('Billable sending was not blocked');
  Deno.env.delete('SEND_SMS_HOOK_SECRET'); Deno.env.delete('SMS_BILLING_ENABLED');
});
