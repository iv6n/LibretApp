import 'package:flutter/material.dart';
import 'package:libretapp/core/core.dart';
import 'package:libretapp/features/directorio/animales/application/bloc/index.dart';
import 'package:libretapp/features/directorio/animales/domain/animal_domain.dart'
    hide AnimalStatus;
import 'package:libretapp/features/directorio/animales/infrastructure/infrastructure.dart';
import 'package:libretapp/features/directorio/lotes/infrastructure/infrastructure.dart';
import 'package:libretapp/features/registro/widgets/animal_selector.dart';
import 'package:libretapp/l10n/app_localizations.dart';

class RegistroMovimientoPage extends StatefulWidget {
  const RegistroMovimientoPage({super.key});

  @override
  State<RegistroMovimientoPage> createState() => _RegistroMovimientoPageState();
}

class _RegistroMovimientoPageState extends State<RegistroMovimientoPage> {
  late final AnimalBloc _bloc;
  final _fromCtrl = TextEditingController();
  final _toCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();
  final _movedByCtrl = TextEditingController();
  var _reason = MovementReason.paddockRotation;
  var _date = DateTime.now();
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
    _fromCtrl.dispose();
    _toCtrl.dispose();
    _notesCtrl.dispose();
    _movedByCtrl.dispose();
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
    if (_toCtrl.text.trim().isEmpty) {
      messenger.showSnackBar(
        SnackBar(content: Text(l10n.detailFormMovementToRequired)),
      );
      return;
    }

    final fromText = _fromCtrl.text.trim();
    final toText = _toCtrl.text.trim();
    if (fromText.isNotEmpty && fromText.toLowerCase() == toText.toLowerCase()) {
      messenger.showSnackBar(
        SnackBar(content: Text(l10n.detailFormMovementDifferentLocations)),
      );
      return;
    }

    setState(() => _saving = true);

    final record = MovementRecord(
      fromLocation: fromText.isEmpty ? null : fromText,
      toLocation: toText,
      date: _date,
      reason: _reason,
      notes: _notesCtrl.text.trim().isEmpty ? null : _notesCtrl.text.trim(),
      movedBy: _movedByCtrl.text.trim().isEmpty
          ? null
          : _movedByCtrl.text.trim(),
    );

    _bloc.add(
      AddMovementRecord(animalUuid: _selectedAnimal!.uuid, record: record),
    );

    final nextState = await _bloc.stream.firstWhere(
      (s) => s.status != AnimalStatus.loading,
    );

    if (!mounted) return;
    setState(() => _saving = false);

    if (nextState.status == AnimalStatus.success) {
      navigator.pop();
      messenger.showSnackBar(
        SnackBar(content: Text(l10n.detailFormMovementSaved)),
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
      appBar: AppBar(title: Text(l10n.detailFormMovementTitle)),
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
            DropdownButtonFormField<MovementReason>(
              initialValue: _reason,
              decoration: InputDecoration(
                labelText: l10n.detailFormMovementReason,
                border: const OutlineInputBorder(),
              ),
              items: MovementReason.values
                  .map(
                    (r) =>
                        DropdownMenuItem(value: r, child: Text(r.displayName)),
                  )
                  .toList(),
              onChanged: (v) {
                if (v != null) setState(() => _reason = v);
              },
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _fromCtrl,
                    decoration: InputDecoration(
                      labelText: l10n.detailFormMovementFrom,
                      border: const OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: _toCtrl,
                    decoration: InputDecoration(
                      labelText: l10n.detailFormMovementTo,
                      border: const OutlineInputBorder(),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
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
            const SizedBox(height: 12),
            TextField(
              controller: _movedByCtrl,
              decoration: InputDecoration(
                labelText: l10n.detailFormMovementMovedBy,
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
