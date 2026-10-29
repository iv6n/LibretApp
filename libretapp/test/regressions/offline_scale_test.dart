import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:libretapp/core/di/injection.dart';
import 'package:libretapp/core/platform/release_features.dart';
import 'package:libretapp/features/directorio/animales/domain/animal_domain.dart';
import 'package:libretapp/features/directorio/animales/infrastructure/animal_repository.dart';
import 'package:libretapp/features/directorio/animales/domain/repositories/weight_record_repository.dart';
import 'package:libretapp/features/directorio/animales/domain/repositories/health_record_repository.dart';
import 'package:libretapp/features/directorio/animales/domain/repositories/production_record_repository.dart';
import 'package:libretapp/features/directorio/animales/domain/repositories/reproduction_record_repository.dart';
import 'package:libretapp/features/directorio/animales/domain/repositories/movement_record_repository.dart';
import 'package:libretapp/features/directorio/animales/domain/repositories/commercial_record_repository.dart';
import 'package:libretapp/features/directorio/animales/domain/repositories/cost_record_repository.dart';
import 'package:libretapp/features/registro/view/registro_peso_page.dart';
import 'package:libretapp/features/rfid/domain/rfid_models.dart';
import 'package:libretapp/features/rfid/infrastructure/simulated_hardware.dart';
import 'package:libretapp/l10n/app_localizations.dart';

class _Animals implements AnimalRepository {
  @override
  Future<List<AnimalEntity>> getAll() async => [];
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _Unused
    implements
        WeightRecordRepository,
        HealthRecordRepository,
        ProductionRecordRepository,
        ReproductionRecordRepository,
        MovementRecordRepository,
        CommercialRecordRepository,
        CostRecordRepository {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  testWidgets('offline does not offer simulated scale capture', (tester) async {
    expect(ReleaseFeatures.offlinePilot, true);
    expect(ReleaseFeatures.hardwareIntegrationsEnabled, false);
    final repos = _Unused();
    final scale = SimulatedScaleAdapter();
    addTearDown(() async {
      await locator.reset();
      await scale.dispose();
    });
    locator
      ..registerSingleton<AnimalRepository>(_Animals())
      ..registerSingleton<WeightRecordRepository>(repos)
      ..registerSingleton<HealthRecordRepository>(repos)
      ..registerSingleton<ProductionRecordRepository>(repos)
      ..registerSingleton<ReproductionRecordRepository>(repos)
      ..registerSingleton<MovementRecordRepository>(repos)
      ..registerSingleton<CommercialRecordRepository>(repos)
      ..registerSingleton<CostRecordRepository>(repos)
      ..registerSingleton<ScaleAdapter>(scale);
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        locale: const Locale('es'),
        home: const RegistroPesoPage(),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Tomar lectura de báscula'), findsNothing);
    expect(
      tester
          .widget<TextFormField>(find.byType(TextFormField).first)
          .controller!
          .text,
      isEmpty,
    );
    expect(tester.takeException(), isNull);
  }, skip: !ReleaseFeatures.offlinePilot);
}
