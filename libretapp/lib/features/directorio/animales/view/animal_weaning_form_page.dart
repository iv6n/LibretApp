library;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:libretapp/core/di/injection.dart';
import 'package:libretapp/core/widgets/widgets.dart';
import '../domain/animal_domain.dart';
import '../domain/repositories/weaning_record_repository.dart';
import '../infrastructure/animal_repository.dart';
import 'package:libretapp/features/registro/widgets/animal_selector.dart';
import 'package:libretapp/core/utils/number_parsing.dart';

class AnimalWeaningFormPage extends StatefulWidget {
  const AnimalWeaningFormPage({this.animalUuid, this.recordId, super.key});
  final String? animalUuid;
  final String? recordId;
  @override
  State<AnimalWeaningFormPage> createState() => _AnimalWeaningFormPageState();
}

class _AnimalWeaningFormPageState extends State<AnimalWeaningFormPage> {
  final _weight = TextEditingController();
  final _responsible = TextEditingController();
  final _notes = TextEditingController();
  final _form = GlobalKey<FormState>();
  DateTime _date = DateTime.now();
  WeightMethod _method = WeightMethod.scale;
  AnimalEntity? _animal;
  WeaningRecord? _record;
  bool _busy = false;
  bool _loading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    if (widget.animalUuid != null) _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final animal = await locator<AnimalRepository>().getByUuid(
        widget.animalUuid!,
      );
      if (animal == null) throw StateError('Animal no encontrado.');
      final records = await locator<WeaningRecordRepository>()
          .getWeaningRecords(animal.uuid);
      final record = widget.recordId == null
          ? null
          : records.where((r) => r.id == widget.recordId).firstOrNull;
      if (widget.recordId != null && record == null)
        throw StateError('El destete ya no existe.');
      if (!mounted) return;
      setState(() {
        _animal = animal;
        _record = record;
        _loading = false;
        if (record != null) {
          _date = record.date;
          _method = record.weightMethod;
          _weight.text = record.weightKg?.toString() ?? '';
          _responsible.text = record.performedBy ?? '';
          _notes.text = record.notes ?? '';
        }
      });
    } catch (error) {
      if (mounted)
        setState(() {
          _error = '$error';
          _loading = false;
        });
    }
  }

  Future<void> _save() async {
    if (_busy ||
        _loading ||
        _error != null ||
        !(_form.currentState?.validate() ?? false))
      return;
    final animal = _animal;
    if (animal == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Selecciona un bovino.')));
      return;
    }
    setState(() => _busy = true);
    try {
      final value = WeaningRecord(
        animalUuid: animal.uuid,
        date: _date,
        id: _record?.id,
        recordUuid: _record?.recordUuid,
        weightRecordUuid: _record?.weightRecordUuid,
        weightKg: parseFormDouble(_weight.text),
        weightMethod: _method,
        performedBy: _responsible.text.trim().isEmpty
            ? null
            : _responsible.text.trim(),
        notes: _notes.text.trim().isEmpty ? null : _notes.text.trim(),
      );
      final repo = locator<WeaningRecordRepository>();
      if (_record == null) {
        await repo.save(value);
      } else {
        await repo.updateRecord(animal.uuid, value);
      }
      if (mounted) context.pop(true);
    } catch (error) {
      if (mounted) {
        setState(() => _busy = false);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('$error')));
      }
    }
  }

  @override
  void dispose() {
    _weight.dispose();
    _responsible.dispose();
    _notes.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AppFormScaffold(
    recordStyle: RecordFormStyle.weaning,
    onCancel: () => Navigator.of(context).pop(),
    title: _record == null ? 'Registrar destete' : 'Corregir destete',
    formKey: _form,
    loading: _loading,
    saving: _busy,
    onSave: _save,
    saveLabel: 'Guardar',
    contextLabel: _animal == null ? null : primaryAnimalLabel(_animal!),
    fields: [
      if (_error != null) ...[
        Text(_error!),
        TextButton(onPressed: _load, child: const Text('Reintentar')),
      ],
      if (widget.animalUuid == null)
        AnimalSelector(
          selectedAnimal: _animal,
          eligible: (a) =>
              a.species == Species.cattle && a.status.isInActiveHerd,
          onSelected: (a) => setState(() => _animal = a),
        ),
      if (widget.animalUuid == null) const SizedBox(height: 16),
      AppDateField(
        value: _date,
        labelText: 'Fecha de destete',
        firstDate: DateTime(1900),
        lastDate: DateTime.now(),
        onChanged: (d) {
          if (d != null) setState(() => _date = d);
        },
      ),
      const SizedBox(height: 16),
      AppTextField(
        controller: _weight,
        labelText: 'Peso al destete (kg, opcional)',
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        validator: (v) {
          if (v == null || v.trim().isEmpty) return null;
          final weight = parseFormDouble(v);
          return weight == null || !weight.isFinite || weight <= 0
              ? 'Ingresa un peso positivo.'
              : null;
        },
      ),
      const SizedBox(height: 16),
      AppSelectField<WeightMethod>(
        value: _method,
        items: WeightMethod.values,
        labelText: 'Método del peso',
        itemLabel: (m) => m == WeightMethod.scale ? 'Báscula' : 'Estimado',
        onChanged: (m) {
          if (m != null) setState(() => _method = m);
        },
      ),
      const SizedBox(height: 16),
      AppTextField(controller: _responsible, labelText: 'Responsable'),
      const SizedBox(height: 16),
      AppTextField(controller: _notes, labelText: 'Notas', maxLines: 3),
    ],
  );
}
