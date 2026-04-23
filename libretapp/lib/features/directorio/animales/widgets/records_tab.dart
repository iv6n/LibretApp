import 'dart:math';

import 'package:flutter/material.dart';
import 'package:libretapp/app/widgets/widgets.dart';
import 'package:libretapp/features/directorio/animales/domain/animal_domain.dart';
import 'package:libretapp/features/directorio/animales/widgets/detail_helpers.dart';
import 'package:libretapp/l10n/app_localizations.dart';

class RecordsTab extends StatelessWidget {
  const RecordsTab({super.key, required this.data});

  final DetailData data;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final bottomInset = ShellInsets.bottomSafePadding(context);
    final fabBottomPadding = ShellInsets.fabDockPadding(context);
    // Use the larger of content inset and FAB dock to keep items clear.
    final listBottomPadding = max(bottomInset + 2, fabBottomPadding + 8);

    final hasAnyRecords =
        data.weights.isNotEmpty ||
        data.productions.isNotEmpty ||
        data.health.isNotEmpty ||
        data.reproductions.isNotEmpty ||
        data.commercial.isNotEmpty ||
        data.movements.isNotEmpty ||
        data.costs.isNotEmpty;

    if (!hasAnyRecords) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.note_add_outlined,
                size: 64,
                color: Theme.of(
                  context,
                ).colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
              ),
              const SizedBox(height: 16),
              Text(
                l10n.detailNoRecordsYet,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                l10n.detailNoRecordsHint,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return SingleChildScrollView(
      key: const PageStorageKey('records_scroll'),
      padding: EdgeInsets.fromLTRB(14, 14, 14, listBottomPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          RecordSection(
            icon: Icons.monitor_weight,
            title: l10n.detailRecordsWeights,
            children: data.weights
                .map(
                  (r) => RecordTile(
                    title:
                        '${fmtDate(r.date)} · ${r.weight.toStringAsFixed(1)} kg',
                    subtitle:
                        r.notes ??
                        (r.method == WeightMethod.scale
                            ? l10n.detailFormWeightMethodScale
                            : l10n.detailFormWeightMethodEstimated),
                  ),
                )
                .toList(),
          ),
          RecordSection(
            icon: Icons.analytics,
            title: l10n.detailRecordsProduction,
            children: data.productions
                .map(
                  (r) => RecordTile(
                    title: '${fmtDate(r.date)} · ${r.type.displayName}',
                    subtitle: [
                      if (r.value != null)
                        '${l10n.detailRecordsValue}: ${r.value} ${r.unit ?? ''}',
                      if (r.score != null)
                        '${l10n.detailRecordsScore}: ${r.score}',
                      if (r.notes != null) r.notes!,
                    ].where((e) => e.isNotEmpty).join(' · '),
                  ),
                )
                .toList(),
          ),
          RecordSection(
            icon: Icons.medical_services,
            title: l10n.detailRecordsHealth,
            children: data.health
                .map(
                  (r) => RecordTile(
                    title: '${fmtDate(r.date)} · ${r.type.displayName}',
                    subtitle: [
                      r.product,
                      if (r.dose != null) '${l10n.detailRecordsDose} ${r.dose}',
                      if (r.appliedBy != null) r.appliedBy!,
                      if (r.cause != null)
                        '${l10n.detailRecordsCause}: ${r.cause}',
                    ].where((e) => e.isNotEmpty).join(' · '),
                  ),
                )
                .toList(),
          ),
          RecordSection(
            icon: Icons.favorite,
            title: l10n.detailRecordsReproduction,
            children: data.reproductions
                .map(
                  (r) => RecordTile(
                    title:
                        '${fmtDate(r.serviceDate)} · ${r.serviceType.displayName}',
                    subtitle: [
                      if (r.maleSireIdentifier != null)
                        'Padre: ${r.maleSireIdentifier}',
                      if (r.pregnancyResult != null &&
                          r.pregnancyResult != PregnancyCheckResult.notChecked)
                        'Preñez: ${r.pregnancyResult!.displayName}',
                      if (r.expectedCalvingDate != null)
                        'Parto esperado: ${fmtDate(r.expectedCalvingDate!)}',
                      if (r.actualCalvingDate != null)
                        'Parto real: ${fmtDate(r.actualCalvingDate!)}',
                      if (r.calvingResult != null) r.calvingResult!,
                      if (r.notes != null) r.notes!,
                    ].where((e) => e.isNotEmpty).join(' · '),
                  ),
                )
                .toList(),
          ),
          RecordSection(
            icon: Icons.store,
            title: l10n.detailRecordsCommercial,
            children: data.commercial
                .map(
                  (r) => RecordTile(
                    title: '${fmtDate(r.date)} · ${r.type.displayName}',
                    subtitle: [
                      if (r.amount != null)
                        '${l10n.detailRecordsAmount}: ${r.amount} ${r.currency ?? ''}',
                      if (r.counterparty != null) r.counterparty!,
                      if (r.notes != null) r.notes!,
                    ].where((e) => e.isNotEmpty).join(' · '),
                  ),
                )
                .toList(),
          ),
          RecordSection(
            icon: Icons.route,
            title: l10n.detailRecordsMovements,
            children: data.movements
                .map(
                  (r) => RecordTile(
                    title: '${fmtDate(r.date)} · ${r.reason.displayName}',
                    subtitle: [
                      if (r.fromLocation != null)
                        '${l10n.detailRecordsFrom} ${r.fromLocation}',
                      '${l10n.detailRecordsTo} ${r.toLocation}',
                      if (r.notes != null) r.notes!,
                    ].where((e) => e.isNotEmpty).join(' · '),
                  ),
                )
                .toList(),
          ),
          RecordSection(
            icon: Icons.payments,
            title: l10n.detailRecordsCosts,
            children: data.costs
                .map(
                  (r) => RecordTile(
                    title: '${fmtDate(r.date)} · ${r.type.displayName}',
                    subtitle:
                        '${l10n.detailRecordsAmount}: ${r.amount} ${r.currency ?? ''}${r.notes != null ? ' · ${r.notes}' : ''}',
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }
}

class RecordSection extends StatelessWidget {
  const RecordSection({
    super.key,
    required this.icon,
    required this.title,
    required this.children,
  });

  final IconData icon;
  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    if (children.isEmpty) return const SizedBox.shrink();
    return Card(
      margin: const EdgeInsets.only(bottom: 14),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: Theme.of(context).colorScheme.primary),
                const SizedBox(width: 8),
                Text(title, style: Theme.of(context).textTheme.titleMedium),
              ],
            ),
            const SizedBox(height: 8),
            ...children,
          ],
        ),
      ),
    );
  }
}

class RecordTile extends StatelessWidget {
  const RecordTile({super.key, required this.title, this.subtitle});

  final String title;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      dense: true,
      contentPadding: EdgeInsets.zero,
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
      subtitle: subtitle != null && subtitle!.isNotEmpty
          ? Text(subtitle!)
          : null,
    );
  }
}
