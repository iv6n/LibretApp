/// GPS walks, pasture rotations and occupancy history.
library;

class GpsPoint {
  const GpsPoint({required this.latitude, required this.longitude, required this.capturedAt, this.accuracyMeters});
  final double latitude;
  final double longitude;
  final DateTime capturedAt;
  final double? accuracyMeters;
  Map<String, dynamic> toJson() => {'latitude': latitude, 'longitude': longitude, 'capturedAt': capturedAt.toUtc().toIso8601String(), 'accuracyMeters': accuracyMeters};
  factory GpsPoint.fromJson(Map<String, dynamic> json) => GpsPoint(latitude: (json['latitude'] as num).toDouble(), longitude: (json['longitude'] as num).toDouble(), capturedAt: DateTime.parse(json['capturedAt'] as String).toUtc(), accuracyMeters: (json['accuracyMeters'] as num?)?.toDouble());
}

class GpsWalk {
  const GpsWalk({required this.uuid, required this.farmId, required this.locationId, required this.startedAt, required this.points, this.endedAt, this.paused = false});
  final String uuid;
  final String farmId;
  final String locationId;
  final DateTime startedAt;
  final DateTime? endedAt;
  final List<GpsPoint> points;
  final bool paused;
  double get hectares => _polygonArea(points.map((p) => (p.latitude, p.longitude)).toList()) / 10000;
  Map<String, dynamic> toJson() => {'uuid': uuid, 'farmId': farmId, 'locationId': locationId, 'startedAt': startedAt.toUtc().toIso8601String(), 'endedAt': endedAt?.toUtc().toIso8601String(), 'paused': paused, 'points': points.map((p) => p.toJson()).toList()};
  factory GpsWalk.fromJson(Map<String, dynamic> json) => GpsWalk(uuid: json['uuid'] as String, farmId: json['farmId'] as String, locationId: json['locationId'] as String, startedAt: DateTime.parse(json['startedAt'] as String).toUtc(), endedAt: (json['endedAt'] as String?) == null ? null : DateTime.parse(json['endedAt'] as String).toUtc(), paused: json['paused'] as bool? ?? false, points: ((json['points'] as List?) ?? const []).map((p) => GpsPoint.fromJson(Map<String, dynamic>.from(p as Map))).toList());
}

class PastureOccupation {
  const PastureOccupation({required this.uuid, required this.farmId, required this.locationId, required this.from, required this.to, required this.headCount, this.alertAtRestDays = 0});
  final String uuid;
  final String farmId;
  final String locationId;
  final DateTime from;
  final DateTime to;
  final int headCount;
  final int alertAtRestDays;
  int get restDays => DateTime.now().difference(to).inDays;
  bool get needsAlert => restDays < alertAtRestDays;
  Map<String, dynamic> toJson() => {'uuid': uuid, 'farmId': farmId, 'locationId': locationId, 'from': from.toUtc().toIso8601String(), 'to': to.toUtc().toIso8601String(), 'headCount': headCount, 'alertAtRestDays': alertAtRestDays};
  factory PastureOccupation.fromJson(Map<String, dynamic> json) => PastureOccupation(uuid: json['uuid'] as String, farmId: json['farmId'] as String, locationId: json['locationId'] as String, from: DateTime.parse(json['from'] as String).toUtc(), to: DateTime.parse(json['to'] as String).toUtc(), headCount: (json['headCount'] as num).toInt(), alertAtRestDays: (json['alertAtRestDays'] as num?)?.toInt() ?? 0);
}

double _polygonArea(List<(double, double)> points) {
  if (points.length < 3) return 0;
  const metersPerDegree = 111320.0;
  final latitude = points.fold<double>(0, (sum, p) => sum + p.$1) / points.length;
  final cosLatitude = (latitude * 3.141592653589793 / 180).cosine;
  var area = 0.0;
  for (var i = 0; i < points.length; i++) {
    final a = points[i];
    final b = points[(i + 1) % points.length];
    final ax = a.$2 * metersPerDegree * cosLatitude;
    final ay = a.$1 * metersPerDegree;
    final bx = b.$2 * metersPerDegree * cosLatitude;
    final by = b.$1 * metersPerDegree;
    area += ax * by - bx * ay;
  }
  return area.abs() / 2;
}

extension on double {
  double get cosine {
    var term = 1.0;
    var sum = 1.0;
    final square = this * this;
    for (var n = 1; n < 8; n++) {
      term *= -square / ((2 * n - 1) * (2 * n));
      sum += term;
    }
    return sum.abs().clamp(0.0000001, 1.0);
  }
}
