import 'package:flutter/material.dart';
import 'package:libretapp/theme/app_theme.dart';

import 'shell_fab.dart';

class AppShellFab extends StatelessWidget {
  const AppShellFab({
    super.key,
    required this.config,
    required this.dockPadding,
    required this.backgroundColor,
    this.foregroundColor = Colors.white,
  });

  final ShellFabConfig? config;
  final double dockPadding;
  final Color backgroundColor;
  final Color foregroundColor;

  @override
  Widget build(BuildContext context) {
    final fabConfig = config;
    if (fabConfig == null) {
      return const SizedBox.shrink(key: ValueKey('fab_none'));
    }

    final chrome = Theme.of(context).extension<ShellChromeTheme>();
    final fabBackground = chrome?.fabBackground ?? backgroundColor;
    final fabForeground = chrome?.fabForeground ?? foregroundColor;
    final screenWidth = MediaQuery.sizeOf(context).width;
    final minFabWidth = (screenWidth * 0.40).clamp(106.0, 202.0).toDouble();

    return Padding(
      key: ValueKey('fab_${fabConfig.id}'),
      padding: EdgeInsets.only(bottom: dockPadding),
      child: ConstrainedBox(
        constraints: BoxConstraints(minWidth: minFabWidth),
        child: SizedBox(
          height: 40,
          child: FloatingActionButton.extended(
            heroTag: fabConfig.heroTag ?? 'shell_fab',
            backgroundColor: fabBackground,
            foregroundColor: fabForeground,
            shape: StadiumBorder(
              side: BorderSide(
                color: fabForeground.withValues(alpha: 0.12),
                width: 1,
              ),
            ),
            elevation: 1,
            onPressed: fabConfig.onPressed,
            extendedPadding: const EdgeInsets.symmetric(horizontal: 10),
            icon: Icon(fabConfig.icon, size: 20),
            label: Text(
              fabConfig.label,
              style: const TextStyle(
                fontWeight: FontWeight.w700,
                letterSpacing: 0.15,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
