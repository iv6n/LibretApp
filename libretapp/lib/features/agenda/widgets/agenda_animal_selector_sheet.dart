/// features › agenda › widgets › agenda_animal_selector_sheet — multi-select animals and/or lotes.
library;

import 'package:flutter/material.dart';
import 'package:libretapp/core/di/injection.dart';
import 'package:libretapp/features/directorio/animales/domain/entities/animal_entity.dart';
import 'package:libretapp/features/directorio/animales/infrastructure/animal_repository.dart';
import 'package:libretapp/features/directorio/lotes/domain/entities/lote_entity.dart';
import 'package:libretapp/features/directorio/lotes/infrastructure/lotes_repository.dart';

typedef AgendaSelectionResult = ({
  List<String> animalIds,
  List<String> loteIds,
});

/// Shows a bottom sheet with two tabs for selecting individual animals and/or lotes.
/// Returns a [AgendaSelectionResult] with the selected IDs, or null if dismissed.
Future<AgendaSelectionResult?> showAgendaAnimalSelector(
  BuildContext context, {
  List<String> initialAnimalIds = const [],
  List<String> initialLoteIds = const [],
}) async {
  return showModalBottomSheet<AgendaSelectionResult>(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (ctx) => _AgendaAnimalSelectorSheet(
      initialAnimalIds: initialAnimalIds,
      initialLoteIds: initialLoteIds,
    ),
  );
}

class _AgendaAnimalSelectorSheet extends StatefulWidget {
  const _AgendaAnimalSelectorSheet({
    required this.initialAnimalIds,
    required this.initialLoteIds,
  });

  final List<String> initialAnimalIds;
  final List<String> initialLoteIds;

  @override
  State<_AgendaAnimalSelectorSheet> createState() =>
      _AgendaAnimalSelectorSheetState();
}

class _AgendaAnimalSelectorSheetState extends State<_AgendaAnimalSelectorSheet>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  List<AnimalEntity> _animals = [];
  List<LoteEntity> _lotes = [];
  bool _loading = true;

  final _selectedAnimalIds = <String>{};
  final _selectedLoteIds = <String>{};
  String _animalSearchQuery = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _selectedAnimalIds.addAll(widget.initialAnimalIds);
    _selectedLoteIds.addAll(widget.initialLoteIds);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    final animalRepo = locator<AnimalRepository>();
    final lotesRepo = locator<LotesRepository>();
    final results = await Future.wait([
      animalRepo.getAll(),
      lotesRepo.getActiveLotes(),
    ]);
    if (!mounted) return;
    setState(() {
      _animals = results[0] as List<AnimalEntity>;
      _lotes = results[1] as List<LoteEntity>;
      _loading = false;
    });
  }

  String _animalLabel(AnimalEntity a) {
    final name = a.customName?.trim().isNotEmpty == true
        ? a.customName!
        : a.visualId?.trim().isNotEmpty == true
        ? a.visualId!
        : null;
    return name != null ? '$name (${a.earTagNumber})' : a.earTagNumber;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final totalSelected = _selectedAnimalIds.length + _selectedLoteIds.length;
    final screenHeight = MediaQuery.of(context).size.height;

    return SizedBox(
      height: screenHeight * 0.75,
      child: Column(
        children: [
          // Handle bar
          const SizedBox(height: 12),
          Center(
            child: Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: theme.colorScheme.onSurfaceVariant.withValues(
                  alpha: 0.4,
                ),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Text(
                  'Seleccionar animales',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const Spacer(),
                if (totalSelected > 0)
                  FilledButton.tonal(
                    onPressed: _confirm,
                    child: Text('Confirmar ($totalSelected)'),
                  )
                else
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Cancelar'),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          TabBar(
            controller: _tabController,
            tabs: [
              Tab(
                text: _selectedAnimalIds.isEmpty
                    ? 'Animales'
                    : 'Animales (${_selectedAnimalIds.length})',
              ),
              Tab(
                text: _selectedLoteIds.isEmpty
                    ? 'Lotes'
                    : 'Lotes (${_selectedLoteIds.length})',
              ),
            ],
          ),
          const Divider(height: 1),
          if (_loading)
            const Expanded(child: Center(child: CircularProgressIndicator()))
          else
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _AnimalsTab(
                    animals: _animals,
                    selected: _selectedAnimalIds,
                    searchQuery: _animalSearchQuery,
                    onSearchChanged: (q) =>
                        setState(() => _animalSearchQuery = q),
                    onToggle: (uuid) => setState(() {
                      if (_selectedAnimalIds.contains(uuid)) {
                        _selectedAnimalIds.remove(uuid);
                      } else {
                        _selectedAnimalIds.add(uuid);
                      }
                    }),
                    animalLabel: _animalLabel,
                  ),
                  _LotesTab(
                    lotes: _lotes,
                    selected: _selectedLoteIds,
                    onToggle: (uuid) => setState(() {
                      if (_selectedLoteIds.contains(uuid)) {
                        _selectedLoteIds.remove(uuid);
                      } else {
                        _selectedLoteIds.add(uuid);
                      }
                    }),
                  ),
                ],
              ),
            ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              child: SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: totalSelected > 0 ? _confirm : null,
                  child: Text(
                    totalSelected == 0
                        ? 'Selecciona al menos 1'
                        : 'Confirmar ($totalSelected seleccionados)',
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _confirm() {
    Navigator.of(context).pop<AgendaSelectionResult>((
      animalIds: _selectedAnimalIds.toList(),
      loteIds: _selectedLoteIds.toList(),
    ));
  }
}

class _AnimalsTab extends StatelessWidget {
  const _AnimalsTab({
    required this.animals,
    required this.selected,
    required this.searchQuery,
    required this.onSearchChanged,
    required this.onToggle,
    required this.animalLabel,
  });

  final List<AnimalEntity> animals;
  final Set<String> selected;
  final String searchQuery;
  final ValueChanged<String> onSearchChanged;
  final ValueChanged<String> onToggle;
  final String Function(AnimalEntity) animalLabel;

  @override
  Widget build(BuildContext context) {
    final filtered = searchQuery.isEmpty
        ? animals
        : animals.where((a) {
            final q = searchQuery.toLowerCase();
            return a.earTagNumber.toLowerCase().contains(q) ||
                (a.customName?.toLowerCase().contains(q) ?? false);
          }).toList();

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(12),
          child: TextField(
            decoration: InputDecoration(
              hintText: 'Buscar por arete o nombre',
              prefixIcon: const Icon(Icons.search),
              isDense: true,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onChanged: onSearchChanged,
          ),
        ),
        if (filtered.isEmpty)
          const Expanded(
            child: Center(child: Text('No se encontraron animales')),
          )
        else
          Expanded(
            child: ListView.builder(
              itemCount: filtered.length,
              itemBuilder: (context, i) {
                final animal = filtered[i];
                return CheckboxListTile(
                  value: selected.contains(animal.uuid),
                  onChanged: (_) => onToggle(animal.uuid),
                  title: Text(animalLabel(animal)),
                  subtitle: Text(
                    '${animal.category.name} · ${animal.sex.name}',
                  ),
                  dense: true,
                );
              },
            ),
          ),
      ],
    );
  }
}

class _LotesTab extends StatelessWidget {
  const _LotesTab({
    required this.lotes,
    required this.selected,
    required this.onToggle,
  });

  final List<LoteEntity> lotes;
  final Set<String> selected;
  final ValueChanged<String> onToggle;

  @override
  Widget build(BuildContext context) {
    if (lotes.isEmpty) {
      return const Center(
        child: Text('No hay lotes activos.\nCrea lotes en el Directorio.'),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: lotes.length,
      itemBuilder: (context, i) {
        final lote = lotes[i];
        return CheckboxListTile(
          value: selected.contains(lote.uuid),
          onChanged: (_) => onToggle(lote.uuid),
          title: Text(lote.nombre),
          subtitle: Text('${lote.animalUuids.length} animal(es)'),
          dense: true,
        );
      },
    );
  }
}
