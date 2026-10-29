/// Directory list for independent cultivations.
library;

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:libretapp/app/widgets/widgets.dart';
import 'package:libretapp/core/di/injection.dart';
import 'package:libretapp/core/router/app_routes.dart';
import 'package:libretapp/core/widgets/app_empty_state.dart';
import 'package:libretapp/core/widgets/app_directory_filter_chip.dart';
import 'package:libretapp/features/directorio/cultivos/domain/cultivation_entity.dart';
import 'package:libretapp/features/directorio/cultivos/domain/cultivation_repository.dart';
import 'package:libretapp/features/directorio/cultivos/view/cultivation_card.dart';
import 'package:libretapp/features/ubicaciones/domain/entities/location_entity.dart';
import 'package:libretapp/features/ubicaciones/domain/repositories/location_repository.dart';
import 'package:libretapp/features/ubicaciones/domain/enums/crop_status.dart';

enum _CultivationFilter { all, active, history }

class CultivosListView extends StatefulWidget {
  CultivosListView({
    super.key,
    this.shellInteractionsEnabled = true,
    CultivationRepository? repository,
    LocationRepository? locationRepository,
  }) : repository = repository ?? locator<CultivationRepository>(),
       locationRepository = locationRepository ?? locator<LocationRepository>();

  final bool shellInteractionsEnabled;
  final CultivationRepository repository;
  final LocationRepository locationRepository;

  @override
  State<CultivosListView> createState() => _CultivosListViewState();
}

class _CultivosListViewState extends State<CultivosListView>
    with AutomaticKeepAliveClientMixin {
  _CultivationFilter _filter = _CultivationFilter.all;
  String? _locationFilter;
  bool _routeFilterInitialized = false;
  List<CultivationEntity>? _cultivations;
  List<LocationEntity> _locations = const [];
  bool _loading = true;
  bool _liveSyncing = false;
  String? _errorMessage;
  bool _cultivationsLiveReady = false;
  bool _locationsLiveReady = false;
  int _bootstrapGeneration = 0;
  StreamSubscription<List<CultivationEntity>>? _cultivationsSubscription;
  StreamSubscription<List<LocationEntity>>? _locationsSubscription;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _bootstrap();
  }

  @override
  void dispose() {
    _bootstrapGeneration++;
    _cultivationsSubscription?.cancel();
    _locationsSubscription?.cancel();
    super.dispose();
  }

  Future<void> _bootstrap() async {
    final generation = ++_bootstrapGeneration;
    final hasVisibleData = _cultivations != null;

    await _cultivationsSubscription?.cancel();
    await _locationsSubscription?.cancel();
    _cultivationsSubscription = null;
    _locationsSubscription = null;

    if (mounted) {
      setState(() {
        _loading = !hasVisibleData;
        _liveSyncing = true;
        _errorMessage = null;
        _cultivationsLiveReady = false;
        _locationsLiveReady = false;
      });
    }

    try {
      final results = await Future.wait<Object?>([
        widget.repository.getAll(),
        widget.locationRepository.getAll(),
      ]);
      if (!mounted || generation != _bootstrapGeneration) return;

      final cultivations = results[0] as List<CultivationEntity>;
      final locations = results[1] as List<LocationEntity>;
      setState(() {
        _cultivations = List<CultivationEntity>.unmodifiable(cultivations);
        _locations = List<LocationEntity>.unmodifiable(locations);
        _loading = false;
        _errorMessage = null;
      });
      _subscribeToLiveData(
        initialCultivations: cultivations,
        initialLocations: locations,
        generation: generation,
      );
    } catch (_) {
      if (!mounted || generation != _bootstrapGeneration) return;
      setState(() {
        _loading = false;
        _liveSyncing = false;
        _errorMessage = 'No se pudieron cargar los cultivos.';
      });
    }
  }

  void _subscribeToLiveData({
    required List<CultivationEntity> initialCultivations,
    required List<LocationEntity> initialLocations,
    required int generation,
  }) {
    var cultivationWatcherReady = initialCultivations.isEmpty;
    var locationWatcherReady = initialLocations.isEmpty;
    _cultivationsLiveReady = cultivationWatcherReady;
    _locationsLiveReady = locationWatcherReady;
    _updateLiveSyncing(generation);

    try {
      _cultivationsSubscription = widget.repository.watchAll().listen(
        (items) {
          if (!mounted || generation != _bootstrapGeneration) return;
          // Isar may emit a stale empty fireImmediately snapshot while the
          // watcher attaches after a restart. Preserve the persisted read
          // until a real live snapshot arrives.
          if (!cultivationWatcherReady && items.isEmpty) return;
          cultivationWatcherReady = true;
          _cultivationsLiveReady = true;
          setState(() {
            _cultivations = List<CultivationEntity>.unmodifiable(items);
          });
          _updateLiveSyncing(generation);
        },
        onError: (_, _) => _handleLiveError(generation),
        onDone: () {
          cultivationWatcherReady = true;
          _cultivationsLiveReady = true;
          _updateLiveSyncing(generation);
        },
      );
    } catch (_) {
      _handleLiveError(generation);
    }

    try {
      _locationsSubscription = widget.locationRepository.watchAll().listen(
        (items) {
          if (!mounted || generation != _bootstrapGeneration) return;
          if (!locationWatcherReady && items.isEmpty) return;
          locationWatcherReady = true;
          _locationsLiveReady = true;
          setState(() {
            _locations = List<LocationEntity>.unmodifiable(items);
          });
          _updateLiveSyncing(generation);
        },
        onError: (_, _) => _handleLiveError(generation),
        onDone: () {
          locationWatcherReady = true;
          _locationsLiveReady = true;
          _updateLiveSyncing(generation);
        },
      );
    } catch (_) {
      _handleLiveError(generation);
    }
  }

  void _updateLiveSyncing(int generation) {
    if (!mounted || generation != _bootstrapGeneration) return;
    final syncing = !(_cultivationsLiveReady && _locationsLiveReady);
    if (_liveSyncing == syncing) return;
    setState(() => _liveSyncing = syncing);
  }

  void _handleLiveError(int generation) {
    if (!mounted || generation != _bootstrapGeneration) return;
    setState(() {
      _liveSyncing = false;
      _errorMessage = 'No se pudieron actualizar los cultivos.';
    });
  }

  void _retry() {
    _bootstrap();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _syncLocationFilter();
  }

  void _syncLocationFilter() {
    try {
      final value = GoRouterState.of(context).uri.queryParameters['ubicacion'];
      final normalized = value?.trim();
      final next = normalized == null || normalized.isEmpty ? null : normalized;
      if (_routeFilterInitialized && _locationFilter == next) return;
      _routeFilterInitialized = true;
      _locationFilter = next;
    } catch (_) {
      // The view is also used in focused widget tests without GoRouter.
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final scaffold = Scaffold(body: _buildBody());

    if (!widget.shellInteractionsEnabled) return scaffold;
    return ShellFabConfigScope(
      config: _cultivations?.isEmpty == true && _locationFilter == null
          ? null
          : ShellFabConfig(
              id: 'cultivos',
              label: 'Nuevo',
              icon: Icons.add,
              heroTag: 'fab_cultivos',
              onPressed: () => context.pushNamed(AppRoutes.nameCultivoNuevo),
            ),
      child: scaffold,
    );
  }

  Widget _buildBody() {
    final cultivations = _cultivations;
    if (cultivations == null && _loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (cultivations == null) {
      return _CultivationLoadError(
        message: _errorMessage ?? 'No se pudieron cargar los cultivos.',
        onRetry: _retry,
      );
    }

    final list = _CultivationListBody(
      cultivations: cultivations,
      locationNames: {
        for (final location in _locations) location.uuid: location.name,
      },
      filter: _filter,
      locationUuid: _locationFilter,
      onFilterChanged: (filter) => setState(() => _filter = filter),
    );

    return Column(
      children: [
        if (_errorMessage != null)
          _CultivationLoadErrorBanner(message: _errorMessage!, onRetry: _retry),
        Expanded(
          child: Stack(
            children: [
              list,
              if (_liveSyncing)
                const Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: LinearProgressIndicator(minHeight: 2),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class _CultivationLoadError extends StatelessWidget {
  const _CultivationLoadError({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: AppEmptyState(
        icon: Icons.error_outline,
        title: 'No se pudieron cargar los cultivos',
        message: message,
        action: FilledButton.icon(
          onPressed: onRetry,
          icon: const Icon(Icons.refresh),
          label: const Text('Reintentar'),
        ),
      ),
    );
  }
}

class _CultivationLoadErrorBanner extends StatelessWidget {
  const _CultivationLoadErrorBanner({
    required this.message,
    required this.onRetry,
  });

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return MaterialBanner(
      content: Text(message),
      actions: [
        TextButton(onPressed: onRetry, child: const Text('Reintentar')),
      ],
    );
  }
}

class _CultivationListBody extends StatelessWidget {
  const _CultivationListBody({
    required this.cultivations,
    required this.locationNames,
    required this.filter,
    this.locationUuid,
    required this.onFilterChanged,
  });

  final List<CultivationEntity> cultivations;
  final Map<String, String> locationNames;
  final _CultivationFilter filter;
  final String? locationUuid;
  final ValueChanged<_CultivationFilter> onFilterChanged;

  @override
  Widget build(BuildContext context) {
    final scopedCultivations = locationUuid == null
        ? cultivations
        : cultivations
              .where((item) => item.locationUuid == locationUuid)
              .toList();
    final active = scopedCultivations.where((item) => item.isActive).toList();
    final previous = scopedCultivations
        .where((item) => item.status != CropStatus.active)
        .toList();
    final visibleActive = filter == _CultivationFilter.history
        ? const <CultivationEntity>[]
        : active;
    final visiblePrevious = filter == _CultivationFilter.active
        ? const <CultivationEntity>[]
        : previous;
    // Keep the last item above the dock and its floating action at scroll end.
    final bottom =
        ShellInsets.bottomSafePadding(context) +
        ShellInsets.fabContentClearance;

    if (scopedCultivations.isEmpty) {
      return Column(
        children: [
          _CultivationFilterBar(
            filter: filter,
            total: 0,
            active: 0,
            history: 0,
            onChanged: onFilterChanged,
          ),
          Expanded(
            child: AppEmptyState(
              illustrationAsset: 'assets/images/location_garden.webp',
              title: locationUuid == null
                  ? 'Empieza a cuidar tus plantas y cultivos'
                  : 'Sin cultivos en esta ubicación',
              message: locationUuid == null
                  ? 'Organiza una planta, un huerto o una siembra en un solo lugar.'
                  : 'Puedes vincular una planta, huerto o siembra desde esta ubicación.',
              action: locationUuid == null
                  ? FilledButton.icon(
                      onPressed: () =>
                          context.pushNamed(AppRoutes.nameCultivoNuevo),
                      icon: const Icon(Icons.add),
                      label: const Text('Agregar planta o cultivo'),
                    )
                  : null,
            ),
          ),
        ],
      );
    }

    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: _CultivationFilterBar(
            filter: filter,
            total: scopedCultivations.length,
            active: active.length,
            history: previous.length,
            onChanged: onFilterChanged,
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 10)),
        if (visibleActive.isNotEmpty)
          _CultivationSection(
            title: 'Activos',
            items: visibleActive,
            locationNames: locationNames,
          ),
        if (visiblePrevious.isNotEmpty)
          _CultivationSection(
            title: 'Historial',
            items: visiblePrevious,
            locationNames: locationNames,
          ),
        if (visibleActive.isEmpty && visiblePrevious.isEmpty)
          SliverFillRemaining(
            hasScrollBody: false,
            child: AppEmptyState(
              icon: Icons.search_off_outlined,
              title: filter == _CultivationFilter.active
                  ? 'No hay cultivos activos'
                  : 'No hay cultivos en el historial',
              message: 'Prueba con otro filtro para ver tus cultivos.',
              action: OutlinedButton.icon(
                onPressed: () => onFilterChanged(_CultivationFilter.all),
                icon: const Icon(Icons.filter_alt_off_outlined),
                label: const Text('Limpiar filtros'),
              ),
            ),
          ),
        SliverToBoxAdapter(child: SizedBox(height: bottom)),
      ],
    );
  }
}

class _CultivationFilterBar extends StatelessWidget {
  const _CultivationFilterBar({
    required this.filter,
    required this.total,
    required this.active,
    required this.history,
    required this.onChanged,
  });

  final _CultivationFilter filter;
  final int total;
  final int active;
  final int history;
  final ValueChanged<_CultivationFilter> onChanged;

  @override
  Widget build(BuildContext context) {
    final options = [
      (_CultivationFilter.all, 'Todos', total, Icons.eco_outlined),
      (_CultivationFilter.active, 'Activos', active, Icons.play_circle_outline),
      (
        _CultivationFilter.history,
        'Historial',
        history,
        Icons.history_outlined,
      ),
    ];
    return SizedBox(
      height: 60,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.fromLTRB(8, 6, 8, 6),
        children: [
          for (final (value, label, count, icon) in options)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: AppDirectoryFilterChip(
                key: ValueKey<String>('cultivos-filter-${value.name}'),
                label: label,
                count: count,
                icon: icon,
                selected: filter == value,
                onTap: () => onChanged(value),
              ),
            ),
        ],
      ),
    );
  }
}

class _CultivationSection extends StatelessWidget {
  const _CultivationSection({
    required this.title,
    required this.items,
    required this.locationNames,
  });

  final String title;
  final List<CultivationEntity> items;
  final Map<String, String> locationNames;

  @override
  Widget build(BuildContext context) {
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      sliver: SliverList(
        delegate: SliverChildListDelegate([
          Padding(
            padding: const EdgeInsets.fromLTRB(4, 2, 4, 8),
            child: Text(
              '$title · ${items.length}',
              style: Theme.of(
                context,
              ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800),
            ),
          ),
          for (final item in items)
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 720),
              child: CultivationCard(
                cultivation: item,
                locationName: locationNames[item.locationUuid],
                onLocationTap: locationNames.containsKey(item.locationUuid)
                    ? () => context.push(
                        AppRoutes.ubicacionDetallePath(item.locationUuid!),
                      )
                    : null,
                onTap: () => context.pushNamed(
                  AppRoutes.nameCultivoDetalle,
                  pathParameters: {'uuid': item.uuid},
                ),
              ),
            ),
        ]),
      ),
    );
  }
}
