import 'package:flutter/material.dart';
import 'package:libretapp/features/animales/application/bloc/animal_event.dart';
import 'package:libretapp/features/animales/domain/animal_domain.dart';
import 'package:libretapp/features/animales/widgets/detail_helpers.dart';
import 'package:libretapp/features/ubicaciones/domain/entities/location_entity.dart';

/// Shows a bottom sheet for changing an animal's location and batch.
Future<void> showLocationBatchSheet(
  BuildContext context, {
  required AnimalEntity animal,
  required List<LocationEntity> locations,
  required List<AnimalEntity> allAnimals,
  required Future<bool> Function(AnimalEvent) dispatchAndAwait,
  required VoidCallback onReload,
}) async {
  final messenger = ScaffoldMessenger.of(context);
  final batches = uniqueBatches(allAnimals);

  String? selectedLocation =
      (animal.currentPaddockId ?? animal.initialLocationId)?.trim();
  String? selectedBatch = animal.batchId;
  var creatingBatch = false;
  final newBatchCtrl = TextEditingController();

  // Deduplicate locations by uuid to avoid duplicate dropdown values
  final uniqueLocations = {
    for (final loc in locations)
      if (loc.uuid.trim().isNotEmpty) loc.uuid.trim(): loc,
  }.values.toList();

  final validLocationIds = uniqueLocations
      .map((loc) => loc.uuid.trim())
      .toSet();

  // If the current selection no longer exists in the list, clear it to avoid dropdown assertion
  if (selectedLocation != null &&
      !validLocationIds.contains(selectedLocation)) {
    selectedLocation = null;
  }

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
                  Row(
                    children: const [
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
                    initialValue: creatingBatch ? 'nuevo' : selectedBatch,
                    decoration: const InputDecoration(
                      labelText: 'Lote',
                      border: OutlineInputBorder(),
                    ),
                    items: [
                      const DropdownMenuItem(
                        value: null,
                        child: Text('Sin lote'),
                      ),
                      ...batches.map(
                        (b) => DropdownMenuItem(value: b, child: Text(b)),
                      ),
                      const DropdownMenuItem(
                        value: 'nuevo',
                        child: Text('Crear nuevo lote'),
                      ),
                    ],
                    onChanged: (value) {
                      setModalState(() {
                        if (value == 'nuevo') {
                          creatingBatch = true;
                          selectedBatch = null;
                        } else {
                          creatingBatch = false;
                          selectedBatch = value;
                        }
                      });
                    },
                  ),
                  if (creatingBatch) ...[
                    const SizedBox(height: 12),
                    TextField(
                      controller: newBatchCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Nombre de lote',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ],
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.save_as_outlined),
                      label: const Text('Guardar'),
                      onPressed: () async {
                        final batchName = creatingBatch
                            ? newBatchCtrl.text.trim()
                            : selectedBatch?.trim();
                        if (creatingBatch && (batchName?.isEmpty ?? true)) {
                          messenger.showSnackBar(
                            const SnackBar(
                              content: Text('Define un nombre para el lote'),
                            ),
                          );
                          return;
                        }

                        final updated = animal.copyWith(
                          currentPaddockId: selectedLocation,
                          initialLocationId:
                              animal.initialLocationId ?? selectedLocation,
                          batchId: batchName?.isEmpty == true
                              ? null
                              : batchName,
                          lastMovementDate: DateTime.now(),
                          lastUpdateDate: DateTime.now(),
                          synced: false,
                        );

                        final ok = await dispatchAndAwait(
                          UpdateAnimal(updated),
                        );
                        if (!context.mounted) return;
                        if (ok) {
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

  newBatchCtrl.dispose();
}
