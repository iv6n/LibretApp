/// features \u203a registro \u203a widgets \u203a animal_selector \u2014 widget for selecting an animal from the directory.
library;

import 'package:flutter/material.dart';
import 'package:libretapp/core/core.dart';
import 'package:libretapp/features/directorio/animales/domain/animal_domain.dart';
import 'package:libretapp/features/directorio/animales/infrastructure/infrastructure.dart';

class AnimalSelector extends StatefulWidget {
  const AnimalSelector({
    required this.onSelected,
    this.selectedAnimal,
    this.label = 'Animal',
    this.eligible,
    super.key,
  });

  final ValueChanged<AnimalEntity?> onSelected;
  final AnimalEntity? selectedAnimal;

  /// Heading above the field, so the same widget can ask for a cow or a sire.
  final String label;

  /// Narrows the herd to the animals that make sense for the field — males of
  /// the same species when picking a sire, for instance. Null means the whole
  /// active herd.
  final bool Function(AnimalEntity)? eligible;

  @override
  State<AnimalSelector> createState() => _AnimalSelectorState();
}

class _AnimalSelectorState extends State<AnimalSelector> {
  final _searchCtrl = TextEditingController();
  List<AnimalEntity> _animals = [];
  List<AnimalEntity> _filtered = [];
  bool _loading = true;
  bool _expanded = false;

  @override
  void initState() {
    super.initState();
    _loadAnimals();
  }

  Future<void> _loadAnimals() async {
    final repo = locator<AnimalRepository>();
    final all = await repo.getAll();
    final eligible = widget.eligible;
    final animals = eligible == null ? all : all.where(eligible).toList();
    if (!mounted) return;
    setState(() {
      _animals = animals;
      _filtered = animals;
      _loading = false;
    });
  }

  void _filter(String query) {
    final q = query.toLowerCase();
    setState(() {
      _filtered = _animals.where((a) {
        return animalSearchPresentationText(a).toLowerCase().contains(q) ||
            a.earTagNumber.toLowerCase().contains(q) ||
            (a.visualId?.toLowerCase().contains(q) ?? false) ||
            (a.customName?.toLowerCase().contains(q) ?? false);
      }).toList();
    });
  }

  String _displayLabel(AnimalEntity animal) {
    final primary = primaryAnimalLabel(animal);
    final parts = <String>[primary];
    final earTag = animal.earTagNumber.trim();
    if (earTag.isEmpty) {
      parts.add(earTagDisplay(animal));
    } else if (earTag != primary) {
      parts.add(earTag);
    }
    if (animal.customName != null &&
        animal.customName!.isNotEmpty &&
        animal.customName != primary) {
      parts.add(animal.customName!);
    }
    if (animal.visualId != null &&
        animal.visualId!.isNotEmpty &&
        animal.visualId != primary) {
      parts.add('(${animal.visualId!})');
    }
    return parts.join(' · ');
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final selected = widget.selectedAnimal;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(widget.label, style: theme.textTheme.titleSmall),
        const SizedBox(height: 8),
        InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () => setState(() => _expanded = !_expanded),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
            decoration: BoxDecoration(
              border: Border.all(
                color: selected != null
                    ? theme.colorScheme.primary
                    : theme.colorScheme.outline,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(
                  selected != null ? Icons.pets : Icons.search,
                  size: 20,
                  color: selected != null
                      ? theme.colorScheme.primary
                      : theme.colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    selected != null
                        ? _displayLabel(selected)
                        : 'Seleccionar animal',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: selected != null
                          ? theme.colorScheme.onSurface
                          : theme.colorScheme.onSurfaceVariant,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Icon(
                  _expanded
                      ? Icons.keyboard_arrow_up
                      : Icons.keyboard_arrow_down,
                  size: 20,
                ),
              ],
            ),
          ),
        ),
        if (_expanded) ...[
          const SizedBox(height: 8),
          TextField(
            controller: _searchCtrl,
            decoration: InputDecoration(
              hintText: 'Buscar por arete, nombre o ID visual',
              prefixIcon: const Icon(Icons.search, size: 20),
              isDense: true,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 10,
              ),
            ),
            onChanged: _filter,
          ),
          const SizedBox(height: 4),
          ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: 200),
            child: _loading
                ? const Center(
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  )
                : _filtered.isEmpty
                ? const Padding(
                    padding: EdgeInsets.all(16),
                    child: Text('No se encontraron animales'),
                  )
                : ListView.builder(
                    shrinkWrap: true,
                    itemCount: _filtered.length,
                    itemBuilder: (context, index) {
                      final animal = _filtered[index];
                      final isSelected = selected?.uuid == animal.uuid;
                      return ListTile(
                        dense: true,
                        selected: isSelected,
                        leading: Icon(
                          Icons.pets,
                          size: 18,
                          color: isSelected ? theme.colorScheme.primary : null,
                        ),
                        title: Text(
                          _displayLabel(animal),
                          style: theme.textTheme.bodySmall,
                        ),
                        onTap: () {
                          widget.onSelected(animal);
                          setState(() {
                            _expanded = false;
                            _searchCtrl.clear();
                            _filtered = _animals;
                          });
                        },
                      );
                    },
                  ),
          ),
        ],
      ],
    );
  }
}
