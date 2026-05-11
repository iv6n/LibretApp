/// features \u203a directorio \u203a animales \u203a widgets \u203a quick_actions_fab \u2014 expandable FAB with quick-action buttons.
library;

import 'package:flutter/material.dart';
import 'package:libretapp/l10n/app_localizations.dart';
import 'package:libretapp/theme/app_theme.dart';

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
    this.accentColor,
  });

  final VoidCallback onAddWeight;
  final VoidCallback onAddReproduction;
  final VoidCallback onAddProduction;
  final VoidCallback onAddHealth;
  final VoidCallback onAddCommercial;
  final VoidCallback onAddMovement;
  final VoidCallback onAddCost;
  final Color? accentColor;

  Future<void> _showActionsPage(BuildContext context) async {
    final l10n = AppLocalizations.of(context);
    final actions = [
      _QuickAction(Icons.monitor_weight, l10n.detailActionWeight, onAddWeight),
      _QuickAction(
        Icons.favorite,
        l10n.detailActionReproduction,
        onAddReproduction,
      ),
      _QuickAction(
        Icons.analytics,
        l10n.detailActionProduction,
        onAddProduction,
      ),
      _QuickAction(
        Icons.medical_services,
        l10n.detailActionHealth,
        onAddHealth,
      ),
      _QuickAction(Icons.store, l10n.detailActionCommercial, onAddCommercial),
      _QuickAction(Icons.route, l10n.detailActionMovement, onAddMovement),
      _QuickAction(Icons.payments, l10n.detailActionCost, onAddCost),
    ];

    await Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        fullscreenDialog: true,
        builder: (ctx) => _QuickActionsPage(actions: actions),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final shellChrome = theme.extension<ShellChromeTheme>();
    return FloatingActionButton(
      heroTag: 'fab-main',
      onPressed: () => _showActionsPage(context),
      backgroundColor:
          accentColor ??
          shellChrome?.fabBackground ??
          theme.colorScheme.tertiary,
      foregroundColor:
          shellChrome?.fabForeground ?? theme.colorScheme.onTertiary,
      elevation: 8,
      highlightElevation: 12,
      shape: const CircleBorder(),
      child: const Icon(Icons.add, size: 30),
    );
  }
}

class _QuickAction {
  const _QuickAction(this.icon, this.label, this.onPressed);
  final IconData icon;
  final String label;
  final VoidCallback onPressed;
}

class _QuickActionsPage extends StatelessWidget {
  const _QuickActionsPage({required this.actions});

  final List<_QuickAction> actions;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.detailQuickActionsTitle)),
      body: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final compact = constraints.maxWidth < 380;
              final columns = compact ? 3 : 4;
              return GridView.count(
                crossAxisCount: columns,
                mainAxisSpacing: 12,
                crossAxisSpacing: 8,
                childAspectRatio: compact ? 0.94 : 0.85,
                children: actions
                    .map(
                      (a) => _ActionTile(
                        icon: a.icon,
                        label: a.label,
                        onTap: () {
                          Navigator.of(context).pop();
                          a.onPressed();
                        },
                      ),
                    )
                    .toList(),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _ActionTile extends StatelessWidget {
  const _ActionTile({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: theme.colorScheme.onPrimaryContainer),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: theme.textTheme.labelSmall,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
