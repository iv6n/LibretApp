/// features › agenda › widgets › agenda_form_sheet — bottom sheet form for creating/editing an agenda entry.
library;

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:libretapp/app/widgets/app_bottom_sheet.dart';
import 'package:libretapp/core/core.dart';
import 'package:libretapp/core/utils/id_generator.dart';
import 'package:libretapp/features/agenda/data/agenda_model.dart';
import 'package:libretapp/features/agenda/widgets/agenda_animal_selector_sheet.dart';
import 'package:libretapp/features/agenda/widgets/agenda_constants.dart';
import 'package:libretapp/features/agenda/widgets/agenda_workforce_sheet.dart';
import 'package:libretapp/features/ubicaciones/domain/entities/location_entity.dart';
import 'package:libretapp/theme/theme.dart';

Future<void> showAgendaFormSheet({
  required BuildContext context,
  required DateTime initialDate,
  required void Function(AgendaEntry) onSave,
  AgendaEntry? entry,
  List<LocationEntity> locations = const [],
}) async {
  await showAppBottomSheet<void>(
    context: context,
    useRootNavigator: true,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (ctx) {
      return Padding(
        padding: EdgeInsets.only(
          left: 16,
          right: 16,
          bottom: MediaQuery.of(ctx).viewInsets.bottom + 16,
          top: 16,
        ),
        child: AgendaEntryForm(
          initialDate: initialDate,
          onSave: onSave,
          entry: entry,
          locations: locations,
          showDragHandle: true,
          popOnSave: true,
        ),
      );
    },
  );
}

class AgendaEntryForm extends StatefulWidget {
  const AgendaEntryForm({
    required this.initialDate,
    required this.onSave,
    this.entry,
    this.locations = const [],
    this.popOnSave = false,
    this.showDragHandle = false,
    super.key,
  });

  final DateTime initialDate;
  final void Function(AgendaEntry) onSave;
  final AgendaEntry? entry;
  final List<LocationEntity> locations;
  final bool popOnSave;
  final bool showDragHandle;

  @override
  State<AgendaEntryForm> createState() => _AgendaEntryFormState();
}

class _AgendaEntryFormState extends State<AgendaEntryForm> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _tituloController;
  late final TextEditingController _descripcionController;
  late final TextEditingController _notasController;
  late final TextEditingController _ubicacionController;
  late final TextEditingController _checklistController;
  String? _locationUuid;

  late DateTime _fechaSeleccionada;
  late bool _hasExplicitTime;
  String? _tipoSeleccionado;
  late List<String> _selectedAnimalIds;
  late List<String> _selectedLoteIds;
  late String _prioridad;
  String? _assigneeId;
  String? _workTeamId;
  late List<String> _collaboratorIds;
  String? _recurrenceRule;

  @override
  void initState() {
    super.initState();
    _tituloController = TextEditingController(text: widget.entry?.titulo ?? '');
    _descripcionController = TextEditingController(
      text: widget.entry?.descripcion ?? '',
    );
    _notasController = TextEditingController(text: widget.entry?.notas ?? '');
    _ubicacionController = TextEditingController(
      text: widget.entry?.ubicacion ?? '',
    );
    _locationUuid = widget.entry?.locationUuid;
    _checklistController = TextEditingController(
      text: widget.entry?.checklist.map((item) => item.label).join('\n') ?? '',
    );

    _fechaSeleccionada = widget.entry?.fecha ?? widget.initialDate;
    _hasExplicitTime = widget.entry?.hasExplicitTime ?? false;
    _tipoSeleccionado = widget.entry?.tipo;
    _selectedAnimalIds = List<String>.from(widget.entry?.animalIds ?? []);
    _selectedLoteIds = List<String>.from(widget.entry?.loteIds ?? []);
    _prioridad = widget.entry?.prioridad ?? AgendaPrioridad.normal;
    _assigneeId = widget.entry?.assigneeId;
    _workTeamId = widget.entry?.workTeamId;
    _collaboratorIds = List<String>.from(
      widget.entry?.collaboratorIds ?? const [],
    );
    _recurrenceRule = widget.entry?.recurrenceRule;
  }

  @override
  void dispose() {
    _tituloController.dispose();
    _descripcionController.dispose();
    _notasController.dispose();
    _ubicacionController.dispose();
    _checklistController.dispose();
    super.dispose();
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    final now = DateTime.now();
    final String ubicacion;
    if (_locationUuid != null && widget.locations.isNotEmpty) {
      ubicacion =
          widget.locations
              .where((l) => l.uuid == _locationUuid)
              .map((l) => l.name)
              .firstOrNull ??
          'Sin ubicación';
    } else {
      ubicacion = _ubicacionController.text.trim().isEmpty
          ? 'Sin ubicación'
          : _ubicacionController.text.trim();
    }
    final previousChecklist = <String, AgendaChecklistItem>{
      for (final item
          in widget.entry?.checklist ?? const <AgendaChecklistItem>[])
        item.label.trim().toLowerCase(): item,
    };
    final checklist = _checklistController.text
        .split('\n')
        .map((line) => line.trim())
        .where((line) => line.isNotEmpty)
        .map(
          (label) =>
              previousChecklist[label.toLowerCase()] ??
              AgendaChecklistItem(id: generateId(), label: label),
        )
        .toList(growable: false);
    final activities = <AgendaActivity>[
      ...widget.entry?.activities ?? const <AgendaActivity>[],
      AgendaActivity(
        id: generateId(),
        type: widget.entry == null ? 'created' : 'updated',
        timestamp: now,
      ),
    ];

    final saved = AgendaEntry(
      id: widget.entry?.id ?? generateId(),
      titulo: _tituloController.text.trim(),
      descripcion: _descripcionController.text.trim(),
      fecha: _fechaSeleccionada,
      hasExplicitTime: _hasExplicitTime,
      tipo: _tipoSeleccionado!,
      animalIds: _selectedAnimalIds,
      loteIds: _selectedLoteIds,
      ubicacion: ubicacion,
      locationUuid: _locationUuid,
      estado: widget.entry?.estado ?? AgendaEstado.pendiente,
      completedAnimalIds: widget.entry?.completedAnimalIds ?? const [],
      notas: _notasController.text.trim(),
      fechaCompletado: widget.entry?.fechaCompletado,
      prioridad: _prioridad,
      assigneeId: _assigneeId,
      collaboratorIds: _collaboratorIds,
      workTeamId: _workTeamId,
      createdById: widget.entry?.createdById,
      createdAt: widget.entry?.createdAt ?? now,
      updatedAt: now,
      recurrenceRule: _recurrenceRule,
      blockedReason: widget.entry?.blockedReason,
      checklist: checklist,
      activities: activities,
      evidence: widget.entry?.evidence ?? const [],
    );
    widget.onSave(saved);
    if (widget.popOnSave) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final totalSelected = _selectedAnimalIds.length + _selectedLoteIds.length;

    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (widget.showDragHandle) ...[
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 12),
            ],
            if (widget.showDragHandle) ...[
              Text(
                widget.entry == null ? 'Nueva tarea / evento' : 'Editar tarea',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 14),
            ],
            AppSelectField<String>(
              value: _tipoSeleccionado,
              items: agendaTipos,
              itemLabel: (tipo) => tipo,
              onChanged: (value) {
                setState(() => _tipoSeleccionado = value);
              },
              labelText: 'Tipo de tarea',
              hintText: 'Selecciona un tipo',
              requiredField: true,
              validator: (value) =>
                  value == null ? 'Selecciona un tipo de tarea' : null,
              prefixIcon: const Icon(Icons.category_outlined),
            ),
            const SizedBox(height: AppSpacing.sm),
            AppSelectField<String>(
              value: _prioridad,
              items: const [
                AgendaPrioridad.baja,
                AgendaPrioridad.normal,
                AgendaPrioridad.alta,
                AgendaPrioridad.urgente,
              ],
              itemLabel: (priority) => switch (priority) {
                AgendaPrioridad.baja => 'Prioridad baja',
                AgendaPrioridad.normal => 'Prioridad normal',
                AgendaPrioridad.alta => 'Prioridad alta',
                AgendaPrioridad.urgente => 'Prioridad urgente',
                _ => priority,
              },
              onChanged: (value) => setState(() {
                _prioridad = value ?? AgendaPrioridad.normal;
              }),
              labelText: 'Prioridad',
              prefixIcon: const Icon(Icons.flag_outlined),
            ),
            const SizedBox(height: AppSpacing.sm),
            AppTextField(
              controller: _tituloController,
              key: const ValueKey('agenda-task-title'),
              labelText: 'Título',
              prefixIcon: const Icon(Icons.title),
              requiredField: true,
              validator: (value) => value == null || value.trim().isEmpty
                  ? 'Ingrese un título'
                  : null,
            ),
            const SizedBox(height: AppSpacing.sm),
            AppTextField(
              controller: _descripcionController,
              labelText: 'Descripción (opcional)',
              prefixIcon: const Icon(Icons.description_outlined),
              maxLines: 2,
            ),
            const SizedBox(height: AppSpacing.sm),
            AppButton(
              variant: AppButtonVariant.secondary,
              expanded: true,
              onPressed: () async {
                final result = await showWorkforceSelector(
                  context: context,
                  assigneeId: _assigneeId,
                  teamId: _workTeamId,
                  collaboratorIds: _collaboratorIds,
                );
                if (result == null || !mounted) return;
                setState(() {
                  _assigneeId = result.assigneeId;
                  _workTeamId = result.teamId;
                  _collaboratorIds = result.collaboratorIds;
                });
              },
              icon: Icons.assignment_ind_outlined,
              label: _assigneeId == null && _workTeamId == null
                  ? 'Asignar responsable / cuadrilla'
                  : 'Asignación configurada · ${_collaboratorIds.length} colaborador(es)',
            ),
            const SizedBox(height: AppSpacing.sm),
            AppButton(
              variant: AppButtonVariant.secondary,
              expanded: true,
              onPressed: () async {
                final result = await showAgendaAnimalSelector(
                  context,
                  initialAnimalIds: _selectedAnimalIds,
                  initialLoteIds: _selectedLoteIds,
                );
                if (result == null) return;
                setState(() {
                  _selectedAnimalIds = result.animalIds;
                  _selectedLoteIds = result.loteIds;
                });
              },
              icon: Icons.pets_outlined,
              label: totalSelected == 0
                  ? 'Seleccionar animales / lotes'
                  : '${_selectedAnimalIds.length} animal(es)  ·  ${_selectedLoteIds.length} lote(s)',
            ),
            const SizedBox(height: AppSpacing.sm),
            if (widget.locations.isEmpty)
              AppTextField(
                controller: _ubicacionController,
                labelText: 'Ubicación (opcional)',
                prefixIcon: const Icon(Icons.place_outlined),
                hintText: 'Ej: Potrero B',
              )
            else
              AppSelectField<String>(
                value: _locationUuid ?? '',
                items: [
                  '',
                  ...widget.locations.map((location) => location.uuid),
                ],
                itemLabel: (uuid) => uuid.isEmpty
                    ? 'Sin ubicación'
                    : widget.locations
                          .firstWhere((location) => location.uuid == uuid)
                          .name,
                onChanged: (value) => setState(
                  () => _locationUuid = value == null || value.isEmpty
                      ? null
                      : value,
                ),
                labelText: 'Ubicación (opcional)',
                prefixIcon: const Icon(Icons.place_outlined),
              ),
            const SizedBox(height: AppSpacing.sm),
            AppDateField(
              value: _fechaSeleccionada,
              labelText: 'Fecha programada',
              firstDate: DateTime.now().subtract(const Duration(days: 365)),
              lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
              onChanged: (picked) {
                if (picked == null) return;
                setState(() {
                  _fechaSeleccionada = DateTime(
                    picked.year,
                    picked.month,
                    picked.day,
                    _fechaSeleccionada.hour,
                    _fechaSeleccionada.minute,
                  );
                });
              },
            ),
            const SizedBox(height: AppSpacing.sm),
            AppButton(
              variant: AppButtonVariant.secondary,
              expanded: true,
              icon: Icons.schedule_outlined,
              label: _hasExplicitTime
                  ? 'Hora límite · ${DateFormat('HH:mm').format(_fechaSeleccionada)}'
                  : 'Sin hora · Añadir hora',
              onPressed: () async {
                final picked = await showTimePicker(
                  context: context,
                  initialTime: TimeOfDay.fromDateTime(_fechaSeleccionada),
                );
                if (picked == null) return;
                setState(() {
                  _hasExplicitTime = true;
                  _fechaSeleccionada = DateTime(
                    _fechaSeleccionada.year,
                    _fechaSeleccionada.month,
                    _fechaSeleccionada.day,
                    picked.hour,
                    picked.minute,
                  );
                });
              },
            ),
            if (_hasExplicitTime)
              TextButton(
                onPressed: () => setState(() {
                  _hasExplicitTime = false;
                  _fechaSeleccionada = DateTime(
                    _fechaSeleccionada.year,
                    _fechaSeleccionada.month,
                    _fechaSeleccionada.day,
                  );
                }),
                child: const Text('Quitar hora'),
              ),
            const SizedBox(height: AppSpacing.sm),
            AppSelectField<String>(
              value: _recurrenceRule ?? '',
              items: const ['', 'weekly', 'monthly'],
              itemLabel: (rule) => switch (rule) {
                '' => 'No repetir',
                'weekly' => 'Cada semana',
                'monthly' => 'Cada mes',
                _ => rule,
              },
              onChanged: (value) => setState(
                () => _recurrenceRule = value == null || value.isEmpty
                    ? null
                    : value,
              ),
              labelText: 'Repetición',
              prefixIcon: const Icon(Icons.repeat),
            ),
            const SizedBox(height: AppSpacing.sm),
            AppTextField(
              controller: _checklistController,
              labelText: 'Checklist (un paso por línea)',
              prefixIcon: const Icon(Icons.checklist_outlined),
              minLines: 2,
              maxLines: 5,
            ),
            const SizedBox(height: AppSpacing.sm),
            AppTextField(
              controller: _notasController,
              labelText: 'Notas adicionales (opcional)',
              prefixIcon: const Icon(Icons.sticky_note_2_outlined),
              maxLines: 2,
            ),
            const SizedBox(height: AppSpacing.md),
            AppButton(
              key: const ValueKey('agenda-task-save'),
              onPressed: _save,
              expanded: true,
              icon: Icons.save_alt,
              label: widget.entry == null
                  ? 'Guardar tarea'
                  : 'Actualizar tarea',
            ),
          ],
        ),
      ),
    );
  }
}
