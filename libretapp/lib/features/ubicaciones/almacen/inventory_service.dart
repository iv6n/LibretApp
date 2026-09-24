library;

import 'package:libretapp/core/persistence/json_feature_repository.dart';
import 'package:libretapp/features/ubicaciones/almacen/inventory_models.dart';
import 'package:uuid/uuid.dart';

class InventoryService {
  InventoryService(JsonFeatureRepository<InventoryTransaction> repository) : _repository = repository;
  final JsonFeatureRepository<InventoryTransaction> _repository;

  Future<List<InventoryTransaction>> kardex(String farmId, String productId) async =>
      (await _repository.list(farmId)).where((t) => t.productId == productId).toList(growable: false);

  Future<StockBalance> balance(String farmId, String productId, {String? locationId, String? lotNumber}) async {
    final rows = await kardex(farmId, productId);
    final filtered = rows.where((row) => (locationId == null || row.locationId == locationId) && (lotNumber == null || row.lotNumber == lotNumber));
    var quantity = 0.0;
    var value = 0;
    var unit = '';
    for (final row in filtered) {
      quantity += row.signedQuantity;
      unit = row.unit;
      if (row.unitCostCents != null) value += (row.signedQuantity * row.unitCostCents!).round();
    }
    return StockBalance(productId: productId, unit: unit, quantity: quantity, valueCents: value);
  }

  Future<InventoryTransaction> record({
    required String farmId,
    required String productId,
    required InventoryTransactionType type,
    required double quantity,
    required String unit,
    String? lotNumber,
    String? locationId,
    String? destinationLocationId,
    int? unitCostCents,
    String? sourceUuid,
    String? notes,
    String? uuid,
  }) async {
    if (quantity <= 0) throw const InventoryValidationException('La cantidad debe ser mayor a cero.');
    if (unit.trim().isEmpty) throw const InventoryValidationException('La unidad es obligatoria.');
    final existing = await _findExisting(
      farmId: farmId,
      uuid: uuid,
      sourceUuid: sourceUuid,
      productId: productId,
      type: type,
    );
    if (existing != null) return existing;
    if (type == InventoryTransactionType.consumption || type == InventoryTransactionType.transfer) {
      final current = await balance(farmId, productId, locationId: locationId, lotNumber: lotNumber);
      if (current.quantity < quantity) throw const InventoryValidationException('Existencia insuficiente para el movimiento.');
    }
    final transaction = InventoryTransaction(
      uuid: uuid ?? const Uuid().v4(), farmId: farmId, productId: productId, type: type,
      quantity: quantity, unit: unit.trim(), date: DateTime.now().toUtc(), lotNumber: lotNumber,
      locationId: locationId, destinationLocationId: destinationLocationId, unitCostCents: unitCostCents,
      sourceUuid: sourceUuid, notes: notes,
    );
    return _repository.save(farmId: farmId, value: transaction, uuid: transaction.uuid);
  }

  Future<InventoryTransaction?> _findExisting({
    required String farmId,
    required String? uuid,
    required String? sourceUuid,
    required String productId,
    required InventoryTransactionType type,
  }) async {
    if (uuid == null && sourceUuid == null) return null;
    for (final transaction in await _repository.list(farmId)) {
      if (uuid != null && transaction.uuid == uuid) return transaction;
      if (sourceUuid != null &&
          transaction.sourceUuid == sourceUuid &&
          transaction.productId == productId &&
          transaction.type == type) {
        return transaction;
      }
    }
    return null;
  }

  Future<InventoryTransaction> consumeForTreatment({
    required String farmId,
    required String productId,
    required double quantity,
    required String unit,
    required String treatmentUuid,
    String? lotNumber,
    int? unitCostCents,
  }) => record(
    farmId: farmId, productId: productId, type: InventoryTransactionType.consumption,
    quantity: quantity, unit: unit, sourceUuid: treatmentUuid, lotNumber: lotNumber, unitCostCents: unitCostCents,
  );
}
