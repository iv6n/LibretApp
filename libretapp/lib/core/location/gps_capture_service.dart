/// Optional GPS capture that never blocks a local save.
library;

import 'package:geolocator/geolocator.dart';
import 'package:libretapp/core/platform/release_features.dart';

class GeoCapture {
  const GeoCapture({
    required this.latitude,
    required this.longitude,
    required this.accuracyMeters,
    required this.capturedAt,
  });

  final double latitude;
  final double longitude;
  final double accuracyMeters;
  final DateTime capturedAt;
}

class GpsCaptureService {
  Future<GeoCapture?> tryCapture() async {
    if (!ReleaseFeatures.gpsCaptureEnabled) return null;
    try {
      if (!await Geolocator.isLocationServiceEnabled()) return null;
      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        return null;
      }
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.low,
          timeLimit: Duration(seconds: 5),
        ),
      );
      return GeoCapture(
        latitude: position.latitude,
        longitude: position.longitude,
        accuracyMeters: position.accuracy,
        capturedAt: position.timestamp,
      );
    } catch (_) {
      return null;
    }
  }
}
