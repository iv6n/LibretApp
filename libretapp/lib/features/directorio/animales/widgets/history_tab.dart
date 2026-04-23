import 'dart:math' show max;

import 'package:flutter/material.dart';
import 'package:libretapp/app/widgets/widgets.dart';
import 'package:libretapp/features/directorio/animales/domain/animal_domain.dart';
import 'package:libretapp/features/directorio/animales/widgets/detail_helpers.dart';
import 'package:libretapp/l10n/app_localizations.dart';

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

    return ListView.builder(
      key: const PageStorageKey('history_list'),
      padding: contentPadding,
      itemCount: events.length,
      itemBuilder: (context, index) {
        final event = events[index];
        final isLast = index == events.length - 1;
        return _TimelineEntry(event: event, isLast: isLast);
      },
    );
  }

  List<_TimelineEvent> _buildTimelineEvents(AppLocalizations l10n) {
    final events = <_TimelineEvent>[];

    // Animal creation
    events.add(
      _TimelineEvent(
        date: animal.creationDate,
        icon: Icons.badge,
        color: Colors.blueGrey,
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
          color: Colors.green,
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

    // Health records
    for (final r in data.health) {
      events.add(
        _TimelineEvent(
          date: r.date,
          icon: Icons.medical_services,
          color: Colors.teal,
          title: '${l10n.detailRecordsHealth}: ${r.type.displayName}',
          subtitle: r.product,
        ),
      );
    }

    // Reproduction records
    for (final r in data.reproductions) {
      events.add(
        _TimelineEvent(
          date: r.serviceDate,
          icon: Icons.favorite,
          color: Colors.pink,
          title:
              '${l10n.detailRecordsReproduction}: ${r.serviceType.displayName}',
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
          color: Colors.blue,
          title: '${l10n.detailRecordsProduction}: ${r.type.displayName}',
          subtitle: r.value != null ? '${r.value} ${r.unit ?? ''}' : r.notes,
        ),
      );
    }

    // Movement records
    for (final r in data.movements) {
      events.add(
        _TimelineEvent(
          date: r.date,
          icon: Icons.route,
          color: Colors.indigo,
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
          color: Colors.purple,
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
          color: Colors.brown,
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
