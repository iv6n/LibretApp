/// Optional ranch hunting log; feature flag remains off by default.
library;

class HuntingEvent {
  const HuntingEvent({required this.uuid, required this.farmId, required this.date, required this.species, this.trophyMeasurements = const {}, this.participantIds = const [], this.photoPaths = const [], this.locationId, this.notes});
  final String uuid;
  final String farmId;
  final DateTime date;
  final String species;
  final Map<String, double> trophyMeasurements;
  final List<String> participantIds;
  final List<String> photoPaths;
  final String? locationId;
  final String? notes;
  Map<String, dynamic> toJson() => {'uuid': uuid, 'farmId': farmId, 'date': date.toUtc().toIso8601String(), 'species': species, 'trophyMeasurements': trophyMeasurements, 'participantIds': participantIds, 'photoPaths': photoPaths, 'locationId': locationId, 'notes': notes};
  factory HuntingEvent.fromJson(Map<String, dynamic> json) => HuntingEvent(uuid: json['uuid'] as String, farmId: json['farmId'] as String, date: DateTime.parse(json['date'] as String).toUtc(), species: json['species'] as String, trophyMeasurements: ((json['trophyMeasurements'] as Map?) ?? const {}).map((key, value) => MapEntry('$key', (value as num).toDouble())), participantIds: ((json['participantIds'] as List?) ?? const []).cast<String>(), photoPaths: ((json['photoPaths'] as List?) ?? const []).cast<String>(), locationId: json['locationId'] as String?, notes: json['notes'] as String?);
}

class HuntingFeatureFlag {
  const HuntingFeatureFlag({this.enabled = false});
  final bool enabled;
}
