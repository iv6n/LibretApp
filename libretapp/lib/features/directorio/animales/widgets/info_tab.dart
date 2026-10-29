/// features \u203a directorio \u203a animales \u203a widgets \u203a info_tab \u2014 info tab on the animal detail page.
library;

import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:libretapp/app/widgets/widgets.dart';
import 'package:libretapp/core/di/injection.dart';
import 'package:libretapp/core/router/app_routes.dart';
import 'package:libretapp/features/directorio/animales/application/bloc/animal_bloc.dart';
import 'package:libretapp/features/directorio/animales/domain/animal_domain.dart';
import 'package:libretapp/features/directorio/animales/widgets/location_batch_sheet.dart';
import 'package:libretapp/features/directorio/lotes/infrastructure/lotes_repository.dart';
import 'package:libretapp/features/directorio/animales/widgets/detail_helpers.dart';
import 'package:libretapp/features/ubicaciones/domain/repositories/location_repository.dart';
import 'package:libretapp/l10n/app_localizations.dart';
import 'package:libretapp/theme/app_theme.dart';
import 'package:libretapp/core/widgets/widgets.dart';
import 'package:libretapp/features/directorio/animales/widgets/animal_summary_panel.dart';

class InfoTab extends StatefulWidget {
  const InfoTab({
    super.key,
    required this.animal,
    this.lotesRepository,
    this.accentColor,
    this.data,
    this.onChanged,
    this.onShowCare,
    this.onEditPurpose,
  });

  final AnimalEntity animal;
  final LotesRepository? lotesRepository;
  final Color? accentColor;
  final DetailData? data;
  final VoidCallback? onChanged;
  final VoidCallback? onShowCare;
  final VoidCallback? onEditPurpose;

  @override
  State<InfoTab> createState() => _InfoTabState();
}

class _InfoTabState extends State<InfoTab> {
  late LotesRepository _lotesRepository;
  String? _batchName;
  bool _loadingBatchName = false;
  String? _locationName;
  String? _locationUuid;
  int _contextLoad = 0;

  @override
  void initState() {
    super.initState();
    _lotesRepository = widget.lotesRepository ?? locator<LotesRepository>();
    _loadBatchName();
  }

  @override
  void didUpdateWidget(covariant InfoTab oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.animal.uuid != widget.animal.uuid ||
        oldWidget.animal.batchUuid != widget.animal.batchUuid ||
        oldWidget.animal.currentLocationId != widget.animal.currentLocationId ||
        oldWidget.animal.initialLocationId != widget.animal.initialLocationId) {
      _loadBatchName();
    }
  }

  Future<void> _loadBatchName() async {
    final generation = ++_contextLoad;
    final animal = widget.animal;
    setState(() {
      _loadingBatchName = true;
      _batchName = null;
      _locationName = null;
      _locationUuid = null;
    });
    String? batchName;
    String? locationName;
    String? locationUuid;
    try {
      if (animal.batchUuid != null) {
        batchName = (await _lotesRepository.getByUuid(animal.batchUuid!))?.name;
      }
    } catch (_) {
      batchName = 'Lote no disponible';
    }
    final locationId = animal.currentLocationId ?? animal.initialLocationId;
    if (locationId != null && locator.isRegistered<LocationRepository>()) {
      try {
        final repo = locator<LocationRepository>();
        final location = await repo.getByUuid(locationId);
        locationName = location?.name;
        locationUuid = location?.uuid;
      } catch (_) {
        locationName = null;
      }
    }
    if (!mounted || generation != _contextLoad) return;
    setState(() {
      _batchName = batchName;
      _locationName = locationName;
      _locationUuid = locationUuid;
      _loadingBatchName = false;
    });
  }

  Future<void> _changeLocation(BuildContext context) async {
    final bloc = context.read<AnimalBloc>();
    final locationRepository = locator<LocationRepository>();

    List<dynamic> locations = [];
    try {
      locations = await locationRepository.getAll();
    } catch (_) {
      // Proceed with empty list — sheet handles it gracefully.
    }

    if (!context.mounted) return;

    await showLocationBatchSheet(
      context,
      animal: widget.animal,
      locations: List.from(locations),
      allAnimals: [widget.animal],
      lotesRepository: _lotesRepository,
      dispatchAndAwait: (event) async {
        final future = bloc.stream.firstWhere(
          (state) => !state.isLoading,
          orElse: () => bloc.state,
        );

        bloc.add(event);
        final nextState = await future;

        if (!mounted) return false;
        return !nextState.isError;
      },
      onReload: () {
        _loadBatchName();
        widget.onChanged?.call();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isPet =
        widget.animal.species == Species.canine ||
        widget.animal.species == Species.feline ||
        widget.animal.productionPurpose == ProductionPurpose.companion;
    final stageColor =
        widget.accentColor ?? detailStageColor(widget.animal.lifeStage);
    final healthColor = detailColorFromHex(widget.animal.healthStatus.hexColor);
    final riskColor = detailColorFromHex(widget.animal.riskLevel.hexColor);
    final bottomInset = ShellInsets.bottomSafePadding(context);
    final fabBottomPadding = ShellInsets.fabDockPadding(context);
    // Use the larger of content inset and FAB dock to keep items clear.
    final listBottomPadding = max(bottomInset + 10, fabBottomPadding + 24);

    final batchDisplay = _loadingBatchName
        ? '(cargando...)'
        : (_batchName ?? l10n.valueNoData);
    final geneticsLabel = breedSummary(widget.animal);
    final shortGeneticsLabel = breedSummary(widget.animal, abbreviated: true);
    final locationId =
        widget.animal.currentLocationId ?? widget.animal.initialLocationId;
    final locationDisplay = _loadingBatchName
        ? 'Cargando ubicación…'
        : _locationName ??
              (locationId == null
                  ? 'Sin ubicación'
                  : 'Ubicación no disponible');

    return SingleChildScrollView(
      key: const PageStorageKey('info_scroll'),
      padding: EdgeInsets.fromLTRB(16, 14, 16, listBottomPadding),
      child: Column(
        children: [
          AnimalSummaryPanel(
            animal: widget.animal,
            data: widget.data,
            onShowCare: widget.onShowCare,
            onEditPurpose: widget.onEditPurpose,
          ),
          if (widget.animal.batchUuid != null || locationId != null)
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.md),
              child: AppCard(
                title: 'Dónde está',
                body: Column(
                  children: [
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(Icons.inventory_2_outlined),
                      title: const Text('Lote'),
                      subtitle: Text(batchDisplay),
                      trailing: widget.animal.batchUuid == null
                          ? null
                          : const Icon(Icons.chevron_right),
                      onTap: widget.animal.batchUuid == null
                          ? null
                          : () => context.pushNamed(
                              AppRoutes.nameLoteDetalle,
                              pathParameters: {
                                'uuid': widget.animal.batchUuid!,
                              },
                            ),
                    ),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(Icons.place_outlined),
                      title: const Text('Ubicación'),
                      subtitle: Text(locationDisplay),
                      trailing: _locationUuid == null
                          ? null
                          : const Icon(Icons.chevron_right),
                      onTap: _locationUuid == null
                          ? null
                          : () => context.pushNamed(
                              AppRoutes.nameUbicacionDetalle,
                              pathParameters: {'uuid': _locationUuid!},
                            ),
                    ),
                  ],
                ),
              ),
            ),
          if (hasPendingEarTag(widget.animal))
            Card(
              color: AppColors.amber.withValues(alpha: 0.12),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    const Icon(
                      Icons.pending_actions_outlined,
                      color: AppColors.amber,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.animalPendingTag,
                            style: const TextStyle(fontWeight: FontWeight.w700),
                          ),
                          Text(l10n.animalPendingTagHelp),
                        ],
                      ),
                    ),
                    TextButton(
                      onPressed: () async {
                        final saved = await context.pushNamed(
                          AppRoutes.nameAnimalEditar,
                          pathParameters: {'uuid': widget.animal.uuid},
                        );
                        if (saved == true && mounted) widget.onChanged?.call();
                      },
                      child: Text(l10n.animalAddTag),
                    ),
                  ],
                ),
              ),
            ),
          InfoSection(
            title: l10n.sectionIdentification,
            icon: Icons.badge_outlined,
            accent: stageColor,
            children: [
              InfoRow(
                label: AnimalRegistrationPolicy.forSpecies(
                  widget.animal.species,
                ).identificationLabel,
                value: earTagDisplay(widget.animal),
                icon: Icons.sell_outlined,
              ),
              InfoRow(
                label: l10n.labelVisualId,
                value: widget.animal.visualId ?? l10n.valueNotAssigned,
                icon: Icons.remove_red_eye_outlined,
              ),
              InfoRow(
                label: l10n.labelBrand,
                value: widget.animal.brand ?? l10n.valueNoData,
                icon: Icons.local_offer_outlined,
              ),
              InfoRow(
                label: l10n.labelRfid,
                value: widget.animal.rfidTag ?? l10n.valueNoData,
                icon: Icons.sensors_outlined,
              ),
              InfoRow(
                label: l10n.labelBatch,
                value: batchDisplay,
                icon: Icons.inventory_2_outlined,
              ),
            ],
          ),
          InfoSection(
            title: isPet ? 'Perfil de mascota' : l10n.sectionProductiveProfile,
            icon: Icons.insights_outlined,
            accent: stageColor,
            children: [
              InfoRow(
                label: l10n.labelSpecies,
                value: widget.animal.species.displayName,
                icon: Icons.pets_outlined,
              ),
              if (isPet)
                const InfoRow(
                  label: 'Tipo',
                  value: 'Mascota',
                  icon: Icons.pets_outlined,
                )
              else ...[
                InfoRow(
                  label: l10n.labelCategory,
                  value: widget.animal.category.displayName,
                  icon: Icons.star_outline,
                ),
                InfoRow(
                  label: l10n.labelLifeStage,
                  value: widget.animal.lifeStage.displayName,
                  accent: stageColor,
                  icon: Icons.eco_outlined,
                ),
              ],
              InfoRow(
                label: l10n.labelBreed,
                value: widget.animal.breed,
                icon: Icons.biotech_outlined,
              ),
              InfoRow(
                label: 'Genética',
                value: geneticsLabel,
                icon: Icons.hub_outlined,
              ),
              if ((widget.animal.crossBreed ?? '').trim().isNotEmpty)
                InfoRow(
                  label: 'Cruza resumida',
                  value: shortGeneticsLabel,
                  icon: Icons.merge_type_outlined,
                ),
              if ((widget.animal.crossBreedType ?? '').trim().isNotEmpty)
                InfoRow(
                  label: 'Tipo de cruza',
                  value: widget.animal.crossBreedType!.trim(),
                  icon: Icons.account_tree_outlined,
                ),
              if ((widget.animal.sireBreed ?? '').trim().isNotEmpty)
                InfoRow(
                  label: 'Raza padre',
                  value: widget.animal.sireBreed!.trim(),
                  icon: Icons.male_outlined,
                ),
              if ((widget.animal.damBreed ?? '').trim().isNotEmpty)
                InfoRow(
                  label: 'Raza madre',
                  value: widget.animal.damBreed!.trim(),
                  icon: Icons.female_outlined,
                ),
              if (widget.animal.bloodPercentage != null)
                InfoRow(
                  label: 'Porcentaje de sangre',
                  value: '${widget.animal.bloodPercentage}%',
                  icon: Icons.percent_outlined,
                ),
              InfoRow(
                label: l10n.labelSex,
                value: widget.animal.sex.displayName,
                icon: Icons.female_outlined,
              ),
              InfoRow(
                label: l10n.labelAge,
                value: widget.animal.hasKnownAge
                    ? formatAge(widget.animal.ageMonths)
                    : 'Sin dato',
                icon: Icons.schedule_outlined,
              ),
              InfoRow(
                label: l10n.labelPurpose,
                value: widget.animal.productionPurpose.displayName,
                icon: Icons.flag_outlined,
              ),
              if (!isPet) ...[
                InfoRow(
                  label: 'Etapa de Producción',
                  value: widget.animal.productionStage.displayName,
                  icon: Icons.timeline_outlined,
                ),
                InfoRow(
                  label: 'Sistema de Producción',
                  value: widget.animal.productionSystem.displayName,
                  icon: Icons.account_tree_outlined,
                ),
              ],
              InfoRow(
                label: l10n.labelFeedType,
                value: widget.animal.feedType ?? l10n.valueNoData,
                icon: Icons.grass_outlined,
              ),
              InfoRow(
                label: l10n.labelDailyGain,
                value: widget.animal.dailyGainEstimate != null
                    ? '${widget.animal.dailyGainEstimate!.toStringAsFixed(2)} kg/día'
                    : l10n.valueNoData,
                icon: Icons.trending_up_outlined,
              ),
            ],
          ),
          InfoSection(
            title: l10n.sectionHealth,
            icon: Icons.health_and_safety_outlined,
            accent: stageColor,
            children: [
              if (widget.animal.needsImmediateAttention)
                InfoRow(
                  label: '⚠️ Atención Requerida',
                  value: widget.animal.requiresAttention
                      ? 'Sí'
                      : 'En Observación',
                  icon: Icons.warning_amber_rounded,
                ),
              if (widget.animal.healthIssueCount > 0)
                InfoRow(
                  label: 'Problemas de Salud Detectados',
                  value: '${widget.animal.healthIssueCount}',
                  icon: Icons.report_problem_outlined,
                ),
              InfoRow(
                label: l10n.labelHealthStatus,
                value: widget.animal.healthStatus.displayName,
                accent: healthColor,
                icon: Icons.favorite_outline,
              ),
              InfoRow(
                label: l10n.labelBodyCondition,
                value: widget.animal.bodyConditionScore != null
                    ? '${widget.animal.bodyConditionScore}/9'
                    : l10n.valueNoData,
                icon: Icons.monitor_weight_outlined,
              ),
              InfoRow(
                label: l10n.labelRisk,
                value: widget.animal.riskLevel.displayName,
                accent: riskColor,
                icon: Icons.shield_outlined,
              ),
              BoolRow(
                label: l10n.labelVaccinated,
                value: widget.animal.vaccinated,
                icon: Icons.vaccines_outlined,
              ),
              BoolRow(
                label: l10n.labelDewormed,
                value: widget.animal.dewormed,
                icon: Icons.medication_outlined,
              ),
              BoolRow(
                label: l10n.labelVitamins,
                value: widget.animal.hasVitamins,
                icon: Icons.energy_savings_leaf_outlined,
              ),
              BoolRow(
                label: l10n.labelChronicCondition,
                value: widget.animal.hasChronicIssues,
                icon: Icons.health_and_safety_outlined,
              ),
              if ((widget.animal.chronicNotes ?? '').isNotEmpty)
                InfoRow(
                  label: l10n.labelChronicNotes,
                  value: widget.animal.chronicNotes!,
                  icon: Icons.notes_outlined,
                ),
            ],
          ),
          InfoSection(
            title: l10n.sectionLocation,
            icon: Icons.location_on_outlined,
            accent: stageColor,
            children: [
              InfoRow(
                label: l10n.labelPaddock,
                value: _locationName ?? l10n.valueNoData,
                icon: Icons.map_outlined,
              ),
              InfoRow(
                label: l10n.labelLastMovement,
                value: formatDate(widget.animal.lastMovementDate),
                icon: Icons.route_outlined,
              ),
              InfoRow(
                label: l10n.labelObservation,
                value: widget.animal.underObservation
                    ? l10n.animalUnderObservation
                    : l10n.valueNo,
                icon: Icons.visibility_outlined,
              ),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton.icon(
                  icon: const Icon(Icons.edit_location_alt_outlined, size: 18),
                  label: const Text('Cambiar ubicación'),
                  onPressed: widget.animal.status.isInActiveHerd
                      ? () => _changeLocation(context)
                      : null,
                ),
              ),
            ],
          ),
          if (widget.animal.sex == Sex.female &&
              AnimalRegistrationPolicy.forSpecies(
                widget.animal.species,
              ).supportsReproduction)
            InfoSection(
              title: l10n.sectionReproduction,
              icon: Icons.monitor_heart_outlined,
              accent: stageColor,
              children: [
                InfoRow(
                  label: l10n.labelReproductiveStatus,
                  value: widget.animal.reproductiveStatus.displayName,
                  icon: Icons.favorite_border,
                ),
                InfoRow(
                  label: l10n.labelFirstService,
                  value: formatDate(widget.animal.firstServiceDate),
                  icon: Icons.event_available_outlined,
                ),
                InfoRow(
                  label: l10n.labelLastService,
                  value: formatDate(widget.animal.lastServiceDate),
                  icon: Icons.update_outlined,
                ),
                InfoRow(
                  label: l10n.labelExpectedCalving,
                  value: formatDate(widget.animal.expectedCalvingDate),
                  icon: Icons.event_outlined,
                ),
              ],
            ),
        ],
      ),
    );
  }
}

class InfoSection extends StatelessWidget {
  const InfoSection({
    super.key,
    required this.title,
    required this.icon,
    required this.children,
    this.accent,
  });

  final String title;
  final IconData icon;
  final List<Widget> children;
  final Color? accent;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: AppCard(
        title: title,
        leading: Icon(icon, color: scheme.primary),
        body: Column(
          children: [
            for (var index = 0; index < children.length; index++) ...[
              children[index],
              if (index != children.length - 1)
                const Divider(height: AppSpacing.xl),
            ],
          ],
        ),
      ),
    );
  }
}

class InfoRow extends StatelessWidget {
  const InfoRow({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
    this.accent,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color? accent;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context);
    final isNoData = value.toLowerCase() == l10n.valueNoData.toLowerCase();

    Widget valueWidget;
    if (isNoData) {
      valueWidget = Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.7),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          value,
          style: textTheme.titleSmall?.copyWith(
            color: colorScheme.onSurfaceVariant,
            fontWeight: FontWeight.w600,
          ),
        ),
      );
    } else {
      valueWidget = Text(
        value,
        style: textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.w800,
          color: accent ?? colorScheme.onSurface,
          height: 1.28,
        ),
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 2),
          child: Icon(
            icon,
            size: 22,
            color: colorScheme.onSurfaceVariant.withValues(alpha: 0.86),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          flex: 9,
          child: Text(
            label,
            style: textTheme.titleMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w500,
              height: 1.3,
            ),
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          flex: 10,
          child: Align(alignment: Alignment.topLeft, child: valueWidget),
        ),
      ],
    );
  }
}

class BoolRow extends StatelessWidget {
  const BoolRow({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
  });

  final String label;
  final bool value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context);
    final color = value ? const Color(0xFF1A9F4E) : const Color(0xFFE24A4A);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 2),
          child: Icon(
            icon,
            size: 22,
            color: colorScheme.onSurfaceVariant.withValues(alpha: 0.86),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          flex: 9,
          child: Text(
            label,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w500,
              height: 1.3,
            ),
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          flex: 10,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              value ? l10n.booleanYes : l10n.booleanNo,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w800,
                color: color,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
