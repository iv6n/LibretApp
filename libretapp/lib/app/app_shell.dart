/// app › app_shell — persistent shell scaffold with bottom navigation bar.
///
/// Hosts the five main tabs via [StatefulShellRoute.indexedStack].
library;

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:go_router/go_router.dart';
import 'package:libretapp/app/widgets/widgets.dart';
import 'package:libretapp/core/router/app_routes.dart';
import 'package:libretapp/l10n/app_localizations.dart';
import 'package:libretapp/theme/app_theme.dart';

class AppShell extends StatefulWidget {
  const AppShell({required this.navigationShell, super.key});

  final StatefulNavigationShell navigationShell;

  static double bottomSafePadding(BuildContext context) =>
      ShellInsets.bottomSafePadding(context);

  static double fabDockPadding(BuildContext context, {double lift = -30}) =>
      ShellInsets.fabDockPadding(context, lift: lift);

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell>
    implements ShellFabHostState<AppShell>, ShellChromeHostState<AppShell> {
  static const double _barHeight = ShellInsets.defaultBarHeight;
  static const double _barHorizontalPadding = 10;
  static const double _barBottomGap = ShellInsets.defaultBarBottomGap;

  static const bool _fabLogEnabled = true;
  int _fabVersion = 0;
  final Map<int, ShellFabConfig> _fabCache = <int, ShellFabConfig>{};
  final Map<int, bool> _chromeCache = <int, bool>{};

  final List<_NavItem> _navItems = const [
    _NavItem(routeName: AppRoutes.nameDirectorio, icon: Icons.folder),
    _NavItem(routeName: AppRoutes.nameEventos, icon: Icons.calendar_today),
    _NavItem(routeName: AppRoutes.nameInicio, icon: Icons.home),
    _NavItem(routeName: AppRoutes.nameUbicaciones, icon: Icons.location_on),
    _NavItem(routeName: AppRoutes.namePerfil, icon: Icons.person),
  ];

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final selectedIndex = widget.navigationShell.currentIndex;
    final routePath = GoRouterState.of(context).uri.path;
    final chromeVisible =
        !_isOverlayRoute(routePath) && _chromeForIndex(selectedIndex);
    final fabConfig = _fabForIndex(selectedIndex);
    final accent = Theme.of(context).colorScheme.primary;
    final shellTheme = Theme.of(context).extension<ShellChromeTheme>();

    final navItems = List<AppNavItemConfig>.generate(
      _navItems.length,
      (index) => AppNavItemConfig(
        index: index,
        icon: _navItems[index].icon,
        label: _labelForNav(_navItems[index].routeName, l10n),
      ),
    );

    final isHomeSelected = selectedIndex == 2;

    return ShellChromeVisibility(
      visible: chromeVisible,
      child: Scaffold(
        extendBody: true,
        body: Stack(
          children: [
            Positioned.fill(child: widget.navigationShell),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: IgnorePointer(
                child: SizedBox(height: _bodyBottomInset(context)),
              ),
            ),
          ],
        ),
        bottomNavigationBar: chromeVisible
            ? SafeArea(
                top: false,
                child: AppBottomNavBar(
                  items: navItems,
                  selectedIndex: selectedIndex,
                  onItemSelected: (index) => widget.navigationShell.goBranch(
                    index,
                    initialLocation: index == selectedIndex,
                  ),
                  center: _buildCenterButton(
                    context,
                    isHomeSelected: isHomeSelected,
                    accent: accent,
                  ),
                  barHeight: _barHeight,
                  barHorizontalPadding: _barHorizontalPadding,
                  barBottomGap: _barBottomGap,
                  backgroundColor:
                      shellTheme?.navBackground ?? const Color(0xFF1B1D22),
                  shadowColor: shellTheme?.navShadow ?? const Color(0x33000000),
                ),
              )
            : null,
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        floatingActionButton: chromeVisible
            ? AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                switchInCurve: Curves.easeOut,
                switchOutCurve: Curves.easeIn,
                child: AppShellFab(
                  config: fabConfig,
                  dockPadding: _fabDockPadding(context, lift: -34),
                  backgroundColor: shellTheme?.fabBackground ?? accent,
                  foregroundColor: shellTheme?.fabForeground ?? Colors.white,
                ),
              )
            : null,
      ),
    );
  }

  int get _activeIndex => widget.navigationShell.currentIndex;

  ShellFabConfig? _fabForIndex(int index) {
    if (!_isFabAllowed(index)) return null;
    return _fabCache[index];
  }

  bool _chromeForIndex(int index) {
    return _chromeCache[index] ?? true;
  }

  Widget _buildCenterButton(
    BuildContext context, {
    required bool isHomeSelected,
    required Color accent,
  }) {
    final l10n = AppLocalizations.of(context);
    final surface = Theme.of(context).colorScheme.surface;
    final onSurface = Theme.of(context).colorScheme.onSurface;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: 44,
          height: 44,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: isHomeSelected ? accent : surface,
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                if (isHomeSelected)
                  BoxShadow(
                    color: accent.withValues(alpha: 0.25),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
              ],
            ),
            child: InkWell(
              borderRadius: BorderRadius.circular(14),
              onTap: () => _onCentralTap(context),
              child: Icon(
                isHomeSelected ? Icons.add : Icons.home,
                key: ValueKey(isHomeSelected),
                size: 22,
                color: isHomeSelected
                    ? Colors.white
                    : onSurface.withValues(alpha: 0.8),
              ),
            ),
          ),
        ),
        Text(
          isHomeSelected ? 'Registrar' : l10n.navHome,
          key: ValueKey(isHomeSelected),
          style: TextStyle(
            fontSize: 9.0,
            fontWeight: isHomeSelected ? FontWeight.w700 : FontWeight.w600,
            color: isHomeSelected ? accent : Colors.grey.shade600,
          ),
        ),
      ],
    );
  }

  @override
  void updateFab(ShellFabConfig? config) => _updateFab(config);

  @override
  void removeFab(ShellFabConfig? config) => _removeFab(config);

  @override
  void updateChromeVisibility(bool visible) => _updateChromeVisibility(visible);

  @override
  void removeChromeVisibility(bool visible) {
    final index = _activeIndex;
    final shouldRestore = !visible || !_chromeForIndex(index);
    if (!shouldRestore) return;
    void restore() {
      if (!mounted) return;
      setState(() {
        _chromeCache.remove(index);
      });
    }

    final phase = WidgetsBinding.instance.schedulerPhase;
    final canSetStateNow =
        phase == SchedulerPhase.idle ||
        phase == SchedulerPhase.postFrameCallbacks;
    if (canSetStateNow) {
      restore();
    } else {
      WidgetsBinding.instance.addPostFrameCallback((_) => restore());
    }
  }

  void _updateFab(ShellFabConfig? config) {
    final index = _activeIndex;
    if (!_isFabAllowed(index)) {
      if (_fabCache.containsKey(index)) {
        setState(() {
          _fabVersion++;
          _fabCache.remove(index);
        });
      }
      return;
    }
    final current = _fabCache[index];
    if (current == config) return;
    setState(() {
      _fabVersion++;
      if (config == null) {
        _fabCache.remove(index);
      } else {
        _fabCache[index] = config;
      }
    });
    _logFab('Set FAB v$_fabVersion index=$index id=${config?.id}');
  }

  void _removeFab(ShellFabConfig? config) {
    final targetEntries = <int>[];
    if (config == null) {
      final active = _activeIndex;
      if (_fabCache.containsKey(active)) {
        targetEntries.add(active);
      }
    } else {
      _fabCache.forEach((index, cached) {
        if (cached.id == config.id) {
          targetEntries.add(index);
        }
      });
    }
    if (targetEntries.isEmpty) return;
    if (!mounted) return;
    void removeEntries() {
      if (!mounted) return;
      setState(() {
        _fabVersion++;
        for (final index in targetEntries) {
          _fabCache.remove(index);
        }
      });
    }

    // Defer setState to a safe time if we're in a frame callback.
    final phase = WidgetsBinding.instance.schedulerPhase;
    if (phase == SchedulerPhase.idle ||
        phase == SchedulerPhase.postFrameCallbacks) {
      removeEntries();
    } else {
      WidgetsBinding.instance.addPostFrameCallback((_) => removeEntries());
    }
    _logFab('Removed FAB id=${config?.id} indexes=$targetEntries');
  }

  bool _isFabAllowed(int index) => index != 1 && index != 4;

  /// Returns true for overlay/detail routes where the shell chrome
  /// (bottom nav + FAB) should be hidden immediately — before the
  /// ShellChromeScope post-frame callback fires.
  bool _isOverlayRoute(String path) {
    // Matches any path containing a known overlay segment.
    return path.contains('/animales/') ||
        path.endsWith('/animales/nuevo') ||
        path.endsWith('/lotes/nuevo') ||
        path.contains('/lotes/') ||
        path.endsWith('/ubicaciones/nueva') ||
        path.contains('/ubicaciones/') ||
        path == AppRoutes.registro ||
        path.startsWith('${AppRoutes.registro}/');
  }

  void _updateChromeVisibility(bool visible) {
    final index = _activeIndex;
    final current = _chromeForIndex(index);
    if (current == visible) return;
    setState(() {
      _chromeCache[index] = visible;
    });
  }

  void _onCentralTap(BuildContext context) {
    final isHome = widget.navigationShell.currentIndex == 2;
    if (isHome) {
      context.push(AppRoutes.registro);
    } else {
      widget.navigationShell.goBranch(2, initialLocation: true);
    }
  }

  double _bodyBottomInset(BuildContext context) {
    return ShellInsets.bottomSafePadding(
      context,
      barHeight: _barHeight,
      barBottomGap: _barBottomGap,
    );
  }

  double _fabDockPadding(BuildContext context, {double lift = 0}) {
    return ShellInsets.fabDockPadding(
      context,
      barHeight: _barHeight,
      barBottomGap: _barBottomGap,
      lift: lift,
    );
  }

  void _logFab(String message) {
    if (!_fabLogEnabled) return;
    debugPrint('[FAB] $message');
  }

  String _labelForNav(String routeName, AppLocalizations l10n) {
    switch (routeName) {
      case AppRoutes.nameDirectorio:
        return l10n.navDirectory;
      case AppRoutes.nameEventos:
        return l10n.navEvents;
      case AppRoutes.nameUbicaciones:
        return l10n.navLocations;
      case AppRoutes.namePerfil:
        return l10n.navProfile;
      case AppRoutes.nameInicio:
      default:
        return l10n.navHome;
    }
  }
}

class _NavItem {
  const _NavItem({required this.routeName, required this.icon});

  final String routeName;
  final IconData icon;
}
