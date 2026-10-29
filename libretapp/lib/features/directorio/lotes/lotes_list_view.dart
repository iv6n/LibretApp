/// features \u203a directorio \u203a lotes \u203a lotes_list_view \u2014 stateless list layout for lotes.
library;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:go_router/go_router.dart';
import 'package:libretapp/app/widgets/widgets.dart';
import 'package:libretapp/core/di/injection.dart';
import 'package:libretapp/core/router/app_routes.dart';
import 'package:libretapp/core/widgets/app_empty_state.dart';
import 'package:libretapp/core/widgets/app_directory_filter_chip.dart';
import 'package:libretapp/features/directorio/lotes/bloc/lotes_bloc.dart';
import 'package:libretapp/features/directorio/lotes/bloc/lotes_event.dart';
import 'package:libretapp/features/directorio/lotes/bloc/lotes_state.dart';
import 'package:libretapp/features/directorio/lotes/domain/entities/lote_entity.dart';
import 'package:libretapp/features/directorio/lotes/lote_card.dart';
import 'package:libretapp/features/ubicaciones/domain/entities/location_entity.dart';
import 'package:libretapp/features/ubicaciones/domain/repositories/location_repository.dart';

enum _LoteListFilter { all, active, closed }

class LotesListView extends StatefulWidget {
  const LotesListView({
    super.key,
    this.shellInteractionsEnabled = true,
    this.locationRepository,
  });

  final bool shellInteractionsEnabled;
  final LocationRepository? locationRepository;

  @override
  State<LotesListView> createState() => _LotesListViewState();
}

class _LotesListViewState extends State<LotesListView> {
  late final ScrollController _scrollController;
  Stream<List<LocationEntity>>? _locationsStream;
  _LoteListFilter _filter = _LoteListFilter.all;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _locationsStream = _locationStream();
    context.read<LotesBloc>().add(const LoadLotes());
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _openCreateLotePage() async {
    await context.pushNamed(AppRoutes.nameLoteNuevo);
  }

  void _openLoteDetail(LoteEntity lote) {
    context.pushNamed(
      AppRoutes.nameLoteDetalle,
      pathParameters: {'uuid': lote.uuid},
    );
  }

  Future<void> _confirmDeleteLote(LoteEntity lote) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      useRootNavigator: true,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar lote'),
        content: Text(
          '¿Deseas borrar "${lote.name}"? Esta acción no se puede deshacer.',
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

    if (shouldDelete == true && mounted) {
      context.read<LotesBloc>().add(DeleteLote(lote.uuid));
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = ShellInsets.bottomSafePadding(context);
    // Keep the last item above the dock and its floating action at scroll end.
    final listBottomPadding = bottomInset + ShellInsets.fabContentClearance;

    // Activating a directory tab adds its shell scope. Keep the subscription
    // above that changing subtree so a single-subscription stream stays alive.
    return StreamBuilder<List<LocationEntity>>(
      stream: _locationsStream,
      initialData: const [],
      builder: (context, locationSnapshot) {
        final scaffold = Scaffold(
          body: BlocBuilder<LotesBloc, LotesState>(
            builder: (context, state) {
              if (state is LotesInitial || state is LotesLoading) {
                return const Center(child: CircularProgressIndicator());
              }

              if (state is LotesError) {
                return AppEmptyState(
                  icon: Icons.error_outline,
                  title: 'No se pudieron cargar los lotes',
                  message: state.message,
                  action: FilledButton.icon(
                    onPressed: () =>
                        context.read<LotesBloc>().add(const LoadLotes()),
                    icon: const Icon(Icons.refresh),
                    label: const Text('Reintentar'),
                  ),
                );
              }

              if (state is! LotesLoaded) {
                return const SizedBox.shrink();
              }

              final locationNames = {
                for (final location
                    in locationSnapshot.data ?? const <LocationEntity>[])
                  location.uuid: location.name,
              };
              return _buildLotesContent(
                context: context,
                lotes: state.lotes,
                locationNames: locationNames,
                listBottomPadding: listBottomPadding,
              );
            },
          ),
        );

        if (!widget.shellInteractionsEnabled) return scaffold;

        final isInitiallyEmpty = switch (context.watch<LotesBloc>().state) {
          LotesLoaded(:final lotes) => lotes.isEmpty,
          _ => false,
        };
        return ShellFabConfigScope(
          config: isInitiallyEmpty
              ? null
              : ShellFabConfig(
                  id: 'lotes',
                  label: 'Agregar Lote',
                  icon: Icons.add,
                  heroTag: 'fab_lotes',
                  onPressed: _openCreateLotePage,
                ),
          child: scaffold,
        );
      },
    );
  }

  Widget _buildLotesContent({
    required BuildContext context,
    required List<LoteEntity> lotes,
    required Map<String, String> locationNames,
    required double listBottomPadding,
  }) {
    final active = lotes.where((lote) => lote.active).toList(growable: false);
    final closed = lotes.where((lote) => !lote.active).toList(growable: false);
    final visible = switch (_filter) {
      _LoteListFilter.all => [...active, ...closed],
      _LoteListFilter.active => active,
      _LoteListFilter.closed => closed,
    };

    if (lotes.isEmpty) {
      return CustomScrollView(
        controller: _scrollController,
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          SliverToBoxAdapter(
            child: _buildFilterBar(context, total: 0, active: 0, closed: 0),
          ),
          SliverFillRemaining(
            hasScrollBody: false,
            child: _buildEmptyState(context),
          ),
        ],
      );
    }

    return CustomScrollView(
      controller: _scrollController,
      physics: const AlwaysScrollableScrollPhysics(),
      slivers: [
        SliverToBoxAdapter(
          child: _buildFilterBar(
            context,
            total: lotes.length,
            active: active.length,
            closed: closed.length,
          ),
        ),
        if (visible.isEmpty)
          SliverFillRemaining(
            hasScrollBody: false,
            child: _buildFilteredEmptyState(context),
          ),
        if (_filter != _LoteListFilter.closed && active.isNotEmpty)
          _buildLoteSection(
            context: context,
            title: 'Activos',
            lotes: _filter == _LoteListFilter.all ? active : visible,
            locationNames: locationNames,
            listBottomPadding:
                _filter == _LoteListFilter.active || closed.isEmpty
                ? listBottomPadding
                : 0,
          ),
        if (_filter != _LoteListFilter.active && closed.isNotEmpty)
          _buildLoteSection(
            context: context,
            title: 'Cerrados',
            lotes: _filter == _LoteListFilter.all ? closed : visible,
            locationNames: locationNames,
            listBottomPadding: listBottomPadding,
          ),
      ],
    );
  }

  Stream<List<LocationEntity>>? _locationStream() {
    final repository =
        widget.locationRepository ??
        (locator.isRegistered<LocationRepository>()
            ? locator<LocationRepository>()
            : null);
    return repository?.watchAll();
  }

  Widget _buildFilterBar(
    BuildContext context, {
    required int total,
    required int active,
    required int closed,
  }) {
    final options = [
      (_LoteListFilter.all, 'Todos', total),
      (_LoteListFilter.active, 'Activos', active),
      (_LoteListFilter.closed, 'Cerrados', closed),
    ];
    final theme = Theme.of(context);
    final visibleCount = switch (_filter) {
      _LoteListFilter.all => total,
      _LoteListFilter.active => active,
      _LoteListFilter.closed => closed,
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 60,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            itemCount: options.length,
            separatorBuilder: (_, _) => const SizedBox(width: 8),
            itemBuilder: (context, index) {
              final option = options[index];
              return AppDirectoryFilterChip(
                label: option.$2,
                count: option.$3,
                icon: switch (option.$1) {
                  _LoteListFilter.all => Icons.layers_outlined,
                  _LoteListFilter.active => Icons.check_circle_outline,
                  _LoteListFilter.closed => Icons.history_outlined,
                },
                selected: _filter == option.$1,
                onTap: () => setState(() => _filter = option.$1),
              );
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 10),
          child: Text(
            '$visibleCount ${visibleCount == 1 ? 'lote' : 'lotes'}',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLoteSection({
    required BuildContext context,
    required String title,
    required List<LoteEntity> lotes,
    required Map<String, String> locationNames,
    required double listBottomPadding,
  }) {
    return SliverPadding(
      padding: EdgeInsets.fromLTRB(12, 0, 12, listBottomPadding),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate((context, index) {
          if (index == 0) {
            return _CenteredSection(
              padding: const EdgeInsets.fromLTRB(2, 0, 2, 10),
              child: Text(
                '$title · ${lotes.length}',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
              ),
            );
          }

          final lote = lotes[index - 1];
          return _CenteredSection(
            padding: const EdgeInsets.symmetric(horizontal: 2),
            child: Slidable(
              key: ValueKey('slide_${lote.uuid}'),
              startActionPane: lote.active
                  ? ActionPane(
                      motion: const DrawerMotion(),
                      extentRatio: 0.22,
                      children: [
                        SlidableAction(
                          onPressed: (_) => _openLoteDetail(lote),
                          backgroundColor: Colors.blue.shade700,
                          foregroundColor: Colors.white,
                          icon: Icons.edit_outlined,
                          label: 'Editar',
                          borderRadius: const BorderRadius.horizontal(
                            left: Radius.circular(20),
                          ),
                        ),
                      ],
                    )
                  : null,
              endActionPane: ActionPane(
                motion: const DrawerMotion(),
                extentRatio: 0.22,
                children: [
                  SlidableAction(
                    onPressed: (_) => _confirmDeleteLote(lote),
                    backgroundColor: Colors.red.shade600,
                    foregroundColor: Colors.white,
                    icon: Icons.delete_outline,
                    label: 'Eliminar',
                    borderRadius: const BorderRadius.horizontal(
                      right: Radius.circular(20),
                    ),
                  ),
                ],
              ),
              child: LoteCard(
                key: ValueKey('lote_${lote.uuid}'),
                lote: lote,
                locationName: locationNames[lote.currentLocationId],
                onLocationTap: locationNames.containsKey(lote.currentLocationId)
                    ? () => context.push(
                        AppRoutes.ubicacionDetallePath(lote.currentLocationId!),
                      )
                    : null,
                onAnimalsTap: lote.animalUuids.isEmpty
                    ? null
                    : () => context.push(
                        AppRoutes.animalesPath(loteUuid: lote.uuid),
                      ),
                onTap: () => _openLoteDetail(lote),
                onEdit: () => _openLoteDetail(lote),
                onDelete: () => _confirmDeleteLote(lote),
              ),
            ),
          );
        }, childCount: lotes.length + 1),
      ),
    );
  }

  Widget _buildFilteredEmptyState(BuildContext context) {
    final label = _filter == _LoteListFilter.closed ? 'cerrados' : 'activos';
    return AppEmptyState(
      icon: Icons.search_off_outlined,
      title: 'No hay lotes $label',
      message: 'Prueba con otro filtro para ver tus lotes.',
      action: OutlinedButton.icon(
        onPressed: () => setState(() => _filter = _LoteListFilter.all),
        icon: const Icon(Icons.filter_alt_off_outlined),
        label: const Text('Limpiar filtros'),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return AppEmptyState(
      illustrationAsset: 'assets/images/location_pasture.webp',
      title: 'Organiza tus animales en lotes',
      message: 'Crea tu primer lote para llevar su seguimiento en grupo.',
      action: FilledButton.icon(
        onPressed: _openCreateLotePage,
        icon: const Icon(Icons.add),
        label: const Text('Crear lote'),
      ),
    );
  }
}

/// Sección centrada para mantener respuesta en pantallas grandes
class _CenteredSection extends StatelessWidget {
  const _CenteredSection({required this.child, this.padding = EdgeInsets.zero});
  final Widget child;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 720),
      child: Padding(padding: padding, child: child),
    );
  }
}
