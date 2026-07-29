/// features › directorio › animales › view › animal_edit_page — Direct animal edit form.
library;

import 'package:flutter/material.dart';
import 'package:libretapp/core/di/injection.dart';
import 'package:libretapp/features/directorio/animales/domain/animal_domain.dart';
import 'package:libretapp/features/directorio/animales/infrastructure/animal_repository.dart';

class AnimalEditPage extends StatefulWidget {
  const AnimalEditPage({super.key, required this.animalUuid});

  final String animalUuid;

  @override
  State<AnimalEditPage> createState() => _AnimalEditPageState();
}

class _AnimalEditPageState extends State<AnimalEditPage> {
  final _formKey = GlobalKey<FormState>();
  late final AnimalRepository _repository;

  final _earTagCtrl = TextEditingController();
  final _nameCtrl = TextEditingController();
  final _visualIdCtrl = TextEditingController();
  final _breedCtrl = TextEditingController();
  final _crossBreedCtrl = TextEditingController();
  final _weightCtrl = TextEditingController();
  final _coatColorCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();
  final _crossBreedTypeCtrl = TextEditingController();
  final _sireBreedCtrl = TextEditingController();
  final _damBreedCtrl = TextEditingController();
  final _bloodPercentageCtrl = TextEditingController();

  AnimalEntity? _animal;
  Species _species = Species.cattle;
  Category _category = Category.calf;
  Sex _sex = Sex.female;
  AnimalStatus _status = AnimalStatus.active;
  HealthStatus _healthStatus = HealthStatus.good;
  RiskLevel _riskLevel = RiskLevel.low;
  bool _underObservation = false;
  bool _requiresAttention = false;
  bool _loading = true;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _repository = locator<AnimalRepository>();
    _loadAnimal();
  }

  @override
  void dispose() {
    _earTagCtrl.dispose();
    _nameCtrl.dispose();
    _visualIdCtrl.dispose();
    _breedCtrl.dispose();
    _crossBreedCtrl.dispose();
    _weightCtrl.dispose();
    _coatColorCtrl.dispose();
    _notesCtrl.dispose();
    _crossBreedTypeCtrl.dispose();
    _sireBreedCtrl.dispose();
    _damBreedCtrl.dispose();
    _bloodPercentageCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadAnimal() async {
    try {
      final animal = await _repository.getByUuid(widget.animalUuid);
      if (!mounted) return;
      if (animal == null) {
        setState(() => _loading = false);
        _showMessage('No se encontro el animal para editar.');
        return;
      }

      _applyAnimal(animal);
      setState(() {
        _animal = animal;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _loading = false);
      _showMessage('No se pudo cargar el animal: $e');
    }
  }

  void _applyAnimal(AnimalEntity animal) {
    _earTagCtrl.text = animal.earTagNumber;
    _nameCtrl.text = animal.customName ?? '';
    _visualIdCtrl.text = animal.visualId ?? '';
    _breedCtrl.text = animal.breed;
    _crossBreedCtrl.text = animal.crossBreed ?? '';
    _weightCtrl.text = animal.weight?.toString() ?? '';
    _coatColorCtrl.text = animal.coatColor ?? '';
    _notesCtrl.text = animal.notes ?? '';
    _crossBreedTypeCtrl.text = animal.crossBreedType ?? '';
    _sireBreedCtrl.text = animal.sireBreed ?? '';
    _damBreedCtrl.text = animal.damBreed ?? '';
    _bloodPercentageCtrl.text = animal.bloodPercentage?.toString() ?? '';
    _species = animal.species;
    _category = animal.category;
    _sex = animal.sex;
    _status = animal.status;
    _healthStatus = animal.healthStatus;
    _riskLevel = animal.riskLevel;
    _underObservation = animal.underObservation;
    _requiresAttention = animal.requiresAttention;
  }

  Future<void> _save() async {
    final animal = _animal;
    if (animal == null || _saving) return;
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final earTag = _earTagCtrl.text.trim();
    if (earTag.isEmpty) {
      final confirmed = await _confirmMissingEarTag();
      if (!mounted || !confirmed) return;
    } else {
      final duplicated = await _isEarTagDuplicated(earTag);
      if (!mounted) return;
      if (duplicated) {
        _showMessage('El arete ya existe en otro registro.');
        return;
      }
    }

    final weight = _parseOptionalDouble(_weightCtrl.text);
    if (_weightCtrl.text.trim().isNotEmpty && weight == null) {
      _showMessage('Ingresa un peso valido.');
      return;
    }

    final bloodPercentage = _parseOptionalInt(_bloodPercentageCtrl.text);
    if (_bloodPercentageCtrl.text.trim().isNotEmpty &&
        bloodPercentage == null) {
      _showMessage('Ingresa un porcentaje de sangre valido.');
      return;
    }

    setState(() => _saving = true);
    try {
      final updated = animal.copyWith(
        earTagNumber: earTag,
        customName: _nullableText(_nameCtrl.text),
        visualId: _nullableText(_visualIdCtrl.text),
        species: _species,
        category: _category,
        sex: _sex,
        breed: _breedCtrl.text.trim(),
        crossBreed: _nullableText(_crossBreedCtrl.text),
        weight: weight,
        coatColor: _nullableText(_coatColorCtrl.text),
        notes: _nullableText(_notesCtrl.text),
        crossBreedType: _nullableText(_crossBreedTypeCtrl.text),
        sireBreed: _nullableText(_sireBreedCtrl.text),
        damBreed: _nullableText(_damBreedCtrl.text),
        bloodPercentage: bloodPercentage,
        status: _status,
        healthStatus: _healthStatus,
        riskLevel: _riskLevel,
        underObservation: _underObservation,
        requiresAttention: _requiresAttention,
        synced: false,
        lastUpdateDate: DateTime.now(),
      );

      await _repository.update(updated);
      if (!mounted) return;
      Navigator.of(context).pop(true);
    } catch (e) {
      if (!mounted) return;
      _showMessage('No se pudo actualizar el animal: $e');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<bool> _isEarTagDuplicated(String earTag) async {
    final normalized = earTag.trim();
    if (normalized.isEmpty) return false;
    final animals = await _repository.getAll();
    return animals.any(
      (animal) =>
          animal.uuid != widget.animalUuid &&
          animal.earTagNumber.trim() == normalized,
    );
  }

  @override
  Widget build(BuildContext context) {
    final title = _animal == null
        ? 'Editar animal'
        : 'Editar ${primaryAnimalLabel(_animal!)}';

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        actions: [
          TextButton(
            onPressed: _saving || _loading ? null : _save,
            child: _saving
                ? const SizedBox.square(
                    dimension: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Guardar'),
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _animal == null
          ? const Center(child: Text('Animal no encontrado.'))
          : Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
                children: [
                  const _SectionHeader(
                    title: 'Identificacion',
                    icon: Icons.badge_outlined,
                  ),
                  TextFormField(
                    controller: _earTagCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Arete / Identificacion',
                      helperText:
                          'Recomendado para identificar y buscar al animal.',
                      prefixIcon: Icon(Icons.sell_outlined),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _nameCtrl,
                    textCapitalization: TextCapitalization.words,
                    decoration: const InputDecoration(
                      labelText: 'Nombre o alias',
                      prefixIcon: Icon(Icons.drive_file_rename_outline),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _visualIdCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Numero arete visual / ID visible',
                      prefixIcon: Icon(Icons.remove_red_eye_outlined),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const _SectionHeader(
                    title: 'Perfil productivo',
                    icon: Icons.insights_outlined,
                  ),
                  _EnumField<Species>(
                    label: 'Especie',
                    value: _species,
                    values: Species.values,
                    labelFor: (value) => value.displayName,
                    onChanged: (value) => setState(() => _species = value),
                  ),
                  const SizedBox(height: 12),
                  _EnumField<Category>(
                    label: 'Categoria',
                    value: _category,
                    values: Category.values,
                    labelFor: (value) => value.displayName,
                    onChanged: (value) => setState(() => _category = value),
                  ),
                  const SizedBox(height: 12),
                  _EnumField<Sex>(
                    label: 'Sexo',
                    value: _sex,
                    values: Sex.values,
                    labelFor: (value) => value.displayName,
                    onChanged: (value) => setState(() => _sex = value),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _breedCtrl,
                    textCapitalization: TextCapitalization.words,
                    decoration: const InputDecoration(
                      labelText: 'Raza',
                      prefixIcon: Icon(Icons.biotech_outlined),
                    ),
                    validator: (value) =>
                        (value ?? '').trim().isEmpty ? 'Ingresa la raza' : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _crossBreedCtrl,
                    textCapitalization: TextCapitalization.words,
                    decoration: const InputDecoration(
                      labelText: 'Cruza / segunda raza',
                      prefixIcon: Icon(Icons.merge_type_outlined),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _weightCtrl,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    decoration: const InputDecoration(
                      labelText: 'Peso actual (kg)',
                      prefixIcon: Icon(Icons.monitor_weight_outlined),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const _SectionHeader(
                    title: 'Genetica y observaciones',
                    icon: Icons.hub_outlined,
                  ),
                  TextFormField(
                    controller: _crossBreedTypeCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Tipo de cruza',
                      prefixIcon: Icon(Icons.account_tree_outlined),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _sireBreedCtrl,
                          decoration: const InputDecoration(
                            labelText: 'Raza padre',
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextFormField(
                          controller: _damBreedCtrl,
                          decoration: const InputDecoration(
                            labelText: 'Raza madre',
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _bloodPercentageCtrl,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Porcentaje de sangre',
                      prefixIcon: Icon(Icons.percent_outlined),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _coatColorCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Color / pelaje',
                      prefixIcon: Icon(Icons.palette_outlined),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _notesCtrl,
                    minLines: 3,
                    maxLines: 5,
                    decoration: const InputDecoration(
                      labelText: 'Notas',
                      prefixIcon: Icon(Icons.notes_outlined),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const _SectionHeader(
                    title: 'Estado',
                    icon: Icons.health_and_safety_outlined,
                  ),
                  _EnumField<AnimalStatus>(
                    label: 'Estado',
                    value: _status,
                    values: AnimalStatus.values,
                    labelFor: (value) => value.displayName,
                    onChanged: (value) => setState(() => _status = value),
                  ),
                  const SizedBox(height: 12),
                  _EnumField<HealthStatus>(
                    label: 'Salud',
                    value: _healthStatus,
                    values: HealthStatus.values,
                    labelFor: (value) => value.displayName,
                    onChanged: (value) => setState(() => _healthStatus = value),
                  ),
                  const SizedBox(height: 12),
                  _EnumField<RiskLevel>(
                    label: 'Riesgo',
                    value: _riskLevel,
                    values: RiskLevel.values,
                    labelFor: (value) => value.displayName,
                    onChanged: (value) => setState(() => _riskLevel = value),
                  ),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('En observacion'),
                    value: _underObservation,
                    onChanged: (value) =>
                        setState(() => _underObservation = value),
                  ),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Requiere atencion'),
                    value: _requiresAttention,
                    onChanged: (value) =>
                        setState(() => _requiresAttention = value),
                  ),
                  const SizedBox(height: 24),
                  FilledButton.icon(
                    onPressed: _saving ? null : _save,
                    icon: const Icon(Icons.save_outlined),
                    label: const Text('Guardar cambios'),
                  ),
                ],
              ),
            ),
    );
  }

  double? _parseOptionalDouble(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) return null;
    return double.tryParse(trimmed.replaceAll(',', '.'));
  }

  int? _parseOptionalInt(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) return null;
    return int.tryParse(trimmed);
  }

  String? _nullableText(String value) {
    final normalized = value.trim();
    return normalized.isEmpty ? null : normalized;
  }

  Future<bool> _confirmMissingEarTag() async {
    final result = await showDialog<bool>(
      context: context,
      useRootNavigator: true,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Arete recomendado'),
        content: const Text(
          'El arete es recomendado para identificar y buscar al animal. Puedes continuar sin arete y agregarlo despues.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Continuar sin arete'),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, required this.icon});

  final String title;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, color: colorScheme.primary),
          const SizedBox(width: 8),
          Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _EnumField<T> extends StatelessWidget {
  const _EnumField({
    required this.label,
    required this.value,
    required this.values,
    required this.labelFor,
    required this.onChanged,
  });

  final String label;
  final T value;
  final List<T> values;
  final String Function(T value) labelFor;
  final ValueChanged<T> onChanged;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<T>(
      initialValue: value,
      decoration: InputDecoration(labelText: label),
      items: values
          .map(
            (item) => DropdownMenuItem<T>(
              value: item,
              child: Text(labelFor(item)),
            ),
          )
          .toList(),
      onChanged: (item) {
        if (item != null) onChanged(item);
      },
    );
  }
}
