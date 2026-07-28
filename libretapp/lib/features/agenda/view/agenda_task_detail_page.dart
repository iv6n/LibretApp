/// features › agenda › view › agenda_task_detail_page — step-by-step task execution for an agenda entry.
library;

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:libretapp/core/di/injection.dart';
import 'package:libretapp/core/router/app_routes.dart';
import 'package:libretapp/features/agenda/bloc/agenda_bloc.dart';
import 'package:libretapp/features/agenda/bloc/agenda_event.dart';
import 'package:libretapp/features/agenda/bloc/agenda_state.dart';
import 'package:libretapp/features/agenda/data/agenda_model.dart';
import 'package:libretapp/features/agenda/widgets/agenda_style.dart';
import 'package:libretapp/features/directorio/animales/domain/entities/animal_entity.dart';
import 'package:libretapp/features/directorio/animales/infrastructure/animal_repository.dart';
import 'package:libretapp/features/directorio/lotes/infrastructure/lotes_repository.dart';
import 'package:path_provider/path_provider.dart';

class AgendaTaskDetailPage extends StatefulWidget {
  const AgendaTaskDetailPage({super.key, required this.entry});

  final AgendaEntry entry;

  @override
  State<AgendaTaskDetailPage> createState() => _AgendaTaskDetailPageState();
}

class _AgendaTaskDetailPageState extends State<AgendaTaskDetailPage> {
  List<AnimalEntity> _directAnimals = [];
  Map<String, List<AnimalEntity>> _loteAnimals = {};
  Map<String, String> _loteNames = {};
  bool _loading = true;

  late AgendaEntry _entry;

  /// Last state the bloc actually confirmed persisted. Used to roll back
  /// [_entry] if a mutation the UI applied optimistically turns out to have
  /// failed to save (see [_onAgendaState]).
  late AgendaEntry _confirmedEntry;

  @override
  void initState() {
    super.initState();
    _entry = widget.entry;
    _confirmedEntry = widget.entry;
    _loadData();
  }

  void _onAgendaState(BuildContext context, AgendaState state) {
    if (state is AgendaLoaded) {
      final updated = state.entries
          .where((e) => e.id == _entry.id)
          .firstOrNull;
      if (updated == null) return;
      _confirmedEntry = updated;
      setState(() => _entry = updated);
      return;
    }
    if (state is AgendaError) {
      setState(() => _entry = _confirmedEntry);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('No se pudo guardar el cambio: ${state.message}'),
        ),
      );
    }
  }

  Future<void> _loadData() async {
    final animalRepo = locator<AnimalRepository>();
    final lotesRepo = locator<LotesRepository>();

    // Load direct animals
    final directAnimals = <AnimalEntity>[];
    for (final uuid in _entry.animalIds) {
      final a = await animalRepo.getByUuid(uuid);
      if (a != null) directAnimals.add(a);
    }

    // Expand lotes into animals
    final loteAnimals = <String, List<AnimalEntity>>{};
    final loteNames = <String, String>{};
    for (final loteUuid in _entry.loteIds) {
      final lote = await lotesRepo.getByUuid(loteUuid);
      if (lote == null) continue;
      loteNames[loteUuid] = lote.name;
      final members = <AnimalEntity>[];
      for (final animalUuid in lote.animalUuids) {
        final a = await animalRepo.getByUuid(animalUuid);
        if (a != null) members.add(a);
      }
      loteAnimals[loteUuid] = members;
    }

    if (!mounted) return;
    setState(() {
      _directAnimals = directAnimals;
      _loteAnimals = loteAnimals;
      _loteNames = loteNames;
      _loading = false;
    });
  }

  String _animalLabel(AnimalEntity a) {
    final name = a.customName?.trim().isNotEmpty == true
        ? a.customName!
        : a.visualId?.trim().isNotEmpty == true
        ? a.visualId!
        : null;
    return name != null ? '$name (${a.earTagNumber})' : a.earTagNumber;
  }

  int get _totalAnimals {
    final fromLotes = _loteAnimals.values.fold<int>(
      0,
      (sum, list) => sum + list.length,
    );
    return _directAnimals.length + fromLotes;
  }

  List<AnimalEntity> get _allAnimals => [
    ..._directAnimals,
    ..._loteAnimals.values.expand((list) => list),
  ];

  void _markCompleted(String animalUuid) {
    context.read<AgendaBloc>().add(
      MarkAnimalCompleted(entryId: _entry.id, animalId: animalUuid),
    );
    setState(() {
      final updated = List<String>.from(_entry.completedAnimalIds);
      if (!updated.contains(animalUuid)) updated.add(animalUuid);
      final allDone =
          _allAnimals.isNotEmpty &&
          _allAnimals.every((a) => updated.contains(a.uuid));
      _entry = _entry.copyWith(
        completedAnimalIds: updated,
        estado: allDone
            ? AgendaEstado.completado
            : updated.isEmpty
            ? AgendaEstado.pendiente
            : AgendaEstado.enProgreso,
        fechaCompletado: allDone ? DateTime.now() : _entry.fechaCompletado,
      );
    });
  }

  void _changeStatus(String status, {String reason = ''}) {
    context.read<AgendaBloc>().add(
      ChangeAgendaStatus(entryId: _entry.id, status: status, reason: reason),
    );
    final now = DateTime.now();
    setState(() {
      _entry = _entry.copyWith(
        estado: status,
        blockedReason: status == AgendaEstado.bloqueado ? reason : null,
        fechaCompletado:
            status == AgendaEstado.completado || status == AgendaEstado.verificado
            ? now
            : _entry.fechaCompletado,
        updatedAt: now,
      );
    });
  }

  Future<void> _blockTask() async {
    final controller = TextEditingController();
    final reason = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Bloquear tarea'),
        content: TextField(
          controller: controller,
          autofocus: true,
          maxLines: 3,
          decoration: const InputDecoration(
            labelText: 'Motivo',
            hintText: 'Ej. falta medicamento o no se encontró el animal',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () {
              final value = controller.text.trim();
              if (value.isNotEmpty) Navigator.pop(dialogContext, value);
            },
            child: const Text('Bloquear'),
          ),
        ],
      ),
    );
    controller.dispose();
    if (reason != null) _changeStatus(AgendaEstado.bloqueado, reason: reason);
  }

  void _toggleChecklist(AgendaChecklistItem item, bool completed) {
    context.read<AgendaBloc>().add(
      ToggleAgendaChecklistItem(
        entryId: _entry.id,
        itemId: item.id,
        completed: completed,
      ),
    );
    setState(() {
      _entry = _entry.copyWith(
        checklist: _entry.checklist
            .map(
              (current) => current.id == item.id
                  ? current.copyWith(
                      completed: completed,
                      completedAt: completed ? DateTime.now() : null,
                    )
                  : current,
            )
            .toList(growable: false),
      );
    });
  }

  Future<void> _addEvidence() async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      builder: (sheetContext) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.photo_camera_outlined),
              title: const Text('Tomar foto'),
              onTap: () => Navigator.pop(sheetContext, ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: const Text('Elegir de galería'),
              onTap: () => Navigator.pop(sheetContext, ImageSource.gallery),
            ),
          ],
        ),
      ),
    );
    if (source == null) return;

    final picked = await ImagePicker().pickImage(
      source: source,
      imageQuality: 82,
      maxWidth: 2048,
    );
    if (picked == null) return;

    final now = DateTime.now();
    final documents = await getApplicationDocumentsDirectory();
    final evidenceDir = Directory('${documents.path}/agenda_evidence');
    await evidenceDir.create(recursive: true);
    final extension = picked.path.contains('.')
        ? picked.path.substring(picked.path.lastIndexOf('.'))
        : '.jpg';
    final saved = await File(picked.path).copy(
      '${evidenceDir.path}/${_entry.id}-${now.microsecondsSinceEpoch}$extension',
    );
    if (!mounted) return;

    final updated = _entry.copyWith(
      evidence: [
        ..._entry.evidence,
        AgendaEvidence(
          id: 'evidence-${now.microsecondsSinceEpoch}',
          path: saved.path,
          createdAt: now,
        ),
      ],
      activities: [
        ..._entry.activities,
        AgendaActivity(
          id: 'activity-${now.microsecondsSinceEpoch}',
          type: 'evidence_added',
          timestamp: now,
          note: 'Se adjuntó evidencia fotográfica',
        ),
      ],
      updatedAt: now,
    );
    context.read<AgendaBloc>().add(UpdateAgendaEntry(updated));
    setState(() => _entry = updated);
  }

  Future<void> _openRegistroForm(
    BuildContext context,
    AnimalEntity animal,
  ) async {
    final tipo = _entry.tipo.toLowerCase();

    void onSaved() {
      _markCompleted(animal.uuid);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Registro guardado para ${_animalLabel(animal)}'),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }

    if (tipo == 'vacunación' ||
        tipo == 'desparasitación' ||
        tipo == 'revisión veterinaria' ||
        tipo == 'mantenimiento') {
      final saved = await context.pushNamed(
        AppRoutes.nameAnimalRegistroSalud,
        pathParameters: {'uuid': animal.uuid},
      );
      if (saved == true) onSaved();
    } else if (tipo == 'pesaje') {
      final saved = await context.pushNamed(
        AppRoutes.nameAnimalRegistroPeso,
        pathParameters: {'uuid': animal.uuid},
      );
      if (saved == true) onSaved();
    } else if (tipo == 'inseminación' || tipo == 'parto') {
      final saved = await context.pushNamed(
        AppRoutes.nameAnimalRegistroReproduccion,
        pathParameters: {'uuid': animal.uuid},
      );
      if (saved == true) onSaved();
    } else {
      // Generic: just mark as completed with a confirm dialog
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text('Registrar: ${_animalLabel(animal)}'),
          content: Text(
            '¿Confirmar que se realizó "${_entry.tipo}" para este animal?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(ctx).pop(true),
              child: const Text('Confirmar'),
            ),
          ],
        ),
      );
      if (confirmed == true) onSaved();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final typeColor = colorForTipo(_entry.tipo);
    final estadoColor = colorForEstado(_entry.estado);
    final dateFormatter = DateFormat('d MMMM yyyy');
    final completedCount = _entry.completedAnimalIds.length;
    final total = _totalAnimals;
    final progress = total == 0 ? 0.0 : completedCount / total;

    return BlocListener<AgendaBloc, AgendaState>(
      listener: _onAgendaState,
      child: Scaffold(
      appBar: AppBar(title: const Text('Realizar tarea'), elevation: 0),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Task header card
                  Card(
                    elevation: 0,
                    color: theme.colorScheme.surfaceContainerHighest,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: typeColor.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Icon(
                                  iconForTipo(_entry.tipo),
                                  color: typeColor,
                                  size: 22,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      _entry.tipo,
                                      style: theme.textTheme.labelLarge
                                          ?.copyWith(
                                            color: typeColor,
                                            fontWeight: FontWeight.w700,
                                          ),
                                    ),
                                    Text(
                                      dateFormatter.format(_entry.fecha),
                                      style: theme.textTheme.labelMedium
                                          ?.copyWith(
                                            color: theme.colorScheme.outline,
                                          ),
                                    ),
                                  ],
                                ),
                              ),
                              _StatusChip(
                                estado: _entry.estado,
                                color: estadoColor,
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            _entry.titulo,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          if (_entry.descripcion.isNotEmpty) ...[
                            const SizedBox(height: 4),
                            Text(
                              _entry.descripcion,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.outline,
                              ),
                            ),
                          ],
                          if (_entry.notas.isNotEmpty) ...[
                            const SizedBox(height: 4),
                            Text(
                              'Notas: ${_entry.notas}',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.outline,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  _TaskStatusActions(
                    status: _entry.estado,
                    canComplete: total == 0 || completedCount >= total,
                    onStart: () => _changeStatus(AgendaEstado.enProgreso),
                    onBlock: _blockTask,
                    onComplete: () => _changeStatus(AgendaEstado.completado),
                    onVerify: () => _changeStatus(AgendaEstado.verificado),
                  ),

                  if (_entry.blockedReason?.isNotEmpty == true) ...[
                    const SizedBox(height: 8),
                    Card(
                      color: theme.colorScheme.errorContainer,
                      child: ListTile(
                        leading: Icon(
                          Icons.report_problem_outlined,
                          color: theme.colorScheme.onErrorContainer,
                        ),
                        title: const Text('Motivo del bloqueo'),
                        subtitle: Text(_entry.blockedReason!),
                      ),
                    ),
                  ],

                  if (_entry.checklist.isNotEmpty) ...[
                    const SizedBox(height: 20),
                    _SectionTitle(
                      title: 'Checklist (${_entry.checklist.where((item) => item.completed).length}/${_entry.checklist.length})',
                      icon: Icons.checklist_outlined,
                    ),
                    const SizedBox(height: 8),
                    Card(
                      elevation: 0,
                      child: Column(
                        children: _entry.checklist
                            .map(
                              (item) => CheckboxListTile(
                                value: item.completed,
                                title: Text(item.label),
                                onChanged: (value) =>
                                    _toggleChecklist(item, value == true),
                              ),
                            )
                            .toList(growable: false),
                      ),
                    ),
                  ],

                  const SizedBox(height: 20),
                  Row(
                    children: [
                      const Expanded(
                        child: _SectionTitle(
                          title: 'Evidencia',
                          icon: Icons.photo_camera_back_outlined,
                        ),
                      ),
                      TextButton.icon(
                        onPressed: _addEvidence,
                        icon: const Icon(Icons.add_a_photo_outlined),
                        label: const Text('Agregar'),
                      ),
                    ],
                  ),
                  if (_entry.evidence.isEmpty)
                    Text(
                      'Sin fotografías adjuntas.',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.outline,
                      ),
                    )
                  else
                    SizedBox(
                      height: 96,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: _entry.evidence.length,
                        separatorBuilder: (_, _) => const SizedBox(width: 8),
                        itemBuilder: (_, index) => ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.file(
                            File(_entry.evidence[index].path),
                            width: 96,
                            height: 96,
                            fit: BoxFit.cover,
                            errorBuilder: (_, _, _) => const SizedBox.square(
                              dimension: 96,
                              child: ColoredBox(
                                color: Color(0xFFE0E0E0),
                                child: Icon(Icons.broken_image_outlined),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),

                  if (_entry.activities.isNotEmpty) ...[
                    const SizedBox(height: 20),
                    _SectionTitle(
                      title: 'Bitácora',
                      icon: Icons.history_outlined,
                    ),
                    const SizedBox(height: 8),
                    ..._entry.activities.reversed.take(5).map(
                      (activity) => ListTile(
                        dense: true,
                        leading: const Icon(Icons.circle, size: 10),
                        title: Text(_activityLabel(activity.type)),
                        subtitle: Text(
                          DateFormat('dd/MM/yyyy HH:mm').format(activity.timestamp),
                        ),
                      ),
                    ),
                  ],

                  const SizedBox(height: 20),

                  // Progress section
                  if (total > 0) ...[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Progreso',
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(
                          '$completedCount / $total animales',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: estadoColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: LinearProgressIndicator(
                        value: progress,
                        minHeight: 10,
                        backgroundColor:
                            theme.colorScheme.surfaceContainerHighest,
                        valueColor: AlwaysStoppedAnimation<Color>(estadoColor),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],

                  // Direct animals section
                  if (_directAnimals.isNotEmpty) ...[
                    _SectionTitle(
                      title: 'Animales (${_directAnimals.length})',
                      icon: Icons.pets_outlined,
                    ),
                    const SizedBox(height: 8),
                    ..._directAnimals.map(
                      (animal) => _AnimalTaskRow(
                        animal: animal,
                        label: _animalLabel(animal),
                        isCompleted: _entry.completedAnimalIds.contains(
                          animal.uuid,
                        ),
                        onRegister: () => _openRegistroForm(context, animal),
                        onMarkDone: () => _markCompleted(animal.uuid),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Lote sections
                  ..._loteAnimals.entries.map(
                    (entry) => Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _SectionTitle(
                          title:
                              'Lote: ${_loteNames[entry.key] ?? entry.key} (${entry.value.length})',
                          icon: Icons.group_work_outlined,
                        ),
                        const SizedBox(height: 8),
                        ...entry.value.map(
                          (animal) => _AnimalTaskRow(
                            animal: animal,
                            label: _animalLabel(animal),
                            isCompleted: _entry.completedAnimalIds.contains(
                              animal.uuid,
                            ),
                            onRegister: () =>
                                _openRegistroForm(context, animal),
                            onMarkDone: () => _markCompleted(animal.uuid),
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],
                    ),
                  ),

                  if (total == 0)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 24),
                      child: Center(
                        child: Column(
                          children: [
                            Icon(
                              Icons.pets_outlined,
                              size: 40,
                              color: theme.colorScheme.outline,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'No hay animales asignados a esta tarea.',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: theme.colorScheme.outline,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 4),
                            FilledButton.tonal(
                              onPressed: () =>
                                  _changeStatus(AgendaEstado.completado),
                              child: const Text('Marcar tarea como completada'),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
      ),
    );
  }
}

class _TaskStatusActions extends StatelessWidget {
  const _TaskStatusActions({
    required this.status,
    required this.canComplete,
    required this.onStart,
    required this.onBlock,
    required this.onComplete,
    required this.onVerify,
  });

  final String status;
  final bool canComplete;
  final VoidCallback onStart;
  final VoidCallback onBlock;
  final VoidCallback onComplete;
  final VoidCallback onVerify;

  @override
  Widget build(BuildContext context) {
    if (status == AgendaEstado.verificado || status == AgendaEstado.cancelado) {
      return const SizedBox.shrink();
    }

    final actions = <Widget>[];
    if (status == AgendaEstado.pendiente || status == AgendaEstado.bloqueado) {
      actions.add(
        FilledButton.icon(
          onPressed: onStart,
          icon: const Icon(Icons.play_arrow),
          label: Text(
            status == AgendaEstado.bloqueado ? 'Reanudar' : 'Iniciar',
          ),
        ),
      );
    }
    if (status == AgendaEstado.enProgreso) {
      actions.add(
        OutlinedButton.icon(
          onPressed: onBlock,
          icon: const Icon(Icons.pause_circle_outline),
          label: const Text('Bloquear'),
        ),
      );
      actions.add(
        FilledButton.icon(
          onPressed: canComplete ? onComplete : null,
          icon: const Icon(Icons.task_alt),
          label: const Text('Completar'),
        ),
      );
    }
    if (status == AgendaEstado.completado) {
      actions.add(
        FilledButton.icon(
          onPressed: onVerify,
          icon: const Icon(Icons.verified_outlined),
          label: const Text('Verificar'),
        ),
      );
    }

    if (actions.isEmpty) return const SizedBox.shrink();
    return Wrap(spacing: 8, runSpacing: 8, children: actions);
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title, required this.icon});
  final String title;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Icon(icon, size: 18, color: theme.colorScheme.primary),
        const SizedBox(width: 8),
        Text(
          title,
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.estado, required this.color});
  final String estado;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Text(
        labelForEstado(estado),
        style: theme.textTheme.labelSmall?.copyWith(
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _AnimalTaskRow extends StatelessWidget {
  const _AnimalTaskRow({
    required this.animal,
    required this.label,
    required this.isCompleted,
    required this.onRegister,
    required this.onMarkDone,
  });

  final AnimalEntity animal;
  final String label;
  final bool isCompleted;
  final VoidCallback onRegister;
  final VoidCallback onMarkDone;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final doneColor = Colors.green;

    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isCompleted
              ? doneColor.withValues(alpha: 0.4)
              : theme.colorScheme.outlineVariant,
        ),
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: isCompleted
              ? doneColor.withValues(alpha: 0.15)
              : theme.colorScheme.surfaceContainerHighest,
          child: Icon(
            isCompleted ? Icons.check : Icons.pets_outlined,
            size: 20,
            color: isCompleted ? doneColor : theme.colorScheme.outline,
          ),
        ),
        title: Text(
          label,
          style: theme.textTheme.bodyMedium?.copyWith(
            decoration: isCompleted ? TextDecoration.lineThrough : null,
            color: isCompleted ? theme.colorScheme.outline : null,
          ),
        ),
        subtitle: Text(
          isCompleted ? 'Completado' : 'Pendiente',
          style: theme.textTheme.labelSmall?.copyWith(
            color: isCompleted ? doneColor : theme.colorScheme.outline,
          ),
        ),
        trailing: isCompleted
            ? Icon(Icons.check_circle, color: doneColor, size: 22)
            : Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextButton(
                    onPressed: onMarkDone,
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      visualDensity: VisualDensity.compact,
                    ),
                    child: const Text('Listo'),
                  ),
                  const SizedBox(width: 4),
                  FilledButton.tonal(
                    onPressed: onRegister,
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      visualDensity: VisualDensity.compact,
                    ),
                    child: const Text('Registrar'),
                  ),
                ],
              ),
      ),
    );
  }
}

String _activityLabel(String type) {
  if (type == 'created') return 'Tarea creada';
  if (type == 'updated') return 'Tarea actualizada';
  if (type == 'animal_completed') return 'Animal completado';
  if (type == 'checklist_completed') return 'Paso del checklist completado';
  if (type == 'checklist_reopened') return 'Paso del checklist reabierto';
  if (type.startsWith('status_changed:')) {
    return 'Estado: ${labelForEstado(type.substring('status_changed:'.length))}';
  }
  return type;
}
