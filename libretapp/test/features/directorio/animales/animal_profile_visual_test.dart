import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:libretapp/core/di/injection.dart';
import 'package:libretapp/features/agenda/data/agenda_model.dart';
import 'package:libretapp/features/agenda/data/agenda_repository.dart';
import 'package:libretapp/features/directorio/animales/domain/animal_domain.dart';
import 'package:libretapp/features/directorio/animales/domain/entities/care_record.dart';
import 'package:libretapp/features/directorio/animales/domain/entities/care_rule.dart';
import 'package:libretapp/features/directorio/animales/domain/entities/scheduled_care.dart';
import 'package:libretapp/features/directorio/animales/domain/repositories/care_repository.dart';
import 'package:libretapp/features/directorio/animales/domain/repositories/weight_record_repository.dart';
import 'package:libretapp/features/directorio/animales/domain/repositories/health_record_repository.dart';
import 'package:libretapp/features/directorio/animales/domain/repositories/reproduction_record_repository.dart';
import 'package:libretapp/features/directorio/animales/domain/repositories/production_record_repository.dart';
import 'package:libretapp/features/directorio/animales/domain/repositories/commercial_record_repository.dart';
import 'package:libretapp/features/directorio/animales/domain/repositories/movement_record_repository.dart';
import 'package:libretapp/features/directorio/animales/domain/repositories/cost_record_repository.dart';
import 'package:libretapp/features/directorio/animales/infrastructure/animal_repository.dart';
import 'package:libretapp/features/directorio/animales/view/animal_detail_page.dart';
import 'package:libretapp/features/directorio/lotes/infrastructure/lotes_repository.dart';
import 'package:libretapp/features/directorio/lotes/domain/entities/lote_entity.dart';
import 'package:libretapp/features/milking/domain/milking_repository.dart';
import 'package:libretapp/features/milking/domain/milking_models.dart';
import 'package:libretapp/l10n/app_localizations.dart';
import 'package:libretapp/theme/app_theme.dart';
import 'advisor/rules/rule_test_fixtures.dart';

class _Animals implements AnimalRepository {
  _Animals(this.animal);
  final AnimalEntity animal;
  @override
  Future<AnimalEntity?> getByUuid(String uuid) async => animal;
  @override
  Future<List<AnimalEntity>> getByParentUuid(String uuid) async => [];
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _Lotes implements LotesRepository {
  @override
  Future<LoteEntity?> getByUuid(String uuid) async => null;
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _Care implements CareRepository {
  @override
  Future<List<CareRule>> getRules() async => [
    const CareRule(
      id: 'r1',
      name: 'Revisión preventiva y cuidado general',
      type: CareType.vaccination,
      intervalDays: 30,
    ),
  ];
  @override
  Future<Map<String, CareRecord>> getLatestRecordsByRule(String uuid) async =>
      {};
  @override
  Future<void> saveSchedules(List<ScheduledCare> schedules) async {}
  @override
  Future<List<CareRecord>> getRecordsForAnimal(String uuid) async => [];
  @override
  Future<List<ScheduledCare>> getPendingForAnimal(String uuid) async => [];
  @override
  Future<void> clearGeneratedFor(String uuid) async {}
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _Records
    implements
        WeightRecordRepository,
        HealthRecordRepository,
        ReproductionRecordRepository,
        ProductionRecordRepository,
        CommercialRecordRepository,
        MovementRecordRepository,
        CostRecordRepository,
        MilkingRepository {
  @override
  Future<List<WeightRecord>> getWeightRecords(String uuid) async => [];
  @override
  Future<List<HealthRecord>> getHealthRecords(String uuid) async => [];
  @override
  Future<List<ReproductionRecord>> getReproductionRecords(String uuid) async =>
      [];
  @override
  Future<List<ReproductionRecord>> getRecordsBySire(String uuid) async => [];
  @override
  Future<List<ProductionRecord>> getProductionRecords(String uuid) async => [];
  @override
  Future<List<CommercialRecord>> getCommercialRecords(String uuid) async => [];
  @override
  Future<List<MovementRecord>> getMovementRecords(String uuid) async => [];
  @override
  Future<List<CostRecord>> getCostRecords(String uuid) async => [];
  @override
  Future<List<MilkingRecord>> getRecordsByAnimal(String uuid) async => [];
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _Agenda implements AgendaRepository {
  @override
  Future<List<AgendaEntry>> fetchEntries() async => [];
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  setUpAll(() async {
    // Flutter's bundled font makes exported captures readable outside the test runner.
    final fontDirectory =
        Platform.environment['FLUTTER_FONT_DIR'] ??
        '${File(Platform.resolvedExecutable).parent.parent.parent.path}/material_fonts';
    for (final font in [
      ('Roboto', 'roboto-regular.ttf'),
      ('MaterialIcons', 'materialicons-regular.otf'),
    ]) {
      final file = File('$fontDirectory/${font.$2}');
      if (file.existsSync()) {
        final loader = FontLoader(font.$1)
          ..addFont(
            Future.value(ByteData.sublistView(await file.readAsBytes())),
          );
        await loader.load();
      }
    }
  });
  tearDown(() async => locator.reset());
  for (final species in Species.values) {
    for (final dark in [false, true]) {
      for (final config in [(360.0, 1.0), (320.0, 2.0), (412.0, 1.0)]) {
        testWidgets(
          '$species ${dark ? "dark" : "light"} ${config.$1}dp text ${config.$2}',
          (tester) async {
            tester.view.physicalSize = Size(config.$1, 900);
            tester.view.devicePixelRatio = 1;
            addTearDown(tester.view.resetPhysicalSize);
            addTearDown(tester.view.resetDevicePixelRatio);
            final animal =
                buildAnimal(
                  species: species,
                  sex: Sex.female,
                  productionPurpose: species == Species.canine
                      ? ProductionPurpose.companion
                      : ProductionPurpose.meat,
                  weight: null,
                ).copyWith(
                  customName: species == Species.canine
                      ? 'Luna'
                      : 'Mezquite · ${species.displayName}',
                  earTagNumber: 'MZQ-0040',
                  profilePhoto: 'missing-photo.jpg',
                );
            final records = _Records();
            final key = GlobalKey();
            await tester.pumpWidget(
              MaterialApp(
                theme: (dark ? AppTheme.darkTheme : AppTheme.lightTheme)
                    .copyWith(
                      textTheme:
                          (dark ? AppTheme.darkTheme : AppTheme.lightTheme)
                              .textTheme
                              .apply(fontFamily: 'Roboto'),
                      primaryTextTheme:
                          (dark ? AppTheme.darkTheme : AppTheme.lightTheme)
                              .primaryTextTheme
                              .apply(fontFamily: 'Roboto'),
                    ),
                locale: const Locale('es'),
                localizationsDelegates: AppLocalizations.localizationsDelegates,
                supportedLocales: AppLocalizations.supportedLocales,
                builder: (context, child) => MediaQuery(
                  data: MediaQuery.of(
                    context,
                  ).copyWith(textScaler: TextScaler.linear(config.$2)),
                  child: child!,
                ),
                home: RepaintBoundary(
                  key: key,
                  child: AnimalDetailPage(
                    animalUuid: animal.uuid,
                    repository: _Animals(animal),
                    lotesRepository: _Lotes(),
                    careRepo: _Care(),
                    weightRepo: records,
                    healthRepo: records,
                    reproductionRepo: records,
                    productionRepo: records,
                    commercialRepo: records,
                    movementRepo: records,
                    costRepo: records,
                    milkingRepo: records,
                    agendaRepository: _Agenda(),
                  ),
                ),
              ),
            );
            await tester.pumpAndSettle();
            expect(find.text('Resumen'), findsOneWidget);
            expect(tester.takeException(), isNull);
            if (Platform.environment['LIBRET_CAPTURE_DIR'] != null &&
                config.$1 == 360) {
              await tester.runAsync(() async {
                final dir = Directory(
                  Platform.environment['LIBRET_CAPTURE_DIR']!,
                )..createSync(recursive: true);
                final boundary =
                    key.currentContext!.findRenderObject()!
                        as RenderRepaintBoundary;
                final img = await boundary.toImage();
                final png = await img.toByteData(
                  format: ui.ImageByteFormat.png,
                );
                await File(
                  '${dir.path}/profile-${species.name}-${dark ? "dark" : "light"}.png',
                ).writeAsBytes(png!.buffer.asUint8List());
                img.dispose();
              });
            }
            for (final tab in [
              'Cuidados',
              'Registros',
              'Genealogía',
              'Historial',
              'Resumen',
            ]) {
              await tester.ensureVisible(find.text(tab));
              await tester.tap(find.text(tab));
              await tester.pumpAndSettle();
              expect(
                tester.takeException(),
                isNull,
                reason: '$tab ${config.$1}dp/${config.$2}',
              );
            }
          },
        );
      }
    }
  }
}
