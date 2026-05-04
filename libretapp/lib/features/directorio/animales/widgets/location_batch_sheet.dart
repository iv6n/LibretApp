/// features \u203a directorio \u203a animales \u203a widgets \u203a location_batch_sheet \u2014 bottom sheet for batch-assigning animals to a location.
library;

import 'package:flutter/material.dart';
import 'package:libretapp/features/directorio/animales/application/bloc/animal_event.dart';
import 'package:libretapp/features/directorio/animales/domain/animal_domain.dart';
import 'package:libretapp/features/directorio/lotes/domain/entities/lote_entity.dart';
import 'package:libretapp/features/directorio/lotes/infrastructure/lotes_repository.dart';
import 'package:libretapp/features/ubicaciones/domain/entities/location_entity.dart';

/// Shows a bottom sheet for changing an animal's location and batch.
/// The batch selection now uses existing LoteEntity objects (UUID-based).
Future<void> showLocationBatchSheet(
  BuildContext context, {
  required AnimalEntity animal,
  required List<LocationEntity> locations,
  required List<AnimalEntity> allAnimals,
  required LotesRepository lotesRepository,
  required Future<bool> Function(AnimalEvent) dispatchAndAwait,
  required VoidCallback onReload,
}) async {
  final messenger = ScaffoldMessenger.of(context);

  String? selectedLocation =
      (animal.currentPaddockId ?? animal.initialLocationId)?.trim();
  String? selectedBatchUuid = animal.batchUuid;

  // Load available batches
  List<LoteEntity> availableLotes = [];
  try {
    availableLotes = await lotesRepository.getActiveLotes();
  } catch (e) {
    if (context.mounted) {
      messenger.showSnackBar(
        SnackBar(content: Text('Error al cargar lotes: $e')),
      );
    }
  }

  // Deduplicate locations by uuid to avoid duplicate dropdown values
  final uniqueLocations = {
    for (final loc in locations)
      if (loc.uuid.trim().isNotEmpty) loc.uuid.trim(): loc,
  }.values.toList();

  final validLocationIds = uniqueLocations
      .map((loc) => loc.uuid.trim())
      .toSet();

  // If the current selection no longer exists in the list, clear it
  if (selectedLocation != null &&
      !validLocationIds.contains(selectedLocation)) {
    selectedLocation = null;
  }

  // Validate current batch UUID exists in available lotes
  if (selectedBatchUuid != null &&
      !availableLotes.any((lote) => lote.uuid == selectedBatchUuid)) {
    selectedBatchUuid = null;
  }

  if (!context.mounted) return;

  await showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setModalState) {
          return Padding(
            padding: EdgeInsets.only(
              left: 16,
              right: 16,
              top: 16,
              bottom: MediaQuery.of(context).viewInsets.bottom + 16,
            ),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.route_outlined, color: Colors.blue),
                      SizedBox(width: 8),
                      Text(
                        'Cambiar ubicación y lote',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String?>(
                    initialValue: selectedLocation,
                    decoration: const InputDecoration(
                      labelText: 'Ubicación',
                      border: OutlineInputBorder(),
                    ),
                    items: [
                      const DropdownMenuItem(
                        value: null,
                        child: Text('Sin ubicación'),
                      ),
                      ...uniqueLocations.map(
                        (LocationEntity loc) => DropdownMenuItem(
                          value: loc.uuid.trim(),
                          child: Text(loc.name),
                        ),
                      ),
                    ],
                    onChanged: (value) =>
                        setModalState(() => selectedLocation = value),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String?>(
                    initialValue: selectedBatchUuid,
                    decoration: const InputDecoration(
                      labelText: 'Lote',
                      border: OutlineInputBorder(),
                    ),
                    items: [
                      const DropdownMenuItem(
                        value: null,
                        child: Text('Sin lote'),
                      ),
                      ...availableLotes.map(
                        (lote) => DropdownMenuItem(
                          value: lote.uuid,
                          child: Text(lote.nombre),
                        ),
                      ),
                    ],
                    onChanged: (value) {
                      setModalState(() => selectedBatchUuid = value);
                    },
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.save_as_outlined),
                      label: const Text('Guardar'),
                      onPressed: () async {
                        // Update location first if changed
                        if (animal.currentPaddockId != selectedLocation ||
                            animal.batchUuid != selectedBatchUuid) {
                          final updatedAnimal = animal.copyWith(
                            currentPaddockId: selectedLocation,
                            initialLocationId:
                                animal.initialLocationId ?? selectedLocation,
                            lastMovementDate: DateTime.now(),
                            lastUpdateDate: DateTime.now(),
                            synced: false,
                          );

                          final ok = await dispatchAndAwait(
                            UpdateAnimal(updatedAnimal),
                          );
                          if (!context.mounted) return;
                          if (!ok) return;
                        }

                        // Assign to batch if batch selection changed
                        if (animal.batchUuid != selectedBatchUuid) {
                          final ok = await dispatchAndAwait(
                            AssignAnimalToBatch(
                              animalUuid: animal.uuid,
                              batchUuid: selectedBatchUuid,
                            ),
                          );
                          if (!context.mounted) return;
                          if (!ok) return;
                        }

                        if (context.mounted) {
                          Navigator.of(context).pop(true);
                          onReload();
                          messenger.showSnackBar(
                            const SnackBar(
                              content: Text('Ubicación y lote actualizados'),
                            ),
                          );
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );
    },
  );
}
