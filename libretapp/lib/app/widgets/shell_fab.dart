import 'package:flutter/material.dart';

/// Configuration for the shared FAB rendered by the app shell.
class ShellFabConfig {
  const ShellFabConfig({
    required this.id,
    required this.label,
    required this.icon,
    required this.onPressed,
    this.heroTag,
  });

  final String id;
  final String label;
  final IconData icon;
  final VoidCallback onPressed;
  final String? heroTag;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ShellFabConfig &&
        other.id == id &&
        other.label == label &&
        other.icon == icon &&
        other.heroTag == heroTag;
  }

  @override
  int get hashCode => Object.hash(id, label, icon, heroTag);
}

/// Contract that allows feature pages to publish FAB configs to the shell.
abstract class ShellFabHostState<T extends StatefulWidget> extends State<T> {
  void updateFab(ShellFabConfig? config);
  void removeFab(ShellFabConfig? config);
}

/// Allows pages to publish a [ShellFabConfig] to the shell.
class ShellFabConfigScope extends StatefulWidget {
  const ShellFabConfigScope({required this.child, this.config, super.key});

  final Widget child;
  final ShellFabConfig? config;

  @override
  State<ShellFabConfigScope> createState() => _ShellFabConfigScopeState();
}

class _ShellFabConfigScopeState extends State<ShellFabConfigScope> {
  ShellFabHostState? _host;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _host = context.findAncestorStateOfType<ShellFabHostState>();
    _notifyHost();
  }

  @override
  void didUpdateWidget(covariant ShellFabConfigScope oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.config != oldWidget.config) {
      _notifyHost();
    }
  }

  @override
  void dispose() {
    _host?.removeFab(widget.config);
    super.dispose();
  }

  void _notifyHost() {
    if (_host == null) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _host?.updateFab(widget.config);
    });
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
