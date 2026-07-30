create extension if not exists pgcrypto;

create table if not exists public.backup_snapshots (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  object_path text not null,
  sha256 text not null check (length(sha256) = 64),
  size_bytes bigint not null check (size_bytes > 0),
  schema_version integer not null check (schema_version > 0),
  app_version text not null,
  verified boolean not null default false,
  created_at timestamptz not null default now(),
  unique (user_id, object_path)
);

create index if not exists backup_snapshots_user_created_idx
  on public.backup_snapshots (user_id, created_at desc);

alter table public.backup_snapshots enable row level security;

drop policy if exists backup_snapshots_owner_select
  on public.backup_snapshots;
create policy backup_snapshots_owner_select
  on public.backup_snapshots
  for select
  to authenticated
  using (user_id = auth.uid());

drop policy if exists backup_snapshots_owner_insert
  on public.backup_snapshots;
create policy backup_snapshots_owner_insert
  on public.backup_snapshots
  for insert
  to authenticated
  with check (
    user_id = auth.uid()
    and object_path like auth.uid()::text || '/%'
  );

drop policy if exists backup_snapshots_owner_delete
  on public.backup_snapshots;
create policy backup_snapshots_owner_delete
  on public.backup_snapshots
  for delete
  to authenticated
  using (user_id = auth.uid());

grant select, insert, delete on public.backup_snapshots to authenticated;

insert into storage.buckets (id, name, public, file_size_limit)
values ('libret-backups', 'libret-backups', false, 104857600)
on conflict (id) do update
set public = false,
    file_size_limit = excluded.file_size_limit;

drop policy if exists libret_backups_owner_select on storage.objects;
create policy libret_backups_owner_select
  on storage.objects
  for select
  to authenticated
  using (
    bucket_id = 'libret-backups'
    and (storage.foldername(name))[1] = auth.uid()::text
  );

drop policy if exists libret_backups_owner_insert on storage.objects;
create policy libret_backups_owner_insert
  on storage.objects
  for insert
  to authenticated
  with check (
    bucket_id = 'libret-backups'
    and (storage.foldername(name))[1] = auth.uid()::text
  );

drop policy if exists libret_backups_owner_delete on storage.objects;
create policy libret_backups_owner_delete
  on storage.objects
  for delete
  to authenticated
  using (
    bucket_id = 'libret-backups'
    and (storage.foldername(name))[1] = auth.uid()::text
  );
