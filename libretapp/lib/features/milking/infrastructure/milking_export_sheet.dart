/// Writes milking sessions and entries to the "Ordeñas" Excel sheet.
library;

import 'package:excel/excel.dart';
import 'package:intl/intl.dart';
import 'package:libretapp/core/services/exportable_sheet.dart';
import 'package:libretapp/features/directorio/animales/infrastructure/animal_repository.dart';
import 'package:libretapp/features/milking/domain/milking_models.dart';
import 'package:libretapp/features/milking/domain/milking_repository.dart';

class MilkingExportSheet implements ExportableSheet {
  const MilkingExportSheet({
    required MilkingRepository milkingRepository,
    required AnimalRepository animalRepository,
  }) : _milkingRepository = milkingRepository,
       _animalRepository = animalRepository;

  final MilkingRepository _milkingRepository;
  final AnimalRepository _animalRepository;

  @override
  String get key => 'milking';

  @override
  String get title => 'Ordeñas';

  @override
  String get description => 'Sesiones, animales, turnos y litros ordeñados.';

  @override
  Future<void> writeTo(Excel excel) async {
    final sessions = await _milkingRepository.getAllSessions();
    final entries = await _milkingRepository.getAllEntries();
    final animals = await _animalRepository.getAllIncludingInactive();
    final tags = {
      for (final animal in animals) animal.uuid: animal.earTagNumber,
    };
    final sessionsById = {
      for (final session in sessions) session.uuid: session,
    };
    final referencedSessions = entries
        .map((entry) => entry.sessionUuid)
        .toSet();
    final rows = <_MilkingRow>[
      for (final entry in entries)
        _MilkingRow(session: sessionsById[entry.sessionUuid], entry: entry),
      for (final session in sessions)
        if (!referencedSessions.contains(session.uuid))
          _MilkingRow(session: session, entry: null),
    ]..sort((a, b) => b.date.compareTo(a.date));

    final sheet = excel['Ordeñas'];
    writeExcelRow(sheet, 0, [
      'UUID Animal',
      'Caravana',
      'UUID Entrada',
      'UUID Sesión',
      'Fecha',
      'Turno',
      'Estado',
      'UUID Lote origen',
      'Litros',
      'Notas entrada',
      'Notas sesión',
      'Creada entrada',
      'Actualizada entrada',
      'Creada sesión',
      'Actualizada sesión',
    ], header: true);
    for (var index = 0; index < rows.length; index++) {
      final row = rows[index];
      final entry = row.entry;
      final session = row.session;
      writeExcelRow(sheet, index + 1, [
        entry?.animalUuid,
        entry == null ? '' : tags[entry.animalUuid] ?? '',
        entry?.uuid,
        entry?.sessionUuid ?? session?.uuid,
        _date(session?.occurredAt),
        session?.shift.name,
        session?.status.name,
        session?.sourceLoteUuid,
        entry?.liters,
        entry?.notes,
        session?.notes,
        _date(entry?.createdAt),
        _date(entry?.updatedAt),
        _date(session?.createdAt),
        _date(session?.updatedAt),
      ]);
    }
  }
}

class _MilkingRow {
  const _MilkingRow({required this.session, required this.entry});

  final MilkingSession? session;
  final MilkingEntry? entry;
  DateTime get date =>
      session?.occurredAt ??
      entry?.createdAt ??
      DateTime.fromMillisecondsSinceEpoch(0);
}

String _date(DateTime? value) =>
    value == null ? '' : DateFormat('yyyy-MM-dd HH:mm').format(value.toLocal());
