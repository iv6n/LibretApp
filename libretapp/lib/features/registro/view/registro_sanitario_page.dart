import 'package:flutter/material.dart';
import 'package:libretapp/core/core.dart';
import 'package:libretapp/features/directorio/animales/application/bloc/index.dart';
import 'package:libretapp/features/directorio/animales/domain/animal_domain.dart'
    hide AnimalStatus;
import 'package:libretapp/features/directorio/animales/infrastructure/infrastructure.dart';
import 'package:libretapp/features/directorio/lotes/infrastructure/infrastructure.dart';
import 'package:libretapp/features/registro/widgets/animal_selector.dart';
import 'package:libretapp/l10n/app_localizations.dart';

class RegistroSanitarioPage extends StatefulWidget {
  const RegistroSanitarioPage({super.key});

  @override
  State<RegistroSanitarioPage> createState() => _RegistroSanitarioPageState();
}

class _RegistroSanitarioPageState extends State<RegistroSanitarioPage> {
  late final AnimalBloc _bloc;
  final _productCtrl = TextEditingController();
  final _doseCtrl = TextEditingController();
  final _appliedByCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();
  final _causeCtrl = TextEditingController();
  var _type = HealthRecordType.vaccine;
  var _date = DateTime.now();
  DateTime? _nextDate;
  AnimalEntity? _selectedAnimal;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _bloc = AnimalBloc(
      animalRepository: locator<AnimalRepository>(),
      lotesRepository: locator<LotesRepository>(),
    );
  }

  @override
  void dispose() {
    _bloc.close();
    _productCtrl.dispose();
    _doseCtrl.dispose();
    _appliedByCtrl.dispose();
    _notesCtrl.dispose();
    _causeCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    final l10n = AppLocalizations.of(context);

    if (_selectedAnimal == null) {
      messenger.showSnackBar(
        SnackBar(content: Text(l10n.detailFormAnimalRequired)),
      );
      return;
    }
    if (_productCtrl.text.trim().isEmpty) {
      messenger.showSnackBar(
        SnackBar(content: Text(l10n.detailFormHealthProductRequired)),
      );
      return;
    }
    if (_nextDate != null && _nextDate!.isBefore(_date)) {
      messenger.showSnackBar(
        SnackBar(content: Text(l10n.detailFormHealthNextAfterDate)),
      );
      return;
    }

    setState(() => _saving = true);

    final record = HealthRecord(
      date: _date,
      type: _type,
      product: _productCtrl.text.trim(),
      dose: _doseCtrl.text.trim().isEmpty ? null : _doseCtrl.text.trim(),
      appliedBy: _appliedByCtrl.text.trim().isEmpty
          ? null
          : _appliedByCtrl.text.trim(),
      notes: _notesCtrl.text.trim().isEmpty ? null : _notesCtrl.text.trim(),
      nextDueDate: _nextDate,
      cause: _causeCtrl.text.trim().isEmpty ? null : _causeCtrl.text.trim(),
    );

    _bloc.add(
      AddHealthRecord(animalUuid: _selectedAnimal!.uuid, record: record),
    );

    final nextState = await _bloc.stream.firstWhere(
      (s) => s.status != AnimalStatus.loading,
    );

    if (!mounted) return;
    setState(() => _saving = false);

    if (nextState.status == AnimalStatus.success) {
      navigator.pop();
      messenger.showSnackBar(
        SnackBar(content: Text(l10n.detailFormHealthSaved)),
      );
    } else {
      messenger.showSnackBar(
        SnackBar(content: Text(nextState.errorMessage ?? 'Error al guardar')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.detailFormHealthTitle)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AnimalSelector(
              selectedAnimal: _selectedAnimal,
              onSelected: (a) => setState(() => _selectedAnimal = a),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<HealthRecordType>(
              initialValue: _type,
              decoration: InputDecoration(
                labelText: l10n.detailFormHealthType,
                border: const OutlineInputBorder(),
              ),
              items: HealthRecordType.values
                  .map((t) => DropdownMenuItem(value: t, child: Text(t.name)))
                  .toList(),
              onChanged: (v) {
                if (v != null) setState(() => _type = v);
              },
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _productCtrl,
              decoration: InputDecoration(
                labelText: l10n.detailFormHealthProduct,
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _doseCtrl,
                    decoration: InputDecoration(
                      labelText: l10n.detailFormHealthDose,
                      border: const OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: _appliedByCtrl,
                    decoration: InputDecoration(
                      labelText: l10n.detailFormHealthAppliedBy,
                      border: const OutlineInputBorder(),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.today),
                    label: Text('${_date.year}-${_date.month}-${_date.day}'),
                    onPressed: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: _date,
                        firstDate: DateTime(_date.year - 5),
                        lastDate: DateTime(_date.year + 1),
                      );
                      if (picked != null) setState(() => _date = picked);
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.event_available),
                    label: Text(
                      _nextDate == null
                          ? l10n.detailFormHealthNext
                          : '${_nextDate!.year}-${_nextDate!.month}-${_nextDate!.day}',
                    ),
                    onPressed: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: _nextDate ?? _date,
                        firstDate: DateTime(_date.year),
                        lastDate: DateTime(_date.year + 5),
                      );
                      setState(() => _nextDate = picked);
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _causeCtrl,
              decoration: InputDecoration(
                labelText: l10n.detailFormHealthCause,
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _notesCtrl,
              decoration: InputDecoration(
                labelText: l10n.fieldNotes,
                border: const OutlineInputBorder(),
              ),
              maxLines: 2,
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: _saving ? null : _save,
                child: _saving
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Text(l10n.actionSave),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
