/// features \u203a directorio \u203a animales \u203a view \u203a animales_list_view \u2014 stateless list layout for animals.
library;

import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:go_router/go_router.dart';
import 'package:libretapp/app/widgets/widgets.dart';
import 'package:libretapp/core/di/injection.dart';
import 'package:libretapp/core/router/app_routes.dart';
import 'package:libretapp/core/experience/care_profile.dart';
import 'package:libretapp/core/experience/app_experience.dart';
import 'package:libretapp/core/widgets/app_empty_state.dart';
import 'package:libretapp/core/widgets/app_directory_filter_chip.dart';
import 'package:libretapp/core/widgets/app_directory_layout.dart';
import 'package:libretapp/features/directorio/animales/animals.dart';
import 'package:libretapp/features/directorio/animales/domain/services/animal_presentation.dart';
import 'package:libretapp/features/directorio/animales/domain/repositories/health_record_repository.dart';
import 'package:libretapp/features/directorio/animales/domain/repositories/reproduction_record_repository.dart';
import 'package:libretapp/features/directorio/animales/domain/repositories/weight_record_repository.dart';
import 'package:libretapp/features/milking/domain/milking_repository.dart';
import 'package:libretapp/features/directorio/animales/widgets/animal_compact_row.dart';
import 'package:libretapp/features/directorio/animales/widgets/pet_card.dart';
import 'package:libretapp/features/directorio/bloc/directorio_state.dart';
import 'package:libretapp/features/ubicaciones/domain/entities/location_entity.dart';
import 'package:libretapp/features/directorio/animales/view/bulk_health_form_page.dart';
import 'package:libretapp/features/ubicaciones/domain/repositories/location_repository.dart';
import 'package:libretapp/l10n/app_localizations.dart';

class AnimalesListView extends StatefulWidget {
  const AnimalesListView({
    super.key,
    this.shellInteractionsEnabled = true,
    this.viewMode = AnimalDirectoryViewMode.cards,
  });

  final bool shellInteractionsEnabled;
  final AnimalDirectoryViewMode viewMode;

  @override
  State<AnimalesListView> createState() => _AnimalesListViewState();
}

class _AnimalesListViewState extends State<AnimalesListView>
    with TickerProviderStateMixin {
  static const double _nearListEndThreshold = 96;
  static const double _estimatedQuickMenuHeight = 288;
  static const double _quickMenuGap = 2;
  // Se conserva el control y toda su lógica para reubicarlo posteriormente
  // en una superficie de filtros más compacta.
  static const bool _showPendingEarTagFilterChip = false;
  late final AnimalesListController _animalController;
  late final HealthRecordRepository _healthRepo;
  late final ScrollController _scrollController;
  late final TabController _tabController;
  bool _isNearListEnd = true;
  bool _isScrollingUp = false;
  bool _taxonomyRefreshInFlight = false;
  String? _lastRouteFilterKey;
  String? _taxonomySourceKey;
  double _quickMenuExtraPadding = 0;
  double _lastScrollOffset = 0;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController()..addListener(_handleScroll);
    _tabController = TabController(length: 2, vsync: this);
    _healthRepo = locator<HealthRecordRepository>();
    _animalController = AnimalesListController(
      locationRepository: locator<LocationRepository>(),
      animalRepository: locator<AnimalRepository>(),
      reproductionRepository: locator<ReproductionRecordRepository>(),
      healthRepository: _healthRepo,
      weightRepository: locator<WeightRecordRepository>(),
      milkingRepository: locator<MilkingRepository>(),
    );
    _animalController.loadInitial();
    unawaited(_animalController.loadTaxonomy());
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _syncRouteFilters();
  }

  @override
  void didUpdateWidget(covariant AnimalesListView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.viewMode == widget.viewMode) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_scrollController.hasClients) return;
      final position = _scrollController.position;
      final offset = position.pixels.clamp(
        position.minScrollExtent,
        position.maxScrollExtent,
      );
      if (offset != position.pixels) _scrollController.jumpTo(offset);
      _handleScroll();
    });
  }

  void _syncRouteFilters() {
    try {
      final query = GoRouterState.of(context).uri.queryParameters;
      final species = Species.values.where((s) => s.name == query['species']).firstOrNull;
      final pendingEarTag = query['pendingEarTag'] == 'true';
      final attention = query['attention'] == 'true';
      final clearFilters = query['clearFilters'] == 'true';
      final healthFilter = switch (query['health']) {
        'pending' => AnimalHealthFilter.pending,
        'unvaccinated' => AnimalHealthFilter.unvaccinated,
        _ => null,
      };
      final loteUuid = query['lote']?.trim();
      final locationUuid = query['ubicacion']?.trim();
      final focusSearch = query['buscar'] == '1';
      final key = [
        species?.name,
        pendingEarTag,
        attention,
        clearFilters,
        healthFilter?.name ?? '',
        loteUuid ?? '',
        locationUuid ?? '',
        focusSearch,
      ].join('|');
      if (_lastRouteFilterKey == key) return;
      _lastRouteFilterKey = key;
      if (focusSearch) {
        context.read<AnimalesBloc>().add(const ToggleSearch(enabled: true));
      }

      if (clearFilters) {
        _animalController.setSpecies(null);
        _animalController.setStages(const <LifeStage>{});
        _animalController.setOnlyPendingEarTag(false);
        _animalController.setOnlyAttention(false);
        _animalController.setHealthFilter(null);
        _animalController.setLoteUuid(null);
        _animalController.setLocationUuid(null);
        _animalController.setIncludeInactive(false);
        context.read<AnimalesBloc>()
          ..add(const ClearSearch())
          ..add(const SetSearchFilters());
      }

      if (species != null) _animalController.setSpecies(species);
      _animalController.setOnlyPendingEarTag(pendingEarTag);
      _animalController.setOnlyAttention(attention);
      _animalController.setHealthFilter(healthFilter);
      _animalController.setLoteUuid(
        loteUuid == null || loteUuid.isEmpty ? null : loteUuid,
      );
      _animalController.setLocationUuid(
        locationUuid == null || locationUuid.isEmpty ? null : locationUuid,
      );
      if (clearFilters ||
          pendingEarTag ||
          attention ||
          healthFilter != null ||
          (loteUuid?.isNotEmpty ?? false) ||
          (locationUuid?.isNotEmpty ?? false)) {
        _ensureAllAnimalsForFilter();
      }
    } catch (_) {
      // The list can also be hosted without GoRouter in focused widget tests.
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_handleScroll);
    _scrollController.dispose();
    _tabController.dispose();
    _animalController.dispose();
    super.dispose();
  }

  void _handleScroll() {
    if (!mounted || !_scrollController.hasClients) return;
    final position = _scrollController.position;
    final offset = position.pixels;
    final canScroll = position.maxScrollExtent > 0;
    final isNearListEnd = !canScroll
        ? true
        : (position.maxScrollExtent - offset) <= _nearListEndThreshold;

    bool isScrollingUp = _isScrollingUp;
    if (offset > _lastScrollOffset + 1) {
      isScrollingUp = false;
    } else if (offset < _lastScrollOffset - 1) {
      isScrollingUp = true;
    }

    final hasChanged =
        isNearListEnd != _isNearListEnd || isScrollingUp != _isScrollingUp;

    _lastScrollOffset = offset;
    if (!hasChanged) return;

    _isNearListEnd = isNearListEnd;
    _isScrollingUp = isScrollingUp;

    // Trigger pagination when scrolling near the bottom.
    if (isNearListEnd && !isScrollingUp && mounted) {
      final bloc = context.read<AnimalesBloc>();
      final s = bloc.state;
      if (s is AnimalesLoaded && s.hasMore && !s.isLoadingMore) {
        bloc.add(const AnimalesLoadMore());
      }
    }
  }

  void _ensureAllAnimalsForFilter() {
    context.read<AnimalesBloc>().add(const EnsureAllAnimalesLoaded());
  }

  void _handleQuickMenuOpenChanged(bool open) {
    if (!mounted || open || _quickMenuExtraPadding == 0) return;
    setState(() => _quickMenuExtraPadding = 0);
  }

  Future<void> _ensureQuickMenuSpaceBelow(BuildContext menuContext) async {
    final button = menuContext.findRenderObject() as RenderBox?;
    if (button == null || !mounted || !_scrollController.hasClients) return;

    final overlay =
        Overlay.of(menuContext).context.findRenderObject() as RenderBox;
    final bottomReserve = ShellInsets.bottomSafePadding(menuContext) + 8;

    double deficitFor(RenderBox trigger) {
      final origin = trigger.localToGlobal(Offset.zero, ancestor: overlay);
      final triggerBottom = origin.dy + trigger.size.height;
      final requiredBottom =
          triggerBottom +
          _estimatedQuickMenuHeight +
          _quickMenuGap +
          bottomReserve;
      return requiredBottom - overlay.size.height;
    }

    var deficit = deficitFor(button);
    if (deficit <= 0) return;

    final maxExtent = _scrollController.position.maxScrollExtent;
    var targetOffset = (_scrollController.offset + deficit).clamp(
      0.0,
      maxExtent,
    );

    await _scrollController.animateTo(
      targetOffset,
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeOutCubic,
    );

    if (!mounted || !_scrollController.hasClients) return;

    var remainingDeficit = deficitFor(button);
    if (remainingDeficit <= 0) return;

    setState(() {
      _quickMenuExtraPadding = remainingDeficit;
    });

    await WidgetsBinding.instance.endOfFrame;
    if (!mounted || !_scrollController.hasClients) return;

    final newMaxExtent = _scrollController.position.maxScrollExtent;
    remainingDeficit = deficitFor(button);
    if (remainingDeficit <= 0) return;

    targetOffset = (_scrollController.offset + remainingDeficit).clamp(
      0.0,
      newMaxExtent,
    );

    await _scrollController.animateTo(
      targetOffset,
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeOutCubic,
    );
  }

  Future<void> _openAnimalDetail(AnimalEntity animal) async {
    await context.push(AppRoutes.animalDetallePath(animal.uuid));
    if (!mounted) return;
    _animalController.invalidateIndicatorSnapshots();
    await _animalController.refreshLocations();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return AnimatedBuilder(
      animation: _animalController,
      builder: (context, _) {
        return BlocBuilder<AnimalesBloc, AnimalesState>(
          builder: (context, state) {
            final isSelectionMode =
                state is AnimalesLoaded && state.isSelectionMode;
            final isSearching = state is AnimalesLoaded && state.isSearching;
            final isKeyboardFullyHidden =
                MediaQuery.of(context).viewInsets.bottom == 0;
            final bottomInset = ShellInsets.bottomSafePadding(context);
            final listBottomPadding = math.max(
              (isSelectionMode && isKeyboardFullyHidden)
                  ? MediaQuery.of(context).padding.bottom + 112
                  : bottomInset + 8 + _quickMenuExtraPadding,
              0.0,
            );

            final scaffold = Scaffold(
              body: _buildAnimalesTab(listBottomPadding, l10n),
            );
            final content = widget.shellInteractionsEnabled
                ? ShellChromeScope(
                    visible: !isSelectionMode && !isSearching,
                    child: scaffold,
                  )
                : scaffold;

            return PopScope(
              canPop: !widget.shellInteractionsEnabled || !isSelectionMode,
              onPopInvokedWithResult: (didPop, _) {
                if (didPop ||
                    !widget.shellInteractionsEnabled ||
                    !isSelectionMode) {
                  return;
                }
                final bloc = context.read<AnimalesBloc>();
                bloc.add(const ClearAnimalSelection());
                bloc.add(const ClearSearch());
              },
              child: content,
            );
          },
        );
      },
    );
  }

  Widget _buildAnimalesTab(double listBottomPadding, AppLocalizations l10n) {
    return BlocBuilder<AnimalesBloc, AnimalesState>(
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

        final filtered = _animalController.applyFilters(state.visibleAnimals);
        // Counted across the whole herd by the bloc, not over the pages
        // loaded so far — otherwise every chip would read low and climb as
        // the user scrolled.
        final taxonomyCounts = _animalController.state.taxonomyCounts;
        final selectedSpecies = _animalController.state.selectedSpecies;
        final selectedCompanion = _animalController.state.selectedCompanion;
        final selectedStages = _animalController.state.selectedStages;
        final taxonomySourceKey = state.allAnimals
            .map(
              (animal) =>
                  '${animal.uuid}:${animal.species.name}:${animal.lifeStage.name}:${animal.ageMonths}:${animal.productionPurpose.name}',
            )
            .join('|');
        if ((_animalController.taxonomyTotal != state.herdTotal ||
                taxonomySourceKey != _taxonomySourceKey) &&
            !_taxonomyRefreshInFlight) {
          _taxonomySourceKey = taxonomySourceKey;
          _taxonomyRefreshInFlight = true;
          unawaited(
            _animalController.loadTaxonomy(state.allAnimals).whenComplete(() {
              if (mounted) _taxonomyRefreshInFlight = false;
            }),
          );
        }

        // Load the record-derived indicators for the rows on screen after the
        // frame settles: the controller notifies listeners when they arrive,
        // which must not happen mid-build. Already-loaded animals are skipped,
        // so repeating this on every build costs nothing.
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;
          unawaited(_animalController.loadIndicatorSnapshots(filtered));
        });
        final selectedVisibleCount = filtered
            .where((animal) => state.selectedAnimalUuids.contains(animal.uuid))
            .length;

        final isKeyboardFullyHidden =
            MediaQuery.of(context).viewInsets.bottom == 0;

        return Stack(
          children: [
            Column(
              children: [
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: () async => context.read<AnimalesBloc>().add(
                      const LoadAnimales(forceRefresh: true),
                    ),
                    child: _buildAnimalList(
                      context: context,
                      state: state,
                      filtered: filtered,
                      l10n: l10n,
                      listBottomPadding: listBottomPadding,
                      locationResolver: _animalController.locationForAnimal,
                      snapshotResolver: (animal) =>
                          _animalController.snapshotFor(animal.uuid),
                      onOpenDetail: _openAnimalDetail,
                      header: _buildListHeader(
                        context: context,
                        state: state,
                        filtered: filtered,
                        l10n: l10n,
                        taxonomyCounts: taxonomyCounts,
                        selectedSpecies: selectedSpecies,
                        selectedCompanion: selectedCompanion,
                        selectedStages: selectedStages,
                        companionStageCounts:
                            _animalController.state.companionStageCounts,
                        onSpeciesChanged: (species) {
                          _animalController.setSpecies(species);
                          _ensureAllAnimalsForFilter();
                        },
                        onCompanionChanged: (selected) {
                          _animalController.setCompanion(selected);
                          _ensureAllAnimalsForFilter();
                        },
                        onStagesChanged: (stages) {
                          _animalController.setStages(stages);
                          _ensureAllAnimalsForFilter();
                        },
                        onlyPendingEarTag:
                            _animalController.state.onlyPendingEarTag,
                        onPendingEarTagChanged: (value) {
                          _animalController.setOnlyPendingEarTag(value);
                          _ensureAllAnimalsForFilter();
                        },
                        hideCategoryChips: state.isSearching,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            if (state.isSelectionMode && isKeyboardFullyHidden)
              Positioned(
                left: 12,
                right: 12,
                bottom: MediaQuery.of(context).padding.bottom,
                child: _buildSelectionActions(
                  state: state,
                  l10n: l10n,
                  selectedVisibleCount: selectedVisibleCount,
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _buildSelectionActions({
    required AnimalesLoaded state,
    required AppLocalizations l10n,
    required int selectedVisibleCount,
  }) {
    final allSelectedHidden =
        state.selectedCount > 0 && selectedVisibleCount == 0;
    final theme = Theme.of(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 10, 14, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (allSelectedHidden)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    Icon(
                      Icons.filter_alt_off_outlined,
                      size: 18,
                      color: theme.colorScheme.error,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        l10n.animalsSelectionAllHiddenWarning,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.error,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: state.selectedCount == 0
                    ? null
                    : () => _openBulkHealthForm(state),
                icon: const Icon(Icons.medical_services_outlined),
                label: Text(
                  l10n.animalsBulkMaintenanceAction(state.selectedCount),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _openBulkHealthForm(AnimalesLoaded state) async {
    final l10n = AppLocalizations.of(context);
    final selectedUuids = state.selectedAnimalUuids.toList(growable: false);
    if (selectedUuids.isEmpty) return;
    final messenger = ScaffoldMessenger.of(context);
    final animalesBloc = context.read<AnimalesBloc>();
    final shouldContinue = await showDialog<bool>(
      context: context,
      useRootNavigator: true,
      builder: (context) => AlertDialog(
        title: Text(l10n.animalsBulkMaintenanceConfirmTitle),
        content: Text(
          l10n.animalsBulkMaintenanceConfirmBody(selectedUuids.length),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l10n.animalsSelectionCancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(l10n.animalsBulkMaintenanceConfirmAction),
          ),
        ],
      ),
    );
    if (shouldContinue != true) return;
    if (!mounted) return;

    await _showBulkHealthForm(
      context,
      selectedCount: selectedUuids.length,
      onSubmit: (record) async {
        try {
          await _healthRepo.addHealthRecordToMultiple(selectedUuids, record);
          return true;
        } catch (e) {
          if (mounted) {
            messenger.showSnackBar(
              SnackBar(
                content: Text(l10n.animalsBulkMaintenanceError(e.toString())),
              ),
            );
          }
          return false;
        }
      },
      onSaved: () {
        animalesBloc.add(const ClearAnimalSelection());
      },
    );
  }

  Future<void> _showBulkHealthForm(
    BuildContext context, {
    required int selectedCount,
    required Future<bool> Function(HealthRecord record) onSubmit,
    required VoidCallback onSaved,
  }) async {
    final saved = await Navigator.of(context).push<bool>(
      MaterialPageRoute<bool>(
        fullscreenDialog: true,
        builder: (context) => BulkHealthFormPage(
          selectedCount: selectedCount,
          onSubmit: onSubmit,
        ),
      ),
    );
    if (saved == true) {
      onSaved();
    }
  }

  /// The directory list: [header] widgets, then one row per animal, then the
  /// load-more spinner.
  ///
  /// Built lazily. The rows used to be spread into `ListView(children:)`, which
  /// meant a herd's worth of row widgets was constructed on every rebuild — and
  /// this list rebuilds on every database change, filter tap and selection
  /// toggle — however few rows were actually on screen.
  Widget _buildAnimalList({
    required BuildContext context,
    required AnimalesLoaded state,
    required List<AnimalEntity> filtered,
    required AppLocalizations l10n,
    required double listBottomPadding,
    required List<Widget> header,
    required LocationEntity? Function(AnimalEntity) locationResolver,
    required AnimalIndicatorSnapshot? Function(AnimalEntity) snapshotResolver,
    required void Function(AnimalEntity) onOpenDetail,
  }) {
    // The spinner only ever showed under a non-empty list; with nothing to
    // page through there is nothing more to load.
    final showLoadingMore = state.isLoadingMore && filtered.isNotEmpty;

    if (filtered.isEmpty) {
      return CustomScrollView(
        controller: _scrollController,
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          if (header.isNotEmpty)
            SliverToBoxAdapter(
              child: Column(mainAxisSize: MainAxisSize.min, children: header),
            ),
          SliverFillRemaining(
            hasScrollBody: false,
            child: AppDirectoryEmptySlot(
              bottomPadding: state.herdTotal == 0
                  ? ShellInsets.bottomSafePadding(context)
                  : listBottomPadding,
              child: _buildAnimalEmptyState(context, state, l10n),
            ),
          ),
        ],
      );
    }

    return ListView.builder(
      controller: _scrollController,
      physics: const AlwaysScrollableScrollPhysics(),
      padding: EdgeInsets.only(bottom: listBottomPadding),
      itemCount: header.length + filtered.length + (showLoadingMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index < header.length) return header[index];

        final rowIndex = index - header.length;
        if (rowIndex < filtered.length) {
          return _buildAnimalRow(
            context: context,
            state: state,
            animal: filtered[rowIndex],
            locationResolver: locationResolver,
            snapshotResolver: snapshotResolver,
            onOpenDetail: onOpenDetail,
          );
        }

        return const Padding(
          padding: EdgeInsets.symmetric(vertical: 16),
          child: Center(child: CircularProgressIndicator()),
        );
      },
    );
  }

  /// The widgets above the animal rows: filter strips and the count line.
  String _animalEmptyIllustration(BuildContext context) {
    final preferences = AppExperienceScope.maybeOf(context)?.value;
    if (preferences?.careProfile == CareProfile.pets) {
      final species = preferences!.preferredSpecies;
      return species.contains(Species.feline) &&
              !species.contains(Species.canine)
          ? 'assets/images/felino.png'
          : 'assets/images/canino.webp';
    }
    return 'assets/images/vaca.webp';
  }

  Widget _buildAnimalEmptyState(
    BuildContext context,
    AnimalesLoaded state,
    AppLocalizations l10n,
  ) {
    final isNarrowed =
        state.searchQuery.trim().isNotEmpty ||
        state.searchFilterSexes.isNotEmpty ||
        _animalController.state.hasFilters;
    final firstAnimal = state.herdTotal == 0 && !isNarrowed;
    return AppEmptyState(
      illustrationAsset: firstAnimal ? _animalEmptyIllustration(context) : null,
      icon: Icons.search_off_outlined,
      title: firstAnimal ? 'Sin animales' : l10n.animalsEmptyTitle,
      action: firstAnimal
          ? Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                FilledButton.icon(
                  onPressed: () =>
                      context.pushNamed(AppRoutes.nameAnimalNuevoRapido),
                  icon: const Icon(Icons.add),
                  label: const Text('Registrar animal'),
                ),
                OutlinedButton.icon(
                  onPressed: () =>
                      context.pushNamed(AppRoutes.nameAnimalNuevoMultiple),
                  icon: const Icon(Icons.playlist_add_outlined),
                  label: const Text('Registrar varios'),
                ),
              ],
            )
          : OutlinedButton.icon(
              onPressed: _clearAnimalFilters,
              icon: const Icon(Icons.filter_alt_off_outlined),
              label: const Text('Limpiar filtros'),
            ),
    );
  }

  void _clearAnimalFilters() {
    _animalController.setSpecies(null);
    _animalController.setStages(const <LifeStage>{});
    _animalController.setOnlyPendingEarTag(false);
    _animalController.setOnlyAttention(false);
    _animalController.setHealthFilter(null);
    _animalController.setLoteUuid(null);
    _animalController.setLocationUuid(null);
    context.read<AnimalesBloc>()
      ..add(const ClearSearch())
      ..add(const SetSearchFilters());
  }

  List<Widget> _buildListHeader({
    required BuildContext context,
    required AnimalesLoaded state,
    required List<AnimalEntity> filtered,
    required AppLocalizations l10n,
    required Map<Species, Map<LifeStage, int>> taxonomyCounts,
    required Species? selectedSpecies,
    required bool selectedCompanion,
    required Set<LifeStage> selectedStages,
    required Map<LifeStage, int> companionStageCounts,
    required ValueChanged<Species?> onSpeciesChanged,
    required ValueChanged<bool> onCompanionChanged,
    required ValueChanged<Set<LifeStage>> onStagesChanged,
    required bool onlyPendingEarTag,
    required ValueChanged<bool> onPendingEarTagChanged,
    bool hideCategoryChips = false,
  }) {
    final theme = Theme.of(context);

    // `filtered` only ever holds the pages loaded so far, so counting it
    // would show "20 animales" and climb as the user scrolls. While nothing
    // is narrowing the list the honest figure is the whole herd's, which the
    // bloc counts in the database. Once a filter or a search is applied only
    // the loaded matches can be counted, so the label follows those instead.
    final isNarrowed =
        state.searchQuery.trim().isNotEmpty ||
        state.searchFilterSexes.isNotEmpty ||
        _animalController.state.hasFilters;
    final headerCount = isNarrowed ? filtered.length : state.herdTotal;
    if (state.herdTotal == 0 && !isNarrowed) return [];

    final singleSpecies = taxonomyCounts.length == 1;
    final effectiveSpecies = singleSpecies
        ? taxonomyCounts.keys.single
        : selectedSpecies;
    final stageCounts = selectedCompanion
        ? companionStageCounts
        : effectiveSpecies == null
        ? const <LifeStage, int>{}
        : taxonomyCounts[effectiveSpecies] ?? const <LifeStage, int>{};
    final stageFilters = hideCategoryChips || stageCounts.isEmpty
        ? const SizedBox.shrink()
        : AnimatedSize(
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeOutCubic,
            alignment: Alignment.topCenter,
            child: AnimalStageFilterRow(
              species: selectedCompanion ? null : effectiveSpecies,
              companionOnly: selectedCompanion,
              counts: stageCounts,
              selectedStages: selectedStages,
              onChanged: onStagesChanged,
            ),
          );

    if (filtered.isEmpty) {
      final filters = <Widget>[
        if (!hideCategoryChips && !singleSpecies)
          _speciesFilterChips(
            taxonomyCounts: taxonomyCounts,
            selectedSpecies: selectedSpecies,
            selectedCompanion: selectedCompanion,
            companionCount: companionStageCounts.values.fold<int>(
              0,
              (sum, count) => sum + count,
            ),
            theme: theme,
            onSpeciesChanged: onSpeciesChanged,
            onCompanionChanged: onCompanionChanged,
          ),
        if (!hideCategoryChips) stageFilters,
        if (!hideCategoryChips && _showPendingEarTagFilterChip)
          AppDirectoryFilterRow(
            children: [
              FilterChip(
                avatar: const Icon(Icons.pending_actions_outlined, size: 18),
                label: Text(l10n.animalsOnlyPendingTag),
                selected: onlyPendingEarTag,
                onSelected: onPendingEarTagChanged,
              ),
            ],
          ),
      ];
      filters.removeWhere((widget) => widget is SizedBox && widget.width == 0);
      return [
        if (isNarrowed)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: Text('0 resultados', style: theme.textTheme.labelLarge),
          ),
        ...filters,
      ];
    }

    return [
      Divider(
        height: 1,
        thickness: 1,
        color: theme.dividerColor.withValues(alpha: 0.4),
      ),
      Padding(
        padding: EdgeInsets.zero,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            if (!hideCategoryChips && !singleSpecies)
              _speciesFilterChips(
                taxonomyCounts: taxonomyCounts,
                selectedSpecies: selectedSpecies,
                selectedCompanion: selectedCompanion,
                companionCount: companionStageCounts.values.fold<int>(
                  0,
                  (sum, count) => sum + count,
                ),
                theme: theme,
                onSpeciesChanged: onSpeciesChanged,
                onCompanionChanged: onCompanionChanged,
              ),
            if (!hideCategoryChips) stageFilters,
            if (!hideCategoryChips && _showPendingEarTagFilterChip)
              Padding(
                padding: const EdgeInsets.fromLTRB(6, 4, 6, 2),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: FilterChip(
                    avatar: const Icon(
                      Icons.pending_actions_outlined,
                      size: 18,
                    ),
                    label: Text(l10n.animalsOnlyPendingTag),
                    selected: onlyPendingEarTag,
                    onSelected: onPendingEarTagChanged,
                  ),
                ),
              ),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 4, 12, 6),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  l10n.animalsCount(headerCount),
                  style: theme.textTheme.labelSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    ];
  }

  /// One directory row.
  ///
  /// Split out of the list body so [ListView.builder] can call it per
  /// visible row: as a spread inside `ListView(children:)` every animal in
  /// the herd was rebuilt on every emission, filter tap and selection
  /// toggle, however few rows were on screen.
  Widget _buildAnimalRow({
    required BuildContext context,
    required AnimalesLoaded state,
    required AnimalEntity animal,
    required LocationEntity? Function(AnimalEntity) locationResolver,
    required AnimalIndicatorSnapshot? Function(AnimalEntity) snapshotResolver,
    required void Function(AnimalEntity) onOpenDetail,
  }) {
    final location = locationResolver(animal);
    final snapshot = snapshotResolver(animal);
    final Widget animalCard;
    if (widget.viewMode == AnimalDirectoryViewMode.compact) {
      animalCard = AnimalCompactRow(
        animal: animal,
        location: location,
        indicatorSnapshot: snapshot,
        onLocationTap: location == null
            ? null
            : () => context.push(AppRoutes.ubicacionDetallePath(location.uuid)),
        isSelected: state.selectedAnimalUuids.contains(animal.uuid),
        selectionEnabled: state.isSelectionMode,
        onMenuAction: (action) => _handleAnimalCardMenuAction(
          context,
          animal: animal,
          action: action,
          onOpenDetail: () => onOpenDetail(animal),
        ),
        onQuickMenuOpenChanged: _handleQuickMenuOpenChanged,
        onPrepareQuickMenu: _ensureQuickMenuSpaceBelow,
        onTap: () {
          if (state.isSelectionMode) {
            context.read<AnimalesBloc>().add(
              ToggleAnimalSelection(animal.uuid),
            );
            return;
          }
          onOpenDetail(animal);
        },
        onLongPress: () => context.read<AnimalesBloc>().add(
          ToggleAnimalSelection(animal.uuid),
        ),
      );
    } else if (animal.productionPurpose == ProductionPurpose.companion ||
        animal.species == Species.canine ||
        animal.species == Species.feline) {
      animalCard = PetCard(
        animal: animal,
        location: location,
        indicatorSnapshot: snapshot,
        onLocationTap: location == null
            ? null
            : () => context.push(AppRoutes.ubicacionDetallePath(location.uuid)),
        isSelected: state.selectedAnimalUuids.contains(animal.uuid),
        selectionEnabled: state.isSelectionMode,
        onLongPress: () => context.read<AnimalesBloc>().add(
          ToggleAnimalSelection(animal.uuid),
        ),
        onMenuAction: (action) => _handleAnimalCardMenuAction(
          context,
          animal: animal,
          action: action,
          onOpenDetail: () => onOpenDetail(animal),
        ),
        onQuickMenuOpenChanged: _handleQuickMenuOpenChanged,
        onPrepareQuickMenu: _ensureQuickMenuSpaceBelow,
        onTap: () {
          if (state.isSelectionMode) {
            context.read<AnimalesBloc>().add(
              ToggleAnimalSelection(animal.uuid),
            );
            return;
          }
          onOpenDetail(animal);
        },
      );
    } else {
      animalCard = AnimalCard(
        animal: animal,
        location: location,
        indicatorSnapshot: snapshot,
        onLocationTap: location == null
            ? null
            : () => context.push(AppRoutes.ubicacionDetallePath(location.uuid)),
        isSelected: state.selectedAnimalUuids.contains(animal.uuid),
        selectionEnabled: state.isSelectionMode,
        onMenuAction: (action) => _handleAnimalCardMenuAction(
          context,
          animal: animal,
          action: action,
          onOpenDetail: () => onOpenDetail(animal),
        ),
        onQuickMenuOpenChanged: _handleQuickMenuOpenChanged,
        onPrepareQuickMenu: _ensureQuickMenuSpaceBelow,
        onTap: () {
          if (state.isSelectionMode) {
            context.read<AnimalesBloc>().add(
              ToggleAnimalSelection(animal.uuid),
            );
            return;
          }
          onOpenDetail(animal);
        },
        onLongPress: () => context.read<AnimalesBloc>().add(
          ToggleAnimalSelection(animal.uuid),
        ),
      );
    }
    return Slidable(
      key: ValueKey('slide_${animal.uuid}'),
      enabled: !state.isSelectionMode,
      startActionPane: ActionPane(
        motion: const DrawerMotion(),
        extentRatio: 0.22,
        children: [
          SlidableAction(
            onPressed: (_) =>
                context.push(AppRoutes.animalRegistroPesoPath(animal.uuid)),
            backgroundColor: Colors.green.shade600,
            foregroundColor: Colors.white,
            icon: Icons.monitor_weight_outlined,
            label: 'Pesar',
            borderRadius: const BorderRadius.horizontal(
              left: Radius.circular(20),
            ),
          ),
        ],
      ),
      endActionPane: ActionPane(
        motion: const DrawerMotion(),
        extentRatio: 0.22,
        children: [
          SlidableAction(
            onPressed: (_) =>
                context.push(AppRoutes.animalRegistroSaludPath(animal.uuid)),
            backgroundColor: Colors.blue.shade700,
            foregroundColor: Colors.white,
            icon: Icons.medical_services_outlined,
            label: 'Salud',
            borderRadius: const BorderRadius.horizontal(
              right: Radius.circular(20),
            ),
          ),
        ],
      ),
      child: animalCard,
    );
  }
}

Widget _speciesFilterChips({
  required Map<Species, Map<LifeStage, int>> taxonomyCounts,
  required Species? selectedSpecies,
  required bool selectedCompanion,
  required int companionCount,
  required ThemeData theme,
  required ValueChanged<Species?> onSpeciesChanged,
  required ValueChanged<bool> onCompanionChanged,
}) {
  if (taxonomyCounts.isEmpty && companionCount == 0) {
    return const SizedBox.shrink();
  }

  final totalCount = taxonomyCounts.values.fold<int>(
    0,
    (sum, stages) => sum + stages.values.fold<int>(0, (a, b) => a + b),
  );
  final species = taxonomyCounts.keys.toList()
    ..sort((a, b) => a.index.compareTo(b.index));

  return AppDirectoryFilterRow(
    children: [
      _AnimalCategoryFilterChip(
        theme: theme,
        label: 'Todos',
        count: totalCount,
        isSelected: selectedSpecies == null && !selectedCompanion,
        onSelected: () => onSpeciesChanged(null),
      ),
      if (selectedCompanion ||
          (companionCount > 0 && companionCount < totalCount))
        _AnimalCategoryFilterChip(
          theme: theme,
          label: 'Mascota',
          count: companionCount,
          isSelected: selectedCompanion,
          onSelected: () => onCompanionChanged(!selectedCompanion),
        ),
      for (final value in species)
        if (species.length > 1 || selectedSpecies == value)
          _AnimalCategoryFilterChip(
            theme: theme,
            label: value.displayName,
            count: taxonomyCounts[value]!.values.fold<int>(0, (a, b) => a + b),
            isSelected: selectedSpecies == value,
            onSelected: () => onSpeciesChanged(value),
          ),
    ],
  );
}

class _AnimalCategoryFilterChip extends StatelessWidget {
  const _AnimalCategoryFilterChip({
    required this.theme,
    required this.label,
    required this.count,
    required this.isSelected,
    required this.onSelected,
  });

  final ThemeData theme;
  final String label;
  final int count;
  final bool isSelected;
  final VoidCallback onSelected;

  @override
  Widget build(BuildContext context) {
    return AppDirectoryFilterChip(
      label: label.replaceFirst(RegExp(r'\s*\(\d+\)$'), ''),
      selected: isSelected,
      count: count > 0 ? count : null,
      accentColor: theme.colorScheme.primary,
      onTap: onSelected,
    );
  }
}

String _animalCardLabel(AnimalEntity animal) {
  return primaryAnimalLabel(animal);
}

Future<void> _confirmDeleteAnimal(
  BuildContext context,
  AnimalEntity animal,
) async {
  final confirmed = await showDialog<bool>(
    context: context,
    useRootNavigator: true,
    builder: (ctx) => AlertDialog(
      title: const Text('Eliminar animal'),
      content: Text(
        '¿Eliminar a ${_animalCardLabel(animal)}? Esta acción no se puede deshacer.',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx, false),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          style: FilledButton.styleFrom(
            backgroundColor: Theme.of(ctx).colorScheme.error,
          ),
          onPressed: () => Navigator.pop(ctx, true),
          child: const Text('Eliminar'),
        ),
      ],
    ),
  );

  if (confirmed == true && context.mounted) {
    context.read<AnimalesBloc>().add(DeleteAnimal(animal.uuid));
  }
}

void _handleAnimalCardMenuAction(
  BuildContext context, {
  required AnimalEntity animal,
  required AnimalCardMenuAction action,
  required VoidCallback onOpenDetail,
}) {
  switch (action) {
    case AnimalCardMenuAction.viewDetail:
      onOpenDetail();
    case AnimalCardMenuAction.edit:
      context.pushNamed(
        AppRoutes.nameAnimalEditar,
        pathParameters: {'uuid': animal.uuid},
      );
    case AnimalCardMenuAction.registerWeight:
      context.push(AppRoutes.animalRegistroPesoPath(animal.uuid));
    case AnimalCardMenuAction.registerHealth:
      context.push(AppRoutes.animalRegistroSaludPath(animal.uuid));
    case AnimalCardMenuAction.delete:
      _confirmDeleteAnimal(context, animal);
  }
}

// ---------------------------------------------------------------------------
