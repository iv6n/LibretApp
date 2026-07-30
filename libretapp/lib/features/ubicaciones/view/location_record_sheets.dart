/// features › ubicaciones › view › location_record_sheets — form sheets for recording location events.
library;

import 'package:flutter/material.dart';
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
    Navigator.of(context).pop(record);
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
                  final parsed = double.tryParse(value ?? '');
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
    Navigator.of(context).pop(record);
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
                  final parsed = double.tryParse(value ?? '');
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
    Navigator.of(context).pop(record);
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
                  final parsed = double.tryParse(value ?? '');
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
    Navigator.of(context).pop(record);
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
                  final parsed = double.tryParse(value ?? '');
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
    Navigator.of(context).pop(record);
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
        final parsed = double.tryParse(value ?? '');
        if (parsed == null || parsed < 0) return 'Ingresa un monto';
        return null;
      },
    );
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    double parseOrZero(TextEditingController ctrl) =>
        double.tryParse(ctrl.text.isEmpty ? '0' : ctrl.text) ?? 0;

    final maintenance = parseOrZero(_maintenanceController);
    final fences = parseOrZero(_fencesController);
    final repairs = parseOrZero(_repairsController);
    final labor = parseOrZero(_laborController);
    final total = _totalController.text.trim().isEmpty
        ? (maintenance + fences + repairs + labor)
        : (double.tryParse(_totalController.text) ??
              maintenance + fences + repairs + labor);

    final record = CostRecord(
      date: DateTime.now(),
      maintenance: maintenance,
      fences: fences,
      repairs: repairs,
      labor: labor,
      total: total,
    );

    Navigator.of(context).pop(record);
  }
}

// ─── Helpers ──────────────────────────────────────────────────────────────────

String _capitalize(String value) {
  if (value.isEmpty) return value;
  return value[0].toUpperCase() + value.substring(1);
}
