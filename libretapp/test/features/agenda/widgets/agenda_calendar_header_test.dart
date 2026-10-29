import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:libretapp/core/di/injection.dart';
import 'package:libretapp/app/widgets/app_shell_fab.dart';
import 'package:libretapp/app/widgets/shell_fab.dart';
import 'package:libretapp/features/agenda/bloc/agenda_bloc.dart';
import 'package:libretapp/features/agenda/bloc/agenda_event.dart';
import 'package:libretapp/features/agenda/data/agenda_model.dart';
import 'package:libretapp/features/agenda/data/agenda_repository.dart';
import 'package:libretapp/features/agenda/data/workforce_model.dart';
import 'package:libretapp/features/agenda/data/workforce_repository.dart';
import 'package:libretapp/features/agenda/view/agenda_view.dart';
import 'package:libretapp/features/agenda/widgets/agenda_calendar.dart';
import 'package:libretapp/features/directorio/animales/domain/entities/animal_entity.dart';
import 'package:libretapp/features/directorio/animales/infrastructure/animal_repository.dart';
import 'package:libretapp/l10n/app_localizations.dart';

class _Animals extends Fake implements AnimalRepository {
  @override
  Future<List<AnimalEntity>> getAll() async => [];

  @override
  Stream<void> watchChanges() => const Stream<void>.empty();
}

class _Entries extends Fake implements AgendaRepository {
  @override
  Future<List<AgendaEntry>> fetchEntries() async => [];
}

class _Workforce extends Fake implements WorkforceRepository {
  @override
  Future<List<WorkerProfile>> fetchWorkers({
    bool includeInactive = false,
  }) async => [];

  @override
  Future<List<WorkTeam>> fetchTeams({bool includeInactive = false}) async => [];
}

void main() {
  setUpAll(() async => initializeDateFormatting('es'));

  test('periods start Monday and navigation crosses month and year', () {
    final endOfYear = DateTime(2026, 12, 31);
    final week = AgendaCalendarPeriod.range(CalendarMode.week, endOfYear);
    expect(week.start, DateTime(2026, 12, 28));
    expect(week.end, DateTime(2027, 1, 3));
    expect(
      AgendaCalendarPeriod.label(CalendarMode.week, endOfYear, 'es'),
      contains('2027'),
    );
    expect(
      AgendaCalendarPeriod.compactLabel(CalendarMode.week, endOfYear, 'es'),
      '28 dic 26–3 ene 27',
    );
    expect(
      AgendaCalendarPeriod.compactLabel(
        CalendarMode.week,
        endOfYear,
        'es',
        numeric: true,
      ),
      '28/12–3/1',
    );
    expect(
      AgendaCalendarPeriod.compactLabel(
        CalendarMode.week,
        DateTime(2026, 10, 26),
        'es',
      ),
      '26 oct–1 nov',
    );
    expect(
      AgendaCalendarPeriod.compactLabel(
        CalendarMode.month,
        DateTime(2026, 10, 26),
        'es',
      ),
      'oct 2026',
    );
    expect(
      AgendaCalendarPeriod.navigate(CalendarMode.week, endOfYear, 1),
      DateTime(2027, 1, 7),
    );
    expect(
      AgendaCalendarPeriod.navigate(CalendarMode.twoWeeks, endOfYear, -1),
      DateTime(2026, 12, 17),
    );
    expect(
      AgendaCalendarPeriod.navigate(
        CalendarMode.month,
        DateTime(2026, 1, 31),
        1,
      ),
      DateTime(2026, 2, 28),
    );
  });

  testWidgets('six-row month fits a narrow screen and accepts day selection', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 640);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final month = DateTime(2026, 8);
    expect(AgendaCalendarPeriod.days(CalendarMode.month, month), hasLength(42));
    DateTime? selected;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            height: AgendaCalendarPeriod.height(CalendarMode.month, month),
            child: MediaQuery(
              data: const MediaQueryData(
                padding: EdgeInsets.only(top: 24),
                textScaler: TextScaler.linear(1.3),
              ),
              child: AgendaCalendar(
                visibleDate: month,
                mode: CalendarMode.month,
                selectedDay: null,
                entriesByDay: const {},
                onDaySelected: (day) => selected = day,
              ),
            ),
          ),
        ),
      ),
    );
    expect(tester.takeException(), isNull);
    expect(
      tester.getBottomLeft(find.byType(AnimatedContainer).last).dy,
      lessThanOrEqualTo(tester.getBottomLeft(find.byType(AgendaCalendar)).dy),
    );
    await tester.tap(find.text('31').last);
    expect(selected, DateTime(2026, 8, 31));
  });

  testWidgets(
    'Agenda starts weekly, changes view and keeps controls on scroll',
    (tester) async {
      tester.view.physicalSize = const Size(320, 640);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await locator.reset();
      locator.registerSingleton<AnimalRepository>(_Animals());
      locator.registerSingleton<WorkforceRepository>(_Workforce());
      addTearDown(locator.reset);

      await tester.pumpWidget(
        BlocProvider(
          create: (_) => AgendaBloc(_Entries())..add(const LoadAgenda()),
          child: const MaterialApp(
            locale: Locale('es'),
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: AgendaView(),
          ),
        ),
      );
      await tester.pumpAndSettle();
      final initial = tester.widget<AgendaCalendar>(
        find.byType(AgendaCalendar),
      );
      expect(initial.mode, CalendarMode.week);
      final selectedDay = initial.selectedDay;

      final previousX = tester.getCenter(find.byTooltip('Periodo anterior')).dx;
      final dateFinder = find.byKey(const ValueKey('agenda_period_label'));
      final dateX = tester.getCenter(dateFinder).dx;
      final modeX = tester
          .getCenter(find.byTooltip('Cambiar vista: Semanal'))
          .dx;
      final nextX = tester.getCenter(find.byTooltip('Periodo siguiente')).dx;
      final searchX = tester.getCenter(find.byTooltip('Buscar agenda')).dx;
      expect(previousX, lessThan(modeX));
      expect(previousX, lessThan(dateX));
      expect(dateX, lessThan(modeX));
      expect(modeX, lessThan(nextX));
      expect(nextX, lessThan(searchX));
      expect(find.text('Agenda'), findsNothing);
      expect(
        tester.widget<SliverAppBar>(find.byType(SliverAppBar)).toolbarHeight,
        56,
      );
      final semantics = tester.ensureSemantics();
      expect(find.bySemanticsLabel(RegExp(r'Agenda, .*2026')), findsOneWidget);
      semantics.dispose();
      expect(
        (tester.getCenter(dateFinder).dy -
                tester.getCenter(find.byTooltip('Periodo siguiente')).dy)
            .abs(),
        lessThan(4),
      );
      await tester.tap(dateFinder);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));
      expect(
        find.text(
          AgendaCalendarPeriod.label(CalendarMode.week, selectedDay!, 'es'),
          findRichText: true,
        ),
        findsOneWidget,
      );
      await tester.tapAt(const Offset(10, 600));
      await tester.pumpAndSettle();
      expect(
        tester.getCenter(find.byTooltip('Cambiar vista: Semanal')).dy,
        tester.getCenter(find.byTooltip('Periodo siguiente')).dy,
      );
      expect(
        tester
            .widget<Icon>(
              find.descendant(
                of: find.byTooltip('Cambiar vista: Semanal'),
                matching: find.byType(Icon),
              ),
            )
            .icon,
        Icons.view_week_outlined,
      );

      await tester.tap(find.byTooltip('Cambiar vista: Semanal'));
      await tester.pumpAndSettle();
      await tester.tapAt(tester.getCenter(find.text('Quincenal')));
      await tester.pumpAndSettle();
      final fortnight = tester.widget<AgendaCalendar>(
        find.byType(AgendaCalendar),
      );
      expect(fortnight.mode, CalendarMode.twoWeeks);
      expect(fortnight.selectedDay, selectedDay);

      expect(find.byTooltip('Cambiar vista: Quincenal'), findsOneWidget);
      await tester.tap(find.byTooltip('Cambiar vista: Quincenal'));
      await tester.pumpAndSettle();
      await tester.tapAt(tester.getCenter(find.text('Mensual')));
      await tester.pumpAndSettle();
      final month = tester.widget<AgendaCalendar>(find.byType(AgendaCalendar));
      expect(month.mode, CalendarMode.month);
      expect(month.selectedDay, selectedDay);
      expect(tester.takeException(), isNull);

      final targetDay = selectedDay.day == 15 ? 16 : 15;
      await tester.tapAt(tester.getCenter(find.text('$targetDay')));
      await tester.pumpAndSettle();
      expect(
        tester.widget<AgendaCalendar>(find.byType(AgendaCalendar)).selectedDay,
        DateTime(selectedDay.year, selectedDay.month, targetDay),
      );
      expect(tester.getSize(find.byType(AppBar)).height, greaterThan(100));

      await tester.drag(find.byType(CustomScrollView), const Offset(0, -500));
      await tester.pumpAndSettle();
      expect(tester.getSize(find.byType(AppBar)).height, lessThan(100));
      expect(find.byTooltip('Periodo siguiente'), findsOneWidget);
      expect(find.byTooltip('Cambiar vista: Mensual'), findsOneWidget);
      expect(find.byTooltip('Buscar agenda'), findsOneWidget);
      await tester.tap(find.byTooltip('Periodo siguiente'));
      await tester.pumpAndSettle();
      expect(
        tester.widget<AgendaCalendar>(find.byType(AgendaCalendar)).selectedDay,
        AgendaCalendarPeriod.navigate(
          CalendarMode.month,
          DateTime(selectedDay.year, selectedDay.month, targetDay),
          1,
        ),
      );
      await tester.tap(find.byTooltip('Cambiar vista: Mensual'));
      await tester.pumpAndSettle();
      expect(find.text('Personal y cuadrillas'), findsNothing);
      await tester.tapAt(const Offset(10, 600));
      await tester.pumpAndSettle();
      await tester.tap(find.byTooltip('Buscar agenda'));
      await tester.pumpAndSettle();
      expect(find.byType(TextField), findsOneWidget);
      expect(
        tester.widget<TextField>(find.byType(TextField)).focusNode?.hasFocus,
        isTrue,
      );
      expect(find.byTooltip('Cambiar vista: Mensual'), findsNothing);
      await tester.tap(find.byTooltip('Cerrar búsqueda'));
      await tester.pumpAndSettle();
      expect(find.byTooltip('Cambiar vista: Mensual'), findsOneWidget);
      expect(find.byTooltip('Buscar agenda'), findsOneWidget);
      expect(tester.takeException(), isNull);

      await tester.drag(find.byType(CustomScrollView), const Offset(0, 500));
      await tester.pumpAndSettle();
      final secondary = tester
          .widget<ShellFabConfigScope>(find.byType(ShellFabConfigScope))
          .config!
          .secondary!;
      expect(secondary.tooltip, 'Personal y cuadrillas');
      secondary.onPressed();
      await tester.pumpAndSettle();
      expect(find.text('Personal y cuadrillas'), findsWidgets);
    },
  );

  testWidgets('Agenda header fits at 320 dp with larger text', (tester) async {
    tester.view.physicalSize = const Size(320, 640);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await locator.reset();
    locator.registerSingleton<AnimalRepository>(_Animals());
    locator.registerSingleton<WorkforceRepository>(_Workforce());
    addTearDown(locator.reset);

    await tester.pumpWidget(
      BlocProvider(
        create: (_) => AgendaBloc(_Entries())..add(const LoadAgenda()),
        child: MaterialApp(
          locale: const Locale('es'),
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(
              context,
            ).copyWith(textScaler: const TextScaler.linear(1.3)),
            child: child!,
          ),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const AgendaView(),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.byTooltip('Cambiar vista: Semanal'), findsOneWidget);
    expect(find.byTooltip('Buscar agenda'), findsOneWidget);
    expect(find.byKey(const ValueKey('agenda_period_label')), findsOneWidget);
    await tester.tap(find.byTooltip('Cambiar vista: Semanal'));
    await tester.pumpAndSettle();
    await tester.tapAt(tester.getCenter(find.text('Quincenal')));
    await tester.pumpAndSettle();
    expect(
      tester.widget<AgendaCalendar>(find.byType(AgendaCalendar)).mode,
      CalendarMode.twoWeeks,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('Agenda action buttons fit at 320 dp with larger text', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 640);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: MediaQuery(
            data: const MediaQueryData(
              size: Size(320, 640),
              textScaler: TextScaler.linear(1.3),
            ),
            child: AppShellFab(
              config: ShellFabConfig(
                id: 'agenda',
                label: 'Agregar',
                icon: Icons.add_task,
                onPressed: () {},
                secondary: ShellFabSecondaryAction(
                  id: 'agenda_workforce',
                  icon: Icons.groups_outlined,
                  tooltip: 'Personal y cuadrillas',
                  onPressed: () {},
                ),
              ),
              dockPadding: 0,
              backgroundColor: const Color(0xFF85502D),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    final add = tester.getRect(find.byType(FloatingActionButton).first);
    final group = tester.getRect(find.byType(FloatingActionButton).last);
    expect(add.right, lessThanOrEqualTo(group.left));
    expect(group.right, lessThanOrEqualTo(320));
    expect(
      tester
          .widget<FloatingActionButton>(find.byType(FloatingActionButton).last)
          .shape,
      isA<CircleBorder>(),
    );
    expect(find.byTooltip('Personal y cuadrillas'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
