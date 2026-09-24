library;

import 'package:libretapp/core/persistence/json_feature_repository.dart';
import 'canal_models.dart';

class CanalService {
  CanalService(this._repository);
  final JsonFeatureRepository<CarcassRecord> _repository;
  Future<CarcassRecord> save(CarcassRecord value) => _repository.save(farmId: value.farmId, value: value, uuid: value.uuid);
  Future<List<CarcassRecord>> list(String farmId) => _repository.list(farmId);
}
