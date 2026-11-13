/// features > inicio > view > inicio_view - customizable home dashboard.
library;

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:libretapp/features/agenda/data/agenda_refresh_signal.dart';
import 'package:libretapp/features/directorio/animales/infrastructure/animal_repository.dart';
import 'package:libretapp/features/directorio/animales/widgets/animal_photo.dart';
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
import 'package:libretapp/features/inicio/widgets/quick_summary_section.dart';
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
        final showPending = widgets.any(
          (widget) =>
              widget.enabled && widget.type == DashboardWidgetType.pendingTasks,
        );
        final showAnimals = widgets.any(
          (widget) =>
              widget.enabled &&
              widget.type == DashboardWidgetType.animalSummary,
        );
        final animalFirst =
            showAnimals &&
            showPending &&
            widgets.indexWhere(
                  (widget) => widget.type == DashboardWidgetType.animalSummary,
                ) <
                widgets.indexWhere(
                  (widget) => widget.type == DashboardWidgetType.pendingTasks,
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
                                const WeatherHomeCard(compact: true),
                                if (firstRun) ...[
                                  _GettingStartedCard(profile: careProfile),
                                  if (showPending && todayCareItems.isNotEmpty)
                                    _TodayCarePanel(items: todayCareItems),
                                ] else ...[
                                  _DashboardStats(
                                    data: data,
                                    items: todayCareItems,
                                    showAnimals: showAnimals,
                                    showPending: showPending,
                                  ),
                                  if (!isTablet && animalFirst)
                                    KeyedSubtree(
                                      key: const ValueKey(
                                        'dashboard-widget-animalSummary',
                                      ),
                                      child: _AnimalHighlightsCard(
                                        profile: careProfile,
                                        data: data,
                                      ),
                                    ),
                                  if (isTablet && showPending && showAnimals)
                                    Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        if (animalFirst)
                                          Expanded(
                                            flex: 2,
                                            child: KeyedSubtree(
                                              key: const ValueKey(
                                                'dashboard-widget-animalSummary',
                                              ),
                                              child: _AnimalHighlightsCard(
                                                profile: careProfile,
                                                data: data,
                                              ),
                                            ),
                                          )
                                        else
                                          Expanded(
                                            flex: 3,
                                            child: KeyedSubtree(
                                              key: const ValueKey(
                                                'dashboard-widget-pendingTasks',
                                              ),
                                              child: _TodayCarePanel(
                                                items: todayCareItems,
                                              ),
                                            ),
                                          ),
                                        const SizedBox(width: AppSpacing.sm),
                                        if (animalFirst)
                                          Expanded(
                                            flex: 3,
                                            child: KeyedSubtree(
                                              key: const ValueKey(
                                                'dashboard-widget-pendingTasks',
                                              ),
                                              child: _TodayCarePanel(
                                                items: todayCareItems,
                                              ),
                                            ),
                                          )
                                        else
                                          Expanded(
                                            flex: 2,
                                            child: KeyedSubtree(
                                              key: const ValueKey(
                                                'dashboard-widget-animalSummary',
                                              ),
                                              child: _AnimalHighlightsCard(
                                                profile: careProfile,
                                                data: data,
                                              ),
                                            ),
                                          ),
                                      ],
                                    )
                                  else if (showPending)
                                    KeyedSubtree(
                                      key: const ValueKey(
                                        'dashboard-widget-pendingTasks',
                                      ),
                                      child: _TodayCarePanel(
                                        items: todayCareItems,
                                      ),
                                    ),
                                ],
                                QuickActionGrid(
                                  compact: !firstRun,
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
                                if (!firstRun &&
                                    showAnimals &&
                                    !animalFirst &&
                                    !(isTablet && showPending))
                                  KeyedSubtree(
                                    key: const ValueKey(
                                      'dashboard-widget-animalSummary',
                                    ),
                                    child: _AnimalHighlightsCard(
                                      profile: careProfile,
                                      data: data,
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
              'AÃ±ade el primer perfil para tener sus datos, cuidados y prÃ³ximas actividades en Inicio.',
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
  final label = Text(pet ? 'AÃ±adir mascota' : 'AÃ±adir animal');
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

class _AnimalHighlightsCard extends StatelessWidget {
  const _AnimalHighlightsCard({required this.profile, required this.data});

  final CareProfile? profile;
  final InicioDashboardData data;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final pets =
        data.petCount > 0 ||
        profile == CareProfile.pets ||
        profile == CareProfile.mixed;
    final livestock =
        data.livestockCount > 0 ||
        profile == CareProfile.livestock ||
        profile == CareProfile.mixed;
    final hasSummary = data.categoryBreakdown.isNotEmpty;
    return Card(
      key: const ValueKey('inicio-animales'),
      color: colors.surfaceContainerLow,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => context.push(AppRoutes.directorio),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.sm),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Icon(Icons.pets_outlined, size: 18, color: colors.primary),
                  const SizedBox(width: AppSpacing.xs),
                  Expanded(
                    child: Text(
                      'Tus animales',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  Icon(
                    Icons.chevron_right,
                    size: 18,
                    color: colors.onSurfaceVariant,
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.xxs),
              Row(
                children: [
                  Text(
                    '${data.totalAnimals} animales',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (pets || livestock) ...[
                    Text(
                      '  Â·  ',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                    Text(
                      [
                        if (livestock) '${data.livestockCount} ganado',
                        if (pets) '${data.petCount} mascotas',
                      ].join(' Â· '),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ],
              ),
              if (data.attentionAnimals > 0) ...[
                const SizedBox(height: AppSpacing.xs),
                ActionChip(
                  avatar: const Icon(Icons.priority_high_rounded, size: 16),
                  label: Text('${data.attentionAnimals} por revisar'),
                  onPressed: () =>
                      context.push(AppRoutes.animalesPath(attention: true)),
                ),
              ],
              if (hasSummary) ...[
                const SizedBox(height: AppSpacing.sm),
                QuickSummarySection(data: data),
              ],
              if (data.recentActivity.isNotEmpty) ...[
                const SizedBox(height: AppSpacing.xs),
                ExpansionTile(
                  tilePadding: EdgeInsets.zero,
                  title: const Text('Actualizados recientemente'),
                  children: [
                    for (final animal in data.recentActivity.take(2))
                      _RecentAnimalTile(animal: animal),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _RecentAnimalTile extends StatelessWidget {
  const _RecentAnimalTile({required this.animal});

  final RecentActivityItem animal;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final name = animal.animalName?.trim();
    final label = name != null && name.isNotEmpty
        ? name
        : animal.animalTag.trim().isNotEmpty
        ? animal.animalTag
        : animal.categoryLabel;
    final detail =
        animal.animalTag.trim().isNotEmpty && label != animal.animalTag
        ? '${animal.categoryLabel} Â· ${animal.animalTag}'
        : animal.categoryLabel;
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.xxs),
      child: Material(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(AppRadii.sm),
        child: ListTile(
          key: ValueKey('inicio-animal-${animal.animalUuid}'),
          contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
          leading: ClipRRect(
            borderRadius: BorderRadius.circular(AppRadii.sm),
            child: SizedBox(
              width: 44,
              height: 44,
              child: AnimalPhotoImage(
                path: animal.photoPath,
                fallback: ColoredBox(
                  color: theme.colorScheme.surfaceContainerHighest,
                  child: Icon(
                    Icons.pets_outlined,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            ),
          ),
          title: Text(label, softWrap: true),
          subtitle: Text(detail, softWrap: true),
          trailing: const Icon(Icons.chevron_right),
          onTap: () =>
              context.push(AppRoutes.animalDetallePath(animal.animalUuid)),
        ),
      ),
    );
  }
}

class _DashboardStats extends StatefulWidget {
  const _DashboardStats({
    required this.data,
    required this.items,
    required this.showAnimals,
    required this.showPending,
  });

  final InicioDashboardData data;
  final List<_HomeCareItem> items;
  final bool showAnimals;
  final bool showPending;

  @override
  State<_DashboardStats> createState() => _DashboardStatsState();
}

class _DashboardStatsState extends State<_DashboardStats> {
  bool _animalsExpanded = false;

  @override
  Widget build(BuildContext context) {
    if (!widget.showPending && !widget.showAnimals) {
      return const SizedBox.shrink();
    }
    final theme = Theme.of(context);
    final data = widget.data;
    final items = widget.items;
    final showAnimals = widget.showAnimals;
    final showPending = widget.showPending;
    final stats =
        <
          ({
            String label,
            int count,
            IconData icon,
            VoidCallback onTap,
            bool attention,
            bool isAnimals,
          })
        >[
          if (showAnimals)
            (
              label: 'Animales',
              count: data.totalAnimals,
              icon: Icons.pets_outlined,
              onTap: () {
                if (data.categoryBreakdown.isEmpty) {
                  context.push(AppRoutes.directorio);
                  return;
                }
                setState(() => _animalsExpanded = !_animalsExpanded);
              },
              attention: false,
              isAnimals: true,
            ),
          if (showAnimals && data.attentionAnimals > 0)
            (
              label: 'Por revisar',
              count: data.attentionAnimals,
              icon: Icons.priority_high_rounded,
              onTap: () =>
                  context.push(AppRoutes.animalesPath(attention: true)),
              attention: true,
              isAnimals: false,
            ),
          if (showPending)
            (
              label: 'Asuntos',
              count: items.length,
              icon: Icons.task_alt_outlined,
              onTap: () => _TodayCarePanel.showAll(context, items),
              attention: false,
              isAnimals: false,
            ),
        ];
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
      child: Column(
        children: [
          Row(
            key: const ValueKey('inicio-resumen'),
            children: [
              for (var index = 0; index < stats.length; index++) ...[
                if (index > 0) const SizedBox(width: AppSpacing.xs),
                Expanded(
                  child: Material(
                    color: stats[index].isAnimals && _animalsExpanded
                        ? theme.colorScheme.primaryContainer
                        : stats[index].attention
                        ? theme.colorScheme.errorContainer
                        : theme.colorScheme.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(AppRadii.sm),
                    child: InkWell(
                      onTap: stats[index].onTap,
                      borderRadius: BorderRadius.circular(AppRadii.sm),
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(minHeight: 72),
                        child: Padding(
                          padding: const EdgeInsets.all(AppSpacing.xs),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Icon(
                                    stats[index].icon,
                                    size: 16,
                                    color: stats[index].attention
                                        ? theme.colorScheme.onErrorContainer
                                        : theme.colorScheme.primary,
                                  ),
                                  if (stats[index].isAnimals &&
                                      data.categoryBreakdown.isNotEmpty)
                                    Icon(
                                      _animalsExpanded
                                          ? Icons.expand_less_rounded
                                          : Icons.expand_more_rounded,
                                      size: 18,
                                      color: theme.colorScheme.onSurfaceVariant,
                                    ),
                                ],
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '${stats[index].count}',
                                style: theme.textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              Text(
                                stats[index].label,
                                maxLines: 2,
                                style: theme.textTheme.labelSmall,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
          AnimatedSize(
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeInOut,
            alignment: Alignment.topCenter,
            child: _animalsExpanded && data.categoryBreakdown.isNotEmpty
                ? Padding(
                    padding: const EdgeInsets.only(top: AppSpacing.sm),
                    child: AnimalCategoryRow(data: data),
                  )
                : const SizedBox.shrink(),
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
      if (!widget.enabled) return false;
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
    final displayTitle = overdue
        ? entry.titulo.replaceFirst(
            RegExp(r'^Parto prÃ³ximo\s*\([^)]*\)'),
            'Aviso de parto',
          )
        : entry.titulo;
    items.add(
      _HomeCareItem(
        title: displayTitle,
        message: overdue
            ? 'Vencida desde ${entry.fecha.day}/${entry.fecha.month}'
            : 'Programada para hoy',
        route: AppRoutes.agenda,
        entryId: entry.id,
        date: day,
        tone: overdue ? _CareItemTone.warning : _CareItemTone.normal,
        priority: overdue ? 2 : 1,
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

  static void showAll(BuildContext context, List<_HomeCareItem> items) {
    final today = DateUtils.dateOnly(DateTime.now());
    final attention = items
        .where((item) => item.tone == _CareItemTone.critical)
        .toList();
    final dueToday = items
        .where(
          (item) => item.date != null && DateUtils.isSameDay(item.date, today),
        )
        .toList();
    final overdue = items
        .where((item) => item.date != null && item.date!.isBefore(today))
        .toList();
    final other = items
        .where(
          (item) =>
              !attention.contains(item) &&
              !dueToday.contains(item) &&
              !overdue.contains(item),
        )
        .toList();
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (sheetContext) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: .8,
        maxChildSize: .95,
        builder: (listContext, controller) => ListView(
          controller: controller,
          padding: const EdgeInsets.all(AppSpacing.md),
          children: [
            Text(
              'Todos los pendientes',
              style: Theme.of(listContext).textTheme.titleLarge,
            ),
            const SizedBox(height: AppSpacing.sm),
            for (final group in [
              ('AtenciÃ³n', attention),
              ('Hoy', dueToday),
              ('Vencidos', overdue),
              ('Otros asuntos', other),
            ])
              if (group.$2.isNotEmpty) ...[
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
                  child: Text(
                    '${group.$1} Â· ${group.$2.length}',
                    style: Theme.of(listContext).textTheme.titleSmall,
                  ),
                ),
                for (final item in group.$2)
                  _TodayCareTile(
                    item: item,
                    onTap: () {
                      Navigator.of(sheetContext).pop();
                      _openCareItem(context, item);
                    },
                  ),
              ],
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final today = DateUtils.dateOnly(DateTime.now());
    final attention = items
        .where((item) => item.tone == _CareItemTone.critical)
        .toList();
    final dueToday = items
        .where(
          (item) => item.date != null && DateUtils.isSameDay(item.date, today),
        )
        .toList();
    final overdueCount = items
        .where((item) => item.date != null && item.date!.isBefore(today))
        .length;
    return Card(
      key: const ValueKey('inicio-pendientes-hoy'),
      color: colors.surfaceContainerLow,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.sm),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Icon(
                  Icons.checklist_rounded,
                  size: 18,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: AppSpacing.xs),
                Expanded(
                  child: Text(
                    'Pendientes',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                if (items.isNotEmpty)
                  TextButton.icon(
                    onPressed: () => showAll(context, items),
                    icon: const Icon(Icons.list_alt_outlined, size: 16),
                    label: Text('Ver ${items.length}'),
                  ),
              ],
            ),
            const SizedBox(height: AppSpacing.xxs),
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
                            'Todo al dÃ­a',
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
            else ...[
              if (attention.isNotEmpty) ...[
                Text(
                  'Atender primero',
                  style: theme.textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                for (final item in attention.take(1))
                  _TodayCareTile(item: item),
              ],
              Padding(
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.xxs),
                child: Text(
                  'Hoy Â· ${dueToday.length}',
                  style: theme.textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              if (dueToday.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: AppSpacing.xxs),
                  child: Text(
                    'Sin actividades programadas',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colors.onSurfaceVariant,
                    ),
                  ),
                ),
              for (final item in dueToday.take(2)) _TodayCareTile(item: item),
              if (attention.isEmpty && dueToday.isEmpty && overdueCount == 0)
                _TodayCareTile(item: items.first),
              if (overdueCount > 0)
                TextButton(
                  onPressed: () => showAll(context, items),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text('$overdueCount vencidas Â· ver pendientes'),
                  ),
                ),
            ],
            if (items.isEmpty)
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
                  const Icon(Icons.chevron_right, size: 20),
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
  if (item.entryId != null) {
    context.pushNamed(
      AppRoutes.nameAgendaTask,
      pathParameters: {'id': item.entryId!},
    );
  } else {
    context.push(item.route);
  }
}
