import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:libretapp/core/di/injection.dart';
import 'package:libretapp/core/widgets/record_load_failure.dart';
import 'package:libretapp/features/directorio/animales/domain/animal_domain.dart';
import 'package:libretapp/features/directorio/animales/domain/repositories/weight_record_repository.dart';
import 'package:libretapp/features/directorio/animales/domain/repositories/production_record_repository.dart';
import 'package:libretapp/features/directorio/animales/domain/repositories/movement_record_repository.dart';
import 'package:libretapp/features/directorio/animales/domain/repositories/commercial_record_repository.dart';
import 'package:libretapp/features/directorio/animales/domain/repositories/cost_record_repository.dart';
import 'package:libretapp/features/directorio/animales/infrastructure/animal_repository.dart';
import 'package:libretapp/features/directorio/animales/view/animal_weight_form_page.dart';
import 'package:libretapp/features/directorio/animales/view/animal_production_form_page.dart';
import 'package:libretapp/features/directorio/animales/view/animal_movement_form_page.dart';
import 'package:libretapp/features/directorio/animales/view/animal_commercial_form_page.dart';
import 'package:libretapp/features/directorio/animales/view/animal_cost_form_page.dart';
import 'package:libretapp/l10n/app_localizations.dart';
import '../features/directorio/animales/advisor/rules/rule_test_fixtures.dart';

class _Records implements WeightRecordRepository, ProductionRecordRepository,
    MovementRecordRepository, CommercialRecordRepository, CostRecordRepository {
  int attempts = 0;
  Future<List<T>> read<T>(T record) async {
    if (attempts++ == 0) throw StateError('Lectura interrumpida');
    return [record];
  }
  @override
  Future<List<WeightRecord>> getWeightRecords(String _) => read(WeightRecord(id:'1',date:DateTime(2026),weight:125,method:WeightMethod.scale));
  @override
  Future<List<ProductionRecord>> getProductionRecords(String _) => read(ProductionRecord(id:'1',date:DateTime(2026),type:ProductionRecordType.production,value:15));
  @override
  Future<List<MovementRecord>> getMovementRecords(String _) => read(MovementRecord(id:'1',date:DateTime(2026),toLocation:'B',reason:MovementReason.relocation));
  @override
  Future<List<CommercialRecord>> getCommercialRecords(String _) => read(CommercialRecord(id:'1',date:DateTime(2026),type:CommercialRecordType.purchase,amount:100));
  @override
  Future<List<CostRecord>> getCostRecords(String _) => read(CostRecord(id:'1',date:DateTime(2026),type:CostType.feeding,amount:50));
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
class _Animals implements AnimalRepository {
  @override
  Future<AnimalEntity?> getByUuid(String uuid) async => buildAnimal(uuid:uuid);
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  final pages = <String,Widget>{
    'peso': const AnimalWeightFormPage(animalUuid:'a',recordId:'1'),
    'producción': const AnimalProductionFormPage(animalUuid:'a',recordId:'1'),
    'movimiento': const AnimalMovementFormPage(animalUuid:'a',recordId:'1'),
    'comercial': const AnimalCommercialFormPage(animalUuid:'a',recordId:'1'),
    'costo': const AnimalCostFormPage(animalUuid:'a',recordId:'1'),
  };
  setUp(() {
    final records=_Records();
    locator..registerSingleton<WeightRecordRepository>(records)
      ..registerSingleton<ProductionRecordRepository>(records)
      ..registerSingleton<MovementRecordRepository>(records)
      ..registerSingleton<CommercialRecordRepository>(records)
      ..registerSingleton<CostRecordRepository>(records)
      ..registerSingleton<AnimalRepository>(_Animals());
  });
  tearDown(locator.reset);
  for(final entry in pages.entries) {
    testWidgets('${entry.key}: load failure is visible and retry restores editing', (tester) async {
      await tester.pumpWidget(MaterialApp(localizationsDelegates:AppLocalizations.localizationsDelegates,
        supportedLocales:AppLocalizations.supportedLocales,locale:const Locale('es'),home:entry.value));
      await tester.pumpAndSettle();
      expect(find.byType(RecordLoadFailure),findsOneWidget);
      await tester.tap(find.text('Reintentar'));
      await tester.pumpAndSettle();
      expect(find.byType(RecordLoadFailure),findsNothing);
      expect(find.byType(TextFormField),findsWidgets);
      expect(tester.takeException(),isNull);
    });
  }
}
