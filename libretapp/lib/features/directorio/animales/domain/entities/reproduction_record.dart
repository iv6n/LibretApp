import 'package:equatable/equatable.dart';

/// Tipos de servicio reproductor.
enum ServiceType { naturalService, artificialInsemination, ivf }

/// Resultado de chequeo de preñez.
enum PregnancyCheckResult { positive, negative, uncertain, notChecked }

/// Registro de evento reproductivo del animal.
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
    this.calvingResult,
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
  final String? calvingResult;
  final String? notes;
  final String? servicedBy;
  final String? id;

  ReproductionRecord copyWith({
    DateTime? serviceDate,
    ServiceType? serviceType,
    String? maleSireUuid,
    String? maleSireIdentifier,
    DateTime? pregnancyCheckDate,
    PregnancyCheckResult? pregnancyResult,
    DateTime? expectedCalvingDate,
    DateTime? actualCalvingDate,
    String? calvingResult,
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
      calvingResult: calvingResult ?? this.calvingResult,
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
    calvingResult,
    notes,
    servicedBy,
    id,
  ];
}
