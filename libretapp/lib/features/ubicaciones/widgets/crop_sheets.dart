/// features \u203a ubicaciones \u203a widgets \u203a crop_sheets \u2014 bottom sheets for crop record management.
library;

import 'package:flutter/material.dart';
import 'package:libretapp/features/ubicaciones/domain/entities/crop_records.dart';
import 'package:libretapp/features/ubicaciones/domain/enums/crop_growth_stage.dart';
import 'package:libretapp/features/ubicaciones/domain/enums/crop_status.dart';
import 'package:libretapp/features/ubicaciones/domain/enums/crop_task_type.dart';

// ── Add / Edit Crop Sheet ──────────────────────────────────────────────

class CropFormSheet extends StatefulWidget {
  const CropFormSheet({super.key, required this.locationName, this.initial});

  final String locationName;
  final CropRecord? initial;

  @override
  State<CropFormSheet> createState() => _CropFormSheetState();
}

class _CropFormSheetState extends State<CropFormSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _varietyController;
  late final TextEditingController _surfaceController;
  late final TextEditingController _frequencyController;
  late final TextEditingController _notesController;
  late CropGrowthStage _stage;
  late CropStatus _status;
  DateTime _plantingDate = DateTime.now();
  DateTime? _expectedHarvestDate;

  bool get _isEditing => widget.initial != null;

  @override
  void initState() {
    super.initState();
    final c = widget.initial;
    _nameController = TextEditingController(text: c?.cropName ?? '');
    _varietyController = TextEditingController(text: c?.variety ?? '');
    _surfaceController = TextEditingController(
      text: c != null && c.surface > 0 ? c.surface.toString() : '',
    );
    _frequencyController = TextEditingController(
      text: '${c?.wateringFrequencyDays ?? 3}',
    );
    _notesController = TextEditingController(text: c?.notes ?? '');
    _stage = c?.growthStage ?? CropGrowthStage.planted;
    _status = c?.status ?? CropStatus.active;
    _plantingDate = c?.plantingDate ?? DateTime.now();
    _expectedHarvestDate = c?.expectedHarvestDate;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _varietyController.dispose();
    _surfaceController.dispose();
    _frequencyController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).viewInsets.bottom;
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(20, 16, 20, 16 + bottom),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _SheetTitle(
                  title: _isEditing ? 'Editar cultivo' : 'Nuevo cultivo',
                  subtitle: widget.locationName,
                ),
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Nombre del cultivo',
                    prefixIcon: Icon(Icons.eco_outlined),
                  ),
                  validator: (v) =>
                      v == null || v.trim().isEmpty ? 'Requerido' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _varietyController,
                  decoration: const InputDecoration(
                    labelText: 'Variedad (opcional)',
                    prefixIcon: Icon(Icons.category_outlined),
                  ),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _surfaceController,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: const InputDecoration(
                    labelText: 'Superficie (ha)',
                    prefixIcon: Icon(Icons.straighten_outlined),
                  ),
                ),
                const SizedBox(height: 12),
                _DatePickerField(
                  label: 'Fecha de siembra',
                  value: _plantingDate,
                  onChanged: (d) => setState(() => _plantingDate = d),
                ),
                const SizedBox(height: 12),
                _DatePickerField(
                  label: 'Cosecha esperada (opcional)',
                  value: _expectedHarvestDate,
                  onChanged: (d) => setState(() => _expectedHarvestDate = d),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<CropGrowthStage>(
                  initialValue: _stage,
                  decoration: const InputDecoration(
                    labelText: 'Etapa de crecimiento',
                    prefixIcon: Icon(Icons.trending_up_outlined),
                  ),
                  items: CropGrowthStage.values
                      .map(
                        (s) => DropdownMenuItem(
                          value: s,
                          child: Text(s.displayName),
                        ),
                      )
                      .toList(),
                  onChanged: (v) => setState(() => _stage = v ?? _stage),
                ),
                const SizedBox(height: 12),
                if (_isEditing)
                  DropdownButtonFormField<CropStatus>(
                    initialValue: _status,
                    decoration: const InputDecoration(
                      labelText: 'Estado',
                      prefixIcon: Icon(Icons.flag_outlined),
                    ),
                    items: CropStatus.values
                        .map(
                          (s) => DropdownMenuItem(
                            value: s,
                            child: Text(s.displayName),
                          ),
                        )
                        .toList(),
                    onChanged: (v) => setState(() => _status = v ?? _status),
                  ),
                if (_isEditing) const SizedBox(height: 12),
                TextFormField(
                  controller: _frequencyController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Frecuencia de riego (días)',
                    prefixIcon: Icon(Icons.water_drop_outlined),
                  ),
                  validator: (v) {
                    final n = int.tryParse(v ?? '');
                    if (n == null || n < 1) return 'Mínimo 1 día';
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _notesController,
                  maxLines: 2,
                  decoration: const InputDecoration(
                    labelText: 'Notas (opcional)',
                    prefixIcon: Icon(Icons.notes_outlined),
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    icon: const Icon(Icons.save_outlined),
                    label: Text(
                      _isEditing ? 'Guardar cambios' : 'Crear cultivo',
                    ),
                    onPressed: _submit,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    final crop = CropRecord(
      uuid: widget.initial?.uuid,
      cropName: _nameController.text.trim(),
      variety: _varietyController.text.trim(),
      plantingDate: _plantingDate,
      expectedHarvestDate: _expectedHarvestDate,
      growthStage: _stage,
      wateringFrequencyDays: int.parse(_frequencyController.text),
      lastWateredDate: widget.initial?.lastWateredDate,
      status: _status,
      surface: double.tryParse(_surfaceController.text) ?? 0,
      notes: _notesController.text.trim().isEmpty
          ? null
          : _notesController.text.trim(),
      harvests: widget.initial?.harvests ?? const [],
      waterings: widget.initial?.waterings ?? const [],
      healthRecords: widget.initial?.healthRecords ?? const [],
      tasks: widget.initial?.tasks ?? const [],
    );
    Navigator.of(context).pop(crop);
  }
}

// ── Harvest Sheet ───────────────────────────────────────────────────────

class HarvestFormSheet extends StatefulWidget {
  const HarvestFormSheet({super.key, required this.cropName});

  final String cropName;

  @override
  State<HarvestFormSheet> createState() => _HarvestFormSheetState();
}

class _HarvestFormSheetState extends State<HarvestFormSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _yieldController;
  late final TextEditingController _notesController;
  int _quality = 3;

  @override
  void initState() {
    super.initState();
    _yieldController = TextEditingController();
    _notesController = TextEditingController();
  }

  @override
  void dispose() {
    _yieldController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).viewInsets.bottom;
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(20, 16, 20, 16 + bottom),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _SheetTitle(
                title: 'Registrar cosecha',
                subtitle: widget.cropName,
              ),
              TextFormField(
                controller: _yieldController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: const InputDecoration(
                  labelText: 'Rendimiento (kg)',
                  prefixIcon: Icon(Icons.scale_outlined),
                ),
                validator: (v) {
                  final n = double.tryParse(v ?? '');
                  if (n == null || n <= 0) return 'Ingresa un rendimiento';
                  return null;
                },
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  const Icon(Icons.star_outline, size: 20),
                  const SizedBox(width: 8),
                  const Text('Calidad:'),
                  const SizedBox(width: 8),
                  ...List.generate(5, (i) {
                    final star = i + 1;
                    return IconButton(
                      icon: Icon(
                        star <= _quality ? Icons.star : Icons.star_border,
                        color: star <= _quality ? Colors.amber : null,
                      ),
                      onPressed: () => setState(() => _quality = star),
                    );
                  }),
                ],
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _notesController,
                maxLines: 2,
                decoration: const InputDecoration(
                  labelText: 'Notas (opcional)',
                  prefixIcon: Icon(Icons.notes_outlined),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  icon: const Icon(Icons.save_outlined),
                  label: const Text('Guardar cosecha'),
                  onPressed: _submit,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    final record = HarvestRecord(
      date: DateTime.now(),
      yieldKg: double.parse(_yieldController.text),
      qualityRating: _quality,
      notes: _notesController.text.trim().isEmpty
          ? null
          : _notesController.text.trim(),
    );
    Navigator.of(context).pop(record);
  }
}

// ── Crop Watering Sheet ─────────────────────────────────────────────────

class CropWateringFormSheet extends StatefulWidget {
  const CropWateringFormSheet({super.key, required this.cropName});

  final String cropName;

  @override
  State<CropWateringFormSheet> createState() => _CropWateringFormSheetState();
}

class _CropWateringFormSheetState extends State<CropWateringFormSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _amountController;
  late final TextEditingController _notesController;
  String _method = 'manual';

  @override
  void initState() {
    super.initState();
    _amountController = TextEditingController();
    _notesController = TextEditingController();
  }

  @override
  void dispose() {
    _amountController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).viewInsets.bottom;
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(20, 16, 20, 16 + bottom),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _SheetTitle(title: 'Registrar riego', subtitle: widget.cropName),
              TextFormField(
                controller: _amountController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: const InputDecoration(
                  labelText: 'Litros (opcional)',
                  prefixIcon: Icon(Icons.water_drop_outlined),
                ),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: _method,
                decoration: const InputDecoration(
                  labelText: 'Método',
                  prefixIcon: Icon(Icons.tune_outlined),
                ),
                items: const [
                  DropdownMenuItem(value: 'manual', child: Text('Manual')),
                  DropdownMenuItem(value: 'goteo', child: Text('Goteo')),
                  DropdownMenuItem(
                    value: 'aspersión',
                    child: Text('Aspersión'),
                  ),
                ],
                onChanged: (v) => setState(() => _method = v ?? 'manual'),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _notesController,
                maxLines: 2,
                decoration: const InputDecoration(
                  labelText: 'Notas (opcional)',
                  prefixIcon: Icon(Icons.notes_outlined),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  icon: const Icon(Icons.save_outlined),
                  label: const Text('Guardar riego'),
                  onPressed: _submit,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    final record = CropWateringRecord(
      date: DateTime.now(),
      amountLiters: double.tryParse(_amountController.text) ?? 0,
      method: _method,
      notes: _notesController.text.trim().isEmpty
          ? null
          : _notesController.text.trim(),
    );
    Navigator.of(context).pop(record);
  }
}

// ── Crop Health Sheet ───────────────────────────────────────────────────

class CropHealthFormSheet extends StatefulWidget {
  const CropHealthFormSheet({super.key, required this.cropName});

  final String cropName;

  @override
  State<CropHealthFormSheet> createState() => _CropHealthFormSheetState();
}

class _CropHealthFormSheetState extends State<CropHealthFormSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _issueController;
  late final TextEditingController _treatmentController;
  late final TextEditingController _notesController;
  String _severity = 'media';

  @override
  void initState() {
    super.initState();
    _issueController = TextEditingController();
    _treatmentController = TextEditingController();
    _notesController = TextEditingController();
  }

  @override
  void dispose() {
    _issueController.dispose();
    _treatmentController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).viewInsets.bottom;
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(20, 16, 20, 16 + bottom),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _SheetTitle(
                title: 'Registrar problema de salud',
                subtitle: widget.cropName,
              ),
              TextFormField(
                controller: _issueController,
                decoration: const InputDecoration(
                  labelText: 'Problema (plaga, enfermedad, etc.)',
                  prefixIcon: Icon(Icons.bug_report_outlined),
                ),
                validator: (v) =>
                    v == null || v.trim().isEmpty ? 'Requerido' : null,
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: _severity,
                decoration: const InputDecoration(
                  labelText: 'Severidad',
                  prefixIcon: Icon(Icons.warning_amber_outlined),
                ),
                items: const [
                  DropdownMenuItem(value: 'baja', child: Text('Baja')),
                  DropdownMenuItem(value: 'media', child: Text('Media')),
                  DropdownMenuItem(value: 'alta', child: Text('Alta')),
                ],
                onChanged: (v) => setState(() => _severity = v ?? 'media'),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _treatmentController,
                decoration: const InputDecoration(
                  labelText: 'Tratamiento aplicado (opcional)',
                  prefixIcon: Icon(Icons.medical_services_outlined),
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _notesController,
                maxLines: 2,
                decoration: const InputDecoration(
                  labelText: 'Notas (opcional)',
                  prefixIcon: Icon(Icons.notes_outlined),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  icon: const Icon(Icons.save_outlined),
                  label: const Text('Guardar'),
                  onPressed: _submit,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    final record = CropHealthRecord(
      date: DateTime.now(),
      issue: _issueController.text.trim(),
      treatment: _treatmentController.text.trim(),
      severity: _severity,
      notes: _notesController.text.trim().isEmpty
          ? null
          : _notesController.text.trim(),
    );
    Navigator.of(context).pop(record);
  }
}

// ── Crop Task Sheet ─────────────────────────────────────────────────────

class CropTaskFormSheet extends StatefulWidget {
  const CropTaskFormSheet({super.key, required this.cropName});

  final String cropName;

  @override
  State<CropTaskFormSheet> createState() => _CropTaskFormSheetState();
}

class _CropTaskFormSheetState extends State<CropTaskFormSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _notesController;
  CropTaskType _type = CropTaskType.water;
  DateTime _dueDate = DateTime.now().add(const Duration(days: 1));

  @override
  void initState() {
    super.initState();
    _notesController = TextEditingController();
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).viewInsets.bottom;
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(20, 16, 20, 16 + bottom),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _SheetTitle(title: 'Nueva tarea', subtitle: widget.cropName),
              DropdownButtonFormField<CropTaskType>(
                initialValue: _type,
                decoration: const InputDecoration(
                  labelText: 'Tipo de tarea',
                  prefixIcon: Icon(Icons.task_outlined),
                ),
                items: CropTaskType.values
                    .map(
                      (t) => DropdownMenuItem(
                        value: t,
                        child: Text(t.displayName),
                      ),
                    )
                    .toList(),
                onChanged: (v) => setState(() => _type = v ?? _type),
              ),
              const SizedBox(height: 12),
              _DatePickerField(
                label: 'Fecha límite',
                value: _dueDate,
                onChanged: (d) => setState(() => _dueDate = d),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _notesController,
                maxLines: 2,
                decoration: const InputDecoration(
                  labelText: 'Notas (opcional)',
                  prefixIcon: Icon(Icons.notes_outlined),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  icon: const Icon(Icons.save_outlined),
                  label: const Text('Crear tarea'),
                  onPressed: _submit,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    final task = CropTask(
      type: _type,
      dueDate: _dueDate,
      notes: _notesController.text.trim().isEmpty
          ? null
          : _notesController.text.trim(),
    );
    Navigator.of(context).pop(task);
  }
}

// ── Shared widgets ──────────────────────────────────────────────────────

class _SheetTitle extends StatelessWidget {
  const _SheetTitle({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                title,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            IconButton(
              onPressed: () => Navigator.of(context).pop(),
              icon: const Icon(Icons.close),
            ),
          ],
        ),
        Text(
          subtitle,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 12),
      ],
    );
  }
}

class _DatePickerField extends StatelessWidget {
  const _DatePickerField({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  final String label;
  final DateTime? value;
  final ValueChanged<DateTime> onChanged;

  @override
  Widget build(BuildContext context) {
    final display = value != null
        ? '${value!.day}/${value!.month}/${value!.year}'
        : 'Seleccionar';
    return InkWell(
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: value ?? DateTime.now(),
          firstDate: DateTime(2020),
          lastDate: DateTime(2040),
        );
        if (picked != null) onChanged(picked);
      },
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: const Icon(Icons.calendar_today_outlined),
        ),
        child: Text(display),
      ),
    );
  }
}
