import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:libretapp/app/theme/theme_bloc.dart';
import 'package:libretapp/app/widgets/widgets.dart';
import 'package:libretapp/features/directorio/animales/animals.dart'
    hide ClearSearch;
import 'package:libretapp/features/directorio/bloc/animales_tab_bloc.dart';
import 'package:libretapp/features/directorio/bloc/directorio_bloc.dart';
import 'package:libretapp/features/directorio/bloc/directorio_event.dart';
import 'package:libretapp/features/directorio/bloc/directorio_state.dart';
import 'package:libretapp/features/directorio/bloc/lotes_tab_bloc.dart';
import 'package:libretapp/features/directorio/lotes/lotes_list_view.dart';
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
  bool _isSearching = false;
  bool _showTabBar = true;
  bool _showLotesTab = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _getTabLength(), vsync: this);
    _searchController = TextEditingController();
    _searchFocusNode = FocusNode();

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
    super.dispose();
  }

  int _getTabLength() => _showLotesTab ? 2 : 1;

  void _toggleLotesTab() {
    setState(() {
      _showLotesTab = !_showLotesTab;
      // Reinitialize TabController with new length
      _tabController.dispose();
      _tabController = TabController(length: _getTabLength(), vsync: this);
      _tabController.addListener(_onTabChange);
      // Hide TabBar when lotes is hidden
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

          return ShellChromeScope(
            visible: !shouldHideChrome,
            child: ShellFabConfigScope(
              config: fabConfig,
              child: Scaffold(
                appBar: AppBar(
                  title: _isSearching
                      ? TextField(
                          focusNode: _searchFocusNode,
                          controller: _searchController,
                          onChanged: _onSearchChanged,
                          decoration: InputDecoration(
                            hintText: 'Buscar...',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: const BorderSide(color: Colors.white),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: const BorderSide(color: Colors.white),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: const BorderSide(color: Colors.white),
                            ),
                            hintStyle: TextStyle(color: Colors.grey.shade400),
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
                      : const Text('Directorio'),
                  actions: !_isSearching
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
                      : [],
                  bottom:
                      (!_isSearching &&
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
        child:
            AnimalesListView(), // Only displays animal list, no TabBar/search
      ),
      // Lotes Tab
      if (_showLotesTab)
        BlocProvider<LotesTabBloc>.value(
          value: context.read<LotesTabBloc>(),
          child: const LotesListView(),
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
    if (state.searchResults.isEmpty) {
      return const Center(child: Text('No se encontraron resultados'));
    }

    return ListView.builder(
      itemCount: state.searchResults.length,
      itemBuilder: (context, index) {
        final result = state.searchResults[index];
        return ListTile(
          leading: _buildTypeIcon(result.type),
          title: Text(result.name),
          subtitle: Text(result.type),
          onTap: () {
            // TODO: Navegar al detalle del item
          },
        );
      },
    );
  }

  Widget _buildTypeIcon(String type) {
    IconData icon;
    Color color;

    switch (type) {
      case 'animal':
        icon = Icons.pets;
        color = Colors.blue;
        break;
      case 'lote':
        icon = Icons.agriculture;
        color = Colors.green;
        break;
      case 'ubicacion':
        icon = Icons.location_on;
        color = Colors.orange;
        break;
      default:
        icon = Icons.help;
        color = Colors.grey;
    }

    return Icon(icon, color: color);
  }
}
