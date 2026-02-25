import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:libretapp/app/widgets/widgets.dart';
import 'package:libretapp/core/database/isar_database.dart';
import 'package:libretapp/core/di/injection.dart';
import 'package:libretapp/core/router/app_routes.dart';
import 'package:libretapp/features/animales/animals.dart';
import 'package:libretapp/features/animales/domain/animal_palette.dart';
import 'package:libretapp/features/ubicaciones/domain/entities/location_entity.dart';
import 'package:libretapp/features/ubicaciones/infrastructure/repositories/isar_location_repository.dart';
import 'package:libretapp/l10n/app_localizations.dart';

class AnimalesListView extends StatefulWidget {
  const AnimalesListView({super.key});

  @override
  State<AnimalesListView> createState() => _AnimalesListViewState();
}

class _AnimalesListViewState extends State<AnimalesListView> {
  late final AnimalesListController _controller;
  late final ScrollController _scrollController;
  bool _isAtTop = true;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController()..addListener(_handleScroll);
    _controller = AnimalesListController(
      locationRepository: IsarLocationRepository(locator<IsarDatabase>()),
    )..loadInitial();
  }

  @override
  void dispose() {
    _scrollController.removeListener(_handleScroll);
    _scrollController.dispose();
    _controller.dispose();
    super.dispose();
  }

  void _handleScroll() {
    if (!_scrollController.hasClients) return;
    final atTop = _scrollController.positions.isNotEmpty
        ? _scrollController.position.pixels <= 0
        : true;
    if (atTop == _isAtTop) return;
    setState(() {
      _isAtTop = atTop;
    });
  }

  void _openAnimalDetail(AnimalEntity animal) {
    context.push(AppRoutes.animalDetallePath(animal.uuid));
  }

  Future<void> _openFiltersSheet() async {
    final uiState = _controller.state;
    await showAnimalFiltersSheet(
      context: context,
      selectedStages: uiState.selectedStages,
      onlyAttention: uiState.onlyAttention,
      onStagesChanged: _controller.setStages,
      onAttentionChanged: _controller.setOnlyAttention,
    );
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
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final bottomInset = ShellInsets.bottomSafePadding(context);
        final listBottomPadding = bottomInset + 2;
        final uiState = _controller.state;
        final isSearching = context.select<AnimalesBloc, bool>((bloc) {
          final state = bloc.state;
          return state is AnimalesLoaded ? state.isSearching : false;
        });

        final fabConfig = ShellFabConfig(
          id: 'animales',
          label: 'Agregar',
          icon: Icons.add,
          heroTag: 'fab_animales',
          onPressed: () => showCreateAnimalSheet(
            context,
            locations: uiState.locations,
            generateUuid: _generateUuid,
            onLocationsRefresh: _controller.refreshLocations,
          ),
        );

        return ShellFabConfigScope(
          config: fabConfig,
          child: ShellChromeScope(
            visible: !isSearching,
            child: Scaffold(
              body: NestedScrollView(
                controller: _scrollController,
                headerSliverBuilder: (context, innerScrolled) => [
                  AnimalesSearchAppBar(
                    l10n: l10n,
                    isAtTop: _isAtTop,
                    onOpenFilters: _openFiltersSheet,
                  ),
                ],
                body: BlocBuilder<AnimalesBloc, AnimalesState>(
                  builder: (context, state) =>
                      _buildBody(state, listBottomPadding, l10n),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildBody(
    AnimalesState state,
    double listBottomPadding,
    AppLocalizations l10n,
  ) {
    if (state is AnimalesInitial || state is AnimalesLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state is AnimalesError) {
      return Center(child: Text(state.message));
    }

    if (state is! AnimalesLoaded) {
      return const SizedBox.shrink();
    }

    final filtered = _controller.applyFilters(state.visibleAnimals);
    final stageCounts = _countByStage(state.allAnimals);

    return RefreshIndicator(
      onRefresh: () async => context.read<AnimalesBloc>().add(
        const LoadAnimales(forceRefresh: true),
      ),
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: _buildSlivers(
          context: context,
          state: state,
          filtered: filtered,
          listBottomPadding: listBottomPadding,
          l10n: l10n,
          selectedStages: _controller.state.selectedStages,
          availableStages: state.allAnimals.map((a) => a.lifeStage).toSet(),
          stageCounts: stageCounts,
          onStagesChanged: _controller.setStages,
          locationResolver: _controller.locationById,
          onOpenDetail: _openAnimalDetail,
        ),
      ),
    );
  }
}

List<Widget> _buildSlivers({
  required BuildContext context,
  required AnimalesLoaded state,
  required List<AnimalEntity> filtered,
  required double listBottomPadding,
  required AppLocalizations l10n,
  required Set<LifeStage> selectedStages,
  required Set<LifeStage> availableStages,
  required Map<LifeStage, int> stageCounts,
  required ValueChanged<Set<LifeStage>> onStagesChanged,
  required LocationEntity? Function(String?) locationResolver,
  required void Function(AnimalEntity) onOpenDetail,
}) {
  final theme = Theme.of(context);
  final hasStageFilters = selectedStages.isNotEmpty;
  const calfStages = {LifeStage.calf, LifeStage.calfMale, LifeStage.calfFemale};
  final isOnlyCalfFilter =
      selectedStages.isNotEmpty && selectedStages.every(calfStages.contains);
  final calfMaleCount = isOnlyCalfFilter
      ? filtered.where((a) => a.sex == Sex.male).length
      : 0;
  final calfFemaleCount = isOnlyCalfFilter
      ? filtered.where((a) => a.sex == Sex.female).length
      : 0;

  return [
    SliverToBoxAdapter(child: const SizedBox(height: 1)),
    if (filtered.isEmpty)
      SliverFillRemaining(
        hasScrollBody: false,
        child: _CenteredSection(
          padding: EdgeInsets.fromLTRB(16, 12, 16, listBottomPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _stageFilterChips(
                l10n: l10n,
                selectedStages: selectedStages,
                availableStages: availableStages,
                stageCounts: stageCounts,
                theme: theme,
                onStagesChanged: onStagesChanged,
              ),
              const SizedBox(height: 16),
              Text(
                l10n.animalsEmptyTitle,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                l10n.animalsEmptySubtitle,
                style: theme.textTheme.bodyMedium,
              ),
            ],
          ),
        ),
      )
    else ...[
      SliverToBoxAdapter(
        child: _CenteredSection(
          padding: const EdgeInsets.fromLTRB(2, 0, 4, 2),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _stageFilterChips(
                l10n: l10n,
                selectedStages: selectedStages,
                availableStages: availableStages,
                stageCounts: stageCounts,
                theme: theme,
                onStagesChanged: onStagesChanged,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6),
                child: Row(
                  children: [
                    Text(
                      l10n.animalsCount(filtered.length),
                      style: theme.textTheme.labelSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const Spacer(),
                    if (isOnlyCalfFilter)
                      Text(
                        '$calfFemaleCount ♀   $calfMaleCount ♂',
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
      ),
      SliverPadding(
        padding: EdgeInsets.fromLTRB(10, 2, 10, listBottomPadding),
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
                onTap: () => onOpenDetail(animal),
              ),
            );
          }, childCount: filtered.length),
        ),
      ),
    ],
  ];
}

class _StageChipConfig {
  _StageChipConfig(this.label, this.stages, this.color);

  final String label;
  final List<LifeStage> stages;
  final Color color;
}

class _ClearFiltersChip extends StatelessWidget {
  const _ClearFiltersChip({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      customBorder: const CircleBorder(),
      child: CircleAvatar(
        radius: 14,
        backgroundColor: Colors.grey[200],
        child: const Icon(Icons.close, size: 16, color: Colors.black54),
      ),
    );
  }
}

Widget _stageFilterChips({
  required AppLocalizations l10n,
  required Set<LifeStage> selectedStages,
  required Set<LifeStage> availableStages,
  required Map<LifeStage, int> stageCounts,
  required ThemeData theme,
  required ValueChanged<Set<LifeStage>> onStagesChanged,
}) {
  final hasStageFilters = selectedStages.isNotEmpty;
  final configs = <_StageChipConfig>[
    _StageChipConfig(l10n.stageFilterCalf, [
      LifeStage.calf,
      LifeStage.calfMale,
      LifeStage.calfFemale,
    ], AnimalPalette.stageColor(LifeStage.calf)),
    _StageChipConfig(l10n.stageFilterHeifer, [
      LifeStage.heifer,
    ], AnimalPalette.stageColor(LifeStage.heifer)),
    _StageChipConfig(l10n.stageFilterYoungBull, [
      LifeStage.youngBull,
    ], AnimalPalette.stageColor(LifeStage.youngBull)),
    _StageChipConfig(l10n.stageFilterSteer, [
      LifeStage.steer,
    ], AnimalPalette.stageColor(LifeStage.steer)),
    _StageChipConfig(l10n.stageFilterCow, [
      LifeStage.cow,
    ], AnimalPalette.stageColor(LifeStage.cow)),
    _StageChipConfig(l10n.stageFilterBull, [
      LifeStage.bull,
    ], AnimalPalette.stageColor(LifeStage.bull)),
    _StageChipConfig(l10n.stageFilterColt, [
      LifeStage.colt,
      LifeStage.filly,
    ], AnimalPalette.stageColor(LifeStage.colt)),
    _StageChipConfig(l10n.stageFilterHorse, [
      LifeStage.horse,
    ], AnimalPalette.stageColor(LifeStage.horse)),
    _StageChipConfig(l10n.stageFilterMare, [
      LifeStage.mare,
    ], AnimalPalette.stageColor(LifeStage.mare)),
    _StageChipConfig(l10n.stageFilterDonkey, [
      LifeStage.donkey,
      LifeStage.donkeyFemale,
    ], AnimalPalette.stageColor(LifeStage.donkey)),
    _StageChipConfig(l10n.stageFilterMule, [
      LifeStage.mule,
    ], AnimalPalette.stageColor(LifeStage.mule)),
  ].where((cfg) => cfg.stages.any(availableStages.contains)).toList();

  if (configs.isEmpty) return const SizedBox.shrink();

  return SizedBox(
    height: 44,
    child: Row(
      children: [
        Expanded(
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 4),
            itemCount: configs.length + (hasStageFilters ? 2 : 0),
            separatorBuilder: (context, _) => const SizedBox(width: 8),
            itemBuilder: (context, index) {
              final bool isLeadingClear = hasStageFilters && index == 0;
              final bool isTrailingClear =
                  hasStageFilters && index == configs.length + 1;

              if (isLeadingClear || isTrailingClear) {
                return _ClearFiltersChip(onTap: () => onStagesChanged({}));
              }

              final configIndex = hasStageFilters ? index - 1 : index;
              final config = configs[configIndex];
              final isSelected = config.stages.any(selectedStages.contains);
              final color = config.color;
              final count = config.stages
                  .map((s) => stageCounts[s] ?? 0)
                  .fold<int>(0, (a, b) => a + b);
              final label = count > 0 ? '${config.label} $count' : config.label;
              final labelColor = isSelected
                  ? Colors.white
                  : color.withValues(alpha: 0.86);
              final bgColor = isSelected
                  ? color
                  : color.withValues(alpha: 0.18);
              final borderColor = isSelected
                  ? color.withValues(alpha: 0.9)
                  : Colors.transparent;

              return ChoiceChip(
                label: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 2),
                  child: Text(
                    label,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: labelColor,
                    ),
                  ),
                ),
                selected: isSelected,
                onSelected: (selected) {
                  final updated = Set<LifeStage>.from(selectedStages);
                  if (selected) {
                    updated.addAll(config.stages);
                  } else {
                    updated.removeAll(config.stages);
                  }
                  onStagesChanged(updated);
                },
                visualDensity: const VisualDensity(
                  horizontal: -2,
                  vertical: -2,
                ),
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                backgroundColor: bgColor,
                selectedColor: bgColor,
                shape: StadiumBorder(side: BorderSide(color: borderColor)),
                showCheckmark: false,
              );
            },
          ),
        ),
      ],
    ),
  );
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
                        ? 0.0
                        : ((currentExtent - minExtent) / denominator).clamp(
                            0.0,
                            1.0,
                          );

                    _updateInlineVisible(t, allowInline: widget.isAtTop);

                    return Align(
                      alignment: Alignment.bottomCenter,
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(12, 0, 12, 10),
                        child: AnimatedOpacity(
                          duration: const Duration(milliseconds: 180),
                          opacity: t,
                          child: IgnorePointer(
                            ignoring: t < 0.05,
                            child: _buildInlineSearch(theme),
                          ),
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
    // Show search icon only when inline search is hidden.
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
    final bloc = context.read<AnimalesBloc>();
    final searchPillColor = theme.colorScheme.surface;
    final searchHintStyle = theme.textTheme.bodySmall?.copyWith(
      color: Colors.grey[600],
      fontWeight: FontWeight.w500,
    );

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
                suffixIcon: IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () {
                    _focusNode.unfocus();
                    bloc.add(const ClearSearch());
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInlineSearch(ThemeData theme) {
    final bloc = context.read<AnimalesBloc>();

    return SizedBox(
      key: const ValueKey('animales_inline_search'),
      height: 44,
      child: TextField(
        controller: _searchController,
        readOnly: true,
        onTap: () => bloc.add(const ToggleSearch(enabled: true)),
        textInputAction: TextInputAction.search,
        onChanged: (value) => bloc.add(SearchQueryChanged(value)),
        decoration: InputDecoration(
          hintText: widget.l10n.animalsSearchHint,
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

Map<LifeStage, int> _countByStage(List<AnimalEntity> animals) {
  final counts = <LifeStage, int>{};
  for (final animal in animals) {
    counts.update(animal.lifeStage, (value) => value + 1, ifAbsent: () => 1);
  }
  return counts;
}
