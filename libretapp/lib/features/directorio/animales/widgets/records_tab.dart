/// features \u203a directorio \u203a animales \u203a widgets \u203a records_tab \u2014 records tab on the animal detail page.
library;

import '../domain/repositories/weaning_record_repository.dart';

import 'dart:math';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:libretapp/app/widgets/widgets.dart';
import 'package:libretapp/core/assets/app_asset_paths.dart';
import 'package:libretapp/core/di/injection.dart';
import 'package:libretapp/core/router/app_routes.dart';
import 'package:libretapp/core/services/logger_service.dart';
import 'package:libretapp/core/widgets/widgets.dart';
import 'package:libretapp/features/agenda/data/agenda_reminder_sync_service.dart';
import 'package:libretapp/features/directorio/animales/domain/animal_domain.dart';
import 'package:libretapp/features/directorio/animales/domain/repositories/commercial_record_repository.dart';
import 'package:libretapp/features/directorio/animales/domain/repositories/cost_record_repository.dart';
import 'package:libretapp/features/directorio/animales/domain/repositories/health_record_repository.dart';
import 'package:libretapp/features/directorio/animales/domain/repositories/movement_record_repository.dart';
import 'package:libretapp/features/directorio/animales/domain/repositories/production_record_repository.dart';
import 'package:libretapp/features/directorio/animales/domain/repositories/reproduction_record_repository.dart';
import 'package:libretapp/features/directorio/animales/domain/repositories/weight_record_repository.dart';
import 'package:libretapp/features/directorio/animales/widgets/animal_record_assets.dart';
import 'package:libretapp/features/directorio/animales/widgets/detail_helpers.dart';
import 'package:libretapp/features/directorio/animales/widgets/movement_location_names.dart';
import 'package:libretapp/l10n/app_localizations.dart';
import 'package:libretapp/theme/app_theme.dart';

class RecordsTab extends StatelessWidget {
  const RecordsTab({super.key, required this.data, required this.onChanged});

  final DetailData data;
  final VoidCallback onChanged;

  String _movementSubtitle(MovementRecord record, AppLocalizations l10n) {
    String locationLabel(String reference) =>
        movementLocationName(reference, data.movementLocationNames) ??
        l10n.valueNoData;
    final origin = record.fromLocation;
    final destination = record.clearsLocation
        ? l10n.animalFormNoLocation
        : locationLabel(record.toLocation);
    return [
      if (origin != null && origin.trim().isNotEmpty)
        '${l10n.detailRecordsFrom} ${locationLabel(origin)}',
      '${l10n.detailRecordsTo} $destination',
      if (record.notes != null) record.notes!,
    ].where((text) => text.isNotEmpty).join(' · ');
  }

  Future<void> _edit(
    BuildContext context, {
    required String routeName,
    required String recordId,
  }) async {
    final saved = await context.pushNamed<bool>(
      routeName,
      pathParameters: {'uuid': data.animal.uuid},
      queryParameters: {'recordId': recordId},
    );
    if (saved == true && context.mounted) onChanged();
  }

  Future<void> _deleteWithUndo(
    BuildContext context, {
    required Future<void> Function() delete,
    required Future<void> Function() restore,
    Future<void> Function()? afterDelete,
    Future<void> Function()? afterRestore,
  }) async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      useRootNavigator: true,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.recordDeleteTitle),
        content: Text(l10n.recordDeleteConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text(l10n.actionCancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: Text(l10n.actionDelete),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;

    try {
      await delete();
    } catch (error, stackTrace) {
      LoggerService.e(
        'No se pudo eliminar el registro: $error',
        tag: 'RecordsTab',
        stackTrace: stackTrace,
      );
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(l10n.errorGenericSave)));
      }
      return;
    }

    var derivedSyncFailed = false;
    if (afterDelete != null) {
      try {
        await afterDelete();
      } catch (error, stackTrace) {
        derivedSyncFailed = true;
        LoggerService.e(
          'Registro eliminado; la proyección derivada requiere sincronización: $error',
          tag: 'RecordsTab',
          stackTrace: stackTrace,
        );
      }
    }
    if (!context.mounted) return;
    onChanged();
    final messenger = ScaffoldMessenger.of(context);
    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(
      SnackBar(
        duration: const Duration(seconds: 6),
        content: Text(
          derivedSyncFailed
              ? l10n.recordDeletedSyncWarning
              : l10n.recordDeleted,
        ),
        action: SnackBarAction(
          label: l10n.actionUndo,
          onPressed: () {
            _restore(context, restore: restore, afterRestore: afterRestore);
          },
        ),
      ),
    );
  }

  Future<void> _restore(
    BuildContext context, {
    required Future<void> Function() restore,
    Future<void> Function()? afterRestore,
  }) async {
    final l10n = AppLocalizations.of(context);
    try {
      await restore();
    } catch (error, stackTrace) {
      LoggerService.e(
        'No se pudo restaurar el registro: $error',
        tag: 'RecordsTab',
        stackTrace: stackTrace,
      );
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(l10n.errorGenericSave)));
      }
      return;
    }

    var derivedSyncFailed = false;
    if (afterRestore != null) {
      try {
        await afterRestore();
      } catch (error, stackTrace) {
        derivedSyncFailed = true;
        LoggerService.e(
          'Registro restaurado; la proyección derivada requiere '
          'sincronización: $error',
          tag: 'RecordsTab',
          stackTrace: stackTrace,
        );
      }
    }
    if (!context.mounted) return;
    onChanged();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          derivedSyncFailed
              ? l10n.recordRestoredSyncWarning
              : l10n.recordDeleteUndone,
        ),
      ),
    );
  }

  Future<void> _syncAgenda() async {
    await locator<AgendaReminderSyncService>().sync();
  }

  Future<void> _deleteHealthProjection(HealthRecord record) async {
    await locator<HealthCareCycleService>().remove(data.animal.uuid, record);
    await _syncAgenda();
  }

  Future<void> _restoreHealthProjection(HealthRecord record) async {
    await locator<HealthCareCycleService>().upsert(
      animal: data.animal,
      record: record,
    );
    await _syncAgenda();
  }

  VoidCallback? _editAction(
    BuildContext context,
    String? recordId,
    String routeName,
  ) {
    if (recordId == null) return null;
    return () => _edit(context, routeName: routeName, recordId: recordId);
  }

  VoidCallback? _deleteAction(
    BuildContext context,
    String? recordId, {
    required Future<void> Function() delete,
    required Future<void> Function() restore,
    Future<void> Function()? afterDelete,
    Future<void> Function()? afterRestore,
  }) {
    if (recordId == null) return null;
    return () => _deleteWithUndo(
      context,
      delete: delete,
      restore: restore,
      afterDelete: afterDelete,
      afterRestore: afterRestore,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final bottomInset = ShellInsets.bottomSafePadding(context);
    final fabBottomPadding = ShellInsets.fabDockPadding(context);
    // Use the larger of content inset and FAB dock to keep items clear.
    final listBottomPadding = max(bottomInset + 2, fabBottomPadding + 8);

    final hasAnyRecords =
        data.weights.isNotEmpty ||
        data.productions.isNotEmpty ||
        data.milkingRecords.isNotEmpty ||
        data.health.isNotEmpty ||
        data.reproductions.isNotEmpty ||
        data.commercial.isNotEmpty ||
        data.movements.isNotEmpty ||
        data.costs.isNotEmpty;

    if (!hasAnyRecords) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.note_add_outlined,
                size: 64,
                color: Theme.of(
                  context,
                ).colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
              ),
              const SizedBox(height: 16),
              Text(
                l10n.detailNoRecordsYet,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                l10n.detailNoRecordsHint,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return SingleChildScrollView(
      key: const PageStorageKey('records_scroll'),
      padding: EdgeInsets.fromLTRB(16, 14, 16, listBottomPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          RecordSection(
            icon: Icons.monitor_weight,
            assetPath: AppAssetPaths.healthWeight,
            title: l10n.detailRecordsWeights,
            children: data.weights
                .map(
                  (r) => RecordTile(
                    assetPath: AppAssetPaths.healthWeight,
                    fallbackIcon: Icons.monitor_weight_outlined,
                    title:
                        '${fmtDate(r.date)} · ${r.weight.toStringAsFixed(1)} kg',
                    subtitle:
                        r.notes ??
                        (r.method == WeightMethod.scale
                            ? l10n.detailFormWeightMethodScale
                            : l10n.detailFormWeightMethodEstimated),
                    onEdit: _editAction(
                      context,
                      r.id,
                      AppRoutes.nameAnimalRegistroPeso,
                    ),
                    onDelete: _deleteAction(
                      context,
                      r.id,
                      delete: () => locator<WeightRecordRepository>()
                          .deleteWeightRecord(r.id!),
                      restore: () async {
                        await locator<WeightRecordRepository>().addWeightRecord(
                          data.animal.uuid,
                          r,
                        );
                      },
                    ),
                  ),
                )
                .toList(),
          ),
          RecordSection(
            icon: Icons.analytics,
            title: l10n.detailRecordsProduction,
            children: data.productions
                .map(
                  (r) => RecordTile(
                    assetPath: assetForProductionRecordType(r.type),
                    fallbackIcon: fallbackIconForProductionRecordType(r.type),
                    title: '${fmtDate(r.date)} · ${r.type.displayName}',
                    subtitle: [
                      if (r.value != null)
                        '${l10n.detailRecordsValue}: ${r.value} ${r.unit ?? ''}',
                      if (r.score != null)
                        '${l10n.detailRecordsScore}: ${r.score}',
                      if (r.notes != null) r.notes!,
                    ].where((e) => e.isNotEmpty).join(' · '),
                    onEdit: _editAction(
                      context,
                      r.id,
                      AppRoutes.nameAnimalRegistroProduccion,
                    ),
                    onDelete: _deleteAction(
                      context,
                      r.id,
                      delete: () => locator<ProductionRecordRepository>()
                          .deleteProductionRecord(r.id!),
                      restore: () async {
                        await locator<ProductionRecordRepository>()
                            .addProductionRecord(data.animal.uuid, r);
                      },
                    ),
                  ),
                )
                .toList(),
          ),
          RecordSection(
            icon: Icons.water_drop,
            assetPath: AppAssetPaths.healthMilkProduction,
            title: 'Ordeñas',
            children: data.milkingRecords
                .map(
                  (record) => RecordTile(
                    assetPath: AppAssetPaths.healthMilkProduction,
                    fallbackIcon: Icons.water_drop_outlined,
                    title:
                        '${fmtDate(record.session.occurredAt)} · '
                        '${record.entry.liters.toStringAsFixed(2)} L',
                    subtitle: [
                      record.session.shift.label,
                      if (record.session.notes != null) record.session.notes!,
                    ].join(' · '),
                  ),
                )
                .toList(),
          ),
          RecordSection(
            icon: Icons.medical_services,
            assetPath: AppAssetPaths.healthVaccine,
            title: l10n.detailRecordsHealth,
            children: data.health
                .map(
                  (r) => RecordTile(
                    assetPath: assetForHealthRecordType(r.type),
                    fallbackIcon: fallbackIconForHealthRecordType(r.type),
                    title: '${fmtDate(r.date)} · ${r.type.displayName}',
                    subtitle: [
                      r.product,
                      if (r.dose != null) '${l10n.detailRecordsDose} ${r.dose}',
                      if (r.appliedBy != null) r.appliedBy!,
                      if (r.cause != null)
                        '${l10n.detailRecordsCause}: ${r.cause}',
                    ].where((e) => e.isNotEmpty).join(' · '),
                    onEdit: _editAction(
                      context,
                      r.id,
                      AppRoutes.nameAnimalRegistroSalud,
                    ),
                    onDelete: _deleteAction(
                      context,
                      r.id,
                      delete: () => locator<HealthRecordRepository>()
                          .deleteHealthRecord(r.id!),
                      restore: () async {
                        await locator<HealthRecordRepository>().addHealthRecord(
                          data.animal.uuid,
                          r,
                        );
                      },
                      afterDelete: () => _deleteHealthProjection(r),
                      afterRestore: () => _restoreHealthProjection(r),
                    ),
                  ),
                )
                .toList(),
          ),
          RecordSection(
            icon: Icons.favorite,
            assetPath: AppAssetPaths.healthReproduction,
            title: l10n.detailRecordsReproduction,
            children: data.reproductions
                .map(
                  (r) => RecordTile(
                    assetPath: r.hasCalved
                        ? AppAssetPaths.healthBirth
                        : AppAssetPaths.healthReproduction,
                    fallbackIcon: Icons.favorite_outline,
                    title:
                        '${fmtDate(r.eventDate)} · ${r.serviceType?.displayName ?? 'Parto sin servicio conocido'}',
                    subtitle: [
                      if (r.maleSireIdentifier != null)
                        'Padre: ${r.maleSireIdentifier}',
                      if (r.pregnancyResult != null &&
                          r.pregnancyResult != PregnancyCheckResult.notChecked)
                        'Preñez: ${r.pregnancyResult!.displayName}',
                      if (r.expectedCalvingDate != null)
                        'Parto esperado: ${fmtDate(r.expectedCalvingDate!)}',
                      if (r.actualCalvingDate != null)
                        'Parto real: ${fmtDate(r.actualCalvingDate!)}',
                      if (r.calvingOutcome != null)
                        r.calvingOutcome!.displayName,
                      if (r.calvingEase != null)
                        'Dificultad: ${r.calvingEase}/5',
                      if (r.offspringUuids.isNotEmpty)
                        '${r.offspringUuids.length} '
                            '${r.offspringUuids.length == 1 ? 'cría' : 'crías'}',
                      if (r.calvingNotes != null) r.calvingNotes!,
                      if (r.notes != null) r.notes!,
                    ].where((e) => e.isNotEmpty).join(' · '),
                    onEdit: _editAction(
                      context,
                      r.id,
                      AppRoutes.nameAnimalRegistroReproduccion,
                    ),
                    onDelete: _deleteAction(
                      context,
                      r.id,
                      delete: () => locator<ReproductionRecordRepository>()
                          .deleteReproductionRecord(r.id!),
                      restore: () async {
                        await locator<ReproductionRecordRepository>()
                            .addReproductionRecord(data.animal.uuid, r);
                      },
                    ),
                  ),
                )
                .toList(),
          ),
          RecordSection(
            icon: Icons.child_friendly_outlined,
            title: 'Destetes',
            children: data.weanings.map((r) => RecordTile(
              title: fmtDate(r.date),
              subtitle: [if (r.weightKg != null) '${r.weightKg} kg · ${r.weightMethod == WeightMethod.scale ? 'Báscula' : 'Estimado'}', if (r.performedBy != null) r.performedBy!, if (r.notes != null) r.notes!].join(' · '),
              onEdit: _editAction(context, r.id, AppRoutes.nameAnimalRegistroDestete),
              onDelete: _deleteAction(context, r.id,
                delete: () => locator<WeaningRecordRepository>().deleteWeaningRecord(r.id!),
                restore: () async { await locator<WeaningRecordRepository>().save(r); }),
            )).toList(),
          ),
          RecordSection(
            icon: Icons.store,
            title: l10n.detailRecordsCommercial,
            children: data.commercial
                .map(
                  (r) => RecordTile(
                    title: '${fmtDate(r.date)} · ${r.type.displayName}',
                    subtitle: [
                      if (r.amount != null)
                        '${l10n.detailRecordsAmount}: ${r.amount} ${r.currency ?? ''}',
                      if (r.counterparty != null) r.counterparty!,
                      if (r.notes != null) r.notes!,
                    ].where((e) => e.isNotEmpty).join(' · '),
                    onEdit: _editAction(
                      context,
                      r.id,
                      AppRoutes.nameAnimalRegistroComercial,
                    ),
                    onDelete: _deleteAction(
                      context,
                      r.id,
                      delete: () => locator<CommercialRecordRepository>()
                          .deleteCommercialRecord(r.id!),
                      restore: () async {
                        await locator<CommercialRecordRepository>()
                            .addCommercialRecord(data.animal.uuid, r);
                      },
                    ),
                  ),
                )
                .toList(),
          ),
          RecordSection(
            icon: Icons.route,
            title: l10n.detailRecordsMovements,
            children: data.movements
                .map(
                  (r) => RecordTile(
                    title: '${fmtDate(r.date)} · ${r.reason.displayName}',
                    subtitle: _movementSubtitle(r, l10n),
                    onEdit: _editAction(
                      context,
                      r.id,
                      AppRoutes.nameAnimalRegistroMovimiento,
                    ),
                    onDelete: _deleteAction(
                      context,
                      r.id,
                      delete: () => locator<MovementRecordRepository>()
                          .deleteMovementRecord(r.id!),
                      restore: () async {
                        await locator<MovementRecordRepository>()
                            .addMovementRecord(data.animal.uuid, r);
                      },
                    ),
                  ),
                )
                .toList(),
          ),
          RecordSection(
            icon: Icons.payments,
            title: l10n.detailRecordsCosts,
            children: data.costs
                .map(
                  (r) => RecordTile(
                    title: '${fmtDate(r.date)} · ${r.type.displayName}',
                    subtitle:
                        '${l10n.detailRecordsAmount}: ${r.amount} ${r.currency ?? ''}${r.notes != null ? ' · ${r.notes}' : ''}',
                    onEdit: _editAction(
                      context,
                      r.id,
                      AppRoutes.nameAnimalRegistroCosto,
                    ),
                    onDelete: _deleteAction(
                      context,
                      r.id,
                      delete: () => locator<CostRecordRepository>()
                          .deleteCostRecord(r.id!),
                      restore: () async {
                        await locator<CostRecordRepository>().addCostRecord(
                          data.animal.uuid,
                          r,
                        );
                      },
                    ),
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }
}

class RecordSection extends StatelessWidget {
  const RecordSection({
    super.key,
    required this.icon,
    required this.title,
    required this.children,
    this.assetPath,
    this.fallbackIcon = Icons.description_outlined,
  });

  final IconData icon;
  final String title;
  final List<Widget> children;
  final String? assetPath;
  final IconData fallbackIcon;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    if (children.isEmpty) return const SizedBox.shrink();
    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: colorScheme.outline.withValues(alpha: 0.35)),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: colorScheme.primary,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: assetPath == null
                      ? Icon(icon, color: colorScheme.onPrimary, size: 20)
                      : GeneratedAssetIcon(
                          assetPath: assetPath!,
                          fallbackIcon: fallbackIcon,
                          size: 24,
                        ),
                ),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: colorScheme.onSurface,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            for (var index = 0; index < children.length; index++) ...[
              children[index],
              if (index != children.length - 1)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Divider(
                    height: 1,
                    color: Theme.of(
                      context,
                    ).dividerColor.withValues(alpha: 0.7),
                  ),
                ),
            ],
          ],
        ),
      ),
    );
  }
}

class RecordTile extends StatelessWidget {
  const RecordTile({
    super.key,
    required this.title,
    this.subtitle,
    this.assetPath,
    this.fallbackIcon = Icons.description_outlined,
    this.onEdit,
    this.onDelete,
  });

  final String title;
  final String? subtitle;
  final String? assetPath;
  final IconData fallbackIcon;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    return ListTile(
      onTap: onEdit,
      dense: true,
      contentPadding: EdgeInsets.zero,
      leading: assetPath == null
          ? null
          : GeneratedAssetIcon(
              assetPath: assetPath!,
              fallbackIcon: fallbackIcon,
              size: 32,
            ),
      title: Text(
        title,
        style: textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.w700,
          color: colorScheme.onSurface,
        ),
      ),
      subtitle: subtitle != null && subtitle!.isNotEmpty
          ? Text(
              subtitle!,
              style: textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
                height: 1.35,
              ),
            )
          : null,
      trailing: onEdit == null && onDelete == null
          ? null
          : PopupMenuButton<_RecordAction>(
              tooltip: MaterialLocalizations.of(context).moreButtonTooltip,
              onSelected: (action) {
                switch (action) {
                  case _RecordAction.edit:
                    onEdit?.call();
                  case _RecordAction.delete:
                    onDelete?.call();
                }
              },
              itemBuilder: (context) => [
                if (onEdit != null)
                  PopupMenuItem(
                    value: _RecordAction.edit,
                    child: ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(Icons.edit_outlined),
                      title: Text(AppLocalizations.of(context).actionEdit),
                    ),
                  ),
                if (onDelete != null)
                  PopupMenuItem(
                    value: _RecordAction.delete,
                    child: ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: Icon(
                        Icons.delete_outline,
                        color: colorScheme.error,
                      ),
                      title: Text(
                        AppLocalizations.of(context).actionDelete,
                        style: TextStyle(color: colorScheme.error),
                      ),
                    ),
                  ),
              ],
            ),
    );
  }
}

enum _RecordAction { edit, delete }
