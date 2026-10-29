/// features › directorio › animales › domain › entities › reproduction_record — entity for a reproduction event record.
library;

import 'package:equatable/equatable.dart';

const Object _unset = Object();

/// Tipos de servicio reproductor.
enum ServiceType { naturalService, artificialInsemination, ivf }

enum ReproductionRecordKind { service, calving }

/// Resultado de chequeo de preñez.
enum PregnancyCheckResult { positive, negative, uncertain, notChecked }

/// Desenlace de un parto.
///
/// Describe *qué pasó con la cría*, no qué tan difícil fue el parto: la
/// dificultad se registra aparte en [ReproductionRecord.calvingEase], porque
/// una cría puede nacer viva tras una distocia o una cesárea. Mantener ambos
/// ejes separados evita tener que elegir entre "nació vivo" y "fue cesárea".
enum CalvingOutcome {
  liveBirth,
  stillbirth,
  abortion,
  unknown;

  String get displayName {
    switch (this) {
      case CalvingOutcome.liveBirth:
        return 'Nacido vivo';
      case CalvingOutcome.stillbirth:
        return 'Nacido muerto';
      case CalvingOutcome.abortion:
        return 'Aborto';
      case CalvingOutcome.unknown:
        return 'Sin especificar';
    }
  }
}

/// Registro de evento reproductivo del animal.
///
/// Cubre el ciclo completo servicio → diagnóstico → parto. Las crías nacidas
/// se enlazan por [offspringUuids], lo que convierte al registro en el puente
/// entre la madre y su descendencia en el árbol genealógico.
class ReproductionRecord extends Equatable {
  const ReproductionRecord({
    this.serviceDate,
    this.serviceType,
    this.kind = ReproductionRecordKind.service,
    this.animalUuid,
    this.maleSireUuid,
    this.maleSireIdentifier,
    this.pregnancyCheckDate,
    this.pregnancyResult,
    this.expectedCalvingDate,
    this.actualCalvingDate,
    this.calvingOutcome,
    this.calvingEase,
    this.offspringUuids = const <String>[],
    this.calvingNotes,
    this.notes,
    this.servicedBy,
    this.recordUuid,
    this.updatedAt,
    this.id,
  });
  final DateTime? serviceDate;
  final ServiceType? serviceType;
  final ReproductionRecordKind kind;
  final String? animalUuid;
  DateTime get eventDate => actualCalvingDate ?? serviceDate!;
  final String? maleSireUuid;
  final String? maleSireIdentifier;
  final DateTime? pregnancyCheckDate;
  final PregnancyCheckResult? pregnancyResult;
  final DateTime? expectedCalvingDate;
  final DateTime? actualCalvingDate;
  final CalvingOutcome? calvingOutcome;

  /// Dificultad del parto en la escala estándar de 1 a 5:
  /// 1 sin asistencia · 2 asistencia leve · 3 asistencia mecánica ·
  /// 4 distocia severa · 5 cesárea.
  final int? calvingEase;

  /// UUIDs de las crías registradas para este parto. Es una lista porque
  /// caprinos y ovinos paren mellizos con normalidad.
  final List<String> offspringUuids;

  /// Texto libre sobre el parto. Antes de que existiera [calvingOutcome] este
  /// era el único campo del parto, así que puede contener notas heredadas.
  final String? calvingNotes;

  final String? notes;
  final String? servicedBy;
  final String? recordUuid;
  final DateTime? updatedAt;
  final String? id;

  /// Duración real de la gestación. Se deriva en lugar de almacenarse para
  /// que nunca contradiga a las fechas de las que depende.
  int? get gestationDays {
    final calving = actualCalvingDate;
    if (calving == null || serviceDate == null) return null;
    return calving.difference(serviceDate!).inDays;
  }

  /// Un parto ya ocurrió para este ciclo.
  bool get hasCalved => actualCalvingDate != null;

  /// El servicio derivó en una cría viva registrada o declarada.
  bool get producedLiveOffspring =>
      calvingOutcome == CalvingOutcome.liveBirth || offspringUuids.isNotEmpty;

  ReproductionRecord copyWith({
    ReproductionRecordKind? kind,
    String? animalUuid,
    Object? serviceDate = _unset,
    Object? serviceType = _unset,
    Object? maleSireUuid = _unset,
    Object? maleSireIdentifier = _unset,
    Object? pregnancyCheckDate = _unset,
    Object? pregnancyResult = _unset,
    Object? expectedCalvingDate = _unset,
    Object? actualCalvingDate = _unset,
    Object? calvingOutcome = _unset,
    Object? calvingEase = _unset,
    List<String>? offspringUuids,
    Object? calvingNotes = _unset,
    Object? notes = _unset,
    Object? servicedBy = _unset,
    String? recordUuid,
    DateTime? updatedAt,
    String? id,
  }) {
    return ReproductionRecord(
      kind: kind ?? this.kind,
      animalUuid: animalUuid ?? this.animalUuid,
      serviceDate: serviceDate == _unset
          ? this.serviceDate
          : serviceDate as DateTime?,
      serviceType: serviceType == _unset
          ? this.serviceType
          : serviceType as ServiceType?,
      maleSireUuid: maleSireUuid == _unset
          ? this.maleSireUuid
          : maleSireUuid as String?,
      maleSireIdentifier: maleSireIdentifier == _unset
          ? this.maleSireIdentifier
          : maleSireIdentifier as String?,
      pregnancyCheckDate: pregnancyCheckDate == _unset
          ? this.pregnancyCheckDate
          : pregnancyCheckDate as DateTime?,
      pregnancyResult: pregnancyResult == _unset
          ? this.pregnancyResult
          : pregnancyResult as PregnancyCheckResult?,
      expectedCalvingDate: expectedCalvingDate == _unset
          ? this.expectedCalvingDate
          : expectedCalvingDate as DateTime?,
      actualCalvingDate: actualCalvingDate == _unset
          ? this.actualCalvingDate
          : actualCalvingDate as DateTime?,
      calvingOutcome: calvingOutcome == _unset
          ? this.calvingOutcome
          : calvingOutcome as CalvingOutcome?,
      calvingEase: calvingEase == _unset
          ? this.calvingEase
          : calvingEase as int?,
      offspringUuids: offspringUuids ?? this.offspringUuids,
      calvingNotes: calvingNotes == _unset
          ? this.calvingNotes
          : calvingNotes as String?,
      notes: notes == _unset ? this.notes : notes as String?,
      servicedBy: servicedBy == _unset
          ? this.servicedBy
          : servicedBy as String?,
      recordUuid: recordUuid ?? this.recordUuid,
      updatedAt: updatedAt ?? this.updatedAt,
      id: id ?? this.id,
    );
  }

  @override
  List<Object?> get props => [
    kind,
    animalUuid,
    serviceDate,
    serviceType,
    maleSireUuid,
    maleSireIdentifier,
    pregnancyCheckDate,
    pregnancyResult,
    expectedCalvingDate,
    actualCalvingDate,
    calvingOutcome,
    calvingEase,
    offspringUuids,
    calvingNotes,
    notes,
    servicedBy,
    recordUuid,
    updatedAt,
    id,
  ];
}
