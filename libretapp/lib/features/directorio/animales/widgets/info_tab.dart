import 'dart:math';

import 'package:flutter/material.dart';
import 'package:libretapp/app/widgets/widgets.dart';
import 'package:libretapp/core/di/injection.dart';
import 'package:libretapp/core/services/logger_service.dart';
import 'package:libretapp/features/directorio/animales/domain/animal_domain.dart';
import 'package:libretapp/features/directorio/lotes/infrastructure/lotes_repository.dart';
import 'package:libretapp/features/directorio/animales/widgets/detail_helpers.dart';
import 'package:libretapp/l10n/app_localizations.dart';

class InfoTab extends StatefulWidget {
  const InfoTab({
    super.key,
    required this.animal,
    this.lotesRepository,
    this.accentColor,
  });

  final AnimalEntity animal;
  final LotesRepository? lotesRepository;
  final Color? accentColor;

  @override
  State<InfoTab> createState() => _InfoTabState();
}

class _InfoTabState extends State<InfoTab> {
  late LotesRepository _lotesRepository;
  String? _batchName;
  bool _loadingBatchName = false;

  @override
  void initState() {
    super.initState();
    _lotesRepository = widget.lotesRepository ?? locator<LotesRepository>();
    _loadBatchName();
  }

  Future<void> _loadBatchName() async {
    if (widget.animal.batchUuid == null) {
      return;
    }

    setState(() => _loadingBatchName = true);
    try {
      final lote = await _lotesRepository.getByUuid(widget.animal.batchUuid!);
      if (mounted && lote != null) {
        setState(() => _batchName = lote.nombre);
      }
    } catch (e, st) {
      LoggerService.w(
        'No se pudo resolver el nombre del lote para ${widget.animal.uuid}: $e',
        tag: 'InfoTab',
      );
      LoggerService.d(st.toString(), tag: 'InfoTab');
    } finally {
      if (mounted) {
        setState(() => _loadingBatchName = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
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

    return SingleChildScrollView(
      key: const PageStorageKey('info_scroll'),
      padding: EdgeInsets.fromLTRB(16, 12, 16, listBottomPadding),
      child: Column(
        children: [
          InfoSection(
            title: l10n.sectionIdentification,
            icon: Icons.badge_outlined,
            accent: stageColor,
            children: [
              InfoRow(
                label: l10n.labelEarTag,
                value: widget.animal.earTagNumber,
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
            title: l10n.sectionProductiveProfile,
            icon: Icons.insights_outlined,
            accent: stageColor,
            children: [
              InfoRow(
                label: l10n.labelSpecies,
                value: widget.animal.species.displayName,
                icon: Icons.pets_outlined,
              ),
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
              InfoRow(
                label: l10n.labelBreed,
                value: widget.animal.breed,
                icon: Icons.biotech_outlined,
              ),
              InfoRow(
                label: l10n.labelSex,
                value: widget.animal.sex.displayName,
                icon: Icons.female_outlined,
              ),
              InfoRow(
                label: l10n.labelAge,
                value: formatAge(widget.animal.ageMonths),
                icon: Icons.schedule_outlined,
              ),
              InfoRow(
                label: l10n.labelPurpose,
                value: widget.animal.productionPurpose.displayName,
                icon: Icons.flag_outlined,
              ),
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
                value: widget.animal.currentPaddockId ?? l10n.valueNoData,
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
            ],
          ),
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
    final accentColor = accent ?? Theme.of(context).colorScheme.primary;
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: accentColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: Colors.white, size: 18),
                ),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF172232),
                    fontSize: 18,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            for (var index = 0; index < children.length; index++)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Column(
                  children: [
                    children[index],
                    if (index != children.length - 1)
                      const Padding(
                        padding: EdgeInsets.only(top: 10),
                        child: Divider(height: 1),
                      ),
                  ],
                ),
              ),
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
            fontWeight: FontWeight.w700,
          ),
        ),
      );
    } else {
      valueWidget = Text(
        value,
        style: textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.w800,
          color: accent ?? colorScheme.onSurface,
          fontSize: 16,
        ),
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Icon(icon, size: 22, color: colorScheme.onSurfaceVariant),
        const SizedBox(width: 10),
        Expanded(
          flex: 9,
          child: Text(
            label,
            style: textTheme.titleLarge?.copyWith(
              color: colorScheme.onSurfaceVariant,
              fontSize: 15,
            ),
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          flex: 10,
          child: Align(alignment: Alignment.centerLeft, child: valueWidget),
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
    final l10n = AppLocalizations.of(context);
    final color = value ? const Color(0xFF1A9F4E) : const Color(0xFFE24A4A);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Icon(
          icon,
          size: 22,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
        const SizedBox(width: 10),
        Expanded(
          flex: 9,
          child: Text(
            label,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              fontSize: 15,
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
