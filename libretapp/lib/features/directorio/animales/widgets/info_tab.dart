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
  const InfoTab({super.key, required this.animal, this.lotesRepository});

  final AnimalEntity animal;
  final LotesRepository? lotesRepository;

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
    final stageColor = detailStageColor(widget.animal.lifeStage);
    final healthColor = detailColorFromHex(widget.animal.healthStatus.hexColor);
    final riskColor = detailColorFromHex(widget.animal.riskLevel.hexColor);
    final bottomInset = ShellInsets.bottomSafePadding(context);
    final fabBottomPadding = ShellInsets.fabDockPadding(context);
    // Use the larger of content inset and FAB dock to keep items clear.
    final listBottomPadding = max(bottomInset + 2, fabBottomPadding + 8);

    final batchDisplay = _loadingBatchName
        ? '(cargando...)'
        : (_batchName ?? l10n.valueNoData);

    return SingleChildScrollView(
      key: const PageStorageKey('info_scroll'),
      padding: EdgeInsets.fromLTRB(14, 14, 14, listBottomPadding),
      child: Column(
        children: [
          InfoSection(
            title: l10n.sectionIdentification,
            children: [
              InfoRow(
                label: l10n.labelEarTag,
                value: widget.animal.earTagNumber,
              ),
              InfoRow(
                label: l10n.labelVisualId,
                value: widget.animal.visualId ?? l10n.valueNotAssigned,
              ),
              InfoRow(
                label: l10n.labelBrand,
                value: widget.animal.brand ?? l10n.valueNoData,
              ),
              InfoRow(
                label: l10n.labelRfid,
                value: widget.animal.rfidTag ?? l10n.valueNoData,
              ),
              InfoRow(label: l10n.labelBatch, value: batchDisplay),
            ],
          ),
          InfoSection(
            title: l10n.sectionProductiveProfile,
            children: [
              InfoRow(
                label: l10n.labelSpecies,
                value: widget.animal.species.displayName,
              ),
              InfoRow(
                label: l10n.labelCategory,
                value: widget.animal.category.displayName,
              ),
              InfoRow(
                label: l10n.labelLifeStage,
                value: widget.animal.lifeStage.displayName,
                accent: stageColor,
              ),
              InfoRow(label: l10n.labelBreed, value: widget.animal.breed),
              InfoRow(
                label: l10n.labelSex,
                value: widget.animal.sex.displayName,
              ),
              InfoRow(
                label: l10n.labelAge,
                value: formatAge(widget.animal.ageMonths),
              ),
              InfoRow(
                label: l10n.labelPurpose,
                value: widget.animal.productionPurpose.displayName,
              ),
              InfoRow(
                label: 'Etapa de Producción',
                value: widget.animal.productionStage.displayName,
              ),
              InfoRow(
                label: 'Sistema de Producción',
                value: widget.animal.productionSystem.displayName,
              ),
              InfoRow(
                label: l10n.labelFeedType,
                value: widget.animal.feedType ?? l10n.valueNoData,
              ),
              InfoRow(
                label: l10n.labelDailyGain,
                value: widget.animal.dailyGainEstimate != null
                    ? '${widget.animal.dailyGainEstimate!.toStringAsFixed(2)} kg/día'
                    : l10n.valueNoData,
              ),
            ],
          ),
          InfoSection(
            title: l10n.sectionHealth,
            children: [
              if (widget.animal.needsImmediateAttention)
                InfoRow(
                  label: '⚠️ Atención Requerida',
                  value: widget.animal.requiresAttention
                      ? 'Sí'
                      : 'En Observación',
                ),
              if (widget.animal.healthIssueCount > 0)
                InfoRow(
                  label: 'Problemas de Salud Detectados',
                  value: '${widget.animal.healthIssueCount}',
                ),
              InfoRow(
                label: l10n.labelHealthStatus,
                value: widget.animal.healthStatus.displayName,
                accent: healthColor,
              ),
              InfoRow(
                label: l10n.labelBodyCondition,
                value: widget.animal.bodyConditionScore != null
                    ? '${widget.animal.bodyConditionScore}/9'
                    : l10n.valueNoData,
              ),
              InfoRow(
                label: l10n.labelRisk,
                value: widget.animal.riskLevel.displayName,
                accent: riskColor,
              ),
              BoolRow(
                label: l10n.labelVaccinated,
                value: widget.animal.vaccinated,
              ),
              BoolRow(label: l10n.labelDewormed, value: widget.animal.dewormed),
              BoolRow(
                label: l10n.labelVitamins,
                value: widget.animal.hasVitamins,
              ),
              BoolRow(
                label: l10n.labelChronicCondition,
                value: widget.animal.hasChronicIssues,
              ),
              if ((widget.animal.chronicNotes ?? '').isNotEmpty)
                InfoRow(
                  label: l10n.labelChronicNotes,
                  value: widget.animal.chronicNotes!,
                ),
            ],
          ),
          InfoSection(
            title: l10n.sectionLocation,
            children: [
              InfoRow(
                label: l10n.labelPaddock,
                value: widget.animal.currentPaddockId ?? l10n.valueNoData,
              ),
              InfoRow(
                label: l10n.labelLastMovement,
                value: formatDate(widget.animal.lastMovementDate),
              ),
              InfoRow(
                label: l10n.labelObservation,
                value: widget.animal.underObservation
                    ? l10n.animalUnderObservation
                    : l10n.valueNo,
              ),
            ],
          ),
          InfoSection(
            title: l10n.sectionReproduction,
            children: [
              InfoRow(
                label: l10n.labelReproductiveStatus,
                value: widget.animal.reproductiveStatus.displayName,
              ),
              InfoRow(
                label: l10n.labelFirstService,
                value: formatDate(widget.animal.firstServiceDate),
              ),
              InfoRow(
                label: l10n.labelLastService,
                value: formatDate(widget.animal.lastServiceDate),
              ),
              InfoRow(
                label: l10n.labelExpectedCalving,
                value: formatDate(widget.animal.expectedCalvingDate),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class InfoSection extends StatelessWidget {
  const InfoSection({super.key, required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 14),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 10),
            ...children.map(
              (child) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: child,
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
    this.accent,
  });

  final String label;
  final String value;
  final Color? accent;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 160,
          child: Text(
            label,
            style: textTheme.bodySmall?.copyWith(color: Colors.grey[700]),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            value,
            style: textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: accent ?? Colors.black87,
            ),
          ),
        ),
      ],
    );
  }
}

class BoolRow extends StatelessWidget {
  const BoolRow({super.key, required this.label, required this.value});

  final String label;
  final bool value;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final color = value ? Colors.green : Colors.red;
    return Row(
      children: [
        Icon(value ? Icons.check_circle : Icons.cancel, size: 18, color: color),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            '$label: ${value ? l10n.booleanYes : l10n.booleanNo}',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
        ),
      ],
    );
  }
}
