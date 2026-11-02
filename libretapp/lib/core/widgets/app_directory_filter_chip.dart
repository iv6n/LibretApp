import 'package:flutter/material.dart';

/// Shared filter treatment for the Directory's category lists.
class AppDirectoryFilterChip extends StatelessWidget {
  const AppDirectoryFilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
    this.count,
    this.icon,
    this.accentColor,
    super.key,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;
  final int? count;
  final IconData? icon;
  final Color? accentColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final accent = accentColor ?? scheme.primary;
    final foreground = selected ? accent : scheme.onSurfaceVariant;
    final border = selected
        ? accent.withValues(alpha: 0.52)
        : scheme.outlineVariant;
    final background = selected
        ? accent.withValues(
            alpha: theme.brightness == Brightness.dark ? .20 : .10,
          )
        : scheme.surface;
    final textScale = MediaQuery.textScalerOf(context).scale(1);
    final tapTargetHeight = 17 * textScale + 12;
    final chipHeight = tapTargetHeight > 48 ? tapTargetHeight : 48.0;

    return Semantics(
      button: true,
      selected: selected,
      label: count == null ? label : '$label, $count',
      excludeSemantics: true,
      onTap: onTap,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          customBorder: const StadiumBorder(),
          child: SizedBox(
            height: chipHeight,
            child: Center(
              child: Material(
                color: background,
                shape: StadiumBorder(side: BorderSide(color: border)),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (icon != null) ...[
                        Icon(icon, size: 18, color: foreground),
                        const SizedBox(width: 6),
                      ],
                      Text(
                        label,
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: foreground,
                          fontWeight: selected
                              ? FontWeight.w800
                              : FontWeight.w600,
                        ),
                      ),
                      if (count != null) ...[
                        const SizedBox(width: 6),
                        Text(
                          '$count',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: foreground,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
