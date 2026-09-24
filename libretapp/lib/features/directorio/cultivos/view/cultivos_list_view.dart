/// Directory list for independent cultivations.
library;

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:libretapp/app/widgets/widgets.dart';
import 'package:libretapp/core/di/injection.dart';
import 'package:libretapp/core/router/app_routes.dart';
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
      config: ShellFabConfig(
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
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 12),
            FilledButton.tonal(
              onPressed: onRetry,
              child: const Text('Reintentar'),
            ),
          ],
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
    // Leave the last card clear of both the shell navigation and the
    // directory FAB when the list reaches its end.
    final bottom = ShellInsets.bottomSafePadding(context) + 160;

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
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  maxWidth: 560,
                  maxHeight: 430,
                ),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 20, 16, 32),
                  child: SizedBox(
                    height: 330,
                    child: Card(
                      margin: EdgeInsets.zero,
                      clipBehavior: Clip.antiAlias,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                        side: BorderSide(
                          color: Theme.of(
                            context,
                          ).colorScheme.outlineVariant.withValues(alpha: 0.45),
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(22),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            CircleAvatar(
                              radius: 29,
                              backgroundColor: Theme.of(
                                context,
                              ).colorScheme.primaryContainer,
                              child: Icon(
                                Icons.eco_outlined,
                                size: 30,
                                color: Theme.of(
                                  context,
                                ).colorScheme.onPrimaryContainer,
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    locationUuid != null
                                        ? 'Sin cultivos en esta ubicación'
                                        : 'Registra tu primer cultivo',
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleMedium
                                        ?.copyWith(fontWeight: FontWeight.w800),
                                  ),
                                  const SizedBox(height: 7),
                                  Text(
                                    locationUuid != null
                                        ? 'Puedes vincular una planta, huerto o siembra desde esta ubicación.'
                                        : 'Organiza desde una planta individual hasta una siembra de varias hectáreas.',
                                    style: Theme.of(context).textTheme.bodySmall
                                        ?.copyWith(
                                          color: Theme.of(
                                            context,
                                          ).colorScheme.onSurfaceVariant,
                                        ),
                                  ),
                                  const SizedBox(height: 14),
                                  const Wrap(
                                    spacing: 7,
                                    runSpacing: 7,
                                    children: [
                                      _EmptyInfoChip(
                                        icon: Icons.local_florist_outlined,
                                        label: 'Planta',
                                      ),
                                      _EmptyInfoChip(
                                        icon: Icons.yard_outlined,
                                        label: 'Huerto',
                                      ),
                                      _EmptyInfoChip(
                                        icon: Icons.grass_outlined,
                                        label: 'Siembra',
                                      ),
                                    ],
                                  ),
                                  if (locationUuid == null) ...[
                                    const SizedBox(height: 16),
                                    FilledButton.icon(
                                      onPressed: () => context.pushNamed(
                                        AppRoutes.nameCultivoNuevo,
                                      ),
                                      icon: const Icon(Icons.add),
                                      label: const Text('Nuevo cultivo'),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
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
            child: Center(
              child: Text(
                filter == _CultivationFilter.active
                    ? 'No hay cultivos activos'
                    : 'No hay cultivos en el historial',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          ),
        SliverToBoxAdapter(child: SizedBox(height: bottom)),
      ],
    );
  }
}

class _EmptyInfoChip extends StatelessWidget {
  const _EmptyInfoChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: scheme.onSurfaceVariant),
          const SizedBox(width: 4),
          Text(
            label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: scheme.onSurfaceVariant,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
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
      height: 48,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.fromLTRB(8, 6, 8, 6),
        children: [
          for (final (value, label, count, icon) in options)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: FilterChip(
                key: ValueKey<String>('cultivos-filter-${value.name}'),
                selected: filter == value,
                showCheckmark: false,
                avatar: Icon(icon, size: 15),
                label: Text('$label $count'),
                onSelected: (_) => onChanged(value),
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
