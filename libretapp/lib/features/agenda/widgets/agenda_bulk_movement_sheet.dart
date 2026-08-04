/// features › agenda › widgets › agenda_bulk_movement_sheet — bottom sheet
/// to move a pre-selected batch of animals (from an agenda "Movimiento de
/// lote" task) to a chosen location in one action.
library;

import 'package:flutter/material.dart';
import 'package:libretapp/core/di/injection.dart';
import 'package:libretapp/features/directorio/animales/domain/entities/animal_entity.dart';
import 'package:libretapp/features/directorio/animales/domain/repositories/movement_record_repository.dart';
import 'package:libretapp/features/directorio/animales/infrastructure/animal_repository.dart';
import 'package:libretapp/features/ubicaciones/domain/entities/location_entity.dart';
import 'package:libretapp/features/ubicaciones/domain/repositories/location_repository.dart';
import 'package:libretapp/features/ubicaciones/domain/services/location_animal_assignment_service.dart';
import 'package:libretapp/theme/app_theme.dart';

/// Returns true if the batch was moved, false/null if the user cancelled.
Future<bool?> showAgendaBulkMovementSheet(
  BuildContext context, {
  required List<AnimalEntity> animals,
}) async {
  final locations = await locator<LocationRepository>().getAll();
  if (!context.mounted) return null;

  LocationEntity? selected;
  var saving = false;

  return showModalBottomSheet<bool>(
    context: context,
    useRootNavigator: true,
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
                    children: [
                      const Icon(Icons.swap_horiz, color: AppColors.earth),
                      const SizedBox(width: 8),
                      Text(
                        'Mover ${animals.length} animales',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<LocationEntity>(
                    initialValue: selected,
                    decoration: const InputDecoration(
                      labelText: 'Ubicación destino',
                      border: OutlineInputBorder(),
                    ),
                    items: [
                      for (final loc in locations)
                        DropdownMenuItem(value: loc, child: Text(loc.name)),
                    ],
                    onChanged: (value) =>
                        setModalState(() => selected = value),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      icon: saving
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.check),
                      label: Text(saving ? 'Moviendo...' : 'Mover'),
                      onPressed: selected == null || saving
                          ? null
                          : () async {
                              setModalState(() => saving = true);
                              final service = LocationAnimalAssignmentService(
                                animalRepository: locator<AnimalRepository>(),
                                movementRepository:
                                    locator<MovementRecordRepository>(),
                              );
                              await service.assign(
                                location: selected!,
                                animals: animals,
                                selectedUuids: {
                                  for (final a in animals) a.uuid,
                                },
                              );
                              if (!context.mounted) return;
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
}
