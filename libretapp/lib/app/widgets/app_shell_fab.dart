/// app › widgets › app_shell_fab — floating action button rendered by the app shell.
library;

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

  static const double _fabHeight = 40;

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

    final secondary = fabConfig.secondary;

    return Padding(
      key: ValueKey('fab_${fabConfig.id}'),
      padding: EdgeInsets.only(bottom: dockPadding),
      child: SizedBox(
        width: screenWidth,
        height: _fabHeight,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Align(
              alignment: Alignment.center,
              child: ConstrainedBox(
                constraints: BoxConstraints(minWidth: minFabWidth),
                child: SizedBox(
                  height: _fabHeight,
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
            ),
            if (secondary != null)
              Positioned(
                right: 32,
                top: 0,
                bottom: 0,
                child: Center(
                  child: SizedBox(
                    height: _fabHeight,
                    width: _fabHeight,
                    child: FloatingActionButton.small(
                      heroTag: secondary.heroTag ?? 'shell_fab_secondary',
                      elevation: 2,
                      onPressed: secondary.onPressed,
                      child: Icon(secondary.icon),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
