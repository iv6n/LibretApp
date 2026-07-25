/// features › ubicaciones › view › ubicaciones_search_app_bar — header with search for ubicaciones.
library;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:libretapp/core/widgets/app_search_bar.dart';
import 'package:libretapp/features/ubicaciones/bloc/ubicaciones_bloc.dart';
import 'package:libretapp/features/ubicaciones/bloc/ubicaciones_event.dart';
import 'package:libretapp/features/ubicaciones/bloc/ubicaciones_state.dart';

class UbicacionesSearchAppBar extends StatefulWidget {
  const UbicacionesSearchAppBar({super.key});

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
    return BlocBuilder<UbicacionesBloc, UbicacionesState>(
      buildWhen: (previous, current) {
        if (previous is UbicacionesLoaded && current is UbicacionesLoaded) {
          return previous.isSearching != current.isSearching ||
              previous.searchQuery != current.searchQuery ||
              previous.filteredCount != current.filteredCount ||
              previous.totalAnimalsAssigned != current.totalAnimalsAssigned;
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

        return Material(
          color: Theme.of(context).colorScheme.surface,
          elevation: isSearching ? 1 : 0,
          child: SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(8, 8, 8, 8),
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                child: isSearching
                    ? _buildSearchMode(context, query)
                    : _buildNormalMode(context, loaded),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildNormalMode(BuildContext context, UbicacionesLoaded? loaded) {
    final theme = Theme.of(context);
    final subtitle = loaded == null
        ? null
        : '${loaded.filteredCount} ubicacion${loaded.filteredCount == 1 ? '' : 'es'}'
            '${loaded.totalAnimalsAssigned > 0 ? ' · ${loaded.totalAnimalsAssigned} animales' : ''}';

    return Row(
      key: const ValueKey('ubicaciones_normal_header'),
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const SizedBox(width: 4),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Ubicaciones',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              if (subtitle != null) ...[
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ],
          ),
        ),
        IconButton(
          tooltip: 'Buscar ubicaciones',
          icon: const Icon(Icons.search),
          onPressed: () => context.read<UbicacionesBloc>().add(
            const ToggleSearch(enabled: true),
          ),
        ),
      ],
    );
  }

  Widget _buildSearchMode(BuildContext context, String query) {
    final bloc = context.read<UbicacionesBloc>();

    return Row(
      key: const ValueKey('ubicaciones_search_header'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        IconButton(
          tooltip: 'Cerrar búsqueda',
          icon: const Icon(Icons.arrow_back),
          onPressed: () => bloc.add(const ToggleSearch(enabled: false)),
        ),
        Expanded(
          child: AppSearchBar(
            controller: _searchController,
            focusNode: _focusNode,
            hintText: 'Buscar ubicaciones',
            autofocus: true,
            onChanged: (value) => bloc.add(SearchQueryChanged(value)),
            onClear: () => bloc.add(ClearSearch()),
          ),
        ),
      ],
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
