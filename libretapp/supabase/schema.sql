-- LibretApp — esquema de respaldo en la nube (Fase 1: solo subida).
--
-- Ejecutar en el SQL Editor de tu proyecto Supabase. Crea una tabla por
-- colección local de Isar, con RLS simple de "cada quien ve lo suyo".
--
-- Columnas comunes:
--   user_id     -> dueño del registro (auth.uid()), obligatorio desde ya.
--   finca_id    -> reservado para compartir por finca/equipo en el futuro.
--                  Nullable ahora a propósito: cuando se construya esa
--                  función, se vuelve NOT NULL sin tener que tocar el resto
--                  del esquema.
--   content_hash / synced_at -> reservados para la Fase 2 (detección de
--                  conflictos en la sincronización bidireccional).
--
-- Las tablas "animals" y "lotes" usan columnas camelCase entre comillas
-- porque reutilizan los DTOs de exportación JSON que ya existían en la app
-- (AnimalDto/LoteDto); el resto usa snake_case, la convención normal de
-- Postgres, ya que no había un DTO previo que respetar.
--
-- Los "uuid" de las tablas raíz (animals, lotes, locations, agenda_entries,
-- worker_profiles, work_teams, milking_sessions, milking_entries) son
-- columnas `text`, no `uuid` nativo: los identificadores que genera la app
-- llevan prefijo (p.ej. "ani-<uuid>", "lote-<timestamp>", slugs como
-- "prop-casa") y el tipo `uuid` de Postgres los rechaza por no ser un UUID
-- puro. Las tablas de registros hijos (health_records, weight_records, etc.)
-- sí usan `uuid` nativo porque ese valor lo genera Postgres
-- (default gen_random_uuid()), nunca la app.

create extension if not exists pgcrypto;

-- Si ya corriste una versión anterior de este script (con "uuid" tipado
-- como uuid nativo en las tablas raíz), bórralas primero para que se
-- vuelvan a crear con el tipo correcto — no hay datos reales que perder
-- todavía en un proyecto recién creado:
--   drop table if exists animals, lotes, locations, agenda_entries,
--     worker_profiles, work_teams, milking_sessions, milking_entries,
--     income_records, general_expense_records, health_records,
--     weight_records, movement_records, cost_records, commercial_records,
--     production_records, reproduction_records, fincas cascade;

-- ── Reservado para compartir por finca/equipo (Fase 4, no usado todavía) ──
create table if not exists fincas (
  id uuid primary key default gen_random_uuid(),
  owner_user_id uuid not null references auth.users(id),
  name text not null,
  created_at timestamptz not null default now()
);

-- ── Animales ───────────────────────────────────────────────────────────────
create table if not exists animals (
  "uuid" text primary key,
  user_id uuid not null references auth.users(id),
  finca_id uuid references fincas(id),
  "earTagNumber" text,
  "customName" text,
  "visualId" text,
  brand text,
  "rfidTag" text,
  "batchId" text,
  "batchUuid" text,
  species text,
  category text,
  "lifeStage" text,
  sex text,
  breed text,
  "crossBreed" text,
  "birthDate" timestamptz,
  "ageMonths" integer,
  weight double precision,
  "sireUuid" text,
  "damUuid" text,
  generation integer,
  "healthStatus" text,
  "bodyConditionScore" integer,
  vaccinated boolean,
  dewormed boolean,
  "hasVitamins" boolean,
  "hasChronicIssues" boolean,
  "chronicNotes" text,
  "reproductiveStatus" text,
  "firstServiceDate" timestamptz,
  "lastServiceDate" timestamptz,
  "expectedCalvingDate" timestamptz,
  "productionPurpose" text,
  "productionStage" text,
  "productionSystem" text,
  "feedType" text,
  "dailyGainEstimate" double precision,
  "coatColor" text,
  "distinguishingMarks" text,
  notes text,
  "originType" text,
  provenance text,
  "crossBreedType" text,
  "sireBreed" text,
  "damBreed" text,
  "bloodPercentage" integer,
  "genealogicalRegistry" text,
  "originNotes" text,
  "housingType" text,
  "shadingAvailability" text,
  "animalWaterSource" text,
  "approximateDensity" text,
  "locationNotes" text,
  "feedFrequency" text,
  "feedSupplements" text,
  "feedNotes" text,
  "earTagColor" text,
  "currentPaddockId" text,
  "initialLocationId" text,
  "lastMovementDate" timestamptz,
  "underObservation" boolean,
  "requiresAttention" boolean,
  "riskLevel" text,
  "profilePhoto" text,
  gallery jsonb,
  owner text,
  "purchasePrice" double precision,
  status text,
  synced boolean,
  "remoteId" text,
  "syncDate" timestamptz,
  "contentHash" text,
  "creationDate" timestamptz,
  "lastUpdateDate" timestamptz
);

-- ── Lotes ──────────────────────────────────────────────────────────────────
create table if not exists lotes (
  "uuid" text primary key,
  user_id uuid not null references auth.users(id),
  finca_id uuid references fincas(id),
  "nombre" text,
  "descripcion" text,
  "animalUuids" jsonb,
  "fechaCreacion" timestamptz,
  "fechaCierre" timestamptz,
  "activo" boolean,
  "notas" text,
  "lastUpdateDate" timestamptz,
  synced boolean,
  "remoteId" text,
  "syncDate" timestamptz
);

-- ── Ubicaciones (Fase 1: solo identidad/configuración, sin historial) ──────
create table if not exists locations (
  "uuid" text primary key,
  user_id uuid not null references auth.users(id),
  finca_id uuid references fincas(id),
  name text,
  kind text,
  parent_uuid text,
  template_uuid text,
  type text,
  surface_area double precision,
  capacity integer,
  water_source text,
  terrain_type text,
  status text,
  category text,
  geometry text,
  is_shared boolean,
  is_communal boolean,
  image_paths jsonb
);

-- ── Agenda ─────────────────────────────────────────────────────────────────
create table if not exists agenda_entries (
  "uuid" text primary key,
  user_id uuid not null references auth.users(id),
  finca_id uuid references fincas(id),
  titulo text,
  descripcion text,
  fecha timestamptz,
  tipo text,
  animal_ids jsonb,
  lote_ids jsonb,
  ubicacion text,
  location_uuid text,
  estado text,
  prioridad text,
  completed_animal_ids jsonb,
  notas text,
  fecha_completado timestamptz,
  assignee_id text,
  collaborator_ids jsonb,
  work_team_id text,
  created_by_id text,
  created_at timestamptz,
  updated_at timestamptz,
  recurrence_rule text,
  blocked_reason text
);

-- ── Personal y equipos de trabajo ──────────────────────────────────────────
create table if not exists worker_profiles (
  "uuid" text primary key,
  user_id uuid not null references auth.users(id),
  finca_id uuid references fincas(id),
  name text,
  role text,
  phone text,
  active boolean,
  created_at timestamptz,
  updated_at timestamptz
);

create table if not exists work_teams (
  "uuid" text primary key,
  user_id uuid not null references auth.users(id),
  finca_id uuid references fincas(id),
  name text,
  member_ids jsonb,
  active boolean,
  created_at timestamptz,
  updated_at timestamptz
);

-- ── Ordeña ─────────────────────────────────────────────────────────────────
create table if not exists milking_sessions (
  "uuid" text primary key,
  user_id uuid not null references auth.users(id),
  finca_id uuid references fincas(id),
  occurred_at timestamptz,
  shift text,
  status text,
  source_lote_uuid text,
  notes text,
  created_at timestamptz,
  updated_at timestamptz
);

create table if not exists milking_entries (
  "uuid" text primary key,
  user_id uuid not null references auth.users(id),
  finca_id uuid references fincas(id),
  session_uuid text,
  animal_uuid text,
  volume_milliliters integer,
  notes text,
  created_at timestamptz,
  updated_at timestamptz
);

-- ── Finanzas (sin uuid propio: Postgres asigna el id) ──────────────────────
create table if not exists income_records (
  "uuid" uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id),
  finca_id uuid references fincas(id),
  date timestamptz,
  type text,
  amount double precision,
  currency text,
  animal_uuid text,
  notes text
);

create table if not exists general_expense_records (
  "uuid" uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id),
  finca_id uuid references fincas(id),
  date timestamptz,
  type text,
  amount double precision,
  currency text,
  notes text
);

-- ── Registros de animales (sin uuid propio: Postgres asigna el id) ────────
create table if not exists health_records (
  "uuid" uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id),
  finca_id uuid references fincas(id),
  animal_uuid text not null,
  date timestamptz,
  type text,
  product text,
  dose text,
  applied_by text,
  notes text,
  next_due_date timestamptz,
  cause text,
  medicine_batch text,
  withdrawal_days integer,
  withdrawal_end_date timestamptz
);

create table if not exists weight_records (
  "uuid" uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id),
  finca_id uuid references fincas(id),
  animal_uuid text not null,
  date timestamptz,
  weight double precision,
  method text,
  measured_by text,
  notes text
);

create table if not exists movement_records (
  "uuid" uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id),
  finca_id uuid references fincas(id),
  animal_uuid text not null,
  from_location text,
  to_location text,
  date timestamptz,
  reason text,
  notes text,
  moved_by text
);

create table if not exists cost_records (
  "uuid" uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id),
  finca_id uuid references fincas(id),
  animal_uuid text not null,
  date timestamptz,
  type text,
  amount double precision,
  currency text,
  notes text
);

create table if not exists commercial_records (
  "uuid" uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id),
  finca_id uuid references fincas(id),
  animal_uuid text not null,
  date timestamptz,
  type text,
  amount double precision,
  currency text,
  counterparty text,
  notes text
);

create table if not exists production_records (
  "uuid" uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id),
  finca_id uuid references fincas(id),
  animal_uuid text not null,
  date timestamptz,
  type text,
  value double precision,
  unit text,
  score integer,
  notes text
);

create table if not exists reproduction_records (
  "uuid" uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id),
  finca_id uuid references fincas(id),
  animal_uuid text not null,
  service_date timestamptz,
  service_type text,
  male_sire_uuid text,
  male_sire_identifier text,
  pregnancy_check_date timestamptz,
  pregnancy_result text,
  expected_calving_date timestamptz,
  actual_calving_date timestamptz,
  calving_result text,
  notes text,
  serviced_by text
);

-- ── Row Level Security: cada quien ve y escribe solo lo suyo ───────────────
-- (Fase 4 cambiará esto a "user_id = auth.uid() OR finca_id IN (...)" sin
-- necesitar ninguna migración de esquema, porque finca_id ya existe.)
do $$
declare
  t text;
begin
  for t in select unnest(array[
    'animals','lotes','locations','agenda_entries','worker_profiles',
    'work_teams','milking_sessions','milking_entries','income_records',
    'general_expense_records','health_records','weight_records',
    'movement_records','cost_records','commercial_records',
    'production_records','reproduction_records'
  ])
  loop
    execute format('alter table %I enable row level security', t);
    execute format(
      'create policy "owner_all" on %I for all using (user_id = auth.uid()) with check (user_id = auth.uid())',
      t
    );
  end loop;
end $$;
