/// Historical feedlot/fattening cycle models and calculations.
library;

class FatteningMembership {
  const FatteningMembership({required this.animalUuid, required this.enteredAt, this.exitedAt, this.entryWeightKg, this.exitWeightKg});
  final String animalUuid;
  final DateTime enteredAt;
  final DateTime? exitedAt;
  final double? entryWeightKg;
  final double? exitWeightKg;
  double? get gainKg => entryWeightKg == null || exitWeightKg == null ? null : exitWeightKg! - entryWeightKg!;
  Map<String, dynamic> toJson() => {'animalUuid': animalUuid, 'enteredAt': enteredAt.toUtc().toIso8601String(), 'exitedAt': exitedAt?.toUtc().toIso8601String(), 'entryWeightKg': entryWeightKg, 'exitWeightKg': exitWeightKg};
  factory FatteningMembership.fromJson(Map<String, dynamic> json) => FatteningMembership(animalUuid: json['animalUuid'] as String, enteredAt: DateTime.parse(json['enteredAt'] as String).toUtc(), exitedAt: (json['exitedAt'] as String?) == null ? null : DateTime.parse(json['exitedAt'] as String).toUtc(), entryWeightKg: (json['entryWeightKg'] as num?)?.toDouble(), exitWeightKg: (json['exitWeightKg'] as num?)?.toDouble());
}

class FatteningCycle {
  const FatteningCycle({required this.uuid, required this.farmId, required this.name, required this.startedAt, this.endedAt, this.targetWeightKg, this.targetDate, this.members = const [], this.totalFeedDryMatterKg = 0, this.totalCostCents = 0, this.projectedSaleCents = 0});
  final String uuid;
  final String farmId;
  final String name;
  final DateTime startedAt;
  final DateTime? endedAt;
  final double? targetWeightKg;
  final DateTime? targetDate;
  final List<FatteningMembership> members;
  final double totalFeedDryMatterKg;
  final int totalCostCents;
  final int projectedSaleCents;
  int get headCount => members.where((m) => m.exitedAt == null).length;
  double? get costPerKgGained => totalGainKg <= 0 ? null : totalCostCents / 100 / totalGainKg;
  double? get breakEvenPricePerKg => totalSellableKg <= 0 ? null : totalCostCents / 100 / totalSellableKg;
  double get totalGainKg => members.fold(0, (sum, m) => sum + (m.gainKg ?? 0));
  double get totalSellableKg => members.fold(0, (sum, m) => sum + (m.exitWeightKg ?? m.entryWeightKg ?? 0));
  Map<String, dynamic> toJson() => {'uuid': uuid, 'farmId': farmId, 'name': name, 'startedAt': startedAt.toUtc().toIso8601String(), 'endedAt': endedAt?.toUtc().toIso8601String(), 'targetWeightKg': targetWeightKg, 'targetDate': targetDate?.toUtc().toIso8601String(), 'members': members.map((m) => m.toJson()).toList(), 'totalFeedDryMatterKg': totalFeedDryMatterKg, 'totalCostCents': totalCostCents, 'projectedSaleCents': projectedSaleCents};
  factory FatteningCycle.fromJson(Map<String, dynamic> json) => FatteningCycle(uuid: json['uuid'] as String, farmId: json['farmId'] as String, name: json['name'] as String, startedAt: DateTime.parse(json['startedAt'] as String).toUtc(), endedAt: (json['endedAt'] as String?) == null ? null : DateTime.parse(json['endedAt'] as String).toUtc(), targetWeightKg: (json['targetWeightKg'] as num?)?.toDouble(), targetDate: (json['targetDate'] as String?) == null ? null : DateTime.parse(json['targetDate'] as String).toUtc(), members: ((json['members'] as List?) ?? const []).map((m) => FatteningMembership.fromJson(Map<String, dynamic>.from(m as Map))).toList(), totalFeedDryMatterKg: (json['totalFeedDryMatterKg'] as num?)?.toDouble() ?? 0, totalCostCents: (json['totalCostCents'] as num?)?.toInt() ?? 0, projectedSaleCents: (json['projectedSaleCents'] as num?)?.toInt() ?? 0);
}

class FatteningMetrics {
  const FatteningMetrics({required this.gdpObserved, required this.ica, required this.costPerKgGained, required this.breakEvenPricePerKg, required this.targetDate});
  final double? gdpObserved;
  final double? ica;
  final double? costPerKgGained;
  final double? breakEvenPricePerKg;
  final DateTime? targetDate;
}

class FatteningCalculator {
  FatteningMetrics calculate({required double? firstWeightKg, required double? lastWeightKg, required DateTime? firstDate, required DateTime? lastDate, required double? dryMatterConsumedKg, required double? targetWeightKg, required double? currentWeightKg, required int totalCostCents, DateTime? asOf}) {
    final days = firstDate == null || lastDate == null ? 0 : lastDate.difference(firstDate).inDays;
    final gain = firstWeightKg == null || lastWeightKg == null ? null : lastWeightKg - firstWeightKg;
    final gdp = gain == null || days <= 0 ? null : gain / days;
    final ica = dryMatterConsumedKg == null || gain == null || gain <= 0 ? null : dryMatterConsumedKg / gain;
    final cost = gain == null || gain <= 0 ? null : totalCostCents / 100 / gain;
    final breakEven = currentWeightKg == null || currentWeightKg <= 0 ? null : totalCostCents / 100 / currentWeightKg;
    final targetDate = targetWeightKg == null || currentWeightKg == null || gdp == null || gdp <= 0 || targetWeightKg <= currentWeightKg
        ? null
        : (asOf ?? DateTime.now().toUtc()).add(Duration(days: ((targetWeightKg - currentWeightKg) / gdp).ceil()));
    return FatteningMetrics(gdpObserved: gdp, ica: ica, costPerKgGained: cost, breakEvenPricePerKg: breakEven, targetDate: targetDate);
  }
}
