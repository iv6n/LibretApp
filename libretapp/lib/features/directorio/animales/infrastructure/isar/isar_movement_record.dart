import 'package:isar/isar.dart';
import 'package:libretapp/features/directorio/animales/domain/entities/movement_record.dart';

part 'isar_movement_record.g.dart';

@collection
class IsarMovementRecord {
  Id id = Isar.autoIncrement;

  @Index()
  late String animalUuid;

  String? fromLocation;
  late String toLocation;
  late DateTime date;
  late String reason;
  String? notes;
  String? movedBy;
}

extension IsarMovementRecordMapper on IsarMovementRecord {
  MovementRecord toEntity() {
    return MovementRecord(
      id: id.toString(),
      fromLocation: fromLocation,
      toLocation: toLocation,
      date: date,
      reason: MovementReason.values.byName(reason),
      notes: notes,
      movedBy: movedBy,
    );
  }
}

extension MovementRecordToIsar on MovementRecord {
  IsarMovementRecord toIsar(String animalUuid) {
    final model = IsarMovementRecord()
      ..animalUuid = animalUuid
      ..fromLocation = fromLocation
      ..toLocation = toLocation
      ..date = date
      ..reason = reason.name
      ..notes = notes
      ..movedBy = movedBy;

    if (id != null) {
      final parsed = int.tryParse(id!);
      if (parsed != null) {
        model.id = parsed;
      }
    }
    return model;
  }
}
