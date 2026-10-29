import 'package:isar_community/isar.dart';

part 'isar_farm_profile.g.dart';

/// One profile per workspace database, committed with restored records.
@collection
class IsarFarmProfile {
  Id id = 1;
  late String payloadJson;
}
