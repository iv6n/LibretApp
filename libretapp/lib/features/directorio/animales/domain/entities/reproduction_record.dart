/// features › directorio › animales › domain › entities › reproduction_record — entity for a reproduction event record.
library;

import 'package:equatable/equatable.dart';

/// Tipos de servicio reproductor.
enum ServiceType { naturalService, artificialInsemination, ivf }

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
    required this.serviceDate,
    required this.serviceType,
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
    this.id,
  });
  final DateTime serviceDate;
  final ServiceType serviceType;
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
  final String? id;

  /// Duración real de la gestación. Se deriva en lugar de almacenarse para
  /// que nunca contradiga a las fechas de las que depende.
  int? get gestationDays {
    final calving = actualCalvingDate;
    if (calving == null) return null;
    return calving.difference(serviceDate).inDays;
  }

  /// Un parto ya ocurrió para este ciclo.
  bool get hasCalved => actualCalvingDate != null;

  /// El servicio derivó en una cría viva registrada o declarada.
  bool get producedLiveOffspring =>
      calvingOutcome == CalvingOutcome.liveBirth || offspringUuids.isNotEmpty;

  ReproductionRecord copyWith({
    DateTime? serviceDate,
    ServiceType? serviceType,
    String? maleSireUuid,
    String? maleSireIdentifier,
    DateTime? pregnancyCheckDate,
    PregnancyCheckResult? pregnancyResult,
    DateTime? expectedCalvingDate,
    DateTime? actualCalvingDate,
    CalvingOutcome? calvingOutcome,
    int? calvingEase,
    List<String>? offspringUuids,
    String? calvingNotes,
    String? notes,
    String? servicedBy,
    String? id,
  }) {
    return ReproductionRecord(
      serviceDate: serviceDate ?? this.serviceDate,
      serviceType: serviceType ?? this.serviceType,
      maleSireUuid: maleSireUuid ?? this.maleSireUuid,
      maleSireIdentifier: maleSireIdentifier ?? this.maleSireIdentifier,
      pregnancyCheckDate: pregnancyCheckDate ?? this.pregnancyCheckDate,
      pregnancyResult: pregnancyResult ?? this.pregnancyResult,
      expectedCalvingDate: expectedCalvingDate ?? this.expectedCalvingDate,
      actualCalvingDate: actualCalvingDate ?? this.actualCalvingDate,
      calvingOutcome: calvingOutcome ?? this.calvingOutcome,
      calvingEase: calvingEase ?? this.calvingEase,
      offspringUuids: offspringUuids ?? this.offspringUuids,
      calvingNotes: calvingNotes ?? this.calvingNotes,
      notes: notes ?? this.notes,
      servicedBy: servicedBy ?? this.servicedBy,
      id: id ?? this.id,
    );
  }

  @override
  List<Object?> get props => [
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
    id,
  ];
}
