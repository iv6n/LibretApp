part of '../location_detail_widgets.dart';

// ─── UpcomingTasksCard ────────────────────────────────────────────────────────

class UpcomingTasksCard extends StatelessWidget {
  const UpcomingTasksCard({required this.location, required this.onComplete});

  final LocationEntity location;
  final void Function(String cropUuid, String taskUuid) onComplete;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final now = DateTime.now();

    final allTasks = <({CropRecord crop, CropTask task})>[];
    for (final crop in location.crops) {
      if (crop.status != CropStatus.active) continue;
      for (final task in crop.tasks) {
        if (!task.completed) {
          allTasks.add((crop: crop, task: task));
        }
      }
      if (crop.isOverdueForWatering) {
        allTasks.add((
          crop: crop,
          task: CropTask(
            uuid: 'auto-water-${crop.uuid}',
            type: CropTaskType.water,
            dueDate: crop.nextWateringDate ?? now,
            notes: 'Riego atrasado',
          ),
        ));
      }
      final daysLeft = crop.daysUntilHarvest;
      if (daysLeft != null && daysLeft <= 7 && daysLeft >= 0) {
        allTasks.add((
          crop: crop,
          task: CropTask(
            uuid: 'auto-harvest-${crop.uuid}',
            type: CropTaskType.harvest,
            dueDate: crop.expectedHarvestDate ?? now,
            notes: '$daysLeft días para cosecha',
          ),
        ));
      }
    }

    allTasks.sort((a, b) => a.task.dueDate.compareTo(b.task.dueDate));

    if (allTasks.isEmpty) return const SizedBox.shrink();

    return Card(
      color: theme.colorScheme.tertiaryContainer.withValues(alpha: 0.3),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.pending_actions_outlined,
                  color: theme.colorScheme.tertiary,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Tareas pendientes',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: theme.colorScheme.tertiary,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            ...allTasks.take(8).map((entry) {
              final isOverdue = entry.task.dueDate.isBefore(now);
              final isAuto = entry.task.uuid.startsWith('auto-');
              return Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  children: [
                    if (!isAuto)
                      InkWell(
                        onTap: () =>
                            onComplete(entry.crop.uuid, entry.task.uuid),
                        child: Icon(
                          Icons.check_circle_outline,
                          size: 20,
                          color: theme.colorScheme.primary,
                        ),
                      )
                    else
                      Icon(
                        isOverdue
                            ? Icons.warning_amber_outlined
                            : Icons.info_outline,
                        size: 20,
                        color: isOverdue
                            ? theme.colorScheme.error
                            : theme.colorScheme.tertiary,
                      ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '${entry.task.type.displayName} — ${entry.crop.cropName}',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: isOverdue ? theme.colorScheme.error : null,
                        ),
                      ),
                    ),
                    Text(
                      '${entry.task.dueDate.day}/${entry.task.dueDate.month}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: isOverdue
                            ? theme.colorScheme.error
                            : theme.colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}

// ─── CropsSection ─────────────────────────────────────────────────────────────

class CropsSection extends StatelessWidget {
  const CropsSection({
    required this.location,
    required this.onAddCrop,
    required this.onEditCrop,
    required this.onDeleteCrop,
    required this.onWaterCrop,
    required this.onHarvestCrop,
    required this.onHealthCrop,
    required this.onAddTask,
    required this.onCompleteTask,
  });

  final LocationEntity location;
  final VoidCallback onAddCrop;
  final ValueChanged<CropRecord> onEditCrop;
  final ValueChanged<CropRecord> onDeleteCrop;
  final ValueChanged<CropRecord> onWaterCrop;
  final ValueChanged<CropRecord> onHarvestCrop;
  final ValueChanged<CropRecord> onHealthCrop;
  final ValueChanged<CropRecord> onAddTask;
  final void Function(CropRecord crop, String taskUuid) onCompleteTask;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final activeCrops = location.crops
        .where((c) => c.status == CropStatus.active)
        .toList();
    final pastCrops = location.crops
        .where((c) => c.status != CropStatus.active)
        .toList();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Cultivos (${location.crops.length})',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                FilledButton.icon(
                  onPressed: onAddCrop,
                  icon: const Icon(Icons.add),
                  label: const Text('Nuevo'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (location.crops.isEmpty) const Text('Sin cultivos registrados'),
            if (activeCrops.isNotEmpty) ...[
              Text(
                'Activos',
                style: theme.textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              ...activeCrops.map(
                (crop) => _CropTile(
                  crop: crop,
                  onEdit: () => onEditCrop(crop),
                  onDelete: () => onDeleteCrop(crop),
                  onWater: () => onWaterCrop(crop),
                  onHarvest: () => onHarvestCrop(crop),
                  onHealth: () => onHealthCrop(crop),
                  onAddTask: () => onAddTask(crop),
                  onCompleteTask: (taskUuid) => onCompleteTask(crop, taskUuid),
                ),
              ),
            ],
            if (pastCrops.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(
                'Anteriores',
                style: theme.textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 8),
              ...pastCrops.map(
                (crop) => _CropTile(
                  crop: crop,
                  onEdit: () => onEditCrop(crop),
                  onDelete: () => onDeleteCrop(crop),
                  onWater: null,
                  onHarvest: null,
                  onHealth: null,
                  onAddTask: null,
                  onCompleteTask: null,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ─── CropTile ─────────────────────────────────────────────────────────────────

class _CropTile extends StatelessWidget {
  const _CropTile({
    required this.crop,
    required this.onEdit,
    required this.onDelete,
    required this.onWater,
    required this.onHarvest,
    required this.onHealth,
    required this.onAddTask,
    required this.onCompleteTask,
  });

  final CropRecord crop;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback? onWater;
  final VoidCallback? onHarvest;
  final VoidCallback? onHealth;
  final VoidCallback? onAddTask;
  final ValueChanged<String>? onCompleteTask;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isActive = crop.status == CropStatus.active;
    final overdue = crop.isOverdueForWatering;
    final daysLeft = crop.daysUntilHarvest;
    final pendingTasks = crop.tasks.where((t) => !t.completed).toList();

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(14),
        border: overdue
            ? Border.all(color: theme.colorScheme.error.withValues(alpha: 0.5))
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: isActive
                    ? theme.colorScheme.primary.withValues(alpha: 0.15)
                    : theme.colorScheme.surfaceContainerHighest,
                child: Icon(
                  Icons.eco_outlined,
                  color: isActive
                      ? theme.colorScheme.primary
                      : theme.colorScheme.onSurfaceVariant,
                  size: 20,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      crop.cropName +
                          (crop.variety.isNotEmpty ? ' (${crop.variety})' : ''),
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      '${crop.growthStage.displayName} • ${crop.status.displayName}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              PopupMenuButton<String>(
                onSelected: (value) {
                  switch (value) {
                    case 'edit':
                      onEdit();
                    case 'delete':
                      onDelete();
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(value: 'edit', child: Text('Editar')),
                  const PopupMenuItem(value: 'delete', child: Text('Eliminar')),
                ],
              ),
            ],
          ),

          const SizedBox(height: 10),

          Wrap(
            spacing: 8,
            runSpacing: 6,
            children: [
              _CropInfoChip(
                icon: Icons.calendar_today_outlined,
                label:
                    'Siembra: ${crop.plantingDate.day}/${crop.plantingDate.month}/${crop.plantingDate.year}',
              ),
              if (crop.expectedHarvestDate != null)
                _CropInfoChip(
                  icon: Icons.event_outlined,
                  label: daysLeft != null && daysLeft >= 0
                      ? 'Cosecha en $daysLeft días'
                      : 'Cosecha: ${crop.expectedHarvestDate!.day}/${crop.expectedHarvestDate!.month}',
                  isWarning: daysLeft != null && daysLeft <= 7,
                ),
              if (crop.lastWateredDate != null)
                _CropInfoChip(
                  icon: Icons.water_drop_outlined,
                  label: overdue
                      ? 'Riego atrasado'
                      : 'Regado: ${crop.lastWateredDate!.day}/${crop.lastWateredDate!.month}',
                  isError: overdue,
                ),
              if (crop.lastWateredDate == null && isActive)
                const _CropInfoChip(
                  icon: Icons.water_drop_outlined,
                  label: 'Sin riego registrado',
                  isError: true,
                ),
              if (crop.surface > 0)
                _CropInfoChip(
                  icon: Icons.straighten_outlined,
                  label: '${crop.surface.toStringAsFixed(1)} ha',
                ),
              if (crop.totalYieldKg > 0)
                _CropInfoChip(
                  icon: Icons.scale_outlined,
                  label: '${crop.totalYieldKg.toStringAsFixed(1)} kg cosechado',
                ),
              _CropInfoChip(
                icon: Icons.water_drop,
                label: 'Riegos: ${crop.waterings.length}',
              ),
              if (crop.harvests.isNotEmpty)
                _CropInfoChip(
                  icon: Icons.agriculture_outlined,
                  label: 'Cosechas: ${crop.harvests.length}',
                ),
              if (crop.healthRecords.isNotEmpty)
                _CropInfoChip(
                  icon: Icons.bug_report_outlined,
                  label: 'Salud: ${crop.healthRecords.length}',
                ),
            ],
          ),

          if (pendingTasks.isNotEmpty && isActive) ...[
            const SizedBox(height: 8),
            ...pendingTasks
                .take(3)
                .map(
                  (task) => Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Row(
                      children: [
                        InkWell(
                          onTap: () => onCompleteTask?.call(task.uuid),
                          child: Icon(
                            Icons.check_circle_outline,
                            size: 18,
                            color: task.isOverdue
                                ? theme.colorScheme.error
                                : theme.colorScheme.primary,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            '${task.type.displayName} — ${task.dueDate.day}/${task.dueDate.month}',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: task.isOverdue
                                  ? theme.colorScheme.error
                                  : null,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
          ],

          if (isActive) ...[
            const SizedBox(height: 10),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                _CropActionChip(
                  icon: Icons.water_drop_outlined,
                  label: 'Regar',
                  onPressed: onWater,
                ),
                _CropActionChip(
                  icon: Icons.agriculture_outlined,
                  label: 'Cosechar',
                  onPressed: onHarvest,
                ),
                _CropActionChip(
                  icon: Icons.bug_report_outlined,
                  label: 'Salud',
                  onPressed: onHealth,
                ),
                _CropActionChip(
                  icon: Icons.add_task_outlined,
                  label: 'Tarea',
                  onPressed: onAddTask,
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

// ─── CropInfoChip ─────────────────────────────────────────────────────────────

class _CropInfoChip extends StatelessWidget {
  const _CropInfoChip({
    required this.icon,
    required this.label,
    this.isWarning = false,
    this.isError = false,
  });

  final IconData icon;
  final String label;
  final bool isWarning;
  final bool isError;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = isError
        ? theme.colorScheme.error
        : isWarning
        ? Colors.orange
        : theme.colorScheme.onSurfaceVariant;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isError
            ? theme.colorScheme.errorContainer.withValues(alpha: 0.3)
            : isWarning
            ? Colors.orange.withValues(alpha: 0.1)
            : theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── CropActionChip ───────────────────────────────────────────────────────────

class _CropActionChip extends StatelessWidget {
  const _CropActionChip({
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  final IconData icon;
  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return ActionChip(
      avatar: Icon(icon, size: 16),
      label: Text(label),
      onPressed: onPressed,
    );
  }
}

