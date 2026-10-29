/// features \u203a directorio \u203a lotes \u203a view \u203a lote_detail_page \u2014 detail page for a single lote.
library;

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:libretapp/app/widgets/widgets.dart';
import 'package:libretapp/core/di/injection.dart';
import 'package:libretapp/core/router/app_routes.dart';
import 'package:libretapp/features/directorio/animales/domain/repositories/movement_record_repository.dart';
import 'package:libretapp/features/directorio/lotes/bloc/lotes_bloc.dart';
import 'package:libretapp/features/directorio/lotes/bloc/lotes_event.dart';
import 'package:libretapp/features/directorio/lotes/bloc/lotes_state.dart';
import 'package:libretapp/features/directorio/lotes/domain/entities/lote_entity.dart';
import 'package:libretapp/features/directorio/lotes/infrastructure/lotes_repository.dart';
import 'package:libretapp/features/directorio/lotes/view/lote_performance_panel.dart';
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
    final future = bloc.stream.firstWhere(
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
      useRootNavigator: true,
      builder: (context) => AlertDialog(
        title: const Text('Cerrar lote'),
        content: Text(
          '¿Cerrar "${lote.name}"? Se conservarán sus integrantes y registros para consultar el historial.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Cerrar lote'),
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
        .where((l) => l.status != LocationStatus.closed)
        .toList();

    if (!mounted) return;

    String? selectedUuid = lote.currentLocationId;

    final confirmed = await showAppBottomSheet<bool>(
      context: context,
      useRootNavigator: true,
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
                          'Mover lote "${lote.name}"',
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

    const animalsLoadFailed = false;
    const animalWritesFailed = false;
    var loteUpdated = true;
    try {
      if (movementRepository is! AtomicMovementRepository) {
        throw StateError('Este almacenamiento no permite mover el lote de forma segura.');
      }
      await (movementRepository as AtomicMovementRepository).moveLotAtomically(lote.uuid, selectedUuid);
    } catch (_) {
      loteUpdated = false;
    }

    if (!mounted) return;

    final locationName = available
        .where((l) => l.uuid == selectedUuid)
        .map((l) => l.name)
        .firstOrNull;
    final partial = animalsLoadFailed || animalWritesFailed || !loteUpdated;
    final message = partial
        ? 'Movimiento parcial: revisa los animales y el lote; puedes reintentar.'
        : locationName != null
        ? 'Lote movido a "$locationName"'
        : 'Lote actualizado';
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
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
              onBatchRecords: () async {
                await context.pushNamed(AppRoutes.nameBatchRecords, queryParameters: {'lote': lote.uuid});
                if (mounted) _reload();
              },
              onRegisterWeight: () async {
                final saved = await context.pushNamed(
                  AppRoutes.nameLoteRegistroPeso,
                  pathParameters: {'uuid': lote.uuid},
                );
                if (saved == true && mounted) _reload();
              },
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
    required this.onRegisterWeight,
    required this.onBatchRecords,
  });

  final LoteEntity lote;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onMoveLocation;
  final VoidCallback onRegisterWeight;
  final VoidCallback onBatchRecords;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      children: [
        Text(
          lote.name,
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          lote.description?.trim().isNotEmpty == true
              ? lote.description!
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
                Text('Estado: ${lote.active ? 'Activo' : 'Inactivo'}'),
                const SizedBox(height: 6),
                Text(
                  'Creado: ${DateFormat("dd/MM/yyyy").format(lote.createdAt)}',
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: FilledButton.icon(
            onPressed: onRegisterWeight,
            icon: const Icon(Icons.monitor_weight_outlined),
            label: const Text('Registrar pesaje'),
          ),
        ),
        const SizedBox(height: 8),
        OutlinedButton.icon(
          onPressed: lote.active ? onBatchRecords : null,
          icon: const Icon(Icons.playlist_add_check_outlined),
          label: const Text('Registro por lotes sin conexión'),
        ),
        const SizedBox(height: 16),
        LotePerformancePanel(lote: lote),
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
                label: const Text('Cerrar lote'),
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
