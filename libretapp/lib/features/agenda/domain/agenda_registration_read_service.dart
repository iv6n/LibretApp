library;

import 'package:intl/intl.dart';
import 'package:libretapp/features/agenda/domain/agenda_registration.dart';
import 'package:libretapp/features/directorio/animales/domain/entities/health_record.dart';
import 'package:libretapp/features/directorio/animales/domain/entities/movement_record.dart';
import 'package:libretapp/features/directorio/animales/domain/entities/reproduction_record.dart';
import 'package:libretapp/features/directorio/animales/domain/entities/weight_record.dart';
import 'package:libretapp/features/directorio/animales/domain/repositories/health_record_repository.dart';
import 'package:libretapp/features/directorio/animales/domain/repositories/movement_record_repository.dart';
import 'package:libretapp/features/directorio/animales/domain/repositories/reproduction_record_repository.dart';
import 'package:libretapp/features/directorio/animales/domain/repositories/weight_record_repository.dart';

class AgendaRegistrationReadService {
  const AgendaRegistrationReadService({
    required HealthRecordRepository healthRepository,
    required WeightRecordRepository weightRepository,
    required MovementRecordRepository movementRepository,
    required ReproductionRecordRepository reproductionRepository,
  }) : _healthRepository = healthRepository,
       _weightRepository = weightRepository,
       _movementRepository = movementRepository,
       _reproductionRepository = reproductionRepository;

  final HealthRecordRepository _healthRepository;
  final WeightRecordRepository _weightRepository;
  final MovementRecordRepository _movementRepository;
  final ReproductionRecordRepository _reproductionRepository;

  Future<List<AgendaRegistrationDetail>> resolve(
    List<AgendaRegistration> registrations,
  ) async {
    if (registrations.isEmpty) return const [];

    Set<String> idsFor(AgendaRegistrationKind kind) => registrations
        .where((registration) => registration.kind == kind)
        .map((registration) => registration.recordUuid)
        .whereType<String>()
        .where((id) => id.isNotEmpty)
        .toSet();

    final health = await _healthByUuids(idsFor(AgendaRegistrationKind.health));
    final weights = await _weightByUuids(idsFor(AgendaRegistrationKind.weight));
    final movements = await _movementByUuids(
      idsFor(AgendaRegistrationKind.movement),
    );
    final reproduction = await _reproductionByUuids(
      idsFor(AgendaRegistrationKind.reproduction),
    );

    return registrations
        .map(
          (registration) => _detailFor(
            registration,
            health: health,
            weights: weights,
            movements: movements,
            reproduction: reproduction,
          ),
        )
        .toList(growable: false);
  }

  Future<Object?> loadRecord(AgendaRegistration registration) async {
    final recordUuid = registration.recordUuid;
    if (recordUuid == null || recordUuid.isEmpty) return null;
    return switch (registration.kind) {
      AgendaRegistrationKind.health => (await _healthByUuids({
        recordUuid,
      }))[recordUuid],
      AgendaRegistrationKind.weight => (await _weightByUuids({
        recordUuid,
      }))[recordUuid],
      AgendaRegistrationKind.movement => (await _movementByUuids({
        recordUuid,
      }))[recordUuid],
      AgendaRegistrationKind.reproduction => (await _reproductionByUuids({
        recordUuid,
      }))[recordUuid],
      AgendaRegistrationKind.general => null,
    };
  }

  AgendaRegistrationDetail _detailFor(
    AgendaRegistration registration, {
    required Map<String, HealthRecord> health,
    required Map<String, WeightRecord> weights,
    required Map<String, MovementRecord> movements,
    required Map<String, ReproductionRecord> reproduction,
  }) {
    final recordUuid = registration.recordUuid;
    switch (registration.kind) {
      case AgendaRegistrationKind.health:
        final record = health[recordUuid];
        if (record == null) return _missing(registration);
        return AgendaRegistrationDetail(
          registration: registration,
          summary: [
            record.product,
            if (record.dose?.isNotEmpty == true) record.dose!,
          ].join(' · '),
          fields: {
            'Tipo': record.type.displayName,
            'Producto': record.product,
            if (record.dose?.isNotEmpty == true) 'Dosis': record.dose!,
            'Fecha': _date(record.date),
            if (record.appliedBy?.isNotEmpty == true)
              'Responsable': record.appliedBy!,
            if (record.nextDueDate != null)
              'Próxima fecha': _date(record.nextDueDate!),
            if (record.notes?.isNotEmpty == true) 'Notas': record.notes!,
          },
        );
      case AgendaRegistrationKind.weight:
        final record = weights[recordUuid];
        if (record == null) return _missing(registration);
        final method = record.method == WeightMethod.scale
            ? 'Báscula'
            : 'Estimado';
        return AgendaRegistrationDetail(
          registration: registration,
          summary: '${_number(record.weight)} kg · $method',
          fields: {
            'Peso': '${_number(record.weight)} kg',
            'Método': method,
            'Fecha': _date(record.date),
            if (record.measuredBy?.isNotEmpty == true)
              'Responsable': record.measuredBy!,
            if (record.notes?.isNotEmpty == true) 'Notas': record.notes!,
          },
        );
      case AgendaRegistrationKind.movement:
        final record = movements[recordUuid];
        if (record == null) return _missing(registration);
        return AgendaRegistrationDetail(
          registration: registration,
          summary: [
            if (record.fromLocation?.isNotEmpty == true) record.fromLocation!,
            record.toLocation,
          ].join(' → '),
          fields: {
            if (record.fromLocation?.isNotEmpty == true)
              'Origen': record.fromLocation!,
            'Destino': record.toLocation,
            'Motivo': record.reason.displayName,
            'Fecha': _date(record.date),
            if (record.movedBy?.isNotEmpty == true)
              'Responsable': record.movedBy!,
            if (record.notes?.isNotEmpty == true) 'Notas': record.notes!,
          },
        );
      case AgendaRegistrationKind.reproduction:
        final record = reproduction[recordUuid];
        if (record == null) return _missing(registration);
        final event = _reproductionEvent(record);
        final result = _reproductionResult(record);
        return AgendaRegistrationDetail(
          registration: registration,
          summary: [event, if (result.isNotEmpty) result].join(' · '),
          fields: {
            'Evento': event,
            if (result.isNotEmpty) 'Resultado': result,
            'Fecha': _date(_reproductionDate(record)),
            if (record.maleSireIdentifier?.isNotEmpty == true)
              'Semental': record.maleSireIdentifier!,
            if (record.servicedBy?.isNotEmpty == true)
              'Responsable': record.servicedBy!,
            if (record.notes?.isNotEmpty == true) 'Notas': record.notes!,
          },
        );
      case AgendaRegistrationKind.general:
        final responsible = registration.data['responsible']?.trim() ?? '';
        final notes = registration.data['notes']?.trim() ?? '';
        final summary = [
          if (responsible.isNotEmpty) responsible,
          if (notes.isNotEmpty) notes,
        ].join(' · ');
        return AgendaRegistrationDetail(
          registration: registration,
          summary: summary.isEmpty ? 'Tarea registrada' : summary,
          fields: {
            'Fecha': _date(registration.performedAt),
            if (responsible.isNotEmpty) 'Responsable': responsible,
            if (notes.isNotEmpty) 'Notas': notes,
            if (registration.evidencePaths.isNotEmpty)
              'Evidencia': '${registration.evidencePaths.length} archivo(s)',
          },
        );
    }
  }

  AgendaRegistrationDetail _missing(AgendaRegistration registration) =>
      AgendaRegistrationDetail(
        registration: registration,
        summary: 'Registro no disponible',
        fields: {'Estado': 'El registro vinculado no se encontró'},
        recordMissing: true,
      );

  Future<Map<String, HealthRecord>> _healthByUuids(Set<String> ids) async {
    final repository = _healthRepository;
    if (repository is HealthRecordUuidLookup) {
      return (repository as HealthRecordUuidLookup)
          .getHealthRecordsByRecordUuids(ids);
    }
    return const {};
  }

  Future<Map<String, WeightRecord>> _weightByUuids(Set<String> ids) async {
    final repository = _weightRepository;
    if (repository is WeightRecordUuidLookup) {
      return (repository as WeightRecordUuidLookup)
          .getWeightRecordsByRecordUuids(ids);
    }
    return const {};
  }

  Future<Map<String, MovementRecord>> _movementByUuids(Set<String> ids) async {
    final repository = _movementRepository;
    if (repository is MovementRecordUuidLookup) {
      return (repository as MovementRecordUuidLookup)
          .getMovementRecordsByRecordUuids(ids);
    }
    return const {};
  }

  Future<Map<String, ReproductionRecord>> _reproductionByUuids(
    Set<String> ids,
  ) async {
    final repository = _reproductionRepository;
    if (repository is ReproductionRecordUuidLookup) {
      return (repository as ReproductionRecordUuidLookup)
          .getReproductionRecordsByRecordUuids(ids);
    }
    return const {};
  }

  String _date(DateTime value) => DateFormat('dd/MM/yyyy').format(value);

  String _number(double value) => value == value.roundToDouble()
      ? value.toStringAsFixed(0)
      : value.toStringAsFixed(1);

  String _reproductionEvent(ReproductionRecord record) {
    if (record.actualCalvingDate != null) return 'Parto';
    if (record.pregnancyCheckDate != null) return 'Chequeo reproductivo';
    return record.serviceType == ServiceType.artificialInsemination
        ? 'Inseminación'
        : 'Servicio';
  }

  String _reproductionResult(ReproductionRecord record) {
    final outcome = record.calvingOutcome;
    if (outcome != null) return outcome.displayName;
    return switch (record.pregnancyResult) {
      PregnancyCheckResult.positive => 'Positivo',
      PregnancyCheckResult.negative => 'Negativo',
      PregnancyCheckResult.uncertain => 'Incierto',
      PregnancyCheckResult.notChecked || null => '',
    };
  }

  DateTime _reproductionDate(ReproductionRecord record) =>
      record.actualCalvingDate ??
      record.pregnancyCheckDate ??
      record.eventDate;
}
