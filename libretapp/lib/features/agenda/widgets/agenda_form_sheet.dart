/// features › agenda › widgets › agenda_form_sheet — bottom sheet form for creating/editing an agenda entry.
library;

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:libretapp/core/utils/id_generator.dart';
import 'package:libretapp/features/agenda/data/agenda_model.dart';
import 'package:libretapp/features/agenda/widgets/agenda_animal_selector_sheet.dart';
import 'package:libretapp/features/agenda/widgets/agenda_constants.dart';
import 'package:libretapp/features/agenda/widgets/agenda_workforce_sheet.dart';
import 'package:libretapp/features/ubicaciones/domain/entities/location_entity.dart';

Future<void> showAgendaFormSheet({
  required BuildContext context,
  required DateTime initialDate,
  required void Function(AgendaEntry) onSave,
  AgendaEntry? entry,
  List<LocationEntity> locations = const [],
}) async {
  await showModalBottomSheet<void>(
    context: context,
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
  late String _tipoSeleccionado;
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
    _tipoSeleccionado = widget.entry?.tipo ?? agendaTipos.first;
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
      for (final item in widget.entry?.checklist ?? const <AgendaChecklistItem>[])
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
      tipo: _tipoSeleccionado,
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
            Text(
              widget.entry == null ? 'Nueva tarea / evento' : 'Editar tarea',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 14),
            DropdownButtonFormField<String>(
              initialValue: _tipoSeleccionado,
              items: agendaTipos
                  .map(
                    (tipo) => DropdownMenuItem(value: tipo, child: Text(tipo)),
                  )
                  .toList(),
              onChanged: (value) {
                setState(() => _tipoSeleccionado = value ?? agendaTipos.first);
              },
              decoration: const InputDecoration(
                labelText: 'Tipo de tarea',
                prefixIcon: Icon(Icons.category_outlined),
              ),
            ),
            const SizedBox(height: 10),
            DropdownButtonFormField<String>(
              initialValue: _prioridad,
              items: const [
                DropdownMenuItem(value: AgendaPrioridad.baja, child: Text('Prioridad baja')),
                DropdownMenuItem(value: AgendaPrioridad.normal, child: Text('Prioridad normal')),
                DropdownMenuItem(value: AgendaPrioridad.alta, child: Text('Prioridad alta')),
                DropdownMenuItem(value: AgendaPrioridad.urgente, child: Text('Prioridad urgente')),
              ],
              onChanged: (value) => setState(() {
                _prioridad = value ?? AgendaPrioridad.normal;
              }),
              decoration: const InputDecoration(
                labelText: 'Prioridad',
                prefixIcon: Icon(Icons.flag_outlined),
              ),
            ),
            const SizedBox(height: 10),
            TextFormField(
              controller: _tituloController,
              decoration: const InputDecoration(
                labelText: 'Título',
                prefixIcon: Icon(Icons.title),
              ),
              validator: (v) =>
                  v == null || v.isEmpty ? 'Ingrese un título' : null,
            ),
            const SizedBox(height: 10),
            TextFormField(
              controller: _descripcionController,
              decoration: const InputDecoration(
                labelText: 'Descripción (opcional)',
                prefixIcon: Icon(Icons.description_outlined),
              ),
              maxLines: 2,
            ),
            const SizedBox(height: 10),
            OutlinedButton.icon(
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
              icon: const Icon(Icons.assignment_ind_outlined),
              label: Text(
                _assigneeId == null && _workTeamId == null
                    ? 'Asignar responsable / cuadrilla'
                    : 'Asignación configurada · ${_collaboratorIds.length} colaborador(es)',
              ),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(double.infinity, 48),
                alignment: Alignment.centerLeft,
              ),
            ),
            const SizedBox(height: 10),
            OutlinedButton.icon(
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
              icon: const Icon(Icons.pets_outlined),
              label: Text(
                totalSelected == 0
                    ? 'Seleccionar animales / lotes'
                    : '${_selectedAnimalIds.length} animal(es)  ·  ${_selectedLoteIds.length} lote(s)',
              ),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(double.infinity, 48),
                alignment: Alignment.centerLeft,
              ),
            ),
            const SizedBox(height: 10),
            if (widget.locations.isEmpty)
              TextFormField(
                controller: _ubicacionController,
                decoration: const InputDecoration(
                  labelText: 'Ubicación (opcional)',
                  prefixIcon: Icon(Icons.place_outlined),
                  hintText: 'Ej: Potrero B',
                ),
              )
            else
              DropdownButtonFormField<String?>(
                initialValue: _locationUuid,
                decoration: const InputDecoration(
                  labelText: 'Ubicación (opcional)',
                  prefixIcon: Icon(Icons.place_outlined),
                ),
                items: [
                  const DropdownMenuItem(
                    value: null,
                    child: Text('Sin ubicación'),
                  ),
                  ...widget.locations.map(
                    (l) => DropdownMenuItem(value: l.uuid, child: Text(l.name)),
                  ),
                ],
                onChanged: (value) => setState(() => _locationUuid = value),
              ),
            const SizedBox(height: 10),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.calendar_today),
              title: const Text('Fecha programada'),
              subtitle: Text(
                DateFormat('EEEE d MMMM, yyyy').format(_fechaSeleccionada),
              ),
              onTap: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: _fechaSeleccionada,
                  firstDate: DateTime.now().subtract(const Duration(days: 365)),
                  lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
                );
                if (picked != null) {
                  setState(() {
                    _fechaSeleccionada = DateTime(
                      picked.year,
                      picked.month,
                      picked.day,
                      _fechaSeleccionada.hour,
                      _fechaSeleccionada.minute,
                    );
                  });
                }
              },
            ),
            const SizedBox(height: 10),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.schedule_outlined),
              title: const Text('Hora límite'),
              subtitle: Text(DateFormat('HH:mm').format(_fechaSeleccionada)),
              onTap: () async {
                final picked = await showTimePicker(
                  context: context,
                  initialTime: TimeOfDay.fromDateTime(_fechaSeleccionada),
                );
                if (picked == null) return;
                setState(() {
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
            const SizedBox(height: 10),
            DropdownButtonFormField<String?>(
              initialValue: _recurrenceRule,
              decoration: const InputDecoration(
                labelText: 'Repetición',
                prefixIcon: Icon(Icons.repeat),
              ),
              items: const [
                DropdownMenuItem(value: null, child: Text('No repetir')),
                DropdownMenuItem(value: 'weekly', child: Text('Cada semana')),
                DropdownMenuItem(value: 'monthly', child: Text('Cada mes')),
              ],
              onChanged: (value) => setState(() => _recurrenceRule = value),
            ),
            const SizedBox(height: 10),
            TextFormField(
              controller: _checklistController,
              decoration: const InputDecoration(
                labelText: 'Checklist (un paso por línea)',
                prefixIcon: Icon(Icons.checklist_outlined),
                alignLabelWithHint: true,
              ),
              minLines: 2,
              maxLines: 5,
            ),
            const SizedBox(height: 10),
            TextFormField(
              controller: _notasController,
              decoration: const InputDecoration(
                labelText: 'Notas adicionales (opcional)',
                prefixIcon: Icon(Icons.sticky_note_2_outlined),
              ),
              maxLines: 2,
            ),
            const SizedBox(height: 18),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _save,
                icon: const Icon(Icons.save_alt),
                label: Text(
                  widget.entry == null ? 'Guardar tarea' : 'Actualizar tarea',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
