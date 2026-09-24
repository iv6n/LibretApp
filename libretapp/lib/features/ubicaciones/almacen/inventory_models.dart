/// Warehouse kardex and stock movements.
library;

enum InventoryTransactionType { entry, consumption, transfer, adjustment, reversal }

class InventoryTransaction {
  const InventoryTransaction({
    required this.uuid,
    required this.farmId,
    required this.productId,
    required this.type,
    required this.quantity,
    required this.unit,
    required this.date,
    this.lotNumber,
    this.locationId,
    this.destinationLocationId,
    this.unitCostCents,
    this.sourceUuid,
    this.notes,
  });

  final String uuid;
  final String farmId;
  final String productId;
  final InventoryTransactionType type;
  final double quantity;
  final String unit;
  final DateTime date;
  final String? lotNumber;
  final String? locationId;
  final String? destinationLocationId;
  final int? unitCostCents;
  final String? sourceUuid;
  final String? notes;

  double get signedQuantity => switch (type) {
    InventoryTransactionType.entry || InventoryTransactionType.adjustment => quantity,
    InventoryTransactionType.consumption || InventoryTransactionType.transfer => -quantity,
    InventoryTransactionType.reversal => quantity,
  };

  Map<String, dynamic> toJson() => {
    'uuid': uuid, 'farmId': farmId, 'productId': productId, 'type': type.name,
    'quantity': quantity, 'unit': unit, 'date': date.toUtc().toIso8601String(),
    'lotNumber': lotNumber, 'locationId': locationId, 'destinationLocationId': destinationLocationId,
    'unitCostCents': unitCostCents, 'sourceUuid': sourceUuid, 'notes': notes,
  };
  factory InventoryTransaction.fromJson(Map<String, dynamic> json) => InventoryTransaction(
    uuid: json['uuid'] as String, farmId: json['farmId'] as String, productId: json['productId'] as String,
    type: InventoryTransactionType.values.byName(json['type'] as String),
    quantity: (json['quantity'] as num).toDouble(), unit: json['unit'] as String,
    date: DateTime.parse(json['date'] as String).toUtc(), lotNumber: json['lotNumber'] as String?,
    locationId: json['locationId'] as String?, destinationLocationId: json['destinationLocationId'] as String?,
    unitCostCents: (json['unitCostCents'] as num?)?.toInt(), sourceUuid: json['sourceUuid'] as String?, notes: json['notes'] as String?,
  );
}

class StockBalance {
  const StockBalance({required this.productId, required this.unit, required this.quantity, this.valueCents = 0});
  final String productId;
  final String unit;
  final double quantity;
  final int valueCents;
}

class InventoryValidationException implements Exception {
  const InventoryValidationException(this.message);
  final String message;
  @override
  String toString() => message;
}
