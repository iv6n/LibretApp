/// Shared delete-location confirmation dialog.
library;

import 'package:flutter/material.dart';
import 'package:libretapp/features/ubicaciones/domain/entities/location_entity.dart';

Future<bool> confirmDeleteLocation(
  BuildContext context,
  LocationEntity location,
) async {
  final result = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Eliminar ubicación'),
      content: Text(
        '¿Deseas borrar "${location.name}"? Esta acción no se puede deshacer.',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(true),
          child: const Text('Eliminar'),
        ),
      ],
    ),
  );
  return result == true;
}
