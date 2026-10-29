library;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:libretapp/app/widgets/app_bottom_sheet.dart';
import 'package:libretapp/core/di/injection.dart';
import 'package:libretapp/core/router/app_routes.dart';
import '../domain/animal_domain.dart';
import '../domain/repositories/reproduction_record_repository.dart';
import '../infrastructure/animal_repository.dart';

/// The calving is already durable. Cancelling leaves it available for later linking.
Future<void> editOffspring(
  BuildContext context,
  AnimalEntity dam,
  ReproductionRecord record,
) async {
  final action = await showDialog<String>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: const Text('Parto registrado'),
      content: const Text(
        'Puedes registrar una cría nueva o vincular una que ya existe. Su padre y madre quedarán enlazados.',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(dialogContext),
          child: const Text('Más tarde'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(dialogContext, 'existing'),
          child: const Text('Vincular cría existente'),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(dialogContext, 'new'),
          child: const Text('Registrar cría'),
        ),
      ],
    ),
  );
  if (!context.mounted || action == null) return;
  try {
    String? calfUuid;
    if (action == 'new') {
      final result = await context.pushNamed(
        AppRoutes.nameAnimalNuevo,
        extra: AnimalRegistrationSeed(
          species: dam.species,
          sex: Sex.female,
          ageMonths: 0,
          breed: dam.breed,
          damUuid: dam.uuid,
          sireUuid: record.maleSireUuid,
          birthDate: record.actualCalvingDate,
        ),
      );
      if (result is String) calfUuid = result;
    } else {
      final animals = await locator<AnimalRepository>().getAll();
      if (!context.mounted) return;
      final eligible = animals
          .where(
            (a) =>
                a.uuid != dam.uuid &&
                a.uuid != record.maleSireUuid &&
                a.species == dam.species &&
                (a.damUuid == null || a.damUuid == dam.uuid) &&
                !record.offspringUuids.contains(a.uuid),
          )
          .toList();
      calfUuid = await showAppBottomSheet<String>(
        context: context,
        useSafeArea: true,
        showDragHandle: true,
        isScrollControlled: true,
        builder: (sheetContext) => SizedBox(
          height: MediaQuery.sizeOf(sheetContext).height * .65,
          child: ListView(
            children: [
              const ListTile(title: Text('Vincular cría existente')),
              if (eligible.isEmpty)
                const ListTile(title: Text('No hay crías compatibles.')),
              for (final calf in eligible)
                ListTile(
                  title: Text(primaryAnimalLabel(calf)),
                  subtitle: Text(
                    'Nacimiento: ${formatDateForCalf(calf.birthDate)}',
                  ),
                  onTap: () => Navigator.pop(sheetContext, calf.uuid),
                ),
            ],
          ),
        ),
      );
    }
    if (!context.mounted || calfUuid == null || record.id == null) return;
    final repo = locator<ReproductionRecordRepository>();
    if (repo is! ReproductionOffspringLinker)
      throw UnsupportedError('Este almacenamiento no permite vincular crías.');
    await (repo as ReproductionOffspringLinker).linkOffspring(
      dam.uuid,
      record.id!,
      calfUuid,
    );
    if (context.mounted)
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Cría vinculada.')));
  } catch (error) {
    if (context.mounted)
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'El parto está guardado. No se pudo vincular la cría: $error',
          ),
        ),
      );
  }
}

String formatDateForCalf(DateTime date) =>
    '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
