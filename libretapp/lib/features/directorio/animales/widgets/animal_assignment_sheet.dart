/// features \u203a directorio \u203a animales \u203a widgets \u203a animal_assignment_sheet \u2014 bottom sheet for assigning animals to a lote.
library;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:libretapp/features/directorio/animales/bloc/animales_bloc.dart';
import 'package:libretapp/features/directorio/animales/bloc/animales_event.dart';
import 'package:libretapp/features/directorio/animales/bloc/animales_state.dart';
import 'package:libretapp/features/directorio/animales/domain/animal_domain.dart';
import 'package:libretapp/features/ubicaciones/domain/entities/location_entity.dart';

/// Shows a bottom sheet for assigning location and batch to an animal.
Future<void> showAssignmentSheet(
  BuildContext context, {
  required AnimalEntity animal,
  required List<LocationEntity> locations,
}) async {
  final messenger = ScaffoldMessenger.of(context);

  final currentState = context.read<AnimalesBloc>().state;
  final animals = currentState is AnimalesLoaded
      ? currentState.animales
      : <AnimalEntity>[];
  final batches = _uniqueBatches(animals);

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

  final saved = await showModalBottomSheet<bool>(
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
                        'Asignar ubicación y lote',
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
                        (loc) => DropdownMenuItem(
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
                      label: const Text('Guardar asignación'),
                      onPressed: () {
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

                        context.read<AnimalesBloc>().add(
                          AssignAnimalLocationBatch(
                            uuid: animal.uuid,
                            locationId: selectedLocation,
                            batchId: batchName?.isEmpty == true
                                ? null
                                : batchName,
                          ),
                        );
                        Navigator.of(context).pop(true);
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

  if (saved == true) {
    messenger.showSnackBar(
      SnackBar(
        content: Text('Asignación actualizada para ${animal.earTagNumber}'),
      ),
    );
  }

  newBatchCtrl.dispose();
}

List<String> _uniqueBatches(List<AnimalEntity> animals) {
  final batches = animals
      .map((a) => a.batchId?.trim())
      .whereType<String>()
      .where((id) => id.isNotEmpty)
      .toSet()
      .toList();
  batches.sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));
  return batches;
}
