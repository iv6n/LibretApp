/// features › ubicaciones › widgets › location_hierarchy_validation — parent/child hierarchy rules for a location.
library;

import 'package:libretapp/features/ubicaciones/domain/entities/location_entity.dart';
import 'package:libretapp/features/ubicaciones/widgets/location_labels.dart';

/// Validates that [location] can be saved under its selected parent.
///
/// Returns a user-facing Spanish error message if the assignment is
/// invalid, or `null` if it's fine to save. [allLocations] must contain
/// every existing location (used to resolve the parent and check for
/// self-reference).
String? validateLocationParent(
  LocationEntity location,
  List<LocationEntity> allLocations,
) {
  final parentUuid = location.parentUuid;
  if (parentUuid == null) return null;

  if (parentUuid == location.uuid) {
    return 'Una ubicacion no puede asignarse como su propio padre';
  }

  LocationEntity? parent;
  for (final candidate in allLocations) {
    if (candidate.uuid == parentUuid) {
      parent = candidate;
      break;
    }
  }
  if (parent == null) {
    return 'La ubicacion padre seleccionada no existe o fue eliminada';
  }

  if (!parent.canAcceptSubLocationType(location.type)) {
    return '${locationTypeLabelEs(location.type)} no puede estar dentro de '
        '${locationTypeLabelEs(parent.type)}';
  }

  return null;
}
