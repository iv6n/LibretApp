/// core › advisor › widgets › advisor_tips_panel — widget displaying advisor tips for an animal.
library;

import 'package:flutter/material.dart';
import 'package:libretapp/core/advisor/livestock_tip.dart';
import 'package:libretapp/theme/app_theme.dart';

/// Widget que muestra los consejos de la "Biblia Ganadera".
///
/// Se puede incrustar en cualquier formulario o vista de detalle.
/// Los tips se muestran colapsados por defecto; el usuario
/// puede expandir cada uno para ver la descripción completa.
///
/// ```dart
/// AdvisorTipsPanel(
///   tips: LivestockAdvisor.forMovement(animal, record),
/// )
/// ```
class AdvisorTipsPanel extends StatelessWidget {
  const AdvisorTipsPanel({super.key, required this.tips});

  final List<LivestockTip> tips;

  @override
  Widget build(BuildContext context) {
    if (tips.isEmpty) return const SizedBox.shrink();

    final criticalCount = tips
        .where((t) => t.severity == TipSeverity.critical)
        .length;
    final warningCount = tips
        .where((t) => t.severity == TipSeverity.warning)
        .length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _Header(
          totalCount: tips.length,
          criticalCount: criticalCount,
          warningCount: warningCount,
        ),
        const SizedBox(height: AppSpacing.xs),
        ...tips.map((tip) => _TipCard(tip: tip)),
      ],
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({
    required this.totalCount,
    required this.criticalCount,
    required this.warningCount,
  });

  final int totalCount;
  final int criticalCount;
  final int warningCount;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      children: [
        Icon(Icons.auto_stories, color: theme.colorScheme.primary, size: 20),
        const SizedBox(width: AppSpacing.xs),
        Text(
          'Biblia Ganadera',
          style: AppTextStyles.label.copyWith(color: theme.colorScheme.primary),
        ),
        const SizedBox(width: AppSpacing.xs),
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.xs,
            vertical: 2,
          ),
          decoration: BoxDecoration(
            color: _badgeColor,
            borderRadius: BorderRadius.circular(AppRadii.sm),
          ),
          child: Text(
            '$totalCount',
            style: AppTextStyles.label.copyWith(
              color: Colors.white,
              fontSize: 10,
            ),
          ),
        ),
      ],
    );
  }

  Color get _badgeColor {
    if (criticalCount > 0) return AppColors.error;
    if (warningCount > 0) return AppColors.warning;
    return AppColors.primary;
  }
}

class _TipCard extends StatefulWidget {
  const _TipCard({required this.tip});

  final LivestockTip tip;

  @override
  State<_TipCard> createState() => _TipCardState();
}

class _TipCardState extends State<_TipCard> {
  bool _expanded = false;

  @override
  void initState() {
    super.initState();
    // Auto-expand critical tips.
    _expanded = widget.tip.severity == TipSeverity.critical;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tip = widget.tip;

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.xs),
      child: Material(
        color: _backgroundColor(theme),
        borderRadius: BorderRadius.circular(AppRadii.sm),
        child: InkWell(
          borderRadius: BorderRadius.circular(AppRadii.sm),
          onTap: () => setState(() => _expanded = !_expanded),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.sm),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    _SeverityDot(severity: tip.severity),
                    const SizedBox(width: AppSpacing.xs),
                    Text(
                      tip.category.icon,
                      style: const TextStyle(fontSize: 14),
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    Expanded(
                      child: Text(
                        tip.title,
                        style: AppTextStyles.label.copyWith(
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                    ),
                    Icon(
                      _expanded
                          ? Icons.keyboard_arrow_up
                          : Icons.keyboard_arrow_down,
                      size: 18,
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                    ),
                  ],
                ),
                if (_expanded) ...[
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    tip.description,
                    style: AppTextStyles.body.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
                      fontSize: 12,
                    ),
                  ),
                  if (tip.source != null) ...[
                    const SizedBox(height: AppSpacing.xxs),
                    Text(
                      '📖 ${tip.source}',
                      style: AppTextStyles.label.copyWith(
                        color: theme.colorScheme.onSurface.withValues(
                          alpha: 0.5,
                        ),
                        fontSize: 10,
                        fontWeight: FontWeight.w400,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Color _backgroundColor(ThemeData theme) {
    switch (widget.tip.severity) {
      case TipSeverity.critical:
        return AppColors.error.withValues(alpha: 0.08);
      case TipSeverity.warning:
        return AppColors.warning.withValues(alpha: 0.08);
      case TipSeverity.info:
        return theme.colorScheme.primary.withValues(alpha: 0.06);
    }
  }
}

class _SeverityDot extends StatelessWidget {
  const _SeverityDot({required this.severity});

  final TipSeverity severity;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 8,
      height: 8,
      decoration: BoxDecoration(shape: BoxShape.circle, color: _color),
    );
  }

  Color get _color {
    switch (severity) {
      case TipSeverity.critical:
        return AppColors.error;
      case TipSeverity.warning:
        return AppColors.warning;
      case TipSeverity.info:
        return AppColors.primary;
    }
  }
}

/// Muestra los tips como un bottom sheet modal independiente.
///
/// Útil para mostrar recomendaciones después de guardar un registro.
Future<void> showAdvisorTipsSheet(
  BuildContext context, {
  required List<LivestockTip> tips,
}) async {
  if (tips.isEmpty) return;

  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    builder: (ctx) {
      final theme = Theme.of(ctx);
      return DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.4,
        minChildSize: 0.25,
        maxChildSize: 0.85,
        builder: (context, scrollController) {
          return Container(
            decoration: BoxDecoration(
              color: theme.scaffoldBackgroundColor,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(AppRadii.lg),
              ),
            ),
            child: ListView(
              controller: scrollController,
              padding: const EdgeInsets.all(AppSpacing.md),
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                AdvisorTipsPanel(tips: tips),
              ],
            ),
          );
        },
      );
    },
  );
}
