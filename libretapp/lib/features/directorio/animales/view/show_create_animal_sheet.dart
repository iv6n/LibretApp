/// features \u203a directorio \u203a animales \u203a view \u203a show_create_animal_sheet \u2014 shows the create-animal bottom sheet.
library;

import 'package:flutter/material.dart';

Future<void> showCreateAnimalSheet(
  BuildContext context, {
  required List<dynamic> locations,
  required String Function() generateUuid,
  required VoidCallback onLocationsRefresh,
}) async {
  await Navigator.of(context).push<void>(
    MaterialPageRoute<void>(
      fullscreenDialog: true,
      builder: (_) => _CreateAnimalPage(
        locations: locations,
        generateUuid: generateUuid,
        onLocationsRefresh: onLocationsRefresh,
      ),
    ),
  );
}

class _CreateAnimalPage extends StatelessWidget {
  const _CreateAnimalPage({
    required this.locations,
    required this.generateUuid,
    required this.onLocationsRefresh,
  });

  final List<dynamic> locations;
  final String Function() generateUuid;
  final VoidCallback onLocationsRefresh;

  @override
  Widget build(BuildContext context) {
    final generatedId = generateUuid();
    return Scaffold(
      appBar: AppBar(title: const Text('Nuevo animal')),
      body: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('ID generado: $generatedId'),
              const SizedBox(height: 8),
              Text('Ubicaciones disponibles: ${locations.length}'),
              const SizedBox(height: 20),
              FilledButton(
                onPressed: () {
                  onLocationsRefresh();
                  Navigator.of(context).pop();
                },
                child: const Text('Cerrar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
