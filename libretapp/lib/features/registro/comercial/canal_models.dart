/// Slaughterhouse/channel yield records.
library;

class CarcassRecord {
  const CarcassRecord({required this.uuid, required this.farmId, required this.animalUuid, required this.date, required this.liveWeightKg, required this.hotCarcassKg, this.coldCarcassKg, this.classification, this.discountsCents = 0, this.settlementCents = 0, this.establishment, this.receiptPath});
  final String uuid;
  final String farmId;
  final String animalUuid;
  final DateTime date;
  final double liveWeightKg;
  final double hotCarcassKg;
  final double? coldCarcassKg;
  final String? classification;
  final int discountsCents;
  final int settlementCents;
  final String? establishment;
  final String? receiptPath;
  double get hotYieldPercent => liveWeightKg <= 0 ? 0 : hotCarcassKg / liveWeightKg * 100;
  double? get coldYieldPercent => coldCarcassKg == null || liveWeightKg <= 0 ? null : coldCarcassKg! / liveWeightKg * 100;
  Map<String, dynamic> toJson() => {'uuid': uuid, 'farmId': farmId, 'animalUuid': animalUuid, 'date': date.toUtc().toIso8601String(), 'liveWeightKg': liveWeightKg, 'hotCarcassKg': hotCarcassKg, 'coldCarcassKg': coldCarcassKg, 'classification': classification, 'discountsCents': discountsCents, 'settlementCents': settlementCents, 'establishment': establishment, 'receiptPath': receiptPath};
  factory CarcassRecord.fromJson(Map<String, dynamic> json) => CarcassRecord(uuid: json['uuid'] as String, farmId: json['farmId'] as String, animalUuid: json['animalUuid'] as String, date: DateTime.parse(json['date'] as String).toUtc(), liveWeightKg: (json['liveWeightKg'] as num).toDouble(), hotCarcassKg: (json['hotCarcassKg'] as num).toDouble(), coldCarcassKg: (json['coldCarcassKg'] as num?)?.toDouble(), classification: json['classification'] as String?, discountsCents: (json['discountsCents'] as num?)?.toInt() ?? 0, settlementCents: (json['settlementCents'] as num?)?.toInt() ?? 0, establishment: json['establishment'] as String?, receiptPath: json['receiptPath'] as String?);
}
