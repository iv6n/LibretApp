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
  int get activeBranchIndex;
  void updateChromeVisibility(bool visible, {required int branchIndex});
  void removeChromeVisibility(bool visible, {required int branchIndex});
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
  int? _branchIndex;
  int _notificationGeneration = 0;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final nextHost = context.findAncestorStateOfType<ShellChromeHostState>();
    if (!identical(_host, nextHost) || _branchIndex == null) {
      _branchIndex = nextHost?.activeBranchIndex;
    }
    _host = nextHost;
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
    _notificationGeneration++;
    final host = _host;
    final branchIndex = _branchIndex;
    final visible = widget.visible;
    if (host != null && branchIndex != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        host.removeChromeVisibility(visible, branchIndex: branchIndex);
      });
    }
    super.dispose();
  }

  void _notifyHost() {
    final host = _host;
    final branchIndex = _branchIndex;
    if (host == null || branchIndex == null) return;
    final generation = ++_notificationGeneration;
    final visible = widget.visible;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || generation != _notificationGeneration) return;
      host.updateChromeVisibility(visible, branchIndex: branchIndex);
    });
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
