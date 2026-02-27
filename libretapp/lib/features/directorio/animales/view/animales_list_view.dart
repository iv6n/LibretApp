import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:libretapp/app/widgets/widgets.dart';
import 'package:libretapp/core/database/isar_database.dart';
import 'package:libretapp/core/di/injection.dart';
import 'package:libretapp/core/router/app_routes.dart';
import 'package:libretapp/features/directorio/animales/animals.dart';
import 'package:libretapp/features/directorio/animales/domain/animal_palette.dart';
import 'package:libretapp/features/directorio/bloc/lotes_tab_bloc.dart';
import 'package:libretapp/features/directorio/bloc/lotes_tab_event.dart';
import 'package:libretapp/features/ubicaciones/domain/entities/location_entity.dart';
import 'package:libretapp/features/ubicaciones/infrastructure/repositories/isar_location_repository.dart';
import 'package:libretapp/l10n/app_localizations.dart';

class AnimalesListView extends StatefulWidget {
  const AnimalesListView({super.key});

  @override
  State<AnimalesListView> createState() => _AnimalesListViewState();
}

class _AnimalesListViewState extends State<AnimalesListView>
    with TickerProviderStateMixin {
  late final AnimalesListController _animalController;
  late final ScrollController _scrollController;
  late final TabController _tabController;
  bool _isAtTop = true;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController()..addListener(_handleScroll);
    _tabController = TabController(length: 2, vsync: this);
    _animalController = AnimalesListController(
      locationRepository: IsarLocationRepository(locator<IsarDatabase>()),
    )..loadInitial();
    context.read<LotesTabBloc>().add(const LoadLotesTab());
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
      animation: _animalController,
      builder: (context, _) {
        final bottomInset = ShellInsets.bottomSafePadding(context);
        final listBottomPadding = bottomInset + 2;
        final uiState = _animalController.state;

        final fabConfig = ShellFabConfig(
          id: 'animales',
          label: 'Agregar',
          icon: Icons.add,
          heroTag: 'fab_animales',
          onPressed: () => showCreateAnimalSheet(
            context,
            locations: uiState.locations,
            generateUuid: _generateUuid,
            onLocationsRefresh: _animalController.refreshLocations,
          ),
        );

        return ShellFabConfigScope(
          config: fabConfig,
          child: ShellChromeScope(
            visible: true,
            child: Scaffold(
              body: Column(
                children: [
                  // Only filter chips and animal list, no tabs or search bar
                  Expanded(child: _buildAnimalesTab(listBottomPadding, l10n)),
                ],
              ),
            ),
          ),
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
        final stageCounts = _countByStage(state.allAnimals);

        return RefreshIndicator(
          onRefresh: () async => context.read<AnimalesBloc>().add(
            const LoadAnimales(forceRefresh: true),
          ),
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: EdgeInsets.fromLTRB(4, 0, 4, listBottomPadding),
            children: _buildListContent(
              context: context,
              state: state,
              filtered: filtered,
              listBottomPadding: listBottomPadding,
              l10n: l10n,
              selectedStages: _animalController.state.selectedStages,
              availableStages: state.allAnimals.map((a) => a.lifeStage).toSet(),
              stageCounts: stageCounts,
              onStagesChanged: _animalController.setStages,
              locationResolver: _animalController.locationById,
              onOpenDetail: _openAnimalDetail,
            ),
          ),
        );
      },
    );
  }

  List<Widget> _buildListContent({
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

    if (filtered.isEmpty) {
      return [
        const SizedBox(height: 1),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
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
      ];
    }

    return [
      Padding(
        padding: const EdgeInsets.fromLTRB(2, 0, 0, 2),
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
      ...filtered.map(
        (animal) => _CenteredSection(
          padding: EdgeInsets.symmetric(horizontal: 2),
          child: AnimalCard(
            animal: animal,
            location: locationResolver(
              animal.currentPaddockId ?? animal.initialLocationId,
            ),
            onTap: () => onOpenDetail(animal),
          ),
        ),
      ),
    ];
  }
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

  void _syncController(String value) {
    if (_searchController.text == value) return;
    _searchController.value = TextEditingValue(
      text: value,
      selection: TextSelection.collapsed(offset: value.length),
    );
  }
}

class _StageChipConfig {
  _StageChipConfig(this.label, this.stages, this.color);

  final String label;
  final List<LifeStage> stages;
  final Color color;
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
