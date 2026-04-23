import 'package:flutter/material.dart';
import 'package:libretapp/core/core.dart';
import 'package:libretapp/features/directorio/animales/application/bloc/index.dart';
import 'package:libretapp/features/directorio/animales/domain/animal_domain.dart'
    hide AnimalStatus;
import 'package:libretapp/features/directorio/animales/infrastructure/infrastructure.dart';
import 'package:libretapp/features/directorio/lotes/infrastructure/infrastructure.dart';
import 'package:libretapp/features/registro/widgets/animal_selector.dart';
import 'package:libretapp/l10n/app_localizations.dart';

class RegistroReproduccionPage extends StatefulWidget {
  const RegistroReproduccionPage({super.key});

  @override
  State<RegistroReproduccionPage> createState() =>
      _RegistroReproduccionPageState();
}

class _RegistroReproduccionPageState extends State<RegistroReproduccionPage> {
  late final AnimalBloc _bloc;
  var _serviceType = ServiceType.naturalService;
  var _serviceDate = DateTime.now();
  DateTime? _expectedCalvingDate;
  String? _sireId;
  String? _notes;
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
    if (_expectedCalvingDate != null &&
        _expectedCalvingDate!.isBefore(_serviceDate)) {
      messenger.showSnackBar(
        SnackBar(content: Text(l10n.detailFormReproductionExpectedAfterDate)),
      );
      return;
    }

    setState(() => _saving = true);

    final record = ReproductionRecord(
      serviceDate: _serviceDate,
      serviceType: _serviceType,
      maleSireIdentifier: _sireId,
      expectedCalvingDate: _expectedCalvingDate,
      notes: _notes,
    );

    _bloc.add(
      AddReproductionRecord(animalUuid: _selectedAnimal!.uuid, record: record),
    );

    final nextState = await _bloc.stream.firstWhere(
      (s) => s.status != AnimalStatus.loading,
    );

    if (!mounted) return;
    setState(() => _saving = false);

    if (nextState.status == AnimalStatus.success) {
      navigator.pop();
      messenger.showSnackBar(
        SnackBar(content: Text(l10n.detailFormReproductionSaved)),
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
      appBar: AppBar(title: Text(l10n.detailFormReproductionTitle)),
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
            DropdownButtonFormField<ServiceType>(
              initialValue: _serviceType,
              decoration: InputDecoration(
                labelText: l10n.detailFormReproductionServiceType,
                border: const OutlineInputBorder(),
              ),
              items: ServiceType.values
                  .map(
                    (s) => DropdownMenuItem(
                      value: s,
                      child: Text(
                        s == ServiceType.naturalService
                            ? l10n.detailFormReproductionServiceNatural
                            : s == ServiceType.artificialInsemination
                            ? l10n.detailFormReproductionServiceAi
                            : l10n.detailFormReproductionServiceIvf,
                      ),
                    ),
                  )
                  .toList(),
              onChanged: (v) {
                if (v != null) setState(() => _serviceType = v);
              },
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.event),
                    label: Text(
                      '${_serviceDate.year}-${_serviceDate.month}-${_serviceDate.day}',
                    ),
                    onPressed: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: _serviceDate,
                        firstDate: DateTime(_serviceDate.year - 5),
                        lastDate: DateTime(_serviceDate.year + 1),
                      );
                      if (picked != null) {
                        setState(() => _serviceDate = picked);
                      }
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.child_friendly),
                    label: Text(
                      _expectedCalvingDate == null
                          ? l10n.detailFormReproductionExpectedCalving
                          : '${_expectedCalvingDate!.year}-${_expectedCalvingDate!.month}-${_expectedCalvingDate!.day}',
                    ),
                    onPressed: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: _expectedCalvingDate ?? _serviceDate,
                        firstDate: DateTime(_serviceDate.year - 1),
                        lastDate: DateTime(_serviceDate.year + 2),
                      );
                      if (picked != null) {
                        setState(() => _expectedCalvingDate = picked);
                      }
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            TextField(
              decoration: InputDecoration(
                labelText: l10n.detailFormReproductionSire,
                border: const OutlineInputBorder(),
              ),
              onChanged: (v) => _sireId = v.trim().isEmpty ? null : v.trim(),
            ),
            const SizedBox(height: 12),
            TextField(
              decoration: InputDecoration(
                labelText: l10n.detailFormReproductionNotes,
                border: const OutlineInputBorder(),
              ),
              maxLines: 2,
              onChanged: (v) => _notes = v,
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
