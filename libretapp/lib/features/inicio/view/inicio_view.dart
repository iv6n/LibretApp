/// features > inicio > view > inicio_view - customizable home dashboard.
library;

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:libretapp/features/agenda/data/agenda_refresh_signal.dart';
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
                                DashboardHeader(data: data),
                                if (firstRun)
                                  _GettingStartedCard(profile: careProfile)
                                else
                                  _CareDashboardOverview(
                                    isTablet: isTablet,
                                    data: data,
                                    profile: careProfile,
                                    items: todayCareItems,
                                  ),
                                const SizedBox(height: AppSpacing.sm),
                                if (!firstRun) ...[
                                  _DashboardPrimaryActions(
                                    profile: careProfile,
                                    data: data,
                                  ),
                                  const SizedBox(height: AppSpacing.sm),
                                ],
                                QuickActionGrid(
                                  actions: state.quickActions
                                      .where(
                                        (action) =>
                                            action.routeName !=
                                            AppRoutes.nameAnimalNuevoRapido,
                                      )
                                      .toList(growable: false),
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
                                const SizedBox(height: AppSpacing.sm),
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
                                ),
                                const WeatherHomeCard(),
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
              'Registra el primero para tener sus cuidados y actividades a la mano.',
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
                      Align(alignment: Alignment.centerRight, child: artwork),
                      const SizedBox(height: AppSpacing.xs),
                      content,
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
        if (showPet)
          FilledButton.icon(
            onPressed: () => context.pushNamed(
              AppRoutes.nameAnimalNuevoRapido,
              queryParameters: const {'kind': 'pet'},
            ),
            icon: const Icon(Icons.pets_outlined),
            label: const Text('Añadir mascota'),
          ),
        if (showAnimal)
          if (showPet)
            OutlinedButton.icon(
              onPressed: () =>
                  context.pushNamed(AppRoutes.nameAnimalNuevoRapido),
              icon: const Icon(Icons.add_circle_outline),
              label: const Text('Añadir animal'),
            )
          else
            FilledButton.icon(
              onPressed: () =>
                  context.pushNamed(AppRoutes.nameAnimalNuevoRapido),
              icon: const Icon(Icons.add_circle_outline),
              label: const Text('Añadir animal'),
            ),
      ],
    );
  }
}

class _CareProfileSummaryCard extends StatelessWidget {
  const _CareProfileSummaryCard({
    required this.profile,
    required this.data,
    required this.pendingCount,
  });

  final CareProfile? profile;
  final InicioDashboardData data;
  final int pendingCount;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final pets =
        data.petCount > 0 ||
        profile == CareProfile.pets ||
        profile == CareProfile.mixed;
    final livestock =
        data.livestockCount > 0 ||
        profile == CareProfile.livestock ||
        profile == CareProfile.mixed;
    return Card(
      color: theme.colorScheme.surfaceContainerLow,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.sm),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Tu resumen',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Wrap(
              alignment: WrapAlignment.spaceBetween,
              spacing: AppSpacing.xs,
              runSpacing: AppSpacing.sm,
              children: [
                if (pets)
                  _SummaryMetric(
                    icon: Icons.pets_outlined,
                    label: 'Mascotas',
                    count: data.petCount,
                  ),
                if (livestock)
                  _SummaryMetric(
                    icon: Icons.agriculture_outlined,
                    label: 'Ganado',
                    count: data.livestockCount,
                  ),
                if (profile == null)
                  _SummaryMetric(
                    icon: Icons.pets_outlined,
                    label: 'Animales',
                    count: data.totalAnimals,
                  ),
                _SummaryMetric(
                  icon: Icons.event_available_outlined,
                  label: 'Pendientes',
                  count: pendingCount,
                  attention: pendingCount > 0,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _SummaryMetric extends StatelessWidget {
  const _SummaryMetric({
    required this.icon,
    required this.label,
    required this.count,
    this.attention = false,
  });
  final IconData icon;
  final String label;
  final int count;
  final bool attention;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SizedBox(
      width: 84,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: theme.colorScheme.onSurfaceVariant, size: 20),
          const SizedBox(height: AppSpacing.xxs),
          Text(
            '$count',
            style: theme.textTheme.titleLarge?.copyWith(
              color: attention
                  ? (theme.extension<AppStatusTheme>()?.warning ??
                        AppColors.warning)
                  : theme.colorScheme.primary,
              fontWeight: FontWeight.w800,
            ),
          ),
          Text(
            label,
            maxLines: 2,
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class _CareDashboardOverview extends StatelessWidget {
  const _CareDashboardOverview({
    required this.isTablet,
    required this.data,
    required this.profile,
    required this.items,
  });

  final bool isTablet;
  final InicioDashboardData data;
  final CareProfile? profile;
  final List<_HomeCareItem> items;

  @override
  Widget build(BuildContext context) {
    final carePanel = _TodayCarePanel(items: items);
    final summary = _CareProfileSummaryCard(
      profile: profile,
      data: data,
      pendingCount: items.length,
    );
    if (!isTablet) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          carePanel,
          const SizedBox(height: AppSpacing.sm),
          summary,
        ],
      );
    }
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(flex: 3, child: carePanel),
        const SizedBox(width: AppSpacing.sm),
        Expanded(flex: 2, child: summary),
      ],
    );
  }
}

class _DashboardPrimaryActions extends StatelessWidget {
  const _DashboardPrimaryActions({required this.profile, required this.data});

  final CareProfile? profile;
  final InicioDashboardData data;

  @override
  Widget build(BuildContext context) {
    final showPets =
        profile == CareProfile.pets ||
        profile == CareProfile.mixed ||
        data.petCount > 0;
    final showAnimals = profile != CareProfile.pets || data.livestockCount > 0;
    final showBoth = showPets && showAnimals;
    return Wrap(
      spacing: AppSpacing.xs,
      runSpacing: AppSpacing.xs,
      children: [
        if (showPets)
          FilledButton.icon(
            onPressed: () => context.pushNamed(
              AppRoutes.nameAnimalNuevoRapido,
              queryParameters: const {'kind': 'pet'},
            ),
            icon: const Icon(Icons.pets_outlined),
            label: const Text('Añadir mascota'),
          ),
        if (showAnimals)
          if (showBoth)
            OutlinedButton.icon(
              onPressed: () =>
                  context.pushNamed(AppRoutes.nameAnimalNuevoRapido),
              icon: const Icon(Icons.add_circle_outline),
              label: const Text('Añadir animal'),
            )
          else
            FilledButton.icon(
              onPressed: () =>
                  context.pushNamed(AppRoutes.nameAnimalNuevoRapido),
              icon: const Icon(Icons.add_circle_outline),
              label: const Text('Alta rápida'),
            ),
        OutlinedButton.icon(
          onPressed: () =>
              context.go(AppRoutes.animalesPath(focusSearch: true)),
          icon: const Icon(Icons.search),
          label: const Text('Buscar animal'),
        ),
      ],
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

  @override
  Widget build(BuildContext context) {
    final enabledWidgets = widgets.where((widget) {
      if (!widget.enabled) return false;
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
        DashboardWidgetType.recentActivity => data.recentActivity.isNotEmpty,
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
    this.entryId,
    this.date,
  });

  final String title;
  final String message;
  final String route;
  final _CareItemTone tone;
  final int priority;
  final String? entryId;
  final DateTime? date;
}

enum _CareItemTone { critical, warning, normal }

List<_HomeCareItem> _buildTodayCareItems(
  InicioDashboardData data,
  DateTime today,
) {
  final items = <_HomeCareItem>[];
  final dueEntries = List.of(data.dueEntries)
    ..sort((a, b) => a.fecha.compareTo(b.fecha));

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

  for (final entry in dueEntries) {
    final day = DateUtils.dateOnly(entry.fecha);
    final overdue = day.isBefore(today);
    items.add(
      _HomeCareItem(
        title: entry.titulo,
        message: overdue
            ? 'Vencida desde ${entry.fecha.day}/${entry.fecha.month}'
            : 'Programada para hoy',
        route: AppRoutes.agenda,
        entryId: entry.id,
        date: day,
        tone: overdue ? _CareItemTone.warning : _CareItemTone.normal,
        priority: overdue ? 1 : 2,
      ),
    );
  }

  for (final task in data.tasks) {
    if (task.title.trimLeft().toLowerCase().startsWith('sin ')) continue;
    if (items.any((item) => item.route == task.targetRoute)) continue;
    items.add(
      _HomeCareItem(
        title: task.title,
        message: task.message,
        route: task.targetRoute,
        tone: _CareItemTone.normal,
        priority: 3,
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
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    return Card(
      key: const ValueKey('inicio-pendientes-hoy'),
      color: colors.surfaceContainerLow,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Cuidados de hoy',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                if (items.isNotEmpty)
                  Text(
                    '${items.length}',
                    semanticsLabel:
                        '${items.length} pendiente${items.length == 1 ? '' : 's'}',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: colors.primary,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: AppSpacing.xs),
            if (items.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.check_circle_outline,
                      color:
                          theme.extension<AppStatusTheme>()?.success ??
                          AppColors.success,
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Todo al día',
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.xxs),
                          Text(
                            'No hay actividades vencidas ni avisos urgentes.',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: colors.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              )
            else
              for (final item in items.take(3)) _TodayCareTile(item: item),
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton.icon(
                onPressed: () => context.go(AppRoutes.agenda),
                icon: const Icon(Icons.calendar_month_outlined),
                label: const Text('Ver agenda completa'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TodayCareTile extends StatelessWidget {
  const _TodayCareTile({required this.item});

  final _HomeCareItem item;

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
        child: ListTile(
          minVerticalPadding: AppSpacing.xxs,
          contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
          leading: Icon(
            item.entryId != null
                ? (item.tone == _CareItemTone.warning
                      ? Icons.event_busy_outlined
                      : Icons.event_available_outlined)
                : (item.tone == _CareItemTone.critical
                      ? Icons.priority_high_rounded
                      : Icons.notifications_active_outlined),
            color: readableTextColor(toneColor, background),
          ),
          title: Text(
            item.title,
            softWrap: true,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          subtitle: Text(item.message, softWrap: true),
          trailing: const Icon(Icons.chevron_right),
          onTap: () {
            if (item.entryId != null) {
              context.pushNamed(
                AppRoutes.nameAgendaTask,
                pathParameters: {'id': item.entryId!},
              );
            } else {
              context.push(item.route);
            }
          },
        ),
      ),
    );
  }
}
