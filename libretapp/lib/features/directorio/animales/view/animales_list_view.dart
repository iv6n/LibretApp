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
import 'package:libretapp/features/directorio/animales/animals.dart';
import 'package:libretapp/features/directorio/animales/domain/services/animal_presentation.dart';
import 'package:libretapp/features/directorio/animales/domain/repositories/health_record_repository.dart';
import 'package:libretapp/features/directorio/animales/domain/repositories/reproduction_record_repository.dart';
import 'package:libretapp/features/directorio/animales/domain/repositories/weight_record_repository.dart';
import 'package:libretapp/features/milking/domain/milking_repository.dart';
import 'package:libretapp/features/directorio/animales/widgets/animal_palette.dart';
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
  bool _isAtTop = true;
  bool _isNearListEnd = true;
  bool _isScrollingUp = false;
  bool _quickMenuOpen = false;
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
      final pendingEarTag = query['pendingEarTag'] == 'true';
      final attention = query['attention'] == 'true';
      final loteUuid = query['lote']?.trim();
      final locationUuid = query['ubicacion']?.trim();
      final key = [
        pendingEarTag,
        attention,
        loteUuid ?? '',
        locationUuid ?? '',
      ].join('|');
      if (_lastRouteFilterKey == key) return;
      _lastRouteFilterKey = key;

      _animalController.setOnlyPendingEarTag(pendingEarTag);
      _animalController.setOnlyAttention(attention);
      _animalController.setLoteUuid(
        loteUuid == null || loteUuid.isEmpty ? null : loteUuid,
      );
      _animalController.setLocationUuid(
        locationUuid == null || locationUuid.isEmpty ? null : locationUuid,
      );
      if (pendingEarTag ||
          attention ||
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
    final atTop = offset <= 0;
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
        atTop != _isAtTop ||
        isNearListEnd != _isNearListEnd ||
        isScrollingUp != _isScrollingUp;

    _lastScrollOffset = offset;
    if (!hasChanged) return;

    setState(() {
      _isAtTop = atTop;
      _isNearListEnd = isNearListEnd;
      _isScrollingUp = isScrollingUp;
    });

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

  Future<void> _scrollToTop() async {
    if (!_scrollController.hasClients) return;
    await _scrollController.animateTo(
      0,
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeOutCubic,
    );
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
            final isKeyboardFullyHidden =
                MediaQuery.of(context).viewInsets.bottom == 0;
            final bottomInset = ShellInsets.bottomSafePadding(context);
            final listBottomPadding = math.max(
              (isSelectionMode && isKeyboardFullyHidden)
                  ? MediaQuery.of(context).padding.bottom + 112
                  : bottomInset +
                        ShellInsets.fabContentClearance +
                        _quickMenuExtraPadding,
              0.0,
            );

            final showRegisterFab =
                isKeyboardFullyHidden &&
                (state is! AnimalesLoaded || _isScrollingUp || _isNearListEnd);
            final showScrollFab =
                state is AnimalesLoaded &&
                !state.isSearching &&
                !_isAtTop &&
                (_isScrollingUp || _isNearListEnd);
            final fabConfig =
                isSelectionMode ||
                    !showRegisterFab ||
                    _quickMenuOpen ||
                    (state is AnimalesLoaded && state.herdTotal == 0)
                ? null
                : ShellFabConfig(
                    id: 'animales',
                    label: 'Nuevo',
                    icon: Icons.add,
                    heroTag: 'fab_animales',
                    onPressed: () =>
                        context.pushNamed(AppRoutes.nameAnimalNuevoRapido),
                    secondary: showScrollFab
                        ? ShellFabSecondaryAction(
                            id: 'animales_scroll_top',
                            icon: Icons.keyboard_arrow_up,
                            heroTag: 'fab_animales_scroll_top',
                            onPressed: _scrollToTop,
                          )
                        : null,
                  );

            final scaffold = Scaffold(
              body: _buildAnimalesTab(listBottomPadding, l10n),
            );
            final content = widget.shellInteractionsEnabled
                ? ShellFabConfigScope(
                    config: fabConfig,
                    child: ShellChromeScope(
                      visible: !isSelectionMode,
                      child: scaffold,
                    ),
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
        final stageSpecies =
            selectedSpecies ??
            (taxonomyCounts.length == 1
                ? taxonomyCounts.keys.first
                : taxonomyCounts.isEmpty
                ? _singleSpeciesInPage(state.allAnimals)
                : null);
        final stageCounts = taxonomyCounts.isNotEmpty
            ? _animalController.selectedSpeciesStageCounts
            : state.herdStageCounts;

        final taxonomySourceKey = state.allAnimals
            .map(
              (animal) =>
                  '${animal.uuid}:${animal.species.name}:${animal.lifeStage.name}:${animal.ageMonths}',
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
                      listBottomPadding: listBottomPadding,
                      locationResolver: _animalController.locationForAnimal,
                      snapshotResolver: (animal) =>
                          _animalController.snapshotFor(animal.uuid),
                      onOpenDetail: _openAnimalDetail,
                      header: _buildListHeader(
                        context: context,
                        state: state,
                        filtered: filtered,
                        listBottomPadding: listBottomPadding,
                        l10n: l10n,
                        selectedStages: _animalController.state.selectedStages,
                        availableStages: stageCounts.keys.toSet(),
                        stageCounts: stageCounts,
                        taxonomyCounts: taxonomyCounts,
                        selectedSpecies: selectedSpecies,
                        stageSpecies: stageSpecies,
                        onSpeciesChanged: (species) {
                          _animalController.setSpecies(species);
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
                        hideStageChips: state.isSearching,
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
    required double listBottomPadding,
    required List<Widget> header,
    required LocationEntity? Function(AnimalEntity) locationResolver,
    required AnimalIndicatorSnapshot? Function(AnimalEntity) snapshotResolver,
    required void Function(AnimalEntity) onOpenDetail,
  }) {
    // The spinner only ever showed under a non-empty list; with nothing to
    // page through there is nothing more to load.
    final showLoadingMore = state.isLoadingMore && filtered.isNotEmpty;

    return ListView.builder(
      controller: _scrollController,
      physics: const AlwaysScrollableScrollPhysics(),
      padding: EdgeInsets.fromLTRB(4, 0, 4, listBottomPadding),
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

  /// The widgets above the animal rows: the filter chips and the count
  /// line, or the whole empty state when nothing matches.
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

  List<Widget> _buildListHeader({
    required BuildContext context,
    required AnimalesLoaded state,
    required List<AnimalEntity> filtered,
    required double listBottomPadding,
    required AppLocalizations l10n,
    required Set<LifeStage> selectedStages,
    required Set<LifeStage> availableStages,
    required Map<LifeStage, int> stageCounts,
    required Map<Species, Map<LifeStage, int>> taxonomyCounts,
    required Species? selectedSpecies,
    required Species? stageSpecies,
    required ValueChanged<Species?> onSpeciesChanged,
    required ValueChanged<Set<LifeStage>> onStagesChanged,
    required bool onlyPendingEarTag,
    required ValueChanged<bool> onPendingEarTagChanged,
    bool hideStageChips = false,
  }) {
    final theme = Theme.of(context);

    // `filtered` only ever holds the pages loaded so far, so counting it
    // would show "20 animales" and climb as the user scrolls. While nothing
    // is narrowing the list the honest figure is the whole herd's, which the
    // bloc counts in the database. Once a filter or a search is applied only
    // the loaded matches can be counted, so the label follows those instead.
    final isNarrowed =
        state.searchQuery.trim().isNotEmpty ||
        state.searchFilterStages.isNotEmpty ||
        state.searchFilterSexes.isNotEmpty ||
        _animalController.state.hasFilters;
    final firstAnimal = state.herdTotal == 0 && !isNarrowed;
    final headerCount = isNarrowed ? filtered.length : state.herdTotal;

    const calfStages = {
      LifeStage.calf,
      LifeStage.calfMale,
      LifeStage.calfFemale,
    };
    final isOnlyCalfFilter =
        selectedStages.isNotEmpty && selectedStages.every(calfStages.contains);
    final calfMaleCount = isOnlyCalfFilter
        ? filtered.where((a) => a.sex == Sex.male).length
        : 0;
    final calfFemaleCount = isOnlyCalfFilter
        ? filtered.where((a) => a.sex == Sex.female).length
        : 0;
    final calfUnknownCount = isOnlyCalfFilter
        ? filtered.where((a) => a.sex == Sex.unknown).length
        : 0;

    if (filtered.isEmpty) {
      return [
        const SizedBox(height: 1),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (!hideStageChips)
                _speciesFilterChips(
                  l10n: l10n,
                  taxonomyCounts: taxonomyCounts,
                  selectedSpecies: selectedSpecies,
                  theme: theme,
                  onSpeciesChanged: onSpeciesChanged,
                ),
              if (!hideStageChips)
                _stageFilterChips(
                  l10n: l10n,
                  selectedStages: selectedStages,
                  availableStages: availableStages,
                  stageCounts: stageCounts,
                  species: stageSpecies,
                  theme: theme,
                  onStagesChanged: onStagesChanged,
                ),
              if (!hideStageChips && _showPendingEarTagFilterChip) ...[
                const SizedBox(height: 8),
                Align(
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
              ],
              const SizedBox(height: 16),
              AppEmptyState(
                illustrationAsset: firstAnimal
                    ? _animalEmptyIllustration(context)
                    : null,
                icon: Icons.search_off_outlined,
                title: firstAnimal
                    ? 'Tus animales, en un lugar'
                    : l10n.animalsEmptyTitle,
                message: firstAnimal
                    ? 'Registra el primero para empezar a llevar su seguimiento.'
                    : l10n.animalsEmptySubtitle,
                action: firstAnimal
                    ? FilledButton.icon(
                        onPressed: () =>
                            context.pushNamed(AppRoutes.nameAnimalNuevoRapido),
                        icon: const Icon(Icons.add),
                        label: const Text('Registrar animal'),
                      )
                    : OutlinedButton.icon(
                        onPressed: () {
                          onSpeciesChanged(null);
                          onStagesChanged({});
                          onPendingEarTagChanged(false);
                          _animalController.setOnlyAttention(false);
                          _animalController.setLoteUuid(null);
                          _animalController.setLocationUuid(null);
                          context.read<AnimalesBloc>().add(const ClearSearch());
                          context.read<AnimalesBloc>().add(
                            const SetSearchFilters(),
                          );
                        },
                        icon: const Icon(Icons.filter_alt_off_outlined),
                        label: const Text('Limpiar filtros'),
                      ),
              ),
            ],
          ),
        ),
      ];
    }

    return [
      Divider(
        height: 2,
        thickness: 1,
        color: theme.dividerColor.withValues(alpha: 0.4),
      ),
      const SizedBox(height: 2),
      Padding(
        padding: const EdgeInsets.fromLTRB(2, 0, 0, 2),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            if (!hideStageChips)
              _speciesFilterChips(
                l10n: l10n,
                taxonomyCounts: taxonomyCounts,
                selectedSpecies: selectedSpecies,
                theme: theme,
                onSpeciesChanged: onSpeciesChanged,
              ),
            if (!hideStageChips)
              _stageFilterChips(
                l10n: l10n,
                selectedStages: selectedStages,
                availableStages: availableStages,
                stageCounts: stageCounts,
                species: stageSpecies,
                theme: theme,
                onStagesChanged: onStagesChanged,
              ),
            if (!hideStageChips && _showPendingEarTagFilterChip)
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
              padding: const EdgeInsets.symmetric(horizontal: 6),
              child: Row(
                children: [
                  Text(
                    l10n.animalsCount(headerCount),
                    style: theme.textTheme.labelSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Spacer(),
                  if (isOnlyCalfFilter)
                    Text(
                      '♀ $calfFemaleCount · ♂ $calfMaleCount · — $calfUnknownCount',
                      style: theme.textTheme.labelSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[700],
                      ),
                    ),
                ],
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
        onQuickMenuOpenChanged: (open) {
          if (!mounted) return;
          setState(() {
            _quickMenuOpen = open;
            if (!open) _quickMenuExtraPadding = 0;
          });
        },
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
        onQuickMenuOpenChanged: (open) {
          if (!mounted) return;
          setState(() {
            _quickMenuOpen = open;
            if (!open) _quickMenuExtraPadding = 0;
          });
        },
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
        onQuickMenuOpenChanged: (open) {
          if (!mounted) return;
          setState(() {
            _quickMenuOpen = open;
            if (!open) _quickMenuExtraPadding = 0;
          });
        },
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
    return _CenteredSection(
      padding: const EdgeInsets.symmetric(horizontal: 2),
      child: Slidable(
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
      ),
    );
  }
}

Species? _singleSpeciesInPage(Iterable<AnimalEntity> animals) {
  final species = animals.map((animal) => animal.species).toSet();
  return species.length == 1 ? species.first : null;
}

Widget _stageFilterChips({
  required AppLocalizations l10n,
  required Set<LifeStage> selectedStages,
  required Set<LifeStage> availableStages,
  required Map<LifeStage, int> stageCounts,
  required Species? species,
  required ThemeData theme,
  required ValueChanged<Set<LifeStage>> onStagesChanged,
}) {
  final hasStageFilters = selectedStages.isNotEmpty;
  final totalCount = stageCounts.values.fold<int>(
    0,
    (sum, count) => sum + count,
  );
  var configs = _stageConfigsForSpecies(
    l10n,
    species,
  ).where((cfg) => cfg.stages.any(availableStages.contains)).toList();
  if (configs.isEmpty && species != null && availableStages.isNotEmpty) {
    configs = availableStages
        .map(
          (stage) => _StageChipConfig(
            (count) => '${stage.displayName} ($count)',
            [stage],
          ),
        )
        .toList();
  }

  if (totalCount == 0 && configs.isEmpty) return const SizedBox.shrink();

  return SizedBox(
    height: 60,
    child: ListView.separated(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 6),
      itemCount: 1 + configs.length,
      separatorBuilder: (context, _) => const SizedBox(width: 7),
      itemBuilder: (context, index) {
        if (index == 0) {
          return _StageFilterChip(
            theme: theme,
            label: l10n.stageFilterAll,
            count: totalCount,
            isSelected: !hasStageFilters,
            onSelected: () => onStagesChanged({}),
          );
        }

        final config = configs[index - 1];
        final isSelected = config.stages.any(selectedStages.contains);
        final count = config.stages
            .map((s) => stageCounts[s] ?? 0)
            .fold<int>(0, (a, b) => a + b);

        return _StageFilterChip(
          theme: theme,
          label: config.labelResolver(count),
          count: count,
          isSelected: isSelected,
          onSelected: () {
            final updated = Set<LifeStage>.from(selectedStages);
            if (isSelected) {
              updated.removeAll(config.stages);
            } else {
              updated.addAll(config.stages);
            }
            onStagesChanged(updated);
          },
        );
      },
    ),
  );
}

List<_StageChipConfig> _stageConfigsForSpecies(
  AppLocalizations l10n,
  Species? species,
) {
  if (species == Species.cattle) {
    return [
      _StageChipConfig((c) => l10n.stageFilterCalf(c), [
        LifeStage.calf,
        LifeStage.calfMale,
        LifeStage.calfFemale,
      ]),
      _StageChipConfig((c) => l10n.stageFilterHeifer(c), [LifeStage.heifer]),
      _StageChipConfig((c) => l10n.stageFilterYoungBull(c), [
        LifeStage.youngBull,
      ]),
      _StageChipConfig((c) => l10n.stageFilterSteer(c), [LifeStage.steer]),
      _StageChipConfig((c) => l10n.stageFilterCow(c), [LifeStage.cow]),
      _StageChipConfig((c) => l10n.stageFilterBull(c), [LifeStage.bull]),
    ];
  }

  if (species == Species.equine) {
    return [
      _StageChipConfig((c) => l10n.stageFilterColt(c), [
        LifeStage.colt,
        LifeStage.filly,
      ]),
      _StageChipConfig((c) => l10n.stageFilterHorse(c), [LifeStage.horse]),
      _StageChipConfig((c) => l10n.stageFilterMare(c), [LifeStage.mare]),
      _StageChipConfig((c) => l10n.stageFilterDonkey(c), [
        LifeStage.donkey,
        LifeStage.donkeyFemale,
      ]),
      _StageChipConfig((c) => l10n.stageFilterMule(c), [LifeStage.mule]),
    ];
  }

  final groups = switch (species) {
    Species.goat => const [
      [LifeStage.kid],
      [LifeStage.youngGoat],
      [LifeStage.goat],
      [LifeStage.breedingBuck],
    ],
    Species.sheep => const [
      [LifeStage.lamb],
      [LifeStage.youngSheep],
      [LifeStage.ewe],
      [LifeStage.ram],
    ],
    Species.pig => const [
      [LifeStage.piglet],
      [LifeStage.youngPig],
      [LifeStage.sow],
      [LifeStage.boar],
    ],
    Species.poultry => const [
      [LifeStage.chick],
      [LifeStage.pullet],
      [LifeStage.hen],
      [LifeStage.rooster],
    ],
    Species.canine => const [
      [LifeStage.puppy],
      [LifeStage.youngDog],
      [LifeStage.workingDog],
      [LifeStage.guardDog],
    ],
    _ => const <List<LifeStage>>[],
  };

  return groups
      .map(
        (stages) => _StageChipConfig(
          (count) => '${stages.first.displayName} ($count)',
          stages,
        ),
      )
      .toList();
}

Widget _speciesFilterChips({
  required AppLocalizations l10n,
  required Map<Species, Map<LifeStage, int>> taxonomyCounts,
  required Species? selectedSpecies,
  required ThemeData theme,
  required ValueChanged<Species?> onSpeciesChanged,
}) {
  if (taxonomyCounts.length < 2) return const SizedBox.shrink();

  final totalCount = taxonomyCounts.values.fold<int>(
    0,
    (sum, stages) => sum + stages.values.fold<int>(0, (a, b) => a + b),
  );
  final species = taxonomyCounts.keys.toList()
    ..sort((a, b) => a.index.compareTo(b.index));

  return SizedBox(
    height: 60,
    child: ListView.separated(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 6),
      itemCount: species.length + 1,
      separatorBuilder: (context, _) => const SizedBox(width: 7),
      itemBuilder: (context, index) {
        if (index == 0) {
          return _StageFilterChip(
            theme: theme,
            label: l10n.stageFilterAll,
            count: totalCount,
            isSelected: selectedSpecies == null,
            onSelected: () => onSpeciesChanged(null),
          );
        }

        final value = species[index - 1];
        final count = taxonomyCounts[value]!.values.fold<int>(
          0,
          (a, b) => a + b,
        );
        return _StageFilterChip(
          theme: theme,
          label: value.displayName,
          count: count,
          isSelected: selectedSpecies == value,
          onSelected: () => onSpeciesChanged(value),
        );
      },
    ),
  );
}

class _StageFilterChip extends StatelessWidget {
  const _StageFilterChip({
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

class AnimalesSearchAppBar extends StatefulWidget {
  const AnimalesSearchAppBar({
    super.key,
    required this.l10n,
    required this.isAtTop,
    required this.onOpenFilters,
  });

  final AppLocalizations l10n;
  final bool isAtTop;
  final VoidCallback onOpenFilters;

  @override
  State<AnimalesSearchAppBar> createState() => _AnimalesSearchAppBarState();
}

class _AnimalesSearchAppBarState extends State<AnimalesSearchAppBar> {
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
    return BlocBuilder<AnimalesBloc, AnimalesState>(
      buildWhen: (previous, current) {
        if (previous is AnimalesLoaded && current is AnimalesLoaded) {
          return previous.isSearching != current.isSearching ||
              previous.searchQuery != current.searchQuery;
        }
        return previous.runtimeType != current.runtimeType;
      },
      builder: (context, state) {
        final loaded = state is AnimalesLoaded ? state : null;
        final isSearching = loaded?.isSearching ?? false;
        final query = loaded?.searchQuery ?? '';
        _syncController(query);

        if (isSearching && !_focusNode.hasFocus) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) _focusNode.requestFocus();
          });
        }

        return AppBar(
          automaticallyImplyLeading: false,
          titleSpacing: 0,
          title: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: _buildTitleBar(context, theme, isSearching),
          ),
          toolbarHeight: kToolbarHeight,
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
    final bloc = context.read<AnimalesBloc>();

    return SizedBox(
      key: const ValueKey('animales_normal_appbar'),
      height: 46,
      child: Row(
        children: [
          const SizedBox(width: 8),
          Text(
            widget.l10n.animalsTitle,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const Spacer(),
          if (showSearchIcon)
            IconButton(
              tooltip: widget.l10n.animalsSearchHint,
              icon: const Icon(Icons.search),
              onPressed: () {
                bloc.add(const ToggleSearch(enabled: true));
              },
            ),
          IconButton(
            tooltip: widget.l10n.animalsFilters,
            icon: const Icon(Icons.tune),
            onPressed: widget.onOpenFilters,
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar(BuildContext context, ThemeData theme) {
    final bloc = context.read<AnimalesBloc>();

    return SizedBox(
      key: const ValueKey('animales_search_appbar'),
      height: 56,
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _searchController,
              focusNode: _focusNode,
              autofocus: true,
              textInputAction: TextInputAction.search,
              onChanged: (value) => bloc.add(SearchQueryChanged(value)),
              decoration: InputDecoration(
                hintText: widget.l10n.animalsSearchHint,
                isDense: true,
                border: InputBorder.none,
                hintStyle: theme.textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[500],
                ),
                suffixIcon: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    BlocBuilder<AnimalesBloc, AnimalesState>(
                      buildWhen: (p, c) {
                        final pLoaded = p is AnimalesLoaded ? p : null;
                        final cLoaded = c is AnimalesLoaded ? c : null;
                        return pLoaded?.searchFilterStages !=
                                cLoaded?.searchFilterStages ||
                            pLoaded?.searchFilterSexes !=
                                cLoaded?.searchFilterSexes;
                      },
                      builder: (context, state) {
                        final loaded = state is AnimalesLoaded ? state : null;
                        final activeCount =
                            (loaded?.searchFilterStages.length ?? 0) +
                            (loaded?.searchFilterSexes.length ?? 0);
                        return _SearchFilterChipButton(
                          activeFilterCount: activeCount,
                          onTap: () => _showSearchFilterPopup(
                            context,
                            currentStages:
                                loaded?.searchFilterStages ?? const {},
                            currentSexes: loaded?.searchFilterSexes ?? const {},
                            onApply: (stages, sexes) {
                              bloc.add(
                                SetSearchFilters(stages: stages, sexes: sexes),
                              );
                            },
                          ),
                        );
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () {
                        _focusNode.unfocus();
                        bloc.add(const ClearSearch());
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
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

class _StageChipConfig {
  _StageChipConfig(this.labelResolver, this.stages);

  final String Function(int count) labelResolver;
  final List<LifeStage> stages;
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
// Search filter chip button (shown inside the search bar suffix)
// ---------------------------------------------------------------------------

class _SearchFilterChipButton extends StatelessWidget {
  const _SearchFilterChipButton({
    required this.activeFilterCount,
    required this.onTap,
  });

  final int activeFilterCount;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasFilters = activeFilterCount > 0;
    final color = hasFilters
        ? theme.colorScheme.primary
        : theme.colorScheme.onSurface.withValues(alpha: 0.6);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.tune, size: 18, color: color),
            if (hasFilters) ...[
              const SizedBox(width: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '$activeFilterCount',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.onPrimary,
                    fontWeight: FontWeight.w700,
                    fontSize: 10,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Search filter popup
// ---------------------------------------------------------------------------

void _showSearchFilterPopup(
  BuildContext context, {
  required Set<LifeStage> currentStages,
  required Set<Sex> currentSexes,
  required void Function(Set<LifeStage> stages, Set<Sex> sexes) onApply,
}) {
  showAppBottomSheet<void>(
    context: context,
    useRootNavigator: true,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (sheetContext) => _SearchFilterSheet(
      initialStages: currentStages,
      initialSexes: currentSexes,
      onApply: (stages, sexes) {
        Navigator.of(sheetContext).pop();
        onApply(stages, sexes);
      },
    ),
  );
}

class _SearchFilterSheet extends StatefulWidget {
  const _SearchFilterSheet({
    required this.initialStages,
    required this.initialSexes,
    required this.onApply,
  });

  final Set<LifeStage> initialStages;
  final Set<Sex> initialSexes;
  final void Function(Set<LifeStage> stages, Set<Sex> sexes) onApply;

  @override
  State<_SearchFilterSheet> createState() => _SearchFilterSheetState();
}

class _SearchFilterSheetState extends State<_SearchFilterSheet> {
  late Set<LifeStage> _stages;
  late Set<Sex> _sexes;

  @override
  void initState() {
    super.initState();
    _stages = Set<LifeStage>.from(widget.initialStages);
    _sexes = Set<Sex>.from(widget.initialSexes);
  }

  bool get _hasFilters => _stages.isNotEmpty || _sexes.isNotEmpty;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Padding(
      padding: EdgeInsets.fromLTRB(20, 16, 20, 16 + bottomPadding),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle bar
          Center(
            child: Container(
              width: 36,
              height: 4,
              margin: const EdgeInsets.only(bottom: 14),
              decoration: BoxDecoration(
                color: theme.colorScheme.outlineVariant,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          Row(
            children: [
              Text(
                'Filtros de búsqueda',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Spacer(),
              if (_hasFilters)
                TextButton(
                  onPressed: () => setState(() {
                    _stages = {};
                    _sexes = {};
                  }),
                  child: const Text('Limpiar'),
                ),
            ],
          ),
          const SizedBox(height: 14),

          // Etapa / Life stage
          Text(
            'Etapa',
            style: theme.textTheme.labelLarge?.copyWith(
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
            ),
          ),
          const SizedBox(height: 8),
          _buildStageChips(theme),
          const SizedBox(height: 16),

          // Sexo
          Text(
            'Sexo',
            style: theme.textTheme.labelLarge?.copyWith(
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
            ),
          ),
          const SizedBox(height: 8),
          _buildSexChips(theme),
          const SizedBox(height: 20),

          // Apply button
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: () => widget.onApply(_stages, _sexes),
              child: const Text('Aplicar filtros'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStageChips(ThemeData theme) {
    const stageGroups = [
      (
        label: 'Ternero/a',
        stages: [LifeStage.calf, LifeStage.calfMale, LifeStage.calfFemale],
      ),
      (label: 'Vaquillona', stages: [LifeStage.heifer]),
      (label: 'Torito', stages: [LifeStage.youngBull]),
      (label: 'Novillo', stages: [LifeStage.steer]),
      (label: 'Vaca', stages: [LifeStage.cow]),
      (label: 'Toro', stages: [LifeStage.bull]),
      (label: 'Potro/a', stages: [LifeStage.colt, LifeStage.filly]),
      (label: 'Caballo', stages: [LifeStage.horse]),
      (label: 'Yegua', stages: [LifeStage.mare]),
      (label: 'Burro/a', stages: [LifeStage.donkey, LifeStage.donkeyFemale]),
      (label: 'Mula', stages: [LifeStage.mule]),
    ];

    return Wrap(
      spacing: 8,
      runSpacing: 6,
      children: stageGroups.map((group) {
        final isSelected = group.stages.any(_stages.contains);
        return FilterChip(
          label: Text(group.label),
          selected: isSelected,
          showCheckmark: false,
          onSelected: (selected) {
            setState(() {
              if (selected) {
                _stages.addAll(group.stages);
              } else {
                _stages.removeAll(group.stages);
              }
            });
          },
          backgroundColor: AnimalPalette.filterChipBackground(
            isSelected: isSelected,
            isDark: theme.brightness == Brightness.dark,
          ),
          selectedColor: AnimalPalette.filterChipBackground(
            isSelected: isSelected,
            isDark: theme.brightness == Brightness.dark,
          ),
          checkmarkColor: AnimalPalette.uiAccent,
          side: BorderSide(
            color: AnimalPalette.filterChipBorder(
              isSelected: isSelected,
              isDark: theme.brightness == Brightness.dark,
            ),
          ),
          labelStyle: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 12,
            color: AnimalPalette.filterChipForeground(
              isSelected: isSelected,
              isDark: theme.brightness == Brightness.dark,
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildSexChips(ThemeData theme) {
    return Wrap(
      spacing: 8,
      runSpacing: 6,
      children: Sex.values.map((sex) {
        final isSelected = _sexes.contains(sex);
        return FilterChip(
          label: Text(sex.displayName),
          selected: isSelected,
          showCheckmark: false,
          onSelected: (selected) {
            setState(() {
              if (selected) {
                _sexes.add(sex);
              } else {
                _sexes.remove(sex);
              }
            });
          },
          backgroundColor: AnimalPalette.filterChipBackground(
            isSelected: isSelected,
            isDark: theme.brightness == Brightness.dark,
          ),
          selectedColor: AnimalPalette.filterChipBackground(
            isSelected: isSelected,
            isDark: theme.brightness == Brightness.dark,
          ),
          side: BorderSide(
            color: AnimalPalette.filterChipBorder(
              isSelected: isSelected,
              isDark: theme.brightness == Brightness.dark,
            ),
          ),
          labelStyle: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 12,
            color: AnimalPalette.filterChipForeground(
              isSelected: isSelected,
              isDark: theme.brightness == Brightness.dark,
            ),
          ),
        );
      }).toList(),
    );
  }
}
