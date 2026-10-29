/// features › directorio › animales › infrastructure › animales_export_sheet
/// — writes the "Animales" sheet for [ExportService].
library;

import 'package:excel/excel.dart';
import 'package:intl/intl.dart';
import 'package:libretapp/core/services/exportable_sheet.dart';
import 'package:libretapp/features/directorio/animales/infrastructure/animal_repository.dart';
import 'package:libretapp/features/directorio/animales/domain/enums/sex.dart';

class AnimalesExportSheet implements ExportableSheet {
  AnimalesExportSheet(this._animalRepository);

  final AnimalRepository _animalRepository;

  @override
  String get key => 'animals';

  @override
  String get title => 'Animales';

  @override
  String get description => 'UUID, caravana, especie, edad, peso y estado.';

  @override
  Future<void> writeTo(Excel excel) async {
    final sheet = excel['Animales'];
    writeExcelRow(sheet, 0, [
      'UUID Animal',
      'N° Caravana',
      'Nombre',
      'Especie',
      'Categoría',
      'Sexo',
      'Raza',
      'Fecha Nac.',
      'Precisión nacimiento',
      'Edad (meses)',
      'Peso (kg)',
      'Estado',
      'Estado Salud',
      'Propietario',
    ], header: true);

    final animals = await _animalRepository.getAllIncludingInactive();
    for (var i = 0; i < animals.length; i++) {
      final a = animals[i];
      writeExcelRow(sheet, i + 1, [
        a.uuid,
        a.earTagNumber,
        a.customName ?? '',
        a.species.name,
        a.category.name,
        a.sex == Sex.unknown ? '' : a.sex.name,
        a.breed,
        a.hasKnownAge ? DateFormat('dd/MM/yyyy').format(a.birthDate) : '',
        a.birthDatePrecision.name,
        a.hasKnownAge ? a.ageMonths : '',
        a.weight ?? '',
        a.status.name,
        a.healthStatus.name,
        a.owner ?? '',
      ]);
    }
  }
}
