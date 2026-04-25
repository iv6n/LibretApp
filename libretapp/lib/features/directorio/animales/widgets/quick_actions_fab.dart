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

  void _showActionsSheet(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
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

    showModalBottomSheet<void>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.onSurfaceVariant.withValues(
                      alpha: 0.4,
                    ),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  l10n.detailQuickActionsTitle,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 16),
                GridView.count(
                  crossAxisCount: 4,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 8,
                  childAspectRatio: 0.85,
                  children: actions
                      .map(
                        (a) => _ActionTile(
                          icon: a.icon,
                          label: a.label,
                          onTap: () {
                            Navigator.pop(ctx);
                            a.onPressed();
                          },
                        ),
                      )
                      .toList(),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      heroTag: 'fab-main',
      onPressed: () => _showActionsSheet(context),
      backgroundColor: accentColor ?? const Color(0xFF6B4CE6),
      foregroundColor: Colors.white,
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
