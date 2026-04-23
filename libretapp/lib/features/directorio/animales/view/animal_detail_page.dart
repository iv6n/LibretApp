import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:libretapp/app/widgets/widgets.dart';
import 'package:libretapp/core/di/injection.dart';
import 'package:libretapp/core/router/app_routes.dart';
import 'package:libretapp/features/directorio/animales/application/bloc/animal_bloc.dart';
import 'package:libretapp/features/directorio/animales/application/bloc/animal_event.dart';
import 'package:libretapp/features/directorio/animales/application/bloc/animal_state.dart';
import 'package:libretapp/features/directorio/animales/domain/entities/animal_entity.dart';
import 'package:libretapp/features/directorio/animales/infrastructure/animal_repository.dart';
import 'package:libretapp/features/directorio/lotes/infrastructure/lotes_repository.dart';
import 'package:libretapp/features/directorio/animales/widgets/widgets.dart';
import 'package:libretapp/l10n/app_localizations.dart';

/// Detail page for a single animal.
///
/// The [AnimalBloc] is provided by the router — this page only consumes it.
class AnimalDetailPage extends StatefulWidget {
  AnimalDetailPage({
    required this.animalUuid,
    this.showQuickActions = true,
    AnimalRepository? repository,
    LotesRepository? lotesRepository,
    super.key,
  }) : repository = repository ?? locator<AnimalRepository>(),
       lotesRepository = lotesRepository ?? locator<LotesRepository>();

  final String animalUuid;
  final AnimalRepository repository;
  final LotesRepository lotesRepository;
  final bool showQuickActions;

  @override
  State<AnimalDetailPage> createState() => _AnimalDetailPageState();
}

class _AnimalDetailPageState extends State<AnimalDetailPage> {
  late Future<DetailData> _future;
  AnimalEntity? _loadedAnimal;

  @override
  void initState() {
    super.initState();
    _future = _loadData();
  }

  // ── data ──────────────────────────────────────────────────────────────

  Future<DetailData> _loadData() async {
    final animal = await widget.repository.getByUuid(widget.animalUuid);
    if (animal == null) throw Exception('Animal no encontrado');
    _loadedAnimal = animal;

    final uuid = animal.uuid;
    final weightsFuture = widget.repository.getWeightRecords(uuid);
    final reproductionsFuture = widget.repository.getReproductionRecords(uuid);
    final productionsFuture = widget.repository.getProductionRecords(uuid);
    final healthFuture = widget.repository.getHealthRecords(uuid);
    final commercialFuture = widget.repository.getCommercialRecords(uuid);
    final movementsFuture = widget.repository.getMovementRecords(uuid);
    final costsFuture = widget.repository.getCostRecords(uuid);

    final weights = await weightsFuture;
    final reproductions = await reproductionsFuture;
    final productions = await productionsFuture;
    final health = await healthFuture;
    final commercial = await commercialFuture;
    final movements = await movementsFuture;
    final costs = await costsFuture;

    return DetailData(
      animal: animal,
      weights: weights,
      reproductions: reproductions,
      productions: productions,
      health: health,
      commercial: commercial,
      movements: movements,
      costs: costs,
    );
  }

  void _reload() => setState(() => _future = _loadData());

  // ── bloc helper ───────────────────────────────────────────────────────

  Future<bool> _dispatchAndAwait(AnimalEvent event) async {
    final bloc = context.read<AnimalBloc>();
    final future = bloc.stream
        .skip(1)
        .firstWhere(
          (state) => state.status != AnimalStatus.loading,
          orElse: () => bloc.state,
        );
    bloc.add(event);
    final nextState = await future;
    if (!mounted) return false;
    if (nextState.status == AnimalStatus.failure) {
      final message = nextState.errorMessage ?? 'Ocurrió un error';
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
      return false;
    }
    return true;
  }

  // ── build ─────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final fabBottomPadding = widget.showQuickActions
        ? ShellInsets.fabDockPadding(context)
        : 0.0;
    return ShellChromeScope(
      visible: false,
      child: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.light,
        child: Scaffold(
          floatingActionButtonLocation: widget.showQuickActions
              ? FloatingActionButtonLocation.endDocked
              : null,
          floatingActionButton: widget.showQuickActions
              ? Padding(
                  padding: EdgeInsets.only(bottom: fabBottomPadding),
                  child: QuickActionsFab(
                    onAddWeight: () => showWeightForm(
                      context,
                      animalUuid: widget.animalUuid,
                      dispatchAndAwait: _dispatchAndAwait,
                      onReload: _reload,
                    ),
                    onAddReproduction: () => showReproductionForm(
                      context,
                      animalUuid: widget.animalUuid,
                      dispatchAndAwait: _dispatchAndAwait,
                      onReload: _reload,
                      animal: _loadedAnimal,
                    ),
                    onAddProduction: () => showProductionForm(
                      context,
                      animalUuid: widget.animalUuid,
                      dispatchAndAwait: _dispatchAndAwait,
                      onReload: _reload,
                    ),
                    onAddHealth: () => showHealthForm(
                      context,
                      animalUuid: widget.animalUuid,
                      dispatchAndAwait: _dispatchAndAwait,
                      onReload: _reload,
                      animal: _loadedAnimal,
                    ),
                    onAddCommercial: () => showCommercialForm(
                      context,
                      animalUuid: widget.animalUuid,
                      dispatchAndAwait: _dispatchAndAwait,
                      onReload: _reload,
                    ),
                    onAddMovement: () => showMovementForm(
                      context,
                      animalUuid: widget.animalUuid,
                      dispatchAndAwait: _dispatchAndAwait,
                      onReload: _reload,
                      animal: _loadedAnimal,
                    ),
                    onAddCost: () => showCostForm(
                      context,
                      animalUuid: widget.animalUuid,
                      dispatchAndAwait: _dispatchAndAwait,
                      onReload: _reload,
                    ),
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

    return DefaultTabController(
      length: 3,
      child: NestedScrollView(
        headerSliverBuilder: (context, _) => [
          SliverAppBar(
            pinned: true,
            expandedHeight: animalHeaderExpandedHeight,
            backgroundColor: Colors.transparent,
            foregroundColor: Colors.white,
            elevation: 0,
            scrolledUnderElevation: 0,
            surfaceTintColor: Colors.transparent,
            actions: [
              IconButton(
                tooltip: 'Editar',
                onPressed: () async {
                  final saved = await context.pushNamed(
                    AppRoutes.nameAnimalEditar,
                    pathParameters: {'uuid': widget.animalUuid},
                  );
                  if (saved == true && mounted) {
                    _reload();
                  }
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
            bottom: TabBar(
              labelColor: Colors.white,
              unselectedLabelColor: Colors.white70,
              indicatorColor: Colors.white,
              indicatorWeight: 3,
              dividerHeight: 0,
              tabs: [
                Tab(text: l10n.tabInformation),
                Tab(text: l10n.tabHistory),
                Tab(text: l10n.tabRecords),
              ],
            ),
          ),
        ],
        body: TabBarView(
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
      ),
    );
  }
}
