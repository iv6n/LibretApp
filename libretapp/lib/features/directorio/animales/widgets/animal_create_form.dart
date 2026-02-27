import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:libretapp/core/di/injection.dart';
import 'package:libretapp/features/directorio/animales/bloc/animales_bloc.dart';
import 'package:libretapp/features/directorio/animales/bloc/animales_event.dart';
import 'package:libretapp/features/directorio/animales/domain/animal_domain.dart';
import 'package:libretapp/features/directorio/lotes/domain/entities/lote_entity.dart';
import 'package:libretapp/features/directorio/animales/domain/enums/production_stage.dart';
import 'package:libretapp/features/directorio/animales/domain/enums/production_system.dart';
import 'package:libretapp/features/directorio/animales/domain/services/animal_lifecycle_calculator.dart';
import 'package:libretapp/features/directorio/lotes/infrastructure/lotes_repository.dart';
import 'package:libretapp/features/ubicaciones/domain/entities/location_entity.dart';

/// Shows a bottom sheet form to create a new animal.
Future<void> showCreateAnimalSheet(
  BuildContext context, {
  required List<LocationEntity> locations,
  required String Function() generateUuid,
  required Future<void> Function() onLocationsRefresh,
  LotesRepository? lotesRepository,
}) async {
  await onLocationsRefresh();
  if (!context.mounted) return;
  final messenger = ScaffoldMessenger.of(context);

  final earTagCtrl = TextEditingController();
  final customNameCtrl = TextEditingController();
  final breedCtrl = TextEditingController();
  final ownerCtrl = TextEditingController();
  final purchaseCtrl = TextEditingController();
  final weightCtrl = TextEditingController();

  var species = Species.cattle;
  var category = Category.values.first;
  var sex = Sex.values.first;
  var status = AnimalStatus.values.first;
  var birthDate = DateTime.now();
  String? selectedLocationId;
  String? selectedBatchUuid;

  final loteRepository = lotesRepository ?? locator<LotesRepository>();

  // Load available batches
  List<LoteEntity> availableLotes = [];
  try {
    availableLotes = await loteRepository.getActiveLotes();
  } catch (e) {
    if (context.mounted) {
      messenger.showSnackBar(
        SnackBar(content: Text('Error al cargar lotes: $e')),
      );
    }
  }

  if (!context.mounted) return;

  await showModalBottomSheet<void>(
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
                      Icon(Icons.pets, color: Colors.green),
                      SizedBox(width: 8),
                      Text(
                        'Agregar animal',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: earTagCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Arete',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: customNameCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Nombre o ID visual',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: breedCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Raza',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<Species>(
                          initialValue: species,
                          decoration: const InputDecoration(
                            labelText: 'Especie',
                            border: OutlineInputBorder(),
                          ),
                          items: Species.values
                              .map(
                                (s) => DropdownMenuItem(
                                  value: s,
                                  child: Text(s.displayName),
                                ),
                              )
                              .toList(),
                          onChanged: (value) {
                            if (value != null) {
                              setModalState(() => species = value);
                            }
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: DropdownButtonFormField<Category>(
                          initialValue: category,
                          decoration: const InputDecoration(
                            labelText: 'Categoría',
                            border: OutlineInputBorder(),
                          ),
                          items: Category.values
                              .map(
                                (c) => DropdownMenuItem(
                                  value: c,
                                  child: Text(c.displayName),
                                ),
                              )
                              .toList(),
                          onChanged: (value) {
                            if (value != null) {
                              setModalState(() => category = value);
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<Sex>(
                          initialValue: sex,
                          decoration: const InputDecoration(
                            labelText: 'Sexo',
                            border: OutlineInputBorder(),
                          ),
                          items: Sex.values
                              .map(
                                (s) => DropdownMenuItem(
                                  value: s,
                                  child: Text(s.displayName),
                                ),
                              )
                              .toList(),
                          onChanged: (value) {
                            if (value != null) {
                              setModalState(() => sex = value);
                            }
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: DropdownButtonFormField<AnimalStatus>(
                          initialValue: status,
                          decoration: const InputDecoration(
                            labelText: 'Estado',
                            border: OutlineInputBorder(),
                          ),
                          items: AnimalStatus.values
                              .map(
                                (s) => DropdownMenuItem(
                                  value: s,
                                  child: Text(s.displayName),
                                ),
                              )
                              .toList(),
                          onChanged: (value) {
                            if (value != null) {
                              setModalState(() => status = value);
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          icon: const Icon(Icons.today),
                          label: Text(
                            '${birthDate.year}-${birthDate.month.toString().padLeft(2, '0')}-${birthDate.day.toString().padLeft(2, '0')}',
                          ),
                          onPressed: () async {
                            final picked = await showDatePicker(
                              context: context,
                              initialDate: birthDate,
                              firstDate: DateTime(1990),
                              lastDate: DateTime.now(),
                            );
                            if (picked != null) {
                              setModalState(() => birthDate = picked);
                            }
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextField(
                          controller: weightCtrl,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: 'Peso (kg) opcional',
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: ownerCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Propietario',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: purchaseCtrl,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: 'Precio de compra',
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: DropdownButtonFormField<String?>(
                          initialValue: selectedLocationId,
                          decoration: const InputDecoration(
                            labelText: 'Ubicación',
                            border: OutlineInputBorder(),
                          ),
                          items: [
                            const DropdownMenuItem(
                              value: null,
                              child: Text('Sin ubicación'),
                            ),
                            ...locations.map(
                              (loc) => DropdownMenuItem(
                                value: loc.uuid,
                                child: Text(loc.name),
                              ),
                            ),
                          ],
                          onChanged: (value) =>
                              setModalState(() => selectedLocationId = value),
                        ),
                      ),
                    ],
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
                    onChanged: (value) =>
                        setModalState(() => selectedBatchUuid = value),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.save),
                      label: const Text('Guardar animal'),
                      onPressed: () {
                        final earTag = earTagCtrl.text.trim();
                        final breed = breedCtrl.text.trim();
                        if (earTag.isEmpty || breed.isEmpty) {
                          messenger.showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Completa arete e información básica',
                              ),
                            ),
                          );
                          return;
                        }

                        final lifecycle = AnimalLifecycleCalculator.calculate(
                          birthDate: birthDate,
                          species: species,
                          sex: sex,
                        );

                        final now = DateTime.now();
                        final animal = AnimalEntity(
                          id: null,
                          uuid: generateUuid(),
                          earTagNumber: earTag,
                          customName: customNameCtrl.text.trim().isEmpty
                              ? null
                              : customNameCtrl.text.trim(),
                          visualId: customNameCtrl.text.trim().isEmpty
                              ? null
                              : customNameCtrl.text.trim(),
                          brand: null,
                          rfidTag: null,
                          species: species,
                          category: category,
                          lifeStage: lifecycle.lifeStage,
                          sex: sex,
                          breed: breed,
                          birthDate: birthDate,
                          ageMonths: lifecycle.ageMonths,
                          weight: double.tryParse(weightCtrl.text.trim()),
                          sireUuid: null,
                          damUuid: null,
                          generation: 1,
                          healthStatus: HealthStatus.good,
                          bodyConditionScore: null,
                          vaccinated: false,
                          dewormed: false,
                          hasVitamins: false,
                          hasChronicIssues: false,
                          chronicNotes: null,
                          reproductiveStatus: ReproductiveStatus.unknown,
                          firstServiceDate: null,
                          lastServiceDate: null,
                          expectedCalvingDate: null,
                          productionPurpose: ProductionPurpose.undefined,
                          productionStage: ProductionStage.unknown,
                          productionSystem: ProductionSystem.unknown,
                          feedType: null,
                          dailyGainEstimate: null,
                          currentPaddockId: selectedLocationId,
                          initialLocationId: selectedLocationId,
                          lastMovementDate: now,
                          underObservation: false,
                          requiresAttention: false,
                          riskLevel: RiskLevel.low,
                          profilePhoto: null,
                          gallery: const [],
                          owner: ownerCtrl.text.trim().isEmpty
                              ? null
                              : ownerCtrl.text.trim(),
                          purchasePrice: purchaseCtrl.text.trim().isEmpty
                              ? null
                              : double.tryParse(purchaseCtrl.text.trim()),
                          status: status,
                          synced: false,
                          remoteId: null,
                          syncDate: null,
                          contentHash: null,
                          creationDate: now,
                          lastUpdateDate: now,
                          batchUuid: selectedBatchUuid,
                        );

                        context.read<AnimalesBloc>().add(AddAnimal(animal));
                        Navigator.of(context).pop();
                        messenger.showSnackBar(
                          const SnackBar(content: Text('Animal creado')),
                        );
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

  earTagCtrl.dispose();
  customNameCtrl.dispose();
  breedCtrl.dispose();
  ownerCtrl.dispose();
  purchaseCtrl.dispose();
  weightCtrl.dispose();
}
