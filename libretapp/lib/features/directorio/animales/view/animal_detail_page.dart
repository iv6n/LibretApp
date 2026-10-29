/// features \u203a directorio \u203a animales \u203a view \u203a animal_detail_page \u2014 detail page for a single animal.
library;

import '../domain/repositories/weaning_record_repository.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:libretapp/app/widgets/widgets.dart';
import 'package:libretapp/core/widgets/widgets.dart';
import 'package:libretapp/features/directorio/animales/domain/services/animal_record_actions.dart';
import 'package:libretapp/core/di/injection.dart';
import 'package:libretapp/core/platform/release_features.dart';
import 'package:libretapp/core/router/app_routes.dart';
import 'package:libretapp/features/agenda/data/agenda_model.dart';
import 'package:libretapp/features/agenda/data/agenda_repository.dart';
import 'package:libretapp/features/directorio/animales/domain/repositories/care_repository.dart';
import 'package:libretapp/features/directorio/animales/domain/repositories/commercial_record_repository.dart';
import 'package:libretapp/features/directorio/animales/domain/repositories/cost_record_repository.dart';
import 'package:libretapp/features/directorio/animales/domain/repositories/health_record_repository.dart';
import 'package:libretapp/features/directorio/animales/domain/repositories/movement_record_repository.dart';
import 'package:libretapp/features/directorio/animales/domain/repositories/production_record_repository.dart';
import 'package:libretapp/features/directorio/animales/domain/repositories/reproduction_record_repository.dart';
import 'package:libretapp/features/directorio/animales/domain/repositories/weight_record_repository.dart';
import 'package:libretapp/features/directorio/animales/domain/animal_domain.dart';
import 'package:libretapp/features/directorio/animales/domain/services/care_calendar_service.dart';
import 'package:libretapp/features/directorio/animales/infrastructure/animal_repository.dart';
import 'package:libretapp/features/directorio/lotes/infrastructure/lotes_repository.dart';
import 'package:libretapp/features/directorio/animales/widgets/widgets.dart';
import 'package:libretapp/features/directorio/animales/widgets/movement_location_names.dart';
import 'package:libretapp/features/ubicaciones/domain/repositories/location_repository.dart';
import 'package:libretapp/features/milking/domain/milking_repository.dart';
import 'package:libretapp/l10n/app_localizations.dart';
import 'package:libretapp/theme/app_theme.dart';

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
    LocationRepository? locationRepository,
    CostRecordRepository? costRepo,
    MilkingRepository? milkingRepo,
    CareRepository? careRepo,
    AgendaRepository? agendaRepository,
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
       locationRepository =
           locationRepository ??
           (locator.isRegistered<LocationRepository>()
               ? locator<LocationRepository>()
               : null),
       costRepo = costRepo ?? locator<CostRecordRepository>(),
       milkingRepo = milkingRepo ?? locator<MilkingRepository>(),
       careRepo = careRepo ?? locator<CareRepository>(),
       agendaRepository = agendaRepository ?? locator<AgendaRepository>();

  final String animalUuid;
  final AnimalRepository repository;
  final LotesRepository lotesRepository;
  final WeightRecordRepository weightRepo;
  final HealthRecordRepository healthRepo;
  final ProductionRecordRepository productionRepo;
  final ReproductionRecordRepository reproductionRepo;
  final CommercialRecordRepository commercialRepo;
  final MovementRecordRepository movementRepo;
  final LocationRepository? locationRepository;
  final CostRecordRepository costRepo;
  final MilkingRepository milkingRepo;
  final CareRepository careRepo;
  final AgendaRepository agendaRepository;
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
    _tabController = TabController(length: 5, vsync: this);
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
    final offspringFuture = widget.repository.getByParentUuid(uuid);
    final agendaFuture = widget.agendaRepository.fetchEntries();

    final weanings = locator.isRegistered<WeaningRecordRepository>()
        ? await locator<WeaningRecordRepository>().getWeaningRecords(uuid)
        : const <WeaningRecord>[];
    final weights = await weightsFuture;
    final reproductions = await reproductionsFuture;
    final productions = await productionsFuture;
    final health = await healthFuture;
    final commercial = await commercialFuture;
    final movements = await movementsFuture;
    final movementLocationNames = await loadMovementLocationNames(
      movements,
      widget.locationRepository,
    );
    final costs = await costsFuture;
    final milkingRecords = await milkingFuture;
    final offspring = await offspringFuture;
    final agendaEntries = await agendaFuture;
    final ancestors = await _loadAncestors(animal);
    // Only males have a sire history, and it is derived from the females'
    // records rather than stored on him.
    final sireRecords = animal.sex == Sex.male
        ? await widget.reproductionRepo.getRecordsBySire(uuid)
        : const <ReproductionRecord>[];

    // A sold or dead animal is not due for anything new — its calendar is
    // whatever was already recorded, not regenerated.
    final carePending = animal.status.isInActiveHerd
        ? await CareCalendarService(widget.careRepo).regenerateFor(animal)
        : await widget.careRepo.getPendingForAnimal(uuid);
    final careRecords = await widget.careRepo.getRecordsForAnimal(uuid);
    final careRules = {
      for (final rule in await widget.careRepo.getRules()) rule.id: rule,
    };
    final agendaPending = agendaEntries
        .where(
          (entry) =>
              entry.animalIds.contains(uuid) &&
              entry.estado != AgendaEstado.completado &&
              entry.estado != AgendaEstado.verificado &&
              entry.estado != AgendaEstado.cancelado &&
              entry.estado != AgendaEstado.reprogramada,
        )
        .toList(growable: false);

    return DetailData(
      animal: animal,
      weights: weights,
      weanings: weanings,
      reproductions: reproductions,
      productions: productions,
      health: health,
      commercial: commercial,
      movements: movements,
      movementLocationNames: movementLocationNames,
      costs: costs,
      milkingRecords: milkingRecords,
      ancestors: ancestors,
      offspring: offspring,
      sireRecords: sireRecords,
      carePending: carePending,
      careRecords: careRecords,
      careRules: careRules,
      agendaPending: agendaPending,
    );
  }

  /// Walks up the parent links breadth-first, fetching only the animals the
  /// pedigree tree will actually draw. A three-generation tree tops out at 6
  /// ancestors, so this stays far cheaper than loading the herd.
  Future<Map<String, AnimalEntity>> _loadAncestors(AnimalEntity animal) async {
    final resolved = <String, AnimalEntity>{animal.uuid: animal};
    var frontier = <String>{...?_parentUuids(animal)};

    for (var depth = 1; depth < PedigreeService.defaultDepth; depth++) {
      final pending = frontier.difference(resolved.keys.toSet());
      if (pending.isEmpty) break;

      final fetched = await Future.wait(
        pending.map(widget.repository.getByUuid),
      );

      final next = <String>{};
      for (final ancestor in fetched) {
        if (ancestor == null) continue;
        resolved[ancestor.uuid] = ancestor;
        next.addAll(_parentUuids(ancestor) ?? const <String>{});
      }
      frontier = next;
    }

    return resolved;
  }

  Set<String>? _parentUuids(AnimalEntity animal) {
    final parents = <String>{};
    for (final uuid in [animal.sireUuid, animal.damUuid]) {
      final trimmed = uuid?.trim();
      if (trimmed != null && trimmed.isNotEmpty) parents.add(trimmed);
    }
    return parents.isEmpty ? null : parents;
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

  List<AnimalQuickAction> _actions(BuildContext context, AnimalEntity animal) {
    final l10n = AppLocalizations.of(context);
    return recordActionsFor(animal)
        .map((action) {
          final (icon, label, route) = switch (action) {
            AnimalRecordAction.weaning => (
              Icons.child_friendly_outlined,
              'Destete',
              AppRoutes.nameAnimalRegistroDestete,
            ),
            AnimalRecordAction.weight => (
              Icons.monitor_weight_outlined,
              l10n.detailActionWeight,
              AppRoutes.nameAnimalRegistroPeso,
            ),
            AnimalRecordAction.health => (
              Icons.medical_services_outlined,
              l10n.detailActionHealth,
              AppRoutes.nameAnimalRegistroSalud,
            ),
            AnimalRecordAction.reproduction => (
              Icons.favorite_outline,
              l10n.detailActionReproduction,
              AppRoutes.nameAnimalRegistroReproduccion,
            ),
            AnimalRecordAction.production => (
              Icons.insights_outlined,
              l10n.detailActionProduction,
              AppRoutes.nameAnimalRegistroProduccion,
            ),
            AnimalRecordAction.milking => (
              Icons.water_drop_outlined,
              'Ordeña',
              AppRoutes.nameRegistroOrdena,
            ),
            AnimalRecordAction.movement => (
              Icons.route_outlined,
              l10n.detailActionMovement,
              AppRoutes.nameAnimalRegistroMovimiento,
            ),
            AnimalRecordAction.commercial => (
              Icons.store_outlined,
              l10n.detailActionCommercial,
              AppRoutes.nameAnimalRegistroComercial,
            ),
            AnimalRecordAction.cost => (
              Icons.payments_outlined,
              l10n.detailActionCost,
              AppRoutes.nameAnimalRegistroCosto,
            ),
          };
          return AnimalQuickAction(
            icon: icon,
            label: label,
            onPressed: () async {
              final saved = action == AnimalRecordAction.milking
                  ? await context.pushNamed(
                      route,
                      queryParameters: {'animalUuid': animal.uuid},
                    )
                  : await context.pushNamed(
                      route,
                      pathParameters: {'uuid': animal.uuid},
                    );
              if (saved == true && mounted) _reload();
            },
          );
        })
        .toList(growable: false);
  }

  @override
  void didUpdateWidget(covariant AnimalDetailPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.animalUuid != widget.animalUuid) {
      _tabController.index = 0;
      _future = _loadData();
    }
  }

  @override
  Widget build(BuildContext context) {
    return ShellChromeScope(
      visible: false,
      child: FutureBuilder<DetailData>(
        future: _future,
        builder: (context, snapshot) {
          final data = snapshot.data;
          final loading = snapshot.connectionState == ConnectionState.waiting;
          final actions = data == null || loading || snapshot.hasError
              ? const <AnimalQuickAction>[]
              : _actions(context, data.animal);
          final showFab =
              widget.showQuickActions &&
              actions.isNotEmpty &&
              MediaQuery.viewInsetsOf(context).bottom == 0;
          return AnnotatedRegion<SystemUiOverlayStyle>(
            value: SystemUiOverlayStyle(
              statusBarIconBrightness:
                  Theme.of(context).colorScheme.primary.computeLuminance() > 0.5
                  ? Brightness.dark
                  : Brightness.light,
            ),
            child: Scaffold(
              appBar: data == null || snapshot.hasError
                  ? AppBar(title: const Text('Perfil del animal'))
                  : null,
              floatingActionButtonLocation:
                  FloatingActionButtonLocation.endFloat,
              floatingActionButton: showFab
                  ? QuickActionsFab(actions: actions)
                  : null,
              body: snapshot.hasError
                  ? DetailError(
                      message:
                          'No se pudo cargar el perfil. Tus datos siguen guardados en este dispositivo.',
                      onRetry: _reload,
                    )
                  : data == null
                  ? const AppLoadingIndicator()
                  : Stack(
                      children: [
                        _buildContent(context, data),
                        if (loading) const LinearProgressIndicator(),
                      ],
                    ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildContent(BuildContext context, DetailData data) {
    final l10n = AppLocalizations.of(context);

    // Extra top padding for the rounded-card effect (purple shows through the
    // rounded corners above the white surface).
    const double tabBarTopRadius = AppRadii.lg;
    // Total height = radius overlap + actual tab bar height.
    final double tabBarHeight =
        tabBarTopRadius +
        48.0 * MediaQuery.textScalerOf(context).scale(14) / 14;

    return NestedScrollView(
      // ── outer scroll: header + sticky tab bar ────────────────────────
      headerSliverBuilder: (context, innerBoxIsScrolled) => [
        // 1. Collapsible animal header (photo, name, etc.)
        SliverAppBar(
          pinned: true,
          expandedHeight: animalHeaderHeight(context),
          backgroundColor: Colors.transparent,
          foregroundColor: Theme.of(context).colorScheme.onPrimary,
          elevation: 0,
          scrolledUnderElevation: 0,
          surfaceTintColor: Colors.transparent,
          // forceElevated drives the shadow when inner list scrolls under the
          // pinned app bar, giving a nice depth cue.
          forceElevated: innerBoxIsScrolled,
          actions: [
            if (ReleaseFeatures.hardwareIntegrationsEnabled)
              IconButton(
                tooltip: 'Asignar RFID',
                onPressed: () => context.pushNamed(
                  AppRoutes.nameRfid,
                  queryParameters: {'animalUuid': widget.animalUuid},
                ),
                icon: const Icon(Icons.sensors_outlined),
              ),
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

        if (!data.animal.hasKnownAge || data.animal.sex == Sex.unknown)
          SliverToBoxAdapter(
            child: Card(
              margin: const EdgeInsets.all(12),
              child: ListTile(
                title: const Text('Ficha por completar'),
                subtitle: const Text('Los datos no registrados se muestran como Sin dato.'),
                trailing: TextButton(
                  onPressed: () async {
                    await context.pushNamed(AppRoutes.nameAnimalCompletar,
                      pathParameters: {'uuid': widget.animalUuid});
                    if (mounted) _reload();
                  },
                  child: const Text('Completar ficha'),
                ),
              ),
            ),
          ),

        // 2. Sticky TabBar sliver — stays pinned right below the app bar.
        SliverPersistentHeader(
          pinned: true,
          delegate: _StickyTabBarDelegate(
            tabBar: TabBar(
              controller: _tabController,
              // Dark labels on white card background.
              labelColor: Theme.of(context).colorScheme.primary,
              unselectedLabelColor: Theme.of(
                context,
              ).colorScheme.onSurfaceVariant,
              labelStyle: const TextStyle(fontWeight: FontWeight.w600),
              indicatorColor: Theme.of(context).primaryColor,
              indicatorWeight: 3,
              dividerHeight: 0,
              isScrollable: true,
              tabAlignment: TabAlignment.start,
              tabs: [
                const Tab(text: 'Resumen'),
                const Tab(text: 'Cuidados'),
                Tab(text: l10n.tabRecords),
                const Tab(text: 'Genealogía'),
                Tab(text: l10n.tabHistory),
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
            data: data,
            lotesRepository: widget.lotesRepository,
            onChanged: _reload,
            onShowCare: () => _tabController.animateTo(1),
            onEditPurpose: () async {
              final saved = await context.pushNamed(
                AppRoutes.nameAnimalEditar,
                pathParameters: {'uuid': widget.animalUuid},
              );
              if (saved == true && mounted) _reload();
            },
          ),
          CareTab(
            key: const PageStorageKey('care_tab'),
            data: data,
            careRepo: widget.careRepo,
            onChanged: _reload,
          ),
          RecordsTab(
            key: const PageStorageKey('records_tab'),
            data: data,
            onChanged: _reload,
          ),
          PedigreeTab(key: const PageStorageKey('pedigree_tab'), data: data),
          HistoryTab(
            key: const PageStorageKey('history_tab'),
            animal: data.animal,
            data: data,
          ),
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
          child: ColoredBox(color: Theme.of(context).colorScheme.surface),
        ),
        // The actual rounded container wrapping the TabBar.
        Positioned.fill(
          child: Material(
            color: Theme.of(context).colorScheme.surface,
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
