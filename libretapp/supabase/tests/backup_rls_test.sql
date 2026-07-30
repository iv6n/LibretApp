begin;
select plan(8);

select has_table('public', 'backup_snapshots', 'metadata table exists');
select policies_are(
  'public',
  'backup_snapshots',
  array[
    'backup_snapshots_owner_delete',
    'backup_snapshots_owner_insert',
    'backup_snapshots_owner_select'
  ],
  'metadata policies are complete'
);
select policies_are(
  'storage',
  'objects',
  array[
    'libret_backups_owner_delete',
    'libret_backups_owner_insert',
    'libret_backups_owner_select'
  ],
  'backup object policies are complete'
);
select is(
  (select public from storage.buckets where id = 'libret-backups'),
  false,
  'backup bucket is private'
);

insert into auth.users (id, instance_id, aud, role, email)
values
  ('00000000-0000-0000-0000-000000000001', '00000000-0000-0000-0000-000000000000', 'authenticated', 'authenticated', 'a@example.test'),
  ('00000000-0000-0000-0000-000000000002', '00000000-0000-0000-0000-000000000000', 'authenticated', 'authenticated', 'b@example.test');

set local role authenticated;
select set_config(
  'request.jwt.claims',
  '{"sub":"00000000-0000-0000-0000-000000000001","role":"authenticated"}',
  true
);

insert into public.backup_snapshots (
  id, user_id, object_path, sha256, size_bytes, schema_version, app_version, verified
) values (
  '10000000-0000-0000-0000-000000000001',
  '00000000-0000-0000-0000-000000000001',
  '00000000-0000-0000-0000-000000000001/one.libretbackup',
  repeat('a', 64),
  100,
  4,
  '0.1.0+2',
  true
);

select is(
  (select count(*)::integer from public.backup_snapshots),
  1,
  'owner can read own metadata'
);

select set_config(
  'request.jwt.claims',
  '{"sub":"00000000-0000-0000-0000-000000000002","role":"authenticated"}',
  true
);
select is(
  (select count(*)::integer from public.backup_snapshots),
  0,
  'another user cannot read owner metadata'
);
delete from public.backup_snapshots
where id = '10000000-0000-0000-0000-000000000001';
select set_config(
  'request.jwt.claims',
  '{"sub":"00000000-0000-0000-0000-000000000001","role":"authenticated"}',
  true
);
select is(
  (select count(*)::integer from public.backup_snapshots),
  1,
  'another user cannot delete owner metadata'
);
select set_config(
  'request.jwt.claims',
  '{"sub":"00000000-0000-0000-0000-000000000002","role":"authenticated"}',
  true
);
select throws_ok(
  $$insert into public.backup_snapshots (
      user_id, object_path, sha256, size_bytes, schema_version, app_version
    ) values (
      '00000000-0000-0000-0000-000000000001',
      '00000000-0000-0000-0000-000000000001/two.libretbackup',
      repeat('b', 64),
      100,
      4,
      '0.1.0+2'
    )$$,
  '42501',
  null,
  'another user cannot insert metadata for the owner'
);

select * from finish();
rollback;
