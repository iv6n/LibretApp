/// Shared layout primitives for the Directory's category lists.
library;

import 'package:flutter/material.dart';

/// Standard horizontal filter strip used by Directory sections.
class AppDirectoryFilterRow extends StatelessWidget {
  const AppDirectoryFilterRow({
    super.key,
    required this.children,
    this.trailing,
  });

  final List<Widget> children;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final textScale = MediaQuery.textScalerOf(context).scale(1);
    final rowHeight = (52 + ((textScale - 1).clamp(0, 3) * 16)).toDouble();
    final filters = ListView.separated(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      itemCount: children.length,
      separatorBuilder: (_, _) => const SizedBox(width: 8),
      itemBuilder: (context, index) => children[index],
    );

    return SizedBox(
      height: rowHeight,
      child: trailing == null
          ? filters
          : Row(
              children: [
                Expanded(child: filters),
                Padding(
                  padding: const EdgeInsets.only(right: 4),
                  child: trailing,
                ),
              ],
            ),
    );
  }
}

/// Centers an empty-state card in the area left below a section's filters.
class AppDirectoryEmptySlot extends StatelessWidget {
  const AppDirectoryEmptySlot({
    super.key,
    required this.child,
    this.bottomPadding = 0,
  });

  final Widget child;
  final double bottomPadding;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(16, 12, 16, bottomPadding),
      child: Align(
        alignment: Alignment.center,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: SizedBox(width: double.infinity, child: child),
        ),
      ),
    );
  }
}

/// Consistent width, outer spacing, and shape for Directory record cards.
class AppDirectoryCardFrame extends StatelessWidget {
  const AppDirectoryCardFrame({
    super.key,
    required this.child,
    this.color,
    this.borderColor,
    this.borderWidth = 1,
    this.elevation = 1.2,
    this.margin = const EdgeInsets.only(bottom: 14),
    this.frameOnly = false,
  });

  static const double maxWidth = 720;
  static const double cornerRadius = 20;

  final Widget child;
  final Color? color;
  final Color? borderColor;
  final double borderWidth;
  final double elevation;
  final EdgeInsetsGeometry margin;
  final bool frameOnly;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: maxWidth),
        child: Padding(
          padding: EdgeInsets.fromLTRB(
            16,
            0,
            16,
            margin.resolve(Directionality.of(context)).bottom,
          ),
          child: frameOnly
              ? child
              : Card(
                  margin: EdgeInsets.zero,
                  clipBehavior: Clip.antiAlias,
                  color: color,
                  elevation: elevation,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(cornerRadius),
                    side: BorderSide(
                      color:
                          borderColor ??
                          Theme.of(
                            context,
                          ).colorScheme.outlineVariant.withValues(alpha: .4),
                      width: borderWidth,
                    ),
                  ),
                  child: child,
                ),
        ),
      ),
    );
  }
}
