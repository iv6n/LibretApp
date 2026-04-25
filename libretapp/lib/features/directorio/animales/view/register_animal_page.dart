import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:libretapp/app/widgets/widgets.dart';
import 'package:libretapp/core/di/injection.dart';
import 'package:libretapp/core/services/prefs_keys.dart';
import 'package:libretapp/core/services/shared_prefs_service.dart';
import 'package:libretapp/features/directorio/animales/domain/animal_domain.dart';
import 'package:libretapp/features/directorio/animales/domain/enums/production_stage.dart';
import 'package:libretapp/features/directorio/animales/domain/enums/production_system.dart';
import 'package:libretapp/features/directorio/animales/domain/services/animal_lifecycle_calculator.dart';
import 'package:libretapp/features/directorio/animales/infrastructure/animal_repository.dart';
import 'package:libretapp/features/directorio/lotes/domain/entities/lote_entity.dart';
import 'package:libretapp/features/directorio/lotes/infrastructure/lotes_repository.dart';
import 'package:libretapp/features/ubicaciones/domain/entities/location_entity.dart';
import 'package:libretapp/features/ubicaciones/domain/enums/location_type.dart';
import 'package:libretapp/features/ubicaciones/domain/repositories/location_repository.dart';

class RegisterAnimalPage extends StatefulWidget {
  const RegisterAnimalPage({super.key});

  @override
  State<RegisterAnimalPage> createState() => _RegisterAnimalPageState();
}

class _RegisterAnimalPageState extends State<RegisterAnimalPage> {
  static const _stepLabels = <String>[
    'Información básica',
    'Origen',
    'Ubicación/ manejo',
    'Salud',
    'Revisión',
  ];

  static const _cattleOnlyCategories = <Category>{
    Category.calf,
    Category.heifer,
    Category.steer,
    Category.cow,
    Category.bull,
    Category.oxen,
    Category.weaned,
  };

  final _step1FormKey = GlobalKey<FormState>();

  late final AnimalRepository _animalRepository;
  late final LotesRepository _lotesRepository;
  late final LocationRepository _locationRepository;
  late final SharedPrefsService _sharedPrefsService;

  final _earTagCtrl = TextEditingController();
  final _nameCtrl = TextEditingController();
  final _breedCtrl = TextEditingController();
  final _crossBreedCtrl = TextEditingController();
  final _coatColorCtrl = TextEditingController();
  final _weightCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();

  final _crossBreedTypeCtrl = TextEditingController();
  final _feedTypeCtrl = TextEditingController();
  final _sireBreedCtrl = TextEditingController();
  final _damBreedCtrl = TextEditingController();
  final _bloodPercentageCtrl = TextEditingController();
  final _genealogicalRegistryCtrl = TextEditingController();
  final _originNotesCtrl = TextEditingController();

  final _approximateDensityCtrl = TextEditingController();
  final _locationNotesCtrl = TextEditingController();
  final _feedNotesCtrl = TextEditingController();
  final _visualIdCtrl = TextEditingController();
  final _distinguishingMarksCtrl = TextEditingController();
  final _healthNotesCtrl = TextEditingController();

  int _currentStep = 0;
  bool _loading = true;
  bool _saving = false;

  Species _species = Species.cattle;
  Category _category = Category.calf;
  Sex _sex = Sex.female;
  AnimalStatus _status = AnimalStatus.active;
  DateTime? _birthDate;
  DateTime _registrationDate = DateTime.now();

  OriginType _originType = OriginType.own;
  String? _selectedProvenanceUuid;
  String? _selectedDamUuid;
  String? _selectedSireUuid;

  String? _selectedRanchUuid;
  String? _selectedPaddockUuid;
  String? _selectedBatchUuid;
  ProductionSystem _productionSystem = ProductionSystem.rotational;
  String _housingType = 'Libre en potrero';
  String _shadingAvailability = 'Parcial';
  String _waterSource = 'Bebedero automatico';
  String _feedFrequency = '2 veces al dia';
  String _feedSupplements = 'Sal mineral';
  String _earTagColor = 'Amarillo';

  _InitialHealthMode _healthMode = _InitialHealthMode.healthy;
  int _bodyConditionScore = 3;

  List<LocationEntity> _locations = const [];
  List<LoteEntity> _lotes = const [];
  List<AnimalEntity> _animals = const [];

  final List<_RecordDraft> _treatments = [];
  final List<_RecordDraft> _vaccinations = [];
  final List<_RecordDraft> _exams = [];

  @override
  void initState() {
    super.initState();
    _animalRepository = locator<AnimalRepository>();
    _lotesRepository = locator<LotesRepository>();
    _locationRepository = locator<LocationRepository>();
    _sharedPrefsService = locator<SharedPrefsService>();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final results = await Future.wait([
        _locationRepository.getAll(),
        _lotesRepository.getAll(),
        _animalRepository.getAll(),
      ]);

      if (!mounted) return;
      setState(() {
        _locations = results[0] as List<LocationEntity>;
        _lotes = results[1] as List<LoteEntity>;
        _animals = results[2] as List<AnimalEntity>;
        _selectedProvenanceUuid = _firstRanch?.uuid;
        _selectedRanchUuid = _firstRanch?.uuid;
        _selectedPaddockUuid = _paddocksForSelectedRanch.isNotEmpty
            ? _paddocksForSelectedRanch.first.uuid
            : null;
        _loading = false;
      });
      await _promptRestoreDraft();
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _loading = false;
      });
      _showMessage('No se pudo cargar la informacion para el registro.');
    }
  }

  @override
  void dispose() {
    _earTagCtrl.dispose();
    _nameCtrl.dispose();
    _breedCtrl.dispose();
    _crossBreedCtrl.dispose();
    _coatColorCtrl.dispose();
    _weightCtrl.dispose();
    _notesCtrl.dispose();
    _crossBreedTypeCtrl.dispose();
    _feedTypeCtrl.dispose();
    _sireBreedCtrl.dispose();
    _damBreedCtrl.dispose();
    _bloodPercentageCtrl.dispose();
    _genealogicalRegistryCtrl.dispose();
    _originNotesCtrl.dispose();
    _approximateDensityCtrl.dispose();
    _locationNotesCtrl.dispose();
    _feedNotesCtrl.dispose();
    _visualIdCtrl.dispose();
    _distinguishingMarksCtrl.dispose();
    _healthNotesCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ShellChromeScope(
      visible: false,
      child: PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, _) {
          if (didPop) return;
          _onAttemptExit();
        },
        child: Scaffold(
          appBar: AppBar(
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: _onAttemptExit,
            ),
            title: const Text('Registrar nuevo animal'),
            actions: [
              TextButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.help_outline),
                label: const Text('Ayuda'),
              ),
            ],
          ),
          body: _loading
              ? const Center(child: CircularProgressIndicator())
              : SafeArea(
                  child: Column(
                    children: [
                      _buildStepper(),
                      Expanded(
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                          child: _buildCurrentStep(),
                        ),
                      ),
                      _buildBottomBar(),
                    ],
                  ),
                ),
        ),
      ),
    );
  }

  Widget _buildStepper() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: Column(
        children: [
          Row(
            children: List.generate(_stepLabels.length * 2 - 1, (index) {
              if (index.isOdd) {
                final connectorIndex = index ~/ 2;
                final done = connectorIndex < _currentStep;
                return Expanded(
                  child: Container(
                    height: 2,
                    color: done
                        ? colorScheme.primary
                        : colorScheme.outline.withValues(alpha: 0.4),
                  ),
                );
              }

              final stepIndex = index ~/ 2;
              final completed = stepIndex < _currentStep;
              final active = stepIndex == _currentStep;

              return Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: completed || active
                      ? colorScheme.primary
                      : colorScheme.surfaceContainerHighest,
                  border: Border.all(
                    color: completed || active
                        ? colorScheme.primary
                        : colorScheme.outline.withValues(alpha: 0.5),
                  ),
                ),
                child: Center(
                  child: completed
                      ? const Icon(Icons.check, color: Colors.white, size: 16)
                      : Text(
                          '${stepIndex + 1}',
                          style: theme.textTheme.labelMedium?.copyWith(
                            color: active
                                ? Colors.white
                                : colorScheme.onSurfaceVariant,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                ),
              );
            }),
          ),
          const SizedBox(height: 10),
          Row(
            children: List.generate(_stepLabels.length, (index) {
              final selected = index == _currentStep;
              return Expanded(
                child: Text(
                  _stepLabels[index],
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                    color: selected ? colorScheme.primary : null,
                    fontSize: 10,
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentStep() {
    switch (_currentStep) {
      case 0:
        return _buildStep1();
      case 1:
        return _buildStep2();
      case 2:
        return _buildStep3();
      case 3:
        return _buildStep4();
      default:
        return _buildStep5();
    }
  }

  Widget _buildStep1() {
    final theme = Theme.of(context);
    return Form(
      key: _step1FormKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle(
            'Información básica',
            Icons.badge_outlined,
            subtitle: 'Ingresá los datos generales del animal.',
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextFormField(
                    controller: _earTagCtrl,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Arete / Identificación',
                      hintText: '00 23 5132 1842',
                      helperText: 'cada animal debe tener un arete único.',
                      suffixIcon: Icon(Icons.qr_code_scanner_outlined),
                    ),
                    validator: (value) {
                      if ((value ?? '').trim().isEmpty) {
                        return 'Ingresa el arete';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _nameCtrl,
                    textCapitalization: TextCapitalization.words,
                    decoration: const InputDecoration(
                      labelText: 'Nombre o alias',
                      hintText: 'Ej. Manchas, Estrella, etc.',
                    ),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<Species>(
                    initialValue: _species,
                    decoration: const InputDecoration(labelText: 'Especie'),
                    items: Species.values
                        .map(
                          (species) => DropdownMenuItem(
                            value: species,
                            child: Text(species.displayName),
                          ),
                        )
                        .toList(),
                    onChanged: (value) {
                      if (value == null) return;
                      setState(() {
                        _species = value;
                        if (value != Species.cattle &&
                            _cattleOnlyCategories.contains(_category)) {
                          _category = Category.other;
                        }
                      });
                    },
                  ),
                  const SizedBox(height: 12),
                  GestureDetector(
                    onTap: _pickBirthDate,
                    child: InputDecorator(
                      decoration: const InputDecoration(
                        labelText: 'Fecha de nacimiento (opcional)',
                        prefixIcon: Icon(Icons.calendar_today_outlined),
                        suffixIcon: Icon(Icons.calendar_month_outlined),
                      ),
                      isEmpty: false,
                      child: Text(
                        _birthDate == null
                            ? 'Seleccioná la fecha de nacimiento'
                            : _formatDate(_birthDate!),
                        style: _birthDate == null
                            ? TextStyle(color: theme.hintColor)
                            : null,
                      ),
                    ),
                  ),
                  if (_birthDate == null &&
                      _estimatedAgeLabel(_category) != null) ...[
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          size: 14,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          _estimatedAgeLabel(_category)!,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ],
                  const SizedBox(height: 12),
                  DropdownButtonFormField<Category>(
                    key: ValueKey(_category),
                    value: _category,
                    decoration: const InputDecoration(labelText: 'Categoría'),
                    items: _availableCategories
                        .map(
                          (category) => DropdownMenuItem(
                            value: category,
                            child: Text(category.displayName),
                          ),
                        )
                        .toList(),
                    onChanged: (value) {
                      if (value == null) return;
                      final impliedSex = _impliedSexForCategory(value);
                      setState(() {
                        _category = value;
                        if (impliedSex != null) _sex = impliedSex;
                      });
                    },
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Género',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: _sex == Sex.female
                            ? FilledButton.icon(
                                onPressed: () =>
                                    setState(() => _sex = Sex.female),
                                icon: const Icon(Icons.female),
                                label: const Text('Hembra'),
                              )
                            : OutlinedButton.icon(
                                onPressed: () =>
                                    setState(() => _sex = Sex.female),
                                icon: const Icon(Icons.female),
                                label: const Text('Hembra'),
                              ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _sex == Sex.male
                            ? FilledButton.icon(
                                onPressed: () =>
                                    setState(() => _sex = Sex.male),
                                icon: const Icon(Icons.male),
                                label: const Text('Macho'),
                              )
                            : OutlinedButton.icon(
                                onPressed: () =>
                                    setState(() => _sex = Sex.male),
                                icon: const Icon(Icons.male),
                                label: const Text('Macho'),
                              ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _breedCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Raza 1',
                      hintText: 'Ej. Angus',
                      suffixIcon: Icon(Icons.expand_more),
                    ),
                    validator: (value) {
                      if ((value ?? '').trim().isEmpty) {
                        return 'Ingresa la raza';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _crossBreedCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Raza 2 (opcional)',
                      hintText: 'Ej. Brahman (si aplica)',
                      suffixIcon: Icon(Icons.expand_more),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _coatColorCtrl,
                          decoration: const InputDecoration(
                            labelText: 'Color / Pelaje',
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextFormField(
                          controller: _weightCtrl,
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          decoration: const InputDecoration(
                            labelText: 'Peso inicial (kg)',
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<AnimalStatus>(
                    initialValue: _status,
                    decoration: const InputDecoration(labelText: 'Estado *'),
                    items: AnimalStatus.values
                        .map(
                          (status) => DropdownMenuItem(
                            value: status,
                            child: Text(status.displayName),
                          ),
                        )
                        .toList(),
                    onChanged: (value) {
                      if (value == null) return;
                      setState(() {
                        _status = value;
                      });
                    },
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    onPressed: _pickRegistrationDate,
                    icon: const Icon(Icons.event_available_outlined),
                    label: Text(
                      'Fecha de registro: ${_formatDate(_registrationDate)}',
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _notesCtrl,
                    maxLines: 3,
                    maxLength: 300,
                    decoration: const InputDecoration(
                      labelText: 'Observaciones',
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _distinguishingMarksCtrl,
                    maxLength: 120,
                    decoration: const InputDecoration(
                      labelText: 'Senas particulares',
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStep2() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Origen del animal', Icons.hub_outlined),
        const SizedBox(height: 12),
        SegmentedButton<OriginType>(
          segments: OriginType.values
              .map(
                (originType) => ButtonSegment(
                  value: originType,
                  label: Text(originType.displayName),
                ),
              )
              .toList(),
          selected: {_originType},
          onSelectionChanged: (value) {
            if (value.isEmpty) return;
            setState(() {
              _originType = value.first;
            });
          },
        ),
        const SizedBox(height: 12),
        DropdownButtonFormField<String>(
          initialValue: _selectedProvenanceUuid,
          decoration: const InputDecoration(labelText: 'Procedencia'),
          items: _ranches
              .map(
                (location) => DropdownMenuItem(
                  value: location.uuid,
                  child: Text(location.name),
                ),
              )
              .toList(),
          onChanged: (value) {
            setState(() {
              _selectedProvenanceUuid = value;
            });
          },
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: DropdownButtonFormField<String>(
                initialValue: _selectedDamUuid,
                decoration: const InputDecoration(
                  labelText: 'Madre (opcional)',
                ),
                items: _animals
                    .map(
                      (animal) => DropdownMenuItem(
                        value: animal.uuid,
                        child: Text(_animalLabel(animal)),
                      ),
                    )
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedDamUuid = value;
                  });
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: DropdownButtonFormField<String>(
                initialValue: _selectedSireUuid,
                decoration: const InputDecoration(
                  labelText: 'Padre (opcional)',
                ),
                items: _animals
                    .map(
                      (animal) => DropdownMenuItem(
                        value: animal.uuid,
                        child: Text(_animalLabel(animal)),
                      ),
                    )
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedSireUuid = value;
                  });
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: _originNotesCtrl,
          maxLength: 250,
          maxLines: 3,
          decoration: const InputDecoration(
            labelText: 'Observaciones del origen',
          ),
        ),
        const SizedBox(height: 16),
        _buildSectionTitle(
          'Informacion genetica (opcional)',
          Icons.bubble_chart,
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _crossBreedTypeCtrl,
                decoration: const InputDecoration(
                  labelText: 'Tipo de cruzamiento',
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextFormField(
                controller: _sireBreedCtrl,
                decoration: const InputDecoration(labelText: 'Raza del padre'),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _damBreedCtrl,
                decoration: const InputDecoration(
                  labelText: 'Raza de la madre',
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextFormField(
                controller: _bloodPercentageCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Porcentaje de sangre',
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: _genealogicalRegistryCtrl,
          decoration: const InputDecoration(labelText: 'Registro genealogico'),
        ),
      ],
    );
  }

  Widget _buildStep3() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Ubicacion y manejo', Icons.location_on_outlined),
        const SizedBox(height: 12),
        DropdownButtonFormField<String>(
          initialValue: _selectedRanchUuid,
          decoration: const InputDecoration(labelText: 'Rancho / Finca *'),
          items: _ranches
              .map(
                (location) => DropdownMenuItem(
                  value: location.uuid,
                  child: Text(location.name),
                ),
              )
              .toList(),
          onChanged: (value) {
            setState(() {
              _selectedRanchUuid = value;
              _selectedPaddockUuid = _paddocksForSelectedRanch.isNotEmpty
                  ? _paddocksForSelectedRanch.first.uuid
                  : null;
            });
          },
        ),
        const SizedBox(height: 12),
        DropdownButtonFormField<String>(
          initialValue: _selectedPaddockUuid,
          decoration: const InputDecoration(
            labelText: 'Potrero / Corral / Area',
          ),
          items: _paddocksForSelectedRanch
              .map(
                (location) => DropdownMenuItem(
                  value: location.uuid,
                  child: Text(location.name),
                ),
              )
              .toList(),
          onChanged: (value) {
            setState(() {
              _selectedPaddockUuid = value;
            });
          },
        ),
        const SizedBox(height: 12),
        DropdownButtonFormField<String>(
          initialValue: _selectedBatchUuid,
          decoration: const InputDecoration(labelText: 'Lote o grupo'),
          items: _lotes
              .map(
                (lote) => DropdownMenuItem(
                  value: lote.uuid,
                  child: Text(lote.nombre),
                ),
              )
              .toList(),
          onChanged: (value) {
            setState(() {
              _selectedBatchUuid = value;
            });
          },
        ),
        const SizedBox(height: 12),
        DropdownButtonFormField<ProductionSystem>(
          initialValue: _productionSystem,
          decoration: const InputDecoration(labelText: 'Sistema de manejo *'),
          items: ProductionSystem.values
              .map(
                (value) => DropdownMenuItem(
                  value: value,
                  child: Text(value.displayName),
                ),
              )
              .toList(),
          onChanged: (value) {
            if (value == null) return;
            setState(() {
              _productionSystem = value;
            });
          },
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildSimpleSelection(
                label: 'Tipo de alojamiento',
                value: _housingType,
                options: const ['Libre en potrero', 'Corral', 'Mixto'],
                onSelected: (value) {
                  setState(() {
                    _housingType = value;
                  });
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildSimpleSelection(
                label: 'Disponibilidad de sombra',
                value: _shadingAvailability,
                options: const ['Nula', 'Parcial', 'Amplia'],
                onSelected: (value) {
                  setState(() {
                    _shadingAvailability = value;
                  });
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildSimpleSelection(
                label: 'Fuente de agua',
                value: _waterSource,
                options: const [
                  'Bebedero automatico',
                  'Bebedero manual',
                  'Quebrada',
                ],
                onSelected: (value) {
                  setState(() {
                    _waterSource = value;
                  });
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextFormField(
                controller: _approximateDensityCtrl,
                decoration: const InputDecoration(
                  labelText: 'Densidad aproximada',
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: _locationNotesCtrl,
          maxLength: 250,
          maxLines: 3,
          decoration: const InputDecoration(
            labelText: 'Observaciones de ubicacion y manejo',
          ),
        ),
        const SizedBox(height: 16),
        _buildSectionTitle('Alimentacion actual', Icons.grass_outlined),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _feedTypeCtrl,
                decoration: const InputDecoration(
                  labelText: 'Tipo de alimentacion',
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildSimpleSelection(
                label: 'Frecuencia',
                value: _feedFrequency,
                options: const [
                  '1 vez al dia',
                  '2 veces al dia',
                  '3 veces al dia',
                ],
                onSelected: (value) {
                  setState(() {
                    _feedFrequency = value;
                  });
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildSimpleSelection(
                label: 'Suplementos',
                value: _feedSupplements,
                options: const [
                  'Ninguno',
                  'Sal mineral',
                  'Concentrado',
                  'Vitaminas',
                ],
                onSelected: (value) {
                  setState(() {
                    _feedSupplements = value;
                  });
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextFormField(
                controller: _feedNotesCtrl,
                decoration: const InputDecoration(labelText: 'Observaciones'),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _buildSectionTitle('Identificacion adicional', Icons.sell_outlined),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildSimpleSelection(
                label: 'Color de arete',
                value: _earTagColor,
                options: const ['Amarillo', 'Rojo', 'Azul', 'Verde', 'Blanco'],
                onSelected: (value) {
                  setState(() {
                    _earTagColor = value;
                  });
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextFormField(
                controller: _visualIdCtrl,
                decoration: const InputDecoration(
                  labelText: 'Numero arete visual',
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStep4() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Salud inicial', Icons.health_and_safety_outlined),
        const SizedBox(height: 12),
        SegmentedButton<_InitialHealthMode>(
          segments: const [
            ButtonSegment(
              value: _InitialHealthMode.healthy,
              label: Text('Saludable'),
            ),
            ButtonSegment(
              value: _InitialHealthMode.observation,
              label: Text('En observacion'),
            ),
            ButtonSegment(
              value: _InitialHealthMode.problem,
              label: Text('Con problemas'),
            ),
          ],
          selected: {_healthMode},
          onSelectionChanged: (values) {
            if (values.isEmpty) return;
            setState(() {
              _healthMode = values.first;
            });
          },
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: List.generate(5, (index) {
            final score = index + 1;
            final selected = score == _bodyConditionScore;
            return ChoiceChip(
              label: Text('$score'),
              selected: selected,
              onSelected: (_) {
                setState(() {
                  _bodyConditionScore = score;
                });
              },
            );
          }),
        ),
        const SizedBox(height: 16),
        _buildRecordSection(
          title: 'Tratamientos aplicados',
          icon: Icons.medication_outlined,
          records: _treatments,
          onAdd: () => _openAddRecordDialog(
            section: 'Agregar tratamiento',
            defaultType: HealthRecordType.treatment,
            onAdded: (record) => _treatments.add(record),
          ),
        ),
        const SizedBox(height: 12),
        _buildRecordSection(
          title: 'Vacunacion',
          icon: Icons.vaccines_outlined,
          records: _vaccinations,
          onAdd: () => _openAddRecordDialog(
            section: 'Agregar vacuna',
            defaultType: HealthRecordType.vaccine,
            onAdded: (record) => _vaccinations.add(record),
          ),
        ),
        const SizedBox(height: 12),
        _buildRecordSection(
          title: 'Examenes realizados',
          icon: Icons.biotech_outlined,
          records: _exams,
          onAdd: () => _openAddRecordDialog(
            section: 'Agregar examen',
            defaultType: HealthRecordType.checkup,
            onAdded: (record) => _exams.add(record),
          ),
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: _healthNotesCtrl,
          maxLines: 3,
          maxLength: 250,
          decoration: const InputDecoration(
            labelText: 'Observaciones de salud',
          ),
        ),
      ],
    );
  }

  Widget _buildStep5() {
    final healthTuple = _resolveHealthFlags();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Revision del registro', Icons.checklist_outlined),
        const SizedBox(height: 12),
        _buildReviewCard(
          title: 'Informacion basica',
          rows: [
            _ReviewRow('Arete', _safeText(_earTagCtrl.text)),
            _ReviewRow('Nombre', _safeText(_nameCtrl.text)),
            _ReviewRow('Especie', _species.displayName),
            _ReviewRow('Categoria', _category.displayName),
            _ReviewRow('Raza', _safeText(_breedCtrl.text)),
            _ReviewRow('Cruza', _safeText(_crossBreedCtrl.text)),
            _ReviewRow('Sexo', _sex.displayName),
            _ReviewRow(
              'Nacimiento',
              _birthDate == null ? '--' : _formatDate(_birthDate!),
            ),
            _ReviewRow('Color/Pelaje', _safeText(_coatColorCtrl.text)),
            _ReviewRow('Estado', _status.displayName),
          ],
        ),
        const SizedBox(height: 10),
        _buildReviewCard(
          title: 'Origen',
          rows: [
            _ReviewRow('Tipo de origen', _originType.displayName),
            _ReviewRow(
              'Procedencia',
              _locationNameByUuid(_selectedProvenanceUuid),
            ),
            _ReviewRow('Madre', _animalNameByUuid(_selectedDamUuid)),
            _ReviewRow('Padre', _animalNameByUuid(_selectedSireUuid)),
            _ReviewRow(
              'Tipo de cruzamiento',
              _safeText(_crossBreedTypeCtrl.text),
            ),
            _ReviewRow(
              'Registro genealogico',
              _safeText(_genealogicalRegistryCtrl.text),
            ),
          ],
        ),
        const SizedBox(height: 10),
        _buildReviewCard(
          title: 'Ubicacion y manejo',
          rows: [
            _ReviewRow('Rancho', _locationNameByUuid(_selectedRanchUuid)),
            _ReviewRow(
              'Potrero/Corral',
              _locationNameByUuid(_selectedPaddockUuid),
            ),
            _ReviewRow('Lote', _loteNameByUuid(_selectedBatchUuid)),
            _ReviewRow('Sistema de manejo', _productionSystem.displayName),
            _ReviewRow('Alojamiento', _housingType),
            _ReviewRow('Sombra', _shadingAvailability),
            _ReviewRow('Fuente de agua', _waterSource),
            _ReviewRow('Densidad', _safeText(_approximateDensityCtrl.text)),
          ],
        ),
        const SizedBox(height: 10),
        _buildReviewCard(
          title: 'Salud inicial',
          rows: [
            _ReviewRow(
              'Estado sanitario',
              healthTuple.healthStatus.displayName,
            ),
            _ReviewRow('BSC', '$_bodyConditionScore'),
            _ReviewRow('Riesgo', healthTuple.riskLevel.displayName),
            _ReviewRow('Tipo de alimentacion', _safeText(_feedTypeCtrl.text)),
            _ReviewRow('Tratamientos', '${_treatments.length}'),
            _ReviewRow('Vacunas', '${_vaccinations.length}'),
            _ReviewRow('Examenes', '${_exams.length}'),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.green.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Text(
            'Todo listo. Revisa la informacion y guarda el registro.',
          ),
        ),
      ],
    );
  }

  Widget _buildBottomBar() {
    final isFirstStep = _currentStep == 0;
    final isLastStep = _currentStep == _stepLabels.length - 1;

    return Container(
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: Theme.of(context).dividerColor)),
      ),
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 5),
      child: Row(
        children: [
          Expanded(
            child: isFirstStep
                ? OutlinedButton.icon(
                    onPressed: _saving ? null : _onSaveForLater,
                    icon: const Icon(Icons.save_alt_outlined),
                    label: const Text('Terminar'),
                  )
                : ElevatedButton.icon(
                    onPressed: _onPreviousStep,
                    icon: const Icon(Icons.arrow_back),
                    label: const Text('Anterior'),
                  ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: FilledButton.icon(
              onPressed: _saving
                  ? null
                  : isLastStep
                  ? _onSave
                  : _onNextStep,
              icon: Icon(
                isLastStep ? Icons.save_outlined : Icons.arrow_forward,
              ),
              label: Text(
                _saving
                    ? 'Guardando...'
                    : isLastStep
                    ? 'Guardar registro'
                    : 'Siguiente',
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title, IconData icon, {String? subtitle}) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: colorScheme.primary.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, size: 24, color: colorScheme.primary),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              if (subtitle != null) ...[
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSimpleSelection({
    required String label,
    required String value,
    required List<String> options,
    required ValueChanged<String> onSelected,
  }) {
    return DropdownButtonFormField<String>(
      initialValue: value,
      decoration: InputDecoration(labelText: label),
      items: options
          .map((option) => DropdownMenuItem(value: option, child: Text(option)))
          .toList(),
      onChanged: (selected) {
        if (selected == null) return;
        onSelected(selected);
      },
    );
  }

  Widget _buildRecordSection({
    required String title,
    required IconData icon,
    required List<_RecordDraft> records,
    required VoidCallback onAdd,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    title,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                TextButton.icon(
                  onPressed: onAdd,
                  icon: const Icon(Icons.add),
                  label: const Text('Agregar'),
                ),
              ],
            ),
            if (records.isEmpty)
              const Padding(
                padding: EdgeInsets.only(top: 8),
                child: Text('Sin registros'),
              )
            else
              ...records.asMap().entries.map((entry) {
                final index = entry.key;
                final record = entry.value;
                return ListTile(
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                  title: Text(record.product),
                  subtitle: Text(
                    '${record.type.name} - ${_formatDate(record.date)}',
                  ),
                  trailing: IconButton(
                    onPressed: () {
                      setState(() {
                        records.removeAt(index);
                      });
                    },
                    icon: const Icon(Icons.delete_outline),
                  ),
                );
              }),
          ],
        ),
      ),
    );
  }

  Widget _buildReviewCard({
    required String title,
    required List<_ReviewRow> rows,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(
                context,
              ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            ...rows.map(
              (row) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        row.label,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ),
                    Expanded(
                      child: Text(
                        row.value,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _openAddRecordDialog({
    required String section,
    required HealthRecordType defaultType,
    required ValueChanged<_RecordDraft> onAdded,
  }) async {
    final productCtrl = TextEditingController();
    final doseCtrl = TextEditingController();
    final notesCtrl = TextEditingController();
    DateTime date = DateTime.now();

    final added = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (dialogContext, setDialogState) {
            return AlertDialog(
              title: Text(section),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: productCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Producto / Descripcion',
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: doseCtrl,
                    decoration: const InputDecoration(labelText: 'Dosis'),
                  ),
                  const SizedBox(height: 8),
                  OutlinedButton.icon(
                    onPressed: () async {
                      final selected = await showDatePicker(
                        context: dialogContext,
                        initialDate: date,
                        firstDate: DateTime(2000),
                        lastDate: DateTime.now().add(
                          const Duration(days: 3650),
                        ),
                      );
                      if (selected == null) return;
                      setDialogState(() {
                        date = selected;
                      });
                    },
                    icon: const Icon(Icons.event_outlined),
                    label: Text('Fecha: ${_formatDate(date)}'),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: notesCtrl,
                    maxLines: 2,
                    decoration: const InputDecoration(labelText: 'Notas'),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(false),
                  child: const Text('Cancelar'),
                ),
                FilledButton(
                  onPressed: () {
                    if (productCtrl.text.trim().isEmpty) {
                      return;
                    }
                    onAdded(
                      _RecordDraft(
                        type: defaultType,
                        product: productCtrl.text.trim(),
                        dose: _nullableText(doseCtrl.text),
                        date: date,
                        notes: _nullableText(notesCtrl.text),
                      ),
                    );
                    Navigator.of(dialogContext).pop(true);
                  },
                  child: const Text('Agregar'),
                ),
              ],
            );
          },
        );
      },
    );

    productCtrl.dispose();
    doseCtrl.dispose();
    notesCtrl.dispose();

    if (added == true && mounted) {
      setState(() {});
    }
  }

  Future<void> _pickBirthDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _birthDate ?? now,
      firstDate: DateTime(now.year - 30),
      lastDate: now,
    );

    if (picked == null) return;
    setState(() {
      _birthDate = picked;
      if (_species == Species.cattle) {
        final ageMonths = AnimalLifecycleCalculator.calculate(
          birthDate: picked,
          species: _species,
          sex: _sex,
        ).ageMonths;
        final validCategories = _categoriesForAge(ageMonths);
        if (!validCategories.contains(_category)) {
          _category = validCategories.first;
          final impliedSex = _impliedSexForCategory(_category);
          if (impliedSex != null) _sex = impliedSex;
        }
      }
    });
  }

  Future<void> _pickRegistrationDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _registrationDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now().add(const Duration(days: 3650)),
    );

    if (picked == null) return;
    setState(() {
      _registrationDate = picked;
    });
  }

  Future<void> _onNextStep() async {
    if (_currentStep == 0) {
      final valid = _step1FormKey.currentState?.validate() ?? false;
      if (!valid) {
        _showMessage('Completa los campos requeridos de informacion basica.');
        return;
      }

      final duplicated = await _isEarTagDuplicated(_earTagCtrl.text.trim());
      if (duplicated && mounted) {
        _showMessage('El arete ya existe en otro registro.');
        return;
      }
    }

    if (_currentStep >= _stepLabels.length - 1) return;

    setState(() {
      _currentStep += 1;
    });
  }

  Future<void> _onAttemptExit() async {
    if (_saving) return;

    if (_currentStep > 0) {
      setState(() {
        _currentStep -= 1;
      });
      return;
    }

    final discard = await _confirmDiscardDialog(
      title: 'Salir del registro',
      message:
          'Si sales ahora, el progreso de este registro no se guardara.\n\nQuieres salir?',
      confirmLabel: 'Salir',
    );

    if (!mounted || !discard) return;
    Navigator.of(context).pop(false);
  }

  // ─── Draft Persistence ────────────────────────────────────────────────────

  Map<String, dynamic> _buildDraftMap() => {
    'step': _currentStep,
    // Controllers
    'earTag': _earTagCtrl.text,
    'name': _nameCtrl.text,
    'breed': _breedCtrl.text,
    'crossBreed': _crossBreedCtrl.text,
    'coatColor': _coatColorCtrl.text,
    'weight': _weightCtrl.text,
    'notes': _notesCtrl.text,
    'distinguishingMarks': _distinguishingMarksCtrl.text,
    'crossBreedType': _crossBreedTypeCtrl.text,
    'feedType': _feedTypeCtrl.text,
    'sireBreed': _sireBreedCtrl.text,
    'damBreed': _damBreedCtrl.text,
    'bloodPercentage': _bloodPercentageCtrl.text,
    'genealogicalRegistry': _genealogicalRegistryCtrl.text,
    'originNotes': _originNotesCtrl.text,
    'approximateDensity': _approximateDensityCtrl.text,
    'locationNotes': _locationNotesCtrl.text,
    'feedNotes': _feedNotesCtrl.text,
    'visualId': _visualIdCtrl.text,
    'healthNotes': _healthNotesCtrl.text,
    // Enums
    'species': _species.name,
    'category': _category.name,
    'sex': _sex.name,
    'status': _status.name,
    'originType': _originType.name,
    'productionSystem': _productionSystem.name,
    'healthMode': _healthMode.name,
    // Dates
    'birthDate': _birthDate?.toIso8601String(),
    'registrationDate': _registrationDate.toIso8601String(),
    // UUID selections
    'provenanceUuid': _selectedProvenanceUuid,
    'damUuid': _selectedDamUuid,
    'sireUuid': _selectedSireUuid,
    'ranchUuid': _selectedRanchUuid,
    'paddockUuid': _selectedPaddockUuid,
    'batchUuid': _selectedBatchUuid,
    // Dropdown strings
    'housingType': _housingType,
    'shadingAvailability': _shadingAvailability,
    'waterSource': _waterSource,
    'feedFrequency': _feedFrequency,
    'feedSupplements': _feedSupplements,
    'earTagColor': _earTagColor,
    // Scalars
    'bodyConditionScore': _bodyConditionScore,
    // Record lists
    'treatments': _treatments.map((r) => r.toMap()).toList(),
    'vaccinations': _vaccinations.map((r) => r.toMap()).toList(),
    'exams': _exams.map((r) => r.toMap()).toList(),
  };

  Future<bool> _persistDraft() async {
    try {
      final json = jsonEncode(_buildDraftMap());
      await _sharedPrefsService.setString(PrefsKeys.animalWizardDraft, json);
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<void> _clearDraft() async {
    try {
      await _sharedPrefsService.remove(PrefsKeys.animalWizardDraft);
    } catch (_) {}
  }

  Future<void> _promptRestoreDraft() async {
    final raw = _sharedPrefsService.getString(PrefsKeys.animalWizardDraft);
    if (raw == null) return;
    if (!mounted) return;

    final action = await showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: const Text('Borrador encontrado'),
        content: const Text(
          'Se encontro un borrador del registro anterior. Deseas restaurarlo?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop('discard'),
            child: const Text('Descartar'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop('cancel'),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop('restore'),
            child: const Text('Restaurar'),
          ),
        ],
      ),
    );

    if (!mounted) return;
    if (action == 'discard') {
      await _clearDraft();
    } else if (action == 'restore') {
      try {
        final map = jsonDecode(raw) as Map<String, dynamic>;
        _applyDraft(map);
      } catch (_) {
        await _clearDraft();
        if (mounted) {
          _showMessage('No se pudo restaurar el borrador.');
        }
      }
    }
  }

  void _applyDraft(Map<String, dynamic> m) {
    T safeEnum<T extends Enum>(List<T> values, String? name, T fallback) {
      if (name == null) return fallback;
      try {
        return values.byName(name);
      } catch (_) {
        return fallback;
      }
    }

    List<_RecordDraft> parseRecords(dynamic raw) {
      if (raw is! List) return [];
      final result = <_RecordDraft>[];
      for (final item in raw) {
        if (item is Map<String, dynamic>) {
          try {
            result.add(_RecordDraft.fromMap(item));
          } catch (_) {}
        }
      }
      return result;
    }

    bool validLocationUuid(String? uuid) =>
        uuid == null || _locations.any((l) => l.uuid == uuid);
    bool validAnimalUuid(String? uuid) =>
        uuid == null || _animals.any((a) => a.uuid == uuid);
    bool validBatchUuid(String? uuid) =>
        uuid == null || _lotes.any((l) => l.uuid == uuid);

    setState(() {
      _currentStep = (m['step'] as int?) ?? 0;
      // Controllers
      _earTagCtrl.text = (m['earTag'] as String?) ?? '';
      _nameCtrl.text = (m['name'] as String?) ?? '';
      _breedCtrl.text = (m['breed'] as String?) ?? '';
      _crossBreedCtrl.text = (m['crossBreed'] as String?) ?? '';
      _coatColorCtrl.text = (m['coatColor'] as String?) ?? '';
      _weightCtrl.text = (m['weight'] as String?) ?? '';
      _notesCtrl.text = (m['notes'] as String?) ?? '';
      _distinguishingMarksCtrl.text =
          (m['distinguishingMarks'] as String?) ?? '';
      _crossBreedTypeCtrl.text = (m['crossBreedType'] as String?) ?? '';
      _feedTypeCtrl.text = (m['feedType'] as String?) ?? '';
      _sireBreedCtrl.text = (m['sireBreed'] as String?) ?? '';
      _damBreedCtrl.text = (m['damBreed'] as String?) ?? '';
      _bloodPercentageCtrl.text = (m['bloodPercentage'] as String?) ?? '';
      _genealogicalRegistryCtrl.text =
          (m['genealogicalRegistry'] as String?) ?? '';
      _originNotesCtrl.text = (m['originNotes'] as String?) ?? '';
      _approximateDensityCtrl.text = (m['approximateDensity'] as String?) ?? '';
      _locationNotesCtrl.text = (m['locationNotes'] as String?) ?? '';
      _feedNotesCtrl.text = (m['feedNotes'] as String?) ?? '';
      _visualIdCtrl.text = (m['visualId'] as String?) ?? '';
      _healthNotesCtrl.text = (m['healthNotes'] as String?) ?? '';
      // Enums
      _species = safeEnum(Species.values, m['species'] as String?, _species);
      _category = safeEnum(
        Category.values,
        m['category'] as String?,
        _category,
      );
      _sex = safeEnum(Sex.values, m['sex'] as String?, _sex);
      _status = safeEnum(AnimalStatus.values, m['status'] as String?, _status);
      _originType = safeEnum(
        OriginType.values,
        m['originType'] as String?,
        _originType,
      );
      _productionSystem = safeEnum(
        ProductionSystem.values,
        m['productionSystem'] as String?,
        _productionSystem,
      );
      _healthMode = safeEnum(
        _InitialHealthMode.values,
        m['healthMode'] as String?,
        _healthMode,
      );
      // Dates
      final birthStr = m['birthDate'] as String?;
      _birthDate = birthStr != null ? DateTime.tryParse(birthStr) : null;
      final regStr = m['registrationDate'] as String?;
      _registrationDate = regStr != null
          ? (DateTime.tryParse(regStr) ?? _registrationDate)
          : _registrationDate;
      // UUID selections — soft fallback to null if reference no longer exists
      final provenanceUuid = m['provenanceUuid'] as String?;
      _selectedProvenanceUuid = validLocationUuid(provenanceUuid)
          ? provenanceUuid
          : null;
      final ranchUuid = m['ranchUuid'] as String?;
      _selectedRanchUuid = validLocationUuid(ranchUuid) ? ranchUuid : null;
      final paddockUuid = m['paddockUuid'] as String?;
      _selectedPaddockUuid = validLocationUuid(paddockUuid)
          ? paddockUuid
          : null;
      final damUuid = m['damUuid'] as String?;
      _selectedDamUuid = validAnimalUuid(damUuid) ? damUuid : null;
      final sireUuid = m['sireUuid'] as String?;
      _selectedSireUuid = validAnimalUuid(sireUuid) ? sireUuid : null;
      final batchUuid = m['batchUuid'] as String?;
      _selectedBatchUuid = validBatchUuid(batchUuid) ? batchUuid : null;
      // Dropdown strings
      _housingType = (m['housingType'] as String?) ?? _housingType;
      _shadingAvailability =
          (m['shadingAvailability'] as String?) ?? _shadingAvailability;
      _waterSource = (m['waterSource'] as String?) ?? _waterSource;
      _feedFrequency = (m['feedFrequency'] as String?) ?? _feedFrequency;
      _feedSupplements = (m['feedSupplements'] as String?) ?? _feedSupplements;
      _earTagColor = (m['earTagColor'] as String?) ?? _earTagColor;
      // Scalars
      _bodyConditionScore =
          (m['bodyConditionScore'] as int?) ?? _bodyConditionScore;
      // Record lists
      _treatments
        ..clear()
        ..addAll(parseRecords(m['treatments']));
      _vaccinations
        ..clear()
        ..addAll(parseRecords(m['vaccinations']));
      _exams
        ..clear()
        ..addAll(parseRecords(m['exams']));
    });
  }

  // ─────────────────────────────────────────────────────────────────────────

  Future<void> _onSaveForLater() async {
    final saved = await _persistDraft();
    if (!mounted) return;
    if (saved) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Borrador guardado. Puedes continuar despues.'),
        ),
      );
      Navigator.of(context).pop(false);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No se pudo guardar el borrador. Intenta de nuevo.'),
        ),
      );
    }
  }

  void _onPreviousStep() {
    if (_currentStep <= 0) return;
    setState(() {
      _currentStep -= 1;
    });
  }

  Future<void> _onSave() async {
    final birthDate = _birthDate ?? _estimatedBirthDate(_category);

    final weight = _parseOptionalDouble(_weightCtrl.text);
    if (_weightCtrl.text.trim().isNotEmpty && weight == null) {
      _showMessage('El peso inicial no es valido.');
      return;
    }

    final bloodPercentage = _parseOptionalInt(_bloodPercentageCtrl.text);
    if (_bloodPercentageCtrl.text.trim().isNotEmpty &&
        bloodPercentage == null) {
      _showMessage('El porcentaje de sangre no es valido.');
      return;
    }

    final lifecycle = AnimalLifecycleCalculator.calculate(
      birthDate: birthDate,
      species: _species,
      sex: _sex,
    );

    final now = DateTime.now();
    final uuid = 'ani-${now.microsecondsSinceEpoch}';
    final healthTuple = _resolveHealthFlags();

    final animal = AnimalEntity(
      id: null,
      uuid: uuid,
      earTagNumber: _earTagCtrl.text.trim(),
      customName: _nullableText(_nameCtrl.text),
      visualId: _nullableText(_visualIdCtrl.text),
      brand: null,
      rfidTag: null,
      batchUuid: _selectedBatchUuid,
      species: _species,
      category: _category,
      lifeStage: lifecycle.lifeStage,
      sex: _sex,
      breed: _breedCtrl.text.trim(),
      crossBreed: _nullableText(_crossBreedCtrl.text),
      birthDate: birthDate,
      ageMonths: lifecycle.ageMonths,
      weight: weight,
      sireUuid: _selectedSireUuid,
      damUuid: _selectedDamUuid,
      generation: 1,
      healthStatus: healthTuple.healthStatus,
      bodyConditionScore: _bodyConditionScore,
      vaccinated: _vaccinations.isNotEmpty,
      dewormed: _treatments.any(
        (record) => record.type == HealthRecordType.deworming,
      ),
      hasVitamins: _treatments.any(
        (record) => record.type == HealthRecordType.vitamins,
      ),
      hasChronicIssues: _healthMode == _InitialHealthMode.problem,
      chronicNotes: _nullableText(_healthNotesCtrl.text),
      reproductiveStatus: ReproductiveStatus.unknown,
      firstServiceDate: null,
      lastServiceDate: null,
      expectedCalvingDate: null,
      productionPurpose: ProductionPurpose.undefined,
      productionStage: ProductionStage.unknown,
      productionSystem: _productionSystem,
      feedType: _nullableText(_feedTypeCtrl.text),
      dailyGainEstimate: null,
      coatColor: _nullableText(_coatColorCtrl.text),
      distinguishingMarks: _nullableText(_distinguishingMarksCtrl.text),
      notes: _nullableText(_notesCtrl.text),
      originType: _originType.name,
      provenance: _selectedProvenanceUuid,
      crossBreedType: _nullableText(_crossBreedTypeCtrl.text),
      sireBreed: _nullableText(_sireBreedCtrl.text),
      damBreed: _nullableText(_damBreedCtrl.text),
      bloodPercentage: bloodPercentage,
      genealogicalRegistry: _nullableText(_genealogicalRegistryCtrl.text),
      originNotes: _nullableText(_originNotesCtrl.text),
      housingType: _nullableText(_housingType),
      shadingAvailability: _nullableText(_shadingAvailability),
      animalWaterSource: _nullableText(_waterSource),
      approximateDensity: _nullableText(_approximateDensityCtrl.text),
      locationNotes: _nullableText(_locationNotesCtrl.text),
      feedFrequency: _nullableText(_feedFrequency),
      feedSupplements: _nullableText(_feedSupplements),
      feedNotes: _nullableText(_feedNotesCtrl.text),
      earTagColor: _nullableText(_earTagColor),
      currentPaddockId: _selectedPaddockUuid,
      initialLocationId: _selectedPaddockUuid ?? _selectedRanchUuid,
      lastMovementDate: _registrationDate,
      underObservation: healthTuple.underObservation,
      requiresAttention: healthTuple.requiresAttention,
      riskLevel: healthTuple.riskLevel,
      profilePhoto: null,
      gallery: const [],
      owner: null,
      purchasePrice: null,
      status: _status,
      synced: false,
      remoteId: null,
      syncDate: null,
      contentHash: null,
      creationDate: now,
      lastUpdateDate: now,
    );

    setState(() {
      _saving = true;
    });

    try {
      await _animalRepository.save(animal);

      // Registrar movimiento inicial si se asignó una ubicación
      final initialLocation = _selectedPaddockUuid ?? _selectedRanchUuid;
      if (initialLocation != null) {
        await _animalRepository.addMovementRecord(
          uuid,
          MovementRecord(
            toLocation: _locationNameByUuid(initialLocation),
            date: _registrationDate,
            reason: MovementReason.relocation,
            notes: 'Ubicación inicial al momento del registro',
          ),
        );
      }

      // Sincronizar lote: agregar el animal al lote seleccionado
      final batchUuid = _selectedBatchUuid;
      if (batchUuid != null) {
        await _lotesRepository.addAnimalToLote(
          loteUuid: batchUuid,
          animalUuid: uuid,
        );
      }

      for (final record in [..._treatments, ..._vaccinations, ..._exams]) {
        await _animalRepository.addHealthRecord(
          uuid,
          HealthRecord(
            type: record.type,
            product: record.product,
            dose: record.dose,
            date: record.date,
            notes: record.notes,
          ),
        );
      }

      if (!mounted) return;
      await _clearDraft();
      if (!mounted) return;
      Navigator.of(context).pop(true);
    } catch (e) {
      if (!mounted) return;
      _showMessage('No se pudo guardar el animal: $e');
    } finally {
      if (mounted) {
        setState(() {
          _saving = false;
        });
      }
    }
  }

  _ResolvedHealth _resolveHealthFlags() {
    switch (_healthMode) {
      case _InitialHealthMode.healthy:
        return const _ResolvedHealth(
          healthStatus: HealthStatus.good,
          underObservation: false,
          requiresAttention: false,
          riskLevel: RiskLevel.low,
        );
      case _InitialHealthMode.observation:
        return const _ResolvedHealth(
          healthStatus: HealthStatus.fair,
          underObservation: true,
          requiresAttention: false,
          riskLevel: RiskLevel.medium,
        );
      case _InitialHealthMode.problem:
        return const _ResolvedHealth(
          healthStatus: HealthStatus.poor,
          underObservation: true,
          requiresAttention: true,
          riskLevel: RiskLevel.high,
        );
    }
  }

  List<Category> get _availableCategories {
    if (_species != Species.cattle) return const [Category.other];
    final birthDate = _birthDate;
    if (birthDate == null) return _cattleOnlyCategories.toList(growable: false);

    final ageMonths = AnimalLifecycleCalculator.calculate(
      birthDate: birthDate,
      species: _species,
      sex: _sex,
    ).ageMonths;

    final filtered = _categoriesForAge(ageMonths);
    if (!filtered.contains(_category)) return [...filtered, _category];
    return filtered;
  }

  List<Category> _categoriesForAge(int ageMonths) {
    if (ageMonths < 12) {
      return [Category.calf, Category.weaned, Category.other];
    }
    if (ageMonths < 24) {
      return [Category.heifer, Category.steer, Category.weaned, Category.other];
    }
    return [Category.cow, Category.bull, Category.oxen, Category.other];
  }

  Sex? _impliedSexForCategory(Category c) {
    switch (c) {
      case Category.heifer:
      case Category.cow:
        return Sex.female;
      case Category.steer:
      case Category.bull:
      case Category.oxen:
        return Sex.male;
      default:
        return null;
    }
  }

  String? _estimatedAgeLabel(Category c) {
    switch (c) {
      case Category.calf:
        return '~0 a 6 meses estimado';
      case Category.weaned:
        return '~6 a 12 meses estimado';
      case Category.heifer:
      case Category.steer:
        return '~12 a 24 meses estimado';
      case Category.cow:
      case Category.bull:
      case Category.oxen:
        return 'Más de 24 meses estimado';
      default:
        return null;
    }
  }

  DateTime _estimatedBirthDate(Category c) {
    final now = DateTime.now();
    switch (c) {
      case Category.calf:
        return now.subtract(const Duration(days: 90));
      case Category.weaned:
        return now.subtract(const Duration(days: 270));
      case Category.heifer:
      case Category.steer:
        return now.subtract(const Duration(days: 540));
      case Category.cow:
      case Category.bull:
      case Category.oxen:
        return now.subtract(const Duration(days: 900));
      default:
        return now.subtract(const Duration(days: 365));
    }
  }

  List<LocationEntity> get _ranches {
    return _locations
        .where((location) => location.type == LocationType.rancho)
        .toList();
  }

  LocationEntity? get _firstRanch {
    if (_ranches.isEmpty) return null;
    return _ranches.first;
  }

  List<LocationEntity> get _paddocksForSelectedRanch {
    final selectedRanchUuid = _selectedRanchUuid;
    if (selectedRanchUuid == null) {
      return _locations
          .where(
            (location) =>
                location.type == LocationType.potrero ||
                location.type == LocationType.corral,
          )
          .toList();
    }

    return _locations
        .where(
          (location) =>
              (location.type == LocationType.potrero ||
                  location.type == LocationType.corral) &&
              location.parentUuid == selectedRanchUuid,
        )
        .toList();
  }

  Future<bool> _isEarTagDuplicated(String earTag) async {
    final normalized = earTag.trim();
    if (normalized.isEmpty) {
      return false;
    }
    final animals = await _animalRepository.getAll();
    return animals.any((animal) => animal.earTagNumber.trim() == normalized);
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  String get _ageLabel {
    final birthDate = _birthDate;
    if (birthDate == null) return '--';

    final lifecycle = AnimalLifecycleCalculator.calculate(
      birthDate: birthDate,
      species: _species,
      sex: _sex,
    );
    return '${lifecycle.ageMonths} meses';
  }

  String _formatDate(DateTime value) {
    final dd = value.day.toString().padLeft(2, '0');
    final mm = value.month.toString().padLeft(2, '0');
    final yyyy = value.year.toString();
    return '$dd/$mm/$yyyy';
  }

  String _animalLabel(AnimalEntity animal) {
    final tag = animal.earTagNumber.trim();
    final name = animal.customName?.trim() ?? '';
    if (name.isEmpty) return tag.isEmpty ? animal.uuid : tag;
    if (tag.isEmpty) return name;
    return '$name · $tag';
  }

  String _safeText(String value) {
    final normalized = value.trim();
    if (normalized.isEmpty) return '--';
    return normalized;
  }

  String? _nullableText(String value) {
    final normalized = value.trim();
    if (normalized.isEmpty) return null;
    return normalized;
  }

  Future<bool> _confirmDiscardDialog({
    required String title,
    required String message,
    required String confirmLabel,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: Text(confirmLabel),
            ),
          ],
        );
      },
    );

    return result ?? false;
  }

  String _locationNameByUuid(String? uuid) {
    if (uuid == null) return '--';
    for (final location in _locations) {
      if (location.uuid == uuid) return location.name;
    }
    return '--';
  }

  String _animalNameByUuid(String? uuid) {
    if (uuid == null) return '--';
    for (final animal in _animals) {
      if (animal.uuid == uuid) return _animalLabel(animal);
    }
    return '--';
  }

  String _loteNameByUuid(String? uuid) {
    if (uuid == null) return '--';
    for (final lote in _lotes) {
      if (lote.uuid == uuid) return lote.nombre;
    }
    return '--';
  }

  double? _parseOptionalDouble(String input) {
    final normalized = input.trim();
    if (normalized.isEmpty) return null;
    final sanitized = normalized.replaceAll(',', '.');
    return double.tryParse(sanitized);
  }

  int? _parseOptionalInt(String input) {
    final normalized = input.trim();
    if (normalized.isEmpty) return null;
    return int.tryParse(normalized);
  }
}

enum _InitialHealthMode { healthy, observation, problem }

class _ResolvedHealth {
  const _ResolvedHealth({
    required this.healthStatus,
    required this.underObservation,
    required this.requiresAttention,
    required this.riskLevel,
  });

  final HealthStatus healthStatus;
  final bool underObservation;
  final bool requiresAttention;
  final RiskLevel riskLevel;
}

class _RecordDraft {
  const _RecordDraft({
    required this.type,
    required this.product,
    required this.date,
    this.dose,
    this.notes,
  });

  final HealthRecordType type;
  final String product;
  final String? dose;
  final DateTime date;
  final String? notes;

  Map<String, dynamic> toMap() => {
    'type': type.name,
    'product': product,
    'dose': dose,
    'date': date.millisecondsSinceEpoch,
    'notes': notes,
  };

  static _RecordDraft fromMap(Map<String, dynamic> map) {
    HealthRecordType parsedType;
    try {
      parsedType = HealthRecordType.values.byName(
        (map['type'] as String?) ?? 'other',
      );
    } catch (_) {
      parsedType = HealthRecordType.other;
    }
    return _RecordDraft(
      type: parsedType,
      product: (map['product'] as String?) ?? '',
      dose: map['dose'] as String?,
      date: DateTime.fromMillisecondsSinceEpoch(
        (map['date'] as int?) ?? DateTime.now().millisecondsSinceEpoch,
      ),
      notes: map['notes'] as String?,
    );
  }
}

class _ReviewRow {
  const _ReviewRow(this.label, this.value);

  final String label;
  final String value;
}
