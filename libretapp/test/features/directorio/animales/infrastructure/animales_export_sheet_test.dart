import 'package:excel/excel.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:libretapp/features/directorio/animales/domain/animal_domain.dart';
import 'package:libretapp/features/directorio/animales/domain/enums/production_stage.dart';
import 'package:libretapp/features/directorio/animales/domain/enums/production_system.dart';
import 'package:libretapp/features/directorio/animales/infrastructure/animal_repository.dart';
import 'package:libretapp/features/directorio/animales/infrastructure/animales_export_sheet.dart';

class _FakeAnimalRepository implements AnimalRepository {
  _FakeAnimalRepository(this._animals);
  final List<AnimalEntity> _animals;

  @override
  Future<List<AnimalEntity>> getAll() async => _animals;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

AnimalEntity _animal({
  required String uuid,
  required String earTagNumber,
  String? customName,
  double? weight,
  String? owner,
}) {
  final now = DateTime(2026, 1, 1);
  return AnimalEntity(
    uuid: uuid,
    earTagNumber: earTagNumber,
    customName: customName,
    species: Species.cattle,
    category: Category.cow,
    lifeStage: LifeStage.cow,
    sex: Sex.female,
    breed: 'Criollo',
    birthDate: DateTime(2022, 4, 1),
    ageMonths: 48,
    weight: weight,
    healthStatus: HealthStatus.good,
    vaccinated: true,
    dewormed: true,
    hasVitamins: false,
    hasChronicIssues: false,
    reproductiveStatus: ReproductiveStatus.active,
    productionPurpose: ProductionPurpose.dairy,
    productionStage: ProductionStage.lactating,
    productionSystem: ProductionSystem.intensive,
    underObservation: false,
    requiresAttention: false,
    riskLevel: RiskLevel.low,
    gallery: const [],
    owner: owner,
    status: AnimalStatus.active,
    synced: true,
    creationDate: now,
    lastUpdateDate: now,
  );
}

List<Data?> _row(Excel excel, int index) => excel['Animales'].rows[index];

String? _text(Data? cell) => cell?.value?.toString();

void main() {
  test('writes the header row and one row per animal', () async {
    final repository = _FakeAnimalRepository([
      _animal(uuid: 'a1', earTagNumber: '001', customName: 'Gorda', weight: 320.5, owner: 'Juan'),
      _animal(uuid: 'a2', earTagNumber: '002'),
    ]);
    final sheet = AnimalesExportSheet(repository);
    final excel = Excel.createExcel();

    await sheet.writeTo(excel);

    final rows = excel['Animales'].rows;
    expect(rows, hasLength(3));
    expect(_text(_row(excel, 0)[0]), 'N° Caravana');

    expect(_text(_row(excel, 1)[0]), '001');
    expect(_text(_row(excel, 1)[1]), 'Gorda');
    expect(_text(_row(excel, 1)[2]), 'cattle');
    expect(_text(_row(excel, 1)[8]), '320.5');
    expect(_text(_row(excel, 1)[11]), 'Juan');

    expect(_text(_row(excel, 2)[0]), '002');
    expect(
      _text(_row(excel, 2)[1]),
      '',
      reason: 'no custom name should render as an empty cell, not "null"',
    );
    expect(
      _text(_row(excel, 2)[8]),
      '',
      reason: 'no weight should render as an empty cell, not "null"',
    );
  });

  test('writes an empty sheet (header only) when there are no animals', () async {
    final sheet = AnimalesExportSheet(_FakeAnimalRepository(const []));
    final excel = Excel.createExcel();

    await sheet.writeTo(excel);

    expect(excel['Animales'].rows, hasLength(1));
  });
}
