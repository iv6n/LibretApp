import 'dart:math';

import 'package:flutter/material.dart';
import 'package:libretapp/app/app_shell.dart';
import 'package:libretapp/features/animales/domain/animal_domain.dart';
import 'package:libretapp/features/animales/widgets/detail_helpers.dart';
import 'package:libretapp/l10n/app_localizations.dart';

class InfoTab extends StatelessWidget {
  const InfoTab({super.key, required this.animal});

  final AnimalEntity animal;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final stageColor = detailStageColor(animal.lifeStage);
    final healthColor = detailColorFromHex(animal.healthStatus.hexColor);
    final riskColor = detailColorFromHex(animal.riskLevel.hexColor);
    final bottomInset = AppShell.bottomSafePadding(context);
    final fabBottomPadding = AppShell.fabDockPadding(context);
    // Use the larger of content inset and FAB dock to keep items clear.
    final listBottomPadding = max(bottomInset + 2, fabBottomPadding + 8);

    return SingleChildScrollView(
      key: const PageStorageKey('info_scroll'),
      padding: EdgeInsets.fromLTRB(14, 14, 14, listBottomPadding),
      child: Column(
        children: [
          InfoSection(
            title: l10n.sectionIdentification,
            children: [
              InfoRow(label: l10n.labelEarTag, value: animal.earTagNumber),
              InfoRow(
                label: l10n.labelVisualId,
                value: animal.visualId ?? l10n.valueNotAssigned,
              ),
              InfoRow(
                label: l10n.labelBrand,
                value: animal.brand ?? l10n.valueNoData,
              ),
              InfoRow(
                label: l10n.labelRfid,
                value: animal.rfidTag ?? l10n.valueNoData,
              ),
              InfoRow(
                label: l10n.labelBatch,
                value: animal.batchId ?? l10n.valueNoData,
              ),
            ],
          ),
          InfoSection(
            title: l10n.sectionProductiveProfile,
            children: [
              InfoRow(
                label: l10n.labelSpecies,
                value: animal.species.displayName,
              ),
              InfoRow(
                label: l10n.labelCategory,
                value: animal.category.displayName,
              ),
              InfoRow(
                label: l10n.labelLifeStage,
                value: animal.lifeStage.displayName,
                accent: stageColor,
              ),
              InfoRow(label: l10n.labelBreed, value: animal.breed),
              InfoRow(label: l10n.labelSex, value: animal.sex.displayName),
              InfoRow(label: l10n.labelAge, value: formatAge(animal.ageMonths)),
              InfoRow(
                label: l10n.labelPurpose,
                value: animal.productionPurpose.displayName,
              ),
              InfoRow(
                label: l10n.labelFeedType,
                value: animal.feedType ?? l10n.valueNoData,
              ),
              InfoRow(
                label: l10n.labelDailyGain,
                value: animal.dailyGainEstimate != null
                    ? '${animal.dailyGainEstimate!.toStringAsFixed(2)} kg/día'
                    : l10n.valueNoData,
              ),
            ],
          ),
          InfoSection(
            title: l10n.sectionHealth,
            children: [
              InfoRow(
                label: l10n.labelHealthStatus,
                value: animal.healthStatus.displayName,
                accent: healthColor,
              ),
              InfoRow(
                label: l10n.labelBodyCondition,
                value: animal.bodyConditionScore != null
                    ? '${animal.bodyConditionScore}/9'
                    : l10n.valueNoData,
              ),
              InfoRow(
                label: l10n.labelRisk,
                value: animal.riskLevel.displayName,
                accent: riskColor,
              ),
              BoolRow(label: l10n.labelVaccinated, value: animal.vaccinated),
              BoolRow(label: l10n.labelDewormed, value: animal.dewormed),
              BoolRow(label: l10n.labelVitamins, value: animal.hasVitamins),
              BoolRow(
                label: l10n.labelChronicCondition,
                value: animal.hasChronicIssues,
              ),
              if ((animal.chronicNotes ?? '').isNotEmpty)
                InfoRow(
                  label: l10n.labelChronicNotes,
                  value: animal.chronicNotes!,
                ),
            ],
          ),
          InfoSection(
            title: l10n.sectionLocation,
            children: [
              InfoRow(
                label: l10n.labelPaddock,
                value: animal.currentPaddockId ?? l10n.valueNoData,
              ),
              InfoRow(
                label: l10n.labelLastMovement,
                value: formatDate(animal.lastMovementDate),
              ),
              InfoRow(
                label: l10n.labelObservation,
                value: animal.underObservation
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
                value: animal.reproductiveStatus.displayName,
              ),
              InfoRow(
                label: l10n.labelFirstService,
                value: formatDate(animal.firstServiceDate),
              ),
              InfoRow(
                label: l10n.labelLastService,
                value: formatDate(animal.lastServiceDate),
              ),
              InfoRow(
                label: l10n.labelExpectedCalving,
                value: formatDate(animal.expectedCalvingDate),
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
