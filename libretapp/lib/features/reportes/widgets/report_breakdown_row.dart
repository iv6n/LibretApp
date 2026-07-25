/// Breakdown row with proportional progress bar for species/category counts.
library;

import 'package:flutter/material.dart';
import 'package:libretapp/theme/app_theme.dart';

class ReportBreakdownRow extends StatelessWidget {
  const ReportBreakdownRow({
    required this.label,
    required this.count,
    required this.total,
    this.color,
    super.key,
  });

  final String label;
  final int count;
  final int total;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final accent = color ?? AppColors.primary;
    final share = total <= 0 ? 0.0 : count / total;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  label,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Text(
                '$count',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: accent,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              minHeight: 6,
              value: share.clamp(0.0, 1.0),
              backgroundColor: accent.withValues(alpha: 0.12),
              valueColor: AlwaysStoppedAnimation(accent),
            ),
          ),
        ],
      ),
    );
  }
}
