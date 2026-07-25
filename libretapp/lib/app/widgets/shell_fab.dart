/// app › widgets › shell_fab — configuration for the shared FAB rendered by the app shell.
library;

import 'package:flutter/material.dart';

/// Optional compact icon FAB rendered beside the primary shell FAB.
class ShellFabSecondaryAction {
  const ShellFabSecondaryAction({
    required this.id,
    required this.icon,
    required this.onPressed,
    this.heroTag,
  });

  final String id;
  final IconData icon;
  final VoidCallback onPressed;
  final String? heroTag;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ShellFabSecondaryAction &&
        other.id == id &&
        other.icon == icon &&
        other.heroTag == heroTag;
  }

  @override
  int get hashCode => Object.hash(id, icon, heroTag);
}

/// Configuration for the shared FAB rendered by the app shell.
class ShellFabConfig {
  const ShellFabConfig({
    required this.id,
    required this.label,
    required this.icon,
    required this.onPressed,
    this.heroTag,
    this.secondary,
  });

  final String id;
  final String label;
  final IconData icon;
  final VoidCallback onPressed;
  final String? heroTag;
  final ShellFabSecondaryAction? secondary;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ShellFabConfig &&
        other.id == id &&
        other.label == label &&
        other.icon == icon &&
        other.heroTag == heroTag &&
        other.secondary == secondary;
  }

  @override
  int get hashCode => Object.hash(id, label, icon, heroTag, secondary);
}

/// Contract that allows feature pages to publish FAB configs to the shell.
abstract class ShellFabHostState<T extends StatefulWidget> extends State<T> {
  int get activeBranchIndex;
  void updateFab(ShellFabConfig? config, {required int branchIndex});
  void removeFab(ShellFabConfig? config, {required int branchIndex});
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
  int? _branchIndex;
  int _notificationGeneration = 0;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final nextHost = context.findAncestorStateOfType<ShellFabHostState>();
    if (!identical(_host, nextHost) || _branchIndex == null) {
      _branchIndex = nextHost?.activeBranchIndex;
    }
    _host = nextHost;
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
    _notificationGeneration++;
    final host = _host;
    final branchIndex = _branchIndex;
    final config = widget.config;
    if (host != null && branchIndex != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        host.removeFab(config, branchIndex: branchIndex);
      });
    }
    super.dispose();
  }

  void _notifyHost() {
    final host = _host;
    final branchIndex = _branchIndex;
    if (host == null || branchIndex == null) return;
    final generation = ++_notificationGeneration;
    final config = widget.config;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || generation != _notificationGeneration) return;
      host.updateFab(config, branchIndex: branchIndex);
    });
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
