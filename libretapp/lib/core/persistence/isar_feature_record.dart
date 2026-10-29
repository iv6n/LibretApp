/// Generic Isar envelope for the vertical slices that are being added.
///
/// Keeping the envelope small lets the domain contracts evolve without
/// forcing a destructive migration every time a new operational module is
/// introduced. Payloads are versioned by [kind] and remain exportable.
library;

import 'package:isar_community/isar.dart';

part 'isar_feature_record.g.dart';

@collection
class IsarFeatureRecord {
  Id id = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  late String uuid;

  @Index()
  late String farmId;

  @Index()
  late String kind;

  late String payloadJson;
  late DateTime createdAt;
  late DateTime updatedAt;
  DateTime? deletedAt;
  late int revision;
  late bool synced;
}
