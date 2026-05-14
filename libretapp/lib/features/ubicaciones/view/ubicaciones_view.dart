/// features \u203a ubicaciones \u203a view \u203a ubicaciones_view \u2014 main view for the farm locations list.
library;

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:libretapp/app/widgets/widgets.dart';
import 'package:libretapp/core/di/injection.dart';
import 'package:libretapp/core/router/app_routes.dart';
import 'package:libretapp/features/directorio/animales/infrastructure/animal_repository.dart';
import 'package:libretapp/features/ubicaciones/bloc/ubicaciones_bloc.dart';
import 'package:libretapp/features/ubicaciones/bloc/ubicaciones_event.dart';
import 'package:libretapp/features/ubicaciones/bloc/ubicaciones_state.dart';
import 'package:libretapp/features/ubicaciones/domain/entities/location_entity.dart';
import 'package:libretapp/features/ubicaciones/domain/enums/location_type.dart';
import 'package:libretapp/features/ubicaciones/widgets/widgets.dart';

class UbicacionesView extends StatefulWidget {
  const UbicacionesView({super.key, this.animalRepository});

  final AnimalRepository? animalRepository;

  @override
  State<UbicacionesView> createState() => _UbicacionesViewState();
}

class _UbicacionesViewState extends State<UbicacionesView> {
  AnimalRepository? _animalRepository;
  Map<String, int> _animalCounts = <String, int>{};
  Map<String, double> _averageWeights = <String, double>{};
  String _lastCountsKey = '';
  final Set<String> _expandedRanchos = {};

  @override
  void initState() {
    super.initState();
    _animalRepository =
        widget.animalRepository ??
        (locator.isRegistered<AnimalRepository>()
            ? locator<AnimalRepository>()
            : null);
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _refreshCounts(List<LocationEntity> locations) async {
    final repository = _animalRepository;
    if (repository == null) {
      if (!mounted) return;
      setState(() {
        _animalCounts = <String, int>{};
        _averageWeights = <String, double>{};
      });
      return;
    }

    final ids = locations.map((e) => e.uuid).toSet();
    final animals = await repository.getAll();
    final counts = <String, int>{};
    final weightTotals = <String, double>{};
    final weightSamples = <String, int>{};
    for (final animal in animals) {
      final locId = animal.currentPaddockId ?? animal.initialLocationId;
      if (locId == null || !ids.contains(locId)) continue;
      counts[locId] = (counts[locId] ?? 0) + 1;

      final weight = animal.weight;
      if (weight == null) continue;
      weightTotals[locId] = (weightTotals[locId] ?? 0) + weight;
      weightSamples[locId] = (weightSamples[locId] ?? 0) + 1;
    }

    final avgWeights = <String, double>{};
    for (final entry in weightTotals.entries) {
      final samples = weightSamples[entry.key] ?? 0;
      if (samples <= 0) continue;
      avgWeights[entry.key] = entry.value / samples;
    }

    if (!mounted) return;
    if (mapEquals(_animalCounts, counts) &&
        mapEquals(_averageWeights, avgWeights)) {
      return;
    }
    setState(() {
      _animalCounts = counts;
      _averageWeights = avgWeights;
    });
  }

  void _scheduleRefreshCounts(List<LocationEntity> locations) {
    final key = locations.map((e) => e.uuid).join('|');
    if (key == _lastCountsKey) return;
    _lastCountsKey = key;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _refreshCounts(locations);
    });
  }

  void _showFiltersPlaceholder(BuildContext context) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Filtros próximamente')));
  }

  void _showSuccessMessage(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = ShellInsets.bottomSafePadding(context);
    final listBottomPadding = bottomInset + 2;

    final fabConfig = ShellFabConfig(
      id: 'ubicaciones',
      label: 'Registrar',
      icon: Icons.add,
      heroTag: 'fab_ubicaciones',
      onPressed: _openPrimaryActionsMenu,
    );

    return ShellFabConfigScope(
      config: fabConfig,
      child: BlocBuilder<UbicacionesBloc, UbicacionesState>(
        builder: (context, state) {
          final isSearching = state is UbicacionesLoaded && state.isSearching;
          return ShellChromeScope(
            visible: !isSearching,
            child: Scaffold(
              backgroundColor: Theme.of(
                context,
              ).colorScheme.surfaceContainerHighest.withValues(alpha: 0.25),
              body: NestedScrollView(
                headerSliverBuilder: (context, innerScrolled) => [
                  UbicacionesSearchAppBar(
                    onOpenFilters: () => _showFiltersPlaceholder(context),
                  ),
                ],
                body: _buildBody(state, listBottomPadding),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildBody(UbicacionesState state, double listBottomPadding) {
    if (state is UbicacionesInitial || state is UbicacionesLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state is UbicacionesError) {
      return Center(child: Text('Error: ${state.message}'));
    }

    if (state is! UbicacionesLoaded) {
      return const SizedBox.shrink();
    }

    _scheduleRefreshCounts(state.allUbicaciones);
    final ubicaciones = state.visibleUbicaciones;
    final allByUuid = {
      for (final location in state.allUbicaciones) location.uuid: location,
    };

    return RefreshIndicator(
      onRefresh: () async =>
          context.read<UbicacionesBloc>().add(const LoadUbicaciones()),
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          const SliverToBoxAdapter(child: SizedBox(height: 4)),
          if (ubicaciones.isEmpty)
            SliverFillRemaining(
              hasScrollBody: false,
              child: _CenteredSection(
                padding: EdgeInsets.fromLTRB(16, 12, 16, listBottomPadding),
                child: LocationEmptyView(onCreate: _openCreatePage),
              ),
            )
          else
            ..._buildGroupedSliver(
              ubicaciones,
              state.isSearching || state.searchQuery.isNotEmpty,
              allByUuid,
              listBottomPadding,
            ),
        ],
      ),
    );
  }

  // ── Hierarchy helpers ─────────────────────────────────────────────────────

  Widget _buildCard(
    LocationEntity location,
    Map<String, LocationEntity> allByUuid,
  ) {
    final parentName = location.parentUuid == null
        ? null
        : allByUuid[location.parentUuid]?.name;
    return LocationCard(
      location: location,
      animalCount: _animalCounts[location.uuid] ?? 0,
      averageWeightKg: _averageWeights[location.uuid],
      parentName: parentName,
      onTap: () => context.push(AppRoutes.ubicacionDetallePath(location.uuid)),
      onEdit: () => _openEditPage(location.uuid),
      onDelete: () => _confirmDelete(context, location),
    );
  }

  List<Widget> _buildHierarchyWidgets(
    List<LocationEntity> all,
    Map<String, LocationEntity> allByUuid,
  ) {
    final ranchos = all.where((l) => l.type.isRootType).toList();
    final childrenByParent = <String, List<LocationEntity>>{};
    final standalones = <LocationEntity>[];

    for (final loc in all) {
      if (loc.type.isRootType) continue;
      final parentId = loc.parentUuid;
      if (parentId != null && allByUuid.containsKey(parentId)) {
        childrenByParent.putIfAbsent(parentId, () => []).add(loc);
      } else {
        standalones.add(loc);
      }
    }

    final widgets = <Widget>[];

    for (final rancho in ranchos) {
      final children = childrenByParent[rancho.uuid] ?? [];
      final isExpanded = _expandedRanchos.contains(rancho.uuid);

      widgets.add(_buildCard(rancho, allByUuid));

      if (children.isNotEmpty) {
        widgets.add(const SizedBox(height: 4));
        widgets.add(
          _RanchoChildrenToggle(
            count: children.length,
            isExpanded: isExpanded,
            onToggle: () => setState(() {
              if (isExpanded) {
                _expandedRanchos.remove(rancho.uuid);
              } else {
                _expandedRanchos.add(rancho.uuid);
              }
            }),
          ),
        );

        if (isExpanded) {
          for (final child in children) {
            widgets.add(const SizedBox(height: 8));
            widgets.add(
              Padding(
                padding: const EdgeInsets.only(left: 12),
                child: _buildCard(child, allByUuid),
              ),
            );
          }
          widgets.add(const SizedBox(height: 4));
        }
      }

      widgets.add(const SizedBox(height: 14));
    }

    if (standalones.isNotEmpty) {
      if (ranchos.isNotEmpty) {
        widgets.add(const _SectionLabel('Ubicaciones independientes'));
        widgets.add(const SizedBox(height: 8));
      }
      for (int i = 0; i < standalones.length; i++) {
        widgets.add(_buildCard(standalones[i], allByUuid));
        if (i < standalones.length - 1) {
          widgets.add(const SizedBox(height: 14));
        }
      }
    }

    return widgets;
  }

  List<Widget> _buildGroupedSliver(
    List<LocationEntity> ubicaciones,
    bool isSearching,
    Map<String, LocationEntity> allByUuid,
    double bottomPadding,
  ) {
    if (isSearching) {
      // Flat list for search results.
      final items = <Widget>[];
      for (int i = 0; i < ubicaciones.length; i++) {
        items.add(_buildCard(ubicaciones[i], allByUuid));
        if (i < ubicaciones.length - 1) items.add(const SizedBox(height: 14));
      }
      return [
        SliverPadding(
          padding: EdgeInsets.fromLTRB(16, 12, 16, bottomPadding),
          sliver: SliverList(delegate: SliverChildListDelegate(items)),
        ),
      ];
    }

    final hierarchyWidgets = _buildHierarchyWidgets(ubicaciones, allByUuid);
    return [
      SliverPadding(
        padding: EdgeInsets.fromLTRB(16, 12, 16, bottomPadding),
        sliver: SliverList(delegate: SliverChildListDelegate(hierarchyWidgets)),
      ),
    ];
  }

  Future<void> _openCreatePage() async {
    final created = await context.pushNamed<bool>(AppRoutes.nameUbicacionNueva);
    if (!mounted || created != true) return;
    context.read<UbicacionesBloc>().add(const LoadUbicaciones());
    _showSuccessMessage('Ubicación creada correctamente');
  }

  Future<void> _openEditPage(String uuid) async {
    final updated = await context.pushNamed<bool>(
      AppRoutes.nameUbicacionEditar,
      pathParameters: {'uuid': uuid},
    );
    if (!mounted || updated != true) return;
    context.read<UbicacionesBloc>().add(const LoadUbicaciones());
    _showSuccessMessage('Ubicación actualizada correctamente');
  }

  Future<void> _openPrimaryActionsMenu() async {
    final action = await Navigator.of(context).push<_UbicacionesPrimaryAction>(
      MaterialPageRoute<_UbicacionesPrimaryAction>(
        fullscreenDialog: true,
        builder: (pageContext) => const ShellChromeScope(
          visible: false,
          child: _UbicacionesPrimaryActionsPage(),
        ),
      ),
    );

    if (!mounted || action == null) return;

    switch (action) {
      case _UbicacionesPrimaryAction.createLocation:
        await _openCreatePage();
        break;
      case _UbicacionesPrimaryAction.maintenance:
        await context.pushNamed(AppRoutes.nameAgendaNuevo);
        break;
      case _UbicacionesPrimaryAction.assignment:
        await context.pushNamed(AppRoutes.nameRegistroMovimiento);
        break;
    }
  }

  Future<void> _confirmDelete(
    BuildContext context,
    LocationEntity location,
  ) async {
    // Check how many animals are assigned before showing dialog.
    int animalCount = 0;
    final repo = _animalRepository;
    if (repo != null) {
      try {
        final animals = await repo.getByPaddock(location.uuid);
        animalCount = animals.length;
      } catch (_) {
        // If the check fails, proceed with normal confirmation dialog.
      }
    }

    if (!context.mounted) return;

    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar ubicación'),
        content: animalCount > 0
            ? Text(
                '${location.name}" tiene $animalCount '
                '${animalCount == 1 ? 'animal asignado' : 'animales asignados'}. '
                'Al eliminar, esos animales quedarán sin ubicación. '
                '¿Deseas continuar de todas formas?',
              )
            : Text(
                '¿Deseas borrar "${location.name}"? Esta acción no se puede deshacer.',
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

    if (shouldDelete == true && context.mounted) {
      context.read<UbicacionesBloc>().add(DeleteUbicacion(location.uuid));
    }
  }
}

class UbicacionesSearchAppBar extends StatefulWidget {
  const UbicacionesSearchAppBar({super.key, required this.onOpenFilters});

  final VoidCallback onOpenFilters;

  @override
  State<UbicacionesSearchAppBar> createState() =>
      _UbicacionesSearchAppBarState();
}

class _UbicacionesSearchAppBarState extends State<UbicacionesSearchAppBar> {
  late final TextEditingController _searchController;
  late final FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _focusNode = FocusNode();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return BlocBuilder<UbicacionesBloc, UbicacionesState>(
      buildWhen: (previous, current) {
        if (previous is UbicacionesLoaded && current is UbicacionesLoaded) {
          return previous.isSearching != current.isSearching ||
              previous.searchQuery != current.searchQuery;
        }
        return previous.runtimeType != current.runtimeType;
      },
      builder: (context, state) {
        final loaded = state is UbicacionesLoaded ? state : null;
        final isSearching = loaded?.isSearching ?? false;
        final query = loaded?.searchQuery ?? '';
        _syncController(query);

        if (isSearching && !_focusNode.hasFocus) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) _focusNode.requestFocus();
          });
        }

        return SliverAppBar(
          pinned: true,
          floating: true,
          snap: true,
          expandedHeight: kToolbarHeight,
          automaticallyImplyLeading: false,
          titleSpacing: 0,
          title: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: _buildTitleBar(context, theme, isSearching),
          ),
        );
      },
    );
  }

  Widget _buildTitleBar(
    BuildContext context,
    ThemeData theme,
    bool isSearching,
  ) {
    final showSearchIcon = !isSearching;

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 200),
      child: isSearching
          ? _buildSearchBar(context, theme)
          : _buildNormalBar(context, theme, showSearchIcon: showSearchIcon),
    );
  }

  Widget _buildNormalBar(
    BuildContext context,
    ThemeData theme, {
    required bool showSearchIcon,
  }) {
    return SizedBox(
      key: const ValueKey('ubicaciones_normal_appbar'),
      height: 46,
      child: Row(
        children: [
          const SizedBox(width: 8),
          Text(
            'Ubicaciones',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const Spacer(),
          if (showSearchIcon)
            IconButton(
              tooltip: 'Buscar ubicaciones',
              icon: const Icon(Icons.search),
              onPressed: () {
                context.read<UbicacionesBloc>().add(
                  const ToggleSearch(enabled: true),
                );
              },
            ),
          IconButton(
            tooltip: 'Filtros',
            icon: const Icon(Icons.tune),
            onPressed: widget.onOpenFilters,
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar(BuildContext context, ThemeData theme) {
    final bloc = context.read<UbicacionesBloc>();

    return SizedBox(
      key: const ValueKey('ubicaciones_search_appbar'),
      height: 56,
      child: Row(
        children: [
          IconButton(
            tooltip: 'Cerrar búsqueda',
            icon: const Icon(Icons.arrow_back),
            onPressed: () => bloc.add(const ToggleSearch(enabled: false)),
          ),
          Expanded(
            child: TextField(
              controller: _searchController,
              focusNode: _focusNode,
              autofocus: true,
              textInputAction: TextInputAction.search,
              onChanged: (value) => bloc.add(SearchQueryChanged(value)),
              decoration: InputDecoration(
                hintText: 'Buscar ubicaciones',
                isDense: true,
                filled: true,
                fillColor: theme.colorScheme.surface,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isEmpty
                    ? null
                    : IconButton(
                        tooltip: 'Limpiar',
                        icon: const Icon(Icons.close),
                        onPressed: () => bloc.add(ClearSearch()),
                      ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: theme.colorScheme.primary,
                    width: 1.6,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 4),
        ],
      ),
    );
  }

  void _syncController(String value) {
    if (_searchController.text == value) return;
    _searchController.value = TextEditingValue(
      text: value,
      selection: TextSelection.collapsed(offset: value.length),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.label);
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Text(
        label,
        style: theme.textTheme.labelMedium?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.6,
        ),
      ),
    );
  }
}

class _RanchoChildrenToggle extends StatelessWidget {
  const _RanchoChildrenToggle({
    required this.count,
    required this.isExpanded,
    required this.onToggle,
  });

  final int count;
  final bool isExpanded;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final label = isExpanded
        ? 'Ocultar $count ${count == 1 ? 'ubicación' : 'ubicaciones'}'
        : 'Ver $count ${count == 1 ? 'ubicación' : 'ubicaciones'}';
    return GestureDetector(
      onTap: onToggle,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 2),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(width: 20),
            SizedBox(
              width: 20,
              child: Divider(
                height: 1,
                color: theme.colorScheme.outlineVariant,
              ),
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(width: 2),
            Icon(
              isExpanded ? Icons.expand_less : Icons.expand_more,
              size: 14,
              color: theme.colorScheme.primary,
            ),
          ],
        ),
      ),
    );
  }
}

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

enum _UbicacionesPrimaryAction { createLocation, maintenance, assignment }

class _UbicacionesPrimaryActionsPage extends StatelessWidget {
  const _UbicacionesPrimaryActionsPage();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Acciones principales')),
      body: SafeArea(
        top: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(8, 8, 8, 10),
          children: [
            ListTile(
              leading: const Icon(Icons.add_location_alt_outlined),
              title: const Text('Agregar ubicación'),
              subtitle: const Text('Crear una nueva ubicación en el mapa'),
              onTap: () => Navigator.of(
                context,
              ).pop(_UbicacionesPrimaryAction.createLocation),
            ),
            ListTile(
              leading: const Icon(Icons.build_circle_outlined),
              title: const Text('Registrar mantenimiento'),
              subtitle: const Text('Abrir eventos de mantenimiento'),
              onTap: () => Navigator.of(
                context,
              ).pop(_UbicacionesPrimaryAction.maintenance),
            ),
            ListTile(
              leading: const Icon(Icons.swap_horiz_outlined),
              title: const Text('Registrar asignación / movimiento'),
              subtitle: const Text(
                'Asignar o mover animales entre ubicaciones',
              ),
              onTap: () => Navigator.of(
                context,
              ).pop(_UbicacionesPrimaryAction.assignment),
            ),
          ],
        ),
      ),
    );
  }
}
