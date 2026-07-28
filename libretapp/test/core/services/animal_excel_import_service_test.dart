import 'package:excel/excel.dart' as xlsx;
import 'package:flutter_test/flutter_test.dart';
import 'package:libretapp/core/services/animal_excel_import_service.dart';
import 'package:libretapp/features/directorio/animales/domain/animal_domain.dart';
import 'package:libretapp/features/directorio/animales/domain/enums/production_stage.dart';
import 'package:libretapp/features/directorio/animales/domain/enums/production_system.dart';
import 'package:libretapp/features/directorio/animales/infrastructure/animal_repository.dart';

class _FakeAnimalRepository implements AnimalRepository {
  _FakeAnimalRepository([List<AnimalEntity> seed = const []])
    : _animals = List<AnimalEntity>.from(seed);

  final List<AnimalEntity> _animals;

  @override
  Future<List<AnimalEntity>> getAll() async => List.of(_animals);

  @override
  Future<AnimalEntity> save(AnimalEntity animal) async {
    _animals.add(animal);
    return animal;
  }

  @override
  Future<AnimalEntity> update(AnimalEntity animal) async {
    final index = _animals.indexWhere((a) => a.uuid == animal.uuid);
    if (index != -1) {
      _animals[index] = animal;
    } else {
      _animals.add(animal);
    }
    return animal;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

/// Builds Animales-sheet xlsx bytes with the exact column order
/// ExportService writes: caravana, nombre, especie, categoría, sexo, raza,
/// fecha nac., edad, peso, estado, estado salud, propietario.
List<int> _buildAnimalesXlsx(List<List<Object?>> rows, {String sheetName = 'Animales'}) {
  final workbook = xlsx.Excel.createExcel();
  workbook.delete('Sheet1');
  final sheet = workbook[sheetName];
  const headers = [
    'N° Caravana',
    'Nombre',
    'Especie',
    'Categoría',
    'Sexo',
    'Raza',
    'Fecha Nac.',
    'Edad (meses)',
    'Peso (kg)',
    'Estado',
    'Estado Salud',
    'Propietario',
  ];
  for (var col = 0; col < headers.length; col++) {
    sheet
        .cell(xlsx.CellIndex.indexByColumnRow(columnIndex: col, rowIndex: 0))
        .value = xlsx.TextCellValue(headers[col]);
  }
  for (var r = 0; r < rows.length; r++) {
    final row = rows[r];
    for (var col = 0; col < row.length; col++) {
      final value = row[col];
      final cell = sheet.cell(
        xlsx.CellIndex.indexByColumnRow(columnIndex: col, rowIndex: r + 1),
      );
      cell.value = xlsx.TextCellValue(value?.toString() ?? '');
    }
  }
  final bytes = workbook.save();
  if (bytes == null) throw StateError('failed to build test xlsx');
  return bytes;
}

AnimalEntity _buildAnimal({
  required String uuid,
  required String earTagNumber,
  String? customName,
  Species species = Species.cattle,
  Category category = Category.cow,
  Sex sex = Sex.female,
  String breed = 'Criollo',
  DateTime? birthDate,
  int ageMonths = 48,
  double? weight,
  AnimalStatus status = AnimalStatus.active,
  HealthStatus healthStatus = HealthStatus.good,
  String? owner,
  String? currentLocationId,
}) {
  final now = DateTime(2026, 1, 1);
  return AnimalEntity(
    uuid: uuid,
    earTagNumber: earTagNumber,
    customName: customName,
    species: species,
    category: category,
    lifeStage: LifeStage.cow,
    sex: sex,
    breed: breed,
    birthDate: birthDate ?? DateTime(2022, 4, 1),
    ageMonths: ageMonths,
    weight: weight,
    healthStatus: healthStatus,
    vaccinated: true,
    dewormed: true,
    hasVitamins: false,
    hasChronicIssues: false,
    reproductiveStatus: ReproductiveStatus.active,
    productionPurpose: ProductionPurpose.dairy,
    productionStage: ProductionStage.lactating,
    productionSystem: ProductionSystem.intensive,
    currentLocationId: currentLocationId,
    underObservation: false,
    requiresAttention: false,
    riskLevel: RiskLevel.low,
    gallery: const [],
    owner: owner,
    status: status,
    synced: true,
    creationDate: now,
    lastUpdateDate: now,
  );
}

void main() {
  group('AnimalExcelImportService', () {
    test('creates a new animal for a row with no matching ear tag', () async {
      final repository = _FakeAnimalRepository();
      final service = AnimalExcelImportService(animalRepository: repository);

      final bytes = _buildAnimalesXlsx([
        [
          '002659025593',
          'Gorda',
          'cattle',
          'cow',
          'female',
          'Criollo',
          '01/04/2022',
          48,
          '',
          'active',
          'good',
          '',
        ],
      ]);

      final summary = await service.importFromBytes(bytes);

      expect(summary.created, 1);
      expect(summary.updated, 0);
      expect(summary.warnings, isEmpty);

      final saved = (await repository.getAll()).single;
      expect(saved.earTagNumber, '002659025593');
      expect(saved.customName, 'Gorda');
      expect(saved.species, Species.cattle);
      expect(saved.category, Category.cow);
      expect(saved.sex, Sex.female);
      expect(saved.breed, 'Criollo');
      expect(saved.birthDate, DateTime(2022, 4, 1));
      expect(saved.ageMonths, 48);
      expect(saved.weight, isNull);
      expect(saved.status, AnimalStatus.active);
      expect(saved.healthStatus, HealthStatus.good);
      expect(saved.owner, isNull);
    });

    test('updates an existing animal matched by ear tag, preserving untouched fields', () async {
      final existing = _buildAnimal(
        uuid: 'ani-existing-1',
        earTagNumber: '002659025593',
        customName: 'Old Name',
        weight: 300,
        currentLocationId: 'loc-1',
      );
      final repository = _FakeAnimalRepository([existing]);
      final service = AnimalExcelImportService(animalRepository: repository);

      final bytes = _buildAnimalesXlsx([
        [
          '002659025593',
          'Gorda',
          'cattle',
          'cow',
          'female',
          'Criollo',
          '01/04/2022',
          50,
          '320.5',
          'active',
          'poor',
          'Juan Perez',
        ],
      ]);

      final summary = await service.importFromBytes(bytes);

      expect(summary.created, 0);
      expect(summary.updated, 1);

      final saved = (await repository.getAll()).single;
      expect(saved.uuid, 'ani-existing-1', reason: 'must update in place, not duplicate');
      expect(saved.customName, 'Gorda');
      expect(saved.ageMonths, 50);
      expect(saved.weight, 320.5);
      expect(saved.healthStatus, HealthStatus.poor);
      expect(saved.owner, 'Juan Perez');
      expect(
        saved.currentLocationId,
        'loc-1',
        reason: 'location is not one of the Excel columns, must survive the merge',
      );
    });

    test('skips a row with no ear tag and reports a warning', () async {
      final repository = _FakeAnimalRepository();
      final service = AnimalExcelImportService(animalRepository: repository);

      final bytes = _buildAnimalesXlsx([
        ['', 'Sin caravana', 'cattle', 'cow', 'female', 'Criollo', '01/04/2022', 48, '', 'active', 'good', ''],
        ['002659025593', 'Gorda', 'cattle', 'cow', 'female', 'Criollo', '01/04/2022', 48, '', 'active', 'good', ''],
      ]);

      final summary = await service.importFromBytes(bytes);

      expect(summary.created, 1);
      expect(summary.warnings, hasLength(1));
      expect(summary.warnings.single, contains('sin N° de caravana'));
    });

    test('falls back to a default and warns on an unrecognized enum value', () async {
      final repository = _FakeAnimalRepository();
      final service = AnimalExcelImportService(animalRepository: repository);

      final bytes = _buildAnimalesXlsx([
        [
          '002659025593',
          'Gorda',
          'unicornio',
          'cow',
          'female',
          'Criollo',
          '01/04/2022',
          48,
          '',
          'active',
          'good',
          '',
        ],
      ]);

      final summary = await service.importFromBytes(bytes);

      expect(summary.warnings, hasLength(1));
      expect(summary.warnings.single, contains('especie'));
      final saved = (await repository.getAll()).single;
      expect(saved.species, Species.cattle, reason: 'unrecognized value falls back to the default');
    });

    test('warns and leaves the birth date unset when it cannot be parsed', () async {
      final repository = _FakeAnimalRepository();
      final service = AnimalExcelImportService(animalRepository: repository);

      final bytes = _buildAnimalesXlsx([
        [
          '002659025593',
          'Gorda',
          'cattle',
          'cow',
          'female',
          'Criollo',
          'no es una fecha',
          48,
          '',
          'active',
          'good',
          '',
        ],
      ]);

      final summary = await service.importFromBytes(bytes);

      expect(summary.warnings, hasLength(1));
      expect(summary.warnings.single, contains('fecha de nacimiento'));
    });

    test('throws a FormatException when there is no Animales sheet', () async {
      final repository = _FakeAnimalRepository();
      final service = AnimalExcelImportService(animalRepository: repository);
      final workbook = xlsx.Excel.createExcel();
      final bytes = workbook.save()!;

      expect(
        () => service.importFromBytes(bytes),
        throwsA(isA<FormatException>()),
      );
    });
  });
}
