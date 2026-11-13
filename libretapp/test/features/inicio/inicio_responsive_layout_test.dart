import 'dart:convert';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:libretapp/core/utils/color_contrast.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:libretapp/features/agenda/data/agenda_model.dart';
import 'package:libretapp/features/directorio/animales/widgets/animal_photo.dart';
import 'package:libretapp/features/biblioteca/data/book_content.dart';
import 'package:libretapp/features/biblioteca/data/library_manifest.dart';
import 'package:libretapp/features/biblioteca/data/library_repository.dart';
import 'package:libretapp/features/finanzas/domain/entities/financial_period_summary.dart';
import 'package:libretapp/features/finanzas/domain/enums/financial_period_preset.dart';
import 'package:libretapp/features/finanzas/domain/finance_summary_service.dart';
import 'package:libretapp/features/inicio/bloc/inicio_bloc.dart';
import 'package:libretapp/features/inicio/bloc/inicio_event.dart';
import 'package:libretapp/features/inicio/data/dashboard_config_repository.dart';
import 'package:libretapp/features/inicio/data/dashboard_quick_action.dart';
import 'package:libretapp/features/inicio/data/dashboard_widget_config.dart';
import 'package:libretapp/features/inicio/data/inicio_dashboard_models.dart';
import 'package:libretapp/features/inicio/data/inicio_dashboard_service.dart';
import 'package:libretapp/features/inicio/view/inicio_view.dart';
import 'package:libretapp/features/inicio/widgets/dashboard/quick_action_grid.dart';
import 'package:libretapp/features/inicio/widgets/weather_home_card.dart';
import 'package:libretapp/core/services/shared_prefs_service.dart';
import 'package:libretapp/core/di/injection.dart';
import 'package:libretapp/core/experience/app_experience.dart';
import 'package:libretapp/core/experience/care_profile.dart';
import 'package:libretapp/core/experience/registration_preferences.dart';
import 'package:libretapp/core/security/ports/phone_auth_port.dart';
import 'package:libretapp/features/inicio/data/weather_preferences_service.dart';
import 'package:libretapp/features/inicio/data/weather_service.dart';
import 'package:libretapp/core/workspace/workspace_manager.dart';
import 'package:libretapp/core/workspace/workspace_registry.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:libretapp/theme/app_theme.dart';
import 'package:libretapp/l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    await initializeDateFormatting('es');
    if (Platform.environment['LIBRET_CAPTURE_DIR'] != null) {
      final fontDirectory =
          Platform.environment['FLUTTER_FONT_DIR'] ??
          '${File(Platform.resolvedExecutable).parent.parent.parent.path}/material_fonts';
      final fonts = [
        ('Roboto', File('assets/fonts/Roboto-Regular.ttf')),
        ('MaterialIcons', File('$fontDirectory/materialicons-regular.otf')),
      ];
      for (final (family, file) in fonts) {
        final loader = FontLoader(family)
          ..addFont(
            Future.value(ByteData.sublistView(await file.readAsBytes())),
          );
        await loader.load();
      }
    }
  });

  group('Inicio responsive layout', () {
    testWidgets('clima precede la guía inicial y ofrece ambos registros', (
      tester,
    ) async {
      await _pumpInicio(tester, width: 360, firstRun: true, topInset: 24);
      final gettingStarted = find.byKey(
        const ValueKey('complete-getting-started'),
      );
      expect(gettingStarted, findsOneWidget);
      expect(find.text('Añadir mascota'), findsOneWidget);
      expect(find.text('Añadir animal'), findsOneWidget);
      expect(
        tester
            .widget<FilledButton>(
              find
                  .ancestor(
                    of: find.text('Añadir animal'),
                    matching: find.byType(FilledButton),
                  )
                  .first,
            )
            .onPressed,
        isNotNull,
      );
      expect(
        tester
            .widget<OutlinedButton>(
              find
                  .ancestor(
                    of: find.text('Añadir mascota'),
                    matching: find.byType(OutlinedButton),
                  )
                  .first,
            )
            .onPressed,
        isNotNull,
      );
      expect(
        tester.getTopLeft(find.byType(WeatherHomeCard)).dy,
        lessThan(tester.getTopLeft(gettingStarted).dy),
      );
      expect(find.text('Resumen del rancho'), findsNothing);
      expect(find.text('Pendientes'), findsNothing);
      await _captureInicio(tester, 'inicio-primer-uso');
      expect(tester.getRect(find.byType(ListView)).top, 24);
      await tester.drag(find.byType(ListView), const Offset(0, -300));
      await tester.pumpAndSettle();
      expect(tester.getRect(find.byType(ListView)).top, 24);
    });

    testWidgets('keeps the first animal guide when locations already exist', (
      tester,
    ) async {
      await _pumpInicio(
        tester,
        width: 390,
        firstRun: true,
        preconfiguredEmpty: true,
      );

      expect(
        find.byKey(const ValueKey('complete-getting-started')),
        findsOneWidget,
      );
      expect(find.text('Tus animales'), findsNothing);
    });

    testWidgets('empty guide fits a 320dp screen with large dark text', (
      tester,
    ) async {
      await _pumpInicio(
        tester,
        width: 320,
        textScale: 2,
        dark: true,
        firstRun: true,
        careProfile: CareProfile.mixed,
      );

      expect(find.text('Añadir mascota'), findsOneWidget);
      expect(find.text('Añadir animal'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    for (final profile in CareProfile.values) {
      testWidgets('empty guide follows the ${profile.name} profile', (
        tester,
      ) async {
        await _pumpInicio(
          tester,
          width: 390,
          firstRun: true,
          careProfile: profile,
        );

        expect(
          find.text('Añadir mascota'),
          profile == CareProfile.pets || profile == CareProfile.mixed
              ? findsOneWidget
              : findsNothing,
        );
        expect(
          find.text('Añadir animal'),
          profile != CareProfile.pets ? findsOneWidget : findsNothing,
        );
      });
    }

    testWidgets('shows actionable care and hides duplicate empty tasks', (
      tester,
    ) async {
      await _pumpInicio(tester, width: 390, noActionable: true);

      expect(find.text('Pendientes'), findsOneWidget);
      expect(find.text('Todo al día'), findsOneWidget);
      expect(find.text('Sin pendientes críticos'), findsNothing);
      expect(find.text('Prioridad de hoy'), findsNothing);
    });

    testWidgets('shows today and overdue activities once', (tester) async {
      final now = DateUtils.dateOnly(DateTime.now());
      await _pumpInicio(
        tester,
        width: 390,
        dueEntries: [
          _agendaEntry(
            id: 'overdue',
            title: 'Actividad vencida',
            date: now.subtract(const Duration(days: 1)),
          ),
          _agendaEntry(id: 'today', title: 'Actividad de hoy', date: now),
        ],
        duplicateOverdueAlert: true,
      );

      expect(find.text('Actividad vencida'), findsNothing);
      expect(find.text('Actividad de hoy'), findsOneWidget);
      expect(find.text('Eventos vencidos'), findsNothing);
      await tester.tap(find.text('Ver 2'));
      await tester.pumpAndSettle();
      expect(find.text('Vencidos · 1'), findsOneWidget);
      expect(find.text('Actividad vencida'), findsOneWidget);
      final overdueTile = tester.widget<InkWell>(
        find
            .ancestor(
              of: find.text('Actividad vencida'),
              matching: find.byType(InkWell),
            )
            .first,
      );
      expect(overdueTile.onTap, isNotNull);
      expect(
        tester
            .getSize(
              find
                  .ancestor(
                    of: find.text('Actividad vencida'),
                    matching: find.byType(InkWell),
                  )
                  .first,
            )
            .height,
        greaterThanOrEqualTo(56),
      );
    });

    testWidgets('keeps today visible with many overdue activities', (
      tester,
    ) async {
      final today = DateUtils.dateOnly(DateTime.now());
      await _pumpInicio(
        tester,
        width: 360,
        height: 800,
        dueEntries: [
          for (var i = 0; i < 130; i++)
            _agendaEntry(
              id: 'overdue-$i',
              title: 'Vencida $i',
              date: today.subtract(const Duration(days: 1)),
            ),
          _agendaEntry(id: 'today', title: 'Actividad de hoy', date: today),
        ],
      );

      expect(find.text('Ver 132'), findsOneWidget);
      expect(find.text('Actividad de hoy'), findsOneWidget);
      expect(tester.getRect(find.text('Actividad de hoy')).top, lessThan(800));
      expect(tester.takeException(), isNull);
    });

    testWidgets('customization scrolls without overflow at 320dp and 200%', (
      tester,
    ) async {
      await _pumpInicio(tester, width: 320, height: 800, textScale: 2);
      final quickActions = find.byKey(const ValueKey('quick-action-grid'));
      final customize = find.descendant(
        of: quickActions,
        matching: find.byIcon(Icons.tune),
      );
      await tester.ensureVisible(customize);
      await tester.pumpAndSettle();
      await tester.tap(customize);
      await tester.pumpAndSettle();

      expect(find.text('Personalizar inicio'), findsOneWidget);
      expect(find.text('Guardar'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('keeps actions ahead of animal details on a phone', (
      tester,
    ) async {
      final today = DateUtils.dateOnly(DateTime.now());
      await _pumpInicio(
        tester,
        width: 390,
        height: 800,
        dueEntries: [
          _agendaEntry(id: 'due-1', title: 'Revisión de Prieta', date: today),
          _agendaEntry(id: 'due-2', title: 'Revisión de Wera', date: today),
        ],
      );

      expect(find.text('Revisión de Prieta'), findsOneWidget);
      expect(find.text('Revisión de Wera'), findsOneWidget);
      expect(
        tester.getRect(find.byKey(const ValueKey('quick-action-grid'))).top,
        lessThan(tester.getRect(find.text('Tus animales')).top),
      );
      expect(
        tester.getRect(find.byType(WeatherHomeCard)).top,
        lessThan(
          tester.getRect(find.byKey(const ValueKey('inicio-resumen'))).top,
        ),
      );
      expect(tester.takeException(), isNull);
      await _captureInicio(tester, 'inicio-pendientes-compacto');
    });

    testWidgets('three pending items remain legible at 320dp and 200 percent', (
      tester,
    ) async {
      final today = DateUtils.dateOnly(DateTime.now());
      await _pumpInicio(
        tester,
        width: 320,
        height: 800,
        textScale: 2,
        dark: true,
        dueEntries: [
          _agendaEntry(id: 'due-1', title: 'Revisión de Prieta', date: today),
          _agendaEntry(id: 'due-2', title: 'Revisión de Wera', date: today),
        ],
      );

      expect(find.text('Revisión de Prieta'), findsOneWidget);
      expect(find.text('Revisión de Wera'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('shows existing agenda care before the first animal', (
      tester,
    ) async {
      await _pumpInicio(
        tester,
        width: 390,
        firstRun: true,
        dueEntries: [
          _agendaEntry(
            id: 'first-care',
            title: 'Preparar visita',
            date: DateUtils.dateOnly(DateTime.now()),
          ),
        ],
      );

      expect(
        find.byKey(const ValueKey('complete-getting-started')),
        findsOneWidget,
      );
      expect(find.text('Preparar visita'), findsOneWidget);
      expect(
        find.byKey(const ValueKey('inicio-pendientes-hoy')),
        findsOneWidget,
      );
      expect(find.byKey(const ValueKey('inicio-animales')), findsNothing);
    });

    testWidgets('shows a recent animal once with a photo fallback', (
      tester,
    ) async {
      await _pumpInicio(
        tester,
        width: 390,
        recentActivity: [
          RecentActivityItem(
            animalUuid: 'mika',
            animalTag: 'M-1',
            animalName: 'Mika',
            categoryLabel: 'Canino',
            categoryAbbrev: 'C',
            lastUpdate: DateTime(2026, 11, 1),
          ),
        ],
      );

      await tester.tap(find.text('Actualizados recientemente'));
      await tester.pumpAndSettle();
      final tile = find.byKey(const ValueKey('inicio-animal-mika'));
      expect(tile, findsOneWidget);
      expect(find.text('Mika'), findsOneWidget);
      expect(find.byType(AnimalPhotoImage), findsOneWidget);
      expect(tester.widget<ListTile>(tile).onTap, isNotNull);
      expect(find.byKey(_widgetKey('recentActivity')), findsNothing);
      await _captureInicio(tester, 'inicio-con-animales');
    });

    testWidgets('respects the saved order of the two main cards', (
      tester,
    ) async {
      await _pumpInicio(
        tester,
        width: 390,
        savedWidgets: const [
          DashboardWidgetConfig(
            id: 'animalSummary',
            title: 'Resumen de animales',
            type: DashboardWidgetType.animalSummary,
            enabled: true,
            order: 0,
          ),
          DashboardWidgetConfig(
            id: 'pendingTasks',
            title: 'Tareas pendientes',
            type: DashboardWidgetType.pendingTasks,
            enabled: true,
            order: 1,
          ),
        ],
      );

      expect(
        _widgetRect(tester, 'animalSummary').top,
        lessThan(_widgetRect(tester, 'pendingTasks').top),
      );
    });

    testWidgets(
      'dark priority text remains readable at 320dp and 200 percent text',
      (tester) async {
        await _pumpInicio(tester, width: 320, textScale: 2, dark: true);
        final label = find.text('Pendientes');
        final foreground =
            tester.widget<Text>(label).style?.color ??
            AppTheme.darkTheme.colorScheme.onSurface;
        final card = tester.widget<Card>(
          find.byKey(const ValueKey('inicio-pendientes-hoy')),
        );
        final background = card.color ?? AppTheme.darkTheme.colorScheme.surface;
        expect(textContrast(foreground, background), greaterThanOrEqualTo(4.5));
        expect(
          tester
              .renderObject<RenderParagraph>(
                find.text('Revisar animales').first,
              )
              .didExceedMaxLines,
          isFalse,
        );
      },
    );
    testWidgets('keeps a single column below the tablet breakpoint', (
      tester,
    ) async {
      await _pumpInicio(tester, width: 599, includeWidgetData: true);

      final pending = _widgetRect(tester, 'pendingTasks');
      final animals = _widgetRect(tester, 'animalSummary');
      final calvings = _widgetRect(tester, 'upcomingCalvings');
      final events = _widgetRect(tester, 'upcomingEvents');

      expect(pending.left, closeTo(16, 0.5));
      expect(animals.left, closeTo(16, 0.5));
      expect(animals.top, greaterThanOrEqualTo(pending.bottom));
      expect(calvings.left, closeTo(16, 0.5));
      expect(events.left, closeTo(16, 0.5));
      expect(events.top, greaterThanOrEqualTo(calvings.bottom));
      expect(find.byKey(_widgetKey('healthAlerts')), findsNothing);
      expect(find.text('Ver todas'), findsNothing);
    });

    testWidgets('uses two columns from the tablet breakpoint', (tester) async {
      await _pumpInicio(tester, width: 600, includeWidgetData: true);

      final pending = _widgetRect(tester, 'pendingTasks');
      final animals = _widgetRect(tester, 'animalSummary');
      final calvings = _widgetRect(tester, 'upcomingCalvings');
      final events = _widgetRect(tester, 'upcomingEvents');

      expect(pending.left, closeTo(20, 0.5));
      expect(pending.width, closeTo(328.8, 0.5));
      expect(animals.left, closeTo(360.8, 0.5));
      expect(animals.width, closeTo(219.2, 0.5));
      expect(calvings.left, closeTo(20, 0.5));
      expect(events.left, closeTo(306, 0.5));
      expect(calvings.width, closeTo(274, 0.5));
      expect(events.width, closeTo(274, 0.5));
      expect(events.top, closeTo(calvings.top, 0.5));
      expect(find.byKey(_widgetKey('healthAlerts')), findsNothing);
      expect(find.text('Ver todas'), findsWidgets);
    });

    testWidgets('keeps full-width cards and centers wide content', (
      tester,
    ) async {
      await _pumpInicio(tester, width: 1400, includeWidgetData: true);

      final pending = _widgetRect(tester, 'pendingTasks');
      final animals = _widgetRect(tester, 'animalSummary');
      final calvings = _widgetRect(tester, 'upcomingCalvings');
      final events = _widgetRect(tester, 'upcomingEvents');

      expect(pending.left, closeTo(120, 0.5));
      expect(pending.width, closeTo(688.8, 0.5));
      expect(animals.left, closeTo(820.8, 0.5));
      expect(animals.width, closeTo(459.2, 0.5));
      expect(calvings.width, closeTo(574, 0.5));
      expect(events.left, closeTo(706, 0.5));
    });

    testWidgets('does not overflow with accessible text scaling', (
      tester,
    ) async {
      await _pumpInicio(
        tester,
        width: 800,
        textScale: 1.4,
        includeWidgetData: true,
      );

      expect(tester.takeException(), isNull);
      expect(find.byKey(_widgetKey('healthAlerts')), findsNothing);
      expect(find.byKey(_widgetKey('pendingTasks')), findsOneWidget);
      expect(find.byKey(_widgetKey('animalSummary')), findsOneWidget);
    });

    testWidgets('keeps eight quick actions readable', (tester) async {
      await _pumpQuickActions(tester, width: 390, count: 8);

      final size = tester.getSize(
        find.byKey(const ValueKey<String>('quick-action-grid')),
      );

      expect(size.height, lessThan(500));
    });

    testWidgets('shrinks the quick action card for four and one action', (
      tester,
    ) async {
      await _pumpQuickActions(tester, width: 390, count: 4);
      final fourActionsHeight = tester
          .getSize(find.byKey(const ValueKey<String>('quick-action-grid')))
          .height;

      await _pumpQuickActions(tester, width: 390, count: 1);
      final oneActionHeight = tester
          .getSize(find.byKey(const ValueKey<String>('quick-action-grid')))
          .height;

      expect(fourActionsHeight, lessThan(300));
      expect(oneActionHeight, lessThan(200));
    });

    testWidgets('quick actions respect accessible text scaling', (
      tester,
    ) async {
      await _pumpQuickActions(tester, width: 800, count: 8, textScale: 1.4);

      expect(tester.takeException(), isNull);
      expect(
        tester
            .getSize(find.byKey(const ValueKey<String>('quick-action-grid')))
            .height,
        lessThan(400),
      );
    });

    for (final (width, scale, columns) in [
      (320.0, 1.0, 2),
      (390.0, 1.0, 3),
      (320.0, 2.0, 2),
    ]) {
      testWidgets(
        'quick actions use $columns columns at ${width}dp and ${scale}x text',
        (tester) async {
          await _pumpQuickActions(
            tester,
            width: width,
            count: 8,
            textScale: scale,
          );
          final lefts = defaultQuickActions()
              .take(8)
              .map(
                (action) => tester
                    .getRect(
                      find.byKey(ValueKey<String>('quick-action-${action.id}')),
                    )
                    .left,
              )
              .toSet();
          expect(lefts, hasLength(columns));
          for (final action in defaultQuickActions().take(8)) {
            final size = tester.getSize(
              find.byKey(ValueKey<String>('quick-action-${action.id}')),
            );
            expect(size.width, greaterThanOrEqualTo(48));
            expect(size.height, greaterThanOrEqualTo(48));
          }
          expect(tester.takeException(), isNull);
        },
      );
    }

    testWidgets('quick actions keep icon and label contrast in dark mode', (
      tester,
    ) async {
      await _pumpQuickActions(tester, width: 390, count: 4, dark: true);
      final action = defaultQuickActions().first;
      final finder = find.byKey(ValueKey<String>('quick-action-${action.id}'));
      final ink = tester.widget<Ink>(
        find.descendant(of: finder, matching: find.byType(Ink)),
      );
      final background = (ink.decoration! as BoxDecoration).color!;
      final icon = tester.widget<Icon>(
        find.descendant(of: finder, matching: find.byType(Icon)),
      );
      expect(textContrast(icon.color!, background), greaterThanOrEqualTo(4.5));
    });

    testWidgets('Inicio keeps quick actions compact in the real dashboard', (
      tester,
    ) async {
      await _pumpInicio(tester, width: 390);

      final size = tester.getSize(
        find.byKey(const ValueKey<String>('quick-action-grid')),
      );

      expect(size.height, lessThan(500));
    });

    testWidgets('compact actions keep the full configured list in Más', (
      tester,
    ) async {
      await _pumpQuickActions(
        tester,
        width: 320,
        count: 8,
        textScale: 2,
        compact: true,
      );

      expect(find.text('Buscar'), findsOneWidget);
      expect(find.text('Más'), findsOneWidget);
      expect(tester.takeException(), isNull);
      await tester.tap(find.text('Más'));
      await tester.pumpAndSettle();
      expect(find.text('Accesos rápidos'), findsOneWidget);
      expect(
        find.text(defaultQuickActions().elementAt(2).label),
        findsOneWidget,
      );
    });
  });
}

Future<void> _pumpInicio(
  WidgetTester tester, {
  required double width,
  double height = 1200,
  double textScale = 1,
  bool dark = false,
  bool firstRun = false,
  bool preconfiguredEmpty = false,
  bool noActionable = false,
  bool duplicateOverdueAlert = false,
  List<AgendaEntry> dueEntries = const [],
  bool includeWidgetData = false,
  List<RecentActivityItem> recentActivity = const [],
  List<DashboardWidgetConfig>? savedWidgets,
  CareProfile? careProfile,
  double topInset = 0,
}) async {
  tester.view.physicalSize = Size(width, height);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  SharedPreferences.setMockInitialValues({
    if (savedWidgets != null)
      'dashboard_config_widgets_v1': jsonEncode(
        savedWidgets.map((item) => item.toJson()).toList(),
      ),
    if (careProfile != null)
      RegistrationPreferences.storageKey: RegistrationPreferences(
        preferredSpecies: RegistrationPreferences.allSpecies,
        includePlants: true,
        careProfile: careProfile,
      ).encode(),
  });
  final prefs = SharedPrefsService(await SharedPreferences.getInstance());
  if (locator.isRegistered<WeatherPreferencesService>()) {
    await locator.unregister<WeatherPreferencesService>();
  }
  if (locator.isRegistered<WorkspaceManager>()) {
    await locator.unregister<WorkspaceManager>();
  }
  locator.registerSingleton<WeatherPreferencesService>(
    WeatherPreferencesService(
      preferences: prefs,
      weatherService: LocalOnlyWeatherService(),
    ),
  );
  final experience = AppExperienceController(prefs);
  addTearDown(experience.dispose);
  final registry = WorkspaceRegistry(prefs);
  await registry.load();
  locator.registerSingleton<WorkspaceManager>(
    WorkspaceManager(registry: registry, auth: const UnavailablePhoneAuth()),
  );
  final bloc = InicioBloc(
    dashboardService: _FakeInicioDashboardService(
      firstRun: firstRun,
      preconfiguredEmpty: preconfiguredEmpty,
      noActionable: noActionable,
      duplicateOverdueAlert: duplicateOverdueAlert,
      dueEntries: dueEntries,
      includeWidgetData: includeWidgetData,
      recentActivity: recentActivity,
    ),
    configRepository: DashboardConfigRepository(prefs),
    financeService: _FakeFinanceSummaryService(),
    libraryRepository: _FakeLibraryRepository(),
  )..add(const LoadInicio());

  await tester.pumpWidget(
    AppExperienceScope(
      controller: experience,
      child: MaterialApp(
        theme: dark ? AppTheme.darkTheme : AppTheme.lightTheme,
        locale: const Locale('es'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: MediaQuery(
          data: MediaQueryData(
            size: Size(width, height),
            textScaler: TextScaler.linear(textScale),
            padding: EdgeInsets.only(top: topInset),
            viewPadding: EdgeInsets.only(top: topInset),
          ),
          child: BlocProvider<InicioBloc>.value(
            value: bloc,
            child: const RepaintBoundary(
              key: ValueKey('inicio-preview-boundary'),
              child: Scaffold(body: InicioView()),
            ),
          ),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

Future<void> _pumpQuickActions(
  WidgetTester tester, {
  required double width,
  required int count,
  double textScale = 1,
  bool dark = false,
  bool compact = false,
}) async {
  tester.view.physicalSize = Size(width, 1200);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  await tester.pumpWidget(
    MaterialApp(
      theme: dark ? AppTheme.darkTheme : AppTheme.lightTheme,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: MediaQuery(
        data: MediaQueryData(
          size: Size(width, 1200),
          textScaler: TextScaler.linear(textScale),
        ),
        child: Scaffold(
          body: Padding(
            padding: const EdgeInsets.all(16),
            child: Align(
              alignment: Alignment.topCenter,
              child: QuickActionGrid(
                actions: defaultQuickActions().take(count).toList(),
                compact: compact,
              ),
            ),
          ),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

Rect _widgetRect(WidgetTester tester, String id) {
  return tester.getRect(find.byKey(_widgetKey(id)));
}

Key _widgetKey(String id) => ValueKey<String>('dashboard-widget-$id');

Future<void> _captureInicio(WidgetTester tester, String name) async {
  final captureDir = Platform.environment['LIBRET_CAPTURE_DIR'];
  if (captureDir == null) return;
  if (name == 'inicio-primer-uso') {
    await tester.runAsync(() async {
      final context = tester.element(
        find.byKey(const ValueKey('complete-getting-started')),
      );
      await Future.wait([
        precacheImage(const AssetImage('assets/images/vaca.webp'), context),
        precacheImage(const AssetImage('assets/images/canino.webp'), context),
        precacheImage(const AssetImage('assets/images/felino.png'), context),
      ]);
    });
    await tester.pumpAndSettle();
  }
  final boundary = tester.renderObject<RenderRepaintBoundary>(
    find.byKey(const ValueKey('inicio-preview-boundary')),
  );
  await tester.runAsync(() async {
    final image = await boundary.toImage(pixelRatio: 1.5);
    final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
    final directory = Directory(captureDir);
    await directory.create(recursive: true);
    await File(
      '${directory.path}/$name.png',
    ).writeAsBytes(bytes!.buffer.asUint8List());
    image.dispose();
  });
}

class _FakeInicioDashboardService implements InicioDashboardService {
  _FakeInicioDashboardService({
    this.firstRun = false,
    this.preconfiguredEmpty = false,
    this.noActionable = false,
    this.duplicateOverdueAlert = false,
    this.dueEntries = const [],
    this.includeWidgetData = false,
    this.recentActivity = const [],
  });

  final bool firstRun;
  final bool preconfiguredEmpty;
  final bool noActionable;
  final bool duplicateOverdueAlert;
  final List<AgendaEntry> dueEntries;
  final bool includeWidgetData;
  final List<RecentActivityItem> recentActivity;

  @override
  Future<InicioDashboardData> loadDashboard() async {
    return InicioDashboardData(
      profileName: 'Usuario de prueba',
      farmName: 'Rancho de prueba',
      totalAnimals: firstRun ? 0 : 12,
      petCount: firstRun ? 0 : 1,
      livestockCount: firstRun ? 0 : 11,
      totalAnimalCapacity: firstRun ? 0 : 30,
      attentionAnimals: 0,
      activeLotes: firstRun && !preconfiguredEmpty ? 0 : 3,
      totalLocations: firstRun && !preconfiguredEmpty ? 0 : 2,
      upcomingEventsCount: includeWidgetData ? 1 : 0,
      upcomingEvents: includeWidgetData
          ? [
              _agendaEntry(
                id: 'upcoming',
                title: 'Actividad próxima',
                date: DateUtils.dateOnly(
                  DateTime.now(),
                ).add(const Duration(days: 2)),
              ),
            ]
          : const <AgendaEntry>[],
      dueEntries: dueEntries,
      alerts: firstRun || noActionable
          ? const []
          : duplicateOverdueAlert
          ? const <InicioAlertItem>[
              InicioAlertItem(
                title: 'Eventos vencidos',
                message: '1 actividad quedó fuera de fecha.',
                severity: InicioAlertSeverity.warning,
                targetRoute: '/agenda',
              ),
            ]
          : const <InicioAlertItem>[
              InicioAlertItem(
                title: 'Revisar animales',
                message: 'Hay animales que requieren atención.',
                severity: InicioAlertSeverity.warning,
                targetRoute: '/directorio',
              ),
            ],
      tasks: noActionable
          ? const <InicioTaskItem>[
              InicioTaskItem(
                title: 'Sin pendientes críticos',
                message: 'No hay pendientes.',
                targetRoute: '/agenda',
              ),
            ]
          : includeWidgetData
          ? const <InicioTaskItem>[
              InicioTaskItem(
                title: 'Revisar lote',
                message: 'Comprobar el seguimiento del lote.',
                targetRoute: '/agenda',
              ),
            ]
          : const <InicioTaskItem>[],
      lastUpdated: DateTime(2026, 1, 1),
      categoryBreakdown: const [],
      upcomingCalvings: includeWidgetData
          ? [
              CalvingItem(
                animalUuid: 'animal-1',
                animalTag: 'V-1',
                animalName: 'Vaca de prueba',
                expectedDate: DateTime.now().add(const Duration(days: 7)),
                daysRemaining: 7,
              ),
            ]
          : const [],
      recentActivity: recentActivity,
    );
  }
}

AgendaEntry _agendaEntry({
  required String id,
  required String title,
  required DateTime date,
}) => AgendaEntry(
  id: id,
  titulo: title,
  descripcion: '',
  fecha: date,
  tipo: 'general',
  animalIds: const [],
  loteIds: const [],
  ubicacion: '',
  estado: AgendaEstado.pendiente,
  completedAnimalIds: const [],
  notas: '',
);

class _FakeFinanceSummaryService implements FinanceSummaryService {
  @override
  Future<FinanceSummaryDetail> loadForPreset({
    FinancialPeriodPreset preset = FinancialPeriodPreset.thisMonth,
    DateTime? now,
  }) async {
    return loadForPeriod(preset.toDateRange(now: now));
  }

  @override
  Future<FinanceSummaryDetail> loadForPeriod(DateRange period) async {
    return FinanceSummaryDetail(
      summary: FinancialPeriodSummary(
        period: period,
        totalIncome: 0,
        totalGeneralExpenses: 0,
        totalAnimalCosts: 0,
        totalAnimalSales: 0,
      ),
      recentMovements: const [],
      expenseBreakdown: const [],
      recentSales: const [],
    );
  }
}

class _FakeLibraryRepository implements LibraryRepository {
  @override
  Future<List<LibraryManifestBook>> getAll() async => const [];

  @override
  Future<List<LibraryManifestBook>> search(String query) async => const [];

  @override
  Future<BookContent> loadBookContent(LibraryManifestBook book) {
    throw UnimplementedError('not exercised by responsive layout tests');
  }
}
