/// core › services › export_service — exports app data to an Excel (.xlsx) file.
library;

import 'dart:io';

import 'package:excel/excel.dart';
import 'package:intl/intl.dart';
import 'package:libretapp/features/directorio/animales/infrastructure/animal_repository.dart';
import 'package:libretapp/features/agenda/data/agenda_repository.dart';
import 'package:libretapp/features/agenda/data/workforce_repository.dart';
import 'package:libretapp/features/ubicaciones/domain/repositories/location_repository.dart';
import 'package:path_provider/path_provider.dart';

class ExportService {
  ExportService({
    required AnimalRepository animalRepository,
    required LocationRepository locationRepository,
    required AgendaRepository eventosRepository,
    required WorkforceRepository workforceRepository,
  }) : _animalRepository = animalRepository,
       _locationRepository = locationRepository,
       _eventosRepository = eventosRepository,
       _workforceRepository = workforceRepository;

  final AnimalRepository _animalRepository;
  final LocationRepository _locationRepository;
  final AgendaRepository _eventosRepository;
  final WorkforceRepository _workforceRepository;

  /// Generates a .xlsx file with the selected sheets and returns its [File].
  Future<File> exportToExcel({
    bool animals = true,
    bool ubicaciones = true,
    bool eventos = true,
  }) async {
    final excel = Excel.createExcel();
    // Remove the default empty sheet that excel package adds.
    excel.delete('Sheet1');

    if (animals) {
      await _writeAnimals(excel);
    }
    if (ubicaciones) {
      await _writeUbicaciones(excel);
    }
    if (eventos) {
      await _writeEventos(excel);
    }

    final bytes = excel.save();
    if (bytes == null) {
      throw StateError('No se pudo generar el archivo Excel.');
    }

    final dir = await getTemporaryDirectory();
    final dateStr = DateFormat('yyyy-MM-dd').format(DateTime.now());
    final file = File('${dir.path}/libretapp_export_$dateStr.xlsx');
    await file.writeAsBytes(bytes, flush: true);
    return file;
  }

  // ---------------------------------------------------------------------------
  // Private helpers
  // ---------------------------------------------------------------------------

  Future<void> _writeAnimals(Excel excel) async {
    final sheet = excel['Animales'];
    _writeRow(sheet, 0, [
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
    ], header: true);

    final animals = await _animalRepository.getAll();
    for (var i = 0; i < animals.length; i++) {
      final a = animals[i];
      _writeRow(sheet, i + 1, [
        a.earTagNumber,
        a.customName ?? '',
        a.species.name,
        a.category.name,
        a.sex.name,
        a.breed,
        DateFormat('dd/MM/yyyy').format(a.birthDate),
        a.ageMonths,
        a.weight ?? '',
        a.status.name,
        a.healthStatus.name,
        a.owner ?? '',
      ]);
    }
  }

  Future<void> _writeUbicaciones(Excel excel) async {
    final sheet = excel['Ubicaciones'];
    _writeRow(sheet, 0, [
      'Nombre',
      'Tipo',
      'Superficie (m²)',
      'Capacidad',
      'Estado',
      'Fuente de Agua',
      'Tipo Terreno',
    ], header: true);

    final locations = await _locationRepository.getAll();
    for (var i = 0; i < locations.length; i++) {
      final l = locations[i];
      _writeRow(sheet, i + 1, [
        l.name,
        l.type.name,
        l.surfaceArea,
        l.capacity,
        l.status,
        l.waterSource,
        l.terrainType,
      ]);
    }
  }

  Future<void> _writeEventos(Excel excel) async {
    final sheet = excel['Eventos'];
    _writeRow(sheet, 0, [
      'Título',
      'Descripción',
      'Fecha',
      'Tipo',
      'ID Animal',
      'Ubicación',
      'Estado',
      'Prioridad',
      'Progreso',
      'Responsable',
      'Equipo',
      'Colaboradores',
      'Checklist',
      'Recurrencia',
      'Actualizada',
    ], header: true);

    final eventList = await _eventosRepository.fetchEntries();
    final workers = await _workforceRepository.fetchWorkers(
      includeInactive: true,
    );
    final teams = await _workforceRepository.fetchTeams(includeInactive: true);
    final workerNames = {for (final worker in workers) worker.id: worker.name};
    final teamNames = {for (final team in teams) team.id: team.name};
    for (var i = 0; i < eventList.length; i++) {
      final e = eventList[i];
      _writeRow(sheet, i + 1, [
        e.titulo,
        e.descripcion,
        DateFormat('dd/MM/yyyy HH:mm').format(e.fecha),
        e.tipo,
        e.animalIds.join(', '),
        e.ubicacion,
        e.estado,
        e.prioridad,
        '${e.completedAnimalIds.length}/${e.animalIds.length}',
        workerNames[e.assigneeId] ?? '',
        teamNames[e.workTeamId] ?? '',
        e.collaboratorIds
            .map((id) => workerNames[id] ?? id)
            .join(', '),
        '${e.checklist.where((item) => item.completed).length}/${e.checklist.length}',
        e.recurrenceRule ?? '',
        e.updatedAt == null
            ? ''
            : DateFormat('dd/MM/yyyy HH:mm').format(e.updatedAt!),
      ]);
    }
  }

  void _writeRow(
    Sheet sheet,
    int rowIndex,
    List<Object?> values, {
    bool header = false,
  }) {
    for (var col = 0; col < values.length; col++) {
      final cell = sheet.cell(
        CellIndex.indexByColumnRow(columnIndex: col, rowIndex: rowIndex),
      );
      final value = values[col];
      if (value is int) {
        cell.value = IntCellValue(value);
      } else if (value is double) {
        cell.value = DoubleCellValue(value);
      } else {
        cell.value = TextCellValue(value?.toString() ?? '');
      }
      if (header) {
        cell.cellStyle = CellStyle(bold: true);
      }
    }
  }
}
