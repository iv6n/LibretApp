/// features › ubicaciones › view › location_record_sheets — form sheets for recording location events.
library;

import 'package:libretapp/core/utils/number_parsing.dart';


import 'package:flutter/material.dart';
import 'package:libretapp/core/widgets/record_save_scope.dart';
import 'package:libretapp/features/ubicaciones/domain/entities/location_records.dart';
import 'package:libretapp/features/ubicaciones/domain/enums/water_type.dart';

// ─── Shared header ────────────────────────────────────────────────────────────

class _SheetHeader extends StatelessWidget {
  const _SheetHeader({required this.title, required this.subtitle});

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

// ─── Visit ────────────────────────────────────────────────────────────────────

class VisitRecordSheet extends StatefulWidget {
  const VisitRecordSheet({super.key, required this.locationName});

  final String locationName;

  @override
  State<VisitRecordSheet> createState() => _VisitRecordSheetState();
}

class _VisitRecordSheetState extends State<VisitRecordSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _animalsController;
  late final TextEditingController _notesController;
  late final TextEditingController _userController;

  @override
  void initState() {
    super.initState();
    _animalsController = TextEditingController();
    _notesController = TextEditingController();
    _userController = TextEditingController();
  }

  @override
  void dispose() {
    _animalsController.dispose();
    _notesController.dispose();
    _userController.dispose();
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
              _SheetHeader(
                title: 'Registrar visita',
                subtitle: widget.locationName,
              ),
              TextFormField(
                controller: _animalsController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Animales observados',
                  prefixIcon: Icon(Icons.groups_outlined),
                ),
                validator: (value) {
                  final parsed = int.tryParse(value ?? '');
                  if (parsed == null || parsed < 0) {
                    return 'Ingresa un número válido';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _userController,
                decoration: const InputDecoration(
                  labelText: 'Responsable (opcional)',
                  prefixIcon: Icon(Icons.badge_outlined),
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _notesController,
                maxLines: 3,
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
                  label: const Text('Guardar visita'),
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
    final animals = int.parse(_animalsController.text);
    final record = VisitRecord(
      date: DateTime.now(),
      animals: animals,
      notes: _notesController.text.trim().isEmpty
          ? null
          : _notesController.text.trim(),
      user: _userController.text.trim().isEmpty
          ? null
          : _userController.text.trim(),
    );
    submitRecordForm(context, record);
  }
}

// ─── Water ────────────────────────────────────────────────────────────────────

class WaterRecordSheet extends StatefulWidget {
  const WaterRecordSheet({super.key, required this.locationName});

  final String locationName;

  @override
  State<WaterRecordSheet> createState() => _WaterRecordSheetState();
}

class _WaterRecordSheetState extends State<WaterRecordSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _levelController;
  late final TextEditingController _notesController;
  WaterType _type = WaterType.well;

  @override
  void initState() {
    super.initState();
    _levelController = TextEditingController();
    _notesController = TextEditingController();
  }

  @override
  void dispose() {
    _levelController.dispose();
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
              _SheetHeader(
                title: 'Registrar agua',
                subtitle: widget.locationName,
              ),
              TextFormField(
                controller: _levelController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: const InputDecoration(
                  labelText: 'Nivel (%)',
                  prefixIcon: Icon(Icons.water_drop_outlined),
                ),
                validator: (value) {
                  final parsed = parseFormDouble(value ?? '');
                  if (parsed == null || parsed < 0) return 'Ingresa un nivel';
                  return null;
                },
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<WaterType>(
                initialValue: _type,
                decoration: const InputDecoration(
                  labelText: 'Tipo de agua',
                  prefixIcon: Icon(Icons.tune),
                ),
                items: WaterType.values
                    .map(
                      (type) => DropdownMenuItem(
                        value: type,
                        child: Text(_capitalize(type.name)),
                      ),
                    )
                    .toList(),
                onChanged: (value) =>
                    setState(() => _type = value ?? WaterType.well),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _notesController,
                maxLines: 3,
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
                  label: const Text('Guardar agua'),
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
    final level = double.parse(_levelController.text);
    final record = WaterRecord(
      date: DateTime.now(),
      level: level,
      type: _type,
      notes: _notesController.text.trim().isEmpty
          ? null
          : _notesController.text.trim(),
    );
    submitRecordForm(context, record);
  }
}

// ─── Salt ─────────────────────────────────────────────────────────────────────

class SaltRecordSheet extends StatefulWidget {
  const SaltRecordSheet({super.key, required this.locationName});

  final String locationName;

  @override
  State<SaltRecordSheet> createState() => _SaltRecordSheetState();
}

class _SaltRecordSheetState extends State<SaltRecordSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _quantityController;
  late final TextEditingController _notesController;

  @override
  void initState() {
    super.initState();
    _quantityController = TextEditingController();
    _notesController = TextEditingController();
  }

  @override
  void dispose() {
    _quantityController.dispose();
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
              _SheetHeader(
                title: 'Registrar sal/mineral',
                subtitle: widget.locationName,
              ),
              TextFormField(
                controller: _quantityController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: const InputDecoration(
                  labelText: 'Cantidad (kg)',
                  prefixIcon: Icon(Icons.scatter_plot_outlined),
                ),
                validator: (value) {
                  final parsed = parseFormDouble(value ?? '');
                  if (parsed == null || parsed < 0) {
                    return 'Ingresa una cantidad';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _notesController,
                maxLines: 3,
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
                  label: const Text('Guardar sal/mineral'),
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
    final qty = double.parse(_quantityController.text);
    final record = SaltRecord(
      date: DateTime.now(),
      quantityKg: qty,
      notes: _notesController.text.trim().isEmpty
          ? null
          : _notesController.text.trim(),
    );
    submitRecordForm(context, record);
  }
}

// ─── Shade ────────────────────────────────────────────────────────────────────

class ShadeRecordSheet extends StatefulWidget {
  const ShadeRecordSheet({super.key, required this.locationName});

  final String locationName;

  @override
  State<ShadeRecordSheet> createState() => _ShadeRecordSheetState();
}

class _ShadeRecordSheetState extends State<ShadeRecordSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _percentController;
  late final TextEditingController _conditionController;
  late final TextEditingController _notesController;

  @override
  void initState() {
    super.initState();
    _percentController = TextEditingController();
    _conditionController = TextEditingController();
    _notesController = TextEditingController();
  }

  @override
  void dispose() {
    _percentController.dispose();
    _conditionController.dispose();
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
              _SheetHeader(
                title: 'Registrar sombra',
                subtitle: widget.locationName,
              ),
              TextFormField(
                controller: _percentController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: const InputDecoration(
                  labelText: 'Cobertura (%)',
                  prefixIcon: Icon(Icons.park_outlined),
                ),
                validator: (value) {
                  final parsed = parseFormDouble(value ?? '');
                  if (parsed == null || parsed < 0) {
                    return 'Ingresa un porcentaje';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _conditionController,
                decoration: const InputDecoration(
                  labelText: 'Condición / infraestructura',
                  prefixIcon: Icon(Icons.nature_outlined),
                ),
                validator: (value) => value == null || value.trim().isEmpty
                    ? 'Ingresa una condición'
                    : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _notesController,
                maxLines: 3,
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
                  label: const Text('Guardar sombra'),
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
    final percent = double.parse(_percentController.text);
    final record = ShadeRecord(
      date: DateTime.now(),
      shadePercent: percent,
      condition: _conditionController.text.trim(),
      notes: _notesController.text.trim().isEmpty
          ? null
          : _notesController.text.trim(),
    );
    submitRecordForm(context, record);
  }
}

// ─── Pasture ──────────────────────────────────────────────────────────────────

class PastureRecordSheet extends StatefulWidget {
  const PastureRecordSheet({super.key, required this.locationName});

  final String locationName;

  @override
  State<PastureRecordSheet> createState() => _PastureRecordSheetState();
}

class _PastureRecordSheetState extends State<PastureRecordSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _grassController;
  late final TextEditingController _conditionController;
  late final TextEditingController _capacityController;

  @override
  void initState() {
    super.initState();
    _grassController = TextEditingController();
    _conditionController = TextEditingController();
    _capacityController = TextEditingController();
  }

  @override
  void dispose() {
    _grassController.dispose();
    _conditionController.dispose();
    _capacityController.dispose();
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
              _SheetHeader(
                title: 'Registrar pastura',
                subtitle: widget.locationName,
              ),
              TextFormField(
                controller: _grassController,
                decoration: const InputDecoration(
                  labelText: 'Tipo de pasto',
                  prefixIcon: Icon(Icons.grass_outlined),
                ),
                validator: (value) => value == null || value.trim().isEmpty
                    ? 'Ingresa el tipo de pasto'
                    : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _conditionController,
                decoration: const InputDecoration(
                  labelText: 'Condición',
                  prefixIcon: Icon(Icons.brightness_medium_outlined),
                ),
                validator: (value) => value == null || value.trim().isEmpty
                    ? 'Ingresa la condición'
                    : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _capacityController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: const InputDecoration(
                  labelText: 'Capacidad de carga (UA/ha)',
                  prefixIcon: Icon(Icons.timeline_outlined),
                ),
                validator: (value) {
                  final parsed = parseFormDouble(value ?? '');
                  if (parsed == null || parsed < 0) {
                    return 'Ingresa una capacidad';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  icon: const Icon(Icons.save_outlined),
                  label: const Text('Guardar pastura'),
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
    final record = PastureRecord(
      date: DateTime.now(),
      grassType: _grassController.text.trim(),
      condition: _conditionController.text.trim(),
      carryingCapacity: double.parse(_capacityController.text),
    );
    submitRecordForm(context, record);
  }
}

// ─── Cost ─────────────────────────────────────────────────────────────────────

class CostRecordSheet extends StatefulWidget {
  const CostRecordSheet({super.key, required this.locationName});

  final String locationName;

  @override
  State<CostRecordSheet> createState() => _CostRecordSheetState();
}

class _CostRecordSheetState extends State<CostRecordSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _maintenanceController;
  late final TextEditingController _fencesController;
  late final TextEditingController _repairsController;
  late final TextEditingController _laborController;
  late final TextEditingController _totalController;

  @override
  void initState() {
    super.initState();
    _maintenanceController = TextEditingController();
    _fencesController = TextEditingController();
    _repairsController = TextEditingController();
    _laborController = TextEditingController();
    _totalController = TextEditingController();
  }

  @override
  void dispose() {
    _maintenanceController.dispose();
    _fencesController.dispose();
    _repairsController.dispose();
    _laborController.dispose();
    _totalController.dispose();
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
              _SheetHeader(
                title: 'Registrar costo',
                subtitle: widget.locationName,
              ),
              _moneyField(
                _maintenanceController,
                'Mantenimiento',
                Icons.build_outlined,
              ),
              const SizedBox(height: 12),
              _moneyField(_fencesController, 'Cercas', Icons.fence_outlined),
              const SizedBox(height: 12),
              _moneyField(
                _repairsController,
                'Reparaciones',
                Icons.handyman_outlined,
              ),
              const SizedBox(height: 12),
              _moneyField(
                _laborController,
                'Mano de obra',
                Icons.badge_outlined,
              ),
              const SizedBox(height: 12),
              _moneyField(
                _totalController,
                'Total (opcional)',
                Icons.payments_outlined,
                required: false,
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  icon: const Icon(Icons.save_outlined),
                  label: const Text('Guardar costo'),
                  onPressed: _submit,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _moneyField(
    TextEditingController controller,
    String label,
    IconData icon, {
    bool required = true,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      decoration: InputDecoration(labelText: label, prefixIcon: Icon(icon)),
      validator: (value) {
        if (!required && (value == null || value.isEmpty)) return null;
        final parsed = parseFormDouble(value ?? '');
        if (parsed == null || parsed < 0) return 'Ingresa un monto';
        return null;
      },
    );
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    double parseOrZero(TextEditingController ctrl) =>
        parseFormDouble(ctrl.text.isEmpty ? '0' : ctrl.text) ?? 0;

    final maintenance = parseOrZero(_maintenanceController);
    final fences = parseOrZero(_fencesController);
    final repairs = parseOrZero(_repairsController);
    final labor = parseOrZero(_laborController);
    final total = _totalController.text.trim().isEmpty
        ? (maintenance + fences + repairs + labor)
        : (parseFormDouble(_totalController.text) ??
              maintenance + fences + repairs + labor);

    final record = LocationCostRecord(
      date: DateTime.now(),
      maintenance: maintenance,
      fences: fences,
      repairs: repairs,
      labor: labor,
      total: total,
    );

    submitRecordForm(context, record);
  }
}

// ─── Seeding ──────────────────────────────────────────────────────────────────

class SeedingRecordSheet extends StatefulWidget {
  const SeedingRecordSheet({super.key, required this.locationName});

  final String locationName;

  @override
  State<SeedingRecordSheet> createState() => _SeedingRecordSheetState();
}

class _SeedingRecordSheetState extends State<SeedingRecordSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _cropController;
  late final TextEditingController _surfaceController;
  late final TextEditingController _costController;

  @override
  void initState() {
    super.initState();
    _cropController = TextEditingController();
    _surfaceController = TextEditingController();
    _costController = TextEditingController();
  }

  @override
  void dispose() {
    _cropController.dispose();
    _surfaceController.dispose();
    _costController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _RecordFormScaffold(
      formKey: _formKey,
      title: 'Registrar siembra',
      subtitle: widget.locationName,
      fields: [
        TextFormField(
          controller: _cropController,
          decoration: const InputDecoration(
            labelText: 'Cultivo o variedad',
            prefixIcon: Icon(Icons.grass_outlined),
          ),
          validator: (value) => value == null || value.trim().isEmpty
              ? 'Ingresa el cultivo'
              : null,
        ),
        const SizedBox(height: 12),
        _numberField(
          controller: _surfaceController,
          label: 'Superficie (ha)',
          icon: Icons.square_foot_outlined,
        ),
        const SizedBox(height: 12),
        _numberField(
          controller: _costController,
          label: 'Costo (opcional)',
          icon: Icons.payments_outlined,
          required: false,
        ),
      ],
      onSubmit: () {
        if (!_formKey.currentState!.validate()) return;
        submitRecordForm(
          context,
          SeedingRecord(
            date: DateTime.now(),
            crop: _cropController.text.trim(),
            surface: _readDouble(_surfaceController),
            cost: _readDouble(_costController),
          ),
        );
      },
    );
  }
}

// ─── Irrigation ──────────────────────────────────────────────────────────────

class IrrigationRecordSheet extends StatefulWidget {
  const IrrigationRecordSheet({super.key, required this.locationName});

  final String locationName;

  @override
  State<IrrigationRecordSheet> createState() => _IrrigationRecordSheetState();
}

class _IrrigationRecordSheetState extends State<IrrigationRecordSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _durationController;
  late final TextEditingController _costController;
  String _type = 'Riego por gravedad';

  @override
  void initState() {
    super.initState();
    _durationController = TextEditingController();
    _costController = TextEditingController();
  }

  @override
  void dispose() {
    _durationController.dispose();
    _costController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _RecordFormScaffold(
      formKey: _formKey,
      title: 'Registrar riego',
      subtitle: widget.locationName,
      fields: [
        DropdownButtonFormField<String>(
          value: _type,
          decoration: const InputDecoration(
            labelText: 'Método',
            prefixIcon: Icon(Icons.waterfall_chart_outlined),
          ),
          items: const [
            DropdownMenuItem(
              value: 'Riego por gravedad',
              child: Text('Riego por gravedad'),
            ),
            DropdownMenuItem(value: 'Goteo', child: Text('Goteo')),
            DropdownMenuItem(value: 'Aspersión', child: Text('Aspersión')),
            DropdownMenuItem(value: 'Bomba', child: Text('Bomba')),
          ],
          onChanged: (value) => setState(() => _type = value ?? _type),
        ),
        const SizedBox(height: 12),
        _numberField(
          controller: _durationController,
          label: 'Duración (minutos)',
          icon: Icons.timer_outlined,
        ),
        const SizedBox(height: 12),
        _numberField(
          controller: _costController,
          label: 'Costo (opcional)',
          icon: Icons.payments_outlined,
          required: false,
        ),
      ],
      onSubmit: () {
        if (!_formKey.currentState!.validate()) return;
        submitRecordForm(
          context,
          IrrigationRecord(
            date: DateTime.now(),
            type: _type,
            duration: Duration(
              minutes: _readDouble(_durationController).round(),
            ),
            cost: _readDouble(_costController),
          ),
        );
      },
    );
  }
}

// ─── Rainfall ─────────────────────────────────────────────────────────────────

class RainRecordSheet extends StatefulWidget {
  const RainRecordSheet({super.key, required this.locationName});

  final String locationName;

  @override
  State<RainRecordSheet> createState() => _RainRecordSheetState();
}

class _RainRecordSheetState extends State<RainRecordSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _millimetersController;
  late final TextEditingController _gaugeController;

  @override
  void initState() {
    super.initState();
    _millimetersController = TextEditingController();
    _gaugeController = TextEditingController(text: widget.locationName);
  }

  @override
  void dispose() {
    _millimetersController.dispose();
    _gaugeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _RecordFormScaffold(
      formKey: _formKey,
      title: 'Registrar lluvia',
      subtitle: widget.locationName,
      fields: [
        _numberField(
          controller: _millimetersController,
          label: 'Lluvia (mm)',
          icon: Icons.umbrella_outlined,
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: _gaugeController,
          decoration: const InputDecoration(
            labelText: 'Pluviómetro o referencia',
            prefixIcon: Icon(Icons.place_outlined),
          ),
          validator: (value) => value == null || value.trim().isEmpty
              ? 'Indica dónde se midió'
              : null,
        ),
      ],
      onSubmit: () {
        if (!_formKey.currentState!.validate()) return;
        submitRecordForm(
          context,
          RainRecord(
            date: DateTime.now(),
            millimeters: _readDouble(_millimetersController),
            location: _gaugeController.text.trim(),
          ),
        );
      },
    );
  }
}

// ─── Maintenance ─────────────────────────────────────────────────────────────

class MaintenanceRecordSheet extends StatefulWidget {
  const MaintenanceRecordSheet({super.key, required this.locationName});

  final String locationName;

  @override
  State<MaintenanceRecordSheet> createState() => _MaintenanceRecordSheetState();
}

class _MaintenanceRecordSheetState extends State<MaintenanceRecordSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _assetController;
  late final TextEditingController _costController;
  late final TextEditingController _meterController;
  late final TextEditingController _notesController;
  String _type = 'Preventivo';
  String _meterUnit = 'Horas';
  DateTime? _nextDueDate;

  @override
  void initState() {
    super.initState();
    _assetController = TextEditingController();
    _costController = TextEditingController();
    _meterController = TextEditingController();
    _notesController = TextEditingController();
  }

  @override
  void dispose() {
    _assetController.dispose();
    _costController.dispose();
    _meterController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _RecordFormScaffold(
      formKey: _formKey,
      title: 'Registrar mantenimiento',
      subtitle: widget.locationName,
      fields: [
        TextFormField(
          controller: _assetController,
          decoration: const InputDecoration(
            labelText: 'Equipo o infraestructura',
            prefixIcon: Icon(Icons.handyman_outlined),
          ),
          validator: (value) => value == null || value.trim().isEmpty
              ? 'Indica qué se atendió'
              : null,
        ),
        const SizedBox(height: 12),
        DropdownButtonFormField<String>(
          value: _type,
          decoration: const InputDecoration(
            labelText: 'Tipo de servicio',
            prefixIcon: Icon(Icons.fact_check_outlined),
          ),
          items: const [
            DropdownMenuItem(value: 'Preventivo', child: Text('Preventivo')),
            DropdownMenuItem(value: 'Correctivo', child: Text('Correctivo')),
            DropdownMenuItem(value: 'Inspección', child: Text('Inspección')),
          ],
          onChanged: (value) => setState(() => _type = value ?? _type),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _numberField(
                controller: _meterController,
                label: 'Lectura de uso',
                icon: Icons.speed_outlined,
                required: false,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: DropdownButtonFormField<String>(
                value: _meterUnit,
                decoration: const InputDecoration(labelText: 'Unidad'),
                items: const [
                  DropdownMenuItem(value: 'Horas', child: Text('Horas')),
                  DropdownMenuItem(value: 'Km', child: Text('Km')),
                  DropdownMenuItem(value: 'Ciclos', child: Text('Ciclos')),
                ],
                onChanged: (value) =>
                    setState(() => _meterUnit = value ?? _meterUnit),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        OutlinedButton.icon(
          onPressed: _pickNextDueDate,
          icon: const Icon(Icons.event_available_outlined),
          label: Text(
            _nextDueDate == null
                ? 'Programar próxima revisión'
                : 'Próxima revisión: ${_nextDueDate!.day}/${_nextDueDate!.month}/${_nextDueDate!.year}',
          ),
        ),
        const SizedBox(height: 12),
        _numberField(
          controller: _costController,
          label: 'Costo (opcional)',
          icon: Icons.payments_outlined,
          required: false,
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
      ],
      onSubmit: () {
        if (!_formKey.currentState!.validate()) return;
        submitRecordForm(
          context,
          MaintenanceRecord(
            date: DateTime.now(),
            assetName: _assetController.text.trim(),
            maintenanceType: _type,
            nextDueDate: _nextDueDate,
            meterReading: _meterController.text.trim().isEmpty
                ? null
                : _readDouble(_meterController),
            meterUnit: _meterController.text.trim().isEmpty ? null : _meterUnit,
            cost: _readDouble(_costController),
            notes: _notesController.text.trim().isEmpty
                ? null
                : _notesController.text.trim(),
          ),
        );
      },
    );
  }

  Future<void> _pickNextDueDate() async {
    final date = await showDatePicker(
      context: context,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 3650)),
      initialDate: _nextDueDate ?? DateTime.now().add(const Duration(days: 90)),
    );
    if (date != null && mounted) setState(() => _nextDueDate = date);
  }
}

class _RecordFormScaffold extends StatelessWidget {
  const _RecordFormScaffold({
    required this.formKey,
    required this.title,
    required this.subtitle,
    required this.fields,
    required this.onSubmit,
  });

  final GlobalKey<FormState> formKey;
  final String title;
  final String subtitle;
  final List<Widget> fields;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).viewInsets.bottom;
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(20, 16, 20, 16 + bottom),
        child: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _SheetHeader(title: title, subtitle: subtitle),
              ...fields,
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: onSubmit,
                  icon: const Icon(Icons.save_outlined),
                  label: const Text('Guardar registro'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

Widget _numberField({
  required TextEditingController controller,
  required String label,
  required IconData icon,
  bool required = true,
}) {
  return TextFormField(
    controller: controller,
    keyboardType: const TextInputType.numberWithOptions(decimal: true),
    decoration: InputDecoration(labelText: label, prefixIcon: Icon(icon)),
    validator: (value) {
      final raw = value?.trim() ?? '';
      if (!required && raw.isEmpty) return null;
      final parsed = parseFormDouble(raw.replaceAll(',', '.'));
      if (parsed == null || parsed < 0) return 'Ingresa un número válido';
      return null;
    },
  );
}

double _readDouble(TextEditingController controller) =>
    parseFormDouble(controller.text.trim().replaceAll(',', '.')) ?? 0;

// ─── Helpers ──────────────────────────────────────────────────────────────────

String _capitalize(String value) {
  if (value.isEmpty) return value;
  return value[0].toUpperCase() + value.substring(1);
}
