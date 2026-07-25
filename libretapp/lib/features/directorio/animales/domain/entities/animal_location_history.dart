enum MovementReason { sale, purchase, transfer, treatment, grazing, other }

class AnimalLocationHistory {
  const AnimalLocationHistory({
    required this.id,
    required this.animalId,
    required this.locationId,
    required this.fromDate,
    this.fromLocationId,
    this.toDate,
    this.reason,
    this.movedBy,
    this.notes,
  });

  final String id;
  final String animalId;
  final String locationId;
  final DateTime fromDate;
  final String? fromLocationId;
  final DateTime? toDate;
  final MovementReason? reason;
  final String? movedBy;
  final String? notes;

  AnimalLocationHistory copyWith({
    String? id,
    String? animalId,
    String? locationId,
    DateTime? fromDate,
    String? fromLocationId,
    DateTime? toDate,
    MovementReason? reason,
    String? movedBy,
    String? notes,
  }) {
    return AnimalLocationHistory(
      id: id ?? this.id,
      animalId: animalId ?? this.animalId,
      locationId: locationId ?? this.locationId,
      fromDate: fromDate ?? this.fromDate,
      fromLocationId: fromLocationId ?? this.fromLocationId,
      toDate: toDate ?? this.toDate,
      reason: reason ?? this.reason,
      movedBy: movedBy ?? this.movedBy,
      notes: notes ?? this.notes,
    );
  }
}
