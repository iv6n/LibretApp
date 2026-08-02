# LibretApp

LibretApp is an offline-first livestock management application built with
Flutter. It manages animals, lots, locations, operational records, agenda,
workforce, milking, and farm finances in a local Isar database.

The current release line is `0.1.x`, intended for a controlled Android pilot.
Spanish is the only enabled application locale.

## Development setup

Requirements:

- Flutter 3.41 or a compatible stable release
- Dart 3.11 or newer
- Java 17 and Android SDK 36 for Android builds
- Docker and the Supabase CLI for database security tests

Install dependencies and generate Isar sources:

```powershell
flutter pub get
dart run build_runner build --delete-conflicting-outputs
flutter analyze --no-fatal-infos
flutter test
```

Plain debug builds remain fully offline. Optional cloud backups are enabled
only when both Supabase values are supplied:

```powershell
flutter run --dart-define-from-file=dart_define.local.json
```

Copy `dart_define.example.json` to `dart_define.local.json` and fill in local
values. The local file is ignored by Git.

## Demo scenario

`DemoScenarioService` (`lib/core/demo/`) seeds a complete, deterministic
fictional ranch — "Rancho El Mezquite — DEMO" — that exercises every module:
animals (40, across 7 species, with genealogy, weights, health, care
calendar, reproduction and history), lotes, locations, movements, commercial
records, costs, milking, finanzas, agenda/workforce, and the farm profile.
Every record it writes is namespaced with a deterministic `demo-` uuid (or,
for the two insert-only finanzas collections, a `[DEMO]` note prefix), so it
is always possible to tell scenario-owned data apart from anything a real
breeder typed.

It is opt-in and never runs silently in a release build:

```powershell
flutter run --dart-define=LIBRET_ENABLE_DEMO_DATA=true
```

In any debug build, it can also be installed or reset without a rebuild from
**Perfil → Ajustes → "Cargar/restablecer escenario demo"**. A plain repeat
install (no reset) is a no-op once the scenario is already installed, so
editing a demo animal is safe — nothing overwrites it until "restablecer" is
requested explicitly, which reseeds every demo-owned record back to its
canonical value without ever touching real data. `DemoDataIntegrityValidator`
(same directory) can be run against any loaded database — demo, real, or
both — to check referential integrity and return a readable report instead
of a bare pass/fail.

## Backup and recovery

Local and cloud backups use the same `.libretbackup` format:

- schema version 5;
- all 20 Isar collections, including the care calendar (rules, records, and
  scheduled tasks);
- persisted farm profile;
- referenced local media, stored by content hash;
- no authentication tokens, encryption keys, theme, language, or other
  device-specific preferences.

Legacy schema v1-v3 JSON files remain importable. Before any replace-all
restore, the app writes an emergency `.libretbackup` snapshot under the
application support directory.

Cloud backup is versioned disaster recovery, not background synchronization.
Each upload is downloaded and SHA-256 verified before it is marked usable.
The five newest verified snapshots are retained.

Restoring a snapshot offers two modes:

- **Replace all** clears local data and imports the snapshot. An emergency
  `.libretbackup` snapshot is written to the application support directory
  first.
- **Merge** matches rows by their stable identity (`uuid`, or `recordUuid` for
  records that have no business key) and keeps whichever copy was modified
  last, so restoring another device's snapshot cannot discard newer local
  edits. Collections with no modification timestamp — the insert-only animal
  child records, both finanzas collections, and the three care-calendar
  collections — let the snapshot win, because no local edit path exists for
  them.

Merge makes a restore usable across devices, but it is still a manual,
user-initiated operation. Background and bidirectional synchronization remain
intentionally deferred until after the pilot.

Apply the local Supabase migration and security tests with:

```powershell
supabase start
supabase test db
```

The migration creates a private Storage bucket and an RLS-protected
`backup_snapshots` metadata table. Users can access only objects below their
own authenticated user ID.

## Signed Android pilot builds

Release builds require a private keystore and fail if
`android/key.properties` is absent. Copy
`android/key.properties.example`, fill it locally, and never commit the
keystore or passwords.

Required release definitions:

- `SUPABASE_URL`
- `SUPABASE_ANON_KEY`
- `LIBRET_TOKEN_MASTER_KEY`

Build an APK with:

```powershell
flutter build apk --release `
  --dart-define-from-file=dart_define.local.json
```

The pilot application ID is `app.libret`. Changing it after pilot
installation would break the normal Android upgrade path.

## Architecture

- Flutter, Material 3, GoRouter
- BLoC/Cubit state management
- GetIt dependency injection
- Isar offline persistence
- SharedPreferences for profile/settings data
- Supabase Auth and private Storage for optional versioned backups

See `docs/CODING_GUIDE.md` and `docs/ARQUITECTURA.md` for module and repository
details.

## Pilot limitations

The pilot does not include maps, expanded camera workflows, push
notifications, multi-farm sharing, or live multi-device synchronization.
These features should be prioritized from observed pilot usage rather than
added before recovery and data-integrity drills pass.
