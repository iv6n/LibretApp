/// features › registro › view › bulk_health_registro_page — standalone page for
/// applying a health record to multiple animals at once.
///
/// Flow:
///   Step 1 — Animal selection: searchable list with checkboxes + species filter chips.
///   Step 2 — Health form: fill in treatment details and save to all selected animals.
library;

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:libretapp/core/di/injection.dart';
import 'package:libretapp/features/directorio/animales/domain/animal_domain.dart';
import 'package:libretapp/features/directorio/animales/domain/repositories/health_record_repository.dart';
import 'package:libretapp/features/directorio/animales/infrastructure/animal_repository.dart';
import 'package:libretapp/l10n/app_localizations.dart';

class BulkHealthRegistroPage extends StatefulWidget {
  const BulkHealthRegistroPage({super.key});

  @override
  State<BulkHealthRegistroPage> createState() => _BulkHealthRegistroPageState();
}

class _BulkHealthRegistroPageState extends State<BulkHealthRegistroPage> {
  // ── step management ─────────────────────────────────────────────────────────
  int _step = 0; // 0 = select animals, 1 = health form

  // ── animal selection ─────────────────────────────────────────────────────────
  List<AnimalEntity> _allAnimals = [];
  List<AnimalEntity> _filtered = [];
  final Set<String> _selectedUuids = {};
  bool _loadingAnimals = true;
  final _searchCtrl = TextEditingController();
  Species? _speciesFilter;

  // ── health form ───────────────────────────────────────────────────────────────
  final _formKey = GlobalKey<FormState>();
  final _productCtrl = TextEditingController();
  final _doseCtrl = TextEditingController();
  final _appliedByCtrl = TextEditingController();
  final _causeCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();
  HealthRecordType _recordType = HealthRecordType.vaccine;
  DateTime _date = DateTime.now();
  DateTime? _nextDate;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _loadAnimals();
    _searchCtrl.addListener(_applyFilter);
  }

  @override
  void dispose() {
    _searchCtrl.removeListener(_applyFilter);
    _searchCtrl.dispose();
    _productCtrl.dispose();
    _doseCtrl.dispose();
    _appliedByCtrl.dispose();
    _causeCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadAnimals() async {
    final animals = await locator<AnimalRepository>().getAll();
    if (!mounted) return;
    setState(() {
      _allAnimals = animals;
      _filtered = animals;
      _loadingAnimals = false;
    });
  }

  void _applyFilter() {
    final q = _searchCtrl.text.toLowerCase();
    setState(() {
      _filtered = _allAnimals.where((a) {
        final matchesSearch =
            q.isEmpty ||
            a.earTagNumber.toLowerCase().contains(q) ||
            (a.customName?.toLowerCase().contains(q) ?? false) ||
            (a.visualId?.toLowerCase().contains(q) ?? false);
        final matchesSpecies =
            _speciesFilter == null || a.species == _speciesFilter;
        return matchesSearch && matchesSpecies;
      }).toList();
    });
  }

  void _setSpeciesFilter(Species? species) {
    setState(() => _speciesFilter = species);
    _applyFilter();
  }

  void _toggleAnimal(String uuid) {
    setState(() {
      if (_selectedUuids.contains(uuid)) {
        _selectedUuids.remove(uuid);
      } else {
        _selectedUuids.add(uuid);
      }
    });
  }

  void _toggleSelectAll() {
    final allVisibleSelected = _filtered.every(
      (a) => _selectedUuids.contains(a.uuid),
    );
    setState(() {
      if (allVisibleSelected) {
        for (final a in _filtered) {
          _selectedUuids.remove(a.uuid);
        }
      } else {
        for (final a in _filtered) {
          _selectedUuids.add(a.uuid);
        }
      }
    });
  }

  String _animalLabel(AnimalEntity a) {
    final parts = <String>[a.earTagNumber];
    if (a.customName != null && a.customName!.isNotEmpty) {
      parts.add(a.customName!);
    }
    return parts.join(' · ');
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate() || _saving) return;
    setState(() => _saving = true);

    final record = HealthRecord(
      date: _date,
      type: _recordType,
      product: _productCtrl.text.trim(),
      dose: _doseCtrl.text.trim().isEmpty ? null : _doseCtrl.text.trim(),
      appliedBy: _appliedByCtrl.text.trim().isEmpty
          ? null
          : _appliedByCtrl.text.trim(),
      cause: _causeCtrl.text.trim().isEmpty ? null : _causeCtrl.text.trim(),
      notes: _notesCtrl.text.trim().isEmpty ? null : _notesCtrl.text.trim(),
      nextDueDate: _nextDate,
    );

    try {
      await locator<HealthRecordRepository>().addHealthRecordToMultiple(
        _selectedUuids.toList(growable: false),
        record,
      );
      if (!mounted) return;
      Navigator.of(context).pop(true);
    } catch (e) {
      if (!mounted) return;
      setState(() => _saving = false);
      final l10n = AppLocalizations.of(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.animalFormRecordSaveError(e.toString()))),
      );
    }
  }

  // ── build ────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _step == 0
              ? 'Seleccionar animales'
              : 'Aplicar tratamiento (${_selectedUuids.length})',
        ),
        leading: _step == 1
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => setState(() => _step = 0),
              )
            : null,
      ),
      body: _step == 0 ? _buildSelectionStep() : _buildFormStep(),
      floatingActionButton:
          _step == 0 && MediaQuery.viewInsetsOf(context).bottom == 0
          ? FloatingActionButton.extended(
              onPressed: _selectedUuids.isEmpty
                  ? null
                  : () => setState(() => _step = 1),
              icon: const Icon(Icons.arrow_forward),
              label: Text('Continuar (${_selectedUuids.length})'),
              backgroundColor: _selectedUuids.isEmpty
                  ? Theme.of(context).colorScheme.surfaceContainerHighest
                  : null,
            )
          : null,
    );
  }

  // ── Step 1: animal selection ─────────────────────────────────────────────────

  Widget _buildSelectionStep() {
    if (_loadingAnimals) {
      return const Center(child: CircularProgressIndicator());
    }

    final allVisible =
        _filtered.isNotEmpty &&
        _filtered.every((a) => _selectedUuids.contains(a.uuid));
    final availableSpecies = _allAnimals.map((a) => a.species).toSet().toList()
      ..sort((a, b) => a.name.compareTo(b.name));

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
          child: TextField(
            controller: _searchCtrl,
            decoration: const InputDecoration(
              prefixIcon: Icon(Icons.search),
              hintText: 'Buscar por arete, nombre...',
              border: OutlineInputBorder(),
              isDense: true,
              contentPadding: EdgeInsets.symmetric(vertical: 10),
            ),
          ),
        ),
        if (availableSpecies.length > 1) ...[
          const SizedBox(height: 8),
          SizedBox(
            height: 36,
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              scrollDirection: Axis.horizontal,
              children: [
                Padding(
                  padding: const EdgeInsets.only(right: 6),
                  child: ChoiceChip(
                    label: const Text('Todos'),
                    selected: _speciesFilter == null,
                    onSelected: (_) => _setSpeciesFilter(null),
                  ),
                ),
                ...availableSpecies.map(
                  (s) => Padding(
                    padding: const EdgeInsets.only(right: 6),
                    child: ChoiceChip(
                      label: Text(s.displayName),
                      selected: _speciesFilter == s,
                      onSelected: (_) =>
                          _setSpeciesFilter(_speciesFilter == s ? null : s),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          child: Row(
            children: [
              Text(
                '${_filtered.length} animales',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const Spacer(),
              TextButton.icon(
                onPressed: _filtered.isEmpty ? null : _toggleSelectAll,
                icon: Icon(
                  allVisible ? Icons.deselect : Icons.select_all,
                  size: 18,
                ),
                label: Text(allVisible ? 'Deseleccionar' : 'Seleccionar todos'),
              ),
            ],
          ),
        ),
        const Divider(height: 1),
        Expanded(
          child: _filtered.isEmpty
              ? const Center(child: Text('Sin resultados'))
              : ListView.builder(
                  itemCount: _filtered.length,
                  itemBuilder: (context, index) {
                    final animal = _filtered[index];
                    final selected = _selectedUuids.contains(animal.uuid);
                    return CheckboxListTile(
                      value: selected,
                      onChanged: (_) => _toggleAnimal(animal.uuid),
                      title: Text(_animalLabel(animal)),
                      subtitle: Text(
                        '${animal.species.displayName} · ${animal.lifeStage.name}',
                      ),
                      secondary: CircleAvatar(
                        backgroundColor: selected
                            ? Theme.of(context).colorScheme.primaryContainer
                            : Theme.of(
                                context,
                              ).colorScheme.surfaceContainerHighest,
                        child: Icon(
                          Icons.pets,
                          size: 18,
                          color: selected
                              ? Theme.of(context).colorScheme.onPrimaryContainer
                              : Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                      controlAffinity: ListTileControlAffinity.leading,
                    );
                  },
                ),
        ),
        const SizedBox(height: 80), // space for FAB
      ],
    );
  }

  // ── Step 2: health form ──────────────────────────────────────────────────────

  Widget _buildFormStep() {
    final l10n = AppLocalizations.of(context);
    final colorScheme = Theme.of(context).colorScheme;

    return SafeArea(
      top: false,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // summary chip
              Wrap(
                spacing: 8,
                runSpacing: 4,
                children: [
                  Chip(
                    avatar: const Icon(Icons.pets, size: 16),
                    label: Text(
                      '${_selectedUuids.length} animales seleccionados',
                    ),
                    backgroundColor: colorScheme.secondaryContainer,
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // type
              DropdownButtonFormField<HealthRecordType>(
                initialValue: _recordType,
                decoration: InputDecoration(
                  labelText: l10n.detailFormHealthType,
                  border: const OutlineInputBorder(),
                ),
                items: HealthRecordType.values
                    .map(
                      (t) => DropdownMenuItem(
                        value: t,
                        child: Text(t.displayName),
                      ),
                    )
                    .toList(),
                onChanged: (v) {
                  if (v != null) setState(() => _recordType = v);
                },
              ),
              const SizedBox(height: 12),

              // product (required)
              TextFormField(
                controller: _productCtrl,
                autofocus: true,
                textCapitalization: TextCapitalization.sentences,
                decoration: InputDecoration(
                  labelText: l10n.detailFormHealthProduct,
                  border: const OutlineInputBorder(),
                ),
                validator: (v) => (v == null || v.trim().isEmpty)
                    ? l10n.detailFormHealthProductRequired
                    : null,
              ),
              const SizedBox(height: 12),

              // dose + applied by
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _doseCtrl,
                      decoration: InputDecoration(
                        labelText: l10n.detailFormHealthDose,
                        border: const OutlineInputBorder(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _appliedByCtrl,
                      decoration: InputDecoration(
                        labelText: l10n.detailFormHealthAppliedBy,
                        border: const OutlineInputBorder(),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // dates
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      icon: const Icon(Icons.today, size: 18),
                      label: Text(DateFormat('dd/MM/yyyy').format(_date)),
                      onPressed: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: _date,
                          firstDate: DateTime(_date.year - 5),
                          lastDate: DateTime(_date.year + 1),
                        );
                        if (picked != null) setState(() => _date = picked);
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                      icon: const Icon(Icons.event_available, size: 18),
                      label: Text(
                        _nextDate == null
                            ? l10n.detailFormHealthNext
                            : DateFormat('dd/MM/yyyy').format(_nextDate!),
                      ),
                      onPressed: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: _nextDate ?? _date,
                          firstDate: _date,
                          lastDate: DateTime(_date.year + 5),
                        );
                        if (picked != null) setState(() => _nextDate = picked);
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // cause
              TextFormField(
                controller: _causeCtrl,
                decoration: InputDecoration(
                  labelText: l10n.detailFormHealthCause,
                  border: const OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),

              // notes
              TextFormField(
                controller: _notesCtrl,
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: l10n.fieldNotes,
                  border: const OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),

              // save button
              SizedBox(
                width: double.infinity,
                height: 52,
                child: FilledButton.icon(
                  onPressed: _saving ? null : _save,
                  icon: _saving
                      ? const SizedBox(
                          height: 18,
                          width: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.check),
                  label: Text(
                    _saving
                        ? 'Guardando...'
                        : 'Guardar en ${_selectedUuids.length} animales',
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
