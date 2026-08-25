/// app › widgets › app_bottom_nav_bar — bottom navigation bar widget for the app shell.
library;

import 'package:flutter/material.dart';
import 'package:libretapp/theme/app_theme.dart';

/// Configuration for a single bottom-navigation item.
class AppNavItemConfig {
  const AppNavItemConfig({
    required this.index,
    required this.icon,
    required this.label,
  });

  final int index;
  final IconData icon;
  final String label;
}

class AppBottomNavBar extends StatelessWidget {
  const AppBottomNavBar({
    super.key,
    required this.items,
    required this.selectedIndex,
    required this.onItemSelected,
    required this.center,
    this.centerIndex = 2,
    this.barHeight = 67,
    this.barHorizontalPadding = 10,
    this.barBottomGap = 10,
    this.centerGapWidth = 56,
    required this.backgroundColor,
    required this.shadowColor,
  });

  final List<AppNavItemConfig> items;
  final int selectedIndex;
  final ValueChanged<int> onItemSelected;
  final Widget center;
  final int centerIndex;
  final double barHeight;
  final double barHorizontalPadding;
  final double barBottomGap;
  final double centerGapWidth;
  final Color backgroundColor;
  final Color shadowColor;

  @override
  Widget build(BuildContext context) {
    final chrome = Theme.of(context).extension<ShellChromeTheme>();
    final selected =
        chrome?.navSelectedItem ?? Theme.of(context).colorScheme.primary;
    final unselected =
        chrome?.navUnselectedItem ??
        Theme.of(context).colorScheme.onSurfaceVariant;

    return Padding(
      padding: EdgeInsets.only(bottom: barBottomGap),
      child: Container(
        height: barHeight,
        color: Colors.transparent,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Positioned.fill(
              top: 11,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: barHorizontalPadding),
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: backgroundColor,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: shadowColor,
                        blurRadius: 16,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: _buildNavItems(selected, unselected),
                  ),
                ),
              ),
            ),
            Center(child: center),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildNavItems(Color selected, Color unselected) {
    final widgets = <Widget>[];
    for (final item in items) {
      if (item.index == centerIndex) {
        widgets.add(SizedBox(width: centerGapWidth));
        continue;
      }
      widgets.add(
        Expanded(
          child: _NavButton(
            icon: item.icon,
            label: item.label,
            isSelected: selectedIndex == item.index,
            selectedColor: selected,
            unselectedColor: unselected,
            onTap: () => onItemSelected(item.index),
          ),
        ),
      );
    }
    return widgets;
  }
}

class _NavButton extends StatelessWidget {
  const _NavButton({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.selectedColor,
    required this.unselectedColor,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool isSelected;
  final Color selectedColor;
  final Color unselectedColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final itemColor = isSelected ? selectedColor : unselectedColor;

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 2),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: itemColor, size: 22),
            const SizedBox(height: 1),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: isSelected ? 9 : 8,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                color: itemColor,
              ),
            ),
            const SizedBox(height: 4),
            Container(
              height: 2,
              width: 18,
              decoration: BoxDecoration(
                color: isSelected ? selectedColor : Colors.transparent,
                borderRadius: BorderRadius.circular(99),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
