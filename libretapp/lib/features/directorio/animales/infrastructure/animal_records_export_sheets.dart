/// Excel sheets for the seven animal-record collections.
library;

import 'package:excel/excel.dart';
import 'package:intl/intl.dart';
import 'package:libretapp/core/services/exportable_sheet.dart';
import 'package:libretapp/features/directorio/animales/domain/animal_domain.dart';
import 'package:libretapp/features/directorio/animales/domain/repositories/animal_record_bulk_reader.dart';
import 'package:libretapp/features/directorio/animales/infrastructure/animal_repository.dart';

List<ExportableSheet> buildAnimalRecordExportSheets({
  required AnimalRepository animalRepository,
  required AnimalRecordBulkReader<WeightRecord> weights,
  required AnimalRecordBulkReader<HealthRecord> health,
  required AnimalRecordBulkReader<ReproductionRecord> reproduction,
  required AnimalRecordBulkReader<MovementRecord> movements,
  required AnimalRecordBulkReader<CostRecord> costs,
  required AnimalRecordBulkReader<CommercialRecord> commercial,
  required AnimalRecordBulkReader<ProductionRecord> production,
}) => [
  _AnimalRecordExportSheet<WeightRecord>(
    key: 'weights',
    title: 'Pesos',
    description: 'Pesajes, método, responsable y notas.',
    sheetName: 'Pesos',
    animalRepository: animalRepository,
    reader: weights,
    headers: const [
      'Fecha',
      'Peso (kg)',
      'Método',
      'Medido por',
      'Notas',
      'Actualizado',
    ],
    recordId: (record) => record.id,
    values: (record) => [
      _date(record.date),
      record.weight,
      record.method.name,
      record.measuredBy,
      record.notes,
      _date(record.updatedAt),
    ],
  ),
  _AnimalRecordExportSheet<HealthRecord>(
    key: 'health',
    title: 'Salud',
    description: 'Tratamientos, productos, retiros y próximas fechas.',
    sheetName: 'Salud',
    animalRepository: animalRepository,
    reader: health,
    headers: const [
      'Fecha',
      'Tipo',
      'Producto',
      'Dosis',
      'Aplicado por',
      'Próxima fecha',
      'Causa',
      'Lote medicamento',
      'Días retiro',
      'Fin retiro',
      'Notas',
      'Actualizado',
    ],
    recordId: (record) => record.id,
    values: (record) => [
      _date(record.date),
      record.type.name,
      record.product,
      record.dose,
      record.appliedBy,
      _date(record.nextDueDate),
      record.cause,
      record.medicineBatch,
      record.withdrawalDays,
      _date(record.withdrawalEndDate),
      record.notes,
      _date(record.updatedAt),
    ],
  ),
  _AnimalRecordExportSheet<ReproductionRecord>(
    key: 'reproduction',
    title: 'Reproducción',
    description: 'Servicios, diagnósticos, partos y crías.',
    sheetName: 'Reproducción',
    animalRepository: animalRepository,
    reader: reproduction,
    headers: const [
      'Fecha servicio',
      'Tipo servicio',
      'UUID semental',
      'Identificador semental',
      'Fecha diagnóstico',
      'Resultado diagnóstico',
      'Parto esperado',
      'Parto real',
      'Resultado parto',
      'Dificultad parto',
      'UUID crías',
      'Notas parto',
      'Notas',
      'Realizado por',
      'Actualizado',
    ],
    recordId: (record) => record.id,
    values: (record) => [
      _date(record.serviceDate),
      record.serviceType.name,
      record.maleSireUuid,
      record.maleSireIdentifier,
      _date(record.pregnancyCheckDate),
      record.pregnancyResult?.name,
      _date(record.expectedCalvingDate),
      _date(record.actualCalvingDate),
      record.calvingOutcome?.name,
      record.calvingEase,
      record.offspringUuids.join(', '),
      record.calvingNotes,
      record.notes,
      record.servicedBy,
      _date(record.updatedAt),
    ],
  ),
  _AnimalRecordExportSheet<MovementRecord>(
    key: 'movements',
    title: 'Movimientos',
    description: 'Origen, destino, motivo y responsable.',
    sheetName: 'Movimientos',
    animalRepository: animalRepository,
    reader: movements,
    headers: const [
      'Fecha',
      'Origen',
      'Destino',
      'Motivo',
      'Movido por',
      'Notas',
      'Actualizado',
    ],
    recordId: (record) => record.id,
    values: (record) => [
      _date(record.date),
      record.fromLocation,
      record.toLocation,
      record.reason.name,
      record.movedBy,
      record.notes,
      _date(record.updatedAt),
    ],
  ),
  _AnimalRecordExportSheet<CostRecord>(
    key: 'costs',
    title: 'Costos',
    description: 'Costos por animal, categoría, monto y moneda.',
    sheetName: 'Costos',
    animalRepository: animalRepository,
    reader: costs,
    headers: const ['Fecha', 'Tipo', 'Monto', 'Moneda', 'Notas'],
    recordId: (record) => record.id,
    values: (record) => [
      _date(record.date),
      record.type.name,
      record.amount,
      record.currency,
      record.notes,
    ],
  ),
  _AnimalRecordExportSheet<CommercialRecord>(
    key: 'commercial',
    title: 'Comercial',
    description: 'Compras, ventas, contraparte, monto y moneda.',
    sheetName: 'Comercial',
    animalRepository: animalRepository,
    reader: commercial,
    headers: const ['Fecha', 'Tipo', 'Monto', 'Moneda', 'Contraparte', 'Notas'],
    recordId: (record) => record.id,
    values: (record) => [
      _date(record.date),
      record.type.name,
      record.amount,
      record.currency,
      record.counterparty,
      record.notes,
    ],
  ),
  _AnimalRecordExportSheet<ProductionRecord>(
    key: 'production',
    title: 'Producción',
    description: 'Mediciones productivas, valores, unidades y puntajes.',
    sheetName: 'Producción',
    animalRepository: animalRepository,
    reader: production,
    headers: const ['Fecha', 'Tipo', 'Valor', 'Unidad', 'Puntaje', 'Notas'],
    recordId: (record) => record.id,
    values: (record) => [
      _date(record.date),
      record.type.name,
      record.value,
      record.unit,
      record.score,
      record.notes,
    ],
  ),
];

class _AnimalRecordExportSheet<T> implements ExportableSheet {
  const _AnimalRecordExportSheet({
    required this.key,
    required this.title,
    required this.description,
    required this.sheetName,
    required AnimalRepository animalRepository,
    required AnimalRecordBulkReader<T> reader,
    required this.headers,
    required this.recordId,
    required this.values,
  }) : _animalRepository = animalRepository,
       _reader = reader;

  @override
  final String key;
  @override
  final String title;
  @override
  final String description;
  final String sheetName;
  final AnimalRepository _animalRepository;
  final AnimalRecordBulkReader<T> _reader;
  final List<String> headers;
  final String? Function(T record) recordId;
  final List<Object?> Function(T record) values;

  @override
  Future<void> writeTo(Excel excel) async {
    final records = await _reader.getAllAnimalRecords();
    final animals = await _animalRepository.getAllIncludingInactive();
    final tags = {
      for (final animal in animals) animal.uuid: animal.earTagNumber,
    };
    final sheet = excel[sheetName];
    writeExcelRow(sheet, 0, [
      'UUID Animal',
      'Caravana',
      'ID Registro',
      'UUID Registro',
      ...headers,
    ], header: true);
    for (var index = 0; index < records.length; index++) {
      final item = records[index];
      writeExcelRow(sheet, index + 1, [
        item.animalUuid,
        tags[item.animalUuid] ?? '',
        recordId(item.record),
        item.recordUuid,
        ...values(item.record),
      ]);
    }
  }
}

String _date(DateTime? value) =>
    value == null ? '' : DateFormat('yyyy-MM-dd HH:mm').format(value.toLocal());
