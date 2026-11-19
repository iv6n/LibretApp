/// features > inicio > view > inicio_view - customizable home dashboard.
library;

import 'package:libretapp/features/agenda/agenda.dart';
import 'package:libretapp/features/agenda/view/agenda_task_detail_page.dart';
import 'package:libretapp/features/directorio/lotes/infrastructure/lotes_repository.dart';

import 'package:libretapp/features/reportes/widgets/report_activity_tile.dart';

import 'package:libretapp/features/directorio/animales/domain/enums/species.dart';

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:libretapp/features/directorio/animales/infrastructure/animal_repository.dart';
import 'package:libretapp/core/utils/color_contrast.dart';
import 'package:libretapp/core/experience/app_experience.dart';
import 'package:libretapp/core/experience/care_profile.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:libretapp/app/widgets/widgets.dart';
import 'package:libretapp/core/core.dart';
import 'package:libretapp/features/biblioteca/data/library_manifest.dart';
import 'package:libretapp/features/finanzas/domain/finance_summary_service.dart';
import 'package:libretapp/features/inicio/bloc/inicio_bloc.dart';
import 'package:libretapp/features/inicio/bloc/inicio_event.dart';
import 'package:libretapp/features/inicio/bloc/inicio_state.dart';
import 'package:libretapp/features/inicio/data/dashboard_widget_config.dart';
import 'package:libretapp/features/inicio/data/inicio_dashboard_models.dart';
import 'package:libretapp/features/inicio/view/dashboard_customize_sheet.dart';
import 'package:libretapp/features/inicio/widgets/dashboard/dashboard_header.dart';
import 'package:libretapp/features/inicio/widgets/dashboard/dashboard_widgets.dart';
import 'package:libretapp/features/inicio/widgets/dashboard/quick_action_grid.dart';
import 'package:libretapp/features/inicio/widgets/weather_home_card.dart';
import 'package:libretapp/theme/app_theme.dart';

class InicioView extends StatefulWidget {
  const InicioView({super.key});

  static const double _tabletBreakpoint = 600;
  static const double _dashboardMaxWidth = 1200;

  @override
  State<InicioView> createState() => _InicioViewState();
}

class _InicioViewState extends State<InicioView> with WidgetsBindingObserver {
  bool _animalsSelected = false;
  final _hiddenAlerts = <String>{};
  String? _preferenceSignature;
  AgendaRefreshSignal? _agendaRefreshSignal;
  StreamSubscription<void>? _animalChanges;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    if (locator.isRegistered<AgendaRefreshSignal>()) {
      _agendaRefreshSignal = locator<AgendaRefreshSignal>()
        ..addListener(_refreshDashboard);
    }
    if (locator.isRegistered<AnimalRepository>()) {
      _animalChanges = locator<AnimalRepository>().watchChanges().listen(
        (_) => _refreshDashboard(),
      );
    }
  }

  void _refreshDashboard() {
    if (mounted) context.read<InicioBloc>().add(const RefreshInicio());
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) _refreshDashboard();
  }

  @override
  void dispose() {
    _agendaRefreshSignal?.removeListener(_refreshDashboard);
    _animalChanges?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final signature = AppExperienceScope.maybeOf(context)?.value.encode();
    final previous = _preferenceSignature;
    _preferenceSignature = signature;
    if (previous != null && previous != signature) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) context.read<InicioBloc>().add(const RefreshInicio());
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<InicioBloc, InicioState>(
      builder: (context, state) {
        final data = state.data;
        final preferences = AppExperienceScope.maybeOf(context)?.value;

        if (data == null && state.status == InicioStatus.loading) {
          return const SafeArea(
            child: Column(
              children: [
                WeatherHomeCard(),
                Expanded(child: AppLoadingIndicator()),
              ],
            ),
          );
        }

        if (data == null && state.status == InicioStatus.error) {
          return SafeArea(
            child: Column(
              children: [
                const WeatherHomeCard(),
                Expanded(
                  child: AppRetryState(
                    title: 'No se pudo cargar Inicio',
                    message: state.errorMessage,
                    onRetry: () {
                      context.read<InicioBloc>().add(const LoadInicio());
                    },
                  ),
                ),
              ],
            ),
          );
        }

        if (data == null) return const SizedBox.shrink();

        final theme = Theme.of(context);
        final bottomInset = ShellInsets.bottomSafePadding(context);
        // Keep the animal onboarding visible until the first animal exists.
        // Locations and lots may already be configured independently.
        final firstRun = data.totalAnimals == 0;
        final careProfile = resolveCareProfileFromCounts(
          selected: preferences?.careProfile,
          pets: data.petCount,
          livestock: data.livestockCount,
          preferredSpecies: preferences?.preferredSpecies ?? const [],
        );
        final widgets = List.of(state.widgetConfigs)
          ..sort((a, b) => a.order.compareTo(b.order));
        final todayCareItems = _buildTodayCareItems(
          data,
          DateUtils.dateOnly(DateTime.now()),
        );
        final showPending = widgets.any(
          (widget) =>
              widget.enabled && widget.type == DashboardWidgetType.pendingTasks,
        );
        final showAnimals = widgets.any(
          (widget) =>
              widget.enabled &&
              widget.type == DashboardWidgetType.animalSummary,
        );
        final pending = todayCareItems
            .where((item) => item.entryId != null)
            .toList();
        final alert = todayCareItems
            .where(
              (item) =>
                  item.tone != _CareItemTone.normal &&
                  !_hiddenAlerts.contains(item.key),
            )
            .firstOrNull;
        final animalsActive = showAnimals && (_animalsSelected || !showPending);
        return SafeArea(
          top: true,
          bottom: false,
          child: RefreshIndicator(
            onRefresh: () async {
              context.read<InicioBloc>().add(const RefreshInicio());
              await context.read<InicioBloc>().stream.firstWhere(
                (next) => !next.isLoading,
              );
            },
            child: ColoredBox(
              color: theme.scaffoldBackgroundColor,
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final textScale =
                      MediaQuery.textScalerOf(context).scale(14) / 14;
                  final isTablet =
                      constraints.maxWidth >= InicioView._tabletBreakpoint &&
                      textScale <= 1.3;
                  final contentWidth = constraints.maxWidth
                      .clamp(0.0, InicioView._dashboardMaxWidth)
                      .toDouble();
                  final horizontalPadding = isTablet
                      ? AppSpacing.lg
                      : AppSpacing.md;

                  return ListView(
                    padding: EdgeInsets.only(
                      bottom: bottomInset + AppSpacing.md,
                    ),
                    children: [
                      Center(
                        child: SizedBox(
                          width: contentWidth,
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: horizontalPadding,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                DashboardHeader(
                                  data: data,
                                  weatherCard: const WeatherHomeCard(
                                    compact: true,
                                  ),
                                ),
                                if (alert != null)
                                  Dismissible(
                                    key: ValueKey(alert.key),
                                    onDismissed: (_) => setState(
                                      () => _hiddenAlerts.add(alert.key),
                                    ),
                                    child: Card(
                                      color: theme.colorScheme.errorContainer,
                                      child: ListTile(
                                        leading: Icon(
                                          Icons.notification_important_outlined,
                                          color: theme
                                              .colorScheme
                                              .onErrorContainer,
                                        ),
                                        title: Text(alert.title),
                                        subtitle: Text(alert.message),
                                        onTap: () =>
                                            _openCareItem(context, alert),
                                        trailing: IconButton(
                                          tooltip: 'Ocultar aviso',
                                          icon: const Icon(Icons.close),
                                          onPressed: () => setState(
                                            () => _hiddenAlerts.add(alert.key),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                if (showAnimals || showPending) ...[
                                  const SizedBox(height: AppSpacing.sm),
                                  if (showAnimals && showPending)
                                    SegmentedButton<bool>(
                                      segments: [
                                        ButtonSegment(
                                          value: true,
                                          icon: const Icon(Icons.pets_outlined),
                                          label: Text(
                                            'Animales · ${data.totalAnimals}',
                                          ),
                                        ),
                                        ButtonSegment(
                                          value: false,
                                          icon: const Icon(
                                            Icons.checklist_rounded,
                                          ),
                                          label: Text(
                                            'Asuntos · ${pending.length}',
                                          ),
                                        ),
                                      ],
                                      showSelectedIcon: false,
                                      selected: {animalsActive},
                                      onSelectionChanged: (v) => setState(
                                        () => _animalsSelected = v.first,
                                      ),
                                    ),
                                  const SizedBox(height: AppSpacing.sm),
                                  if (animalsActive && !firstRun)
                                    _SpeciesCards(data: data)
                                  else if (!animalsActive)
                                    _TodayCarePanel(items: pending),
                                ],
                                if (firstRun && (animalsActive || !showPending))
                                  _GettingStartedCard(profile: careProfile),
                                const SizedBox(height: AppSpacing.md),
                                QuickActionGrid(
                                  compact: true,
                                  actions: firstRun
                                      ? state.quickActions
                                            .where(
                                              (a) =>
                                                  a.routeName !=
                                                  AppRoutes
                                                      .nameAnimalNuevoRapido,
                                            )
                                            .toList()
                                      : state.quickActions,
                                  onCustomizeTap: () =>
                                      showDashboardCustomizeSheet(
                                        context: context,
                                        widgets: state.widgetConfigs,
                                        actions: state.quickActions,
                                        profile: careProfile,
                                        onSaved: (w, a) {
                                          context.read<InicioBloc>().add(
                                            UpdateDashboardConfig(
                                              widgets: w,
                                              actions: a,
                                            ),
                                          );
                                        },
                                      ),
                                ),
                                const SizedBox(height: AppSpacing.md),
                                if (widgets.any(
                                  (w) =>
                                      w.enabled &&
                                      w.type ==
                                          DashboardWidgetType.recentActivity,
                                ))
                                  AppCard(
                                    title: 'Actividad reciente',
                                    body: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.stretch,
                                      children: [
                                        if (data.latestRecords.isEmpty)
                                          const Text(
                                            'Aquí aparecerán tus últimos registros.',
                                          ),
                                        for (final record in data.latestRecords)
                                          ReportActivityTile(item: record),
                                      ],
                                    ),
                                  ),
                                _DashboardWidgetsLayout(
                                  isTablet: isTablet,
                                  widgets: widgets,
                                  data: data,
                                  financeDetail: state.financeDetail,
                                  financeLoading: state.financeLoading,
                                  financeErrorMessage:
                                      state.financeErrorMessage,
                                  libraryItems: state.libraryPicks,
                                  libraryLoading: state.libraryLoading,
                                  libraryErrorMessage:
                                      state.libraryErrorMessage,
                                  onRetrySupplements: () => context
                                      .read<InicioBloc>()
                                      .add(const RefreshInicio()),
                                  showOnlyPopulated: true,
                                  featuredPending: showPending,
                                  featuredAnimals: showAnimals && !firstRun,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }
}

class _GettingStartedCard extends StatelessWidget {
  const _GettingStartedCard({required this.profile});

  final CareProfile? profile;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final artwork = _animalArtwork(profile);
    final textScale = MediaQuery.textScalerOf(context).scale(14) / 14;
    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 420 || textScale > 1.25;
        final content = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              profile == CareProfile.pets
                  ? 'Empieza con tus mascotas'
                  : profile == CareProfile.livestock
                  ? 'Empieza con tus animales'
                  : 'Organiza el cuidado de tus animales',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w800,
                height: 1.1,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              'Añade el primer perfil para tener sus datos, cuidados y próximas actividades en Inicio.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            _GettingStartedActions(profile: profile),
          ],
        );
        return Card(
          key: const ValueKey('complete-getting-started'),
          color: theme.colorScheme.surfaceContainerLow,
          clipBehavior: Clip.antiAlias,
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: compact
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      content,
                      const SizedBox(height: AppSpacing.xs),
                      Align(alignment: Alignment.centerRight, child: artwork),
                    ],
                  )
                : Row(
                    children: [
                      Expanded(child: content),
                      const SizedBox(width: AppSpacing.md),
                      artwork,
                    ],
                  ),
          ),
        );
      },
    );
  }
}

Widget _animalArtwork(CareProfile? profile) {
  final assets = switch (profile) {
    CareProfile.pets => const [
      'assets/images/canino.webp',
      'assets/images/felino.png',
    ],
    CareProfile.livestock => const ['assets/images/vaca.webp'],
    CareProfile.mixed || null => const [
      'assets/images/vaca.webp',
      'assets/images/canino.webp',
      'assets/images/felino.png',
    ],
  };
  return ExcludeSemantics(
    child: SizedBox(
      width: 150,
      height: 86,
      child: Stack(
        alignment: Alignment.center,
        children: [
          for (var index = 0; index < assets.length; index++)
            Positioned(
              left: (150 - (72 + (assets.length - 1) * 39)) / 2 + index * 39,
              child: Image.asset(
                assets[index],
                width: 72,
                height: 72,
                fit: BoxFit.contain,
                errorBuilder: (_, _, _) => const SizedBox.shrink(),
              ),
            ),
        ],
      ),
    ),
  );
}

Widget _registrationAction(
  BuildContext context, {
  required bool pet,
  required bool primary,
}) {
  void open() {
    if (pet) {
      context.pushNamed(
        AppRoutes.nameAnimalNuevoRapido,
        queryParameters: const {'kind': 'pet'},
      );
    } else {
      context.pushNamed(AppRoutes.nameAnimalNuevoRapido);
    }
  }

  final icon = Icon(pet ? Icons.pets_outlined : Icons.add_circle_outline);
  final label = Text(pet ? 'Añadir mascota' : 'Añadir animal');
  return primary
      ? FilledButton.icon(onPressed: open, icon: icon, label: label)
      : OutlinedButton.icon(onPressed: open, icon: icon, label: label);
}

class _GettingStartedActions extends StatelessWidget {
  const _GettingStartedActions({required this.profile});

  final CareProfile? profile;

  @override
  Widget build(BuildContext context) {
    final showPet =
        profile == CareProfile.pets ||
        profile == CareProfile.mixed ||
        profile == null;
    final showAnimal = profile != CareProfile.pets;
    return Wrap(
      spacing: AppSpacing.xs,
      runSpacing: AppSpacing.xs,
      children: [
        if (showAnimal) _registrationAction(context, pet: false, primary: true),
        if (showPet)
          _registrationAction(context, pet: true, primary: !showAnimal),
      ],
    );
  }
}

class _SpeciesCards extends StatelessWidget {
  const _SpeciesCards({required this.data});
  final InicioDashboardData data;
  @override
  Widget build(BuildContext context) {
    const images = {
      Species.cattle: 'vaca.webp',
      Species.canine: 'canino.webp',
      Species.feline: 'felino.png',
      Species.goat: 'cabra.webp',
      Species.sheep: 'oveja.webp',
      Species.equine: 'caballo.webp',
      Species.pig: 'cerdo.webp',
      Species.poultry: 'ave.webp',
    };
    final counts = data.speciesCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final colors = Theme.of(context).colorScheme;
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          for (final group in counts)
            Padding(
              padding: const EdgeInsets.only(right: AppSpacing.xs),
              child: Material(
                color: colors.surfaceContainerHigh,
                borderRadius: BorderRadius.circular(AppRadii.lg),
                child: InkWell(
                  borderRadius: BorderRadius.circular(AppRadii.lg),
                  onTap: () => context.push(
                    AppRoutes.animalesPath(
                      species: group.key.name,
                      clearFilters: true,
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 10,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            if (images[group.key] case final asset?)
                              Image.asset(
                                'assets/images/$asset',
                                height: 40,
                                width: 40,
                              )
                            else
                              const Icon(Icons.pets, size: 40),
                            const SizedBox(width: 12),
                            Text(
                              '${group.value}',
                              style: Theme.of(context).textTheme.headlineSmall
                                  ?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: colors.primary,
                                  ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          group.key.displayName,
                          style: Theme.of(context).textTheme.labelLarge,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _DashboardWidgetsLayout extends StatelessWidget {
  const _DashboardWidgetsLayout({
    required this.isTablet,
    required this.widgets,
    required this.data,
    required this.financeDetail,
    required this.financeLoading,
    required this.financeErrorMessage,
    required this.libraryItems,
    required this.libraryLoading,
    required this.libraryErrorMessage,
    required this.onRetrySupplements,
    required this.showOnlyPopulated,
    required this.featuredPending,
    required this.featuredAnimals,
  });

  final bool isTablet;
  final List<DashboardWidgetConfig> widgets;
  final InicioDashboardData data;
  final FinanceSummaryDetail? financeDetail;
  final bool financeLoading;
  final String? financeErrorMessage;
  final List<LibraryManifestBook> libraryItems;
  final bool libraryLoading;
  final String? libraryErrorMessage;
  final VoidCallback onRetrySupplements;
  final bool showOnlyPopulated;
  final bool featuredPending;
  final bool featuredAnimals;

  @override
  Widget build(BuildContext context) {
    final enabledWidgets = widgets.where((widget) {
      if (!widget.enabled ||
          widget.type == DashboardWidgetType.recentActivity ||
          widget.type == DashboardWidgetType.weather ||
          (featuredPending &&
              widget.type == DashboardWidgetType.upcomingEvents)) {
        return false;
      }
      if (widget.type == DashboardWidgetType.pendingTasks ||
          widget.type == DashboardWidgetType.animalSummary) {
        return false;
      }
      if (featuredPending && widget.type == DashboardWidgetType.healthAlerts) {
        return false;
      }
      if (widget.type == DashboardWidgetType.healthAlerts &&
          !data.alerts.any(_isHealthAlertItem)) {
        return false;
      }
      if (!showOnlyPopulated) return true;
      return switch (widget.type) {
        DashboardWidgetType.animalSummary => data.totalAnimals > 0,
        DashboardWidgetType.activeLocations => data.activeLocations.isNotEmpty,
        DashboardWidgetType.inventory => false,
        DashboardWidgetType.upcomingEvents => data.upcomingEvents.isNotEmpty,
        DashboardWidgetType.healthAlerts => true,
        DashboardWidgetType.upcomingCalvings =>
          data.upcomingCalvings.isNotEmpty,
        DashboardWidgetType.financeMonth =>
          financeLoading ||
              financeErrorMessage != null ||
              (financeDetail != null &&
                  (financeDetail!.summary.totalRevenue != 0 ||
                      financeDetail!.summary.totalExpenses != 0)),
        DashboardWidgetType.recentActivity =>
          data.recentActivity.length > (featuredAnimals ? 2 : 0),
        DashboardWidgetType.pendingTasks => data.tasks.any(
          (task) => !task.title.trimLeft().toLowerCase().startsWith('sin '),
        ),
        DashboardWidgetType.weather => data.weather != null,
        DashboardWidgetType.libraryPicks =>
          libraryItems.isNotEmpty ||
              libraryLoading ||
              libraryErrorMessage != null,
      };
    }).toList();

    if (!isTablet) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: enabledWidgets.map(_buildHost).toList(),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        const gap = AppSpacing.sm;
        final halfWidth = (constraints.maxWidth - gap) / 2;

        return Wrap(
          spacing: gap,
          runSpacing: 0,
          children: enabledWidgets.map((config) {
            final width = _isFullWidth(config.type)
                ? constraints.maxWidth
                : halfWidth;
            return SizedBox(
              key: ValueKey<String>('dashboard-widget-${config.id}'),
              width: width,
              child: DashboardWidgetHost(
                config: config,
                data: data,
                financeDetail: financeDetail,
                financeLoading: financeLoading,
                financeErrorMessage: financeErrorMessage,
                libraryItems: libraryItems,
                libraryLoading: libraryLoading,
                libraryErrorMessage: libraryErrorMessage,
                onRetrySupplements: onRetrySupplements,
                recentActivityOffset: featuredAnimals ? 2 : 0,
              ),
            );
          }).toList(),
        );
      },
    );
  }

  Widget _buildHost(DashboardWidgetConfig config) {
    return KeyedSubtree(
      key: ValueKey<String>('dashboard-widget-${config.id}'),
      child: DashboardWidgetHost(
        config: config,
        data: data,
        financeDetail: financeDetail,
        financeLoading: financeLoading,
        financeErrorMessage: financeErrorMessage,
        libraryItems: libraryItems,
        libraryLoading: libraryLoading,
        libraryErrorMessage: libraryErrorMessage,
        onRetrySupplements: onRetrySupplements,
        recentActivityOffset: featuredAnimals ? 2 : 0,
      ),
    );
  }

  bool _isFullWidth(DashboardWidgetType type) {
    return switch (type) {
      DashboardWidgetType.animalSummary ||
      DashboardWidgetType.healthAlerts ||
      DashboardWidgetType.pendingTasks ||
      DashboardWidgetType.libraryPicks => true,
      _ => false,
    };
  }
}

bool _isHealthAlertItem(InicioAlertItem alert) =>
    alert.severity != InicioAlertSeverity.info &&
    !alert.title.toLowerCase().contains('vencid');

class _HomeCareItem {
  const _HomeCareItem({
    required this.title,
    required this.message,
    required this.route,
    required this.tone,
    required this.priority,
    this.group,
    this.date,
  });

  final String title;
  final String message;
  final String route;
  final _CareItemTone tone;
  final int priority;
  String get key => [entryId ?? route, title, message, tone.name].join('|');
  final AgendaEventGroup? group;
  String? get entryId => group?.primaryEntry.id;
  final DateTime? date;
}

enum _CareItemTone { critical, warning, normal }

List<_HomeCareItem> _buildTodayCareItems(
  InicioDashboardData data,
  DateTime today,
) {
  final items = <_HomeCareItem>[];
  final dueEntries = {
    for (final e in [...data.dueEntries, ...data.upcomingEvents]) e.id: e,
  }.values.toList()..sort((a, b) => a.fecha.compareTo(b.fecha));

  for (final alert in data.alerts) {
    if (alert.severity == InicioAlertSeverity.info) continue;
    final isOverdueAgendaAlert = alert.title.toLowerCase().contains('vencid');
    if (isOverdueAgendaAlert && dueEntries.isNotEmpty) continue;
    final tone = switch (alert.severity) {
      InicioAlertSeverity.critical => _CareItemTone.critical,
      InicioAlertSeverity.warning => _CareItemTone.warning,
      InicioAlertSeverity.info => _CareItemTone.normal,
    };
    items.add(
      _HomeCareItem(
        title: alert.title,
        message: alert.message,
        route: alert.targetRoute,
        tone: tone,
        priority: tone == _CareItemTone.critical ? 0 : 1,
      ),
    );
  }

  final categories = const AgendaTaskGrouper().group(dueEntries, today: today);
  for (final group in categories.expand((category) => category.events)) {
    final entry = group.rows.first.entry;
    final day = DateUtils.dateOnly(entry.fecha);
    final overdue = day.isBefore(today);
    final displayTitle = overdue
        ? group.titulo.replaceFirst(
            RegExp(r'^Parto próximo\s*\([^)]*\)'),
            'Aviso de parto',
          )
        : group.titulo;
    final rank = switch (entry.prioridad) {
      AgendaPrioridad.urgente => 0,
      AgendaPrioridad.alta => 1,
      _ when overdue => 2,
      AgendaPrioridad.baja => 4,
      _ => 3,
    };
    final timing = overdue
        ? 'Vencida desde ${day.day}/${day.month}'
        : day == today
        ? 'Hoy'
        : 'Próxima · ${day.day}/${day.month}';
    items.add(
      _HomeCareItem(
        title: displayTitle,
        message: rank < 2 ? 'Prioridad ${entry.prioridad} · $timing' : timing,
        route: AppRoutes.agenda,
        group: group,
        date: day,
        tone: rank == 0
            ? _CareItemTone.critical
            : rank <= 2
            ? _CareItemTone.warning
            : _CareItemTone.normal,
        priority: rank,
      ),
    );
  }

  items.sort((a, b) {
    final byPriority = a.priority.compareTo(b.priority);
    if (byPriority != 0) return byPriority;
    final aDate = a.date;
    final bDate = b.date;
    if (aDate != null && bDate != null) return aDate.compareTo(bDate);
    return 0;
  });
  return items;
}

class _TodayCarePanel extends StatelessWidget {
  const _TodayCarePanel({required this.items});

  final List<_HomeCareItem> items;

  @override
  Widget build(BuildContext context) => AppCard(
    title: 'Pendientes',
    body: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (items.isEmpty) const Text('Todo al día'),
        for (final item in items.take(3)) _TodayCareTile(item: item),
        if (items.length > 3)
          TextButton(
            onPressed: () => showModalBottomSheet<void>(
              context: context,
              useSafeArea: true,
              isScrollControlled: true,
              builder: (sheet) => FractionallySizedBox(
                heightFactor: .8,
                child: ListView.builder(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  itemCount: items.length,
                  itemBuilder: (_, i) => _TodayCareTile(
                    item: items[i],
                    onTap: () {
                      Navigator.pop(sheet);
                      _openCareItem(context, items[i]);
                    },
                  ),
                ),
              ),
            ),
            child: Text('Ver los ${items.length} pendientes'),
          ),
      ],
    ),
  );
}

class _TodayCareTile extends StatelessWidget {
  const _TodayCareTile({required this.item, this.onTap});

  final _HomeCareItem item;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final status = theme.extension<AppStatusTheme>();
    final toneColor = switch (item.tone) {
      _CareItemTone.critical => status?.error ?? theme.colorScheme.error,
      _CareItemTone.warning => status?.warning ?? AppColors.warning,
      _CareItemTone.normal => theme.colorScheme.primary,
    };
    final background = Color.alphaBlend(
      toneColor.withValues(
        alpha: theme.brightness == Brightness.dark ? .22 : .10,
      ),
      theme.colorScheme.surface,
    );
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.xxs),
      child: Material(
        color: background,
        borderRadius: BorderRadius.circular(AppRadii.sm),
        child: InkWell(
          borderRadius: BorderRadius.circular(AppRadii.sm),
          onTap: onTap ?? () => _openCareItem(context, item),
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 56),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.sm,
                vertical: AppSpacing.xs,
              ),
              child: Row(
                children: [
                  Icon(
                    item.entryId != null
                        ? (item.tone == _CareItemTone.warning
                              ? Icons.event_busy_outlined
                              : Icons.event_available_outlined)
                        : (item.tone == _CareItemTone.critical
                              ? Icons.priority_high_rounded
                              : Icons.notifications_active_outlined),
                    size: 20,
                    color: readableTextColor(toneColor, background),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          item.title,
                          softWrap: true,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(
                          item.message,
                          softWrap: true,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: AppSpacing.xxs),
                  if ((item.group?.animalCount ?? 0) > 0)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surface,
                        borderRadius: BorderRadius.circular(AppRadii.pill),
                      ),
                      child: Text(
                        item.group!.animalCount == 1
                            ? '1 animal'
                            : '${item.group!.animalCount} animales',
                        style: theme.textTheme.labelSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  const Icon(Icons.chevron_right, size: 18),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

void _openCareItem(BuildContext context, _HomeCareItem item) {
  final group = item.group;
  if (group == null) {
    context.push(item.route);
    return;
  }
  Navigator.of(context).push(
    MaterialPageRoute<void>(
      builder: (_) => BlocProvider(
        create: (_) => AgendaBloc(
          locator<AgendaRepository>(),
          lotesRepository: locator<LotesRepository>(),
          refreshSignal: locator<AgendaRefreshSignal>(),
          registrationRepository: locator<AgendaRegistrationRepository>(),
          registrationReadService: locator<AgendaRegistrationReadService>(),
        )..add(const LoadAgenda()),
        child: AgendaTaskDetailPage(group: group),
      ),
    ),
  );
}
