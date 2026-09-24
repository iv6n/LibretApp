library;

class AnimalMovementDetails {
  const AnimalMovementDetails({
    required this.movementUuid,
    required this.animalUuid,
    required this.date,
    this.upp,
    this.origin,
    this.destination,
    this.documentPath,
    this.notes,
  });

  final String movementUuid;
  final String animalUuid;
  final DateTime date;
  final String? upp;
  final String? origin;
  final String? destination;
  final String? documentPath;
  final String? notes;

  Map<String, dynamic> toJson() => {
    'movementUuid': movementUuid, 'animalUuid': animalUuid,
    'date': date.toUtc().toIso8601String(), 'upp': upp, 'origin': origin,
    'destination': destination, 'documentPath': documentPath, 'notes': notes,
  };
  factory AnimalMovementDetails.fromJson(Map<String, dynamic> json) => AnimalMovementDetails(
    movementUuid: json['movementUuid'] as String, animalUuid: json['animalUuid'] as String,
    date: DateTime.parse(json['date'] as String).toUtc(), upp: json['upp'] as String?,
    origin: json['origin'] as String?, destination: json['destination'] as String?,
    documentPath: json['documentPath'] as String?, notes: json['notes'] as String?,
  );
}
