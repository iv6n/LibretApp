/// Compact directory card for a cultivation.
library;

import 'package:flutter/material.dart';
import 'package:libretapp/core/widgets/app_directory_layout.dart';
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
    final metrics = AppDirectoryMetrics.of(context);
    final overdue = cultivation.isOverdueForWatering;
    final pending = cultivation.tasks.where((task) => !task.completed).toList()
      ..sort((a, b) => a.dueDate.compareTo(b.dueDate));
    final nextAction = pending.isNotEmpty
        ? '${pending.first.type.displayName} · ${_date(pending.first.dueDate)}'
        : cultivation.isActive
        ? 'Regar · ${_date(cultivation.nextWateringDate)}'
        : null;

    return AppDirectoryCardFrame(
      borderColor: overdue
          ? scheme.error.withValues(alpha: 0.55)
          : scheme.outlineVariant.withValues(alpha: 0.45),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppDirectoryCardFrame.cornerRadius),
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.all(metrics.cardPaddingV),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: metrics.cardBadgeSize / 2,
                    backgroundColor: scheme.primaryContainer,
                    child: Padding(
                      padding: const EdgeInsets.all(3),
                      child: Image.asset(
                        cultivation.growthStage.assetPath,
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) => Icon(
                          _iconForScale(cultivation.scale),
                          size: metrics.cardBadgeIconSize,
                          color: scheme.onPrimaryContainer,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: metrics.cardGap),
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
              SizedBox(height: metrics.headerGap),
              Material(
                color: scheme.surfaceContainerHighest.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(11),
                child: InkWell(
                  onTap: onLocationTap,
                  borderRadius: BorderRadius.circular(11),
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: metrics.cardGap - 2,
                      vertical: 8,
                    ),
                    child: Row(
                      children: [
                        Icon(
                          locationName == null
                              ? Icons.location_off_outlined
                              : Icons.location_on_outlined,
                          size: metrics.cardInlineIconSize,
                          color: scheme.onSurfaceVariant,
                        ),
                        SizedBox(width: metrics.cardChipGap),
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
                          Icon(
                            Icons.chevron_right,
                            size: metrics.cardInlineIconSize + 1,
                          ),
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(height: metrics.headerGap - 1),
              Wrap(
                spacing: metrics.cardChipGap,
                runSpacing: metrics.cardChipGap,
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
                SizedBox(height: metrics.headerGap - 2),
                Row(
                  children: [
                    Icon(
                      Icons.event_note_outlined,
                      size: metrics.cardInlineIconSize,
                      color: scheme.primary,
                    ),
                    SizedBox(width: metrics.actionsGap),
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
    final metrics = AppDirectoryMetrics.of(context);
    final active = status == CropStatus.active;
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: metrics.cardChipGap + 1,
        vertical: 5,
      ),
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
    final metrics = AppDirectoryMetrics.of(context);
    final color = warning ? scheme.error : scheme.onSurfaceVariant;
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: metrics.cardChipGap + 1,
        vertical: 5,
      ),
      decoration: BoxDecoration(
        color: warning
            ? scheme.errorContainer.withValues(alpha: 0.45)
            : scheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: metrics.cardInlineIconSize - 3, color: color),
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
