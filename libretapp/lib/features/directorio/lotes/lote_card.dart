/// features › directorio › lotes › lote_card — card widget for displaying a lote.
library;

import 'package:flutter/material.dart';
import 'package:libretapp/features/directorio/lotes/domain/entities/lote_entity.dart';

class LoteCard extends StatelessWidget {
  const LoteCard({
    super.key,
    required this.lote,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
  });

  final LoteEntity lote;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final headerColor = theme.brightness == Brightness.dark
        ? Color.alphaBlend(
            colorScheme.primary.withValues(alpha: 0.18),
            colorScheme.surface,
          )
        : Color.alphaBlend(
            colorScheme.primary.withValues(alpha: 0.10),
            colorScheme.surface,
          );
    final footerColor = theme.brightness == Brightness.dark
        ? Color.alphaBlend(
            Colors.white.withValues(alpha: 0.035),
            colorScheme.surface,
          )
        : colorScheme.surfaceContainerHighest.withValues(alpha: 0.45);

    return Card(
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header ────────────────────────────────────────────────
            Container(
              width: double.infinity,
              decoration: BoxDecoration(color: headerColor),
              padding: const EdgeInsets.fromLTRB(10, 8, 10, 6),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: colorScheme.primary.withValues(
                      alpha: 0.18,
                    ),
                    child: Icon(
                      Icons.layers_outlined,
                      size: 20,
                      color: colorScheme.primary,
                    ),
                  ),
                  const SizedBox(width: 10),
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
                  _CountChip(
                    count: lote.animalUuids.length,
                    color: colorScheme.primary,
                  ),
                ],
              ),
            ),
            // ── Footer ────────────────────────────────────────────────
            Container(
              width: double.infinity,
              decoration: BoxDecoration(color: footerColor),
              padding: const EdgeInsets.fromLTRB(14, 6, 14, 6),
              child: Row(
                children: [
                  Icon(
                    Icons.calendar_today_outlined,
                    size: 14,
                    color: colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    _formatDate(lote.createdAt),
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
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

class _CountChip extends StatelessWidget {
  const _CountChip({required this.count, required this.color});

  final int count;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.pets_outlined, size: 12, color: color),
          const SizedBox(width: 4),
          Text(
            '$count',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
