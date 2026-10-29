import type { SupabaseClient } from 'npm:@supabase/supabase-js@2.57.4';

/// Caller must establish identity (end user) or server authority (recovery worker).
export async function finishDeletion(client: SupabaseClient, owner: string): Promise<boolean> {
  for (let batch = 0; batch < 100; batch++) {
    const { data: files, error } = await client.storage.from('libret-backups').list(owner, { limit: 100 });
    if (error) throw error;
    if (!files.length) break;
    if (files.some((f) => !f.id)) throw new Error('Unexpected nested object');
    const { error: removed } = await client.storage.from('libret-backups').remove(files.map((f) => `${owner}/${f.name}`));
    if (removed) throw removed;
    if (batch === 99) return false;
  }
  const { error: metadata } = await client.from('backup_snapshots').delete().eq('user_id', owner);
  if (metadata) throw metadata;
  // Remove data owned solely by this internal account, preserving other owners.
  const { data: farms, error: memberships } = await client.from('farm_memberships').select('farm_id').eq('user_id', owner).eq('role', 'owner');
  if (memberships) throw memberships;
  for (const farm of farms) {
    const { count, error } = await client.from('farm_memberships').select('id', { count: 'exact', head: true })
      .eq('farm_id', farm.farm_id).eq('role', 'owner').neq('user_id', owner);
    if (error) throw error;
    if (count === 0) {
      const { error: removed } = await client.from('farms').delete().eq('id', farm.farm_id);
      if (removed) throw removed;
    }
  }
  const { error: anonymized } = await client.from('feature_records').update({ updated_by: null }).eq('updated_by', owner);
  if (anonymized) throw anonymized;
  // Auth deletion is idempotent: check if a previous request already removed it.
  const { data: existing, error: lookup } = await client.auth.admin.getUserById(owner);
  if (lookup && lookup.status !== 404) throw lookup;
  if (existing?.user) {
    const { error } = await client.auth.admin.deleteUser(owner);
    if (error) throw error;
  }
  const { error: complete } = await client.from('account_deletions')
    .update({ status: 'complete', updated_at: new Date().toISOString() }).eq('user_id', owner);
  if (complete) throw complete;
  return true;
}
