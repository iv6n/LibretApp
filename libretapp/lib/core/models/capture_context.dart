/// Shared metadata passed through field capture flows.
library;

enum CaptureSource { manual, rfid, scale, import }

class CaptureContext {
  const CaptureContext({
    required this.source,
    required this.capturedAt,
    this.animalUuid,
    this.batchUuid,
    this.locationUuid,
    this.latitude,
    this.longitude,
    this.accuracyMeters,
  });

  final CaptureSource source;
  final DateTime capturedAt;
  final String? animalUuid;
  final String? batchUuid;
  final String? locationUuid;
  final double? latitude;
  final double? longitude;
  final double? accuracyMeters;
}
