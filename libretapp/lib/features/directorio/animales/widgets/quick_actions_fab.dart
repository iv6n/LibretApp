import 'dart:math';

import 'package:flutter/material.dart';
import 'package:libretapp/l10n/app_localizations.dart';

class QuickActionsFab extends StatelessWidget {
  const QuickActionsFab({
    super.key,
    required this.onAddWeight,
    required this.onAddReproduction,
    required this.onAddProduction,
    required this.onAddHealth,
    required this.onAddCommercial,
    required this.onAddMovement,
    required this.onAddCost,
  });

  final VoidCallback onAddWeight;
  final VoidCallback onAddReproduction;
  final VoidCallback onAddProduction;
  final VoidCallback onAddHealth;
  final VoidCallback onAddCommercial;
  final VoidCallback onAddMovement;
  final VoidCallback onAddCost;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return ExpandableFab(
      distance: 78,
      children: [
        _ActionButton(
          icon: Icons.monitor_weight,
          label: l10n.detailActionWeight,
          onPressed: onAddWeight,
        ),
        _ActionButton(
          icon: Icons.favorite,
          label: l10n.detailActionReproduction,
          onPressed: onAddReproduction,
        ),
        _ActionButton(
          icon: Icons.analytics,
          label: l10n.detailActionProduction,
          onPressed: onAddProduction,
        ),
        _ActionButton(
          icon: Icons.medical_services,
          label: l10n.detailActionHealth,
          onPressed: onAddHealth,
        ),
        _ActionButton(
          icon: Icons.store,
          label: l10n.detailActionCommercial,
          onPressed: onAddCommercial,
        ),
        _ActionButton(
          icon: Icons.route,
          label: l10n.detailActionMovement,
          onPressed: onAddMovement,
        ),
        _ActionButton(
          icon: Icons.payments,
          label: l10n.detailActionCost,
          onPressed: onAddCost,
        ),
      ],
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  final IconData icon;
  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        FloatingActionButton.small(
          heroTag: label,
          onPressed: onPressed,
          child: Icon(icon),
        ),
        const SizedBox(height: 6),
        Text(label, style: const TextStyle(fontSize: 11)),
      ],
    );
  }
}

/// Expandable FAB for multiple quick actions.
class ExpandableFab extends StatefulWidget {
  const ExpandableFab({
    super.key,
    required this.distance,
    required this.children,
  });

  final double distance;
  final List<Widget> children;

  @override
  State<ExpandableFab> createState() => _ExpandableFabState();
}

class _ExpandableFabState extends State<ExpandableFab>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _expandAnimation;
  bool _open = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _expandAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.fastOutSlowIn,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggle() {
    setState(() {
      _open = !_open;
      if (_open) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 56,
      height: 56,
      child: Stack(
        alignment: Alignment.bottomRight,
        clipBehavior: Clip.none,
        children: [
          ..._buildExpandingActionButtons(),
          FloatingActionButton(
            heroTag: 'fab-main',
            onPressed: _toggle,
            child: AnimatedIcon(
              icon: AnimatedIcons.menu_close,
              progress: _controller,
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildExpandingActionButtons() {
    final children = <Widget>[];
    final count = widget.children.length;
    for (var i = 0; i < count; i++) {
      children.add(
        _ExpandingActionButton(
          directionInDegrees: 270 - (i * 90),
          maxDistance: widget.distance,
          progress: _expandAnimation,
          child: widget.children[i],
        ),
      );
    }
    return children;
  }
}

class _ExpandingActionButton extends StatelessWidget {
  const _ExpandingActionButton({
    required this.directionInDegrees,
    required this.maxDistance,
    required this.progress,
    required this.child,
  });

  final double directionInDegrees;
  final double maxDistance;
  final Animation<double> progress;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final angleInRadians = directionInDegrees * (3.1415926 / 180.0);
    return AnimatedBuilder(
      animation: progress,
      builder: (context, child) {
        final offset = Offset(
          maxDistance * progress.value * cos(angleInRadians),
          maxDistance * progress.value * sin(angleInRadians),
        );
        return Positioned(
          right: 4 + offset.dx,
          bottom: 4 + offset.dy,
          child: FadeTransition(opacity: progress, child: child),
        );
      },
      child: child,
    );
  }
}
