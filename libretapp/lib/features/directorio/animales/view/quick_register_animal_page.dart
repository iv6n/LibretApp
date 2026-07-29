/// features › directorio › animales › view › quick_register_animal_page —
/// Field-optimised 4-field animal entry form.  Saves immediately; the full
/// wizard is offered afterwards via a SnackBar action.
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:libretapp/core/di/injection.dart';
import 'package:libretapp/core/router/app_routes.dart';
import 'package:libretapp/core/utils/id_generator.dart';
import 'package:libretapp/features/directorio/animales/bloc/animales_bloc.dart';
import 'package:libretapp/features/directorio/animales/bloc/animales_event.dart';
import 'package:libretapp/features/directorio/animales/domain/animal_domain.dart';
import 'package:libretapp/features/directorio/animales/domain/enums/production_stage.dart';
import 'package:libretapp/features/directorio/animales/domain/enums/production_system.dart';
import 'package:libretapp/features/directorio/animales/domain/services/animal_lifecycle_calculator.dart';
import 'package:libretapp/features/directorio/animales/infrastructure/animal_repository.dart';

class QuickRegisterAnimalPage extends StatefulWidget {
  const QuickRegisterAnimalPage({super.key});

  @override
  State<QuickRegisterAnimalPage> createState() =>
      _QuickRegisterAnimalPageState();
}

class _QuickRegisterAnimalPageState extends State<QuickRegisterAnimalPage> {
  final _earTagFocus = FocusNode();
  final _earTagCtrl = TextEditingController();
  final _weightCtrl = TextEditingController();

  Species _species = Species.cattle;
  Sex _sex = Sex.female;
  int _ageMonths = 12;
  bool _saving = false;

  static const _commonSpecies = [
    Species.cattle,
    Species.equine,
    Species.sheep,
    Species.goat,
    Species.pig,
    Species.poultry,
    Species.canine,
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _earTagFocus.requestFocus();
    });
  }

  @override
  void dispose() {
    _earTagFocus.dispose();
    _earTagCtrl.dispose();
    _weightCtrl.dispose();
    super.dispose();
  }

  Category _defaultCategory() {
    return AnimalTaxonomy.defaultCategory(
      species: _species,
      sex: _sex,
      ageMonths: _ageMonths,
    );
  }

  Future<void> _save() async {
    if (_saving) return;
    final earTag = _earTagCtrl.text.trim();
    if (earTag.isEmpty) {
      final shouldContinue = await _confirmMissingEarTag(context);
      if (!mounted || !shouldContinue) return;
    }

    setState(() => _saving = true);

    try {
      final now = DateTime.now();
      final birthDate = DateTime(
        now.year,
        now.month - (_ageMonths % 12),
        1,
      ).subtract(Duration(days: 365 * (_ageMonths ~/ 12)));

      final lifecycle = AnimalLifecycleCalculator.calculate(
        birthDate: birthDate,
        species: _species,
        sex: _sex,
      );
      final category = _defaultCategory();
      final lifeStage = AnimalTaxonomy.resolveLifeStage(
        species: _species,
        sex: _sex,
        ageMonths: lifecycle.ageMonths,
        category: category,
        fallback: lifecycle.lifeStage,
      );

      final uuid = 'ani-${generateId()}';
      final animal = AnimalEntity(
        id: null,
        uuid: uuid,
        earTagNumber: earTag,
        customName: null,
        visualId: null,
        brand: null,
        rfidTag: null,
        batchUuid: null,
        species: _species,
        category: category,
        lifeStage: lifeStage,
        sex: _sex,
        breed: '',
        crossBreed: null,
        birthDate: birthDate,
        ageMonths: lifecycle.ageMonths,
        weight: double.tryParse(_weightCtrl.text.trim()),
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
      );

      await locator<AnimalRepository>().save(animal);

      if (!mounted) return;
      context.read<AnimalesBloc>().add(const LoadAnimales(forceRefresh: true));

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${primaryAnimalLabel(animal)} registrado'),
          behavior: SnackBarBehavior.floating,
          action: SnackBarAction(
            label: 'Completar perfil',
            onPressed: () => context.pushNamed(
              AppRoutes.nameAnimalEditar,
              pathParameters: {'uuid': uuid},
            ),
          ),
        ),
      );

      context.pop();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No se pudo guardar. Intentá de nuevo.')),
      );
      setState(() => _saving = false);
    }
  }

  Future<bool> _confirmMissingEarTag(BuildContext context) async {
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Registro Rápido'),
        actions: [
          TextButton(
            onPressed: () => context.pushNamed(AppRoutes.nameAnimalNuevo),
            child: const Text('Ficha completa'),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // — Ear tag ——————————————————————————————————————
              TextField(
                focusNode: _earTagFocus,
                controller: _earTagCtrl,
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.2,
                ),
                textCapitalization: TextCapitalization.characters,
                decoration: const InputDecoration(
                  labelText: 'N° Caravana',
                  hintText: 'Ej: 1042',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.tag),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 18,
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // — Species ——————————————————————————————————————
              Text('Especie', style: theme.textTheme.labelLarge),
              const SizedBox(height: 8),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    ..._commonSpecies.map((s) {
                      final selected = _species == s;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ChoiceChip(
                          label: Text(s.displayName),
                          selected: selected,
                          onSelected: (_) => setState(() => _species = s),
                          selectedColor: colorScheme.primaryContainer,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 10,
                          ),
                        ),
                      );
                    }),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // — Sex ——————————————————————————————————————————
              Text('Sexo', style: theme.textTheme.labelLarge),
              const SizedBox(height: 8),
              SegmentedButton<Sex>(
                segments: const [
                  ButtonSegment(value: Sex.female, label: Text('♀  Hembra')),
                  ButtonSegment(value: Sex.male, label: Text('♂  Macho')),
                ],
                selected: {_sex},
                onSelectionChanged: (s) => setState(() => _sex = s.first),
                expandedInsets: EdgeInsets.zero,
              ),
              const SizedBox(height: 20),

              // — Age ———————————————————————————————————————————
              Text('Edad aproximada', style: theme.textTheme.labelLarge),
              const SizedBox(height: 8),
              Row(
                children: [
                  _AgeStepButton(
                    icon: Icons.remove,
                    onPressed: _ageMonths > 0
                        ? () => setState(() => _ageMonths--)
                        : null,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Center(
                      child: Text(
                        _ageLabel(_ageMonths),
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  _AgeStepButton(
                    icon: Icons.add,
                    onPressed: _ageMonths < 360
                        ? () => setState(() => _ageMonths++)
                        : null,
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // — Weight (optional) ————————————————————————————
              TextField(
                controller: _weightCtrl,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[\d.]')),
                ],
                decoration: const InputDecoration(
                  labelText: 'Peso (kg) — opcional',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.monitor_weight_outlined),
                  suffixText: 'kg',
                ),
              ),
              const Spacer(),

              // — Save button ———————————————————————————————————
              SizedBox(
                width: double.infinity,
                height: 56,
                child: FilledButton.icon(
                  onPressed: _saving ? null : _save,
                  icon: _saving
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.check, size: 22),
                  label: Text(
                    _saving ? 'Guardando…' : 'Guardar animal',
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  String _ageLabel(int months) {
    if (months == 0) return 'Recién nacido';
    final years = months ~/ 12;
    final rem = months % 12;
    if (years == 0) return '$months mes${months == 1 ? '' : 'es'}';
    if (rem == 0) return '$years año${years == 1 ? '' : 's'}';
    return '$years año${years == 1 ? '' : 's'} $rem mes${rem == 1 ? '' : 'es'}';
  }
}

class _AgeStepButton extends StatelessWidget {
  const _AgeStepButton({required this.icon, required this.onPressed});

  final IconData icon;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 52,
      height: 52,
      child: FilledButton.tonal(
        onPressed: onPressed,
        style: FilledButton.styleFrom(
          padding: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        child: Icon(icon, size: 26),
      ),
    );
  }
}
