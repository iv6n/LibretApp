/// Compact directory card for a cultivation.
library;

import 'package:flutter/material.dart';
import 'package:libretapp/features/directorio/cultivos/domain/cultivation_entity.dart';
import 'package:libretapp/features/ubicaciones/domain/enums/crop_growth_stage.dart';
import 'package:libretapp/features/ubicaciones/domain/enums/crop_status.dart';
import 'package:libretapp/features/ubicaciones/domain/enums/crop_task_type.dart';

class CultivationCard extends StatelessWidget {
  const CultivationCard({
    super.key,
    required this.cultivation,
    required this.locationName,
    required this.onTap,
    this.onLocationTap,
  });

  final CultivationEntity cultivation;
  final String? locationName;
  final VoidCallback onTap;
  final VoidCallback? onLocationTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final overdue = cultivation.isOverdueForWatering;
    final pending = cultivation.tasks.where((task) => !task.completed).toList()
      ..sort((a, b) => a.dueDate.compareTo(b.dueDate));
    final nextAction = pending.isNotEmpty
        ? '${pending.first.type.displayName} · ${_date(pending.first.dueDate)}'
        : cultivation.isActive
        ? 'Regar · ${_date(cultivation.nextWateringDate)}'
        : null;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: BorderSide(
          color: overdue
              ? scheme.error.withValues(alpha: 0.55)
              : scheme.outlineVariant.withValues(alpha: 0.45),
        ),
      ),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 23,
                    backgroundColor: scheme.primaryContainer,
                    child: Padding(
                      padding: const EdgeInsets.all(3),
                      child: Image.asset(
                        cultivation.growthStage.assetPath,
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) => Icon(
                          _iconForScale(cultivation.scale),
                          color: scheme.onPrimaryContainer,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 11),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          cultivation.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        if (cultivation.variety.isNotEmpty)
                          Text(
                            cultivation.variety,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: scheme.onSurfaceVariant,
                            ),
                          ),
                      ],
                    ),
                  ),
                  _StatusChip(status: cultivation.status),
                ],
              ),
              const SizedBox(height: 11),
              Material(
                color: scheme.surfaceContainerHighest.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(11),
                child: InkWell(
                  onTap: onLocationTap,
                  borderRadius: BorderRadius.circular(11),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 8,
                    ),
                    child: Row(
                      children: [
                        Icon(
                          locationName == null
                              ? Icons.location_off_outlined
                              : Icons.location_on_outlined,
                          size: 17,
                          color: scheme.onSurfaceVariant,
                        ),
                        const SizedBox(width: 7),
                        Expanded(
                          child: Text(
                            locationName ?? 'Sin ubicación',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.bodySmall?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        if (onLocationTap != null)
                          const Icon(Icons.chevron_right, size: 18),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 7,
                runSpacing: 7,
                children: [
                  _InfoChip(
                    icon: Icons.straighten_outlined,
                    label: cultivation.measureLabel,
                  ),
                  _InfoChip(
                    icon: Icons.trending_up,
                    label: cultivation.growthStage.displayName,
                  ),
                  _InfoChip(
                    icon: Icons.water_drop_outlined,
                    label: overdue ? 'Riego atrasado' : 'Riego al día',
                    warning: overdue,
                  ),
                ],
              ),
              if (nextAction != null) ...[
                const SizedBox(height: 10),
                Row(
                  children: [
                    Icon(
                      Icons.event_note_outlined,
                      size: 17,
                      color: scheme.primary,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        'Próximo: $nextAction',
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  IconData _iconForScale(CultivationScale scale) => switch (scale) {
    CultivationScale.individual => Icons.local_florist_outlined,
    CultivationScale.group => Icons.yard_outlined,
    CultivationScale.area => Icons.grass_outlined,
  };

  String _date(DateTime value) => '${value.day}/${value.month}';
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.status});

  final CropStatus status;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final active = status == CropStatus.active;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: active
            ? scheme.primaryContainer
            : scheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        status.displayName,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: active ? scheme.onPrimaryContainer : scheme.onSurfaceVariant,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({
    required this.icon,
    required this.label,
    this.warning = false,
  });

  final IconData icon;
  final String label;
  final bool warning;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final color = warning ? scheme.error : scheme.onSurfaceVariant;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: warning
            ? scheme.errorContainer.withValues(alpha: 0.45)
            : scheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: color,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
