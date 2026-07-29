/// app › app_shell — persistent shell scaffold with bottom navigation bar.
///
/// Hosts the five main tabs via [StatefulShellRoute.indexedStack].
library;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:go_router/go_router.dart';
import 'package:libretapp/app/shell_route_policy.dart';
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

  int _fabVersion = 0;
  final Map<int, ShellFabConfig> _fabCache = <int, ShellFabConfig>{};
  final Map<int, bool> _chromeCache = <int, bool>{};
  bool _treeActive = true;

  final List<_NavItem> _navItems = const [
    _NavItem(routeName: AppRoutes.nameDirectorio, icon: Icons.folder),
    _NavItem(routeName: AppRoutes.nameAgenda, icon: Icons.calendar_today),
    _NavItem(routeName: AppRoutes.nameInicio, icon: Icons.home),
    _NavItem(routeName: AppRoutes.nameReportes, icon: Icons.analytics),
    _NavItem(routeName: AppRoutes.namePerfil, icon: Icons.person),
  ];

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final selectedIndex = widget.navigationShell.currentIndex;
    final routeUri = GoRouterState.of(context).uri;
    final chromeVisible =
        !shouldHideShellChrome(routeUri) && _chromeForIndex(selectedIndex);
    final fabConfig = _fabForIndex(selectedIndex);
    final accent = Theme.of(context).colorScheme.tertiary;
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
    final homeFabColor = AppColors.accent;

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
                    accent: isHomeSelected ? homeFabColor : accent,
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

  @override
  int get activeBranchIndex => _activeIndex;

  @override
  void activate() {
    super.activate();
    _treeActive = true;
  }

  @override
  void deactivate() {
    _treeActive = false;
    super.deactivate();
  }

  @override
  void dispose() {
    _treeActive = false;
    super.dispose();
  }

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
    final theme = Theme.of(context);
    final onSurface = theme.colorScheme.onSurface;
    final inactiveBackground = theme.brightness == Brightness.dark
        ? Colors.white.withValues(alpha: 0.10)
        : Colors.grey.shade200;
    final inactiveForeground = onSurface.withValues(alpha: 0.46);
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
              color: isHomeSelected ? accent : inactiveBackground,
              borderRadius: BorderRadius.circular(14),
              border: isHomeSelected
                  ? null
                  : Border.all(color: onSurface.withValues(alpha: 0.10)),
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
                size: 22,
                color: isHomeSelected ? Colors.white : inactiveForeground,
              ),
            ),
          ),
        ),
        Text(
          isHomeSelected ? l10n.navAdd : l10n.navHome,
          style: TextStyle(
            fontSize: 9.0,
            fontWeight: isHomeSelected ? FontWeight.w700 : FontWeight.w600,
            color: isHomeSelected ? accent : inactiveForeground,
          ),
        ),
      ],
    );
  }

  @override
  void updateFab(ShellFabConfig? config, {required int branchIndex}) =>
      _updateFab(config, branchIndex: branchIndex);

  @override
  void removeFab(ShellFabConfig? config, {required int branchIndex}) =>
      _removeFab(config, branchIndex: branchIndex);

  @override
  void updateChromeVisibility(bool visible, {required int branchIndex}) =>
      _updateChromeVisibility(visible, branchIndex: branchIndex);

  @override
  void removeChromeVisibility(bool visible, {required int branchIndex}) {
    if (!_canMutateShell) return;
    final index = branchIndex;
    final shouldRestore = !visible || !_chromeForIndex(index);
    if (!shouldRestore) return;
    void restore() {
      if (!_canMutateShell) return;
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

  void _updateFab(ShellFabConfig? config, {required int branchIndex}) {
    if (!_canMutateShell) return;
    final index = branchIndex;
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

  void _removeFab(ShellFabConfig? config, {required int branchIndex}) {
    if (!_canMutateShell) return;
    final targetEntries = <int>[];
    final cached = _fabCache[branchIndex];
    if (cached != null && (config == null || cached.id == config.id)) {
      targetEntries.add(branchIndex);
    }
    if (targetEntries.isEmpty) return;
    void removeEntries() {
      if (!_canMutateShell) return;
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

  bool _isFabAllowed(int index) => index != 4;

  void _updateChromeVisibility(bool visible, {required int branchIndex}) {
    if (!_canMutateShell) return;
    final index = branchIndex;
    final current = _chromeForIndex(index);
    if (current == visible) return;
    setState(() {
      _chromeCache[index] = visible;
    });
  }

  bool get _canMutateShell => mounted && _treeActive;

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
    if (!kDebugMode) return;
    debugPrint('[FAB] $message');
  }

  String _labelForNav(String routeName, AppLocalizations l10n) {
    switch (routeName) {
      case AppRoutes.nameDirectorio:
        return l10n.navDirectory;
      case AppRoutes.nameAgenda:
        return l10n.navAgenda;
      case AppRoutes.nameReportes:
        return l10n.navReports;
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
