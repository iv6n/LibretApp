/// features \u203a directorio \u203a view \u203a directorio_view \u2014 main view for the directorio feature.
library;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:libretapp/app/widgets/widgets.dart';
import 'package:libretapp/core/widgets/widgets.dart';
import 'package:libretapp/core/router/app_routes.dart';
import 'package:libretapp/features/directorio/animales/animals.dart'
    hide ClearSearch;
import 'package:libretapp/features/directorio/animales/bloc/animales_event.dart'
    as animales_event;
import 'package:libretapp/features/directorio/bloc/animales_tab_bloc.dart';
import 'package:libretapp/features/directorio/bloc/directorio_bloc.dart';
import 'package:libretapp/features/directorio/bloc/directorio_event.dart';
import 'package:libretapp/features/directorio/bloc/directorio_state.dart';
import 'package:libretapp/features/directorio/bloc/lotes_tab_bloc.dart';
import 'package:libretapp/features/directorio/cultivos/view/cultivos_list_view.dart';
import 'package:libretapp/features/directorio/lotes/lotes_list_view.dart';
import 'package:libretapp/features/ubicaciones/view/ubicaciones_page.dart';
import 'package:libretapp/l10n/app_localizations.dart';
import 'package:libretapp/theme/theme.dart';

class DirectorioView extends StatefulWidget {
  const DirectorioView({super.key});

  @override
  State<DirectorioView> createState() => _DirectorioViewState();
}

class _DirectorioViewState extends State<DirectorioView>
    with TickerProviderStateMixin {
  static const _animalesTabKey = ValueKey<String>('directorio_animales_tab');
  static const _lotesTabKey = ValueKey<String>('directorio_lotes_tab');
  static const _cultivosTabKey = ValueKey<String>('directorio_cultivos_tab');
  static const _ubicacionesTabKey = ValueKey<String>(
    'directorio_ubicaciones_tab',
  );
  late TabController _tabController;
  late TextEditingController _searchController;
  late FocusNode _searchFocusNode;
  late TextEditingController _animalSearchController;
  late FocusNode _animalSearchFocusNode;
  bool _isSearching = false;
  String? _lastRouteTabParam;
  List<DirectorioSection> _orderedSections = defaultDirectorioSectionOrder;
  Set<DirectorioSection> _visibleSections = defaultDirectorioVisibleSections;
  DirectorioSection? _lastNotifiedSection;

  @override
  void initState() {
    super.initState();
    _tabController = _createTabController(
      initialSection: DirectorioSection.animales,
    );
    _lastNotifiedSection = _activeSection;
    _searchController = TextEditingController();
    _searchFocusNode = FocusNode();
    _animalSearchController = TextEditingController();
    _animalSearchFocusNode = FocusNode();

    // Cargar datos al inicializar
    context.read<DirectorioBloc>().add(const LoadDirectorioData());
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _applyInitialRouteTab();
  }

  @override
  void dispose() {
    _tabController.removeListener(_onTabChange);
    _tabController.dispose();
    _searchController.dispose();
    _searchFocusNode.dispose();
    _animalSearchController.dispose();
    _animalSearchFocusNode.dispose();
    super.dispose();
  }

  List<DirectorioSection> get _activeSections =>
      _orderedSections.where(_visibleSections.contains).toList(growable: false);

  DirectorioSection get _activeSection {
    final sections = _activeSections;
    if (sections.isEmpty) return DirectorioSection.animales;
    final index = _tabController.index.clamp(0, sections.length - 1);
    return sections[index];
  }

  TabController _createTabController({
    required DirectorioSection initialSection,
  }) {
    final sections = _activeSections;
    final initialIndex = sections.indexOf(initialSection);
    final controller = TabController(
      length: sections.length,
      vsync: this,
      initialIndex: initialIndex < 0 ? 0 : initialIndex,
    );
    controller.addListener(_onTabChange);
    return controller;
  }

  void _replaceTabController(DirectorioSection preferredSection) {
    _tabController.removeListener(_onTabChange);
    _tabController.dispose();
    _tabController = _createTabController(initialSection: preferredSection);
    _lastNotifiedSection = _activeSection;
  }

  void _applyInitialRouteTab() {
    DirectorioSection? target;
    String? tab;
    try {
      tab = GoRouterState.of(context).uri.queryParameters['tab'];
      target = _sectionFromRouteParam(tab);
    } catch (_) {
      target = null;
    }

    if (_lastRouteTabParam == tab) return;
    _lastRouteTabParam = tab;

    if (target == null || !_visibleSections.contains(target)) return;
    final targetIndex = _activeSections.indexOf(target);
    if (targetIndex < 0 || targetIndex == _tabController.index) return;
    _tabController.index = targetIndex;
    _lastNotifiedSection = target;
    context.read<DirectorioBloc>().add(ChangeDirectorioSection(target));
  }

  DirectorioSection? _sectionFromRouteParam(String? value) {
    switch (value) {
      case 'animales':
        return DirectorioSection.animales;
      case 'lotes':
        return DirectorioSection.lotes;
      case 'cultivos':
        return DirectorioSection.cultivos;
      case 'ubicaciones':
        return DirectorioSection.ubicaciones;
    }
    return null;
  }

  void _toggleSectionVisibility(DirectorioSection section, bool visible) {
    final updatedVisible = Set<DirectorioSection>.of(_visibleSections);
    if (visible) {
      updatedVisible.add(section);
    } else {
      if (updatedVisible.length == 1 && updatedVisible.contains(section)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('El directorio debe mostrar al menos una categoria.'),
          ),
        );
        return;
      }
      updatedVisible.remove(section);
    }

    _applySectionConfig(
      orderedSections: _orderedSections,
      visibleSections: updatedVisible,
    );
  }

  void _moveSection(DirectorioSection section, int delta) {
    final currentIndex = _orderedSections.indexOf(section);
    if (currentIndex < 0) return;
    final nextIndex = currentIndex + delta;
    if (nextIndex < 0 || nextIndex >= _orderedSections.length) return;

    final updatedOrder = List<DirectorioSection>.of(_orderedSections);
    final moved = updatedOrder.removeAt(currentIndex);
    updatedOrder.insert(nextIndex, moved);

    _applySectionConfig(
      orderedSections: updatedOrder,
      visibleSections: _visibleSections,
    );
  }

  void _applySectionConfig({
    required List<DirectorioSection> orderedSections,
    required Set<DirectorioSection> visibleSections,
  }) {
    if (visibleSections.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('El directorio debe mostrar al menos una categoria.'),
        ),
      );
      return;
    }

    final currentSection = _activeSection;
    final nextSection = visibleSections.contains(currentSection)
        ? currentSection
        : orderedSections.firstWhere(
            visibleSections.contains,
            orElse: () => DirectorioSection.animales,
          );

    setState(() {
      _orderedSections = List<DirectorioSection>.of(orderedSections);
      _visibleSections = Set<DirectorioSection>.of(visibleSections);
      _replaceTabController(nextSection);
    });

    context.read<DirectorioBloc>().add(
      SetDirectorioSectionConfig(
        orderedSections: orderedSections,
        visibleSections: visibleSections,
        activeSection: nextSection,
      ),
    );
  }

  void _onTabChange() {
    // TabController notifies once per animation frame. Rebuilding the whole
    // directory and notifying the bloc for every frame made the Cultivos tab
    // look as if it were loading again. Only publish a settled section.
    if (!mounted ||
        _tabController.indexIsChanging ||
        _tabController.offset.abs() > 0.001) {
      return;
    }

    final section = _activeSection;
    if (_lastNotifiedSection == section) return;
    _lastNotifiedSection = section;
    setState(() {});
    context.read<DirectorioBloc>().add(ChangeDirectorioSection(section));
  }

  void _onSearchChanged(String query) {
    context.read<DirectorioBloc>().add(PerformCombinedSearch(query));
  }

  void _toggleSearch() {
    setState(() {
      _isSearching = !_isSearching;
      if (!_isSearching) {
        _searchController.clear();
        _searchFocusNode.unfocus();
        context.read<DirectorioBloc>().add(const ClearSearch());
      } else {
        context.read<DirectorioBloc>().add(const StartSearch());
        // Request focus and show keyboard
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _searchFocusNode.requestFocus();
        });
      }
    });
  }

  void _syncAnimalSearchController(String value) {
    if (_animalSearchController.text == value) return;
    _animalSearchController.value = TextEditingValue(
      text: value,
      selection: TextSelection.collapsed(offset: value.length),
    );
  }

  void _clearAnimalSelection(BuildContext context) {
    final bloc = context.read<AnimalesBloc>();
    bloc.add(const ClearAnimalSelection());
    bloc.add(const animales_event.ClearSearch());
    _animalSearchFocusNode.unfocus();
  }

  Widget _buildAnimalSelectionTitle(
    BuildContext context,
    AnimalesLoaded state,
  ) {
    final l10n = AppLocalizations.of(context);
    _syncAnimalSearchController(state.searchQuery);
    final bloc = context.read<AnimalesBloc>();

    if (state.isSearching && !_animalSearchFocusNode.hasFocus) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _animalSearchFocusNode.requestFocus();
      });
    }

    return Row(
      children: [
        AppIconButton(
          icon: Icons.arrow_back,
          tooltip: MaterialLocalizations.of(context).backButtonTooltip,
          onPressed: () => _clearAnimalSelection(context),
        ),
        const SizedBox(width: AppSpacing.xxs),
        if (!state.isSearching) ...[
          Expanded(
            child: Text(
              l10n.animalsSelectedCount(state.selectedCount),
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
            ),
          ),
          AppIconButton(
            icon: Icons.search,
            tooltip: l10n.animalsSearchHint,
            onPressed: () => bloc.add(const ToggleSearch(enabled: true)),
          ),
        ] else ...[
          Expanded(
            child: AppSearchBar(
              controller: _animalSearchController,
              focusNode: _animalSearchFocusNode,
              onChanged: (value) => bloc.add(SearchQueryChanged(value)),
              hintText: l10n.animalsSearchHint,
              onClose: () {
                _animalSearchFocusNode.unfocus();
                bloc.add(const ToggleSearch(enabled: false));
                bloc.add(const animales_event.ClearSearch());
              },
              onClear: () => bloc.add(const animales_event.ClearSearch()),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildDirectoryMenu(BuildContext context) {
    return MenuAnchor(
      menuChildren: [
        DirectorioTabsMenuContent(
          orderedSections: _orderedSections,
          visibleSections: _visibleSections,
          labelForSection: _labelForSection,
          iconForSection: _iconForSection,
          onVisibilityChanged: _toggleSectionVisibility,
          onMoveSection: _moveSection,
        ),
      ],
      builder: (context, controller, child) {
        return AppIconButton(
          icon: Icons.more_vert,
          tooltip: 'Más opciones del directorio',
          onPressed: () {
            if (controller.isOpen) {
              controller.close();
            } else {
              controller.open();
            }
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // Detect keyboard visibility
    final keyboardVisible = MediaQuery.of(context).viewInsets.bottom > 0;

    // Hide navbar and FAB when search is active or keyboard is visible
    final shouldHideChrome = _isSearching || keyboardVisible;

    return BlocBuilder<DirectorioBloc, DirectorioState>(
      builder: (context, state) {
        if (state is DirectorioLoading) {
          return const Scaffold(body: AppLoadingIndicator());
        }

        if (state is DirectorioError) {
          return Scaffold(
            appBar: AppBar(title: const Text('Directorio')),
            body: AppEmptyState(
              icon: Icons.error_outline,
              title: 'No se pudo cargar el directorio',
              message: state.message,
            ),
          );
        }

        if (state is DirectorioLoaded) {
          _syncBlocState(state);
          // FAB config is null when searching or keyboard is visible (hides FAB)
          final fabConfig = null;

          return BlocBuilder<AnimalesBloc, AnimalesState>(
            builder: (context, animalesState) {
              final animalesLoaded = animalesState is AnimalesLoaded
                  ? animalesState
                  : null;
              final isAnimalSelectionMode =
                  _activeSection == DirectorioSection.animales &&
                  (animalesLoaded?.isSelectionMode ?? false);

              return ShellChromeScope(
                visible: !shouldHideChrome,
                child: ShellFabConfigScope(
                  config: fabConfig,
                  child: Scaffold(
                    appBar: AppBar(
                      automaticallyImplyLeading: false,
                      title: isAnimalSelectionMode
                          ? _buildAnimalSelectionTitle(context, animalesLoaded!)
                          : _isSearching
                          ? SizedBox(
                              width: MediaQuery.sizeOf(
                                context,
                              ).width.clamp(220.0, 420.0),
                              child: AppSearchBar(
                                focusNode: _searchFocusNode,
                                controller: _searchController,
                                onChanged: _onSearchChanged,
                                hintText: 'Buscar en el directorio',
                                onClose: _toggleSearch,
                              ),
                            )
                          : Text(
                              _directoryTitle(),
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                      actions: isAnimalSelectionMode
                          ? const []
                          : !_isSearching
                          ? [
                              AppIconButton(
                                icon: Icons.search,
                                tooltip: 'Buscar en el directorio',
                                onPressed: _toggleSearch,
                              ),
                              _buildDirectoryMenu(context),
                            ]
                          : const [],
                      bottom:
                          (!isAnimalSelectionMode &&
                              !_isSearching &&
                              !keyboardVisible &&
                              _activeSections.length > 1)
                          ? AppSegmentedTabBar(
                              keyPrefix: 'directorio_segmented_tab',
                              controller: _tabController,
                              variant: AppSegmentedTabBarVariant.colorAccented,
                              items: _activeSections
                                  .map(
                                    (section) => AppSegmentedTabItem(
                                      label: _labelForSection(section),
                                      icon: _iconForSection(section),
                                      accentColor: _accentColorForSection(
                                        context,
                                        section,
                                      ),
                                    ),
                                  )
                                  .toList(),
                            )
                          : null,
                    ),
                    body: _buildDirectoryBody(),
                  ),
                ),
              );
            },
          );
        }

        return const Scaffold(body: Center(child: Text('Estado desconocido')));
      },
    );
  }

  Widget _buildDirectoryBody() {
    if (_isSearching) return _buildSearchResults();
    return _buildTabContent();
  }

  Widget _buildSearchResults() {
    return BlocBuilder<DirectorioBloc, DirectorioState>(
      builder: (context, state) {
        final results = state is DirectorioLoaded
            ? state.searchResults
            : const <CombinedSearchResult>[];
        return DirectorioSearchResultsPanel(results: results);
      },
    );
  }

  Widget _buildTabContent() {
    final sections = _activeSections;
    return TabBarView(
      controller: _tabController,
      physics: sections.length > 1
          ? const AlwaysScrollableScrollPhysics()
          : const NeverScrollableScrollPhysics(),
      children: sections.map(_buildSectionContent).toList(),
    );
  }

  Widget _buildSectionContent(DirectorioSection section) {
    final isActive = section == _activeSection && !_isSearching;
    switch (section) {
      case DirectorioSection.animales:
        return KeyedSubtree(
          key: _animalesTabKey,
          child: BlocProvider<AnimalesTabBloc>.value(
            value: context.read<AnimalesTabBloc>(),
            child: AnimalesListView(shellInteractionsEnabled: isActive),
          ),
        );
      case DirectorioSection.lotes:
        return KeyedSubtree(
          key: _lotesTabKey,
          child: BlocProvider<LotesTabBloc>.value(
            value: context.read<LotesTabBloc>(),
            child: LotesListView(shellInteractionsEnabled: isActive),
          ),
        );
      case DirectorioSection.cultivos:
        return KeyedSubtree(
          key: _cultivosTabKey,
          child: _DeferredCultivosTab(active: isActive),
        );
      case DirectorioSection.ubicaciones:
        return KeyedSubtree(
          key: _ubicacionesTabKey,
          child: UbicacionesPage(
            showHeader: false,
            shellInteractionsEnabled: isActive,
          ),
        );
    }
  }

  String _directoryTitle() {
    if (_activeSections.length > 1) return 'Directorio';
    return _labelForSection(_activeSections.first);
  }

  String _labelForSection(DirectorioSection section) {
    switch (section) {
      case DirectorioSection.animales:
        return 'Animales';
      case DirectorioSection.lotes:
        return 'Lotes';
      case DirectorioSection.cultivos:
        return 'Cultivos';
      case DirectorioSection.ubicaciones:
        return 'Ubicaciones';
    }
  }

  IconData _iconForSection(DirectorioSection section) {
    switch (section) {
      case DirectorioSection.animales:
        return Icons.pets;
      case DirectorioSection.lotes:
        return Icons.fence;
      case DirectorioSection.cultivos:
        return Icons.eco_outlined;
      case DirectorioSection.ubicaciones:
        return Icons.location_on_outlined;
    }
  }

  Color _accentColorForSection(
    BuildContext context,
    DirectorioSection section,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    switch (section) {
      case DirectorioSection.animales:
        return isDark ? const Color(0xFFE58A67) : const Color(0xFFA65332);
      case DirectorioSection.lotes:
        return isDark ? const Color(0xFF7FC7AA) : AppColors.primary;
      case DirectorioSection.cultivos:
        return isDark ? const Color(0xFFE4B65D) : AppColors.amber;
      case DirectorioSection.ubicaciones:
        return isDark ? const Color(0xFF7FB2CE) : AppColors.secondary;
    }
  }

  void _syncBlocState(DirectorioLoaded state) {
    if (state.activeSection == _activeSection &&
        _sameOrderedSections(state.orderedSections, _orderedSections) &&
        _sameSections(state.visibleSections, _visibleSections)) {
      return;
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      setState(() {
        _orderedSections = List<DirectorioSection>.of(state.orderedSections);
        _visibleSections = Set<DirectorioSection>.of(state.visibleSections);
        _replaceTabController(state.activeSection);
      });
    });
  }

  bool _sameOrderedSections(
    List<DirectorioSection> a,
    List<DirectorioSection> b,
  ) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }

  bool _sameSections(Set<DirectorioSection> a, Set<DirectorioSection> b) {
    if (a.length != b.length) return false;
    for (final section in a) {
      if (!b.contains(section)) return false;
    }
    return true;
  }
}

/// Keeps Cultivos out of the initial Directorio build, then keeps its state
/// alive after the first visit so switching tabs does not restart its reads.
class _DeferredCultivosTab extends StatefulWidget {
  const _DeferredCultivosTab({required this.active});

  final bool active;

  @override
  State<_DeferredCultivosTab> createState() => _DeferredCultivosTabState();
}

class _DeferredCultivosTabState extends State<_DeferredCultivosTab> {
  late bool _activated = widget.active;

  @override
  void didUpdateWidget(covariant _DeferredCultivosTab oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.active) _activated = true;
  }

  @override
  Widget build(BuildContext context) {
    if (!_activated) {
      // The page is intentionally not created until the tab settles, but a
      // small placeholder keeps the incoming TabBarView pane from looking
      // like a blank or broken screen during the swipe animation.
      return const ColoredBox(
        color: Colors.transparent,
        child: AppLoadingIndicator.inline(),
      );
    }
    return CultivosListView(shellInteractionsEnabled: widget.active);
  }
}

class DirectorioTabsMenuContent extends StatelessWidget {
  const DirectorioTabsMenuContent({
    required this.orderedSections,
    required this.visibleSections,
    required this.labelForSection,
    required this.iconForSection,
    required this.onVisibilityChanged,
    required this.onMoveSection,
    super.key,
  });

  final List<DirectorioSection> orderedSections;
  final Set<DirectorioSection> visibleSections;
  final String Function(DirectorioSection) labelForSection;
  final IconData Function(DirectorioSection) iconForSection;
  final void Function(DirectorioSection, bool) onVisibilityChanged;
  final void Function(DirectorioSection, int) onMoveSection;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 344,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (var index = 0; index < orderedSections.length; index++)
            _DirectorioTabsMenuRow(
              section: orderedSections[index],
              index: index,
              lastIndex: orderedSections.length - 1,
              visible: visibleSections.contains(orderedSections[index]),
              label: labelForSection(orderedSections[index]),
              icon: iconForSection(orderedSections[index]),
              onVisibilityChanged: onVisibilityChanged,
              onMoveSection: onMoveSection,
            ),
        ],
      ),
    );
  }
}

class _DirectorioTabsMenuRow extends StatelessWidget {
  const _DirectorioTabsMenuRow({
    required this.section,
    required this.index,
    required this.lastIndex,
    required this.visible,
    required this.label,
    required this.icon,
    required this.onVisibilityChanged,
    required this.onMoveSection,
  });

  final DirectorioSection section;
  final int index;
  final int lastIndex;
  final bool visible;
  final String label;
  final IconData icon;
  final void Function(DirectorioSection, bool) onVisibilityChanged;
  final void Function(DirectorioSection, int) onMoveSection;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      child: Row(
        children: [
          Checkbox(
            key: ValueKey<String>('directorio_menu_visible_${section.name}'),
            value: visible,
            onChanged: (value) => onVisibilityChanged(section, value ?? false),
          ),
          Icon(icon, size: 20),
          const SizedBox(width: 10),
          Expanded(child: Text(label)),
          IconButton(
            key: ValueKey<String>('directorio_menu_move_up_${section.name}'),
            tooltip: 'Subir $label',
            onPressed: index == 0 ? null : () => onMoveSection(section, -1),
            icon: const Icon(Icons.keyboard_arrow_up),
          ),
          IconButton(
            key: ValueKey<String>('directorio_menu_move_down_${section.name}'),
            tooltip: 'Bajar $label',
            onPressed: index == lastIndex
                ? null
                : () => onMoveSection(section, 1),
            icon: const Icon(Icons.keyboard_arrow_down),
          ),
        ],
      ),
    );
  }
}

class DirectorioSearchResultsPanel extends StatelessWidget {
  const DirectorioSearchResultsPanel({required this.results, super.key});

  final List<CombinedSearchResult> results;

  @override
  Widget build(BuildContext context) {
    if (results.isEmpty) {
      return const AppEmptyState(
        compact: true,
        icon: Icons.search_off,
        title: 'No se encontraron resultados',
        message: 'Prueba con otro término de búsqueda.',
      );
    }

    return ListView.builder(
      itemCount: results.length,
      itemBuilder: (context, index) {
        final result = results[index];
        return ListTile(
          leading: buildDirectorioTypeIcon(result.type),
          title: Text(result.name),
          subtitle: Text(result.type.label),
          onTap: () => openDirectorioSearchResult(context, result),
        );
      },
    );
  }
}

Widget buildDirectorioTypeIcon(CombinedSearchType type) {
  IconData icon;
  Color color;

  switch (type) {
    case CombinedSearchType.animal:
      icon = Icons.pets;
      color = AppColors.secondary;
      break;
    case CombinedSearchType.lote:
      icon = Icons.agriculture;
      color = AppColors.success;
      break;
    case CombinedSearchType.cultivo:
      icon = Icons.eco_outlined;
      color = AppColors.primary;
      break;
    case CombinedSearchType.ubicacion:
      icon = Icons.location_on;
      color = AppColors.warning;
      break;
  }

  return Icon(icon, color: color);
}

void openDirectorioSearchResult(
  BuildContext context,
  CombinedSearchResult result,
) {
  if (result.id.isEmpty) return;

  try {
    switch (result.type) {
      case CombinedSearchType.animal:
        context.pushNamed(
          AppRoutes.nameAnimalDetalle,
          pathParameters: {'uuid': result.id},
        );
        break;
      case CombinedSearchType.lote:
        context.pushNamed(
          AppRoutes.nameLoteDetalle,
          pathParameters: {'uuid': result.id},
        );
        break;
      case CombinedSearchType.cultivo:
        context.pushNamed(
          AppRoutes.nameCultivoDetalle,
          pathParameters: {'uuid': result.id},
        );
        break;
      case CombinedSearchType.ubicacion:
        context.pushNamed(
          AppRoutes.nameUbicacionDetalle,
          pathParameters: {'uuid': result.id},
        );
        break;
    }
  } catch (error) {
    debugPrint('Directorio navigation failed: $error');
  }
}
