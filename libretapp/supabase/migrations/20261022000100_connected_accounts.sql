begin;

-- Tombstones deliberately have no FK: old JWTs remain denied after Auth deletion.
create table public.account_deletions (
  user_id uuid primary key,
  session_id uuid not null,
  requested_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  status text not null default 'pending' check (status in ('pending','storage','metadata','complete'))
);
alter table public.account_deletions enable row level security;
revoke all on public.account_deletions from anon, authenticated;
grant all on public.account_deletions to service_role;

create function public.account_is_active() returns boolean
language sql stable security definer set search_path = '' as $$
  select exists(select 1 from auth.users where id = auth.uid())
     and not exists(select 1 from public.account_deletions where user_id = auth.uid());
$$;
revoke all on function public.account_is_active() from public;
grant execute on function public.account_is_active() to authenticated;

-- Serialize the final Storage/metadata write with the deletion tombstone.
-- A request authorized before deletion must commit before deletion can start;
-- a request waiting for the lock takes a fresh snapshot and is then rejected.
create function public.account_can_write() returns boolean
language plpgsql volatile security definer set search_path = '' as $$
begin
  if auth.uid() is null then return false; end if;
  perform pg_advisory_xact_lock(hashtextextended(auth.uid()::text, 220026));
  return exists(select 1 from auth.users where id = auth.uid())
    and not exists(select 1 from public.account_deletions where user_id = auth.uid());
end $$;
revoke all on function public.account_can_write() from public;
grant execute on function public.account_can_write() to authenticated;
create function public.lock_account_deletion() returns trigger
language plpgsql set search_path = '' as $$
begin
  perform pg_advisory_xact_lock(hashtextextended(new.user_id::text, 220026));
  return new;
end $$;
revoke all on function public.lock_account_deletion() from public;
create trigger lock_account_deletion before insert on public.account_deletions
for each row execute function public.lock_account_deletion();

-- Restrictive policies AND all existing permissive policies, including internal sync.
do $$
declare t text;
begin
  foreach t in array array['backup_snapshots','farms','farm_memberships','feature_records','sync_operations'] loop
    execute format('create policy active_account_required on public.%I as restrictive for all to authenticated using (public.account_is_active()) with check (public.account_can_write())', t);
  end loop;
end $$;
create policy active_backup_account_required on storage.objects as restrictive
for all to authenticated
using (bucket_id <> 'libret-backups' or public.account_is_active())
with check (bucket_id <> 'libret-backups' or public.account_can_write());

alter table public.backup_snapshots
  add constraint snapshot_size_max check (size_bytes <= 104857600) not valid;
alter table public.backup_snapshots
  add constraint snapshot_digest_hex check (sha256 ~ '^[0-9a-f]{64}$') not valid;
alter table public.backup_snapshots
  add constraint snapshot_canonical_path check (object_path = user_id::text || '/' || id::text || '.libretbackup') not valid;
create policy reserved_backup_object_required on storage.objects as restrictive
for insert to authenticated with check (
  bucket_id <> 'libret-backups' or exists(
    select 1 from public.backup_snapshots s where s.user_id = auth.uid()
      and s.object_path = name and not s.verified
  )
);
-- Reservations are immutable except for verified false -> true.
create function public.backup_identity_immutable() returns trigger
language plpgsql set search_path = '' as $$
begin
  if (to_jsonb(new) - 'verified') is distinct from (to_jsonb(old) - 'verified')
     or (old.verified and not new.verified) then
    raise exception 'Snapshot identity is immutable' using errcode = '23514';
  end if;
  return new;
end $$;
create trigger backup_identity_immutable before update on public.backup_snapshots
for each row execute function public.backup_identity_immutable();
revoke all on function public.backup_identity_immutable() from public;
create policy backup_snapshots_owner_update on public.backup_snapshots
for update to authenticated using (user_id = auth.uid())
with check (user_id = auth.uid());
grant update (verified) on public.backup_snapshots to authenticated;

-- Service-only quota reservations. No raw phone number or OTP is persisted.
create table public.sms_send_attempts (
  request_id text primary key,
  phone_hash text not null check (phone_hash ~ '^[0-9a-f]{64}$'),
  created_at timestamptz not null default clock_timestamp(),
  status text not null default 'reserved' check (status in ('reserved','sent','failed','unknown'))
);
create index sms_attempts_phone_time on public.sms_send_attempts(phone_hash, created_at);
create index sms_attempts_time on public.sms_send_attempts(created_at);
create table public.sms_quota_alerts (
  period text primary key,
  created_at timestamptz not null default now(),
  used integer not null,
  limit_count integer not null
);
alter table public.sms_send_attempts enable row level security;
alter table public.sms_quota_alerts enable row level security;
revoke all on public.sms_send_attempts, public.sms_quota_alerts from anon, authenticated;
grant all on public.sms_send_attempts, public.sms_quota_alerts to service_role;

create function public.reserve_sms(p_request_id text, p_phone_hash text) returns jsonb
language plpgsql security definer set search_path = '' as $$
declare
  day_start timestamptz := date_trunc('day', clock_timestamp() at time zone 'America/Mexico_City') at time zone 'America/Mexico_City';
  month_start timestamptz := date_trunc('month', clock_timestamp() at time zone 'America/Mexico_City') at time zone 'America/Mexico_City';
  daily integer; monthly integer; per_phone integer; last_send timestamptz; previous text;
begin
  perform pg_advisory_xact_lock(22002610);
  if p_request_id is null or length(p_request_id) not between 1 and 200
     or p_phone_hash is null or p_phone_hash !~ '^[0-9a-f]{64}$' then
    raise exception 'Invalid quota request' using errcode = '22023';
  end if;
  select status into previous from public.sms_send_attempts where request_id = p_request_id;
  if found then return jsonb_build_object('allowed', false, 'duplicate', true, 'status', previous); end if;
  select count(*) filter(where created_at >= day_start), count(*)
    into daily, monthly from public.sms_send_attempts where created_at >= month_start;
  select count(*) filter(where created_at >= day_start), max(created_at)
    into per_phone, last_send from public.sms_send_attempts where phone_hash = p_phone_hash;
  if daily >= 50 or monthly >= 300 or per_phone >= 5 or last_send > clock_timestamp() - interval '60 seconds' then
    return jsonb_build_object('allowed', false, 'duplicate', false);
  end if;
  insert into public.sms_send_attempts(request_id,phone_hash) values(p_request_id,p_phone_hash);
  if per_phone + 1 >= 4 then
    insert into public.sms_quota_alerts(period,used,limit_count)
      values('phone:' || p_phone_hash || ':' || day_start::text,per_phone+1,5) on conflict do nothing;
  end if;
  if daily + 1 >= 40 then
    insert into public.sms_quota_alerts(period,used,limit_count)
      values('day:' || day_start::text,daily+1,50) on conflict do nothing;
  end if;
  if monthly + 1 >= 240 then
    insert into public.sms_quota_alerts(period,used,limit_count)
      values('month:' || month_start::text,monthly+1,300) on conflict do nothing;
  end if;
  -- Keep current-month counters; all older anti-abuse hashes expire after 32 days.
  delete from public.sms_send_attempts where created_at < clock_timestamp() - interval '32 days';
  delete from public.sms_quota_alerts where created_at < clock_timestamp() - interval '32 days';
  return jsonb_build_object('allowed', true, 'warning', per_phone+1 >= 4 or daily+1 >= 40 or monthly+1 >= 240);
end $$;
revoke all on function public.reserve_sms(text,text) from public, anon, authenticated;
grant execute on function public.reserve_sms(text,text) to service_role;

create function public.prune_sms_usage() returns void
language sql security definer set search_path = '' as $$
  delete from public.sms_send_attempts where created_at < now() - interval '32 days';
  delete from public.sms_quota_alerts where created_at < now() - interval '32 days';
$$;
revoke all on function public.prune_sms_usage() from public, anon, authenticated;
grant execute on function public.prune_sms_usage() to service_role;

commit;
