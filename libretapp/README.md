# LibretApp

LibretApp is an offline-first livestock management application built with
Flutter. It manages animals, lots, locations, operational records, agenda,
workforce, milking, and farm finances with Isar on mobile and a shared
Drift/SQLite WASM envelope on the web.

The current release line is `0.1.x`, intended for a controlled Android pilot.
Spanish is the only enabled application locale.

The `connected` Android flavor and Google Play preparation are documented in
[the staging/release guide](docs/publicacion-connected/ENSAYO.md), with
[draft listing and data disclosures](docs/publicacion-connected/FICHA-Y-DECLARACIONES.md).
The public information site is deployed; connected services and production
acceptance still require staging, owner details, and the checks in that guide.

## Development setup

Requirements:

- Flutter 3.47.5 (also pinned in CI), with bundled Dart 3.13.4
- Java 17 and Android SDK 36 for Android builds
- Docker and the Supabase CLI for database security tests

Install dependencies and generate Isar sources:

```powershell
flutter pub get
python tool/regenerate_models.py
flutter analyze --no-fatal-infos
flutter test
```

Plain debug builds remain fully offline. Optional cloud backups are enabled
only when both Supabase values are supplied:

```powershell
flutter run --flavor standard --dart-define-from-file=dart_define.local.json
```

Copy `dart_define.example.json` to `dart_define.local.json` and fill in local
values. The local file is ignored by Git.

## Demo scenario

`DemoScenarioService` (`lib/core/demo/`) seeds a complete, deterministic
fictional ranch — "Rancho El Mezquite — DEMO" — that exercises every module:
animals (40, across 8 species, with genealogy, weights, health, care
calendar, reproduction and history), lotes, locations, movements, commercial
records, costs, milking, finanzas, agenda/workforce, and the farm profile.
Every record it writes is namespaced with a deterministic `demo-` uuid (or,
for the two insert-only finanzas collections, a `[DEMO]` note prefix), so it
is always possible to tell scenario-owned data apart from anything a real
breeder typed.

It is opt-in and never runs silently in a release build:

```powershell
flutter run --flavor standard --dart-define=LIBRET_ENABLE_DEMO_DATA=true
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

## Herd import and offline batch records

Herd imports now open a review screen from **Registros → Importar hato** or
the import action in Settings. Excel `.xlsx`, UTF-8 CSV and TSV are mapped by
headers; previews identify file duplicates, existing animals and invalid rows.
Existing animals are skipped until the user explicitly chooses an update.
Only selected valid rows are committed, in one local transaction with a fresh
identity check. This imports basic animal data; use `.libretbackup` to restore
complete histories and media.

The installed app also provides **Registros → Registro por lotes**, linked
from each lot. Weighing, health and movement sessions retain raw draft inputs
and their original participants locally. Users can resume or discard drafts
and confirm a session atomically without internet. Completed sessions are
retained as receipts, and retries do not apply their records again. Drafts are
included in the existing schema-11 backups. The web's legacy operational
repositories still require migration before batch recording is available there.

See [stage-one behavior and validation](docs/etapa-1-hato-y-lotes.md).

## Backup and recovery

Local and cloud backups use the same `.libretbackup` format:

- schema version 11 (older supported envelopes and v1-v3 JSON remain importable);
- all current Isar collections, including RFID and shared feature records;
- persisted farm profile;
- referenced local media, stored by content hash;
- no authentication tokens, encryption keys, theme, language, or other
  device-specific preferences.

Native restoration validates and writes collections, migrations and profile in
one Isar transaction. Media uses isolated directories with verified hashes.
Formats newer than the supported schema are rejected before writing anything.
The profile now lives in Isar per workspace; migration retains the original
`perfil_v1` preference and never overwrites a migrated profile.

Settings provides **Revisión de datos** and **Copias de recuperación**. Cleanup
requires preview, explicit selections, confirmation, an unchanged source, and
a native database/media copy before a single transaction applies the changes.
It never automatically merges animals or genealogies. Native copies retain
malformed historical values that JSON cannot represent. They restore only to
the same workspace/device; `.libretbackup` is the portable interchange format.

Cloud backup is versioned disaster recovery, not background synchronization.
Each upload is downloaded and SHA-256 verified before it is marked usable.
The five newest verified snapshots are retained.

Restoring a snapshot offers two modes:

- **Replace all** clears local data and imports the snapshot. An emergency
  `.libretbackup` snapshot is written to the application support directory
  first.
- **Merge** matches rows by their stable identity (`uuid`, or `recordUuid` for
  records that have no business key) and keeps whichever copy was modified
  last. Financial edits retain their identity and use `updatedAt`. For old
  collections without a modification timestamp, no last-write ordering can be
  inferred; compatibility retains the collection's existing merge policy.

Merge makes a restore usable across devices, but it is still a manual,
user-initiated operation. The shared sync queue, cursors, conflicts and
tombstones are now implemented locally; remote bidirectional synchronization
requires applying the Supabase migration and configuring authenticated access.

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

The free pilot uses the `offline` flavor and Android 9/API 28 or newer. Older
Android kernels reject the current Isar/libmdbx database engine; this pilot
does not disable its compatibility protection. It keeps `app.libret`, requires no
external credentials, hides accounts/cloud/payments/hardware/GPS, and removes
Internet, GPS and Bluetooth permissions from the release manifest. Standard
internal QA uses `--flavor standard`; cloud and the experimental encryption
core remain outside the offline pilot's launch scope.

Generate a QA bundle with disposable signing (never upload this to Play):

```powershell
python tool/build_android_candidate.py --mode qa --out artifacts/candidate-qa
```

The store generator requires real `LIBRET_RESPONSIBLE_NAME`,
`LIBRET_SUPPORT_EMAIL` and `LIBRET_PRIVACY_URL` in a JSON metadata file; an
acceptance JSON containing `sourceSha256` and every required check; and the
actual highest version code already in Console. Pending or stale evidence is
rejected. It builds locally and never uploads or publishes.

```powershell
python tool/build_android_candidate.py --mode store --metadata metadata.local.json `
  --evidence acceptance.local.json --last-play-code 5 --out artifacts/candidate-store
```

Version `0.1.3+6` is planned; the generator advances past a higher Console code.
The maintained Isar
Community 3.3.2 libraries support 16 KB alignment while preserving the existing
collection schemas and UUIDs. A compressed database fixture created with Isar
3.1 verifies a real open/write/reopen upgrade. Backup schema is 11.

Run the automated release inspection against the final bundle and its merged
manifest, then verify its signature and the final APK with SDK `zipalign -c
-P 16 -v 4`. Static checks do not replace Android installation/update or a
16 KB device/emulator run.

```powershell
python tool/verify_offline_release.py `
  build/app/outputs/bundle/offlineRelease/app-offline-release.aab `
  --manifest build/app/intermediates/merged_manifests/offlineRelease/processOfflineReleaseManifest/AndroidManifest.xml `
  --out artifacts/directorio/release-verification.json
```

See [pilot acceptance and coverage](docs/piloto/README.md), the coverage CSV,
and the privacy/store drafts in `docs/piloto/`. Back up the ignored upload
keystore and its private configuration outside this checkout before uploading
to Play Console; subsequent APK updates require the same signing identity.

Generated Flutter, Dart, Gradle and Windows intermediary files can be removed
without touching source code, assets, local databases, keys or uncommitted
changes:

```powershell
.\tool\clean_generated.ps1
```

The pilot application ID is `app.libret`. Changing it after pilot
installation would break the normal Android upgrade path.

## Architecture

- Flutter, Material 3, GoRouter
- BLoC/Cubit state management
- GetIt dependency injection
- Isar offline persistence on mobile
- Drift/SQLite WASM persistence and PWA service worker on web
- farm context, role contracts, persistent sync queue and conflict records
- Isar for the workspace profile; SharedPreferences for device settings
- Supabase Auth and private Storage for optional versioned backups

See `docs/CODING_GUIDE.md` and `docs/ARQUITECTURA.md` for module and repository
details.

Batch records support offline weighing, health events and movements on both
the installed app and the web. Drafts resume after reopening, and confirming
again returns the original receipt without adding duplicate records. On web,
load the app online once so its offline shell can finish caching. See
[the first-stage guide](docs/etapa-1-hato-y-lotes.md) for the workflow and tests.

## Pilot limitations

The offline pilot hides fiscal, payment, OpenAI, cloud and hardware provider
entry points. These remain available only in standard internal builds. Supabase RLS and live multi-device synchronization require the
deployment migration and authenticated environment configuration.
