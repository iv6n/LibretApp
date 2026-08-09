/// features > biblioteca > widgets > adaptation_box — the additive regional
/// adaptation box for a chapter. Per ADAPTIVE_CONTENT.md in the content
/// repo: "Chapter text is always shown. The regional adaptation box is
/// additive." This widget is that box — it never replaces chapter text.
library;

import 'package:flutter/material.dart';
import 'package:libretapp/features/biblioteca/data/book_content.dart';
import 'package:libretapp/theme/app_theme.dart';

class AdaptationBox extends StatelessWidget {
  const AdaptationBox({required this.entry, this.taskTips = const [], super.key});

  final AdaptationEntry entry;
  final List<TaskTip> taskTips;

  bool get _isGeneral => entry.states.contains('general');

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final accent = _isGeneral ? theme.colorScheme.outline : AppColors.secondary;

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppRadii.md),
        color: accent.withValues(alpha: 0.07),
        border: Border.all(color: accent.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                _isGeneral ? Icons.info_outline : Icons.map_outlined,
                size: 18,
                color: accent,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  entry.title,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: accent,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(entry.body, style: theme.textTheme.bodyMedium?.copyWith(height: 1.45)),
          if (entry.actions.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.xs),
            for (final action in entry.actions)
              Padding(
                padding: const EdgeInsets.only(bottom: 2),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.check_circle_outline, size: 16, color: accent),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(action, style: theme.textTheme.bodySmall),
                    ),
                  ],
                ),
              ),
          ],
          if (taskTips.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.sm),
            const Divider(height: 1),
            const SizedBox(height: AppSpacing.sm),
            for (final tip in taskTips)
              Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.lightbulb_outline, size: 16, color: accent),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(tip.tip, style: theme.textTheme.bodySmall),
                    ),
                  ],
                ),
              ),
          ],
        ],
      ),
    );
  }
}
