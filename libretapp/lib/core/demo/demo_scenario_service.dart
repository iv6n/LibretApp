/// core › demo › demo_scenario_service — single orchestrator for the
/// "Rancho El Mezquite — DEMO" scenario.
///
/// This is the one place that seeds demo data. It replaces the old
/// `core/mock/mock_data_seeder.dart` (17 homogeneous cattle, animals only,
/// unconditionally auto-run in `kDebugMode`): that call is removed from
/// `main.dart`, and the file itself is retired — see `main.dart` for the new
/// opt-in gating (`LIBRET_ENABLE_DEMO_DATA` dart-define, plus a debug-only
/// action in the Perfil screen).
///
/// ## Idempotency strategy
///
/// Every collection needs its own answer for "how do I write this twice
/// without duplicating it", because the repositories underneath are not
/// uniform:
///
/// - **Animals, lotes, locations, care rules, care records** carry an
///   app-controlled stable id (`demoId(...)`, or the rule/record's own
///   domain id) backed by a unique-replacing Isar index, so a plain
///   `save`/`update`/`upsert` call is already a true upsert — calling it
///   twice with the same input converges, never duplicates.
/// - **Weight, health, reproduction, production, movement, commercial and
///   cost records** have no such id — `IsarRecordRepositoryBase` mints a
///   fresh random `recordUuid` for every insert. For these, idempotency is
///   "delete every existing record the previous install wrote for this demo
///   animal, then insert the fresh set" — scoped strictly to the 40 demo
///   animal uuids, so a real user's own animals are never touched.
/// - **Milking sessions/entries** are upserted by their `demoId(...)` uuid,
///   but nothing exposes "delete a session", so a full reinstall goes
///   through `MilkingRepository.replaceAll`, keeping every non-`demo-`
///   session/entry untouched and replacing only the demo ones.
/// - **Income/expense records** are insert-only with no stable id at all;
///   they are found and replaced by the `[DEMO]` note-tag prefix (see
///   `DemoPriceBook.demoNoteTag`), not a uuid.
/// - **Agenda entries** are split the same way `AgendaReminderSyncService`
///   already splits them: anything with a `demo-` id is scenario-owned and
///   is cleared before the fresh manual tasks are written; anything else
///   (a real user's own tasks, or `auto:`-prefixed derived reminders) is
///   left alone.
/// - **Perfil** is a single global record, not a list — see
///   [_maybeWritePerfil] for why it is only ever written when it is blank or
///   already equals the demo profile.
///
/// ## Install gating
///
/// [install] only actually seeds anything when the scenario has never been
/// installed at the current [demoScenarioVersion], or when the caller passes
/// `reset: true`. A plain repeat call on an already-installed scenario is a
/// no-op — it must never silently overwrite a user's edits to a demo animal.
/// The installed-version flag is written only after every step below
/// succeeds; any exception aborts before it is set, so a failed install is
/// never mistaken for a completed one, and the next call (install or reset)
/// starts from a clean slate because every step below clears its own
/// scenario-owned rows before writing.
///
/// ## Uninstalling
///
/// [uninstall] is the opposite operation: every row whose id carries the
/// `demo-` prefix (or, for the two note-tagged finanzas collections, the
/// `[DEMO]` tag) is deleted outright rather than reset. A breeder's own
/// record that pointed at something demo-owned (their animal parked in a
/// demo corral) is not deleted — only that one pointer is cleared, so their
/// row survives with a blank location/lote instead of a reference to
/// something that no longer exists.
library;

import 'package:libretapp/core/demo/builders/demo_agenda_workforce.dart';
import 'package:libretapp/core/demo/builders/demo_animals.dart';
import 'package:libretapp/core/demo/builders/demo_commercial_costs.dart';
import 'package:libretapp/core/demo/builders/demo_finanzas.dart';
import 'package:libretapp/core/demo/builders/demo_health.dart';
import 'package:libretapp/core/demo/builders/demo_locations.dart';
import 'package:libretapp/core/demo/builders/demo_lotes.dart';
import 'package:libretapp/core/demo/builders/demo_milking.dart';
import 'package:libretapp/core/demo/builders/demo_movements.dart';
import 'package:libretapp/core/demo/builders/demo_perfil.dart';
import 'package:libretapp/core/demo/builders/demo_price_book.dart';
import 'package:libretapp/core/demo/builders/demo_production.dart';
import 'package:libretapp/core/demo/builders/demo_reproduction.dart';
import 'package:libretapp/core/demo/builders/demo_weights.dart';
import 'package:libretapp/core/demo/demo_identity.dart';
import 'package:libretapp/core/demo/demo_scenario_version.dart';
import 'package:libretapp/core/services/logger_service.dart';
import 'package:libretapp/core/services/prefs_keys.dart';
import 'package:libretapp/core/services/shared_prefs_service.dart';
import 'package:libretapp/features/agenda/data/agenda_reminder_sync_service.dart';
import 'package:libretapp/features/agenda/data/agenda_repository.dart';
import 'package:libretapp/features/agenda/data/workforce_repository.dart';
import 'package:libretapp/features/directorio/animales/domain/entities/animal_entity.dart';
import 'package:libretapp/features/directorio/animales/domain/repositories/care_repository.dart';
import 'package:libretapp/features/directorio/animales/domain/repositories/commercial_record_repository.dart';
import 'package:libretapp/features/directorio/animales/domain/repositories/cost_record_repository.dart';
import 'package:libretapp/features/directorio/animales/domain/repositories/health_record_repository.dart';
import 'package:libretapp/features/directorio/animales/domain/repositories/movement_record_repository.dart';
import 'package:libretapp/features/directorio/animales/domain/repositories/production_record_repository.dart';
import 'package:libretapp/features/directorio/animales/domain/repositories/reproduction_record_repository.dart';
import 'package:libretapp/features/directorio/animales/domain/repositories/weight_record_repository.dart';
import 'package:libretapp/features/directorio/animales/domain/services/care_calendar_service.dart';
import 'package:libretapp/features/directorio/animales/infrastructure/animal_repository.dart';
import 'package:libretapp/features/directorio/lotes/domain/entities/lote_entity.dart';
import 'package:libretapp/features/directorio/lotes/infrastructure/lotes_repository.dart';
import 'package:libretapp/features/finanzas/domain/entities/financial_period_summary.dart';
import 'package:libretapp/features/finanzas/domain/repositories/finanzas_repository.dart';
import 'package:libretapp/features/milking/domain/milking_repository.dart';
import 'package:libretapp/features/perfil/data/perfil_model.dart';
import 'package:libretapp/features/perfil/data/perfil_repository.dart';
import 'package:libretapp/features/ubicaciones/domain/repositories/location_repository.dart';

class DemoInstallResult {
  const DemoInstallResult({
    required this.installed,
    required this.alreadyInstalled,
    required this.referenceDate,
    this.counts = const {},
    this.profileWritten = false,
  });
  final bool installed;
  final bool alreadyInstalled;
  final DateTime referenceDate;
  final Map<String, int> counts;
  final bool profileWritten;
}

class DemoUninstallResult {
  const DemoUninstallResult({
    required this.removed,
    this.counts = const {},
    this.detachedReferences = 0,
    this.profileCleared = false,
  });

  /// False when there was nothing installed to take down.
  final bool removed;
  final Map<String, int> counts;

  /// Records of the breeder's own that pointed at something the demo owned
  /// (an animal parked in a demo corral, say) and had that pointer cleared
  /// so it would not dangle. Their own data is otherwise untouched.
  final int detachedReferences;
  final bool profileCleared;
}

class DemoScenarioService {
  DemoScenarioService({
    required AnimalRepository animalRepository,
    required LotesRepository lotesRepository,
    required LocationRepository locationRepository,
    required WeightRecordRepository weightRepository,
    required HealthRecordRepository healthRepository,
    required ReproductionRecordRepository reproductionRepository,
    required ProductionRecordRepository productionRepository,
    required MovementRecordRepository movementRepository,
    required CommercialRecordRepository commercialRepository,
    required CostRecordRepository costRepository,
    required CareRepository careRepository,
    required CareCalendarService careCalendarService,
    required MilkingRepository milkingRepository,
    required FinanzasRepository finanzasRepository,
    required AgendaRepository agendaRepository,
    required WorkforceRepository workforceRepository,
    required PerfilRepository perfilRepository,
    required AgendaReminderSyncService agendaReminderSyncService,
    required SharedPrefsService prefs,
  }) : _animalRepository = animalRepository,
       _lotesRepository = lotesRepository,
       _locationRepository = locationRepository,
       _weightRepository = weightRepository,
       _healthRepository = healthRepository,
       _reproductionRepository = reproductionRepository,
       _productionRepository = productionRepository,
       _movementRepository = movementRepository,
       _commercialRepository = commercialRepository,
       _costRepository = costRepository,
       _careRepository = careRepository,
       _careCalendarService = careCalendarService,
       _milkingRepository = milkingRepository,
       _finanzasRepository = finanzasRepository,
       _agendaRepository = agendaRepository,
       _workforceRepository = workforceRepository,
       _perfilRepository = perfilRepository,
       _agendaReminderSyncService = agendaReminderSyncService,
       _prefs = prefs;

  final AnimalRepository _animalRepository;
  final LotesRepository _lotesRepository;
  final LocationRepository _locationRepository;
  final WeightRecordRepository _weightRepository;
  final HealthRecordRepository _healthRepository;
  final ReproductionRecordRepository _reproductionRepository;
  final ProductionRecordRepository _productionRepository;
  final MovementRecordRepository _movementRepository;
  final CommercialRecordRepository _commercialRepository;
  final CostRecordRepository _costRepository;
  final CareRepository _careRepository;
  final CareCalendarService _careCalendarService;
  final MilkingRepository _milkingRepository;
  final FinanzasRepository _finanzasRepository;
  final AgendaRepository _agendaRepository;
  final WorkforceRepository _workforceRepository;
  final PerfilRepository _perfilRepository;
  final AgendaReminderSyncService _agendaReminderSyncService;
  final SharedPrefsService _prefs;

  static const _logTag = 'DemoScenarioService';

  /// Local-midnight normalisation: the scenario always reasons in whole
  /// days, so two calls issued at different times of the same day compute
  /// identical due dates.
  static DateTime normalizeReferenceDate(DateTime date) =>
      DateTime(date.year, date.month, date.day);

  bool get isInstalled =>
      _prefs.getInt(PrefsKeys.demoScenarioInstalledVersion) ==
      demoScenarioVersion;

  /// Installs (or re-installs) the demo scenario.
  ///
  /// [referenceDate] defaults to today (local midnight). Pass a fixed date
  /// in tests. [reset] forces a full reseed even when already installed at
  /// the current version — this is "restablecer escenario demo": every demo
  /// record is overwritten back to its canonical value, discarding whatever
  /// the user had edited on a demo animal. Without it, a repeat call on an
  /// already-installed scenario is a no-op.
  Future<DemoInstallResult> install({
    DateTime? referenceDate,
    bool reset = false,
  }) async {
    final reference = normalizeReferenceDate(referenceDate ?? DateTime.now());

    if (isInstalled && !reset) {
      return DemoInstallResult(
        installed: false,
        alreadyInstalled: true,
        referenceDate: reference,
      );
    }

    LoggerService.i(
      'Instalando escenario demo (reset=$reset, referencia=$reference)',
      tag: _logTag,
    );

    try {
      final counts = <String, int>{};
      final profileWritten = await _seedAll(reference, counts);

      await _prefs.setInt(
        PrefsKeys.demoScenarioInstalledVersion,
        demoScenarioVersion,
      );

      LoggerService.i('Escenario demo instalado: $counts', tag: _logTag);
      return DemoInstallResult(
        installed: true,
        alreadyInstalled: false,
        referenceDate: reference,
        counts: counts,
        profileWritten: profileWritten,
      );
    } catch (e, st) {
      // Never mark the scenario as installed on a partial failure — the next
      // call (with or without reset) must see it as not-installed and start
      // the clear-then-reseed sequence from scratch.
      LoggerService.e(
        'Error instalando el escenario demo: $e',
        tag: _logTag,
        stackTrace: st,
      );
      rethrow;
    }
  }

  /// Removes the demo scenario, leaving the breeder's own data in place.
  ///
  /// Ownership is decided by [demoIdPrefix] on the stored row, not by the
  /// current builders: a scenario seeded by an older version is torn down
  /// just as completely. The two ranch-level finanzas collections have no
  /// uuid to check, so they go by the `[DEMO]` note tag instead — the same
  /// marker a reinstall uses.
  ///
  /// Records of the breeder's own that referenced something demo-owned are
  /// *detached*, not deleted: an animal of theirs standing in a demo corral
  /// keeps existing, it simply stops pointing at a corral that is about to
  /// be gone. That is the one way this touches their data, and it is
  /// reported back as [DemoUninstallResult.detachedReferences].
  Future<DemoUninstallResult> uninstall() async {
    LoggerService.i('Desinstalando escenario demo', tag: _logTag);

    final counts = <String, int>{};

    final allAnimals = await _animalRepository.getAllIncludingInactive();
    final demoAnimals = allAnimals.where((a) => isDemoId(a.uuid)).toList();
    final locations = await _locationRepository.getAll();
    final demoLocationUuids = locations
        .map((l) => l.uuid)
        .where(isDemoId)
        .toSet();
    final lotes = await _lotesRepository.getAll();
    final demoLoteUuids = lotes.map((l) => l.uuid).where(isDemoId).toSet();

    final detached = await _detachForeignReferences(
      allAnimals: allAnimals,
      lotes: lotes,
      demoLoteUuids: demoLoteUuids,
      demoLocationUuids: demoLocationUuids,
    );

    // Animals and everything hanging off them.
    for (final animal in demoAnimals) {
      await _deleteAnimalRecords(animal.uuid);
      await _careRepository.deleteAllForAnimal(animal.uuid);
      // `delete` only archives — the row and its uuid would survive, which is
      // right for a real animal and wrong for one the scenario is taking back.
      await _animalRepository.purge(animal.uuid);
    }
    counts['animals'] = demoAnimals.length;

    for (final uuid in demoLoteUuids) {
      await _lotesRepository.purge(uuid);
    }
    counts['lotes'] = demoLoteUuids.length;

    for (final uuid in demoLocationUuids) {
      await _locationRepository.deleteByUuid(uuid);
    }
    counts['locations'] = demoLocationUuids.length;

    // Milking and workforce expose no per-row delete, so both are rewritten
    // without their demo rows.
    final sessions = await _milkingRepository.getAllSessions();
    final entries = await _milkingRepository.getAllEntries();
    final keptSessions = sessions.where((s) => !isDemoId(s.uuid)).toList();
    final keptEntries = entries.where((e) => !isDemoId(e.uuid)).toList();
    counts['milkingSessions'] = sessions.length - keptSessions.length;
    counts['milkingEntries'] = entries.length - keptEntries.length;
    await _milkingRepository.replaceAll(
      sessions: keptSessions,
      entries: keptEntries,
    );

    final workers = await _workforceRepository.fetchWorkers(
      includeInactive: true,
    );
    final teams = await _workforceRepository.fetchTeams(includeInactive: true);
    final keptWorkers = workers.where((w) => !isDemoId(w.id)).toList();
    final keptTeams = teams.where((t) => !isDemoId(t.id)).toList();
    counts['workers'] = workers.length - keptWorkers.length;
    counts['teams'] = teams.length - keptTeams.length;
    await _workforceRepository.replaceAll(
      workers: keptWorkers,
      teams: keptTeams,
    );

    counts.addAll(await _deleteDemoFinanzas());

    final agendaEntries = await _agendaRepository.fetchEntries();
    var removedAgenda = 0;
    for (final entry in agendaEntries) {
      if (!isDemoId(entry.id)) continue;
      await _agendaRepository.deleteEntry(entry.id);
      removedAgenda++;
    }
    counts['agendaEntries'] = removedAgenda;

    final profileCleared = await _clearPerfilIfDemo();

    await _prefs.remove(PrefsKeys.demoScenarioInstalledVersion);

    // Rebuilds the derived `auto:` reminders now that the demo animals they
    // were generated from are gone.
    await _agendaReminderSyncService.sync();

    // Uninstall is safe to call whether or not the scenario was actually
    // installed — every step above is "delete what matches, if anything" —
    // so whether something was actually removed is read back from what was
    // counted rather than assumed.
    final removedAnything =
        counts.values.any((count) => count > 0) ||
        detached > 0 ||
        profileCleared;

    LoggerService.i(
      'Escenario demo desinstalado: $counts (referencias ajenas '
      'desvinculadas: $detached)',
      tag: _logTag,
    );
    return DemoUninstallResult(
      removed: removedAnything,
      counts: counts,
      detachedReferences: detached,
      profileCleared: profileCleared,
    );
  }

  /// Clears pointers from the breeder's own rows into demo-owned ones, so
  /// nothing is left referencing a lote or location about to be deleted.
  Future<int> _detachForeignReferences({
    required List<AnimalEntity> allAnimals,
    required List<LoteEntity> lotes,
    required Set<String> demoLoteUuids,
    required Set<String> demoLocationUuids,
  }) async {
    var detached = 0;

    for (final animal in allAnimals) {
      if (isDemoId(animal.uuid)) continue;

      final losesBatch = demoLoteUuids.contains(animal.batchUuid);
      final losesCurrent = demoLocationUuids.contains(animal.currentLocationId);
      final losesInitial = demoLocationUuids.contains(animal.initialLocationId);
      if (!losesBatch && !losesCurrent && !losesInitial) continue;

      await _animalRepository.update(
        animal.copyWith(
          batchUuid: losesBatch ? null : animal.batchUuid,
          currentLocationId: losesCurrent ? null : animal.currentLocationId,
          initialLocationId: losesInitial ? null : animal.initialLocationId,
        ),
      );
      detached++;
    }

    // A lote of the breeder's own may list demo animals that are going away.
    for (final lote in lotes) {
      if (isDemoId(lote.uuid)) continue;
      final kept = lote.animalUuids.where((u) => !isDemoId(u)).toList();
      if (kept.length == lote.animalUuids.length) continue;
      await _lotesRepository.upsert(lote.copyWith(animalUuids: kept));
      detached++;
    }

    return detached;
  }

  Future<void> _deleteAnimalRecords(String animalUuid) async {
    for (final record in await _weightRepository.getWeightRecords(animalUuid)) {
      if (record.id != null) {
        await _weightRepository.deleteWeightRecord(record.id!);
      }
    }
    for (final record in await _healthRepository.getHealthRecords(animalUuid)) {
      if (record.id != null) {
        await _healthRepository.deleteHealthRecord(record.id!);
      }
    }
    for (final record in await _reproductionRepository.getReproductionRecords(
      animalUuid,
    )) {
      if (record.id != null) {
        await _reproductionRepository.deleteReproductionRecord(record.id!);
      }
    }
    for (final record in await _productionRepository.getProductionRecords(
      animalUuid,
    )) {
      if (record.id != null) {
        await _productionRepository.deleteProductionRecord(record.id!);
      }
    }
    for (final record in await _movementRepository.getMovementRecords(
      animalUuid,
    )) {
      if (record.id != null) {
        await _movementRepository.deleteMovementRecord(record.id!);
      }
    }
    for (final record in await _commercialRepository.getCommercialRecords(
      animalUuid,
    )) {
      if (record.id != null) {
        await _commercialRepository.deleteCommercialRecord(record.id!);
      }
    }
    for (final record in await _costRepository.getCostRecords(animalUuid)) {
      if (record.id != null) {
        await _costRepository.deleteCostRecord(record.id!);
      }
    }
  }

  Future<Map<String, int>> _deleteDemoFinanzas() async {
    final now = DateTime.now();
    final range = DateRange(
      start: DateTime(now.year - 5, 1, 1),
      end: DateTime(now.year + 5, 12, 31),
    );

    var removedIncomes = 0;
    for (final income in await _finanzasRepository.getIncomes(range)) {
      if (income.notes?.startsWith(DemoPriceBook.demoNoteTag) != true) continue;
      if (income.id == null) continue;
      await _finanzasRepository.deleteIncome(income.id!);
      removedIncomes++;
    }

    var removedExpenses = 0;
    for (final expense in await _finanzasRepository.getExpenses(range)) {
      if (expense.notes?.startsWith(DemoPriceBook.demoNoteTag) != true) {
        continue;
      }
      if (expense.id == null) continue;
      await _finanzasRepository.deleteExpense(expense.id!);
      removedExpenses++;
    }

    return {
      'incomeRecords': removedIncomes,
      'generalExpenseRecords': removedExpenses,
    };
  }

  /// Blanks the farm profile only while it is still verbatim the demo one.
  ///
  /// The mirror of [_maybeWritePerfil]: if the breeder has since typed their
  /// own ranch name over it, that is theirs and stays.
  Future<bool> _clearPerfilIfDemo() async {
    final current = await _perfilRepository.fetchPerfil();
    if (current.nombre != demoPerfil.nombre ||
        current.finca != demoPerfil.finca) {
      return false;
    }
    await _perfilRepository.updatePerfil(
      const Perfil(
        id: '',
        nombre: '',
        apellido: '',
        email: '',
        telefono: '',
        finca: '',
        direccion: '',
      ),
    );
    return true;
  }

  Future<bool> _seedAll(DateTime reference, Map<String, int> counts) async {
    // 1. Locations — upsert by uuid, always safe to repeat.
    final locations = buildDemoLocations(reference: reference);
    for (final location in locations) {
      await _locationRepository.upsert(location);
    }
    counts['locations'] = locations.length;

    // 2. Lotes, empty roster — filled in step 4.
    final lotes = buildDemoLotes(reference: reference);
    for (final lote in lotes) {
      await _lotesRepository.upsert(lote);
    }
    counts['lotes'] = lotes.length;

    // 3. Animals — upsert by uuid (update if present, save if not: a plain
    // `save()` twice would violate the unique index on `uuid`).
    final animals = buildDemoAnimals(reference: reference);
    for (final animal in animals) {
      final existing = await _animalRepository.getByUuid(animal.uuid);
      if (existing == null) {
        await _animalRepository.save(animal);
      } else {
        await _animalRepository.update(animal);
      }
    }
    counts['animals'] = animals.length;

    // 4. Lote membership, derived from the animals just written.
    await recomputeDemoLoteMembership(_lotesRepository, animals);

    final animalUuids = animals.map((a) => a.uuid).toList(growable: false);

    // 5. Per-animal child records with no stable id: clear this demo
    // animal's previous rows, then write the fresh set.
    await _reinstallWeights(reference, animalUuids, counts);
    await _reinstallHealth(reference, animalUuids, counts);
    await _reinstallReproduction(reference, animalUuids, counts);
    await _reinstallProduction(reference, animalUuids, counts);
    await _reinstallMovements(reference, animalUuids, counts);
    await _reinstallCommercial(reference, animalUuids, counts);
    await _reinstallCosts(reference, animalUuids, counts);

    // 6. Care calendar: default rules (idempotent — only fills in ids
    // missing from storage) + demo care history (idempotent — unique
    // replacing index on the record's own id).
    await _careCalendarService.preloadDefaults(alreadyLoaded: false);
    final careSeries = buildDemoCareRecords(reference: reference);
    var careRecordCount = 0;
    for (final series in careSeries) {
      for (final record in series.records) {
        await _careRepository.saveRecord(record);
        careRecordCount++;
      }
    }
    counts['careRecords'] = careRecordCount;

    // 7. Milking — replace only the demo-owned sessions/entries.
    final milking = buildDemoMilking(reference: reference);
    final existingSessions = await _milkingRepository.getAllSessions();
    final existingEntries = await _milkingRepository.getAllEntries();
    await _milkingRepository.replaceAll(
      sessions: [
        ...existingSessions.where((s) => !s.uuid.startsWith('demo-')),
        ...milking.sessions,
      ],
      entries: [
        ...existingEntries.where((e) => !e.uuid.startsWith('demo-')),
        ...milking.entries,
      ],
    );
    counts['milkingSessions'] = milking.sessions.length;
    counts['milkingEntries'] = milking.entries.length;

    // 8. Finanzas — insert-only collections, found by the `[DEMO]` note tag.
    await _reinstallFinanzas(reference, counts);

    // 9. Workforce — upsert by id.
    final workers = buildDemoWorkers(reference: reference);
    for (final worker in workers) {
      await _workforceRepository.saveWorker(worker);
    }
    counts['workers'] = workers.length;
    final teams = buildDemoTeams(reference: reference);
    for (final team in teams) {
      await _workforceRepository.saveTeam(team);
    }
    counts['teams'] = teams.length;

    // 10. Agenda manual tasks — clear this scenario's previous entries
    // (every id here uses the `demo-` prefix; `auto:` reminders and a real
    // user's own tasks never match), then write the fresh set.
    final existingAgenda = await _agendaRepository.fetchEntries();
    for (final entry in existingAgenda) {
      if (entry.id.startsWith('demo-')) {
        await _agendaRepository.deleteEntry(entry.id);
      }
    }
    final agendaEntries = buildDemoAgendaEntries(reference: reference);
    for (final entry in agendaEntries) {
      await _agendaRepository.saveEntry(entry);
    }
    counts['agendaEntries'] = agendaEntries.length;

    // 11. Perfil — see _maybeWritePerfil for why this is guarded.
    final profileWritten = await _maybeWritePerfil();

    // 12. Derive care schedules + automatic agenda reminders for the whole
    // active herd (demo and real alike) from what was just written — the
    // same recompute the app already runs on every start.
    await _agendaReminderSyncService.sync();

    return profileWritten;
  }

  // ── Per-animal record reinstallation ────────────────────────────────────

  Future<void> _reinstallWeights(
    DateTime reference,
    List<String> animalUuids,
    Map<String, int> counts,
  ) async {
    final bySlug = <String, List<dynamic>>{
      for (final s in buildDemoWeights(reference: reference))
        demoAnimalUuid(s.animalSlug): s.records,
    };
    var written = 0;
    for (final uuid in animalUuids) {
      final existing = await _weightRepository.getWeightRecords(uuid);
      for (final record in existing) {
        if (record.id != null) {
          await _weightRepository.deleteWeightRecord(record.id!);
        }
      }
      for (final record in (bySlug[uuid] ?? const [])) {
        await _weightRepository.addWeightRecord(uuid, record);
        written++;
      }
    }
    counts['weightRecords'] = written;
  }

  Future<void> _reinstallHealth(
    DateTime reference,
    List<String> animalUuids,
    Map<String, int> counts,
  ) async {
    final bySlug = <String, List<dynamic>>{
      for (final s in buildDemoHealthRecords(reference: reference))
        demoAnimalUuid(s.animalSlug): s.records,
    };
    var written = 0;
    for (final uuid in animalUuids) {
      final existing = await _healthRepository.getHealthRecords(uuid);
      for (final record in existing) {
        if (record.id != null) {
          await _healthRepository.deleteHealthRecord(record.id!);
        }
      }
      for (final record in (bySlug[uuid] ?? const [])) {
        await _healthRepository.addHealthRecord(uuid, record);
        written++;
      }
    }
    counts['healthRecords'] = written;
  }

  Future<void> _reinstallReproduction(
    DateTime reference,
    List<String> animalUuids,
    Map<String, int> counts,
  ) async {
    final bySlug = <String, List<dynamic>>{};
    for (final entry in buildDemoReproductionRecords(reference: reference)) {
      bySlug
          .putIfAbsent(demoAnimalUuid(entry.animalSlug), () => [])
          .add(entry.record);
    }
    var written = 0;
    for (final uuid in animalUuids) {
      final existing = await _reproductionRepository.getReproductionRecords(
        uuid,
      );
      for (final record in existing) {
        if (record.id != null) {
          await _reproductionRepository.deleteReproductionRecord(record.id!);
        }
      }
      for (final record in (bySlug[uuid] ?? const [])) {
        await _reproductionRepository.addReproductionRecord(uuid, record);
        written++;
      }
    }
    counts['reproductionRecords'] = written;
  }

  Future<void> _reinstallProduction(
    DateTime reference,
    List<String> animalUuids,
    Map<String, int> counts,
  ) async {
    final bySlug = <String, List<dynamic>>{};
    for (final entry in buildDemoProductionRecords(reference: reference)) {
      bySlug
          .putIfAbsent(demoAnimalUuid(entry.animalSlug), () => [])
          .add(entry.record);
    }
    var written = 0;
    for (final uuid in animalUuids) {
      final existing = await _productionRepository.getProductionRecords(uuid);
      for (final record in existing) {
        if (record.id != null) {
          await _productionRepository.deleteProductionRecord(record.id!);
        }
      }
      for (final record in (bySlug[uuid] ?? const [])) {
        await _productionRepository.addProductionRecord(uuid, record);
        written++;
      }
    }
    counts['productionRecords'] = written;
  }

  Future<void> _reinstallMovements(
    DateTime reference,
    List<String> animalUuids,
    Map<String, int> counts,
  ) async {
    final bySlug = <String, List<dynamic>>{};
    for (final entry in buildDemoMovementRecords(reference: reference)) {
      bySlug
          .putIfAbsent(demoAnimalUuid(entry.animalSlug), () => [])
          .add(entry.record);
    }
    var written = 0;
    for (final uuid in animalUuids) {
      final existing = await _movementRepository.getMovementRecords(uuid);
      for (final record in existing) {
        if (record.id != null) {
          await _movementRepository.deleteMovementRecord(record.id!);
        }
      }
      for (final record in (bySlug[uuid] ?? const [])) {
        await _movementRepository.addMovementRecord(uuid, record);
        written++;
      }
    }
    counts['movementRecords'] = written;
  }

  Future<void> _reinstallCommercial(
    DateTime reference,
    List<String> animalUuids,
    Map<String, int> counts,
  ) async {
    final bySlug = <String, List<dynamic>>{};
    for (final entry in buildDemoCommercialRecords(reference: reference)) {
      bySlug
          .putIfAbsent(demoAnimalUuid(entry.animalSlug), () => [])
          .add(entry.record);
    }
    var written = 0;
    for (final uuid in animalUuids) {
      final existing = await _commercialRepository.getCommercialRecords(uuid);
      for (final record in existing) {
        if (record.id != null) {
          await _commercialRepository.deleteCommercialRecord(record.id!);
        }
      }
      for (final record in (bySlug[uuid] ?? const [])) {
        await _commercialRepository.addCommercialRecord(uuid, record);
        written++;
      }
    }
    counts['commercialRecords'] = written;
  }

  Future<void> _reinstallCosts(
    DateTime reference,
    List<String> animalUuids,
    Map<String, int> counts,
  ) async {
    final bySlug = <String, List<dynamic>>{};
    for (final entry in buildDemoCostRecords(reference: reference)) {
      bySlug
          .putIfAbsent(demoAnimalUuid(entry.animalSlug), () => [])
          .add(entry.record);
    }
    var written = 0;
    for (final uuid in animalUuids) {
      final existing = await _costRepository.getCostRecords(uuid);
      for (final record in existing) {
        if (record.id != null) {
          await _costRepository.deleteCostRecord(record.id!);
        }
      }
      for (final record in (bySlug[uuid] ?? const [])) {
        await _costRepository.addCostRecord(uuid, record);
        written++;
      }
    }
    counts['costRecords'] = written;
  }

  Future<void> _reinstallFinanzas(
    DateTime reference,
    Map<String, int> counts,
  ) async {
    // Wide enough to catch every demo entry regardless of the reference
    // date's position in the calendar.
    final range = DateRange(
      start: DateTime(reference.year - 1, 1, 1),
      end: DateTime(reference.year + 1, 12, 31),
    );

    const tag = '[DEMO]';
    final existingIncomes = await _finanzasRepository.getIncomes(range);
    for (final income in existingIncomes) {
      if (income.notes?.startsWith(tag) == true && income.id != null) {
        await _finanzasRepository.deleteIncome(income.id!);
      }
    }
    final existingExpenses = await _finanzasRepository.getExpenses(range);
    for (final expense in existingExpenses) {
      if (expense.notes?.startsWith(tag) == true && expense.id != null) {
        await _finanzasRepository.deleteExpense(expense.id!);
      }
    }

    final incomes = buildDemoIncomes(reference: reference);
    for (final income in incomes) {
      await _finanzasRepository.addIncome(income);
    }
    counts['incomeRecords'] = incomes.length;

    final expenses = buildDemoExpenses(reference: reference);
    for (final expense in expenses) {
      await _finanzasRepository.addExpense(expense);
    }
    counts['generalExpenseRecords'] = expenses.length;
  }

  /// Writes [demoPerfil] only when it is safe to: the stored profile is
  /// blank (nothing a real breeder typed yet), or it already equals the
  /// demo profile (a previous install wrote it — safe to refresh). Any other
  /// stored profile is treated as real user data and is left untouched, even
  /// under `reset: true` — a farm profile is a single global record, not a
  /// `demo-*`-scoped list, so there is no id-based way to tell "the demo's
  /// copy" apart from "what the breeder typed over it" once it stops
  /// matching byte-for-byte.
  Future<bool> _maybeWritePerfil() async {
    final current = await _perfilRepository.fetchPerfil();
    final isBlank =
        current.nombre.trim().isEmpty && current.finca.trim().isEmpty;
    final isOurs =
        current.nombre == demoPerfil.nombre &&
        current.finca == demoPerfil.finca;
    if (!isBlank && !isOurs) {
      LoggerService.w(
        'Perfil existente no vacío y distinto al de demostración: no se '
        'sobrescribe.',
        tag: _logTag,
      );
      return false;
    }
    await _perfilRepository.updatePerfil(demoPerfil);
    return true;
  }
}
