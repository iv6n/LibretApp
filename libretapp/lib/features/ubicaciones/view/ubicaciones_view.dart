import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:libretapp/app/widgets/widgets.dart';
import 'package:libretapp/core/di/injection.dart';
import 'package:libretapp/features/directorio/animales/infrastructure/animal_repository.dart';
import 'package:libretapp/features/ubicaciones/bloc/ubicaciones_bloc.dart';
import 'package:libretapp/features/ubicaciones/bloc/ubicaciones_event.dart';
import 'package:libretapp/features/ubicaciones/bloc/ubicaciones_state.dart';
import 'package:libretapp/features/ubicaciones/domain/entities/location_entity.dart';
import 'package:libretapp/features/ubicaciones/widgets/widgets.dart';

class UbicacionesView extends StatefulWidget {
  const UbicacionesView({super.key, this.animalRepository});

  final AnimalRepository? animalRepository;

  @override
  State<UbicacionesView> createState() => _UbicacionesViewState();
}

class _UbicacionesViewState extends State<UbicacionesView> {
  late final ScrollController _scrollController;
  AnimalRepository? _animalRepository;
  Map<String, int> _animalCounts = <String, int>{};
  String _lastCountsKey = '';
  bool _isAtTop = true;

  @override
  void initState() {
    super.initState();
    _animalRepository =
        widget.animalRepository ??
        (locator.isRegistered<AnimalRepository>()
            ? locator<AnimalRepository>()
            : null);
    _scrollController = ScrollController()..addListener(_handleScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_handleScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _handleScroll() {
    if (!_scrollController.hasClients) return;
    final atTop = _scrollController.position.pixels <= 0;
    if (atTop == _isAtTop) return;
    setState(() => _isAtTop = atTop);
  }

  Future<void> _refreshCounts(List<LocationEntity> locations) async {
    final repository = _animalRepository;
    if (repository == null) {
      if (!mounted) return;
      setState(() => _animalCounts = <String, int>{});
      return;
    }

    final ids = locations.map((e) => e.uuid).toSet();
    final animals = await repository.getAll();
    final counts = <String, int>{};
    for (final animal in animals) {
      final locId = animal.currentPaddockId ?? animal.initialLocationId;
      if (locId == null || !ids.contains(locId)) continue;
      counts[locId] = (counts[locId] ?? 0) + 1;
    }

    if (!mounted) return;
    if (mapEquals(_animalCounts, counts)) return;
    setState(() => _animalCounts = counts);
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

  @override
  Widget build(BuildContext context) {
    final bottomInset = ShellInsets.bottomSafePadding(context);
    final listBottomPadding = bottomInset + 2;

    final fabConfig = ShellFabConfig(
      id: 'ubicaciones',
      label: 'Agregar',
      icon: Icons.add_location_alt_outlined,
      heroTag: 'fab_ubicaciones',
      onPressed: () => _openForm(context),
    );

    return ShellFabConfigScope(
      config: fabConfig,
      child: BlocBuilder<UbicacionesBloc, UbicacionesState>(
        builder: (context, state) {
          final isSearching = state is UbicacionesLoaded && state.isSearching;
          return ShellChromeScope(
            visible: !isSearching,
            child: Scaffold(
              body: NestedScrollView(
                controller: _scrollController,
                headerSliverBuilder: (context, innerScrolled) => [
                  UbicacionesSearchAppBar(
                    isAtTop: _isAtTop,
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
                child: const LocationEmptyView(),
              ),
            )
          else
            SliverPadding(
              padding: EdgeInsets.fromLTRB(16, 12, 16, listBottomPadding),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    if (index.isOdd) {
                      return const SizedBox(height: 12);
                    }
                    final itemIndex = index ~/ 2;
                    final location = ubicaciones[itemIndex];
                    return LocationCard(
                      location: location,
                      animalCount: _animalCounts[location.uuid] ?? 0,
                      onEdit: () => _openForm(context, initial: location),
                      onDelete: () => _confirmDelete(context, location),
                    );
                  },
                  childCount: ubicaciones.isEmpty
                      ? 0
                      : (ubicaciones.length * 2) - 1,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _openForm(
    BuildContext context, {
    LocationEntity? initial,
  }) async {
    final created = await showModalBottomSheet<LocationEntity>(
      context: context,
      isScrollControlled: true,
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: LocationFormSheet(initial: initial),
      ),
    );

    if (!context.mounted || created == null) return;
    context.read<UbicacionesBloc>().add(UpsertUbicacion(created));
  }

  Future<void> _confirmDelete(
    BuildContext context,
    LocationEntity location,
  ) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar ubicación'),
        content: Text(
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
  const UbicacionesSearchAppBar({
    super.key,
    required this.isAtTop,
    required this.onOpenFilters,
  });

  final bool isAtTop;
  final VoidCallback onOpenFilters;

  @override
  State<UbicacionesSearchAppBar> createState() =>
      _UbicacionesSearchAppBarState();
}

class _UbicacionesSearchAppBarState extends State<UbicacionesSearchAppBar> {
  late final TextEditingController _searchController;
  late final FocusNode _focusNode;
  bool _inlineVisible = true;

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

        final double expandedHeight = isSearching
            ? kToolbarHeight
            : (widget.isAtTop ? 106 : kToolbarHeight);

        if (!widget.isAtTop && _inlineVisible) {
          _updateInlineVisible(0, allowInline: false);
        }

        return SliverAppBar(
          pinned: true,
          floating: true,
          snap: true,
          expandedHeight: expandedHeight,
          automaticallyImplyLeading: false,
          titleSpacing: 0,
          title: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: _buildTitleBar(context, theme, isSearching),
          ),
          flexibleSpace: isSearching || !widget.isAtTop
              ? null
              : LayoutBuilder(
                  builder: (context, constraints) {
                    final settings = context
                        .dependOnInheritedWidgetOfExactType<
                          FlexibleSpaceBarSettings
                        >();
                    final minExtent = settings?.minExtent ?? kToolbarHeight;
                    final maxExtent =
                        settings?.maxExtent ?? constraints.biggest.height;
                    final currentExtent = settings?.currentExtent ?? maxExtent;
                    final denominator = (maxExtent - minExtent);
                    final t = denominator == 0
                        ? 1.0
                        : (currentExtent - minExtent) / denominator;
                    _updateInlineVisible(t, allowInline: widget.isAtTop);
                    return Align(
                      alignment: Alignment.bottomCenter,
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(12, 0, 12, 10),
                        child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 180),
                          child: _inlineVisible
                              ? _buildInlineSearch(theme)
                              : const SizedBox.shrink(),
                        ),
                      ),
                    );
                  },
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
    final showSearchIcon = !isSearching && !_inlineVisible;

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

  Widget _buildInlineSearch(ThemeData theme) {
    return SizedBox(
      key: const ValueKey('ubicaciones_inline_search'),
      height: 44,
      child: TextField(
        controller: _searchController,
        readOnly: true,
        onTap: () => context.read<UbicacionesBloc>().add(
          const ToggleSearch(enabled: true),
        ),
        decoration: InputDecoration(
          hintText: 'Buscar ubicaciones',
          isDense: true,
          filled: true,
          fillColor: theme.colorScheme.surface,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 10,
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
    );
  }

  void _syncController(String value) {
    if (_searchController.text == value) return;
    _searchController.value = TextEditingValue(
      text: value,
      selection: TextSelection.collapsed(offset: value.length),
    );
  }

  void _updateInlineVisible(double t, {required bool allowInline}) {
    final visible = allowInline && t > 0.25;
    if (visible == _inlineVisible) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      setState(() {
        _inlineVisible = visible;
      });
    });
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
