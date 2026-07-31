/// Field-optimized animal entry that shares rules with the full wizard.
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:libretapp/core/di/injection.dart';
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
import 'package:libretapp/theme/app_theme.dart';

class QuickRegisterAnimalPage extends StatefulWidget {
  const QuickRegisterAnimalPage({super.key});

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
  Sex _sex = Sex.female;
  ApproximateAge _age = const ApproximateAge(years: 1, months: 0);
  ProductionPurpose? _purpose;
  bool _saving = false;

  AnimalRegistrationPolicy get _policy =>
      AnimalRegistrationPolicy.forSpecies(_species);

  @override
  void initState() {
    super.initState();
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
    ageMonths: _age.totalMonths,
    identification: _nullableText(_identificationCtrl.text),
    name: _nullableText(_nameCtrl.text),
    breed: _nullableText(_breedCtrl.text),
    weight: parseFormDouble(_weightCtrl.text),
    productionPurpose: _purpose,
  );

  Future<void> _openFullRegistration() async {
    await context.pushNamed(AppRoutes.nameAnimalNuevo, extra: _currentSeed());
  }

  Future<void> _save() async {
    if (_saving) return;
    FocusScope.of(context).unfocus();
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
      final birthDate = _age.estimatedBirthDate(now);
      final lifecycle = AnimalLifecycleCalculator.calculate(
        birthDate: birthDate,
        species: _species,
        sex: _sex,
      );
      final category = AnimalTaxonomy.defaultCategory(
        species: _species,
        sex: _sex,
        ageMonths: _age.totalMonths,
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
          ageMonths: _age.totalMonths,
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
          profilePhoto: null,
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
      final action = await _showSuccessActions(animal);
      if (!mounted) return;
      await _handleSuccessAction(action, uuid);
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

  Future<_QuickSaveAction?> _showSuccessActions(AnimalEntity animal) {
    return showModalBottomSheet<_QuickSaveAction>(
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
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
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
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _handleSuccessAction(
    _QuickSaveAction? action,
    String uuid,
  ) async {
    switch (action) {
      case _QuickSaveAction.registerAnother:
        setState(() {
          _identificationCtrl.clear();
          _nameCtrl.clear();
          _breedCtrl.clear();
          _weightCtrl.clear();
          _sex = Sex.female;
          _age = const ApproximateAge(years: 1, months: 0);
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
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final policy = _policy;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Registro rápido'),
        actions: [
          TextButton(
            onPressed: _saving ? null : _openFullRegistration,
            child: const Text('Ficha completa'),
          ),
        ],
      ),
      body: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.lg,
            AppSpacing.md,
            AppSpacing.lg,
            AppSpacing.xxl,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Especie', style: theme.textTheme.labelLarge),
              const SizedBox(height: AppSpacing.xs),
              AnimalSpeciesSelector(
                value: _species,
                onChanged: _onSpeciesSelected,
              ),
              const SizedBox(height: AppSpacing.lg),
              TextField(
                focusNode: _identificationFocus,
                controller: _identificationCtrl,
                textCapitalization: TextCapitalization.characters,
                decoration: InputDecoration(
                  labelText: policy.identificationLabel,
                  hintText: policy.identificationHint,
                  helperText: policy.tracksPendingEarTag
                      ? 'Recomendado. Puedes guardarlo como pendiente.'
                      : 'Opcional',
                  prefixIcon: Icon(_identificationIcon(policy)),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              TextField(
                controller: _nameCtrl,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(
                  labelText: 'Nombre o alias — opcional',
                  prefixIcon: Icon(Icons.drive_file_rename_outline),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              TextField(
                controller: _breedCtrl,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(
                  labelText: 'Raza — opcional',
                  prefixIcon: Icon(Icons.pets_outlined),
                ),
              ),
              if (policy.purposeOptions.isNotEmpty) ...[
                const SizedBox(height: AppSpacing.lg),
                Text('Propósito — opcional', style: theme.textTheme.labelLarge),
                const SizedBox(height: AppSpacing.xs),
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
              const SizedBox(height: AppSpacing.lg),
              Text('Sexo', style: theme.textTheme.labelLarge),
              const SizedBox(height: AppSpacing.xs),
              CompactSexSelector(
                value: _sex,
                onChanged: (sex) => setState(() => _sex = sex),
              ),
              const SizedBox(height: AppSpacing.lg),
              ApproximateAgeField(
                value: _age,
                onChanged: (age) => setState(() => _age = age),
              ),
              const SizedBox(height: AppSpacing.md),
              TextField(
                controller: _weightCtrl,
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
        ),
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        minimum: const EdgeInsets.fromLTRB(
          AppSpacing.lg,
          AppSpacing.xs,
          AppSpacing.lg,
          AppSpacing.sm,
        ),
        child: SizedBox(
          height: 56,
          child: FilledButton.icon(
            onPressed: _saving ? null : _save,
            icon: _saving
                ? const SizedBox.square(
                    dimension: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.check),
            label: Text(_saving ? 'Guardando…' : 'Guardar animal'),
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

enum _QuickSaveAction { registerAnother, completeProfile, backToDirectory }

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
