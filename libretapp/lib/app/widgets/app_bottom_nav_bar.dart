import 'package:flutter/material.dart';

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
    this.backgroundColor = Colors.white,
    this.shadowColor = const Color(0x24000000),
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
    final accent = Theme.of(context).colorScheme.primary;

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
                    children: _buildNavItems(accent),
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

  List<Widget> _buildNavItems(Color accent) {
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
            accent: accent,
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
    required this.accent,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool isSelected;
  final Color accent;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final iconColor = isSelected ? accent : Colors.grey.shade400;
    final textColor = isSelected ? accent : Colors.grey.shade500;

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 2),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: iconColor, size: 22),
            const SizedBox(height: 1),
            Text(
              label,
              key: ValueKey(isSelected),
              style: TextStyle(
                fontSize: isSelected ? 9 : 8,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                color: textColor,
              ),
            ),
            const SizedBox(height: 4),
            Container(
              height: 2,
              width: 18,
              decoration: BoxDecoration(
                color: isSelected ? accent : Colors.transparent,
                borderRadius: BorderRadius.circular(99),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
