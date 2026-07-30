/// features \u203a directorio \u203a animales \u203a view \u203a animal_detail_page \u2014 detail page for a single animal.
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:libretapp/app/widgets/widgets.dart';
import 'package:libretapp/core/di/injection.dart';
import 'package:libretapp/core/router/app_routes.dart';
import 'package:libretapp/features/directorio/animales/domain/repositories/commercial_record_repository.dart';
import 'package:libretapp/features/directorio/animales/domain/repositories/cost_record_repository.dart';
import 'package:libretapp/features/directorio/animales/domain/repositories/health_record_repository.dart';
import 'package:libretapp/features/directorio/animales/domain/repositories/movement_record_repository.dart';
import 'package:libretapp/features/directorio/animales/domain/repositories/production_record_repository.dart';
import 'package:libretapp/features/directorio/animales/domain/repositories/reproduction_record_repository.dart';
import 'package:libretapp/features/directorio/animales/domain/repositories/weight_record_repository.dart';
import 'package:libretapp/features/directorio/animales/infrastructure/animal_repository.dart';
import 'package:libretapp/features/directorio/lotes/infrastructure/lotes_repository.dart';
import 'package:libretapp/features/directorio/animales/widgets/widgets.dart';
import 'package:libretapp/features/milking/domain/milking_repository.dart';
import 'package:libretapp/l10n/app_localizations.dart';

/// Detail page for a single animal.
///
/// Uses a [NestedScrollView] with two separate slivers:
///   1. [SliverAppBar] — collapses the animal header photo/info on scroll.
///   2. [_StickyTabBarDelegate] — keeps the [TabBar] pinned below the
///      collapsed app bar once the header scrolls out of view.
///
/// The [AnimalBloc] is provided by the router — this page only consumes it.
class AnimalDetailPage extends StatefulWidget {
  AnimalDetailPage({
    required this.animalUuid,
    this.showQuickActions = true,
    AnimalRepository? repository,
    LotesRepository? lotesRepository,
    WeightRecordRepository? weightRepo,
    HealthRecordRepository? healthRepo,
    ProductionRecordRepository? productionRepo,
    ReproductionRecordRepository? reproductionRepo,
    CommercialRecordRepository? commercialRepo,
    MovementRecordRepository? movementRepo,
    CostRecordRepository? costRepo,
    MilkingRepository? milkingRepo,
    super.key,
  }) : repository = repository ?? locator<AnimalRepository>(),
       lotesRepository = lotesRepository ?? locator<LotesRepository>(),
       weightRepo = weightRepo ?? locator<WeightRecordRepository>(),
       healthRepo = healthRepo ?? locator<HealthRecordRepository>(),
       productionRepo = productionRepo ?? locator<ProductionRecordRepository>(),
       reproductionRepo =
           reproductionRepo ?? locator<ReproductionRecordRepository>(),
       commercialRepo = commercialRepo ?? locator<CommercialRecordRepository>(),
       movementRepo = movementRepo ?? locator<MovementRecordRepository>(),
       costRepo = costRepo ?? locator<CostRecordRepository>(),
       milkingRepo = milkingRepo ?? locator<MilkingRepository>();

  final String animalUuid;
  final AnimalRepository repository;
  final LotesRepository lotesRepository;
  final WeightRecordRepository weightRepo;
  final HealthRecordRepository healthRepo;
  final ProductionRecordRepository productionRepo;
  final ReproductionRecordRepository reproductionRepo;
  final CommercialRecordRepository commercialRepo;
  final MovementRecordRepository movementRepo;
  final CostRecordRepository costRepo;
  final MilkingRepository milkingRepo;
  final bool showQuickActions;

  @override
  State<AnimalDetailPage> createState() => _AnimalDetailPageState();
}

class _AnimalDetailPageState extends State<AnimalDetailPage>
    with SingleTickerProviderStateMixin {
  late Future<DetailData> _future;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _future = _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // ── data ──────────────────────────────────────────────────────────────

  Future<DetailData> _loadData() async {
    final animal = await widget.repository.getByUuid(widget.animalUuid);
    if (animal == null) throw Exception('Animal no encontrado');

    final uuid = animal.uuid;
    final weightsFuture = widget.weightRepo.getWeightRecords(uuid);
    final reproductionsFuture = widget.reproductionRepo.getReproductionRecords(
      uuid,
    );
    final productionsFuture = widget.productionRepo.getProductionRecords(uuid);
    final healthFuture = widget.healthRepo.getHealthRecords(uuid);
    final commercialFuture = widget.commercialRepo.getCommercialRecords(uuid);
    final movementsFuture = widget.movementRepo.getMovementRecords(uuid);
    final costsFuture = widget.costRepo.getCostRecords(uuid);
    final milkingFuture = widget.milkingRepo.getRecordsByAnimal(uuid);

    final weights = await weightsFuture;
    final reproductions = await reproductionsFuture;
    final productions = await productionsFuture;
    final health = await healthFuture;
    final commercial = await commercialFuture;
    final movements = await movementsFuture;
    final costs = await costsFuture;
    final milkingRecords = await milkingFuture;

    return DetailData(
      animal: animal,
      weights: weights,
      reproductions: reproductions,
      productions: productions,
      health: health,
      commercial: commercial,
      movements: movements,
      costs: costs,
      milkingRecords: milkingRecords,
    );
  }

  void _reload() {
    // A block body is required, not `=>`: the arrow form's "return value" is
    // the assignment's value — a Future here — and setState()'s callback must
    // return void, or Flutter throws in debug mode even though nothing is
    // awaited.
    setState(() {
      _future = _loadData();
    });
  }

  // ── build ─────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final keyboardVisible = MediaQuery.viewInsetsOf(context).bottom > 0;
    final showFab = widget.showQuickActions && !keyboardVisible;
    final fabBottomPadding = showFab
        ? ShellInsets.fabDockPadding(context)
        : 0.0;

    return ShellChromeScope(
      visible: false,
      child: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.light,
        child: Scaffold(
          floatingActionButtonLocation: showFab
              ? FloatingActionButtonLocation.endDocked
              : null,
          floatingActionButton: showFab
              ? Padding(
                  padding: EdgeInsets.only(bottom: fabBottomPadding),
                  child: QuickActionsFab(
                    onAddWeight: () async {
                      final saved = await context.pushNamed(
                        AppRoutes.nameAnimalRegistroPeso,
                        pathParameters: {'uuid': widget.animalUuid},
                      );
                      if (saved == true && mounted) {
                        _reload();
                      }
                    },
                    onAddReproduction: () async {
                      final saved = await context.pushNamed(
                        AppRoutes.nameAnimalRegistroReproduccion,
                        pathParameters: {'uuid': widget.animalUuid},
                      );
                      if (saved == true && mounted) {
                        _reload();
                      }
                    },
                    onAddProduction: () async {
                      final saved = await context.pushNamed(
                        AppRoutes.nameAnimalRegistroProduccion,
                        pathParameters: {'uuid': widget.animalUuid},
                      );
                      if (saved == true && mounted) {
                        _reload();
                      }
                    },
                    onAddMilking: () async {
                      final saved = await context.pushNamed(
                        AppRoutes.nameRegistroOrdena,
                        queryParameters: {'animalUuid': widget.animalUuid},
                      );
                      if (saved == true && mounted) {
                        _reload();
                      }
                    },
                    onAddHealth: () async {
                      final saved = await context.pushNamed(
                        AppRoutes.nameAnimalRegistroSalud,
                        pathParameters: {'uuid': widget.animalUuid},
                      );
                      if (saved == true && mounted) {
                        _reload();
                      }
                    },
                    onAddCommercial: () async {
                      final saved = await context.pushNamed(
                        AppRoutes.nameAnimalRegistroComercial,
                        pathParameters: {'uuid': widget.animalUuid},
                      );
                      if (saved == true && mounted) {
                        _reload();
                      }
                    },
                    onAddMovement: () async {
                      final saved = await context.pushNamed(
                        AppRoutes.nameAnimalRegistroMovimiento,
                        pathParameters: {'uuid': widget.animalUuid},
                      );
                      if (saved == true && mounted) {
                        _reload();
                      }
                    },
                    onAddCost: () async {
                      final saved = await context.pushNamed(
                        AppRoutes.nameAnimalRegistroCosto,
                        pathParameters: {'uuid': widget.animalUuid},
                      );
                      if (saved == true && mounted) {
                        _reload();
                      }
                    },
                  ),
                )
              : null,
          body: FutureBuilder<DetailData>(
            future: _future,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                return DetailError(
                  message: '${snapshot.error}',
                  onRetry: _reload,
                );
              }
              final data = snapshot.data;
              if (data == null) {
                return DetailError(message: l10n.detailNotFound);
              }
              return _buildContent(context, data);
            },
          ),
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, DetailData data) {
    final l10n = AppLocalizations.of(context);

    // Extra top padding for the rounded-card effect (purple shows through the
    // rounded corners above the white surface).
    const double tabBarTopRadius = 19.0;
    // Total height = radius overlap + actual tab bar height.
    const double tabBarHeight = tabBarTopRadius + 48.0;

    return NestedScrollView(
      // ── outer scroll: header + sticky tab bar ────────────────────────
      headerSliverBuilder: (context, innerBoxIsScrolled) => [
        // 1. Collapsible animal header (photo, name, etc.)
        SliverAppBar(
          pinned: true,
          expandedHeight: animalHeaderExpandedHeight,
          backgroundColor: Colors.transparent,
          foregroundColor: Colors.white,
          elevation: 0,
          scrolledUnderElevation: 0,
          surfaceTintColor: Colors.transparent,
          // forceElevated drives the shadow when inner list scrolls under the
          // pinned app bar, giving a nice depth cue.
          forceElevated: innerBoxIsScrolled,
          actions: [
            IconButton(
              tooltip: 'Editar',
              onPressed: () async {
                final saved = await context.pushNamed(
                  AppRoutes.nameAnimalEditar,
                  pathParameters: {'uuid': widget.animalUuid},
                );
                if (saved == true && mounted) _reload();
              },
              icon: const Icon(Icons.edit_outlined),
            ),
            IconButton(
              tooltip: l10n.detailReload,
              onPressed: _reload,
              icon: const Icon(Icons.refresh),
            ),
          ],
          flexibleSpace: CollapsibleAnimalHeader(animal: data.animal),
          // ⚠️ No `bottom:` here — the TabBar lives in its own sliver below.
        ),

        // 2. Sticky TabBar sliver — stays pinned right below the app bar.
        SliverPersistentHeader(
          pinned: true,
          delegate: _StickyTabBarDelegate(
            tabBar: TabBar(
              controller: _tabController,
              // Dark labels on white card background.
              labelColor: Theme.of(context).primaryColor,
              unselectedLabelColor: Colors.black54,
              labelStyle: const TextStyle(fontWeight: FontWeight.w600),
              indicatorColor: Theme.of(context).primaryColor,
              indicatorWeight: 3,
              dividerHeight: 0,
              tabs: [
                Tab(text: l10n.tabInformation),
                Tab(text: l10n.tabHistory),
                Tab(text: l10n.tabRecords),
              ],
            ),
            height: tabBarHeight,
            topRadius: tabBarTopRadius,
          ),
        ),
      ],

      // ── inner scroll: tab content ─────────────────────────────────────
      body: TabBarView(
        controller: _tabController,
        children: [
          InfoTab(
            key: const PageStorageKey('info_tab'),
            animal: data.animal,
            lotesRepository: widget.lotesRepository,
          ),
          HistoryTab(
            key: const PageStorageKey('history_tab'),
            animal: data.animal,
            data: data,
          ),
          RecordsTab(key: const PageStorageKey('records_tab'), data: data),
        ],
      ),
    );
  }
}

// ── Sticky TabBar delegate ────────────────────────────────────────────────────

/// Renders the [TabBar] inside a white card with rounded top corners, creating
/// the "floating card" effect seen in the design: the purple app-bar colour
/// shows through the rounded corners above the white surface.
class _StickyTabBarDelegate extends SliverPersistentHeaderDelegate {
  const _StickyTabBarDelegate({
    required this.tabBar,
    required this.height,
    this.topRadius = 16.0,
  });

  final TabBar tabBar;
  final double height;
  final double topRadius;

  @override
  double get minExtent => height;

  @override
  double get maxExtent => height;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    final radius = Radius.circular(topRadius);

    return Stack(
      children: [
        // Purple fill behind the rounded corners so the cutout looks correct.
        const Positioned.fill(child: ColoredBox(color: Colors.transparent)),
        // White card that sits on top with rounded top corners.
        Positioned.fill(
          top: topRadius, // push it down so only the rounded arch is clipped
          child: const ColoredBox(color: Color.fromARGB(255, 240, 239, 239)),
        ),
        // The actual rounded container wrapping the TabBar.
        Positioned.fill(
          child: Material(
            color: const Color.fromARGB(255, 240, 239, 239),
            borderRadius: BorderRadius.only(topLeft: radius, topRight: radius),
            // Subtle shadow for depth when pinned.
            elevation: overlapsContent ? 2 : 0,
            shadowColor: Colors.black26,
            child: tabBar,
          ),
        ),
      ],
    );
  }

  @override
  bool shouldRebuild(_StickyTabBarDelegate oldDelegate) =>
      oldDelegate.tabBar != tabBar ||
      oldDelegate.height != height ||
      oldDelegate.topRadius != topRadius;
}
