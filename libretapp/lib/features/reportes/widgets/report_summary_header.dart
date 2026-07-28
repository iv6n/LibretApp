/// Hero header for the ranch reports summary tab.
library;

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:libretapp/features/reportes/data/report_summary.dart';
import 'package:libretapp/theme/app_theme.dart';

class ReportSummaryHeader extends StatelessWidget {
  const ReportSummaryHeader({required this.summary, super.key});

  final ReportSummary summary;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final attention = summary.healthAlertsCount +
        summary.unvaccinatedCount +
        summary.underObservationCount;
    final stable = attention == 0;
    final statusColor = stable ? AppColors.success : AppColors.warning;
    final updatedAt = DateFormat('d MMM, HH:mm').format(summary.generatedAt);

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(AppRadii.lg),
        border: Border.all(
          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.55),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 14,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Resumen del rancho',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF174332),
                  ),
                ),
              ),
              Text(
                '${summary.totalAnimals} animales',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Icon(
                stable
                    ? Icons.check_circle_outline
                    : Icons.warning_amber_rounded,
                size: 20,
                color: statusColor,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  stable
                      ? 'Operación estable'
                      : '$attention pendientes de seguimiento',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            'Actualizado $updatedAt',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
