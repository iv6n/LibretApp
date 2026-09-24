library;

import 'package:libretapp/core/persistence/json_feature_repository.dart';
import 'package:libretapp/features/directorio/lotes/alimentacion/feed_models.dart';
import 'package:libretapp/features/ubicaciones/almacen/inventory_service.dart';
import 'package:libretapp/features/ubicaciones/almacen/inventory_models.dart';
import 'package:uuid/uuid.dart';

class FeedService {
  FeedService({required JsonFeatureRepository<FeedPlan> plans, required JsonFeatureRepository<FeedExecution> executions, required InventoryService inventory}) : _plans = plans, _executions = executions, _inventory = inventory;
  final JsonFeatureRepository<FeedPlan> _plans;
  final JsonFeatureRepository<FeedExecution> _executions;
  final InventoryService _inventory;

  Future<FeedPlan> savePlan(FeedPlan plan) => _plans.save(farmId: plan.farmId, value: plan, uuid: plan.uuid);
  Future<List<FeedPlan>> plans(String farmId, String lotId) async => (await _plans.list(farmId)).where((p) => p.lotId == lotId).toList(growable: false);

  Future<FeedExecution> execute({required String farmId, required FeedPlan plan, required int headCount, required double servedKg, double leftoverKg = 0, String? locationId, String? uuid}) async {
    if (headCount <= 0 || servedKg < 0 || leftoverKg < 0 || leftoverKg > servedKg) throw const FormatException('La ejecución de alimento no es válida.');
    final execution = FeedExecution(uuid: uuid ?? const Uuid().v4(), farmId: farmId, planId: plan.uuid, lotId: plan.lotId, date: DateTime.now().toUtc(), headCount: headCount, servedKg: servedKg, leftoverKg: leftoverKg);
    final existing = await _executions.get(farmId, execution.uuid);
    if (existing != null) return existing;
    final consumed = execution.effectiveConsumptionKg;
    if (consumed > 0) {
      for (final ingredient in plan.ingredients) {
        final share = plan.ingredients.fold<double>(0, (sum, item) => sum + item.quantityKg);
        if (share <= 0) continue;
        await _inventory.record(farmId: farmId, productId: ingredient.productId, type: InventoryTransactionType.consumption, quantity: consumed * ingredient.quantityKg / share, unit: 'kg', locationId: locationId, sourceUuid: execution.uuid, unitCostCents: ingredient.unitCostCentsPerKg);
      }
    }
    return _executions.save(farmId: farmId, value: execution, uuid: execution.uuid);
  }
}
