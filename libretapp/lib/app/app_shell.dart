import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:go_router/go_router.dart';
import 'package:libretapp/app/widgets/widgets.dart';
import 'package:libretapp/core/core.dart';
import 'package:libretapp/l10n/app_localizations.dart';
import 'package:libretapp/theme/theme.dart';

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

  ShellFabConfig? _fabConfig;
  int? _fabOwnerIndex;
  int _lastIndex = -1;

  bool _chromeVisible = true;
  int? _chromeOwnerIndex;
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
    _ensureFabResetOnIndexChange(selectedIndex);
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
      visible: _chromeVisible,
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
        bottomNavigationBar: _chromeVisible
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
        floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
        floatingActionButton: _chromeVisible
            ? AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                switchInCurve: Curves.easeOut,
                switchOutCurve: Curves.easeIn,
                child: AppShellFab(
                  config: _fabConfig,
                  dockPadding: _fabDockPadding(context, lift: -40),
                  backgroundColor: shellTheme?.fabBackground ?? accent,
                  foregroundColor: shellTheme?.fabForeground ?? Colors.white,
                ),
              )
            : null,
      ),
    );
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

  void _ensureFabResetOnIndexChange(int index) {
    if (_lastIndex == index) return;
    _logFab('Tab change $_lastIndex -> $index (owner: $_fabOwnerIndex)');
    _lastIndex = index;
    final cached = _fabCache[index];
    final cachedChrome = _chromeCache[index];
    setState(() {
      final allowedFab = _isFabAllowed(index) ? cached : null;
      _fabConfig = allowedFab;
      _fabOwnerIndex = allowedFab == null ? null : index;
      _chromeVisible = cachedChrome ?? true;
      _chromeOwnerIndex = cachedChrome == null ? null : index;
      _fabVersion++;
    });
    _logFab(
      cached == null
          ? 'No cached FAB for tab $index, cleared.'
          : 'Restored cached FAB for tab $index id=${cached.id}',
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
    final shouldRestore = !visible || !_chromeVisible;
    if (!shouldRestore) return;
    void restore() {
      if (!mounted) return;
      setState(() {
        _chromeVisible = true;
        _chromeOwnerIndex = null;
        _chromeCache.remove(_lastIndex);
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
    if (!_isFabAllowed(_lastIndex)) {
      if (_fabConfig != null) {
        setState(() {
          _fabConfig = null;
          _fabOwnerIndex = null;
          _fabCache.remove(_lastIndex);
        });
      }
      return;
    }
    final needsUpdate = config != _fabConfig || _fabOwnerIndex != _lastIndex;
    if (!needsUpdate) return;
    setState(() {
      _fabVersion++;
      _fabConfig = config;
      _fabOwnerIndex = config == null ? null : _lastIndex;
      if (config == null) {
        _fabCache.remove(_lastIndex);
      } else {
        _fabCache[_lastIndex] = config;
      }
    });
    _logFab('Set FAB v$_fabVersion owner=$_fabOwnerIndex id=${config?.id}');
  }

  void _removeFab(ShellFabConfig? config) {
    if (_fabConfig == null) return;
    if (config == null || _fabConfig?.id == config.id) {
      if (!mounted) return;
      // Defer setState to a safe time if we're in a frame callback
      final phase = WidgetsBinding.instance.schedulerPhase;
      if (phase == SchedulerPhase.idle ||
          phase == SchedulerPhase.postFrameCallbacks) {
        setState(() {
          _fabConfig = null;
          _fabOwnerIndex = null;
          _fabCache.remove(_lastIndex);
        });
      } else {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;
          setState(() {
            _fabConfig = null;
            _fabOwnerIndex = null;
            _fabCache.remove(_lastIndex);
          });
        });
      }
      _logFab('Removed FAB id=${config?.id}');
    }
  }

  bool _isFabAllowed(int index) => index != 3 && index != 5;

  void _updateChromeVisibility(bool visible) {
    final needsUpdate =
        _chromeVisible != visible || _chromeOwnerIndex != _lastIndex;
    if (!needsUpdate) return;
    setState(() {
      _chromeVisible = visible;
      _chromeOwnerIndex = _lastIndex;
      _chromeCache[_lastIndex] = visible;
    });
  }

  void _onCentralTap(BuildContext context) {
    widget.navigationShell.goBranch(2, initialLocation: true);
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
