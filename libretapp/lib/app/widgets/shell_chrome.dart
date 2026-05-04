/// app › widgets › shell_chrome — exposes nav-bar / FAB visibility to descendants.
library;

import 'package:flutter/widgets.dart';

/// Exposes shell chrome visibility to descendants (nav bar + FAB).
class ShellChromeVisibility extends InheritedWidget {
  const ShellChromeVisibility({
    super.key,
    required this.visible,
    required super.child,
  });

  final bool visible;

  static ShellChromeVisibility? of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<ShellChromeVisibility>();
  }

  @override
  bool updateShouldNotify(ShellChromeVisibility oldWidget) {
    return oldWidget.visible != visible;
  }
}

/// Contract for shells that can show/hide their chrome (nav bar + FAB).
abstract class ShellChromeHostState<T extends StatefulWidget> extends State<T> {
  void updateChromeVisibility(bool visible);
  void removeChromeVisibility(bool visible);
}

/// Allows pages to request shell chrome visibility changes.
class ShellChromeScope extends StatefulWidget {
  const ShellChromeScope({
    required this.child,
    required this.visible,
    super.key,
  });

  final Widget child;
  final bool visible;

  @override
  State<ShellChromeScope> createState() => _ShellChromeScopeState();
}

class _ShellChromeScopeState extends State<ShellChromeScope> {
  ShellChromeHostState? _host;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _host = context.findAncestorStateOfType<ShellChromeHostState>();
    _notifyHost();
  }

  @override
  void didUpdateWidget(covariant ShellChromeScope oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.visible != oldWidget.visible) {
      _notifyHost();
    }
  }

  @override
  void dispose() {
    _host?.removeChromeVisibility(widget.visible);
    super.dispose();
  }

  void _notifyHost() {
    if (_host == null) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _host?.updateChromeVisibility(widget.visible);
    });
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
