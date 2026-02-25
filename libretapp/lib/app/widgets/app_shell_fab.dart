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

    return Padding(
      key: ValueKey('fab_${fabConfig.id}'),
      padding: EdgeInsets.only(bottom: dockPadding),
      child: SizedBox(
        height: 46,
        child: FloatingActionButton.extended(
          heroTag: fabConfig.heroTag ?? 'shell_fab',
          backgroundColor: fabBackground,
          foregroundColor: fabForeground,
          elevation: 1.5,
          onPressed: fabConfig.onPressed,
          extendedPadding: const EdgeInsets.symmetric(horizontal: 18),
          icon: Icon(fabConfig.icon, size: 20),
          label: Text(fabConfig.label),
        ),
      ),
    );
  }
}
