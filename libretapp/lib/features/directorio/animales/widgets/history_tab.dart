/// features \u203a directorio \u203a animales \u203a widgets \u203a history_tab \u2014 history tab on the animal detail page.
library;

import 'dart:math' show max;

import 'package:flutter/material.dart';
import 'package:libretapp/app/widgets/widgets.dart';
import 'package:libretapp/features/directorio/animales/domain/animal_domain.dart';
import 'package:libretapp/features/directorio/lotes/domain/services/weight_performance_calculator.dart';
import 'package:libretapp/features/directorio/animales/widgets/detail_helpers.dart';
import 'package:libretapp/l10n/app_localizations.dart';
import 'package:libretapp/theme/app_theme.dart';

class HistoryTab extends StatelessWidget {
  const HistoryTab({super.key, required this.animal, required this.data});

  final AnimalEntity animal;
  final DetailData data;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final bottomInset = ShellInsets.bottomSafePadding(context);
    final fabBottomPadding = ShellInsets.fabDockPadding(context);
    final contentPadding = EdgeInsets.fromLTRB(
      14,
      14,
      14,
      max(bottomInset + 2, fabBottomPadding + 8),
    );

    final events = _buildTimelineEvents(l10n);

    if (events.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.timeline_outlined,
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
            ],
          ),
        ),
      );
    }

    return ListView(
      key: const PageStorageKey('history_list'),
      padding: contentPadding,
      children: [
        if (data.weights.isNotEmpty) ...[
          _WeightHistorySummary(weights: data.weights),
          const SizedBox(height: 8),
        ],
        ...events.asMap().entries.map(
          (entry) => _TimelineEntry(
            event: entry.value,
            isLast: entry.key == events.length - 1,
          ),
        ),
      ],
    );
  }

  List<_TimelineEvent> _buildTimelineEvents(AppLocalizations l10n) {
    final events = <_TimelineEvent>[];

    // Animal creation
    events.add(
      _TimelineEvent(
        date: animal.creationDate,
        icon: Icons.badge,
        color: const Color(0xFF6B5A4A),
        title: l10n.detailCreated,
        subtitle: formatDate(animal.creationDate, withTime: true),
      ),
    );

    // Weight records
    for (final r in data.weights) {
      events.add(
        _TimelineEvent(
          date: r.date,
          icon: Icons.monitor_weight,
          color: AppColors.success,
          title:
              '${l10n.detailRecordsWeights}: ${r.weight.toStringAsFixed(1)} kg',
          subtitle:
              r.notes ??
              (r.method == WeightMethod.scale
                  ? l10n.detailFormWeightMethodScale
                  : l10n.detailFormWeightMethodEstimated),
        ),
      );
    }

    for (final r in data.weanings) {
      events.add(_TimelineEvent(date: r.date, icon: Icons.child_friendly,
        color: AppColors.earth, title: 'Destete',
        subtitle: r.weightKg == null ? r.notes : '${r.weightKg} kg · ${r.weightMethod == WeightMethod.scale ? 'Báscula' : 'Estimado'}'));
    }
    // Health records
    for (final r in data.health) {
      events.add(
        _TimelineEvent(
          date: r.date,
          icon: Icons.medical_services,
          color: AppColors.primary,
          title: '${l10n.detailRecordsHealth}: ${r.type.displayName}',
          subtitle: r.product,
        ),
      );
    }

    // Reproduction records
    for (final r in data.reproductions) {
      events.add(
        _TimelineEvent(
          date: r.eventDate,
          icon: Icons.favorite,
          color: AppColors.earth,
          title:
              '${l10n.detailRecordsReproduction}: ${r.serviceType?.displayName ?? 'Parto'}',
          subtitle: r.maleSireIdentifier ?? r.notes,
        ),
      );
    }

    // Production records
    for (final r in data.productions) {
      events.add(
        _TimelineEvent(
          date: r.date,
          icon: Icons.analytics,
          color: AppColors.secondary,
          title: '${l10n.detailRecordsProduction}: ${r.type.displayName}',
          subtitle: r.value != null ? '${r.value} ${r.unit ?? ''}' : r.notes,
        ),
      );
    }

    // Milking records
    for (final record in data.milkingRecords) {
      events.add(
        _TimelineEvent(
          date: record.session.occurredAt,
          icon: Icons.water_drop,
          color: Colors.lightBlue,
          title: 'Ordeña: ${record.entry.liters.toStringAsFixed(2)} L',
          subtitle: record.session.shift.label,
        ),
      );
    }

    // Movement records
    for (final r in data.movements) {
      events.add(
        _TimelineEvent(
          date: r.date,
          icon: Icons.route,
          color: AppColors.secondary,
          title: '${l10n.detailRecordsMovements}: ${r.reason.displayName}',
          subtitle: '→ ${r.toLocation}',
        ),
      );
    }

    // Commercial records
    for (final r in data.commercial) {
      events.add(
        _TimelineEvent(
          date: r.date,
          icon: Icons.store,
          color: const Color(0xFF8B623A),
          title: '${l10n.detailRecordsCommercial}: ${r.type.displayName}',
          subtitle: r.amount != null
              ? '${r.amount} ${r.currency ?? ''}'
              : r.notes,
        ),
      );
    }

    // Cost records
    for (final r in data.costs) {
      events.add(
        _TimelineEvent(
          date: r.date,
          icon: Icons.payments,
          color: AppColors.accent,
          title: '${l10n.detailRecordsCosts}: ${r.type.displayName}',
          subtitle: '${r.amount} ${r.currency ?? ''}',
        ),
      );
    }

    // Sort descending (most recent first)
    events.sort((a, b) => b.date.compareTo(a.date));

    return events;
  }
}

class _WeightHistorySummary extends StatelessWidget {
  const _WeightHistorySummary({required this.weights});

  final List<WeightRecord> weights;

  @override
  Widget build(BuildContext context) {
    final ordered = weights.toList(growable: false)
      ..sort((a, b) => a.date.compareTo(b.date));
    final latest = ordered.last;
    final calculator = const WeightPerformanceCalculator();
    final latestPerformance = calculator.calculateAnimalPerformance(
      animalUuid: latest.animalUuid ?? '',
      currentWeightKg: latest.weight,
      measuredAt: latest.date,
      history: ordered,
      currentRecordUuid: latest.recordUuid,
      currentMethod: latest.method,
    );
    final cutoff = DateTime.now().subtract(const Duration(days: 30));
    final baseline = ordered
        .where((record) => record.method == WeightMethod.scale && !record.date.isAfter(cutoff))
        .lastOrNull;
    final last30Gain = baseline == null || latest.method != WeightMethod.scale
        ? null
        : latest.weight - baseline.weight;
    final points = ordered.length > 8
        ? ordered.sublist(ordered.length - 8)
        : ordered;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'PESO',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w800,
                letterSpacing: 0.8,
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: _WeightMetric(
                    'Actual',
                    '${latest.weight.toStringAsFixed(1)} kg',
                  ),
                ),
                Expanded(
                  child: _WeightMetric(
                    'Últimos 30 días',
                    _signedKg(last30Gain),
                  ),
                ),
                Expanded(
                  child: _WeightMetric(
                    'GDP',
                    _adg(latestPerformance.adgKgPerDay),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            SizedBox(
              height: 90,
              width: double.infinity,
              child: CustomPaint(
                painter: _WeightTrendPainter(
                  points.map((record) => record.weight).toList(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _WeightMetric extends StatelessWidget {
  const _WeightMetric(this.label, this.value);

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(label, style: Theme.of(context).textTheme.bodySmall),
      const SizedBox(height: 2),
      Text(
        value,
        style: Theme.of(
          context,
        ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800),
      ),
    ],
  );
}

class _WeightTrendPainter extends CustomPainter {
  _WeightTrendPainter(this.values);

  final List<double> values;

  @override
  void paint(Canvas canvas, Size size) {
    if (values.length < 2) return;
    final minValue = values.reduce((a, b) => a < b ? a : b);
    final maxValue = values.reduce((a, b) => a > b ? a : b);
    final range = (maxValue - minValue).abs();
    final verticalRange = range == 0 ? 1.0 : range.toDouble();
    final path = Path();
    for (var index = 0; index < values.length; index++) {
      final x = values.length == 1
          ? 0.0
          : size.width * index / (values.length - 1).toDouble();
      final y =
          size.height -
          ((values[index] - minValue) / verticalRange) * (size.height - 8) -
          4;
      if (index == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    final paint = Paint()
      ..color = Colors.green.shade700
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    canvas.drawPath(path, paint);
    final pointPaint = Paint()..color = Colors.green.shade700;
    for (var index = 0; index < values.length; index++) {
      final x = values.length == 1
          ? 0.0
          : size.width * index / (values.length - 1).toDouble();
      final y =
          size.height -
          ((values[index] - minValue) / verticalRange) * (size.height - 8) -
          4;
      canvas.drawCircle(Offset(x, y), 3.5, pointPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _WeightTrendPainter oldDelegate) =>
      oldDelegate.values != values;
}

String _signedKg(double? value) => value == null
    ? '—'
    : '${value >= 0 ? '+' : ''}${value.toStringAsFixed(1)} kg';

String _adg(double? value) =>
    value == null ? '—' : '${value.toStringAsFixed(2)} kg/d';

class _TimelineEvent {
  const _TimelineEvent({
    required this.date,
    required this.icon,
    required this.color,
    required this.title,
    this.subtitle,
  });

  final DateTime date;
  final IconData icon;
  final Color color;
  final String title;
  final String? subtitle;
}

class _TimelineEntry extends StatelessWidget {
  const _TimelineEntry({required this.event, required this.isLast});

  final _TimelineEvent event;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Timeline rail
          SizedBox(
            width: 40,
            child: Column(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: event.color.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(event.icon, size: 16, color: event.color),
                ),
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 2,
                      color: theme.colorScheme.outlineVariant,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          // Content
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    formatDate(event.date, withTime: true),
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    event.title,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (event.subtitle != null && event.subtitle!.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: Text(
                        event.subtitle!,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
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
}
