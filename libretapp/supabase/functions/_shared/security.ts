export function recentPhoneOtp(claims: Record<string, unknown>, phone: string | undefined, now = Date.now() / 1000): boolean {
  const metadata = claims.app_metadata as {provider?: unknown; providers?: unknown} | undefined;
  if (!phone || !/^52\d{10}$/.test(phone.replace(/^\+/, '')) ||
      claims.phone !== phone || claims.is_anonymous === true || claims.role !== 'authenticated' ||
      (claims.email != null && claims.email !== '') || metadata?.provider !== 'phone' ||
      !Array.isArray(metadata.providers) || metadata.providers.length !== 1 || metadata.providers[0] !== 'phone') return false;
  return Array.isArray(claims.amr) && claims.amr.some((entry) =>
    entry.method === 'otp' && Number.isFinite(entry.timestamp) &&
    entry.timestamp <= now && now - entry.timestamp <= 300);
}

export function normalizeMexicanPhone(phone: unknown): string {
  if (typeof phone !== 'string') throw new Error('Invalid phone');
  const normalized = '+' + phone.replace(/^\+/, '');
  if (!/^\+52\d{10}$/.test(normalized)) throw new Error('Mexico only');
  return normalized;
}

export function parseSmsEvent(input: unknown): {user: {id: string; phone: string}; sms: {otp: string}} {
  const value = input as {user?: {id?: unknown; phone?: unknown}; sms?: {otp?: unknown}};
  if (!value || typeof value.user?.id !== 'string' ||
      !/^[0-9a-f-]{36}$/.test(value.user.id) ||
      typeof value.sms?.otp !== 'string' || !/^\d{6}$/.test(value.sms.otp)) {
    throw new Error('Invalid SMS hook payload');
  }
  return { user: {id: value.user.id, phone: normalizeMexicanPhone(value.user.phone)}, sms: {otp: value.sms.otp} };
}
