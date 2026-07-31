/// Drives the three modes of the reproduction page.
///
/// The page decides between registering a service, a pregnancy diagnosis or a
/// calving from the selected cow's own state. That branching is where the
/// cycle used to break — a service stored fine, but nothing could confirm the
/// pregnancy, so the calving step was unreachable — and no test covered it.
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:libretapp/core/di/injection.dart';
import 'package:libretapp/features/directorio/animales/domain/animal_domain.dart';
import 'package:libretapp/features/directorio/animales/domain/enums/production_stage.dart';
import 'package:libretapp/features/directorio/animales/domain/enums/production_system.dart';
import 'package:libretapp/features/directorio/animales/domain/repositories/commercial_record_repository.dart';
import 'package:libretapp/features/directorio/animales/domain/repositories/cost_record_repository.dart';
import 'package:libretapp/features/directorio/animales/domain/repositories/health_record_repository.dart';
import 'package:libretapp/features/directorio/animales/domain/repositories/movement_record_repository.dart';
import 'package:libretapp/features/directorio/animales/domain/repositories/production_record_repository.dart';
import 'package:libretapp/features/directorio/animales/domain/repositories/reproduction_record_repository.dart';
import 'package:libretapp/features/directorio/animales/domain/repositories/weight_record_repository.dart';
import 'package:libretapp/features/directorio/animales/infrastructure/animal_repository.dart';
import 'package:libretapp/features/registro/view/registro_reproduccion_page.dart';
import 'package:libretapp/l10n/app_localizations.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late _FakeReproductionRepository reproductionRepo;

  void register({List<ReproductionRecord> records = const []}) {
    reproductionRepo = _FakeReproductionRepository(records);
    locator
      ..registerSingleton<AnimalRepository>(_FakeAnimalRepository())
      ..registerSingleton<ReproductionRecordRepository>(reproductionRepo)
      ..registerSingleton<WeightRecordRepository>(_Unused())
      ..registerSingleton<HealthRecordRepository>(_Unused())
      ..registerSingleton<ProductionRecordRepository>(_Unused())
      ..registerSingleton<CommercialRecordRepository>(_Unused())
      ..registerSingleton<MovementRecordRepository>(_Unused())
      ..registerSingleton<CostRecordRepository>(_Unused());
  }

  tearDown(() async => locator.reset());

  Future<void> open(WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        locale: const Locale('es'),
        home: const RegistroReproduccionPage(),
      ),
    );
    await tester.pumpAndSettle();

    // Two selectors now live on the page — the cow and the sire — so this
    // has to target the first one explicitly.
    await tester.tap(find.text('Seleccionar animal').first);
    await tester.pumpAndSettle();
    await tester.tap(find.textContaining('TAG-VACA').last);
    await tester.pumpAndSettle();
  }

  testWidgets('a cow with no open cycle gets the service form', (tester) async {
    register();
    await open(tester);

    expect(find.text('Registrar diagnóstico de preñez'), findsNothing);
    expect(find.text('Registrar el parto de este ciclo'), findsNothing);
    // The service form is what stays on screen.
    expect(find.text('Guardar'), findsOneWidget);
  });

  testWidgets('the expected calving arrives already projected', (tester) async {
    // 283 days from today, so the user never has to count them by hand.
    register();
    await open(tester);

    final due = DateTime.now().add(const Duration(days: 283));
    final label =
        '${due.day.toString().padLeft(2, '0')}/'
        '${due.month.toString().padLeft(2, '0')}/${due.year}';

    expect(find.text(label), findsOneWidget);
  });

  testWidgets('an undiagnosed service offers the diagnosis step', (
    tester,
  ) async {
    register(
      records: [
        ReproductionRecord(
          id: '1',
          serviceDate: DateTime(2026, 1, 10),
          serviceType: ServiceType.naturalService,
        ),
      ],
    );
    await open(tester);

    expect(find.text('Registrar diagnóstico de preñez'), findsOneWidget);

    await tester.tap(find.byType(SwitchListTile));
    await tester.pumpAndSettle();

    expect(find.text('Guardar diagnóstico'), findsOneWidget);
    expect(find.text('Resultado'), findsOneWidget);
  });

  testWidgets('a confirmed pregnancy offers the calving step', (tester) async {
    register(
      records: [
        ReproductionRecord(
          id: '1',
          serviceDate: DateTime(2026, 1, 10),
          serviceType: ServiceType.naturalService,
          pregnancyResult: PregnancyCheckResult.positive,
          expectedCalvingDate: DateTime(2026, 10, 20),
        ),
      ],
    );
    await open(tester);

    expect(find.text('Registrar el parto de este ciclo'), findsOneWidget);
    // A cycle awaiting calving is past the diagnosis step.
    expect(find.text('Registrar diagnóstico de preñez'), findsNothing);

    await tester.tap(find.byType(SwitchListTile));
    await tester.pumpAndSettle();

    expect(find.text('Registrar parto'), findsOneWidget);
    expect(find.text('Desenlace'), findsOneWidget);
    expect(find.text('Dificultad del parto'), findsOneWidget);
  });

  testWidgets('an already calved cycle offers neither step', (tester) async {
    register(
      records: [
        ReproductionRecord(
          id: '1',
          serviceDate: DateTime(2026, 1, 10),
          serviceType: ServiceType.naturalService,
          pregnancyResult: PregnancyCheckResult.positive,
          actualCalvingDate: DateTime(2026, 10, 20),
          calvingOutcome: CalvingOutcome.liveBirth,
        ),
      ],
    );
    await open(tester);

    expect(find.text('Registrar el parto de este ciclo'), findsNothing);
    expect(find.text('Registrar diagnóstico de preñez'), findsNothing);
  });

  testWidgets('saving a diagnosis updates the service, not a new record', (
    tester,
  ) async {
    register(
      records: [
        ReproductionRecord(
          id: '7',
          serviceDate: DateTime(2026, 1, 10),
          serviceType: ServiceType.naturalService,
        ),
      ],
    );
    await open(tester);

    await tester.tap(find.byType(SwitchListTile));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Guardar diagnóstico'));
    await tester.pumpAndSettle();

    expect(reproductionRepo.saved, hasLength(1));
    final saved = reproductionRepo.saved.single;
    expect(
      saved.id,
      '7',
      reason: 'keeping the id is what makes this an update instead of a new '
          'cycle for the same pregnancy',
    );
    expect(saved.pregnancyResult, PregnancyCheckResult.positive);
    expect(saved.expectedCalvingDate, isNotNull);
  });
}

class _FakeReproductionRepository implements ReproductionRecordRepository {
  _FakeReproductionRepository(this._records);
  final List<ReproductionRecord> _records;

  final List<ReproductionRecord> saved = [];

  @override
  Future<List<ReproductionRecord>> getReproductionRecords(
    String animalUuid,
  ) async => _records;

  @override
  Future<ReproductionRecord> addReproductionRecord(
    String animalUuid,
    ReproductionRecord record,
  ) async {
    saved.add(record);
    return record;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeAnimalRepository implements AnimalRepository {
  @override
  Future<List<AnimalEntity>> getAll() async => [_cow];

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

/// The page's bloc wires up every record repository, but this test only
/// exercises the reproduction one; the rest just need to exist.
class _Unused
    implements
        WeightRecordRepository,
        HealthRecordRepository,
        ProductionRecordRepository,
        CommercialRecordRepository,
        MovementRecordRepository,
        CostRecordRepository {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

final _cow = AnimalEntity(
  uuid: 'vaca-1',
  earTagNumber: 'TAG-VACA-1',
  customName: 'Lucera',
  species: Species.cattle,
  category: Category.cow,
  lifeStage: LifeStage.cow,
  sex: Sex.female,
  breed: 'Cebu',
  birthDate: DateTime(2021, 1, 1),
  ageMonths: 60,
  healthStatus: HealthStatus.good,
  vaccinated: true,
  dewormed: true,
  hasVitamins: true,
  hasChronicIssues: false,
  reproductiveStatus: ReproductiveStatus.active,
  productionPurpose: ProductionPurpose.breeding,
  productionStage: ProductionStage.reproductive,
  productionSystem: ProductionSystem.extensive,
  underObservation: false,
  requiresAttention: false,
  riskLevel: RiskLevel.low,
  gallery: const [],
  status: AnimalStatus.active,
  synced: false,
  creationDate: DateTime(2025, 1, 1),
  lastUpdateDate: DateTime(2025, 1, 1),
);
