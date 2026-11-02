import { recentPhoneOtp, normalizeAllowedPhone } from './security.ts';
function assert(value: boolean) { if (!value) throw new Error('Assertion failed'); }
Deno.test('recent SMS requires an OTP AMR timestamp, not token iat or refresh', () => {
  const claims = { role: 'authenticated', phone: '525555123456',
    app_metadata: {provider:'phone',providers:['phone']}, amr: [{ method: 'otp', timestamp: 1000 }] };
  assert(recentPhoneOtp(claims, '525555123456', 1299));
  assert(!recentPhoneOtp(claims, '525555123456', 1301));
  assert(!recentPhoneOtp(claims, '525555123456', 999));
  assert(!recentPhoneOtp({ ...claims, amr: [{method:'token_refresh', timestamp:1299}], iat:1299 }, '525555123456', 1300));
  assert(!recentPhoneOtp({...claims, amr:[]}, '525555123456', 1000));
  assert(!recentPhoneOtp({...claims, role:'service_role'}, '525555123456', 1000));
  assert(!recentPhoneOtp(claims, '525555654321', 1000));
  assert(!recentPhoneOtp({...claims, is_anonymous:true}, '525555123456', 1000));
  assert(!recentPhoneOtp({...claims, email:'legacy@example.test'}, '525555123456', 1000));
  assert(!recentPhoneOtp({...claims, app_metadata:{provider:'email',providers:['email','phone']}}, '525555123456', 1000));
  assert(recentPhoneOtp({...claims, phone:'15555551234'}, '15555551234', 1000));
});
Deno.test('only canonical Mexican and US phones reach the provider', () => {
  assert(normalizeAllowedPhone('525555123456') === '+525555123456');
  assert(normalizeAllowedPhone('+525555123456') === '+525555123456');
  assert(normalizeAllowedPhone('+15555551234') === '+15555551234');
  for (const phone of ['+5215555123456', '+52 5555123456', '+1 5555551234', null]) {
    let rejected = false;
    try { normalizeAllowedPhone(phone); } catch (_) { rejected = true; }
    assert(rejected);
  }
});
