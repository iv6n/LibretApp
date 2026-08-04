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
import 'package:libretapp/features/agenda/domain/agenda_realize_strategy.dart';
import 'package:libretapp/features/agenda/domain/agenda_task_grouping.dart';
import 'package:libretapp/features/agenda/widgets/agenda_bulk_movement_sheet.dart';
import 'package:libretapp/features/agenda/widgets/agenda_form_queue.dart';
import 'package:libretapp/features/agenda/widgets/agenda_style.dart';
import 'package:libretapp/features/directorio/animales/domain/entities/animal_entity.dart';
import 'package:libretapp/features/directorio/animales/domain/entities/care_record.dart';
import 'package:libretapp/features/directorio/animales/domain/repositories/care_repository.dart';
import 'package:libretapp/features/directorio/animales/infrastructure/animal_repository.dart';
import 'package:libretapp/features/directorio/lotes/infrastructure/lotes_repository.dart';
import 'package:libretapp/features/registro/view/bulk_health_registro_page.dart';
import 'package:path_provider/path_provider.dart';

class AgendaTaskDetailPage extends StatefulWidget {
  const AgendaTaskDetailPage({super.key, required this.group});

  final AgendaEventGroup group;

  @override
  State<AgendaTaskDetailPage> createState() => _AgendaTaskDetailPageState();
}

class _AgendaTaskDetailPageState extends State<AgendaTaskDetailPage> {
  List<AnimalEntity> _directAnimals = [];
  Map<String, List<AnimalEntity>> _loteAnimals = {};
  final Map<String, Set<String>> _entryIdsByAnimal = {};
  final Set<String> _selectedAnimalIds = {};
  bool _loading = true;

  late AgendaEntry _entry;
  late Map<String, AgendaEntry> _entriesById;

  /// Last state the bloc actually confirmed persisted. Used to roll back
  /// [_entry] if a mutation the UI applied optimistically turns out to have
  /// failed to save (see [_onAgendaState]).
  late Map<String, AgendaEntry> _confirmedEntries;

  @override
  void initState() {
    super.initState();
    _entriesById = {for (final entry in widget.group.entries) entry.id: entry};
    _entry = widget.group.primaryEntry;
    _confirmedEntries = Map.of(_entriesById);
    _loadData();
  }

  void _onAgendaState(BuildContext context, AgendaState state) {
    if (state is AgendaLoaded) {
      final representedIds = _entriesById.keys.toSet();
      final updated = {
        for (final entry in state.entries)
          if (representedIds.contains(entry.id)) entry.id: entry,
      };
      if (updated.isEmpty) return;
      _confirmedEntries = Map.of(updated);
      setState(() {
        _entriesById = updated;
        _entry = updated[_entry.id] ?? updated.values.first;
        _selectedAnimalIds.removeWhere(_isAnimalCompleted);
      });
      return;
    }
    if (state is AgendaError) {
      setState(() {
        _entriesById = Map.of(_confirmedEntries);
        _entry = _entriesById[_entry.id] ?? _entriesById.values.first;
      });
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

    final blocState = context.read<AgendaBloc>().state;
    if (blocState is AgendaLoaded) {
      final representedIds = _entriesById.keys.toSet();
      final currentEntries = {
        for (final entry in blocState.entries)
          if (representedIds.contains(entry.id)) entry.id: entry,
      };
      if (currentEntries.isNotEmpty) {
        _entriesById = currentEntries;
        _confirmedEntries = Map.of(currentEntries);
        _entry = currentEntries[_entry.id] ?? currentEntries.values.first;
      }
    }

    // Load direct animals
    final directAnimals = <AnimalEntity>[];
    final seenDirect = <String>{};
    for (final sourceEntry in _entriesById.values) {
      for (final uuid in sourceEntry.animalIds) {
        _entryIdsByAnimal.putIfAbsent(uuid, () => {}).add(sourceEntry.id);
        if (!seenDirect.add(uuid)) continue;
        final a = await animalRepo.getByUuid(uuid);
        if (a != null) directAnimals.add(a);
      }
    }

    // Expand lotes into animals
    final loteAnimals = <String, List<AnimalEntity>>{};
    for (final sourceEntry in _entriesById.values) {
      for (final loteUuid in sourceEntry.loteIds) {
        final lote = await lotesRepo.getByUuid(loteUuid);
        if (lote == null) continue;
        final members = loteAnimals.putIfAbsent(loteUuid, () => []);
        final knownMembers = members.map((animal) => animal.uuid).toSet();
        for (final animalUuid in lote.animalUuids) {
          _entryIdsByAnimal
              .putIfAbsent(animalUuid, () => {})
              .add(sourceEntry.id);
          if (!knownMembers.add(animalUuid)) continue;
          final a = await animalRepo.getByUuid(animalUuid);
          if (a != null) members.add(a);
        }
      }
    }

    if (!mounted) return;
    setState(() {
      _directAnimals = directAnimals;
      _loteAnimals = loteAnimals;
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

  List<AgendaEntry> get _sourceEntries => _entriesById.values.toList();

  List<AnimalEntity> get _allAnimals {
    final unique = <String, AnimalEntity>{};
    for (final animal in _directAnimals) {
      unique[animal.uuid] = animal;
    }
    for (final animal in _loteAnimals.values.expand((list) => list)) {
      unique[animal.uuid] = animal;
    }
    return unique.values.toList(growable: false);
  }

  int get _totalAnimals => _allAnimals.length;

  bool _entryIsTerminal(AgendaEntry entry) =>
      entry.estado == AgendaEstado.completado ||
      entry.estado == AgendaEstado.verificado;

  bool _isAnimalCompleted(String animalUuid) {
    final entryIds = _entryIdsByAnimal[animalUuid] ?? const <String>{};
    if (entryIds.isEmpty) return false;
    return entryIds.every((entryId) {
      final entry = _entriesById[entryId];
      return entry != null &&
          (_entryIsTerminal(entry) ||
              entry.completedAnimalIds.contains(animalUuid));
    });
  }

  String get _groupStatus {
    final entries = _sourceEntries;
    if (entries.every((entry) => entry.estado == AgendaEstado.verificado)) {
      return AgendaEstado.verificado;
    }
    if (entries.every(_entryIsTerminal)) return AgendaEstado.completado;
    if (entries.any((entry) => entry.estado == AgendaEstado.bloqueado)) {
      return AgendaEstado.bloqueado;
    }
    if (entries.any(
      (entry) =>
          entry.estado == AgendaEstado.enProgreso ||
          entry.completedAnimalIds.isNotEmpty,
    )) {
      return AgendaEstado.enProgreso;
    }
    return AgendaEstado.pendiente;
  }

  List<AgendaActivity> get _activities {
    final byId = <String, AgendaActivity>{};
    for (final entry in _sourceEntries) {
      for (final activity in entry.activities) {
        byId[activity.id] = activity;
      }
    }
    final values = byId.values.toList(growable: false)
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return values;
  }

  void _markCompleted(String animalUuid) {
    final entryIds = _entryIdsByAnimal[animalUuid] ?? const <String>{};
    final bloc = context.read<AgendaBloc>();
    for (final entryId in entryIds) {
      final source = _entriesById[entryId];
      if (source == null ||
          source.completedAnimalIds.contains(animalUuid) ||
          _entryIsTerminal(source)) {
        continue;
      }
      bloc.add(MarkAnimalCompleted(entryId: entryId, animalId: animalUuid));
    }
    setState(() {
      final now = DateTime.now();
      for (final entryId in entryIds) {
        final source = _entriesById[entryId];
        if (source == null) continue;
        final completed = {...source.completedAnimalIds, animalUuid}.toList();
        final allDone =
            source.animalIds.isNotEmpty &&
            source.animalIds.every(completed.contains);
        _entriesById[entryId] = source.copyWith(
          completedAnimalIds: completed,
          estado: allDone ? AgendaEstado.completado : AgendaEstado.enProgreso,
          fechaCompletado: allDone ? now : source.fechaCompletado,
        );
      }
      _entry = _entriesById[_entry.id] ?? _entriesById.values.first;
      _selectedAnimalIds.remove(animalUuid);
    });
  }

  /// Advances the care calendar when an automatic care reminder is executed.
  /// Without this record, the completed card would disappear but the next
  /// occurrence of the vaccination/deworming protocol would never be dated.
  Future<void> _recordCareExecution(String animalUuid) async {
    final careEntries = (_entryIdsByAnimal[animalUuid] ?? const <String>{})
        .map((id) => _entriesById[id])
        .whereType<AgendaEntry>()
        .where((entry) => entry.id.startsWith('auto:care:'))
        .toList(growable: false);
    if (careEntries.isEmpty) return;

    try {
      final repository = locator<CareRepository>();
      final rules = {
        for (final rule in await repository.getRules()) rule.id: rule,
      };
      final performedAt = DateTime.now();
      for (final source in careEntries) {
        final parts = source.id.split(':');
        if (parts.length < 5) continue;
        final rule = rules[parts[3]];
        if (rule == null) continue;
        await repository.saveRecord(
          CareRecord(
            id: 'agenda-care:${source.id}',
            animalId: animalUuid,
            ruleId: rule.id,
            type: rule.type,
            performedAt: performedAt,
            notes: 'Registrado desde Agenda: ${widget.group.titulo}',
          ),
        );
      }
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'La tarea se completó, pero no se pudo actualizar el calendario '
            'de cuidados.',
          ),
        ),
      );
    }
  }

  void _changeStatus(String status, {String reason = ''}) {
    final bloc = context.read<AgendaBloc>();
    for (final source in _sourceEntries) {
      if (status == AgendaEstado.verificado &&
          source.estado != AgendaEstado.completado) {
        continue;
      }
      bloc.add(
        ChangeAgendaStatus(entryId: source.id, status: status, reason: reason),
      );
    }
    final now = DateTime.now();
    setState(() {
      _entriesById = _entriesById.map((id, source) {
        if (status == AgendaEstado.verificado &&
            source.estado != AgendaEstado.completado) {
          return MapEntry(id, source);
        }
        return MapEntry(
          id,
          source.copyWith(
            estado: status,
            blockedReason: status == AgendaEstado.bloqueado ? reason : null,
            fechaCompletado:
                status == AgendaEstado.completado ||
                    status == AgendaEstado.verificado
                ? now
                : source.fechaCompletado,
            updatedAt: now,
          ),
        );
      });
      _entry = _entriesById[_entry.id] ?? _entriesById.values.first;
    });
  }

  Future<void> _blockTask() async {
    final controller = TextEditingController();
    final reason = await showDialog<String>(
      context: context,
      useRootNavigator: true,
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
      useRootNavigator: true,
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

    Future<void> onSaved() async {
      await _recordCareExecution(animal.uuid);
      if (!mounted) return;
      _markCompleted(animal.uuid);
      if (mounted) {
        ScaffoldMessenger.of(this.context).showSnackBar(
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
      if (saved == true) await onSaved();
    } else if (tipo == 'pesaje') {
      final saved = await context.pushNamed(
        AppRoutes.nameAnimalRegistroPeso,
        pathParameters: {'uuid': animal.uuid},
      );
      if (saved == true) await onSaved();
    } else if (tipo == 'inseminación' || tipo == 'parto') {
      final saved = await context.pushNamed(
        AppRoutes.nameAnimalRegistroReproduccion,
        pathParameters: {'uuid': animal.uuid},
      );
      if (saved == true) await onSaved();
    } else {
      // Generic: just mark as completed with a confirm dialog
      final confirmed = await showDialog<bool>(
        context: context,
        useRootNavigator: true,
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
      if (confirmed == true) await onSaved();
    }
  }

  void _toggleAnimalSelection(String animalUuid, bool selected) {
    if (_isAnimalCompleted(animalUuid)) return;
    setState(() {
      if (selected) {
        _selectedAnimalIds.add(animalUuid);
      } else {
        _selectedAnimalIds.remove(animalUuid);
      }
    });
  }

  void _toggleSelectAll() {
    final pendingIds = _allAnimals
        .where((animal) => !_isAnimalCompleted(animal.uuid))
        .map((animal) => animal.uuid)
        .toSet();
    setState(() {
      if (_selectedAnimalIds.containsAll(pendingIds)) {
        _selectedAnimalIds.clear();
      } else {
        _selectedAnimalIds
          ..clear()
          ..addAll(pendingIds);
      }
    });
  }

  Future<void> _realizeSelected() async {
    final ids = _selectedAnimalIds
        .where((id) => !_isAnimalCompleted(id))
        .toList(growable: false);
    if (ids.isEmpty) return;

    switch (realizeStrategyForCategoria(widget.group.categoria)) {
      case AgendaRealizeStrategy.bulkHealth:
        final result = await Navigator.of(context).push<List<String>>(
          MaterialPageRoute(
            builder: (_) => BulkHealthRegistroPage(
              initialAnimalUuids: ids,
              initialType: healthRecordTypeForAgendaTipo(widget.group.tipo),
            ),
          ),
        );
        if (result == null || !mounted) return;
        for (final animalId in result) {
          await _recordCareExecution(animalId);
          if (!mounted) return;
          _markCompleted(animalId);
        }
      case AgendaRealizeStrategy.bulkMovement:
        final animals = ids
            .map(
              (id) =>
                  _allAnimals.where((animal) => animal.uuid == id).firstOrNull,
            )
            .whereType<AnimalEntity>()
            .toList(growable: false);
        final saved = await showAgendaBulkMovementSheet(
          context,
          animals: animals,
        );
        if (saved == true && mounted) {
          for (final animalId in ids) {
            _markCompleted(animalId);
          }
        }
      case AgendaRealizeStrategy.queuedReproduction:
        await _runQueuedForms(
          ids,
          routeName: AppRoutes.nameAnimalRegistroReproduccion,
        );
      case AgendaRealizeStrategy.queuedWeight:
        await _runQueuedForms(ids, routeName: AppRoutes.nameAnimalRegistroPeso);
      case AgendaRealizeStrategy.none:
        final confirmed = await showDialog<bool>(
          context: context,
          builder: (dialogContext) => AlertDialog(
            title: Text('Completar ${widget.group.titulo}'),
            content: Text(
              '¿Confirmar la tarea para ${ids.length} '
              '${ids.length == 1 ? 'animal' : 'animales'}?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext, false),
                child: const Text('Cancelar'),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(dialogContext, true),
                child: const Text('Confirmar'),
              ),
            ],
          ),
        );
        if (confirmed == true && mounted) {
          for (final animalId in ids) {
            _markCompleted(animalId);
          }
        }
    }
  }

  Future<void> _runQueuedForms(
    List<String> animalUuids, {
    required String routeName,
  }) async {
    await runAgendaFormQueue<bool>(
      animalUuids: animalUuids,
      shouldContinue: () => mounted,
      isSuccess: (result) => result == true,
      pushStep: (uuid, index, total) async {
        if (!mounted) return null;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Animal ${index + 1} de $total'),
            duration: const Duration(seconds: 2),
          ),
        );
        return context.pushNamed<bool>(
          routeName,
          pathParameters: {'uuid': uuid},
        );
      },
      onStepSuccess: _markCompleted,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final typeColor = colorForTipo(_entry.tipo);
    final groupStatus = _groupStatus;
    final estadoColor = colorForEstado(groupStatus);
    final dateFormatter = DateFormat('d MMMM yyyy');
    final allAnimals = _allAnimals;
    final completedCount = allAnimals
        .where((animal) => _isAnimalCompleted(animal.uuid))
        .length;
    final total = _totalAnimals;
    final progress = total == 0 ? 0.0 : completedCount / total;
    final activities = _activities;

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
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
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
                                  estado: groupStatus,
                                  color: estadoColor,
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Text(
                              widget.group.titulo,
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
                      status: groupStatus,
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
                        title:
                            'Checklist (${_entry.checklist.where((item) => item.completed).length}/${_entry.checklist.length})',
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

                    if (activities.isNotEmpty) ...[
                      const SizedBox(height: 20),
                      const _SectionTitle(
                        title: 'Bitácora',
                        icon: Icons.history_outlined,
                      ),
                      const SizedBox(height: 8),
                      ...activities.map(
                        (activity) => ListTile(
                          dense: true,
                          leading: const Icon(Icons.circle, size: 10),
                          title: Text(_activityLabel(activity.type)),
                          subtitle: Text(
                            [
                              DateFormat(
                                'dd/MM/yyyy HH:mm',
                              ).format(activity.timestamp),
                              if (activity.note?.isNotEmpty == true)
                                activity.note!,
                            ].join(' · '),
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
                          valueColor: AlwaysStoppedAnimation<Color>(
                            estadoColor,
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],

                    if (allAnimals.isNotEmpty) ...[
                      Row(
                        children: [
                          Expanded(
                            child: _SectionTitle(
                              title: 'Animales (${allAnimals.length})',
                              icon: Icons.pets_outlined,
                            ),
                          ),
                          TextButton(
                            onPressed: completedCount >= total
                                ? null
                                : _toggleSelectAll,
                            child: Text(
                              _selectedAnimalIds.length ==
                                      total - completedCount
                                  ? 'Quitar selección'
                                  : 'Seleccionar pendientes',
                            ),
                          ),
                        ],
                      ),
                      if (_selectedAnimalIds.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        SizedBox(
                          width: double.infinity,
                          child: FilledButton.icon(
                            onPressed: _realizeSelected,
                            icon: const Icon(Icons.playlist_add_check),
                            label: Text(
                              'Realizar (${_selectedAnimalIds.length})',
                            ),
                          ),
                        ),
                      ],
                      const SizedBox(height: 8),
                      ...allAnimals.map(
                        (animal) => _AnimalTaskRow(
                          animal: animal,
                          label: _animalLabel(animal),
                          isCompleted: _isAnimalCompleted(animal.uuid),
                          selected: _selectedAnimalIds.contains(animal.uuid),
                          onSelected: (selected) =>
                              _toggleAnimalSelection(animal.uuid, selected),
                          onRegister: () => _openRegistroForm(context, animal),
                          onMarkDone: () async {
                            await _recordCareExecution(animal.uuid);
                            if (mounted) _markCompleted(animal.uuid);
                          },
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],

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
                                child: const Text(
                                  'Marcar tarea como completada',
                                ),
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
    required this.selected,
    required this.onSelected,
    required this.onRegister,
    required this.onMarkDone,
  });

  final AnimalEntity animal;
  final String label;
  final bool isCompleted;
  final bool selected;
  final ValueChanged<bool> onSelected;
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
        leading: isCompleted
            ? CircleAvatar(
                backgroundColor: doneColor.withValues(alpha: 0.15),
                child: Icon(Icons.check, size: 20, color: doneColor),
              )
            : Checkbox(
                value: selected,
                onChanged: (value) => onSelected(value == true),
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
