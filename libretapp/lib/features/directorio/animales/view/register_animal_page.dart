/// features \u203a directorio \u203a animales \u203a view \u203a register_animal_page \u2014 page for registering a new animal.
library;

import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:libretapp/app/widgets/widgets.dart';
import 'package:libretapp/core/di/injection.dart';
import 'package:libretapp/core/services/prefs_keys.dart';
import 'package:libretapp/core/services/shared_prefs_service.dart';
import 'package:libretapp/core/utils/id_generator.dart';
import 'package:libretapp/features/directorio/animales/domain/animal_domain.dart';
import 'package:libretapp/features/directorio/animales/domain/enums/production_stage.dart';
import 'package:libretapp/features/directorio/animales/domain/enums/production_system.dart';
import 'package:libretapp/features/directorio/animales/domain/services/animal_edit_service.dart';
import 'package:libretapp/features/directorio/animales/domain/services/animal_lifecycle_calculator.dart';
import 'package:libretapp/features/directorio/animales/infrastructure/animal_repository.dart';
import 'package:libretapp/features/directorio/animales/widgets/registration_widgets.dart';
import 'package:libretapp/features/directorio/animales/domain/repositories/health_record_repository.dart';
import 'package:libretapp/features/directorio/animales/domain/repositories/movement_record_repository.dart';
import 'package:libretapp/features/directorio/animales/domain/repositories/reproduction_record_repository.dart';
import 'package:libretapp/features/directorio/lotes/domain/entities/lote_entity.dart';
import 'package:libretapp/features/directorio/lotes/infrastructure/lotes_repository.dart';
import 'package:libretapp/features/ubicaciones/domain/entities/location_entity.dart';
import 'package:libretapp/features/ubicaciones/domain/enums/location_type.dart';
import 'package:libretapp/features/ubicaciones/domain/repositories/location_repository.dart';

class RegisterAnimalPage extends StatefulWidget {
  const RegisterAnimalPage({this.animalUuid, this.initialSeed, super.key});

  final String? animalUuid;
  final AnimalRegistrationSeed? initialSeed;

  bool get isEdit => animalUuid != null;

  @override
  State<RegisterAnimalPage> createState() => _RegisterAnimalPageState();
}

class _RegisterAnimalPageState extends State<RegisterAnimalPage> {
  static const _stepLabels = <String>[
    'Información',
    'Origen',
    'Salud',
    'Manejo',
    'Revisión',
  ];

  final _step1FormKey = GlobalKey<FormState>();

  late final AnimalRepository _animalRepository;
  late final AnimalEditService _animalEditService;
  late final HealthRecordRepository _healthRepo;
  late final MovementRecordRepository _movementRepo;
  late final ReproductionRecordRepository _reproductionRepo;
  late final LotesRepository _lotesRepository;
  late final LocationRepository _locationRepository;
  late final SharedPrefsService _sharedPrefsService;

  final _earTagCtrl = TextEditingController();
  final _nameCtrl = TextEditingController();
  final _breedCtrl = TextEditingController();
  final _crossBreedCtrl = TextEditingController();
  final _ageMonthsCtrl = TextEditingController();
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
  AnimalEntity? _editingAnimal;
  Timer? _draftDebounce;

  Species _species = Species.cattle;
  Category _category = Category.heifer;
  Sex _sex = Sex.female;
  AnimalStatus _status = AnimalStatus.active;
  DateTime? _birthDate;
  _BirthInputMode _birthInputMode = _BirthInputMode.approximate;
  ApproximateAge _approximateAge = const ApproximateAge(years: 1, months: 0);
  DateTime _registrationDate = DateTime.now();

  OriginType _originType = OriginType.own;
  String? _selectedProvenanceUuid;
  String? _selectedDamUuid;
  String? _selectedSireUuid;

  String? _selectedRanchUuid;
  String? _selectedPaddockUuid;
  String? _selectedBatchUuid;
  ProductionSystem _productionSystem = ProductionSystem.rotational;
  ProductionPurpose _productionPurpose = ProductionPurpose.undefined;
  String _housingType = 'Libre en potrero';
  String _shadingAvailability = 'Parcial';
  String _waterSource = 'Bebedero automatico';
  String _feedFrequency = '2 veces al dia';
  String _feedSupplements = 'Sal mineral';
  String _earTagColor = 'Amarillo';

  _InitialHealthMode _healthMode = _InitialHealthMode.healthy;
  ReproductiveStatus _reproductiveStatus = ReproductiveStatus.unknown;
  int _bodyConditionScore = 3;

  List<LocationEntity> _locations = const [];
  List<LoteEntity> _lotes = const [];
  List<AnimalEntity> _animals = const [];

  final List<_RecordDraft> _treatments = [];
  final List<_RecordDraft> _vaccinations = [];
  final List<_RecordDraft> _exams = [];
  final List<_ReproductionDraft> _reproductions = [];

  AnimalRegistrationPolicy get _policy =>
      AnimalRegistrationPolicy.forSpecies(_species);

  Iterable<TextEditingController> get _draftControllers => [
    _earTagCtrl,
    _nameCtrl,
    _breedCtrl,
    _crossBreedCtrl,
    _ageMonthsCtrl,
    _coatColorCtrl,
    _weightCtrl,
    _notesCtrl,
    _crossBreedTypeCtrl,
    _feedTypeCtrl,
    _sireBreedCtrl,
    _damBreedCtrl,
    _bloodPercentageCtrl,
    _genealogicalRegistryCtrl,
    _originNotesCtrl,
    _approximateDensityCtrl,
    _locationNotesCtrl,
    _feedNotesCtrl,
    _visualIdCtrl,
    _distinguishingMarksCtrl,
    _healthNotesCtrl,
  ];

  @override
  void initState() {
    super.initState();
    _animalRepository = locator<AnimalRepository>();
    _animalEditService = locator<AnimalEditService>();
    _healthRepo = locator<HealthRecordRepository>();
    _movementRepo = locator<MovementRecordRepository>();
    _reproductionRepo = locator<ReproductionRecordRepository>();
    _lotesRepository = locator<LotesRepository>();
    _locationRepository = locator<LocationRepository>();
    _sharedPrefsService = locator<SharedPrefsService>();
    for (final controller in _draftControllers) {
      controller.addListener(_scheduleDraftSave);
    }
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final results = await Future.wait<dynamic>([
        _locationRepository.getAll(),
        _lotesRepository.getAll(),
        _animalRepository.getAll(),
        if (widget.isEdit) _animalRepository.getByUuid(widget.animalUuid!),
      ]);

      if (!mounted) return;
      final locations = results[0] as List<LocationEntity>;
      final lotes = results[1] as List<LoteEntity>;
      final animals = results[2] as List<AnimalEntity>;
      final editingAnimal = widget.isEdit ? results[3] as AnimalEntity? : null;

      setState(() {
        _locations = locations;
        _lotes = lotes;
        _animals = animals;

        if (widget.isEdit) {
          _editingAnimal = editingAnimal;
          if (editingAnimal != null) {
            _applyAnimalToForm(editingAnimal);
          }
        } else {
          final seed = widget.initialSeed;
          if (seed != null) {
            _applySeed(seed);
          }
          _selectedProvenanceUuid = _firstRanch?.uuid;
          _selectedRanchUuid = _firstRanch?.uuid;
          _selectedPaddockUuid = _paddocksForSelectedRanch.isNotEmpty
              ? _paddocksForSelectedRanch.first.uuid
              : null;
        }

        _loading = false;
      });

      if (widget.isEdit) {
        if (editingAnimal == null) {
          _showMessage('No se encontró el animal para editar.');
        }
      } else if (widget.initialSeed == null) {
        await _promptRestoreDraft();
      }
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _loading = false;
      });
      _showMessage('No se pudo cargar la informacion del formulario.');
    }
  }

  void _applyAnimalToForm(AnimalEntity animal) {
    _earTagCtrl.text = animal.earTagNumber;
    _nameCtrl.text = animal.customName ?? '';
    _breedCtrl.text = animal.breed;
    _crossBreedCtrl.text = animal.crossBreed ?? '';
    _ageMonthsCtrl.text = animal.ageMonths > 0
        ? animal.ageMonths.toString()
        : '';
    _coatColorCtrl.text = animal.coatColor ?? '';
    _weightCtrl.text = animal.weight?.toString() ?? '';
    _notesCtrl.text = animal.notes ?? '';
    _distinguishingMarksCtrl.text = animal.distinguishingMarks ?? '';
    _visualIdCtrl.text = animal.visualId ?? '';
    _healthNotesCtrl.text = animal.chronicNotes ?? '';
    _feedTypeCtrl.text = animal.feedType ?? '';
    _crossBreedTypeCtrl.text = animal.crossBreedType ?? '';
    _sireBreedCtrl.text = animal.sireBreed ?? '';
    _damBreedCtrl.text = animal.damBreed ?? '';
    _bloodPercentageCtrl.text = animal.bloodPercentage?.toString() ?? '';
    _genealogicalRegistryCtrl.text = animal.genealogicalRegistry ?? '';
    _originNotesCtrl.text = animal.originNotes ?? '';
    _approximateDensityCtrl.text = animal.approximateDensity ?? '';
    _locationNotesCtrl.text = animal.locationNotes ?? '';
    _feedNotesCtrl.text = animal.feedNotes ?? '';

    _species = animal.species;
    _category = animal.category;
    _sex = animal.sex;
    _status = animal.status;
    _birthDate = animal.birthDate;
    _birthInputMode = _BirthInputMode.exact;
    _approximateAge = ApproximateAge.fromTotalMonths(animal.ageMonths);
    _registrationDate = animal.lastMovementDate ?? animal.lastUpdateDate;
    _reproductiveStatus = animal.reproductiveStatus;
    _productionSystem = animal.productionSystem;
    _productionPurpose = animal.productionPurpose;
    _originType = animal.originType ?? OriginType.own;

    if (animal.healthStatus == HealthStatus.poor) {
      _healthMode = _InitialHealthMode.problem;
    } else if (animal.healthStatus == HealthStatus.fair) {
      _healthMode = _InitialHealthMode.observation;
    } else {
      _healthMode = _InitialHealthMode.healthy;
    }

    _selectedDamUuid = animal.damUuid;
    _selectedSireUuid = animal.sireUuid;
    _selectedBatchUuid = animal.batchUuid;
    _selectedPaddockUuid = animal.currentLocationId;

    final initialLocation = animal.initialLocationId;
    if (initialLocation != null) {
      _selectedProvenanceUuid = initialLocation;
      final location = _locations.where((item) => item.uuid == initialLocation);
      if (location.isNotEmpty && location.first.type.isRootType) {
        _selectedRanchUuid = initialLocation;
      } else {
        final paddock = _locations.where(
          (item) => item.uuid == _selectedPaddockUuid,
        );
        _selectedRanchUuid = paddock.isNotEmpty
            ? paddock.first.parentUuid
            : null;
      }
    }
  }

  @override
  void dispose() {
    _draftDebounce?.cancel();
    for (final controller in _draftControllers) {
      controller.removeListener(_scheduleDraftSave);
    }
    _earTagCtrl.dispose();
    _nameCtrl.dispose();
    _breedCtrl.dispose();
    _crossBreedCtrl.dispose();
    _ageMonthsCtrl.dispose();
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

  void _applySeed(AnimalRegistrationSeed seed) {
    _species = seed.species;
    _sex = seed.sex;
    _approximateAge = ApproximateAge.fromTotalMonths(seed.ageMonths);
    _ageMonthsCtrl.text = seed.ageMonths.toString();
    _birthInputMode = _BirthInputMode.approximate;
    _birthDate = null;
    _earTagCtrl.text = seed.identification ?? '';
    _nameCtrl.text = seed.name ?? '';
    _breedCtrl.text = seed.breed ?? '';
    _weightCtrl.text = seed.weight?.toString() ?? '';
    _productionPurpose = seed.productionPurpose ?? ProductionPurpose.undefined;
    _category = AnimalTaxonomy.defaultCategory(
      species: _species,
      sex: _sex,
      ageMonths: seed.ageMonths,
    );
  }

  void _scheduleDraftSave() {
    if (widget.isEdit || _loading) return;
    _draftDebounce?.cancel();
    _draftDebounce = Timer(const Duration(milliseconds: 500), () {
      _persistDraft();
    });
  }

  @override
  Widget build(BuildContext context) {
    final keyboardVisible = MediaQuery.viewInsetsOf(context).bottom > 0;
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
            title: Text(
              widget.isEdit ? 'Editar animal' : 'Registrar nuevo animal',
            ),
            titleSpacing: 0,
            actions: [
              TextButton.icon(
                onPressed: _showRegistrationHelp,
                icon: const Icon(Icons.help_outline),
                label: Text(widget.isEdit ? 'Editar' : 'Ayuda'),
              ),
            ],
          ),
          body: _loading
              ? const Center(child: CircularProgressIndicator())
              : SafeArea(
                  child: Column(
                    children: [
                      Expanded(
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.fromLTRB(0, 6, 0, 12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [_buildStepper(), _buildCurrentStep()],
                          ),
                        ),
                      ),
                      if (!keyboardVisible) _buildBottomBar(),
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
      padding: const EdgeInsets.fromLTRB(4, 4, 4, 16),
      child: Column(
        children: [
          // ── circles + connectors ─────────────────────────────────
          SizedBox(
            height: 30,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // flex:1 half-slot en cada extremo + flex:2 por conector
                // las líneas corren exactamente de centro a centro de círculo
                Row(
                  children: [
                    const Expanded(flex: 1, child: SizedBox.shrink()),
                    ...List.generate(_stepLabels.length - 1, (i) {
                      final done = i < _currentStep;
                      return Expanded(
                        flex: 2,
                        child: Container(
                          height: 2,
                          color: done
                              ? colorScheme.primary
                              : colorScheme.outline.withValues(alpha: 0.4),
                        ),
                      );
                    }),
                    const Expanded(flex: 1, child: SizedBox.shrink()),
                  ],
                ),
                // circles: each centered in an equal Expanded slot
                Row(
                  children: List.generate(_stepLabels.length, (stepIndex) {
                    final completed = stepIndex < _currentStep;
                    final active = stepIndex == _currentStep;
                    return Expanded(
                      child: Center(
                        child: Container(
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
                                ? const Icon(
                                    Icons.check,
                                    color: Colors.white,
                                    size: 16,
                                  )
                                : Text(
                                    '${stepIndex + 1}',
                                    style: theme.textTheme.labelMedium
                                        ?.copyWith(
                                          color: active
                                              ? Colors.white
                                              : colorScheme.onSurfaceVariant,
                                          fontWeight: FontWeight.w700,
                                        ),
                                  ),
                          ),
                        ),
                      ),
                    );
                  }),
                ),
              ],
            ),
          ),
          const SizedBox(height: 6),
          // ── labels ────────────────────────────────────────────────
          Row(
            children: List.generate(_stepLabels.length, (stepIndex) {
              final active = stepIndex == _currentStep;
              return Expanded(
                child: Text(
                  _stepLabels[stepIndex],
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontSize: active ? 10 : 9,
                    fontWeight: active ? FontWeight.w700 : FontWeight.w400,
                    color: active
                        ? colorScheme.primary
                        : colorScheme.onSurfaceVariant,
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
        return _buildStep4();
      case 3:
        return _buildStep3();
      default:
        return _buildStep5();
    }
  }

  Widget _buildStep1() {
    final theme = Theme.of(context);
    final policy = _policy;
    return Form(
      key: _step1FormKey,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle(
              'Informacion basica',
              Icons.badge_outlined,
              subtitle: 'Ingresa los datos generales del animal.',
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final wide = constraints.maxWidth >= 600;
                    Widget pair(Widget first, Widget second) {
                      if (!wide) {
                        return Column(
                          children: [first, const SizedBox(height: 12), second],
                        );
                      }
                      return Row(
                        children: [
                          Expanded(child: first),
                          const SizedBox(width: 12),
                          Expanded(child: second),
                        ],
                      );
                    }

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Especie', style: theme.textTheme.labelLarge),
                        const SizedBox(height: 8),
                        AnimalSpeciesSelector(
                          value: _species,
                          onChanged: _onSpeciesChanged,
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _earTagCtrl,
                          textCapitalization: TextCapitalization.characters,
                          decoration: InputDecoration(
                            labelText: policy.identificationLabel,
                            hintText: policy.identificationHint,
                            helperText: policy.tracksPendingEarTag
                                ? 'Recomendado. Puedes dejarlo pendiente.'
                                : 'Opcional',
                            suffixIcon: const Icon(
                              Icons.qr_code_scanner_outlined,
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _nameCtrl,
                          textCapitalization: TextCapitalization.words,
                          decoration: const InputDecoration(
                            labelText: 'Nombre o alias — opcional',
                            hintText: 'Ej. Manchas, Estrella, etc.',
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text('Sexo', style: theme.textTheme.labelLarge),
                        const SizedBox(height: 8),
                        CompactSexSelector(
                          value: _sex,
                          onChanged: _onSexChanged,
                        ),
                        const SizedBox(height: 16),
                        SegmentedButton<_BirthInputMode>(
                          segments: const [
                            ButtonSegment(
                              value: _BirthInputMode.approximate,
                              icon: Icon(Icons.cake_outlined),
                              label: Text('Edad aproximada'),
                            ),
                            ButtonSegment(
                              value: _BirthInputMode.exact,
                              icon: Icon(Icons.calendar_month_outlined),
                              label: Text('Fecha exacta'),
                            ),
                          ],
                          selected: {_birthInputMode},
                          onSelectionChanged: (values) {
                            _changeBirthInputMode(values.first);
                          },
                        ),
                        const SizedBox(height: 12),
                        if (_birthInputMode == _BirthInputMode.approximate)
                          ApproximateAgeField(
                            value: _approximateAge,
                            onChanged: _onApproximateAgeChanged,
                          )
                        else
                          InkWell(
                            borderRadius: BorderRadius.circular(12),
                            onTap: _pickBirthDate,
                            child: InputDecorator(
                              decoration: const InputDecoration(
                                labelText: 'Fecha de nacimiento',
                                suffixIcon: Icon(Icons.calendar_month_outlined),
                              ),
                              child: Text(
                                _birthDate == null
                                    ? 'Selecciona la fecha'
                                    : _formatDate(_birthDate!),
                                style: _birthDate == null
                                    ? TextStyle(color: theme.hintColor)
                                    : null,
                              ),
                            ),
                          ),
                        const SizedBox(height: 12),
                        DropdownButtonFormField<Category>(
                          key: ValueKey(
                            'category-${_species.name}-${_sex.name}-'
                            '${_currentAgeMonths()}-${_category.name}',
                          ),
                          initialValue: _category,
                          decoration: const InputDecoration(
                            labelText: 'Categoría sugerida',
                            helperText: 'Se ajusta según especie, sexo y edad.',
                          ),
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
                            setState(() => _category = value);
                            _scheduleDraftSave();
                          },
                        ),
                        const SizedBox(height: 12),
                        pair(
                          TextFormField(
                            controller: _breedCtrl,
                            textCapitalization: TextCapitalization.words,
                            decoration: const InputDecoration(
                              labelText: 'Raza — opcional',
                              hintText: 'Ej. Angus',
                            ),
                          ),
                          TextFormField(
                            controller: _crossBreedCtrl,
                            textCapitalization: TextCapitalization.words,
                            decoration: const InputDecoration(
                              labelText: 'Segunda raza / cruza — opcional',
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        pair(
                          TextFormField(
                            controller: _coatColorCtrl,
                            decoration: InputDecoration(
                              labelText: '${policy.coatLabel} — opcional',
                            ),
                          ),
                          TextFormField(
                            controller: _weightCtrl,
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                            decoration: const InputDecoration(
                              labelText: 'Peso inicial (kg) — opcional',
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        ExpansionTile(
                          tilePadding: EdgeInsets.zero,
                          title: const Text('Detalles adicionales'),
                          subtitle: const Text('Señas, observaciones y estado'),
                          children: [
                            TextFormField(
                              controller: _distinguishingMarksCtrl,
                              maxLength: 120,
                              decoration: const InputDecoration(
                                labelText: 'Señas particulares',
                              ),
                            ),
                            const SizedBox(height: 8),
                            TextFormField(
                              controller: _notesCtrl,
                              maxLines: 3,
                              maxLength: 300,
                              decoration: const InputDecoration(
                                labelText: 'Observaciones',
                              ),
                            ),
                            const SizedBox(height: 12),
                            DropdownButtonFormField<AnimalStatus>(
                              initialValue: _status,
                              decoration: const InputDecoration(
                                labelText: 'Estado',
                              ),
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
                                setState(() => _status = value);
                                _scheduleDraftSave();
                              },
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        OutlinedButton.icon(
                          onPressed: _pickRegistrationDate,
                          icon: const Icon(Icons.event_available_outlined),
                          label: Text(
                            'Fecha de registro: '
                            '${_formatDate(_registrationDate)}',
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStep2() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final usePairs = constraints.maxWidth >= 600;
          Widget pair(Widget first, Widget second) {
            if (!usePairs) {
              return Column(
                children: [first, const SizedBox(height: 12), second],
              );
            }
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: first),
                const SizedBox(width: 12),
                Expanded(child: second),
              ],
            );
          }

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
                  setState(() => _originType = value.first);
                  _scheduleDraftSave();
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
                  setState(() => _selectedProvenanceUuid = value);
                  _scheduleDraftSave();
                },
              ),
              const SizedBox(height: 12),
              pair(
                DropdownButtonFormField<String>(
                  isExpanded: true,
                  initialValue: _selectedDamUuid,
                  decoration: const InputDecoration(
                    labelText: 'Madre (opcional)',
                  ),
                  items: _eligibleMothers
                      .map(
                        (animal) => DropdownMenuItem(
                          value: animal.uuid,
                          child: Text(_animalLabel(animal)),
                        ),
                      )
                      .toList(),
                  onChanged: (value) {
                    setState(() => _selectedDamUuid = value);
                    _scheduleDraftSave();
                  },
                ),
                DropdownButtonFormField<String>(
                  isExpanded: true,
                  initialValue: _selectedSireUuid,
                  decoration: const InputDecoration(
                    labelText: 'Padre (opcional)',
                  ),
                  items: _eligibleFathers
                      .map(
                        (animal) => DropdownMenuItem(
                          value: animal.uuid,
                          child: Text(_animalLabel(animal)),
                        ),
                      )
                      .toList(),
                  onChanged: (value) {
                    setState(() => _selectedSireUuid = value);
                    _scheduleDraftSave();
                  },
                ),
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
              const SizedBox(height: 8),
              ExpansionTile(
                tilePadding: EdgeInsets.zero,
                childrenPadding: const EdgeInsets.only(bottom: 8),
                leading: const Icon(Icons.bubble_chart_outlined),
                title: const Text('Genética avanzada'),
                subtitle: const Text('Opcional'),
                children: [
                  pair(
                    TextFormField(
                      controller: _crossBreedTypeCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Tipo de cruzamiento',
                      ),
                    ),
                    TextFormField(
                      controller: _sireBreedCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Raza del padre',
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  pair(
                    TextFormField(
                      controller: _damBreedCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Raza de la madre',
                      ),
                    ),
                    TextFormField(
                      controller: _bloodPercentageCtrl,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Porcentaje de sangre',
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _genealogicalRegistryCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Registro genealógico',
                    ),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildStep3() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: Column(
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
                    child: Text(lote.name),
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
          DropdownButtonFormField<ProductionPurpose>(
            initialValue: _productionPurpose,
            decoration: const InputDecoration(
              labelText: 'Propósito de producción',
            ),
            items: [
              const DropdownMenuItem(
                value: ProductionPurpose.undefined,
                child: Text('Sin asignar'),
              ),
              ..._policy.purposeOptions.map(
                (value) => DropdownMenuItem(
                  value: value,
                  child: Text(value.displayName),
                ),
              ),
              if (widget.isEdit &&
                  _productionPurpose != ProductionPurpose.undefined &&
                  !_policy.purposeOptions.contains(_productionPurpose))
                DropdownMenuItem(
                  value: _productionPurpose,
                  child: Text('${_productionPurpose.displayName} (existente)'),
                ),
            ],
            onChanged: (value) {
              if (value == null) return;
              setState(() {
                _productionPurpose = value;
              });
            },
          ),
          const SizedBox(height: 12),
          if (_policy.productionSystems.isNotEmpty) ...[
            DropdownButtonFormField<ProductionSystem>(
              key: ValueKey('system-${_species.name}'),
              initialValue: _productionSystem,
              decoration: const InputDecoration(labelText: 'Sistema de manejo'),
              items: [
                ..._policy.productionSystems.map(
                  (value) => DropdownMenuItem(
                    value: value,
                    child: Text(value.displayName),
                  ),
                ),
                if (widget.isEdit &&
                    !_policy.productionSystems.contains(_productionSystem))
                  DropdownMenuItem(
                    value: _productionSystem,
                    child: Text('${_productionSystem.displayName} (existente)'),
                  ),
              ],
              onChanged: (value) {
                if (value == null) return;
                setState(() {
                  _productionSystem = value;
                });
              },
            ),
            const SizedBox(height: 12),
          ],
          _responsiveFieldPair(
            _buildSimpleSelection(
              label: 'Tipo de alojamiento',
              value: _housingType,
              options: [
                ..._policy.housingOptions,
                if (widget.isEdit &&
                    !_policy.housingOptions.contains(_housingType))
                  _housingType,
              ],
              onSelected: (value) {
                setState(() {
                  _housingType = value;
                });
                _scheduleDraftSave();
              },
            ),
            _buildSimpleSelection(
              label: 'Disponibilidad de sombra',
              value: _shadingAvailability,
              options: const ['Nula', 'Parcial', 'Amplia'],
              onSelected: (value) {
                setState(() {
                  _shadingAvailability = value;
                });
                _scheduleDraftSave();
              },
            ),
          ),
          const SizedBox(height: 12),
          _responsiveFieldPair(
            _buildSimpleSelection(
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
                _scheduleDraftSave();
              },
            ),
            TextFormField(
              controller: _approximateDensityCtrl,
              decoration: const InputDecoration(
                labelText: 'Densidad aproximada',
              ),
            ),
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
          _responsiveFieldPair(
            TextFormField(
              controller: _feedTypeCtrl,
              decoration: const InputDecoration(
                labelText: 'Tipo de alimentacion',
              ),
            ),
            _buildSimpleSelection(
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
                _scheduleDraftSave();
              },
            ),
          ),
          const SizedBox(height: 12),
          _responsiveFieldPair(
            _buildSimpleSelection(
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
                _scheduleDraftSave();
              },
            ),
            TextFormField(
              controller: _feedNotesCtrl,
              decoration: const InputDecoration(labelText: 'Observaciones'),
            ),
          ),
          const SizedBox(height: 16),
          _buildSectionTitle('Identificacion adicional', Icons.sell_outlined),
          const SizedBox(height: 12),
          if (_policy.supportsEarTagColor)
            _responsiveFieldPair(
              _buildSimpleSelection(
                label: 'Color de arete',
                value: _earTagColor,
                options: const ['Amarillo', 'Rojo', 'Azul', 'Verde', 'Blanco'],
                onSelected: (value) {
                  setState(() {
                    _earTagColor = value;
                  });
                  _scheduleDraftSave();
                },
              ),
              TextFormField(
                controller: _visualIdCtrl,
                decoration: const InputDecoration(
                  labelText: 'Número de arete visual',
                ),
              ),
            )
          else
            TextFormField(
              controller: _visualIdCtrl,
              decoration: InputDecoration(
                labelText: '${_policy.identificationLabel} visible',
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildStep4() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: Column(
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
          if (_sex == Sex.male && _policy.supportsCastration) ...[
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Castrado'),
              subtitle: const Text(
                'Activa si el animal fue castrado (novillo/buey)',
              ),
              value: _reproductiveStatus == ReproductiveStatus.neutered,
              onChanged: (value) {
                setState(() {
                  _reproductiveStatus = value
                      ? ReproductiveStatus.neutered
                      : ReproductiveStatus.active;
                  _synchronizeTaxonomy();
                });
                _scheduleDraftSave();
              },
            ),
            const SizedBox(height: 4),
          ],
          if (_policy.supportsBodyConditionScore) ...[
            Text(
              'Condición corporal (1–5)',
              style: Theme.of(context).textTheme.labelLarge,
            ),
            const SizedBox(height: 8),
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
          ],
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
          if (_showReproductionSection) ...[
            const SizedBox(height: 12),
            _buildReproductionSection(),
          ],
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
      ),
    );
  }

  Widget _buildStep5() {
    final healthTuple = _resolveHealthFlags();

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('Revision del registro', Icons.checklist_outlined),
          const SizedBox(height: 12),
          _buildReviewCard(
            title: 'Informacion basica',
            onEdit: () => setState(() => _currentStep = 0),
            rows: [
              _ReviewRow(
                _policy.identificationLabel,
                _earTagCtrl.text.trim().isEmpty
                    ? (_policy.tracksPendingEarTag
                          ? 'Pendiente'
                          : 'Sin identificación')
                    : _safeText(_earTagCtrl.text),
              ),
              _ReviewRow('Nombre', _safeText(_nameCtrl.text)),
              _ReviewRow('Especie', _species.displayName),
              _ReviewRow('Categoria', _category.displayName),
              _ReviewRow('Raza', _safeText(_breedCtrl.text)),
              _ReviewRow('Cruza', _safeText(_crossBreedCtrl.text)),
              _ReviewRow('Sexo', _sex.displayName),
              _ReviewRow(
                'Estado reproductivo',
                _reproductiveStatus.displayName,
              ),
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
            onEdit: () => setState(() => _currentStep = 1),
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
            onEdit: () => setState(() => _currentStep = 3),
            rows: [
              _ReviewRow('Rancho', _locationNameByUuid(_selectedRanchUuid)),
              _ReviewRow(
                'Potrero/Corral',
                _locationNameByUuid(_selectedPaddockUuid),
              ),
              _ReviewRow('Lote', _loteNameByUuid(_selectedBatchUuid)),
              _ReviewRow(
                'Propósito',
                _productionPurpose == ProductionPurpose.undefined
                    ? 'Sin asignar'
                    : _productionPurpose.displayName,
              ),
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
            onEdit: () => setState(() => _currentStep = 2),
            rows: [
              _ReviewRow(
                'Estado sanitario',
                healthTuple.healthStatus.displayName,
              ),
              if (_policy.supportsBodyConditionScore)
                _ReviewRow('Condición corporal', '$_bodyConditionScore'),
              _ReviewRow('Riesgo', healthTuple.riskLevel.displayName),
              _ReviewRow('Tipo de alimentacion', _safeText(_feedTypeCtrl.text)),
              _ReviewRow('Tratamientos', '${_treatments.length}'),
              _ReviewRow('Vacunas', '${_vaccinations.length}'),
              _ReviewRow('Examenes', '${_exams.length}'),
              if (_showReproductionSection)
                _ReviewRow(
                  'Reproducción',
                  '${_reproductions.length} registro(s)',
                ),
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
      ),
    );
  }

  Widget _buildBottomBar() {
    final isFirstStep = _currentStep == 0;
    final isLastStep = _currentStep == _stepLabels.length - 1;
    final canFinish = _canFinishRegistration;

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
                    label: const Text('Guardar borrador'),
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
                  ? (canFinish ? _onSave : null)
                  : _onNextStep,
              icon: Icon(
                isLastStep ? Icons.save_outlined : Icons.arrow_forward,
              ),
              label: Text(
                _saving
                    ? 'Guardando...'
                    : isLastStep
                    ? 'Guardar animal'
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

  Widget _responsiveFieldPair(Widget first, Widget second) {
    if (MediaQuery.sizeOf(context).width < 600) {
      return Column(children: [first, const SizedBox(height: 12), second]);
    }
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: first),
        const SizedBox(width: 12),
        Expanded(child: second),
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
      isExpanded: true,
      initialValue: value,
      decoration: InputDecoration(
        label: Text(label, maxLines: 1, overflow: TextOverflow.ellipsis),
      ),
      items: options
          .map(
            (option) => DropdownMenuItem(
              value: option,
              child: Text(option, maxLines: 1, overflow: TextOverflow.ellipsis),
            ),
          )
          .toList(),
      onChanged: (selected) {
        if (selected == null) return;
        onSelected(selected);
      },
    );
  }

  // ─── Reproduction section ────────────────────────────────────────────────

  String _serviceTypeLabel(ServiceType t) {
    switch (t) {
      case ServiceType.naturalService:
        return 'Monta natural';
      case ServiceType.artificialInsemination:
        return 'Inseminación artificial';
      case ServiceType.ivf:
        return 'FIV';
    }
  }

  String _pregnancyResultLabel(PregnancyCheckResult? r) {
    switch (r) {
      case PregnancyCheckResult.positive:
        return 'Positivo';
      case PregnancyCheckResult.negative:
        return 'Negativo';
      case PregnancyCheckResult.uncertain:
        return 'Incierto';
      case PregnancyCheckResult.notChecked:
      case null:
        return 'No verificado';
    }
  }

  Widget _buildReproductionSection() {
    final isFemale = _sex == Sex.female;
    final title = isFemale ? 'Eventos reproductivos' : 'Registros de servicio';
    final subtitle = isFemale
        ? 'Agrega montas, inseminaciones o chequeos de preñez previos.'
        : 'Registra servicios o montas realizados por este animal.';

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.favorite_border,
                  size: 18,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    title,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                OutlinedButton.icon(
                  onPressed: () => _openAddReproductionDialog(isFemale),
                  icon: const Icon(Icons.add, size: 16),
                  label: const Text('Agregar'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    visualDensity: VisualDensity.compact,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: Colors.grey),
            ),
            if (_reproductions.isEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  'Sin registros. Opcional.',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              )
            else ...[
              const SizedBox(height: 8),
              ...List.generate(_reproductions.length, (i) {
                final r = _reproductions[i];
                final subtitle = isFemale
                    ? '${_serviceTypeLabel(r.serviceType)}  ·  ${_pregnancyResultLabel(r.pregnancyResult)}'
                    : _serviceTypeLabel(r.serviceType);
                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.favorite, color: Colors.pink),
                  title: Text(_formatDate(r.serviceDate)),
                  subtitle: Text(subtitle),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete_outline, size: 20),
                    onPressed: () => setState(() => _reproductions.removeAt(i)),
                  ),
                );
              }),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _openAddReproductionDialog(bool isFemale) async {
    var serviceType = ServiceType.naturalService;
    var serviceDate = DateTime.now();
    final sireIdCtrl = TextEditingController();
    final notesCtrl = TextEditingController();
    PregnancyCheckResult? pregnancyResult;
    DateTime? expectedCalvingDate;

    final added = await showDialog<bool>(
      context: context,
      useRootNavigator: true,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (dialogContext, setDialogState) {
            return AlertDialog(
              title: Text(
                isFemale ? 'Agregar evento reproductivo' : 'Agregar servicio',
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    DropdownButtonFormField<ServiceType>(
                      initialValue: serviceType,
                      decoration: const InputDecoration(
                        labelText: 'Tipo de servicio',
                        border: OutlineInputBorder(),
                      ),
                      items: ServiceType.values
                          .map(
                            (t) => DropdownMenuItem(
                              value: t,
                              child: Text(_serviceTypeLabel(t)),
                            ),
                          )
                          .toList(),
                      onChanged: (v) {
                        if (v != null) setDialogState(() => serviceType = v);
                      },
                    ),
                    const SizedBox(height: 12),
                    InkWell(
                      onTap: () async {
                        final now = DateTime.now();
                        final picked = await showDatePicker(
                          context: dialogContext,
                          initialDate: serviceDate,
                          firstDate: DateTime(now.year - 20),
                          lastDate: now,
                        );
                        if (picked != null) {
                          setDialogState(() => serviceDate = picked);
                        }
                      },
                      child: InputDecorator(
                        decoration: const InputDecoration(
                          labelText: 'Fecha del servicio',
                          border: OutlineInputBorder(),
                          suffixIcon: Icon(Icons.calendar_today, size: 18),
                        ),
                        child: Text(_formatDate(serviceDate)),
                      ),
                    ),
                    if (isFemale) ...[
                      const SizedBox(height: 12),
                      TextField(
                        controller: sireIdCtrl,
                        decoration: const InputDecoration(
                          labelText: 'ID del semental (opcional)',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<PregnancyCheckResult?>(
                        initialValue: pregnancyResult,
                        decoration: const InputDecoration(
                          labelText: 'Resultado de chequeo de preñez',
                          border: OutlineInputBorder(),
                        ),
                        items: [
                          const DropdownMenuItem(
                            value: null,
                            child: Text('No verificado'),
                          ),
                          ...PregnancyCheckResult.values.map(
                            (r) => DropdownMenuItem(
                              value: r,
                              child: Text(_pregnancyResultLabel(r)),
                            ),
                          ),
                        ],
                        onChanged: (v) {
                          setDialogState(() {
                            pregnancyResult = v;
                            if (v != PregnancyCheckResult.positive) {
                              expectedCalvingDate = null;
                            }
                          });
                        },
                      ),
                      if (pregnancyResult == PregnancyCheckResult.positive) ...[
                        const SizedBox(height: 12),
                        InkWell(
                          onTap: () async {
                            final now = DateTime.now();
                            final picked = await showDatePicker(
                              context: dialogContext,
                              initialDate:
                                  expectedCalvingDate ??
                                  now.add(const Duration(days: 283)),
                              firstDate: now.subtract(const Duration(days: 30)),
                              lastDate: now.add(const Duration(days: 365)),
                            );
                            if (picked != null) {
                              setDialogState(
                                () => expectedCalvingDate = picked,
                              );
                            }
                          },
                          child: InputDecorator(
                            decoration: const InputDecoration(
                              labelText: 'Fecha esperada de parto',
                              border: OutlineInputBorder(),
                              suffixIcon: Icon(Icons.calendar_today, size: 18),
                            ),
                            child: Text(
                              expectedCalvingDate != null
                                  ? _formatDate(expectedCalvingDate!)
                                  : 'Seleccionar',
                            ),
                          ),
                        ),
                      ],
                    ],
                    const SizedBox(height: 12),
                    TextField(
                      controller: notesCtrl,
                      maxLines: 2,
                      maxLength: 200,
                      decoration: const InputDecoration(
                        labelText: 'Notas (opcional)',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(false),
                  child: const Text('Cancelar'),
                ),
                FilledButton(
                  onPressed: () => Navigator.of(dialogContext).pop(true),
                  child: const Text('Guardar'),
                ),
              ],
            );
          },
        );
      },
    );

    final sireIdText = sireIdCtrl.text.trim().isEmpty
        ? null
        : sireIdCtrl.text.trim();
    final notesText = notesCtrl.text.trim().isEmpty
        ? null
        : notesCtrl.text.trim();
    sireIdCtrl.dispose();
    notesCtrl.dispose();

    if (added == true && mounted) {
      setState(() {
        _reproductions.add(
          _ReproductionDraft(
            serviceDate: serviceDate,
            serviceType: serviceType,
            maleSireIdentifier: sireIdText,
            pregnancyResult: pregnancyResult,
            expectedCalvingDate: expectedCalvingDate,
            notes: notesText,
          ),
        );
      });
    }
  }

  // ─────────────────────────────────────────────────────────────────────────

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
    required VoidCallback onEdit,
  }) {
    final visibleRows = rows.where((row) => row.value != '--').toList();
    if (visibleRows.isEmpty) return const SizedBox.shrink();
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                TextButton(onPressed: onEdit, child: const Text('Editar')),
              ],
            ),
            const SizedBox(height: 8),
            ...visibleRows.map(
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
      useRootNavigator: true,
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

  int _currentAgeMonths() {
    if (_birthInputMode == _BirthInputMode.approximate) {
      return _approximateAge.totalMonths;
    }
    final birthDate = _birthDate;
    if (birthDate == null) return _approximateAge.totalMonths;
    return AnimalLifecycleCalculator.calculate(
      birthDate: birthDate,
      species: _species,
      sex: _sex,
    ).ageMonths;
  }

  void _synchronizeTaxonomy() {
    final ageMonths = _currentAgeMonths();
    final categories = AnimalTaxonomy.categoriesFor(
      species: _species,
      sex: _sex,
      ageMonths: ageMonths,
      neutered: _reproductiveStatus == ReproductiveStatus.neutered,
    );
    if (!categories.contains(_category)) {
      _category = AnimalTaxonomy.defaultCategory(
        species: _species,
        sex: _sex,
        ageMonths: ageMonths,
        neutered: _reproductiveStatus == ReproductiveStatus.neutered,
      );
    }
  }

  void _onSpeciesChanged(Species species) {
    setState(() {
      _species = species;
      if (!widget.isEdit) {
        _selectedDamUuid = null;
        _selectedSireUuid = null;
        if (!_policy.purposeOptions.contains(_productionPurpose)) {
          _productionPurpose = ProductionPurpose.undefined;
        }
        if (_policy.productionSystems.isNotEmpty &&
            !_policy.productionSystems.contains(_productionSystem)) {
          _productionSystem = _policy.productionSystems.first;
        }
        if (_policy.housingOptions.isNotEmpty &&
            !_policy.housingOptions.contains(_housingType)) {
          _housingType = _policy.housingOptions.first;
        }
      }
      _synchronizeTaxonomy();
      if (!_policy.supportsEarTagColor) {
        _earTagColor = 'Amarillo';
      }
    });
    _scheduleDraftSave();
  }

  void _onSexChanged(Sex sex) {
    setState(() {
      _sex = sex;
      if (sex == Sex.female &&
          _reproductiveStatus == ReproductiveStatus.neutered) {
        _reproductiveStatus = ReproductiveStatus.unknown;
      }
      _synchronizeTaxonomy();
    });
    _scheduleDraftSave();
  }

  void _onApproximateAgeChanged(ApproximateAge age) {
    setState(() {
      _approximateAge = age;
      _ageMonthsCtrl.text = age.totalMonths.toString();
      _birthDate = null;
      _synchronizeTaxonomy();
    });
    _scheduleDraftSave();
  }

  void _changeBirthInputMode(_BirthInputMode mode) {
    if (mode == _birthInputMode) return;
    setState(() {
      if (mode == _BirthInputMode.approximate) {
        final birthDate = _birthDate;
        if (birthDate != null) {
          final lifecycle = AnimalLifecycleCalculator.calculate(
            birthDate: birthDate,
            species: _species,
            sex: _sex,
          );
          _approximateAge = ApproximateAge.fromTotalMonths(lifecycle.ageMonths);
          _ageMonthsCtrl.text = _approximateAge.totalMonths.toString();
        }
        _birthDate = null;
      } else {
        _birthDate = _approximateAge.estimatedBirthDate();
        _ageMonthsCtrl.clear();
      }
      _birthInputMode = mode;
      _synchronizeTaxonomy();
    });
    _scheduleDraftSave();
  }

  // ─────────────────────────────────────────────────────────────────────────

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
      final lifecycle = AnimalLifecycleCalculator.calculate(
        birthDate: picked,
        species: _species,
        sex: _sex,
      );
      _approximateAge = ApproximateAge.fromTotalMonths(lifecycle.ageMonths);
      _ageMonthsCtrl.clear();
      _synchronizeTaxonomy();
    });
    _scheduleDraftSave();
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

      if (_policy.tracksPendingEarTag && _earTagCtrl.text.trim().isEmpty) {
        final continueWithoutEarTag = await _confirmMissingEarTag();
        if (!mounted || !continueWithoutEarTag) return;
      } else {
        final duplicated = await _isEarTagDuplicated(_earTagCtrl.text.trim());
        if (duplicated && mounted) {
          _showMessage('El arete ya existe en otro registro.');
          return;
        }
      }
    }

    if (_currentStep >= _stepLabels.length - 1) return;

    setState(() {
      _currentStep += 1;
    });
    await _persistDraft();
  }

  Future<void> _onAttemptExit() async {
    if (_saving) return;

    final discard = await _confirmDiscardDialog(
      title: 'Salir del registro',
      message:
          'Si sales ahora, se guardara un borrador para que puedas continuar despues.\n\nQuieres salir?',
      confirmLabel: 'Salir',
    );

    if (!mounted || !discard) return;

    if (widget.isEdit) {
      Navigator.of(context).pop(false);
      return;
    }

    final saved = await _persistDraft();
    if (!mounted) return;
    if (!saved) {
      _showMessage('No se pudo guardar el borrador. Intenta de nuevo.');
      return;
    }

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
    'ageMonths': _ageMonthsCtrl.text,
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
    'productionPurpose': _productionPurpose.name,
    'healthMode': _healthMode.name,
    'reproductiveStatus': _reproductiveStatus.name,
    // Dates
    'birthDate': _birthDate?.toIso8601String(),
    'birthInputMode': _birthInputMode.name,
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
    'reproductions': _reproductions.map((r) => r.toMap()).toList(),
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
      useRootNavigator: true,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: const Text('Borrador encontrado'),
        content: const Text(
          'Encontramos un borrador del registro anterior. Puedes continuar donde te quedaste o iniciar de nuevo.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop('discard'),
            child: const Text('Iniciar de nuevo'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop('restore'),
            child: const Text('Continuar'),
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

    List<_ReproductionDraft> parseReproductionRecords(dynamic raw) {
      if (raw is! List) return [];
      final result = <_ReproductionDraft>[];
      for (final item in raw) {
        if (item is Map<String, dynamic>) {
          try {
            result.add(_ReproductionDraft.fromMap(item));
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
      _ageMonthsCtrl.text = (m['ageMonths'] as String?) ?? '';
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
      _productionPurpose = safeEnum(
        ProductionPurpose.values,
        m['productionPurpose'] as String?,
        _productionPurpose,
      );
      _healthMode = safeEnum(
        _InitialHealthMode.values,
        m['healthMode'] as String?,
        _healthMode,
      );
      _reproductiveStatus = safeEnum(
        ReproductiveStatus.values,
        m['reproductiveStatus'] as String?,
        _reproductiveStatus,
      );
      // Dates
      final birthStr = m['birthDate'] as String?;
      _birthDate = birthStr != null ? DateTime.tryParse(birthStr) : null;
      _birthInputMode = safeEnum(
        _BirthInputMode.values,
        m['birthInputMode'] as String?,
        _birthDate == null
            ? _BirthInputMode.approximate
            : _BirthInputMode.exact,
      );
      final draftAge = _parseOptionalInt(_ageMonthsCtrl.text);
      if (draftAge != null) {
        _approximateAge = ApproximateAge.fromTotalMonths(draftAge);
      } else if (_birthDate != null) {
        final lifecycle = AnimalLifecycleCalculator.calculate(
          birthDate: _birthDate!,
          species: _species,
          sex: _sex,
        );
        _approximateAge = ApproximateAge.fromTotalMonths(lifecycle.ageMonths);
      }
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
      _reproductions
        ..clear()
        ..addAll(parseReproductionRecords(m['reproductions']));
      if (!_policy.purposeOptions.contains(_productionPurpose)) {
        _productionPurpose = ProductionPurpose.undefined;
      }
      if (_policy.productionSystems.isNotEmpty &&
          !_policy.productionSystems.contains(_productionSystem)) {
        _productionSystem = _policy.productionSystems.first;
      }
      if (_policy.housingOptions.isNotEmpty &&
          !_policy.housingOptions.contains(_housingType)) {
        _housingType = _policy.housingOptions.first;
      }
      _synchronizeTaxonomy();
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
    _persistDraft();
  }

  bool get _canFinishRegistration {
    return Species.values.contains(_species) &&
        Category.values.contains(_category);
  }

  bool get _showReproductionSection {
    if (!_policy.supportsReproduction) return false;
    if (_reproductiveStatus == ReproductiveStatus.neutered) return false;
    final minimumAge = switch (_species) {
      Species.cattle => 12,
      Species.equine => 36,
      Species.sheep || Species.goat || Species.pig => 12,
      Species.canine => 18,
      Species.poultry || Species.other => 9999,
    };
    return _currentAgeMonths() >= minimumAge ||
        _productionPurpose == ProductionPurpose.breeding ||
        _category == Category.reproduction;
  }

  Future<void> _onSave() async {
    if (widget.isEdit && _editingAnimal == null) {
      _showMessage('No se encontró el animal para editar.');
      return;
    }

    if (_policy.tracksPendingEarTag && _earTagCtrl.text.trim().isEmpty) {
      final continueWithoutEarTag = await _confirmMissingEarTag();
      if (!mounted || !continueWithoutEarTag) return;
    }

    final birthDate = _birthInputMode == _BirthInputMode.exact
        ? (_birthDate ?? _approximateAge.estimatedBirthDate())
        : _approximateAge.estimatedBirthDate();

    final weight = _parseOptionalDouble(_weightCtrl.text);
    if (_weightCtrl.text.trim().isNotEmpty && weight == null) {
      _showMessage('El peso inicial no es valido.');
      return;
    }

    final manualAgeMonths = _birthInputMode == _BirthInputMode.approximate
        ? _approximateAge.totalMonths
        : null;

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
    final resolvedAgeMonths = manualAgeMonths ?? lifecycle.ageMonths;
    final resolvedLifeStage = AnimalTaxonomy.resolveLifeStage(
      species: _species,
      sex: _sex,
      ageMonths: resolvedAgeMonths,
      category: _category,
      fallback: lifecycle.lifeStage,
    );

    // Derive reproductive entity fields from reproduction drafts
    final derivedFirstService = _reproductions.isNotEmpty
        ? _reproductions
              .map((r) => r.serviceDate)
              .reduce((a, b) => a.isBefore(b) ? a : b)
        : null;
    final derivedLastService = _reproductions.isNotEmpty
        ? _reproductions
              .map((r) => r.serviceDate)
              .reduce((a, b) => a.isAfter(b) ? a : b)
        : null;
    final derivedCalvingDate = _reproductions
        .where(
          (r) =>
              r.pregnancyResult == PregnancyCheckResult.positive &&
              r.expectedCalvingDate != null,
        )
        .lastOrNull
        ?.expectedCalvingDate;
    final derivedReproStatus = () {
      if (_sex == Sex.female && _reproductions.isNotEmpty) {
        if (_reproductions.any(
          (r) => r.pregnancyResult == PregnancyCheckResult.positive,
        )) {
          return ReproductiveStatus.pregnant;
        }
        if (_reproductiveStatus == ReproductiveStatus.unknown) {
          return ReproductiveStatus.active;
        }
      }
      return _reproductiveStatus;
    }();

    final now = DateTime.now();
    final uuid = widget.isEdit ? _editingAnimal!.uuid : 'ani-${generateId()}';
    final healthTuple = _resolveHealthFlags();
    final normalizedName = _nullableText(_nameCtrl.text);
    final normalizedVisualId =
        _nullableText(_visualIdCtrl.text) ?? normalizedName;

    final animal = AnimalRegistrationNormalizer.normalizeEntity(
      widget.isEdit
          ? _editingAnimal!.copyWith(
              earTagNumber: _earTagCtrl.text.trim(),
              customName: normalizedName,
              visualId: normalizedVisualId,
              batchUuid: _selectedBatchUuid,
              species: _species,
              category: _category,
              lifeStage: resolvedLifeStage,
              sex: _sex,
              breed: _breedCtrl.text,
              crossBreed: _nullableText(_crossBreedCtrl.text),
              birthDate: birthDate,
              ageMonths: resolvedAgeMonths,
              weight: weight,
              sireUuid: _selectedSireUuid,
              damUuid: _selectedDamUuid,
              healthStatus: healthTuple.healthStatus,
              bodyConditionScore: _policy.supportsBodyConditionScore
                  ? _bodyConditionScore
                  : _editingAnimal!.bodyConditionScore,
              vaccinated: _vaccinations.isNotEmpty,
              dewormed: _treatments.any(
                (record) => record.type == HealthRecordType.deworming,
              ),
              hasVitamins: _treatments.any(
                (record) => record.type == HealthRecordType.vitamins,
              ),
              hasChronicIssues: _healthMode == _InitialHealthMode.problem,
              chronicNotes: _nullableText(_healthNotesCtrl.text),
              reproductiveStatus: _reproductiveStatus,
              productionPurpose: _productionPurpose,
              productionSystem: _policy.productionSystems.isEmpty
                  ? _editingAnimal!.productionSystem
                  : _productionSystem,
              feedType: _nullableText(_feedTypeCtrl.text),
              coatColor: _nullableText(_coatColorCtrl.text),
              distinguishingMarks: _nullableText(_distinguishingMarksCtrl.text),
              notes: _nullableText(_notesCtrl.text),
              originType: _originType,
              provenance: _selectedProvenanceUuid,
              crossBreedType: _nullableText(_crossBreedTypeCtrl.text),
              sireBreed: _nullableText(_sireBreedCtrl.text),
              damBreed: _nullableText(_damBreedCtrl.text),
              bloodPercentage: bloodPercentage,
              genealogicalRegistry: _nullableText(
                _genealogicalRegistryCtrl.text,
              ),
              originNotes: _nullableText(_originNotesCtrl.text),
              housingType: _nullableText(_housingType),
              shadingAvailability: _nullableText(_shadingAvailability),
              animalWaterSource: _nullableText(_waterSource),
              approximateDensity: _nullableText(_approximateDensityCtrl.text),
              locationNotes: _nullableText(_locationNotesCtrl.text),
              feedFrequency: _nullableText(_feedFrequency),
              feedSupplements: _nullableText(_feedSupplements),
              feedNotes: _nullableText(_feedNotesCtrl.text),
              earTagColor: _policy.supportsEarTagColor
                  ? _nullableText(_earTagColor)
                  : _editingAnimal!.earTagColor,
              currentLocationId: _selectedPaddockUuid,
              initialLocationId:
                  _editingAnimal!.initialLocationId ??
                  _selectedPaddockUuid ??
                  _selectedRanchUuid,
              lastMovementDate: _registrationDate,
              underObservation: healthTuple.underObservation,
              requiresAttention: healthTuple.requiresAttention,
              riskLevel: healthTuple.riskLevel,
              status: _status,
              synced: false,
              lastUpdateDate: now,
            )
          : AnimalEntity(
              id: null,
              uuid: uuid,
              earTagNumber: _earTagCtrl.text.trim(),
              customName: normalizedName,
              visualId: normalizedVisualId,
              brand: null,
              rfidTag: null,
              batchUuid: _selectedBatchUuid,
              species: _species,
              category: _category,
              lifeStage: resolvedLifeStage,
              sex: _sex,
              breed: _breedCtrl.text,
              crossBreed: _nullableText(_crossBreedCtrl.text),
              birthDate: birthDate,
              ageMonths: resolvedAgeMonths,
              weight: weight,
              sireUuid: _selectedSireUuid,
              damUuid: _selectedDamUuid,
              generation: 1,
              healthStatus: healthTuple.healthStatus,
              bodyConditionScore: _policy.supportsBodyConditionScore
                  ? _bodyConditionScore
                  : null,
              vaccinated: _vaccinations.isNotEmpty,
              dewormed: _treatments.any(
                (record) => record.type == HealthRecordType.deworming,
              ),
              hasVitamins: _treatments.any(
                (record) => record.type == HealthRecordType.vitamins,
              ),
              hasChronicIssues: _healthMode == _InitialHealthMode.problem,
              chronicNotes: _nullableText(_healthNotesCtrl.text),
              reproductiveStatus: derivedReproStatus,
              firstServiceDate: derivedFirstService,
              lastServiceDate: derivedLastService,
              expectedCalvingDate: derivedCalvingDate,
              productionPurpose: _productionPurpose,
              productionStage: ProductionStage.unknown,
              productionSystem: _policy.productionSystems.isEmpty
                  ? ProductionSystem.unknown
                  : _productionSystem,
              feedType: _nullableText(_feedTypeCtrl.text),
              dailyGainEstimate: null,
              coatColor: _nullableText(_coatColorCtrl.text),
              distinguishingMarks: _nullableText(_distinguishingMarksCtrl.text),
              notes: _nullableText(_notesCtrl.text),
              originType: _originType,
              provenance: _selectedProvenanceUuid,
              crossBreedType: _nullableText(_crossBreedTypeCtrl.text),
              sireBreed: _nullableText(_sireBreedCtrl.text),
              damBreed: _nullableText(_damBreedCtrl.text),
              bloodPercentage: bloodPercentage,
              genealogicalRegistry: _nullableText(
                _genealogicalRegistryCtrl.text,
              ),
              originNotes: _nullableText(_originNotesCtrl.text),
              housingType: _nullableText(_housingType),
              shadingAvailability: _nullableText(_shadingAvailability),
              animalWaterSource: _nullableText(_waterSource),
              approximateDensity: _nullableText(_approximateDensityCtrl.text),
              locationNotes: _nullableText(_locationNotesCtrl.text),
              feedFrequency: _nullableText(_feedFrequency),
              feedSupplements: _nullableText(_feedSupplements),
              feedNotes: _nullableText(_feedNotesCtrl.text),
              earTagColor: _policy.supportsEarTagColor
                  ? _nullableText(_earTagColor)
                  : null,
              currentLocationId: _selectedPaddockUuid,
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
            ),
    );

    setState(() {
      _saving = true;
    });

    try {
      if (widget.isEdit) {
        // The canonical edit path: diffs lote/ubicación against what is
        // actually persisted, creates the MovementRecord if the location
        // changed, and refreshes the care calendar/agenda — see
        // AnimalEditService for why this replaced a direct `update` call.
        await _animalEditService.applyEdit(
          original: _editingAnimal!,
          draft: animal,
        );
      } else {
        await _animalRepository.save(animal);

        // Registrar movimiento inicial si se asignó una ubicación
        final initialLocation = _selectedPaddockUuid ?? _selectedRanchUuid;
        if (initialLocation != null) {
          await _movementRepo.addMovementRecord(
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
          await _healthRepo.addHealthRecord(
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
        for (final record in _reproductions) {
          await _reproductionRepo.addReproductionRecord(
            uuid,
            ReproductionRecord(
              serviceDate: record.serviceDate,
              serviceType: record.serviceType,
              maleSireIdentifier: record.maleSireIdentifier,
              pregnancyResult: record.pregnancyResult,
              expectedCalvingDate: record.expectedCalvingDate,
              notes: record.notes,
            ),
          );
        }
      }

      if (!mounted) return;
      await _clearDraft();
      if (!mounted) return;
      // Returns the uuid, not just a success flag: the calving flow needs it to
      // link the newborn back to its dam's reproduction record.
      Navigator.of(context).pop(uuid);
    } catch (e) {
      if (!mounted) return;
      final message = e is AnimalEditValidationException
          ? e.message
          : 'No se pudo guardar el animal: $e';
      _showMessage(message);
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
    final filtered = AnimalTaxonomy.categoriesFor(
      species: _species,
      sex: _sex,
      ageMonths: _currentAgeMonths(),
      neutered: _reproductiveStatus == ReproductiveStatus.neutered,
    );
    if (widget.isEdit && !filtered.contains(_category)) {
      return [...filtered, _category];
    }
    return filtered;
  }

  List<LocationEntity> get _ranches {
    return _locations.where((location) => location.type.isRootType).toList();
  }

  /// Candidate parents of [sex], excluding the animal itself and everything
  /// descended from it: offering a daughter as a mother would record the
  /// animal as its own ancestor and turn the pedigree into a cycle.
  ///
  /// [alreadySelectedUuid] is kept in the list while editing so an existing
  /// choice never silently disappears from the dropdown.
  List<AnimalEntity> _eligibleParents(Sex sex, String? alreadySelectedUuid) {
    const pedigree = PedigreeService();
    final editing = _editingAnimal;

    final allowed = editing == null
        ? _animals.where(
            (animal) => animal.species == _species && animal.sex == sex,
          )
        : pedigree.candidateParents(
            herd: _animals,
            sex: sex,
            excluding: editing,
          );

    final result = allowed.toList();
    if (widget.isEdit &&
        alreadySelectedUuid != null &&
        !result.any((animal) => animal.uuid == alreadySelectedUuid)) {
      final selected = _animals
          .where((animal) => animal.uuid == alreadySelectedUuid)
          .toList();
      result.addAll(selected);
    }
    return result;
  }

  List<AnimalEntity> get _eligibleMothers =>
      _eligibleParents(Sex.female, _selectedDamUuid);

  List<AnimalEntity> get _eligibleFathers =>
      _eligibleParents(Sex.male, _selectedSireUuid);

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
                location.type == LocationType.pasture ||
                location.type == LocationType.corral,
          )
          .toList();
    }

    return _locations
        .where(
          (location) =>
              (location.type == LocationType.pasture ||
                  location.type == LocationType.corral) &&
              location.parentUuid == selectedRanchUuid,
        )
        .toList();
  }

  Future<bool> _isEarTagDuplicated(String earTag) async {
    final animals = await _animalRepository.getAll();
    return AnimalRegistrationNormalizer.isDuplicateIdentification(
      candidate: earTag,
      animals: animals,
      excludingUuid: _editingAnimal?.uuid,
    );
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _showRegistrationHelp() {
    return showModalBottomSheet<void>(
      context: context,
      useSafeArea: true,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (sheetContext) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Cómo funciona el registro',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 16),
            const ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Icon(Icons.auto_awesome_outlined),
              title: Text('Adaptado a la especie'),
              subtitle: Text(
                'Categorías, propósitos e identificación cambian '
                'automáticamente.',
              ),
            ),
            const ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Icon(Icons.pending_actions_outlined),
              title: Text('Aretes pendientes'),
              subtitle: Text(
                'En bovinos, ovinos, caprinos y porcinos puedes guardar sin '
                'arete y completarlo después.',
              ),
            ),
            const ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Icon(Icons.save_outlined),
              title: Text('Borrador automático'),
              subtitle: Text(
                'Tus cambios se guardan mientras avanzas para poder continuar '
                'más tarde.',
              ),
            ),
            const ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Icon(Icons.info_outline),
              title: Text('Campos opcionales'),
              subtitle: Text(
                'Nombre, raza y peso pueden completarse ahora o posteriormente.',
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () => Navigator.of(sheetContext).pop(),
                child: const Text('Entendido'),
              ),
            ),
          ],
        ),
      ),
    );
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
      useRootNavigator: true,
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

  Future<bool> _confirmMissingEarTag() {
    return _confirmDiscardDialog(
      title: 'Dejar arete pendiente',
      message:
          'El animal quedará registrado y aparecerá en tus pendientes hasta '
          'que agregues el número de arete.',
      confirmLabel: 'Guardar como pendiente',
    );
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
      if (lote.uuid == uuid) return lote.name;
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

enum _BirthInputMode { approximate, exact }

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

class _ReproductionDraft {
  const _ReproductionDraft({
    required this.serviceDate,
    required this.serviceType,
    this.maleSireIdentifier,
    this.pregnancyResult,
    this.expectedCalvingDate,
    this.notes,
  });

  final DateTime serviceDate;
  final ServiceType serviceType;
  final String? maleSireIdentifier;
  final PregnancyCheckResult? pregnancyResult;
  final DateTime? expectedCalvingDate;
  final String? notes;

  Map<String, dynamic> toMap() => {
    'serviceDate': serviceDate.millisecondsSinceEpoch,
    'serviceType': serviceType.name,
    'maleSireIdentifier': maleSireIdentifier,
    'pregnancyResult': pregnancyResult?.name,
    'expectedCalvingDate': expectedCalvingDate?.millisecondsSinceEpoch,
    'notes': notes,
  };

  static _ReproductionDraft fromMap(Map<String, dynamic> map) {
    ServiceType parsedType;
    try {
      parsedType = ServiceType.values.byName(
        (map['serviceType'] as String?) ?? 'naturalService',
      );
    } catch (_) {
      parsedType = ServiceType.naturalService;
    }
    PregnancyCheckResult? parsedResult;
    final resultName = map['pregnancyResult'] as String?;
    if (resultName != null) {
      try {
        parsedResult = PregnancyCheckResult.values.byName(resultName);
      } catch (_) {}
    }
    final expectedMs = map['expectedCalvingDate'] as int?;
    return _ReproductionDraft(
      serviceDate: DateTime.fromMillisecondsSinceEpoch(
        (map['serviceDate'] as int?) ?? DateTime.now().millisecondsSinceEpoch,
      ),
      serviceType: parsedType,
      maleSireIdentifier: map['maleSireIdentifier'] as String?,
      pregnancyResult: parsedResult,
      expectedCalvingDate: expectedMs != null
          ? DateTime.fromMillisecondsSinceEpoch(expectedMs)
          : null,
      notes: map['notes'] as String?,
    );
  }
}
