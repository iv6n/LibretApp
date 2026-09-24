/// app › widgets › app_segmented_tab_bar — pill-style segmented tab bar.
library;

import 'package:flutter/material.dart';
import 'package:libretapp/theme/app_theme.dart';

/// Visual variants for the reusable segmented tab bar.
enum AppSegmentedTabBarVariant { standard, colorAccented }

class AppSegmentedTabItem {
  const AppSegmentedTabItem({
    required this.label,
    required this.icon,
    this.accentColor,
  });

  final String label;
  final IconData icon;

  /// Optional category color used by [AppSegmentedTabBarVariant.colorAccented].
  ///
  /// It is deliberately optional so existing consumers retain the original
  /// single-color appearance.
  final Color? accentColor;
}

class AppSegmentedTabBar extends StatelessWidget
    implements PreferredSizeWidget {
  const AppSegmentedTabBar({
    required this.controller,
    required this.items,
    this.keyPrefix = 'segmented_tab',
    this.variant = AppSegmentedTabBarVariant.standard,
    super.key,
  });

  static const double barHeight = 42;
  static const double totalHeight = 54;
  static const double accentedTotalHeight = 72;

  final TabController controller;
  final List<AppSegmentedTabItem> items;
  final String keyPrefix;
  final AppSegmentedTabBarVariant variant;

  @override
  Size get preferredSize => Size.fromHeight(
    variant == AppSegmentedTabBarVariant.colorAccented
        ? accentedTotalHeight
        : totalHeight,
  );

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final colors = _SegmentedTabBarColors.resolve(theme, isDark);
    final isColorAccented = variant == AppSegmentedTabBarVariant.colorAccented;
    final height = isColorAccented ? accentedTotalHeight : totalHeight;
    final radius = isColorAccented ? 24.0 : 18.0;

    if (items.isEmpty) {
      return SizedBox(height: height);
    }

    return SizedBox(
      height: height,
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          isColorAccented ? 8 : 6,
          isColorAccented ? 4 : 2,
          isColorAccented ? 8 : 6,
          isColorAccented ? 4 : 2,
        ),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: colors.track,
            borderRadius: BorderRadius.circular(radius),
            boxShadow: [
              BoxShadow(
                color: colors.shadow,
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(radius),
            child: AnimatedBuilder(
              animation: controller,
              builder: (context, _) {
                final selectedIndex = controller.index.clamp(
                  0,
                  items.length - 1,
                );

                return Row(
                  children: [
                    for (var index = 0; index < items.length; index++) ...[
                      Expanded(
                        child: _SegmentedTabButton(
                          index: index,
                          item: items[index],
                          selected: index == selectedIndex,
                          activeColor: colors.activeForeground,
                          inactiveColor: colors.inactiveForeground,
                          activeSurface: isColorAccented
                              ? Color.alphaBlend(
                                  (items[index].accentColor ??
                                          colors.activeForeground)
                                      .withValues(alpha: isDark ? 0.18 : 0.08),
                                  isDark
                                      ? theme.colorScheme.surface
                                      : LightColors.background,
                                )
                              : colors.activeSurface,
                          colorAccented: isColorAccented,
                          keyPrefix: keyPrefix,
                          onTap: () {
                            if (controller.index == index) return;
                            controller.animateTo(index);
                          },
                        ),
                      ),
                      if (index < items.length - 1)
                        _SegmentedTabDivider(
                          color: colors.divider,
                          hidden:
                              index == selectedIndex ||
                              index + 1 == selectedIndex,
                        ),
                    ],
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

class AppSegmentedTabBarSliverDelegate extends SliverPersistentHeaderDelegate {
  AppSegmentedTabBarSliverDelegate({required this.tabBar});

  final AppSegmentedTabBar tabBar;

  @override
  double get minExtent => tabBar.preferredSize.height;

  @override
  double get maxExtent => tabBar.preferredSize.height;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return Material(
      color: Theme.of(context).scaffoldBackgroundColor,
      elevation: overlapsContent ? 2 : 0,
      child: tabBar,
    );
  }

  @override
  bool shouldRebuild(covariant AppSegmentedTabBarSliverDelegate oldDelegate) =>
      tabBar != oldDelegate.tabBar;
}

class _SegmentedTabBarColors {
  const _SegmentedTabBarColors({
    required this.track,
    required this.activeSurface,
    required this.activeForeground,
    required this.inactiveForeground,
    required this.divider,
    required this.shadow,
  });

  final Color track;
  final Color activeSurface;
  final Color activeForeground;
  final Color inactiveForeground;
  final Color divider;
  final Color shadow;

  static _SegmentedTabBarColors resolve(ThemeData theme, bool isDark) {
    if (isDark) {
      return _SegmentedTabBarColors(
        track: Color.alphaBlend(
          Colors.white.withValues(alpha: 0.06),
          theme.colorScheme.surface,
        ),
        activeSurface: AppColors.primary.withValues(alpha: 0.22),
        activeForeground: AppColors.primary,
        inactiveForeground: Colors.white.withValues(alpha: 0.68),
        divider: Colors.white.withValues(alpha: 0.10),
        shadow: Colors.black.withValues(alpha: 0.18),
      );
    }

    return const _SegmentedTabBarColors(
      track: LightColors.elevated,
      activeSurface: LightColors.background,
      activeForeground: AppColors.primary,
      inactiveForeground: LightColors.textMuted,
      divider: LightColors.borderSoft,
      shadow: Color(0x0F000000),
    );
  }
}

class _SegmentedTabButton extends StatelessWidget {
  const _SegmentedTabButton({
    required this.index,
    required this.item,
    required this.selected,
    required this.activeColor,
    required this.inactiveColor,
    required this.activeSurface,
    required this.colorAccented,
    required this.keyPrefix,
    required this.onTap,
  });

  final int index;
  final AppSegmentedTabItem item;
  final bool selected;
  final Color activeColor;
  final Color inactiveColor;
  final Color activeSurface;
  final bool colorAccented;
  final String keyPrefix;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final accent = item.accentColor ?? activeColor;
    final labelColor = selected ? accent : inactiveColor;
    final iconColor = colorAccented && item.accentColor != null
        ? accent
        : labelColor;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final buttonRadius = colorAccented ? 20.0 : 15.0;

    return Semantics(
      button: true,
      selected: selected,
      child: Tooltip(
        message: item.label,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            key: ValueKey<String>('${keyPrefix}_button_$index'),
            borderRadius: BorderRadius.circular(buttonRadius),
            splashFactory: NoSplash.splashFactory,
            splashColor: Colors.transparent,
            highlightColor: Colors.transparent,
            hoverColor: Colors.transparent,
            focusColor: Colors.transparent,
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.all(4),
              child: AnimatedContainer(
                key: ValueKey<String>('${keyPrefix}_background_$index'),
                duration: const Duration(milliseconds: 180),
                curve: Curves.easeOutCubic,
                height: double.infinity,
                decoration: BoxDecoration(
                  color: selected ? activeSurface : Colors.transparent,
                  borderRadius: BorderRadius.circular(buttonRadius),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (colorAccented)
                      Container(
                        width: 38,
                        height: 38,
                        decoration: BoxDecoration(
                          color: accent.withValues(alpha: isDark ? 0.22 : 0.12),
                          shape: BoxShape.circle,
                        ),
                        alignment: Alignment.center,
                        child: Icon(
                          item.icon,
                          size: selected ? 23 : 22,
                          color: iconColor,
                        ),
                      )
                    else
                      Icon(
                        item.icon,
                        size: selected ? 22 : 21,
                        color: iconColor,
                      ),
                    SizedBox(height: colorAccented ? 3 : 2),
                    Flexible(
                      child: Text(
                        item.label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: labelColor,
                          fontSize: colorAccented ? 11.5 : 10.5,
                          height: 1.05,
                          fontWeight: selected
                              ? FontWeight.w800
                              : FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SegmentedTabDivider extends StatelessWidget {
  const _SegmentedTabDivider({required this.color, required this.hidden});

  final Color color;
  final bool hidden;

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      opacity: hidden ? 0 : 1,
      duration: const Duration(milliseconds: 120),
      child: SizedBox(
        width: 1,
        child: Center(child: Container(width: 1, height: 24, color: color)),
      ),
    );
  }
}
