/// Maquila contracts and restricted client statements.
library;

enum MaquilaRateUnit { day, liveKg, animal, rent }

class MaquilaTariff {
  const MaquilaTariff({required this.uuid, required this.unit, required this.amountCents, required this.validFrom, this.validTo});
  final String uuid;
  final MaquilaRateUnit unit;
  final int amountCents;
  final DateTime validFrom;
  final DateTime? validTo;
  bool applies(DateTime date) => !date.isBefore(validFrom) && (validTo == null || date.isBefore(validTo!));
  Map<String, dynamic> toJson() => {'uuid': uuid, 'unit': unit.name, 'amountCents': amountCents, 'validFrom': validFrom.toUtc().toIso8601String(), 'validTo': validTo?.toUtc().toIso8601String()};
  factory MaquilaTariff.fromJson(Map<String, dynamic> json) => MaquilaTariff(uuid: json['uuid'] as String, unit: MaquilaRateUnit.values.byName(json['unit'] as String), amountCents: (json['amountCents'] as num).toInt(), validFrom: DateTime.parse(json['validFrom'] as String).toUtc(), validTo: (json['validTo'] as String?) == null ? null : DateTime.parse(json['validTo'] as String).toUtc());
}

class MaquilaContract {
  const MaquilaContract({required this.uuid, required this.farmId, required this.clientId, required this.animalIds, required this.startedAt, this.endedAt, required this.tariffs, this.notes});
  final String uuid;
  final String farmId;
  final String clientId;
  final List<String> animalIds;
  final DateTime startedAt;
  final DateTime? endedAt;
  final List<MaquilaTariff> tariffs;
  final String? notes;
  MaquilaTariff? tariffFor(DateTime date, MaquilaRateUnit unit) => tariffs.where((t) => t.unit == unit && t.applies(date)).firstOrNull;
  Map<String, dynamic> toJson() => {'uuid': uuid, 'farmId': farmId, 'clientId': clientId, 'animalIds': animalIds, 'startedAt': startedAt.toUtc().toIso8601String(), 'endedAt': endedAt?.toUtc().toIso8601String(), 'tariffs': tariffs.map((t) => t.toJson()).toList(), 'notes': notes};
  factory MaquilaContract.fromJson(Map<String, dynamic> json) => MaquilaContract(uuid: json['uuid'] as String, farmId: json['farmId'] as String, clientId: json['clientId'] as String, animalIds: ((json['animalIds'] as List?) ?? const []).cast<String>(), startedAt: DateTime.parse(json['startedAt'] as String).toUtc(), endedAt: (json['endedAt'] as String?) == null ? null : DateTime.parse(json['endedAt'] as String).toUtc(), tariffs: ((json['tariffs'] as List?) ?? const []).map((t) => MaquilaTariff.fromJson(Map<String, dynamic>.from(t as Map))).toList(), notes: json['notes'] as String?);
}

class ClientStatementLine {
  const ClientStatementLine({required this.uuid, required this.date, required this.description, required this.amountCents, this.invoiceId, this.paymentId});
  final String uuid;
  final DateTime date;
  final String description;
  final int amountCents;
  final String? invoiceId;
  final String? paymentId;
}
