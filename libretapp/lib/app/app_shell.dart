import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:libretapp/core/router/app_routes.dart';
import 'package:libretapp/l10n/app_localizations.dart';

class AppShell extends StatefulWidget {
  const AppShell({required this.navigationShell, super.key});

  final StatefulNavigationShell navigationShell;

  static double bottomSafePadding(BuildContext context) {
    final state = context.findAncestorStateOfType<_AppShellState>();
    return state?._bodyBottomInset(context) ?? 0;
  }

  static double fabDockPadding(BuildContext context, {double lift = -30}) {
    final state = context.findAncestorStateOfType<_AppShellState>();
    return state?._fabDockPadding(context, lift: lift) ?? 0;
  }

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  static const double _barHeight = 67;

  static const double _barHorizontalPadding = 10;
  static const double _barBottomGap = 10;

  final List<_NavItem> _navItems = const [
    _NavItem(routeName: AppRoutes.nameAnimales, icon: Icons.pets),
    _NavItem(routeName: AppRoutes.nameEventos, icon: Icons.calendar_today),
    _NavItem(routeName: AppRoutes.nameInicio, icon: Icons.home),
    _NavItem(routeName: AppRoutes.nameUbicaciones, icon: Icons.location_on),
    _NavItem(routeName: AppRoutes.namePerfil, icon: Icons.person),
  ];

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final selectedIndex = widget.navigationShell.currentIndex;
    final accent = Theme.of(context).colorScheme.primary;
    const navBackground = Color.fromARGB(255, 27, 29, 34);
    const surfaceShadow = Color(0x33000000);
    double fabSize = selectedIndex == 2 ? 46 : 39.5;

    return Scaffold(
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
      bottomNavigationBar: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.only(bottom: _barBottomGap),
          child: Container(
            height: _barHeight,
            color: Colors.transparent,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Positioned.fill(
                  top: 11,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: _barHorizontalPadding,
                    ),
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: navBackground,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: const [
                          BoxShadow(
                            color: surfaceShadow,
                            blurRadius: 16,
                            offset: Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            child: _buildNavItem(
                              context,
                              l10n,
                              index: 0,
                              selectedIndex: selectedIndex,
                              icon: _navItems[0].icon,
                              label: _labelForNav(_navItems[0].routeName, l10n),
                            ),
                          ),
                          Expanded(
                            child: _buildNavItem(
                              context,
                              l10n,
                              index: 1,
                              selectedIndex: selectedIndex,
                              icon: _navItems[1].icon,
                              label: _labelForNav(_navItems[1].routeName, l10n),
                            ),
                          ),
                          SizedBox(width: 46 + 10),
                          Expanded(
                            child: _buildNavItem(
                              context,
                              l10n,
                              index: 3,
                              selectedIndex: selectedIndex,
                              icon: _navItems[3].icon,
                              label: _labelForNav(_navItems[3].routeName, l10n),
                            ),
                          ),
                          Expanded(
                            child: _buildNavItem(
                              context,
                              l10n,
                              index: 4,
                              selectedIndex: selectedIndex,
                              icon: _navItems[4].icon,
                              label: _labelForNav(_navItems[4].routeName, l10n),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Center(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: selectedIndex == 2
                        ? MainAxisAlignment.start
                        : MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(height: selectedIndex == 2 ? 0 : 13),
                      SizedBox(
                        width: 46,
                        height: fabSize,
                        child: FloatingActionButton(
                          heroTag: 'home_fab_central',
                          onPressed: () =>
                              _onCentralTap(selectedIndex, context),
                          backgroundColor: selectedIndex == 2
                              ? accent
                              : Colors.grey.shade700,
                          elevation: selectedIndex == 2 ? 4 : 0,
                          shape: selectedIndex == 2
                              ? const RoundedRectangleBorder(
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(15),
                                  ),
                                )
                              : const CircleBorder(),
                          child: Icon(
                            selectedIndex == 2 ? Icons.add : Icons.home,
                            key: ValueKey(selectedIndex == 2),
                            size: selectedIndex == 2 ? 26 : 21,
                            color: Colors.white,
                          ),
                        ),
                      ),

                      Text(
                        selectedIndex == 2 ? "Registrar" : l10n.navHome,
                        key: ValueKey(selectedIndex == 2),
                        style: TextStyle(
                          fontSize: selectedIndex == 2 ? 9.0 : 8.2,
                          fontWeight: selectedIndex == 2
                              ? FontWeight.w700
                              : FontWeight.w600,
                          color: selectedIndex == 2
                              ? accent
                              : Colors.grey.shade500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _onCentralTap(int selectedIndex, BuildContext context) {
    widget.navigationShell.goBranch(2, initialLocation: true);
  }

  double _bodyBottomInset(BuildContext context) {
    final media = MediaQuery.of(context);
    final safeBottom = media.padding.bottom;
    final keyboard = media.viewInsets.bottom;
    // Leave room for the nav bar; if the keyboard is open, prefer that inset so
    // scrollables stay fully visible while the bar remains reachable.
    final inset = _barHeight + _barBottomGap + 2 + safeBottom;
    final effective = keyboard > 0 ? keyboard + _barBottomGap + 4 : inset;
    return effective.clamp(0, 260).toDouble();
  }

  double _fabDockPadding(BuildContext context, {double lift = 0}) {
    final inset = _bodyBottomInset(context);
    // Position FAB just above the bar; positive lift moves it further up.
    return (inset - (_barHeight - 20) + lift).clamp(0, 220).toDouble();
  }

  Widget _buildNavItem(
    BuildContext context,
    AppLocalizations l10n, {
    required int index,
    required int selectedIndex,
    required IconData icon,
    required String label,
  }) {
    final isSelected = selectedIndex == index;
    final accent = Theme.of(context).colorScheme.primary;
    final iconColor = isSelected ? accent : Colors.grey.shade400;
    final textColor = isSelected ? accent : Colors.grey.shade500;

    return InkWell(
      onTap: () => widget.navigationShell.goBranch(
        index,
        initialLocation: index == selectedIndex,
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 2),
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
          ],
        ),
      ),
    );
  }

  String _labelForNav(String routeName, AppLocalizations l10n) {
    switch (routeName) {
      case AppRoutes.nameAnimales:
        return l10n.navAnimals;
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
  final String routeName;
  final IconData icon;

  const _NavItem({required this.routeName, required this.icon});
}
