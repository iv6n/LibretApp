import 'package:flutter/material.dart';
import 'package:libretapp/core/core.dart';
import 'package:libretapp/features/directorio/animales/application/bloc/index.dart';
import 'package:libretapp/features/directorio/animales/domain/animal_domain.dart'
    hide AnimalStatus;
import 'package:libretapp/features/directorio/animales/infrastructure/infrastructure.dart';
import 'package:libretapp/features/directorio/lotes/infrastructure/infrastructure.dart';
import 'package:libretapp/features/registro/widgets/animal_selector.dart';
import 'package:libretapp/l10n/app_localizations.dart';

class RegistroPesoPage extends StatefulWidget {
  const RegistroPesoPage({super.key});

  @override
  State<RegistroPesoPage> createState() => _RegistroPesoPageState();
}

class _RegistroPesoPageState extends State<RegistroPesoPage> {
  late final AnimalBloc _bloc;
  final _weightCtrl = TextEditingController();
  var _method = WeightMethod.scale;
  var _date = DateTime.now();
  String? _notes;
  AnimalEntity? _selectedAnimal;
  bool _saving = false;

  double? _parseDouble(String raw) {
    final normalized = raw.trim().replaceAll(',', '.');
    if (normalized.isEmpty) {
      return null;
    }
    return double.tryParse(normalized);
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
    _weightCtrl.dispose();
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

    final parsed = _parseDouble(_weightCtrl.text);
    if (parsed == null) {
      messenger.showSnackBar(
        SnackBar(content: Text(l10n.detailFormWeightErrorInvalid)),
      );
      return;
    }
    if (parsed <= 0) {
      messenger.showSnackBar(
        SnackBar(content: Text(l10n.detailFormAmountPositive)),
      );
      return;
    }

    setState(() => _saving = true);

    final record = WeightRecord(
      date: _date,
      weight: parsed,
      method: _method,
      notes: _notes,
    );

    _bloc.add(
      AddWeightRecord(animalUuid: _selectedAnimal!.uuid, record: record),
    );

    final nextState = await _bloc.stream.firstWhere(
      (s) => s.status != AnimalStatus.loading,
    );

    if (!mounted) return;
    setState(() => _saving = false);

    if (nextState.status == AnimalStatus.success) {
      navigator.pop();
      messenger.showSnackBar(
        SnackBar(content: Text(l10n.detailFormWeightSaved)),
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
      appBar: AppBar(title: Text(l10n.detailFormWeightTitle)),
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
            TextField(
              controller: _weightCtrl,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: l10n.detailFormWeightValue,
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<WeightMethod>(
              initialValue: _method,
              decoration: InputDecoration(
                labelText: l10n.detailFormWeightMethod,
                border: const OutlineInputBorder(),
              ),
              items: WeightMethod.values
                  .map(
                    (m) => DropdownMenuItem(
                      value: m,
                      child: Text(
                        m == WeightMethod.scale
                            ? l10n.detailFormWeightMethodScale
                            : l10n.detailFormWeightMethodEstimated,
                      ),
                    ),
                  )
                  .toList(),
              onChanged: (v) {
                if (v != null) setState(() => _method = v);
              },
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
                  child: TextField(
                    decoration: InputDecoration(
                      labelText: l10n.fieldNotesOptional,
                      border: const OutlineInputBorder(),
                    ),
                    onChanged: (v) => _notes = v,
                  ),
                ),
              ],
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
