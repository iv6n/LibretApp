/// features \u203a ubicaciones \u203a widgets \u203a crop_sheets \u2014 bottom sheets for crop record management.
library;

import 'package:flutter/material.dart';
import 'package:libretapp/core/widgets/record_save_scope.dart';
import 'package:libretapp/core/core.dart';
import 'package:libretapp/core/utils/number_parsing.dart';
import 'package:libretapp/features/ubicaciones/domain/entities/crop_records.dart';
import 'package:libretapp/features/ubicaciones/domain/crop_template.dart';
import 'package:libretapp/features/ubicaciones/domain/enums/crop_growth_stage.dart';
import 'package:libretapp/features/ubicaciones/domain/enums/crop_status.dart';
import 'package:libretapp/features/ubicaciones/domain/enums/crop_task_type.dart';
import 'package:libretapp/theme/theme.dart';

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
  String? _templateKey;

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
    _templateKey = null;
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
    return AppFormBody(
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _SheetTitle(
              title: _isEditing ? 'Editar cultivo' : 'Nuevo cultivo',
              style: RecordFormStyle.crop,
              subtitle: widget.locationName,
            ),
            AppTextField(
              controller: _nameController,
              labelText: 'Nombre del cultivo',
              prefixIcon: const Icon(Icons.eco_outlined),
              requiredField: true,
              validator: (v) =>
                  v == null || v.trim().isEmpty ? 'Requerido' : null,
            ),
            const SizedBox(height: 12),
            AppTextField(
              controller: _varietyController,
              labelText: 'Variedad (opcional)',
              prefixIcon: const Icon(Icons.category_outlined),
            ),
            const SizedBox(height: 12),
            if (!_isEditing)
              DropdownButtonFormField<String?>(
                isExpanded: true,
                value: _templateKey,
                decoration: const InputDecoration(
                  labelText: 'Plantilla de manejo (opcional)',
                  prefixIcon: Icon(Icons.auto_awesome_outlined),
                ),
                items: [
                  const DropdownMenuItem<String?>(
                    value: null,
                    child: Text('Sin plantilla'),
                  ),
                  ...CropTemplateLibrary.templates.map(
                    (template) => DropdownMenuItem<String?>(
                      value: template.key,
                      child: Text('${template.name} · ${template.cycleType}'),
                    ),
                  ),
                ],
                onChanged: _applyTemplate,
              ),
            if (!_isEditing) const SizedBox(height: 12),
            AppTextField(
              controller: _surfaceController,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              labelText: 'Superficie (ha)',
              prefixIcon: const Icon(Icons.straighten_outlined),
            ),
            const SizedBox(height: 12),
            AppDateField(
              labelText: 'Fecha de siembra',
              value: _plantingDate,
              onChanged: (d) {
                if (d != null) setState(() => _plantingDate = d);
              },
            ),
            const SizedBox(height: AppSpacing.md),
            AppDateField(
              labelText: 'Cosecha esperada (opcional)',
              value: _expectedHarvestDate,
              emptyLabel: 'Sin fecha de cosecha',
              allowClear: true,
              clearTooltip: 'Borrar fecha',
              onChanged: (d) => setState(() => _expectedHarvestDate = d),
            ),
            const SizedBox(height: AppSpacing.md),
            AppSelectField<CropGrowthStage>(
              value: _stage,
              items: CropGrowthStage.values,
              itemLabel: (stage) => stage.displayName,
              labelText: 'Etapa de crecimiento',
              prefixIcon: const Icon(Icons.trending_up_outlined),
              onChanged: (v) => setState(() => _stage = v ?? _stage),
            ),
            const SizedBox(height: AppSpacing.md),
            if (_isEditing)
              AppSelectField<CropStatus>(
                value: _status,
                items: CropStatus.values,
                itemLabel: (status) => status.displayName,
                labelText: 'Estado',
                prefixIcon: const Icon(Icons.flag_outlined),
                onChanged: (v) => setState(() => _status = v ?? _status),
              ),
            if (_isEditing) const SizedBox(height: AppSpacing.md),
            AppTextField(
              controller: _frequencyController,
              keyboardType: TextInputType.number,
              labelText: 'Frecuencia de riego (días)',
              prefixIcon: const Icon(Icons.water_drop_outlined),
              validator: (v) {
                final n = int.tryParse(v ?? '');
                if (n == null || n < 1) return 'Mínimo 1 día';
                return null;
              },
            ),
            const SizedBox(height: AppSpacing.md),
            AppTextField(
              controller: _notesController,
              maxLines: 2,
              labelText: 'Notas (opcional)',
              prefixIcon: const Icon(Icons.notes_outlined),
            ),
            const SizedBox(height: AppSpacing.md),
            AppFormActions(
              saveLabel: _isEditing ? 'Guardar cambios' : 'Crear cultivo',
              onSave: _submit,
              onCancel: () => Navigator.of(context).pop(),
            ),
          ],
        ),
      ),
    );
  }

  void _applyTemplate(String? key) {
    final template = key == null ? null : CropTemplateLibrary.byKey(key);
    setState(() {
      _templateKey = key;
      if (template == null) return;
      _frequencyController.text = '${template.wateringFrequencyDays}';
      final harvestDays = template.expectedHarvestDays;
      _expectedHarvestDate = harvestDays == null
          ? null
          : _plantingDate.add(Duration(days: harvestDays));
    });
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
      surface: parseFormDouble(_surfaceController.text) ?? 0,
      notes: _notesController.text.trim().isEmpty
          ? null
          : _notesController.text.trim(),
      harvests: widget.initial?.harvests ?? const [],
      waterings: widget.initial?.waterings ?? const [],
      healthRecords: widget.initial?.healthRecords ?? const [],
      tasks: widget.initial?.tasks ?? const [],
    );
    submitRecordForm(context, crop);
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
  bool _isFinal = true;

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
    return AppFormBody(
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _SheetTitle(
              title: 'Registrar cosecha',
              style: RecordFormStyle.harvest,
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
                final n = parseFormDouble(v ?? '');
                if (n == null || n <= 0) return 'Ingresa un rendimiento';
                return null;
              },
            ),
            const SizedBox(height: 12),
            Wrap(
              crossAxisAlignment: WrapCrossAlignment.center,
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
            CheckboxListTile(
              value: _isFinal,
              onChanged: (value) => setState(() => _isFinal = value ?? true),
              contentPadding: EdgeInsets.zero,
              title: const Text('Cosecha final del ciclo'),
              subtitle: const Text(
                'Desactívalo para cultivos con varias cosechas.',
              ),
              controlAffinity: ListTileControlAffinity.leading,
            ),
            const SizedBox(height: 4),
            TextFormField(
              controller: _notesController,
              maxLines: 2,
              decoration: const InputDecoration(
                labelText: 'Notas (opcional)',
                prefixIcon: Icon(Icons.notes_outlined),
              ),
            ),
            const SizedBox(height: 16),
            AppFormActions(
              onSave: _submit,
              saveLabel: 'Guardar cosecha',
              onCancel: () => Navigator.of(context).pop(),
            ),
          ],
        ),
      ),
    );
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    final record = HarvestRecord(
      date: DateTime.now(),
      yieldKg: parseFormDouble(_yieldController.text)!,
      qualityRating: _quality,
      isFinal: _isFinal,
      notes: _notesController.text.trim().isEmpty
          ? null
          : _notesController.text.trim(),
    );
    submitRecordForm(context, record);
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
    return AppFormBody(
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _SheetTitle(
              title: 'Registrar riego',
              style: RecordFormStyle.watering,
              subtitle: widget.cropName,
            ),
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
              isExpanded: true,
              initialValue: _method,
              decoration: const InputDecoration(
                labelText: 'Método',
                prefixIcon: Icon(Icons.tune_outlined),
              ),
              items: const [
                DropdownMenuItem(value: 'manual', child: Text('Manual')),
                DropdownMenuItem(value: 'goteo', child: Text('Goteo')),
                DropdownMenuItem(value: 'aspersión', child: Text('Aspersión')),
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
            AppFormActions(
              onSave: _submit,
              saveLabel: 'Guardar riego',
              onCancel: () => Navigator.of(context).pop(),
            ),
          ],
        ),
      ),
    );
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    final record = CropWateringRecord(
      date: DateTime.now(),
      amountLiters: parseFormDouble(_amountController.text) ?? 0,
      method: _method,
      notes: _notesController.text.trim().isEmpty
          ? null
          : _notesController.text.trim(),
    );
    submitRecordForm(context, record);
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
    return AppFormBody(
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _SheetTitle(
              title: 'Registrar problema de salud',
              style: RecordFormStyle.cropHealth,
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
              isExpanded: true,
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
            AppFormActions(
              onSave: _submit,
              saveLabel: 'Guardar',
              onCancel: () => Navigator.of(context).pop(),
            ),
          ],
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
    submitRecordForm(context, record);
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
    return AppFormBody(
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _SheetTitle(
              title: 'Nueva tarea',
              style: RecordFormStyle.task,
              subtitle: widget.cropName,
            ),
            DropdownButtonFormField<CropTaskType>(
              isExpanded: true,
              initialValue: _type,
              decoration: const InputDecoration(
                labelText: 'Tipo de tarea',
                prefixIcon: Icon(Icons.task_outlined),
              ),
              items: CropTaskType.values
                  .map(
                    (t) =>
                        DropdownMenuItem(value: t, child: Text(t.displayName)),
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
            AppFormActions(
              onSave: _submit,
              saveLabel: 'Crear tarea',
              onCancel: () => Navigator.of(context).pop(),
            ),
          ],
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
    submitRecordForm(context, task);
  }
}

// ── Shared widgets ──────────────────────────────────────────────────────

class _SheetTitle extends StatelessWidget {
  const _SheetTitle({
    required this.title,
    required this.subtitle,
    required this.style,
  });

  final String title;
  final String subtitle;
  final RecordFormStyle style;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: AppRecordHeader(style: style, title: title),
            ),
            IconButton(
              tooltip: 'Cerrar',
              onPressed: () => Navigator.of(context).pop(),
              icon: const Icon(Icons.close),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(subtitle, style: Theme.of(context).textTheme.bodyMedium),
        const SizedBox(height: AppSpacing.md),
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
