import 'package:flutter/material.dart';
import 'package:libretapp/core/core.dart';
import 'package:libretapp/features/directorio/animales/application/bloc/index.dart';
import 'package:libretapp/features/directorio/animales/domain/animal_domain.dart'
    hide AnimalStatus;
import 'package:libretapp/features/directorio/animales/infrastructure/infrastructure.dart';
import 'package:libretapp/features/directorio/lotes/infrastructure/infrastructure.dart';
import 'package:libretapp/features/registro/widgets/animal_selector.dart';
import 'package:libretapp/l10n/app_localizations.dart';

class RegistroProduccionPage extends StatefulWidget {
  const RegistroProduccionPage({super.key});

  @override
  State<RegistroProduccionPage> createState() => _RegistroProduccionPageState();
}

class _RegistroProduccionPageState extends State<RegistroProduccionPage> {
  late final AnimalBloc _bloc;
  final _valueCtrl = TextEditingController();
  final _unitCtrl = TextEditingController();
  final _scoreCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();
  var _type = ProductionRecordType.weighing;
  var _date = DateTime.now();
  AnimalEntity? _selectedAnimal;
  bool _saving = false;

  double? _parseDouble(String raw) {
    final normalized = raw.trim().replaceAll(',', '.');
    if (normalized.isEmpty) {
      return null;
    }
    return double.tryParse(normalized);
  }

  int? _parseInt(String raw) {
    final normalized = raw.trim();
    if (normalized.isEmpty) {
      return null;
    }
    return int.tryParse(normalized);
  }

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
    _valueCtrl.dispose();
    _unitCtrl.dispose();
    _scoreCtrl.dispose();
    _notesCtrl.dispose();
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

    final rawValue = _valueCtrl.text.trim();
    final parsedValue = _parseDouble(rawValue);
    if (rawValue.isNotEmpty && parsedValue == null) {
      messenger.showSnackBar(
        SnackBar(content: Text(l10n.detailFormNumberInvalid)),
      );
      return;
    }
    if (parsedValue != null && parsedValue <= 0) {
      messenger.showSnackBar(
        SnackBar(content: Text(l10n.detailFormAmountPositive)),
      );
      return;
    }

    final rawScore = _scoreCtrl.text.trim();
    final parsedScore = _parseInt(rawScore);
    if (rawScore.isNotEmpty && parsedScore == null) {
      messenger.showSnackBar(
        SnackBar(content: Text(l10n.detailFormProductionScoreInvalid)),
      );
      return;
    }
    if (parsedScore != null && (parsedScore < 0 || parsedScore > 9)) {
      messenger.showSnackBar(
        SnackBar(content: Text(l10n.detailFormProductionScoreRange)),
      );
      return;
    }

    if (_type == ProductionRecordType.bodyConditionScore &&
        parsedScore == null) {
      messenger.showSnackBar(
        SnackBar(content: Text(l10n.detailFormProductionScoreRequired)),
      );
      return;
    }

    if ((_type == ProductionRecordType.weighing ||
            _type == ProductionRecordType.weightGain ||
            _type == ProductionRecordType.production) &&
        parsedValue == null) {
      messenger.showSnackBar(
        SnackBar(content: Text(l10n.detailFormProductionValueRequired)),
      );
      return;
    }

    final hasUnit = _unitCtrl.text.trim().isNotEmpty;
    final hasNotes = _notesCtrl.text.trim().isNotEmpty;
    if (_type == ProductionRecordType.fatteningStart &&
        parsedValue == null &&
        parsedScore == null &&
        !hasUnit &&
        !hasNotes) {
      messenger.showSnackBar(
        SnackBar(content: Text(l10n.detailFormProductionDataRequired)),
      );
      return;
    }

    if (_type == ProductionRecordType.fatteningEnd &&
        parsedValue == null &&
        parsedScore == null &&
        !hasUnit &&
        !hasNotes) {
      messenger.showSnackBar(
        SnackBar(content: Text(l10n.detailFormProductionDataRequired)),
      );
      return;
    }

    setState(() => _saving = true);

    final record = ProductionRecord(
      date: _date,
      type: _type,
      value: parsedValue,
      unit: _unitCtrl.text.trim().isEmpty ? null : _unitCtrl.text.trim(),
      score: parsedScore,
      notes: _notesCtrl.text.trim().isEmpty ? null : _notesCtrl.text.trim(),
    );

    _bloc.add(
      AddProductionRecord(animalUuid: _selectedAnimal!.uuid, record: record),
    );

    final nextState = await _bloc.stream.firstWhere(
      (s) => s.status != AnimalStatus.loading,
    );

    if (!mounted) return;
    setState(() => _saving = false);

    if (nextState.status == AnimalStatus.success) {
      navigator.pop();
      messenger.showSnackBar(
        SnackBar(content: Text(l10n.detailFormProductionSaved)),
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
      appBar: AppBar(title: Text(l10n.detailFormProductionTitle)),
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
            DropdownButtonFormField<ProductionRecordType>(
              initialValue: _type,
              decoration: InputDecoration(
                labelText: l10n.detailFormProductionType,
                border: const OutlineInputBorder(),
              ),
              items: ProductionRecordType.values
                  .map((t) => DropdownMenuItem(value: t, child: Text(t.name)))
                  .toList(),
              onChanged: (v) {
                if (v != null) setState(() => _type = v);
              },
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.event),
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
                  child: TextField(
                    controller: _valueCtrl,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: l10n.detailFormProductionValue,
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
                  child: TextField(
                    controller: _unitCtrl,
                    decoration: InputDecoration(
                      labelText: l10n.detailFormProductionUnit,
                      border: const OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: _scoreCtrl,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: l10n.detailFormProductionScore,
                      border: const OutlineInputBorder(),
                    ),
                  ),
                ),
              ],
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
