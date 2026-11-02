/// Field-optimized animal entry that shares rules with the full wizard.
library;

import 'package:flutter/material.dart';
import 'package:libretapp/app/widgets/app_bottom_sheet.dart';
import 'package:libretapp/core/widgets/widgets.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:libretapp/core/di/injection.dart';
import 'package:libretapp/core/backup/first_backup_suggestion.dart';
import 'package:libretapp/core/router/app_routes.dart';
import 'package:libretapp/core/utils/id_generator.dart';
import 'package:libretapp/core/utils/number_parsing.dart';
import 'package:libretapp/features/directorio/animales/bloc/animales_bloc.dart';
import 'package:libretapp/features/directorio/animales/bloc/animales_event.dart';
import 'package:libretapp/features/directorio/animales/domain/animal_domain.dart';
import 'package:libretapp/features/directorio/animales/domain/enums/production_stage.dart';
import 'package:libretapp/features/directorio/animales/domain/enums/production_system.dart';
import 'package:libretapp/features/directorio/animales/domain/services/animal_lifecycle_calculator.dart';
import 'package:libretapp/features/directorio/animales/infrastructure/animal_repository.dart';
import 'package:libretapp/features/directorio/animales/widgets/registration_widgets.dart';
import 'package:libretapp/features/directorio/animales/widgets/animal_photo.dart';
import 'package:libretapp/theme/app_theme.dart';

class QuickRegisterAnimalPage extends StatefulWidget {
  const QuickRegisterAnimalPage({
    super.key,
    this.initialSpecies,
    this.preferredSpecies = const [],
  });

  final Species? initialSpecies;
  final List<Species> preferredSpecies;

  @override
  State<QuickRegisterAnimalPage> createState() =>
      _QuickRegisterAnimalPageState();
}

class _QuickRegisterAnimalPageState extends State<QuickRegisterAnimalPage> {
  final _identificationFocus = FocusNode();
  final _identificationCtrl = TextEditingController();
  final _nameCtrl = TextEditingController();
  final _weightCtrl = TextEditingController();
  final _breedCtrl = TextEditingController();

  Species _species = Species.cattle;
  Sex _sex = Sex.unknown;
  ApproximateAge _age = const ApproximateAge.unknown();
  _BirthInputMode _birthInputMode = _BirthInputMode.unknown;
  DateTime? _exactBirthDate;
  ProductionPurpose? _purpose;
  String? _profilePhoto;
  bool _saving = false;

  AnimalRegistrationPolicy get _policy =>
      AnimalRegistrationPolicy.forSpecies(_species);

  @override
  void initState() {
    super.initState();
    _species = widget.initialSpecies ?? _species;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _identificationFocus.requestFocus();
    });
  }

  @override
  void dispose() {
    _identificationFocus.dispose();
    _identificationCtrl.dispose();
    _nameCtrl.dispose();
    _weightCtrl.dispose();
    _breedCtrl.dispose();
    super.dispose();
  }

  void _onSpeciesSelected(Species species) {
    setState(() {
      _species = species;
      if (!_policy.purposeOptions.contains(_purpose)) {
        _purpose = null;
      }
    });
  }

  AnimalRegistrationSeed _currentSeed() => AnimalRegistrationSeed(
    species: _species,
    sex: _sex,
    ageMonths: _selectedAgeMonths(DateTime.now()),
    birthDate: _birthInputMode == _BirthInputMode.exact
        ? _exactBirthDate
        : null,
    birthDatePrecision: _birthInputMode == _BirthInputMode.exact
        ? BirthDatePrecision.exact
        : _birthInputMode == _BirthInputMode.approximate && !_age.isUnknown
        ? BirthDatePrecision.estimated
        : BirthDatePrecision.unknown,
    identification: _nullableText(_identificationCtrl.text),
    name: _nullableText(_nameCtrl.text),
    breed: _nullableText(_breedCtrl.text),
    weight: parseFormDouble(_weightCtrl.text),
    productionPurpose: _purpose,
    profilePhoto: _profilePhoto,
  );

  Future<void> _openFullRegistration() async {
    await context.pushNamed(AppRoutes.nameAnimalNuevo, extra: _currentSeed());
  }

  Future<void> _save() async {
    if (_saving) return;
    FocusScope.of(context).unfocus();
    if (_birthInputMode == _BirthInputMode.exact && _exactBirthDate == null) {
      _showMessage('Elige la fecha de nacimiento.');
      return;
    }
    if (_birthInputMode == _BirthInputMode.approximate && _age.isUnknown) {
      _showMessage('Elige la edad aproximada o selecciona No lo sé.');
      return;
    }
    final identification = _identificationCtrl.text.trim();
    final weight = parseFormDouble(_weightCtrl.text);
    if (_weightCtrl.text.trim().isNotEmpty && weight == null) {
      _showMessage('Ingresa un peso válido.');
      return;
    }

    if (_policy.tracksPendingEarTag && identification.isEmpty) {
      final shouldContinue = await _confirmPendingEarTag();
      if (!mounted || !shouldContinue) return;
    }

    if (identification.isNotEmpty &&
        await _isIdentificationDuplicated(identification)) {
      if (mounted) {
        _showMessage('Ya existe un animal con esa identificación.');
      }
      return;
    }

    setState(() => _saving = true);
    try {
      final now = DateTime.now();
      final ageMonths = _selectedAgeMonths(now);
      final birthDate = switch (_birthInputMode) {
        _BirthInputMode.exact => _exactBirthDate!,
        _BirthInputMode.approximate => _age.estimatedBirthDate(now),
        _BirthInputMode.unknown => DateTime.fromMillisecondsSinceEpoch(0),
      };
      final lifecycle = AnimalLifecycleCalculator.calculate(
        birthDate: birthDate,
        species: _species,
        sex: _sex,
      );
      final category = AnimalTaxonomy.defaultCategory(
        species: _species,
        sex: _sex,
        ageMonths: ageMonths,
      );
      final lifeStage = AnimalTaxonomy.resolveLifeStage(
        species: _species,
        sex: _sex,
        ageMonths: _age.totalMonths,
        category: category,
        fallback: lifecycle.lifeStage,
      );
      final uuid = 'ani-${generateId()}';
      final normalizedName = _nullableText(_nameCtrl.text);
      final animal = AnimalRegistrationNormalizer.normalizeEntity(
        AnimalEntity(
          id: null,
          uuid: uuid,
          earTagNumber: identification,
          customName: normalizedName,
          visualId: normalizedName,
          brand: null,
          rfidTag: null,
          batchUuid: null,
          species: _species,
          category: category,
          lifeStage: lifeStage,
          sex: _sex,
          breed: _breedCtrl.text,
          crossBreed: null,
          birthDate: birthDate,
          birthDatePrecision: switch (_birthInputMode) {
            _BirthInputMode.exact => BirthDatePrecision.exact,
            _BirthInputMode.approximate => BirthDatePrecision.estimated,
            _BirthInputMode.unknown => BirthDatePrecision.unknown,
          },
          ageMonths: ageMonths,
          weight: weight,
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
          productionPurpose: _purpose ?? ProductionPurpose.undefined,
          productionStage: ProductionStage.unknown,
          productionSystem: ProductionSystem.unknown,
          feedType: null,
          dailyGainEstimate: null,
          coatColor: null,
          distinguishingMarks: null,
          notes: null,
          originType: null,
          provenance: null,
          crossBreedType: null,
          sireBreed: null,
          damBreed: null,
          bloodPercentage: null,
          genealogicalRegistry: null,
          originNotes: null,
          housingType: null,
          shadingAvailability: null,
          animalWaterSource: null,
          approximateDensity: null,
          locationNotes: null,
          feedFrequency: null,
          feedSupplements: null,
          feedNotes: null,
          earTagColor: null,
          currentLocationId: null,
          initialLocationId: null,
          lastMovementDate: now,
          underObservation: false,
          requiresAttention: false,
          riskLevel: RiskLevel.low,
          profilePhoto: _profilePhoto,
          gallery: const [],
          owner: null,
          purchasePrice: null,
          status: AnimalStatus.active,
          synced: false,
          remoteId: null,
          syncDate: null,
          contentHash: null,
          creationDate: now,
          lastUpdateDate: now,
        ),
      );

      await locator<AnimalRepository>().save(animal);
      if (!mounted) return;
      try {
        context.read<AnimalesBloc>().add(
          const LoadAnimales(forceRefresh: true),
        );
      } catch (_) {
        // The page can also be opened without the directory bloc in tests.
      }
      setState(() => _saving = false);
      final showBackupSuggestion = await consumeFirstBackupSuggestion();
      if (!mounted) return;
      final action = await _showSuccessActions(
        animal,
        showBackupSuggestion: showBackupSuggestion,
      );
      if (!mounted) return;
      await _handleSuccessAction(action, animal);
    } catch (_) {
      if (!mounted) return;
      setState(() => _saving = false);
      _showMessage('No se pudo guardar. Intenta de nuevo.');
    }
  }

  Future<bool> _isIdentificationDuplicated(String identification) async {
    final animals = await locator<AnimalRepository>().getAll();
    return AnimalRegistrationNormalizer.isDuplicateIdentification(
      candidate: identification,
      animals: animals,
    );
  }

  Future<bool> _confirmPendingEarTag() async {
    return await showDialog<bool>(
          context: context,
          useRootNavigator: true,
          builder: (dialogContext) => AlertDialog(
            scrollable: true,
            icon: const Icon(Icons.pending_actions_outlined),
            title: const Text('Dejar arete pendiente'),
            content: const Text(
              'El animal quedará registrado y aparecerá en tus pendientes '
              'hasta que agregues el número de arete.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(false),
                child: const Text('Volver y agregar'),
              ),
              FilledButton(
                onPressed: () => Navigator.of(dialogContext).pop(true),
                child: const Text('Guardar como pendiente'),
              ),
            ],
          ),
        ) ??
        false;
  }

  Future<_QuickSaveAction?> _showSuccessActions(
    AnimalEntity animal, {
    required bool showBackupSuggestion,
  }) {
    return showAppBottomSheet<_QuickSaveAction>(
      context: context,
      useSafeArea: true,
      showDragHandle: true,
      isDismissible: false,
      enableDrag: false,
      builder: (sheetContext) => Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg,
          0,
          AppSpacing.lg,
          AppSpacing.lg,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircleAvatar(
                radius: 28,
                backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                child: const Icon(Icons.check, size: 30),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'Animal registrado',
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                primaryAnimalLabel(animal),
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: AppSpacing.lg),
              if (_canRegisterService(animal)) ...[
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: () => Navigator.of(
                      sheetContext,
                    ).pop(_QuickSaveAction.registerService),
                    icon: const Icon(Icons.event_available_outlined),
                    label: const Text('Registrar monta'),
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
              ],
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () => Navigator.of(
                    sheetContext,
                  ).pop(_QuickSaveAction.registerAnother),
                  icon: const Icon(Icons.add),
                  label: const Text('Registrar otro'),
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () => Navigator.of(
                    sheetContext,
                  ).pop(_QuickSaveAction.completeProfile),
                  icon: const Icon(Icons.assignment_outlined),
                  label: const Text('Completar ficha'),
                ),
              ),
              TextButton(
                onPressed: () => Navigator.of(
                  sheetContext,
                ).pop(_QuickSaveAction.backToDirectory),
                child: const Text('Volver al directorio'),
              ),
              if (showBackupSuggestion)
                TextButton.icon(
                  onPressed: () => Navigator.of(
                    sheetContext,
                  ).pop(_QuickSaveAction.openBackups),
                  icon: const Icon(Icons.backup_outlined),
                  label: const Text('Proteger mis datos · Ver respaldos'),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _handleSuccessAction(
    _QuickSaveAction? action,
    AnimalEntity animal,
  ) async {
    final uuid = animal.uuid;
    switch (action) {
      case _QuickSaveAction.registerService:
        final saved = await context.pushNamed<bool>(
          AppRoutes.nameAnimalRegistroReproduccion,
          pathParameters: {'uuid': uuid},
          queryParameters: const {'step': 'service'},
        );
        if (!mounted) return;
        if (saved == true) {
          context.go(AppRoutes.animalDetallePath(uuid));
        } else {
          final nextAction = await _showSuccessActions(
            animal,
            showBackupSuggestion: false,
          );
          if (mounted) await _handleSuccessAction(nextAction, animal);
        }
      case _QuickSaveAction.registerAnother:
        setState(() {
          _identificationCtrl.clear();
          _nameCtrl.clear();
          _breedCtrl.clear();
          _weightCtrl.clear();
          _sex = Sex.unknown;
          _age = const ApproximateAge.unknown();
          _birthInputMode = _BirthInputMode.unknown;
          _exactBirthDate = null;
        });
        _identificationFocus.requestFocus();
      case _QuickSaveAction.completeProfile:
        await context.pushNamed(
          AppRoutes.nameAnimalCompletar,
          pathParameters: {'uuid': uuid},
        );
        if (mounted) context.pop(true);
      case _QuickSaveAction.backToDirectory:
      case null:
        context.pop(true);
      case _QuickSaveAction.openBackups:
        context.go('${AppRoutes.perfil}?backups=1');
    }
  }

  bool _canRegisterService(AnimalEntity animal) =>
      animal.sex == Sex.female &&
      {Species.cattle, Species.sheep, Species.goat}.contains(animal.species);

  int _selectedAgeMonths(DateTime now) => switch (_birthInputMode) {
    _BirthInputMode.exact when _exactBirthDate != null =>
      AnimalLifecycleCalculator.monthsBetween(_exactBirthDate!, now),
    _BirthInputMode.approximate => _age.totalMonths,
    _ => -1,
  };

  Future<void> _pickExactBirthDate() async {
    final today = DateTime.now();
    final date = await showDatePicker(
      context: context,
      initialDate: _exactBirthDate ?? today,
      firstDate: DateTime(1900),
      lastDate: today,
    );
    if (mounted && date != null) {
      setState(() {
        _exactBirthDate = date;
        _birthInputMode = _BirthInputMode.exact;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final policy = _policy;
    final largeText = MediaQuery.textScalerOf(context).scale(14) >= 22;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Alta rápida'),
        actions: largeText
            ? null
            : [
                TextButton(
                  onPressed: _saving ? null : _openFullRegistration,
                  child: const Text('Ficha completa'),
                ),
              ],
      ),
      body: AppFormBody(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Especie', style: theme.textTheme.labelLarge),
            const SizedBox(height: AppSpacing.xs),
            AnimalSpeciesSelector(
              value: _species,
              onChanged: _onSpeciesSelected,
              preferredSpecies: widget.preferredSpecies,
            ),
            const SizedBox(height: AppSpacing.md),
            TextField(
              focusNode: _identificationFocus,
              controller: _identificationCtrl,
              key: const ValueKey('animal-quick-identification'),
              textCapitalization: TextCapitalization.characters,
              decoration: InputDecoration(
                labelText: policy.identificationLabel,
                hintText: policy.identificationHint,
                helperText: policy.tracksPendingEarTag
                    ? 'Recomendado. Puedes guardarlo como pendiente.'
                    : 'Opcional',
                helperMaxLines: 2,
                prefixIcon: Icon(_identificationIcon(policy)),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            TextField(
              controller: _nameCtrl,
              key: const ValueKey('animal-quick-name'),
              textCapitalization: TextCapitalization.words,
              decoration: const InputDecoration(
                labelText: 'Nombre o alias — opcional',
                prefixIcon: Icon(Icons.drive_file_rename_outline),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Text('Sexo', style: theme.textTheme.labelLarge),
            const SizedBox(height: AppSpacing.xs),
            CompactSexSelector(
              value: _sex,
              onChanged: (sex) => setState(() => _sex = sex),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text('Nacimiento o edad', style: theme.textTheme.labelLarge),
            const SizedBox(height: AppSpacing.xs),
            Wrap(
              spacing: AppSpacing.xs,
              runSpacing: AppSpacing.xs,
              children: [
                for (final (mode, label) in const [
                  (_BirthInputMode.exact, 'Fecha'),
                  (_BirthInputMode.approximate, 'Edad'),
                  (_BirthInputMode.unknown, 'No lo sé'),
                ])
                  ChoiceChip(
                    label: Text(label),
                    selected: _birthInputMode == mode,
                    onSelected: (_) => setState(() => _birthInputMode = mode),
                  ),
              ],
            ),
            if (_birthInputMode == _BirthInputMode.exact) ...[
              const SizedBox(height: AppSpacing.sm),
              OutlinedButton.icon(
                key: const ValueKey('animal-quick-exact-birth-date'),
                onPressed: _pickExactBirthDate,
                icon: const Icon(Icons.calendar_today_outlined),
                label: Text(
                  _exactBirthDate == null
                      ? 'Elegir fecha de nacimiento'
                      : '${_exactBirthDate!.day}/${_exactBirthDate!.month}/${_exactBirthDate!.year}',
                ),
              ),
            ],
            if (_birthInputMode == _BirthInputMode.approximate) ...[
              const SizedBox(height: AppSpacing.sm),
              ApproximateAgeField(
                value: _age,
                onChanged: (age) => setState(() => _age = age),
              ),
            ],
            const SizedBox(height: AppSpacing.md),
            ExpansionTile(
              key: const ValueKey('animal-quick-more-data'),
              title: const Text('Más datos'),
              children: [
                AnimalPhotoField(
                  photoPath: _profilePhoto,
                  species: _species,
                  enabled: !_saving,
                  compact: true,
                  onChanged: (path) => setState(() => _profilePhoto = path),
                ),
                const SizedBox(height: AppSpacing.md),
                TextField(
                  controller: _breedCtrl,
                  key: const ValueKey('animal-quick-breed'),
                  textCapitalization: TextCapitalization.words,
                  decoration: const InputDecoration(
                    labelText: 'Raza — opcional',
                    prefixIcon: Icon(Icons.pets_outlined),
                  ),
                ),
                if (policy.purposeOptions.isNotEmpty) ...[
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    'Propósito — opcional',
                    style: theme.textTheme.labelLarge,
                  ),
                  Wrap(
                    spacing: AppSpacing.xs,
                    runSpacing: AppSpacing.xs,
                    children: policy.purposeOptions.map((purpose) {
                      final selected = _purpose == purpose;
                      return ChoiceChip(
                        label: Text(purpose.displayName),
                        selected: selected,
                        onSelected: (_) => setState(() {
                          _purpose = selected ? null : purpose;
                        }),
                      );
                    }).toList(),
                  ),
                ],
                const SizedBox(height: AppSpacing.md),
                TextField(
                  controller: _weightCtrl,
                  key: const ValueKey('animal-quick-weight'),
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[\d.,]')),
                  ],
                  decoration: const InputDecoration(
                    labelText: 'Peso (kg) — opcional',
                    prefixIcon: Icon(Icons.monitor_weight_outlined),
                    suffixText: 'kg',
                  ),
                ),
              ],
            ),
            if (largeText)
              OutlinedButton.icon(
                onPressed: _saving ? null : _openFullRegistration,
                icon: const Icon(Icons.assignment_outlined),
                label: const Text('Abrir ficha completa'),
              ),
          ],
        ),
      ),
      bottomNavigationBar: AnimatedPadding(
        duration: const Duration(milliseconds: 180),
        padding: EdgeInsets.only(
          bottom: MediaQuery.viewInsetsOf(context).bottom,
        ),
        child: SafeArea(
          top: false,
          minimum: const EdgeInsets.fromLTRB(
            AppSpacing.lg,
            AppSpacing.xs,
            AppSpacing.lg,
            AppSpacing.sm,
          ),
          child: AppFormActions(
            saveKey: const ValueKey('animal-quick-save'),
            onSave: _save,
            saving: _saving,
            saveLabel: 'Guardar animal',
          ),
        ),
      ),
    );
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  String? _nullableText(String raw) {
    final value = raw.trim();
    return value.isEmpty ? null : value;
  }
}

enum _QuickSaveAction {
  registerService,
  registerAnother,
  completeProfile,
  backToDirectory,
  openBackups,
}

enum _BirthInputMode { exact, approximate, unknown }

IconData _identificationIcon(AnimalRegistrationPolicy policy) {
  switch (policy.identificationKind) {
    case AnimalIdentificationKind.earTag:
      return Icons.sell_outlined;
    case AnimalIdentificationKind.microchipOrPassport:
      return Icons.badge_outlined;
    case AnimalIdentificationKind.legBand:
      return Icons.radio_button_checked;
    case AnimalIdentificationKind.microchipOrPlate:
      return Icons.memory_outlined;
    case AnimalIdentificationKind.generic:
      return Icons.tag;
  }
}
