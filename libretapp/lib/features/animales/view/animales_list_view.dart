import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:libretapp/core/database/isar_database.dart';
import 'package:libretapp/core/di/injection.dart';
import 'package:libretapp/features/animales/bloc/animales_bloc.dart';
import 'package:libretapp/features/animales/bloc/animales_event.dart';
import 'package:libretapp/features/animales/bloc/animales_state.dart';
import 'package:libretapp/features/animales/domain/animal_domain.dart';
import 'package:libretapp/features/animales/widgets/animal_card.dart';
import 'package:libretapp/features/animales/widgets/animal_create_form.dart';
import 'package:libretapp/features/animales/widgets/animal_batch_manager.dart';
import 'package:libretapp/features/animales/widgets/animal_filter_bar.dart';
import 'package:libretapp/features/ubicaciones/domain/entities/location_entity.dart';
import 'package:libretapp/features/ubicaciones/infrastructure/repositories/isar_location_repository.dart';
import 'package:libretapp/l10n/app_localizations.dart';
import 'package:libretapp/app/app_shell.dart';

class AnimalesListView extends StatefulWidget {
  const AnimalesListView({super.key});

  @override
  State<AnimalesListView> createState() => _AnimalesListViewState();
}

class _AnimalesListViewState extends State<AnimalesListView> {
  final _locationRepository = IsarLocationRepository(locator<IsarDatabase>());
  final Set<LifeStage> _selectedStages = {};

  List<LocationEntity> _locations = [];
  String _searchQuery = '';
  bool _onlyAttention = false;

  @override
  void initState() {
    super.initState();
    _loadLocations();
  }

  Future<void> _loadLocations() async {
    final locations = await _locationRepository.getAll();
    if (!mounted) return;
    setState(() => _locations = locations);
  }

  LocationEntity? _locationById(String? uuid) {
    if (uuid == null) return null;
    try {
      return _locations.firstWhere((l) => l.uuid == uuid);
    } catch (_) {
      return null;
    }
  }

  List<AnimalEntity> _applyFilters(List<AnimalEntity> animales) {
    final query = _searchQuery.trim().toLowerCase();
    return animales.where((animal) {
      final matchesSearch =
          query.isEmpty ||
          [
            animal.earTagNumber,
            animal.visualId ?? '',
            animal.breed,
            animal.species.displayName,
            animal.category.displayName,
            animal.lifeStage.displayName,
            animal.sex.displayName,
            animal.rfidTag ?? '',
            animal.batchId ?? '',
            animal.chronicNotes ?? '',
          ].any((field) => field.toLowerCase().contains(query));

      final matchesStage =
          _selectedStages.isEmpty || _selectedStages.contains(animal.lifeStage);

      final needsAttention =
          animal.requiresAttention ||
          animal.underObservation ||
          animal.riskLevel == RiskLevel.high ||
          animal.riskLevel == RiskLevel.critical ||
          animal.healthStatus == HealthStatus.poor ||
          animal.healthStatus == HealthStatus.critical;

      final matchesAttention = !_onlyAttention || needsAttention;

      return matchesSearch && matchesStage && matchesAttention;
    }).toList();
  }

  String _generateUuid() {
    final rand = Random();
    final timestamp = DateTime.now().microsecondsSinceEpoch;
    final randomBits = rand.nextInt(1 << 32);
    return 'ani-$timestamp-$randomBits';
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final bottomInset = AppShell.bottomSafePadding(context);
    final fabBottomPadding = AppShell.fabDockPadding(context);
    // Use the larger of content inset and FAB dock to keep items clear.
    final listBottomPadding = max(bottomInset + 2, fabBottomPadding + 8);
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.animalsTitle),
        actions: [
          IconButton(
            tooltip: l10n.animalsOnlyAttention,
            icon: Icon(
              _onlyAttention ? Icons.visibility : Icons.visibility_outlined,
            ),
            onPressed: () => setState(() => _onlyAttention = !_onlyAttention),
          ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
      floatingActionButton: Padding(
        padding: EdgeInsets.only(bottom: fabBottomPadding),
        child: FloatingActionButton.extended(
          onPressed: () => showCreateAnimalSheet(
            context,
            locations: _locations,
            generateUuid: _generateUuid,
            onLocationsRefresh: _loadLocations,
          ),
          icon: const Icon(Icons.add),
          label: Text(l10n.navAnimals),
        ),
      ),
      body: BlocBuilder<AnimalesBloc, AnimalesState>(
        builder: (context, state) {
          if (state is AnimalesInitial || state is AnimalesLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is AnimalesError) {
            return Center(child: Text(state.message));
          }

          if (state is! AnimalesLoaded) {
            return const SizedBox.shrink();
          }

          return _LoadedBody(
            state: state,
            filtered: _applyFilters(state.animales),
            listBottomPadding: listBottomPadding,
            searchQuery: _searchQuery,
            selectedStages: _selectedStages,
            onlyAttention: _onlyAttention,
            onRefresh: () => context.read<AnimalesBloc>().add(
              const LoadAnimales(forceRefresh: true),
            ),
            onSearchChanged: (v) => setState(() => _searchQuery = v),
            onStagesChanged: (stages) => setState(() {
              _selectedStages.clear();
              _selectedStages.addAll(stages);
            }),
            onAttentionChanged: (v) => setState(() => _onlyAttention = v),
            locationResolver: _locationById,
          );
        },
      ),
    );
  }
}

class _LoadedBody extends StatelessWidget {
  const _LoadedBody({
    required this.state,
    required this.filtered,
    required this.listBottomPadding,
    required this.searchQuery,
    required this.selectedStages,
    required this.onlyAttention,
    required this.onRefresh,
    required this.onSearchChanged,
    required this.onStagesChanged,
    required this.onAttentionChanged,
    required this.locationResolver,
  });

  final AnimalesLoaded state;
  final List<AnimalEntity> filtered;
  final double listBottomPadding;
  final String searchQuery;
  final Set<LifeStage> selectedStages;
  final bool onlyAttention;
  final VoidCallback onRefresh;
  final ValueChanged<String> onSearchChanged;
  final ValueChanged<Set<LifeStage>> onStagesChanged;
  final ValueChanged<bool> onAttentionChanged;
  final LocationEntity? Function(String?) locationResolver;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return RefreshIndicator(
      onRefresh: () async => onRefresh(),
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          SliverToBoxAdapter(
            child: _CenteredSection(
              padding: const EdgeInsets.fromLTRB(0, 0, 0, 12),
              child: AnimalFilterBar(
                searchQuery: searchQuery,
                selectedStages: selectedStages,
                onlyAttention: onlyAttention,
                onSearchChanged: onSearchChanged,
                onStagesChanged: onStagesChanged,
                onAttentionChanged: onAttentionChanged,
              ),
            ),
          ),
          if (filtered.isEmpty)
            SliverFillRemaining(
              hasScrollBody: false,
              child: _CenteredSection(
                padding: EdgeInsets.fromLTRB(16, 24, 16, listBottomPadding),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      l10n.animalsEmptyTitle,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      l10n.animalsEmptySubtitle,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
            )
          else ...[
            SliverToBoxAdapter(
              child: _CenteredSection(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
                child: Row(
                  children: [
                    Text(
                      l10n.animalsCount(filtered.length),
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      tooltip: 'Lotes',
                      icon: const Icon(Icons.inventory_2_outlined),
                      onPressed: () =>
                          showBatchManager(context, animals: state.animales),
                    ),
                  ],
                ),
              ),
            ),
            SliverPadding(
              padding: EdgeInsets.fromLTRB(16, 0, 16, listBottomPadding),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate((context, index) {
                  final animal = filtered[index];
                  return _CenteredSection(
                    padding: EdgeInsets.zero,
                    child: AnimalCard(
                      animal: animal,
                      location: locationResolver(
                        animal.currentPaddockId ?? animal.initialLocationId,
                      ),
                      batchLabel: animal.batchId,
                    ),
                  );
                }, childCount: filtered.length),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _CenteredSection extends StatelessWidget {
  const _CenteredSection({
    required this.child,
    this.padding = EdgeInsets.zero,
    this.maxWidth = 720,
  });
  final Widget child;
  final EdgeInsets padding;
  final double maxWidth;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maxWidth),
          child: child,
        ),
      ),
    );
  }
}
