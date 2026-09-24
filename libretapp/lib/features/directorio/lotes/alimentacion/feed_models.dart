/// Versioned feeding plans for lots.
library;

class FeedIngredient {
  const FeedIngredient({required this.productId, required this.quantityKg, required this.dryMatterPercent, this.unitCostCentsPerKg = 0});
  final String productId;
  final double quantityKg;
  final double dryMatterPercent;
  final int unitCostCentsPerKg;
  double get dryMatterKg => quantityKg * dryMatterPercent / 100;
  int get costCents => (quantityKg * unitCostCentsPerKg).round();
  Map<String, dynamic> toJson() => {'productId': productId, 'quantityKg': quantityKg, 'dryMatterPercent': dryMatterPercent, 'unitCostCentsPerKg': unitCostCentsPerKg};
  factory FeedIngredient.fromJson(Map<String, dynamic> json) => FeedIngredient(productId: json['productId'] as String, quantityKg: (json['quantityKg'] as num).toDouble(), dryMatterPercent: (json['dryMatterPercent'] as num).toDouble(), unitCostCentsPerKg: (json['unitCostCentsPerKg'] as num?)?.toInt() ?? 0);
}

class FeedPlan {
  const FeedPlan({required this.uuid, required this.farmId, required this.lotId, required this.name, required this.version, required this.validFrom, required this.ingredients, required this.headRationKg, this.notes});
  final String uuid;
  final String farmId;
  final String lotId;
  final String name;
  final int version;
  final DateTime validFrom;
  final List<FeedIngredient> ingredients;
  final double headRationKg;
  final String? notes;
  double get dryMatterPerHeadKg => ingredients.fold<double>(0, (sum, item) => sum + item.dryMatterKg) * headRationKg;
  int get costPerHeadCents => (ingredients.fold<double>(0, (sum, item) => sum + item.costCents) * headRationKg).round();
  Map<String, dynamic> toJson() => {'uuid': uuid, 'farmId': farmId, 'lotId': lotId, 'name': name, 'version': version, 'validFrom': validFrom.toUtc().toIso8601String(), 'ingredients': ingredients.map((i) => i.toJson()).toList(), 'headRationKg': headRationKg, 'notes': notes};
  factory FeedPlan.fromJson(Map<String, dynamic> json) => FeedPlan(uuid: json['uuid'] as String, farmId: json['farmId'] as String, lotId: json['lotId'] as String, name: json['name'] as String, version: (json['version'] as num).toInt(), validFrom: DateTime.parse(json['validFrom'] as String).toUtc(), ingredients: ((json['ingredients'] as List?) ?? const []).map((i) => FeedIngredient.fromJson(Map<String, dynamic>.from(i as Map))).toList(), headRationKg: (json['headRationKg'] as num).toDouble(), notes: json['notes'] as String?);
}

class FeedExecution {
  const FeedExecution({required this.uuid, required this.farmId, required this.planId, required this.lotId, required this.date, required this.headCount, required this.servedKg, this.leftoverKg = 0});
  final String uuid;
  final String farmId;
  final String planId;
  final String lotId;
  final DateTime date;
  final int headCount;
  final double servedKg;
  final double leftoverKg;
  double get effectiveConsumptionKg => (servedKg - leftoverKg).clamp(0, double.infinity);
  Map<String, dynamic> toJson() => {'uuid': uuid, 'farmId': farmId, 'planId': planId, 'lotId': lotId, 'date': date.toUtc().toIso8601String(), 'headCount': headCount, 'servedKg': servedKg, 'leftoverKg': leftoverKg};
  factory FeedExecution.fromJson(Map<String, dynamic> json) => FeedExecution(uuid: json['uuid'] as String, farmId: json['farmId'] as String, planId: json['planId'] as String, lotId: json['lotId'] as String, date: DateTime.parse(json['date'] as String).toUtc(), headCount: (json['headCount'] as num).toInt(), servedKg: (json['servedKg'] as num).toDouble(), leftoverKg: (json['leftoverKg'] as num?)?.toDouble() ?? 0);
}
