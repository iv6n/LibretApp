/// Compact bottom navigation for the Lite experience.
library;

import 'package:flutter/material.dart';
import 'package:libretapp/app/widgets/app_bottom_nav_bar.dart';
import 'package:libretapp/core/utils/color_contrast.dart';
import 'package:libretapp/theme/app_theme.dart';

class AppLiteBottomNavBar extends StatelessWidget {
  const AppLiteBottomNavBar({
    super.key,
    required this.items,
    required this.selectedIndex,
    required this.onItemSelected,
  });

  final List<AppNavItemConfig> items;
  final int selectedIndex;
  final ValueChanged<int> onItemSelected;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final chrome = theme.extension<ShellChromeTheme>();
    final background = chrome?.navBackground ?? theme.colorScheme.surface;
    final selected = readableTextColor(
      chrome?.navSelectedItem ?? theme.colorScheme.primary,
      background,
    );
    final unselected = readableTextColor(
      chrome?.navUnselectedItem ?? theme.colorScheme.onSurfaceVariant,
      background,
    );
    final textScale = MediaQuery.textScalerOf(context).scale(14) / 14;

    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 360;
        final selectedLabelOnly =
            textScale >= 1.5 || constraints.maxWidth < 300;
        final height = textScale >= 1.5
            ? 66.0
            : compact
            ? 58.0
            : 62.0;
        final horizontalMargin = compact ? 8.0 : 10.0;

        return Padding(
          padding: const EdgeInsets.only(top: 4, bottom: 6),
          child: Center(
            heightFactor: 1,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 520, minWidth: 0),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: horizontalMargin),
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: background,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: chrome?.navShadow ?? const Color(0x33000000),
                        blurRadius: 16,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: SizedBox(
                    height: height,
                    child: Row(
                      children: [
                        for (final item in items)
                          Expanded(
                            flex:
                                selectedLabelOnly && item.index == selectedIndex
                                ? 3
                                : 2,
                            child: _LiteDestination(
                              key: ValueKey('lite-nav-${item.index}'),
                              item: item,
                              selected: item.index == selectedIndex,
                              selectedColor: selected,
                              unselectedColor: unselected,
                              showLabel:
                                  !selectedLabelOnly ||
                                  item.index == selectedIndex,
                              compact: compact,
                              onTap: () => onItemSelected(item.index),
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
      },
    );
  }
}

class _LiteDestination extends StatelessWidget {
  const _LiteDestination({
    super.key,
    required this.item,
    required this.selected,
    required this.selectedColor,
    required this.unselectedColor,
    required this.showLabel,
    required this.compact,
    required this.onTap,
  });

  final AppNavItemConfig item;
  final bool selected;
  final Color selectedColor;
  final Color unselectedColor;
  final bool showLabel;
  final bool compact;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = selected ? selectedColor : unselectedColor;
    return Semantics(
      button: true,
      selected: selected,
      label: item.label,
      onTap: onTap,
      child: ExcludeSemantics(
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(18),
          child: SizedBox.expand(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(item.icon, size: compact ? 21 : 23, color: color),
                if (showLabel) ...[
                  const SizedBox(height: 2),
                  Text(
                    item.label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: compact ? 9 : 10,
                      height: 1.05,
                      fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
                      color: color,
                    ),
                  ),
                ],
                const SizedBox(height: 3),
                Container(
                  width: 18,
                  height: 2,
                  decoration: BoxDecoration(
                    color: selected ? selectedColor : Colors.transparent,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
