/// Shared archive-location confirmation dialog.
library;

import 'package:flutter/material.dart';
import 'package:libretapp/features/ubicaciones/domain/entities/location_entity.dart';

Future<bool> confirmDeleteLocation(
  BuildContext context,
  LocationEntity location,
) async {
  final result = await showDialog<bool>(
    context: context,
    useRootNavigator: true,
    builder: (context) => AlertDialog(
      title: const Text('Archivar ubicación'),
      content: Text(
        '¿Deseas archivar "${location.name}"? Se conservará su historial y dejará de aparecer en las listas activas.',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(true),
          child: const Text('Archivar'),
        ),
      ],
    ),
  );
  return result == true;
}
