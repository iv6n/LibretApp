import 'package:libretapp/features/directorio/animales/domain/entities/movement_record.dart';
import 'package:libretapp/features/ubicaciones/domain/repositories/location_repository.dart';

/// Resolves historical references from the local repository, including archived
/// locations that are deliberately absent from the active destination list.
Future<Map<String, String>> loadMovementLocationNames(
  Iterable<MovementRecord> movements,
  LocationRepository? repository,
) async {
  if (repository == null) return const {};
  final references = <String>{
    for (final movement in movements) ...[
      if (movement.fromLocation != null) movement.fromLocation!.trim(),
      if (!movement.clearsLocation) movement.toLocation.trim(),
    ],
  }..remove('');
  final entries = await Future.wait(
    references.map((reference) async {
      final location = await repository.getByUuid(reference);
      return MapEntry(reference, location?.name.trim());
    }),
  );
  return {
    for (final entry in entries)
      if (entry.value != null && entry.value!.isNotEmpty)
        entry.key: entry.value!,
  };
}

final _uuidReference = RegExp(
  r'^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$',
  caseSensitive: false,
);

/// Older records may contain a literal name instead of a location reference.
/// Preserve those names, while leaving missing UUIDs for the UI's empty label.
String? movementLocationName(String reference, Map<String, String> names) {
  final key = reference.trim();
  final name = names[key];
  if (name != null && name.isNotEmpty) return name;
  return key.isEmpty || _uuidReference.hasMatch(key) ? null : key;
}
