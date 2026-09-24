/// features › directorio › lotes › lote_card — card widget for displaying a lote.
library;

import 'package:flutter/material.dart';
import 'package:libretapp/features/directorio/lotes/domain/entities/lote_entity.dart';
import 'package:libretapp/theme/app_theme.dart';

class LoteCard extends StatelessWidget {
  const LoteCard({
    super.key,
    required this.lote,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
    this.locationName,
    this.onLocationTap,
    this.onAnimalsTap,
  });

  final LoteEntity lote;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final String? locationName;
  final VoidCallback? onLocationTap;
  final VoidCallback? onAnimalsTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final cardColor = theme.brightness == Brightness.dark
        ? colorScheme.surface
        : LightColors.background;
    final footerColor = theme.brightness == Brightness.dark
        ? Color.alphaBlend(
            Colors.white.withValues(alpha: 0.035),
            colorScheme.surface,
          )
        : LightColors.surfaceContainerLow;
    final animalCount = lote.animalUuids.length;
    final statusColor = lote.active ? colorScheme.primary : colorScheme.outline;
    final accentColor = lote.active
        ? colorScheme.primary
        : colorScheme.outlineVariant;

    return Card(
      color: cardColor,
      margin: const EdgeInsets.only(bottom: 14),
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: colorScheme.outlineVariant.withValues(alpha: 0.38),
          width: 1,
        ),
      ),
      elevation: 1.2,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Header ────────────────────────────────────────────────
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(14, 14, 14, 10),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      CircleAvatar(
                        radius: 22,
                        backgroundColor: colorScheme.primary.withValues(
                          alpha: theme.brightness == Brightness.dark
                              ? 0.22
                              : 0.14,
                        ),
                        child: Icon(
                          Icons.layers_outlined,
                          size: 22,
                          color: colorScheme.primary,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              lote.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            if (lote.description != null &&
                                lote.description!.isNotEmpty) ...[
                              const SizedBox(height: 2),
                              Text(
                                lote.description!,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      _StatusChip(
                        label: lote.active ? 'Activo' : 'Cerrado',
                        color: statusColor,
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(14, 2, 14, 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _ContextAction(
                        icon: locationName == null
                            ? Icons.location_off_outlined
                            : Icons.location_on_outlined,
                        label: locationName ?? 'Sin ubicación',
                        onTap: onLocationTap,
                      ),
                      const SizedBox(height: 9),
                      Wrap(
                        spacing: 7,
                        runSpacing: 7,
                        children: [
                          _MetricChip(
                            icon: Icons.pets_outlined,
                            label: animalCount == 0
                                ? 'Sin animales asignados'
                                : '$animalCount ${animalCount == 1 ? 'animal' : 'animales'}',
                            onTap: animalCount == 0 ? null : onAnimalsTap,
                          ),
                          _MetricChip(
                            icon: Icons.update_outlined,
                            label:
                                'Actualizado ${_formatDate(lote.lastUpdateDate)}',
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                // ── Footer ────────────────────────────────────────────────
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(color: footerColor),
                  padding: const EdgeInsets.fromLTRB(14, 9, 14, 9),
                  child: Row(
                    children: [
                      Icon(
                        lote.active
                            ? Icons.play_circle_outline
                            : Icons.history_outlined,
                        size: 18,
                        color: colorScheme.onSurfaceVariant,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        lote.active
                            ? 'Creado ${_formatDate(lote.createdAt)}'
                            : 'Cerrado ${_formatDate(lote.closedAt ?? lote.lastUpdateDate)}',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            Positioned(
              left: 0,
              top: 0,
              bottom: 0,
              width: 4,
              child: ColoredBox(color: accentColor),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final year = date.year.toString();
    return '$day/$month/$year';
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class _ContextAction extends StatelessWidget {
  const _ContextAction({required this.icon, required this.label, this.onTap});

  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Material(
      color: scheme.surfaceContainerHighest.withValues(alpha: 0.48),
      borderRadius: BorderRadius.circular(11),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(11),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          child: Row(
            children: [
              Icon(icon, size: 19, color: scheme.onSurfaceVariant),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w700),
                ),
              ),
              if (onTap != null)
                Icon(
                  Icons.chevron_right,
                  size: 18,
                  color: scheme.onSurfaceVariant,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MetricChip extends StatelessWidget {
  const _MetricChip({required this.icon, required this.label, this.onTap});

  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final child = Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 8),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest.withValues(alpha: 0.62),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: scheme.onSurfaceVariant),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: scheme.onSurfaceVariant,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
    final constrainedChild = ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 250),
      child: child,
    );
    if (onTap == null) return constrainedChild;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: constrainedChild,
    );
  }
}
