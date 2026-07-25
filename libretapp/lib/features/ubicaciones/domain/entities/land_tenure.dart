import 'package:libretapp/features/ubicaciones/domain/enums/tenure_type.dart';

class LandTenure {
  const LandTenure({
    required this.id,
    required this.locationId,
    required this.tenureType,
    required this.holderName,
    required this.active,
    this.organizationId,
    this.livestockCapacity,
    this.areaHectares,
    this.startDate,
    this.endDate,
    this.legalReference,
    this.notes,
  });

  final String id;
  final String locationId;
  final TenureType tenureType;
  final String holderName;
  final bool active;
  final String? organizationId;
  final int? livestockCapacity;
  final double? areaHectares;
  final DateTime? startDate;
  final DateTime? endDate;
  final String? legalReference;
  final String? notes;

  LandTenure copyWith({
    String? id,
    String? locationId,
    TenureType? tenureType,
    String? holderName,
    bool? active,
    String? organizationId,
    int? livestockCapacity,
    double? areaHectares,
    DateTime? startDate,
    DateTime? endDate,
    String? legalReference,
    String? notes,
  }) {
    return LandTenure(
      id: id ?? this.id,
      locationId: locationId ?? this.locationId,
      tenureType: tenureType ?? this.tenureType,
      holderName: holderName ?? this.holderName,
      active: active ?? this.active,
      organizationId: organizationId ?? this.organizationId,
      livestockCapacity: livestockCapacity ?? this.livestockCapacity,
      areaHectares: areaHectares ?? this.areaHectares,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      legalReference: legalReference ?? this.legalReference,
      notes: notes ?? this.notes,
    );
  }
}
