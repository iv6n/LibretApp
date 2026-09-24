library;

import 'package:libretapp/core/persistence/json_feature_repository.dart';
import 'maquila_models.dart';

class MaquilaService {
  MaquilaService(this._contracts);
  final JsonFeatureRepository<MaquilaContract> _contracts;
  Future<MaquilaContract> save(MaquilaContract contract) => _contracts.save(farmId: contract.farmId, value: contract, uuid: contract.uuid);
  Future<List<MaquilaContract>> forClient(String farmId, String clientId) async => (await _contracts.list(farmId)).where((c) => c.clientId == clientId).toList(growable: false);
  Future<bool> canClientSeeAnimal({required String farmId, required String clientId, required String animalId}) async => (await forClient(farmId, clientId)).any((c) => c.animalIds.contains(animalId));
  int calculateCharge({required MaquilaContract contract, required DateTime from, required DateTime to, required double liveKg, required MaquilaRateUnit unit}) {
    final tariff = contract.tariffFor(to, unit);
    if (tariff == null) return 0;
    final quantity = switch (unit) { MaquilaRateUnit.day => to.difference(from).inDays.clamp(0, 100000), MaquilaRateUnit.liveKg => liveKg, MaquilaRateUnit.animal || MaquilaRateUnit.rent => 1 };
    return (quantity * tariff.amountCents).round();
  }
}
