/// features \u203a directorio \u203a animales \u203a widgets \u203a animal_batch_manager \u2014 manages batch operations on multiple animals.
library;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:libretapp/features/directorio/animales/bloc/animales_bloc.dart';
import 'package:libretapp/features/directorio/animales/bloc/animales_event.dart';
import 'package:libretapp/features/directorio/animales/domain/animal_domain.dart';

/// Shows a bottom sheet listing all batches with rename capability.
Future<void> showBatchManager(
  BuildContext context, {
  required List<AnimalEntity> animals,
}) async {
  final messenger = ScaffoldMessenger.of(context);
  final batches = _uniqueBatches(animals);
  if (batches.isEmpty) {
    messenger.showSnackBar(
      const SnackBar(content: Text('No hay lotes creados aún')),
    );
    return;
  }

  await showModalBottomSheet<void>(
    context: context,
    builder: (context) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.inventory_2_outlined),
                const SizedBox(width: 8),
                const Text(
                  'Lotes',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ...batches.map((batch) {
              final count = animals.where((a) => a.batchId == batch).length;
              return ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(batch),
                subtitle: Text('$count animales'),
                trailing: IconButton(
                  icon: const Icon(Icons.edit_outlined),
                  onPressed: () async {
                    final newName = await showDialog<String>(
                      context: context,
                      builder: (context) {
                        final ctrl = TextEditingController(text: batch);
                        return AlertDialog(
                          title: const Text('Renombrar lote'),
                          content: TextField(
                            controller: ctrl,
                            decoration: const InputDecoration(
                              labelText: 'Nuevo nombre',
                            ),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(),
                              child: const Text('Cancelar'),
                            ),
                            FilledButton(
                              onPressed: () {
                                final value = ctrl.text.trim();
                                if (value.isEmpty) return;
                                Navigator.of(context).pop(value);
                              },
                              child: const Text('Guardar'),
                            ),
                          ],
                        );
                      },
                    );

                    if (newName != null && newName.trim().isNotEmpty) {
                      if (!context.mounted) return;
                      context.read<AnimalesBloc>().add(
                        RenameBatch(
                          oldBatchId: batch,
                          newBatchId: newName.trim(),
                        ),
                      );
                      messenger.showSnackBar(
                        SnackBar(
                          content: Text(
                            'Lote "$batch" renombrado a "$newName"',
                          ),
                        ),
                      );
                    }
                  },
                ),
              );
            }),
          ],
        ),
      );
    },
  );
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
