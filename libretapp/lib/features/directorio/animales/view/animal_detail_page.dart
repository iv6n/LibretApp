import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:libretapp/app/widgets/widgets.dart';
import 'package:libretapp/core/database/isar_database.dart';
import 'package:libretapp/core/di/injection.dart';
import 'package:libretapp/features/directorio/animales/application/bloc/animal_bloc.dart';
import 'package:libretapp/features/directorio/animales/application/bloc/animal_event.dart';
import 'package:libretapp/features/directorio/animales/application/bloc/animal_state.dart';
import 'package:libretapp/features/directorio/animales/domain/entities/commercial_record.dart';
import 'package:libretapp/features/directorio/animales/domain/entities/cost_record.dart';
import 'package:libretapp/features/directorio/animales/domain/entities/health_record.dart';
import 'package:libretapp/features/directorio/animales/domain/entities/movement_record.dart';
import 'package:libretapp/features/directorio/animales/domain/entities/production_record.dart';
import 'package:libretapp/features/directorio/animales/domain/entities/reproduction_record.dart';
import 'package:libretapp/features/directorio/animales/domain/entities/weight_record.dart';
import 'package:libretapp/features/directorio/animales/infrastructure/animal_repository.dart';
import 'package:libretapp/features/directorio/lotes/infrastructure/lotes_repository.dart';
import 'package:libretapp/features/directorio/animales/widgets/widgets.dart';
import 'package:libretapp/features/ubicaciones/infrastructure/repositories/isar_location_repository.dart';
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
  final _locationRepository = IsarLocationRepository(locator<IsarDatabase>());

  @override
  void initState() {
    super.initState();
    _future = _loadData();
  }

  // ── data ──────────────────────────────────────────────────────────────

  Future<DetailData> _loadData() async {
    final animal = await widget.repository.getByUuid(widget.animalUuid);
    if (animal == null) throw Exception('Animal no encontrado');

    final uuid = animal.uuid;
    final results = await Future.wait([
      widget.repository.getWeightRecords(uuid),
      widget.repository.getReproductionRecords(uuid),
      widget.repository.getProductionRecords(uuid),
      widget.repository.getHealthRecords(uuid),
      widget.repository.getCommercialRecords(uuid),
      widget.repository.getMovementRecords(uuid),
      widget.repository.getCostRecords(uuid),
    ]);

    return DetailData(
      animal: animal,
      weights: results[0] as List<WeightRecord>,
      reproductions: results[1] as List<ReproductionRecord>,
      productions: results[2] as List<ProductionRecord>,
      health: results[3] as List<HealthRecord>,
      commercial: results[4] as List<CommercialRecord>,
      movements: results[5] as List<MovementRecord>,
      costs: results[6] as List<CostRecord>,
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

  // ── location / batch sheet ────────────────────────────────────────────

  Future<void> _openLocationBatchSheet(DetailData data) async {
    final locations = await _locationRepository.getAll();
    final animals = await widget.repository.getAll();

    if (!mounted) return;
    await showLocationBatchSheet(
      context,
      animal: data.animal,
      locations: locations,
      allAnimals: animals,
      lotesRepository: widget.lotesRepository,
      dispatchAndAwait: _dispatchAndAwait,
      onReload: _reload,
    );
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
      child: Scaffold(
        appBar: AppBar(
          title: Text(l10n.animalDetailTitle),
          actions: [
            IconButton(
              tooltip: l10n.detailReload,
              onPressed: _reload,
              icon: const Icon(Icons.refresh),
            ),
          ],
        ),
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
    );
  }

  Widget _buildContent(BuildContext context, DetailData data) {
    final l10n = AppLocalizations.of(context);
    return DefaultTabController(
      length: 3,
      child: Column(
        children: [
          DetailHeader(animal: data.animal),

          const SizedBox(height: 4),
          TabBar(
            labelColor: Theme.of(context).colorScheme.primary,
            tabs: [
              Tab(text: l10n.tabInformation),
              Tab(text: l10n.tabHistory),
              Tab(text: l10n.tabRecords),
            ],
          ),
          const SizedBox(height: 8),
          Expanded(
            child: TabBarView(
              children: [
                InfoTab(
                  key: const PageStorageKey('info_tab'),
                  animal: data.animal,
                  lotesRepository: widget.lotesRepository,
                ),
                HistoryTab(
                  key: const PageStorageKey('history_tab'),
                  animal: data.animal,
                ),
                RecordsTab(
                  key: const PageStorageKey('records_tab'),
                  data: data,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
