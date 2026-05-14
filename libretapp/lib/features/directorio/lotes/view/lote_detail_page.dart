/// features \u203a directorio \u203a lotes \u203a view \u203a lote_detail_page \u2014 detail page for a single lote.
library;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:libretapp/app/widgets/widgets.dart';
import 'package:libretapp/core/di/injection.dart';
import 'package:libretapp/core/router/app_routes.dart';
import 'package:libretapp/features/directorio/animales/domain/entities/movement_record.dart';
import 'package:libretapp/features/directorio/animales/infrastructure/animal_repository.dart';
import 'package:libretapp/features/directorio/animales/domain/repositories/movement_record_repository.dart';
import 'package:libretapp/features/directorio/lotes/bloc/lotes_bloc.dart';
import 'package:libretapp/features/directorio/lotes/bloc/lotes_event.dart';
import 'package:libretapp/features/directorio/lotes/bloc/lotes_state.dart';
import 'package:libretapp/features/directorio/lotes/domain/entities/lote_entity.dart';
import 'package:libretapp/features/directorio/lotes/infrastructure/lotes_repository.dart';
import 'package:libretapp/features/ubicaciones/domain/entities/location_entity.dart';
import 'package:libretapp/features/ubicaciones/domain/enums/location_status.dart';
import 'package:libretapp/features/ubicaciones/domain/repositories/location_repository.dart';

class LoteDetailPage extends StatefulWidget {
  LoteDetailPage({
    required this.loteUuid,
    LotesRepository? repository,
    super.key,
  }) : repository = repository ?? locator<LotesRepository>();

  final String loteUuid;
  final LotesRepository repository;

  @override
  State<LoteDetailPage> createState() => _LoteDetailPageState();
}

class _LoteDetailPageState extends State<LoteDetailPage> {
  late Future<LoteEntity?> _future;

  @override
  void initState() {
    super.initState();
    _future = _loadLote();
  }

  Future<LoteEntity?> _loadLote() =>
      widget.repository.getByUuid(widget.loteUuid);

  void _reload() {
    setState(() {
      _future = _loadLote();
    });
  }

  Future<bool> _dispatchAndAwait(LotesEvent event) async {
    final bloc = context.read<LotesBloc>();
    final future = bloc.stream
        .skip(1)
        .firstWhere(
          (state) => state is! LotesActionInProgress,
          orElse: () => bloc.state,
        );
    bloc.add(event);
    final nextState = await future;

    if (!mounted) return false;

    if (nextState is LotesError) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(nextState.message)));
      return false;
    }

    return true;
  }

  Future<void> _confirmDelete(LoteEntity lote) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar lote'),
        content: Text(
          '¿Deseas borrar "${lote.nombre}"? Esta acción no se puede deshacer.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (shouldDelete != true || !mounted) return;

    final ok = await _dispatchAndAwait(DeleteLote(lote.uuid));
    if (ok && mounted) {
      Navigator.of(context).pop();
    }
  }

  Future<void> _openEditPage(LoteEntity lote) async {
    final saved = await context.pushNamed(
      AppRoutes.nameLoteEditar,
      pathParameters: {'uuid': lote.uuid},
    );
    if (saved == true && mounted) {
      _reload();
    }
  }

  Future<void> _showMoveLoteSheet(LoteEntity lote) async {
    final locationRepository = locator<LocationRepository>();
    final animalRepository = locator<AnimalRepository>();
    final movementRepository = locator<MovementRecordRepository>();

    List<LocationEntity> locations = [];
    try {
      locations = await locationRepository.getAll();
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error al cargar ubicaciones')),
        );
      }
      return;
    }

    final available = locations
        .where((l) => l.status != LocationStatus.clausurado)
        .toList();

    if (!mounted) return;

    String? selectedUuid = lote.currentLocationId;

    final confirmed = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      builder: (sheetCtx) {
        return StatefulBuilder(
          builder: (ctx, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 16,
                right: 16,
                top: 20,
                bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.swap_horiz, color: Colors.blue),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Mover lote "${lote.nombre}"',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Se moverán ${lote.animalUuids.length} animales a la ubicación seleccionada.',
                    style: Theme.of(ctx).textTheme.bodySmall,
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String?>(
                    value: selectedUuid,
                    decoration: const InputDecoration(
                      labelText: 'Ubicación destino',
                      border: OutlineInputBorder(),
                    ),
                    items: [
                      const DropdownMenuItem(
                        value: null,
                        child: Text('Sin ubicación'),
                      ),
                      ...available.map(
                        (loc) => DropdownMenuItem(
                          value: loc.uuid,
                          child: Text(loc.name),
                        ),
                      ),
                    ],
                    onChanged: (v) => setModalState(() => selectedUuid = v),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      icon: const Icon(Icons.check),
                      label: const Text('Confirmar movimiento'),
                      onPressed: () => Navigator.of(ctx).pop(true),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );

    if (confirmed != true || !mounted) return;
    if (selectedUuid == lote.currentLocationId) return;

    final now = DateTime.now();

    // 1. Load all animals that belong to this batch.
    List<dynamic> animals = [];
    try {
      animals = await animalRepository.getByBatchUuid(lote.uuid);
    } catch (_) {
      // Proceed — empty list means only the lote record is updated.
    }

    // 2. Move each animal and create a MovementRecord.
    final updateFutures = <Future<void>>[];
    final moveFutures = <Future<void>>[];
    for (final rawAnimal in animals) {
      final animal = rawAnimal;
      final oldLocId = animal.currentPaddockId;
      final updatedAnimal = animal.copyWith(
        currentPaddockId: selectedUuid,
        initialLocationId: animal.initialLocationId ?? selectedUuid,
        lastMovementDate: now,
        lastUpdateDate: now,
        synced: false,
      );
      updateFutures.add(animalRepository.update(updatedAnimal));

      if (selectedUuid != null) {
        final record = MovementRecord(
          fromLocation: oldLocId,
          toLocation: selectedUuid!,
          date: now,
          reason: MovementReason.paddockRotation,
        );
        moveFutures.add(
          movementRepository.addMovementRecord(animal.uuid, record),
        );
      }
    }
    await Future.wait(updateFutures);
    await Future.wait(moveFutures);

    // 3. Update the lote's currentLocationId.
    try {
      await widget.repository.updateLote(
        lote.copyWith(currentLocationId: selectedUuid),
      );
    } catch (_) {
      // Best-effort — animals were already moved.
    }

    if (!mounted) return;

    final locationName = available
        .where((l) => l.uuid == selectedUuid)
        .map((l) => l.name)
        .firstOrNull;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          locationName != null
              ? 'Lote movido a "$locationName"'
              : 'Lote actualizado',
        ),
      ),
    );
    _reload();
  }

  @override
  Widget build(BuildContext context) {
    return ShellChromeScope(
      visible: false,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Detalle del lote'),
          actions: [
            IconButton(
              tooltip: 'Editar',
              onPressed: () async {
                final lote = await _loadLote();
                if (!mounted || lote == null) return;
                await _openEditPage(lote);
              },
              icon: const Icon(Icons.edit_outlined),
            ),
            IconButton(
              tooltip: 'Recargar',
              onPressed: _reload,
              icon: const Icon(Icons.refresh),
            ),
          ],
        ),
        body: FutureBuilder<LoteEntity?>(
          future: _future,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return _ErrorState(
                message: 'Error al cargar el lote: ${snapshot.error}',
                onRetry: _reload,
              );
            }

            final lote = snapshot.data;
            if (lote == null) {
              return const _ErrorState(message: 'Lote no encontrado');
            }

            return _LoteDetailContent(
              lote: lote,
              onEdit: () => _openEditPage(lote),
              onDelete: () => _confirmDelete(lote),
              onMoveLocation: () => _showMoveLoteSheet(lote),
            );
          },
        ),
      ),
    );
  }
}

class _LoteDetailContent extends StatelessWidget {
  const _LoteDetailContent({
    required this.lote,
    required this.onEdit,
    required this.onDelete,
    required this.onMoveLocation,
  });

  final LoteEntity lote;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onMoveLocation;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      children: [
        Text(
          lote.nombre,
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          lote.descripcion?.trim().isNotEmpty == true
              ? lote.descripcion!
              : 'Sin descripción',
        ),
        const SizedBox(height: 16),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Animales: ${lote.animalUuids.length}'),
                const SizedBox(height: 6),
                Text('Estado: ${lote.activo ? 'Activo' : 'Inactivo'}'),
                const SizedBox(height: 6),
                Text('Creado: ${lote.fechaCreacion}'),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: onEdit,
                icon: const Icon(Icons.edit_outlined),
                label: const Text('Editar'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: onDelete,
                icon: const Icon(Icons.delete_outline),
                label: const Text('Eliminar'),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: onMoveLocation,
            icon: const Icon(Icons.swap_horiz),
            label: const Text('Mover lote'),
          ),
        ),
      ],
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message, this.onRetry});

  final String message;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(message, textAlign: TextAlign.center),
            if (onRetry != null) ...[
              const SizedBox(height: 12),
              FilledButton(onPressed: onRetry, child: const Text('Reintentar')),
            ],
          ],
        ),
      ),
    );
  }
}
