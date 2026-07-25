/// features › perfil › view › perfil_view — profile hub with tabs.
library;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:libretapp/app/widgets/widgets.dart';
import 'package:libretapp/core/widgets/app_empty_state.dart';import 'package:libretapp/features/perfil/bloc/perfil_bloc.dart';
import 'package:libretapp/features/perfil/bloc/perfil_event.dart';
import 'package:libretapp/features/perfil/bloc/perfil_state.dart';
import 'package:libretapp/features/perfil/data/perfil_model.dart';
import 'package:libretapp/features/perfil/view/perfil_settings_sheet.dart';
import 'package:libretapp/features/perfil/view/tabs/perfil_biblioteca_tab.dart';
import 'package:libretapp/features/perfil/widgets/profile_header_card.dart';

class PerfilView extends StatelessWidget {
  const PerfilView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PerfilBloc, PerfilState>(
      builder: (context, state) {
        if (state is PerfilInitial || state is PerfilLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state is PerfilError) {
          return AppEmptyState(
            icon: Icons.error_outline,
            title: 'No se pudo cargar el perfil',
            message: state.message,
            action: FilledButton.icon(
              onPressed: () =>
                  context.read<PerfilBloc>().add(const LoadPerfil()),
              icon: const Icon(Icons.refresh),
              label: const Text('Reintentar'),
            ),
          );
        }

        final perfil = state is PerfilLoaded
            ? state.perfil
            : (state as PerfilUpdated).perfil;

        return _PerfilTabbedContent(perfil: perfil);
      },
    );
  }
}

class _PerfilTabbedContent extends StatefulWidget {
  const _PerfilTabbedContent({required this.perfil});

  final Perfil perfil;

  @override
  State<_PerfilTabbedContent> createState() => _PerfilTabbedContentState();
}

class _PerfilTabbedContentState extends State<_PerfilTabbedContent>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return NestedScrollView(
      headerSliverBuilder: (context, innerBoxIsScrolled) => [
        SliverToBoxAdapter(child: ProfileHeaderCard(perfil: widget.perfil)),
        SliverPersistentHeader(
          pinned: true,
          delegate: AppSegmentedTabBarSliverDelegate(
            tabBar: AppSegmentedTabBar(
              controller: _tabController,
              items: const [
                AppSegmentedTabItem(
                  label: 'Biblioteca',
                  icon: Icons.menu_book_outlined,
                ),
                AppSegmentedTabItem(
                  label: 'Ajustes',
                  icon: Icons.settings_outlined,
                ),
              ],
            ),
          ),
        ),      ],
      body: TabBarView(
        controller: _tabController,
        children: [
          const PerfilBibliotecaTab(),
          PerfilSettingsContent(perfil: widget.perfil),
        ],
      ),
    );
  }
}
