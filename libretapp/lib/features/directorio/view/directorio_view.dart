import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:libretapp/app/theme/theme_bloc.dart';
import 'package:libretapp/app/widgets/widgets.dart';
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
import 'package:libretapp/features/directorio/lotes/lotes_list_view.dart';
import 'package:libretapp/l10n/app_localizations.dart';
//import 'package:libretapp/features/directorio/ubicaciones/ubicaciones_tab.dart';

class DirectorioView extends StatefulWidget {
  const DirectorioView({super.key});

  @override
  State<DirectorioView> createState() => _DirectorioViewState();
}

class _DirectorioViewState extends State<DirectorioView>
    with TickerProviderStateMixin {
  late TabController _tabController;
  late TextEditingController _searchController;
  late FocusNode _searchFocusNode;
  late TextEditingController _animalSearchController;
  late FocusNode _animalSearchFocusNode;
  bool _isSearching = false;
  bool _showTabBar = true;
  bool _showLotesTab = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _searchController = TextEditingController();
    _searchFocusNode = FocusNode();
    _animalSearchController = TextEditingController();
    _animalSearchFocusNode = FocusNode();

    // Cargar datos al inicializar
    context.read<DirectorioBloc>().add(const LoadDirectorioData());

    // Escuchar cambios en el tab
    _tabController.addListener(_onTabChange);
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

  void _toggleLotesTab() {
    setState(() {
      _showLotesTab = !_showLotesTab;
      // If lotes gets hidden while selected, return to animales tab.
      if (!_showLotesTab && _tabController.index == 1) {
        _tabController.animateTo(0);
      }
      if (!_showLotesTab) {
        _showTabBar = false;
      }
    });
  }

  void _toggleTheme() {
    context.read<ThemeBloc>().add(const ThemeToggled());
  }

  void _onTabChange() {
    setState(() {
      if (!_isSearching) {
        _showTabBar = true;
      }
    });

    // Notificar al bloc que el tab cambió
    context.read<DirectorioBloc>().add(
      ChangeDirectorioTab(_tabController.index),
    );
  }

  void _onSearchChanged(String query) {
    if (query.isEmpty) {
      context.read<DirectorioBloc>().add(const ClearSearch());
    } else {
      context.read<DirectorioBloc>().add(PerformCombinedSearch(query));
    }
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

  void _onScroll(ScrollUpdateNotification notification) {
    if (notification.scrollDelta == null) return;

    // Defer setState to avoid calling it during build phase
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        setState(() {
          if (notification.scrollDelta! > 0) {
            // Scrolling down
            _showTabBar = false;
          } else if (notification.scrollDelta! < 0) {
            // Scrolling up
            _showTabBar = true;
          }
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
        IconButton(
          tooltip: MaterialLocalizations.of(context).backButtonTooltip,
          onPressed: () => _clearAnimalSelection(context),
          icon: const Icon(Icons.arrow_back),
        ),
        const SizedBox(width: 4),
        if (!state.isSearching) ...[
          Expanded(
            child: Text(
              l10n.animalsSelectedCount(state.selectedCount),
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
            ),
          ),
          IconButton(
            tooltip: l10n.animalsSearchHint,
            icon: const Icon(Icons.search),
            onPressed: () => bloc.add(const ToggleSearch(enabled: true)),
          ),
        ] else ...[
          Expanded(
            child: TextField(
              controller: _animalSearchController,
              focusNode: _animalSearchFocusNode,
              textInputAction: TextInputAction.search,
              onChanged: (value) => bloc.add(SearchQueryChanged(value)),
              decoration: InputDecoration(
                hintText: l10n.animalsSearchHint,
                isDense: true,
                border: InputBorder.none,
                suffixIcon: IconButton(
                  tooltip: MaterialLocalizations.of(context).clearButtonTooltip,
                  icon: const Icon(Icons.close),
                  onPressed: () {
                    _animalSearchFocusNode.unfocus();
                    bloc.add(const animales_event.ClearSearch());
                  },
                ),
              ),
            ),
          ),
        ],
      ],
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
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (state is DirectorioError) {
          return Scaffold(
            appBar: AppBar(title: const Text('Directorio')),
            body: Center(child: Text('Error: ${state.message}')),
          );
        }

        if (state is DirectorioLoaded) {
          // FAB config is null when searching or keyboard is visible (hides FAB)
          final fabConfig = null;

          return BlocBuilder<AnimalesBloc, AnimalesState>(
            builder: (context, animalesState) {
              final animalesLoaded = animalesState is AnimalesLoaded
                  ? animalesState
                  : null;
              final isAnimalSelectionMode =
                  _tabController.index == 0 &&
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
                          ? TextField(
                              focusNode: _searchFocusNode,
                              controller: _searchController,
                              onChanged: _onSearchChanged,
                              decoration: InputDecoration(
                                hintText: 'Buscar...',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: const BorderSide(
                                    color: Colors.white,
                                  ),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: const BorderSide(
                                    color: Colors.white,
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: const BorderSide(
                                    color: Colors.white,
                                  ),
                                ),
                                hintStyle: TextStyle(
                                  color: Colors.grey.shade400,
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 12,
                                ),
                                suffixIcon: IconButton(
                                  icon: const Icon(
                                    Icons.close,
                                    color: Colors.white,
                                  ),
                                  onPressed: _toggleSearch,
                                ),
                              ),
                              style: const TextStyle(color: Colors.white),
                            )
                          : Text(
                              _showLotesTab ? 'Directorio' : 'Animales',
                              style: const TextStyle(
                                fontSize: 21.5,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                      actions: isAnimalSelectionMode
                          ? const []
                          : !_isSearching
                          ? [
                              IconButton(
                                icon: const Icon(Icons.search),
                                onPressed: _toggleSearch,
                              ),
                              PopupMenuButton<String>(
                                icon: const Icon(Icons.more_vert),
                                onSelected: (value) {
                                  if (value == 'theme') {
                                    _toggleTheme();
                                  } else if (value == 'lotes') {
                                    _toggleLotesTab();
                                  }
                                },
                                itemBuilder: (BuildContext context) => [
                                  PopupMenuItem<String>(
                                    value: 'theme',
                                    child: Row(
                                      children: [
                                        Icon(
                                          Theme.of(context).brightness ==
                                                  Brightness.dark
                                              ? Icons.light_mode
                                              : Icons.dark_mode,
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          Theme.of(context).brightness ==
                                                  Brightness.dark
                                              ? 'Modo claro'
                                              : 'Modo oscuro',
                                        ),
                                      ],
                                    ),
                                  ),
                                  PopupMenuItem<String>(
                                    value: 'lotes',
                                    child: Row(
                                      children: [
                                        Icon(
                                          _showLotesTab
                                              ? Icons.visibility_off
                                              : Icons.visibility,
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          _showLotesTab
                                              ? 'Ocultar lotes'
                                              : 'Mostrar lotes',
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ]
                          : const [],
                      bottom:
                          (!isAnimalSelectionMode &&
                              !_isSearching &&
                              _showTabBar &&
                              !keyboardVisible &&
                              _showLotesTab)
                          ? TabBar(
                              controller: _tabController,
                              tabs: [
                                const Tab(text: 'Animales'),
                                if (_showLotesTab) const Tab(text: 'Lotes'),
                                //Tab(text: 'Ubicaciones'),
                              ],
                            )
                          : null,
                    ),
                    body: _isSearching && state.searchResults.isNotEmpty
                        ? _buildSearchResults(state)
                        : NotificationListener<ScrollUpdateNotification>(
                            onNotification: (notification) {
                              _onScroll(notification);
                              return false;
                            },
                            child: _buildTabContent(),
                          ),
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

  Widget _buildTabContent() {
    final children = [
      // Animales Tab
      BlocProvider<AnimalesTabBloc>.value(
        value: context.read<AnimalesTabBloc>(),
        child: const AnimalesListView(),
      ),
      BlocProvider<LotesTabBloc>.value(
        value: context.read<LotesTabBloc>(),
        child: _showLotesTab
            ? const LotesListView()
            : const Center(child: Text('Tab de lotes desactivado')),
      ),
    ];

    return TabBarView(
      controller: _tabController,
      physics: _showLotesTab
          ? const AlwaysScrollableScrollPhysics()
          : const NeverScrollableScrollPhysics(),
      children: children,
    );
  }

  Widget _buildSearchResults(DirectorioLoaded state) {
    return DirectorioSearchResultsPanel(results: state.searchResults);
  }
}

class DirectorioSearchResultsPanel extends StatelessWidget {
  const DirectorioSearchResultsPanel({required this.results, super.key});

  final List<CombinedSearchResult> results;

  @override
  Widget build(BuildContext context) {
    if (results.isEmpty) {
      return const Center(child: Text('No se encontraron resultados'));
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
      color = Colors.blue;
      break;
    case CombinedSearchType.lote:
      icon = Icons.agriculture;
      color = Colors.green;
      break;
    case CombinedSearchType.ubicacion:
      icon = Icons.location_on;
      color = Colors.orange;
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
