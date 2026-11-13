import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:libretapp/core/database/write_transaction.dart';
import 'package:libretapp/core/di/injection.dart';
import 'package:libretapp/core/router/app_routes.dart';
import 'package:libretapp/core/services/shared_prefs_service.dart';
import 'package:libretapp/features/directorio/animales/application/animal_batch_registration.dart';
import 'package:libretapp/features/directorio/animales/bloc/animales_bloc.dart';
import 'package:libretapp/features/directorio/animales/bloc/animales_event.dart';
import 'package:libretapp/features/directorio/animales/domain/animal_domain.dart';
import 'package:libretapp/features/directorio/animales/domain/models/animal_batch_draft.dart';
import 'package:libretapp/features/directorio/animales/domain/repositories/health_record_repository.dart';
import 'package:libretapp/features/directorio/animales/domain/repositories/movement_record_repository.dart';
import 'package:libretapp/features/directorio/animales/domain/repositories/reproduction_record_repository.dart';
import 'package:libretapp/features/directorio/animales/infrastructure/animal_repository.dart';
import 'package:libretapp/features/directorio/animales/view/quick_register_animal_page.dart';
import 'package:libretapp/features/directorio/animales/view/register_animal_page.dart';
import 'package:libretapp/features/directorio/lotes/domain/entities/lote_entity.dart';
import 'package:libretapp/features/directorio/lotes/infrastructure/lotes_repository.dart';

class AnimalBatchRegisterPage extends StatefulWidget {
  const AnimalBatchRegisterPage({
    super.key,
    this.preferredSpecies = const [],
    this.registration,
  });

  final List<Species> preferredSpecies;
  final AnimalBatchRegistration? registration;

  @override
  State<AnimalBatchRegisterPage> createState() =>
      _AnimalBatchRegisterPageState();
}

class _AnimalBatchRegisterPageState extends State<AnimalBatchRegisterPage> {
  late final AnimalBatchRegistration _registration;
  AnimalBatchSession _session = const AnimalBatchSession();
  List<LoteEntity> _lots = const [];
  Species _suggestedSpecies = Species.cattle;
  bool _loading = true;
  bool _busy = false;
  Future<void> _draftWrites = Future.value();
  bool _draftWriteFailed = false;

  @override
  void initState() {
    super.initState();
    _registration =
        widget.registration ??
        AnimalBatchRegistration(
          preferences: locator<SharedPrefsService>(),
          animals: locator<AnimalRepository>(),
          lots: locator<LotesRepository>(),
          health: locator<HealthRecordRepository>(),
          movements: locator<MovementRecordRepository>(),
          reproduction: locator<ReproductionRecordRepository>(),
          transactions: locator<WriteTransactionRunner>(),
        );
    _load();
  }

  Future<void> _load() async {
    try {
      var session = _registration.load();
      final results = await Future.wait<dynamic>([
        _registration.lots.getActiveLotes(),
        _registration.animals.getAllIncludingInactive(),
      ]);
      final lots = results[0] as List<LoteEntity>;
      final existing = [...(results[1] as List<AnimalEntity>)];
      if (session.animals.isNotEmpty) {
        final savedUuids = existing.map((animal) => animal.uuid).toSet();
        if (session.animals.every(
          (draft) => savedUuids.contains(draft.animal.uuid),
        )) {
          try {
            await _registration.discard();
          } catch (_) {}
          session = const AnimalBatchSession();
        }
      }
      existing.sort((a, b) => b.creationDate.compareTo(a.creationDate));
      if (!mounted) return;
      setState(() {
        _session = session;
        _lots = lots;
        _suggestedSpecies =
            session.animals.lastOrNull?.animal.species ??
            existing.firstOrNull?.species ??
            widget.preferredSpecies.firstOrNull ??
            Species.cattle;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _loading = false);
      _message('No se pudo recuperar la lista de animales.');
    }
  }

  void _message(String text) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));

  Future<void> _update(AnimalBatchSession next) async {
    if (mounted) setState(() => _session = next);
    final write = _draftWrites.then((_) => _registration.persist(next));
    _draftWrites = write.catchError((Object _) {});
    try {
      await write;
      _draftWriteFailed = false;
    } catch (_) {
      _draftWriteFailed = true;
      if (mounted) {
        _message('No se pudo guardar el borrador. Intenta de nuevo.');
      }
    }
  }

  Future<void> _openQuick([int? index]) async {
    final current = index == null ? null : _session.animals[index];
    final draft = await Navigator.of(context).push<AnimalBatchDraft>(
      MaterialPageRoute(
        builder: (_) => QuickRegisterAnimalPage(
          batchMode: true,
          initialBatchDraft: current,
          initialSpecies: _suggestedSpecies,
          preferredSpecies: widget.preferredSpecies,
        ),
      ),
    );
    if (!mounted || draft == null) return;
    if (_hasDuplicateInList(draft, index)) {
      _message('Esa identificación ya está en la lista.');
      return;
    }
    final next = [..._session.animals];
    if (index == null) {
      next.add(draft);
    } else {
      next[index] = draft;
    }
    await _update(_session.copyWith(animals: next));
    if (mounted) {
      setState(() => _suggestedSpecies = next.last.animal.species);
    }
  }

  Future<void> _openFull(int index) async {
    final current = _session.animals[index];
    final animal = current.animal;
    final draft = await Navigator.of(context).push<AnimalBatchDraft>(
      MaterialPageRoute(
        builder: (_) => RegisterAnimalPage(
          batchAnimalUuid: animal.uuid,
          initialBatchDraft: current,
          initialSeed: current.isComplete
              ? null
              : AnimalRegistrationSeed(
                  species: animal.species,
                  sex: animal.sex,
                  ageMonths: animal.ageMonths,
                  identification: animal.earTagNumber,
                  name: animal.customName,
                  breed: animal.breed,
                  weight: animal.weight,
                  productionPurpose: animal.productionPurpose,
                  birthDate:
                      animal.birthDatePrecision == BirthDatePrecision.exact
                      ? animal.birthDate
                      : null,
                  birthDatePrecision: animal.birthDatePrecision,
                  profilePhoto: animal.profilePhoto,
                ),
          preferredSpecies: widget.preferredSpecies,
        ),
      ),
    );
    if (!mounted || draft == null) return;
    if (_hasDuplicateInList(draft, index)) {
      _message('Esa identificación ya está en la lista.');
      return;
    }
    final next = [..._session.animals]..[index] = draft;
    await _update(_session.copyWith(animals: next));
  }

  bool _hasDuplicateInList(AnimalBatchDraft candidate, int? index) {
    final tag = candidate.animal.earTagNumber.trim().toLowerCase();
    return tag.isNotEmpty &&
        _session.animals.asMap().entries.any(
          (entry) =>
              entry.key != index &&
              entry.value.animal.earTagNumber.trim().toLowerCase() == tag,
        );
  }

  Future<void> _remove(int index) async {
    final next = [..._session.animals]..removeAt(index);
    await _update(_session.copyWith(animals: next));
  }

  Future<void> _exit() async {
    if (_busy) return;
    await _draftWrites;
    if (_draftWriteFailed) {
      await _update(_session);
      if (_draftWriteFailed) return;
    }
    if (!mounted) return;
    if (_session.animals.isEmpty) {
      context.pop();
      return;
    }
    final choice = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Salir de la lista'),
        content: const Text(
          'Puedes retomarla después o eliminar todos sus borradores.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Seguir capturando'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, 'discard'),
            child: const Text('Eliminar lista'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, 'keep'),
            child: const Text('Conservar borrador'),
          ),
        ],
      ),
    );
    if (!mounted || choice == null) return;
    if (choice == 'discard') {
      try {
        await _registration.discard();
      } catch (_) {
        if (mounted) _message('No se pudo eliminar el borrador.');
        return;
      }
    }
    if (mounted) context.pop();
  }

  String _lotLabel() => switch (_session.lotChoice) {
    BatchLotChoice.none => 'Sin lote',
    BatchLotChoice.create => _session.newLotName.trim(),
    BatchLotChoice.existing =>
      _lots
              .where((lot) => lot.uuid == _session.lotUuid)
              .map((lot) => lot.name)
              .firstOrNull ??
          'Lote no disponible',
  };

  Future<void> _saveAll() async {
    if (_busy || _session.animals.isEmpty) return;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Confirmar altas'),
        content: Text(
          'Se guardarán ${_session.animals.length} animales. '
          'Lote: ${_lotLabel().isEmpty ? "Sin nombre" : _lotLabel()}.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Revisar lista'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Guardar todos'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    setState(() => _busy = true);
    try {
      await _draftWrites;
      if (_draftWriteFailed) await _registration.persist(_session);
      await _registration.commit(_session);
      if (!mounted) return;
      try {
        context.read<AnimalesBloc>().add(
          const LoadAnimales(forceRefresh: true),
        );
      } catch (_) {}
      _message('${_session.animals.length} animales guardados.');
      context.go(AppRoutes.animalesPath());
    } catch (error) {
      if (mounted) {
        _message(
          error is StateError
              ? error.message
              : 'No se pudo guardar la lista. El borrador sigue disponible.',
        );
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) => PopScope(
    canPop: false,
    onPopInvokedWithResult: (didPop, _) {
      if (!didPop) _exit();
    },
    child: Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: _exit,
        ),
        title: const Text('Alta de varios animales'),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Text(
                  '${_session.animals.length} animales en la lista',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                const Text(
                  'Se guardarán en el directorio cuando confirmes toda la lista.',
                ),
                const SizedBox(height: 16),
                FilledButton.icon(
                  onPressed: _busy ? null : () => _openQuick(),
                  icon: const Icon(Icons.add),
                  label: Text(
                    MediaQuery.textScalerOf(context).scale(14) >= 22
                        ? 'Agregar animal'
                        : 'Agregar animal rápido',
                  ),
                ),
                const SizedBox(height: 16),
                for (final (index, draft) in _session.animals.indexed)
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            primaryAnimalLabel(draft.animal),
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          if (draft.animal.earTagNumber.trim() !=
                              primaryAnimalLabel(draft.animal))
                            Text(identificationDisplay(draft.animal)),
                          Text(
                            '${draft.animal.species.displayName} · '
                            '${draft.animal.sex.displayName} · '
                            '${draft.isComplete ? "Ficha completa" : "Alta rápida"}',
                          ),
                          Wrap(
                            spacing: 4,
                            children: [
                              TextButton(
                                onPressed: _busy
                                    ? null
                                    : () => draft.isComplete
                                          ? _openFull(index)
                                          : _openQuick(index),
                                child: const Text('Editar'),
                              ),
                              if (!draft.isComplete)
                                TextButton(
                                  onPressed: _busy
                                      ? null
                                      : () => _openFull(index),
                                  child: const Text('Completar ficha'),
                                ),
                              TextButton(
                                onPressed: _busy ? null : () => _remove(index),
                                child: const Text('Eliminar'),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                const SizedBox(height: 20),
                Text(
                  'Lote para toda la lista',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                DropdownButtonFormField<BatchLotChoice>(
                  key: const ValueKey('animal-batch-lot-choice'),
                  isExpanded: true,
                  initialValue: _session.lotChoice,
                  items: const [
                    DropdownMenuItem(
                      value: BatchLotChoice.none,
                      child: Text('Sin lote'),
                    ),
                    DropdownMenuItem(
                      value: BatchLotChoice.existing,
                      child: Text('Lote existente'),
                    ),
                    DropdownMenuItem(
                      value: BatchLotChoice.create,
                      child: Text('Crear lote'),
                    ),
                  ],
                  onChanged: _busy
                      ? null
                      : (choice) {
                          if (choice != null) {
                            _update(_session.copyWith(lotChoice: choice));
                          }
                        },
                ),
                if (_session.lotChoice == BatchLotChoice.existing)
                  DropdownButtonFormField<String>(
                    key: const ValueKey('animal-batch-existing-lot'),
                    isExpanded: true,
                    initialValue:
                        _lots.any((lot) => lot.uuid == _session.lotUuid)
                        ? _session.lotUuid
                        : null,
                    decoration: const InputDecoration(labelText: 'Lote activo'),
                    items: _lots
                        .map(
                          (lot) => DropdownMenuItem(
                            value: lot.uuid,
                            child: Text(lot.name),
                          ),
                        )
                        .toList(),
                    onChanged: _busy
                        ? null
                        : (uuid) => _update(_session.copyWith(lotUuid: uuid)),
                  ),
                if (_session.lotChoice == BatchLotChoice.create) ...[
                  TextFormField(
                    initialValue: _session.newLotName,
                    decoration: const InputDecoration(
                      labelText: 'Nombre del lote',
                    ),
                    onChanged: (name) =>
                        _update(_session.copyWith(newLotName: name)),
                  ),
                  TextFormField(
                    initialValue: _session.newLotDescription,
                    decoration: const InputDecoration(
                      labelText: 'Descripción opcional',
                    ),
                    onChanged: (description) => _update(
                      _session.copyWith(newLotDescription: description),
                    ),
                  ),
                ],
                const SizedBox(height: 90),
              ],
            ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: FilledButton(
            key: const ValueKey('animal-batch-save'),
            onPressed: _busy || _session.animals.isEmpty ? null : _saveAll,
            child: Text(
              _busy
                  ? 'Guardando...'
                  : 'Guardar todos (${_session.animals.length})',
            ),
          ),
        ),
      ),
    ),
  );
}
