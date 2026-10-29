import 'package:flutter/material.dart';
import 'package:libretapp/core/widgets/generated_asset_icon.dart';
import 'package:libretapp/core/widgets/record_form_style.dart';
import 'package:libretapp/theme/theme.dart';

/// Common hierarchy with a distinct icon, accent and explanation per record.
class AppRecordHeader extends StatelessWidget {
  const AppRecordHeader({required this.style, this.title, super.key});

  final RecordFormStyle style;
  final String? title;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Semantics(
      container: true,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: Color.alphaBlend(
            style.color.withValues(alpha: 0.09),
            theme.colorScheme.surface,
          ),
          borderRadius: BorderRadius.circular(AppRadii.md),
          border: Border.all(color: style.color.withValues(alpha: 0.3)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ExcludeSemantics(
              child: Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: style.color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(AppRadii.sm),
                ),
                child: Center(
                  child: style.assetPath == null
                      ? Icon(style.icon, color: theme.colorScheme.onSurface)
                      : GeneratedAssetIcon(
                          assetPath: style.assetPath!,
                          fallbackIcon: style.icon,
                          size: 30,
                        ),
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Semantics(
                    header: true,
                    child: Text(
                      title ?? style.label,
                      style: theme.textTheme.titleMedium,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    style.description,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
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
}
