create extension if not exists pgcrypto;

create table if not exists public.farms (
  id uuid primary key,
  name text not null,
  legal_name text,
  owner_name text,
  upp text,
  time_zone text not null default 'America/Hermosillo',
  default_currency text not null default 'MXN',
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.farm_memberships (
  id uuid primary key default gen_random_uuid(),
  farm_id uuid not null references public.farms(id) on delete cascade,
  user_id uuid not null references auth.users(id) on delete cascade,
  role text not null check (role in ('owner', 'manager', 'veterinarian', 'worker', 'client')),
  worker_id text,
  client_animal_ids jsonb not null default '[]'::jsonb,
  active boolean not null default true,
  unique (farm_id, user_id)
);

create table if not exists public.feature_records (
  uuid uuid primary key,
  farm_id uuid not null references public.farms(id) on delete cascade,
  kind text not null,
  payload jsonb not null,
  created_at timestamptz not null,
  updated_at timestamptz not null,
  deleted_at timestamptz,
  revision bigint not null default 0,
  updated_by uuid references auth.users(id)
);

create table if not exists public.sync_operations (
  operation_uuid uuid primary key,
  farm_id uuid not null references public.farms(id) on delete cascade,
  entity_uuid uuid not null,
  kind text not null,
  operation text not null check (operation in ('upsert', 'delete')),
  base_revision bigint,
  created_at timestamptz not null default now(),
  applied_at timestamptz,
  unique (farm_id, operation_uuid)
);

create index if not exists feature_records_farm_kind_updated_idx
  on public.feature_records (farm_id, kind, updated_at);
create index if not exists sync_operations_farm_pending_idx
  on public.sync_operations (farm_id, applied_at, created_at);

alter table public.farms enable row level security;
alter table public.farm_memberships enable row level security;
alter table public.feature_records enable row level security;
alter table public.sync_operations enable row level security;

create or replace function public.has_farm_role(target_farm uuid, allowed_roles text[])
returns boolean
language sql
security definer
stable
set search_path = public
as $$
  select exists (
    select 1
    from public.farm_memberships m
    where m.farm_id = target_farm
      and m.user_id = auth.uid()
      and m.active
      and m.role = any(allowed_roles)
  );
$$;

revoke all on function public.has_farm_role(uuid, text[]) from public;
grant execute on function public.has_farm_role(uuid, text[]) to authenticated;

drop policy if exists farms_member_select on public.farms;
create policy farms_member_select on public.farms for select to authenticated
using (public.has_farm_role(id, array['owner', 'manager', 'veterinarian', 'worker', 'client']));

drop policy if exists memberships_self_or_owner on public.farm_memberships;
drop policy if exists memberships_select on public.farm_memberships;
drop policy if exists memberships_owner_insert on public.farm_memberships;
drop policy if exists memberships_owner_update on public.farm_memberships;
drop policy if exists memberships_owner_delete on public.farm_memberships;
create policy memberships_select on public.farm_memberships for select to authenticated
using (user_id = auth.uid() or public.has_farm_role(farm_id, array['owner']));
create policy memberships_owner_insert on public.farm_memberships for insert to authenticated
with check (public.has_farm_role(farm_id, array['owner']));
create policy memberships_owner_update on public.farm_memberships for update to authenticated
using (public.has_farm_role(farm_id, array['owner']))
with check (public.has_farm_role(farm_id, array['owner']));
create policy memberships_owner_delete on public.farm_memberships for delete to authenticated
using (public.has_farm_role(farm_id, array['owner']));

drop policy if exists feature_records_scoped_access on public.feature_records;
create policy feature_records_scoped_access on public.feature_records for all to authenticated
using (
  public.has_farm_role(feature_records.farm_id, array['owner', 'manager', 'veterinarian', 'worker'])
  or (
    feature_records.payload ? 'animalUuid'
    and exists (
      select 1 from public.farm_memberships m
      where m.farm_id = feature_records.farm_id
        and m.user_id = auth.uid()
        and m.active
        and m.role = 'client'
        and feature_records.payload->>'animalUuid' = any (select jsonb_array_elements_text(m.client_animal_ids))
    )
  )
)
with check (
  public.has_farm_role(feature_records.farm_id, array['owner', 'manager', 'veterinarian', 'worker'])
);

drop policy if exists sync_operations_scoped_access on public.sync_operations;
create policy sync_operations_scoped_access on public.sync_operations for all to authenticated
using (public.has_farm_role(sync_operations.farm_id, array['owner', 'manager', 'veterinarian', 'worker']))
with check (public.has_farm_role(sync_operations.farm_id, array['owner', 'manager', 'veterinarian', 'worker']));

grant select, insert, update on public.farms to authenticated;
grant select, insert, update, delete on public.farm_memberships to authenticated;
grant select, insert, update, delete on public.feature_records to authenticated;
grant select, insert, update on public.sync_operations to authenticated;
