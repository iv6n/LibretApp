import 'dart:math' show max;

import 'package:flutter/material.dart';
import 'package:libretapp/app/widgets/widgets.dart';
import 'package:libretapp/features/animales/domain/animal_domain.dart';
import 'package:libretapp/features/animales/widgets/detail_helpers.dart';
import 'package:libretapp/l10n/app_localizations.dart';

class HistoryTab extends StatelessWidget {
  const HistoryTab({super.key, required this.animal});

  final AnimalEntity animal;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final bottomInset = ShellInsets.bottomSafePadding(context);
    final fabBottomPadding = ShellInsets.fabDockPadding(context);
    // Use the larger of content inset and FAB dock to keep items clear.
    final contentPadding = EdgeInsets.fromLTRB(
      14,
      14,
      14,
      max(bottomInset + 2, fabBottomPadding + 8),
    );
    return ListView(
      key: const PageStorageKey('history_list'),
      padding: contentPadding,
      children: [
        HistoryItem(
          icon: Icons.badge,
          label: l10n.detailCreated,
          value: formatDate(animal.creationDate, withTime: true),
        ),
        HistoryItem(
          icon: Icons.update,
          label: l10n.detailUpdated,
          value: formatDate(animal.lastUpdateDate, withTime: true),
        ),
        HistoryItem(
          icon: Icons.agriculture,
          label: l10n.detailLastMovement,
          value: formatDate(animal.lastMovementDate, withTime: true),
        ),
        HistoryItem(
          icon: Icons.health_and_safety,
          label: l10n.detailHealth,
          value: animal.healthStatus.displayName,
        ),
        HistoryItem(
          icon: Icons.warning,
          label: l10n.detailRisk,
          value: animal.riskLevel.displayName,
        ),
        HistoryItem(
          icon: Icons.vaccines,
          label: l10n.detailVaccinated,
          value: animal.vaccinated ? l10n.booleanYes : l10n.booleanNo,
        ),
        HistoryItem(
          icon: Icons.verified_user,
          label: l10n.detailSynced,
          value: l10n.detailSyncedValue(animal.synced ? 'true' : 'false'),
        ),
      ],
    );
  }
}

class HistoryItem extends StatelessWidget {
  const HistoryItem({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Icon(icon, color: Theme.of(context).colorScheme.primary),
        title: Text(label, style: const TextStyle(fontWeight: FontWeight.w700)),
        subtitle: Text(value),
      ),
    );
  }
}
