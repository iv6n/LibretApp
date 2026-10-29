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
  Future<List<AnimalEntity>> getAllIncludingInactive() async => _animals;

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
      _animal(
        uuid: 'a1',
        earTagNumber: '001',
        customName: 'Gorda',
        weight: 320.5,
        owner: 'Juan',
      ),
      _animal(uuid: 'a2', earTagNumber: '002'),
    ]);
    final sheet = AnimalesExportSheet(repository);
    final excel = Excel.createExcel();

    await sheet.writeTo(excel);

    final rows = excel['Animales'].rows;
    expect(rows, hasLength(3));
    expect(_text(_row(excel, 0)[0]), 'UUID Animal');
    expect(_text(_row(excel, 0)[1]), 'N° Caravana');

    expect(_text(_row(excel, 1)[0]), 'a1');
    expect(_text(_row(excel, 1)[1]), '001');
    expect(_text(_row(excel, 1)[2]), 'Gorda');
    expect(_text(_row(excel, 1)[3]), 'cattle');
    expect(_text(_row(excel, 0)[8]), 'Precisión nacimiento');
    expect(_text(_row(excel, 1)[8]), 'unknown');
    expect(_text(_row(excel, 1)[10]), '320.5');
    expect(_text(_row(excel, 1)[13]), 'Juan');

    expect(_text(_row(excel, 2)[1]), '002');
    expect(
      _text(_row(excel, 2)[2]),
      '',
      reason: 'no custom name should render as an empty cell, not "null"',
    );
    expect(
      _text(_row(excel, 2)[10]),
      '',
      reason: 'no weight should render as an empty cell, not "null"',
    );
  });

  test(
    'writes an empty sheet (header only) when there are no animals',
    () async {
      final sheet = AnimalesExportSheet(_FakeAnimalRepository(const []));
      final excel = Excel.createExcel();

      await sheet.writeTo(excel);

      expect(excel['Animales'].rows, hasLength(1));
    },
  );

  test('leaves unknown pet sex and age blank in the export', () async {
    final pet = _animal(uuid: 'cat-1', earTagNumber: '').copyWith(
      customName: 'Michi',
      species: Species.feline,
      category: Category.other,
      lifeStage: LifeStage.cat,
      sex: Sex.unknown,
      birthDate: DateTime(1970),
      birthDatePrecision: BirthDatePrecision.unknown,
      ageMonths: -1,
    );
    final excel = Excel.createExcel();

    await AnimalesExportSheet(_FakeAnimalRepository([pet])).writeTo(excel);

    final row = _row(excel, 1);
    expect(_text(row[3]), 'feline');
    expect(_text(row[5]), '');
    expect(_text(row[7]), '');
    expect(_text(row[9]), '');
  });
}
