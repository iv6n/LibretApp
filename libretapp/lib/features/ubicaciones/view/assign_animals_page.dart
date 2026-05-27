/// features › ubicaciones › view › assign_animals_page — page for assigning animals to a location.
library;

import 'package:flutter/material.dart';
import 'package:libretapp/features/directorio/animales/domain/entities/animal_entity.dart';
import 'package:libretapp/features/ubicaciones/domain/entities/location_entity.dart';

class AssignAnimalsPage extends StatefulWidget {
  const AssignAnimalsPage({
    super.key,
    required this.allAnimals,
    required this.initiallySelected,
    required this.locationName,
    required this.allLocations,
  });

  final List<AnimalEntity> allAnimals;
  final Set<String> initiallySelected;
  final String locationName;
  final List<LocationEntity> allLocations;

  @override
  State<AssignAnimalsPage> createState() => _AssignAnimalsPageState();
}

class _AssignAnimalsPageState extends State<AssignAnimalsPage> {
  late final Set<String> _selected = Set<String>.from(widget.initiallySelected);

  @override
  Widget build(BuildContext context) {
    final animals = widget.allAnimals;
    return Scaffold(
      appBar: AppBar(title: Text('Asignar animales a ${widget.locationName}')),
      body: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: ListView.separated(
                  itemCount: animals.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final animal = animals[index];
                    final checked = _selected.contains(animal.uuid);
                    final currentLocId =
                        animal.currentPaddockId ?? animal.initialLocationId;
                    final currentLocName = currentLocId != null
                        ? widget.allLocations
                              .where((l) => l.uuid == currentLocId)
                              .map((l) => l.name)
                              .firstOrNull
                        : null;
                    return CheckboxListTile(
                      value: checked,
                      title: Text(_animalTitle(animal)),
                      subtitle: Text(
                        currentLocName != null
                            ? 'Ubicación actual: $currentLocName'
                            : animal.breed.isNotEmpty
                            ? '${animal.breed} • ${animal.species.displayName}'
                            : animal.species.displayName,
                      ),
                      onChanged: (value) {
                        setState(() {
                          if (value == true) {
                            _selected.add(animal.uuid);
                          } else {
                            _selected.remove(animal.uuid);
                          }
                        });
                      },
                    );
                  },
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  icon: const Icon(Icons.save_outlined),
                  label: const Text('Guardar'),
                  onPressed: () => Navigator.of(context).pop(_selected),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _animalTitle(AnimalEntity animal) {
    return animal.earTagNumber.isNotEmpty
        ? animal.earTagNumber
        : (animal.visualId?.isNotEmpty == true ? animal.visualId! : 'Animal');
  }
}
