import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:libretapp/app/widgets/shell_fab.dart';
import 'package:libretapp/core/di/injection.dart';
import 'package:libretapp/core/router/app_routes.dart';
import 'package:libretapp/features/agenda/bloc/agenda_bloc.dart';
import 'package:libretapp/features/agenda/bloc/agenda_event.dart';
import 'package:libretapp/features/agenda/data/agenda_model.dart';
import 'package:libretapp/features/agenda/data/agenda_repository.dart';
import 'package:libretapp/features/agenda/view/agenda_view.dart';
import 'package:libretapp/features/agenda/widgets/agenda_calendar.dart';
import 'package:libretapp/features/directorio/animales/domain/entities/animal_entity.dart';
import 'package:libretapp/features/directorio/animales/infrastructure/animal_repository.dart';
import 'package:libretapp/features/directorio/cultivos/domain/cultivation_entity.dart';
import 'package:libretapp/features/directorio/cultivos/domain/cultivation_repository.dart';
import 'package:libretapp/l10n/app_localizations.dart';

class _Animals extends Fake implements AnimalRepository {
  @override
  Future<List<AnimalEntity>> getAll() async => [];

  @override
  Stream<void> watchChanges() => const Stream<void>.empty();
}

class _Crop extends Fake implements CultivationEntity {}

class _Cultivations extends Fake implements CultivationRepository {
  _Cultivations(this.items);

  List<CultivationEntity> items;
  final _changes = StreamController<List<CultivationEntity>>.broadcast();

  void replace(List<CultivationEntity> next) {
    items = next;
    _changes.add(next);
  }

  Future<void> dispose() => _changes.close();

  @override
  Stream<List<CultivationEntity>> watchAll({
    bool includeArchived = false,
  }) async* {
    yield items;
    yield* _changes.stream;
  }

  @override
  Future<List<CultivationEntity>> getAll({
    bool includeArchived = false,
  }) async => items;
}

class _Entries extends Fake implements AgendaRepository {
  _Entries(this.items);

  final List<AgendaEntry> items;

  @override
  Future<List<AgendaEntry>> fetchEntries() async => items;
}

AgendaEntry _generalTask(DateTime date) => AgendaEntry(
  id: 'general-task',
  titulo: 'Revisar cuidados',
  descripcion: '',
  fecha: date,
  tipo: 'cuidado',
  animalIds: const [],
  loteIds: const [],
  ubicacion: '',
  estado: AgendaEstado.pendiente,
  completedAnimalIds: const [],
  notas: '',
);

Future<GoRouter> _mountAgenda(
  WidgetTester tester, {
  required List<CultivationEntity> crops,
  required List<AgendaEntry> entries,
  _Cultivations? cultivationRepository,
  ThemeMode themeMode = ThemeMode.light,
  double textScale = 1,
}) async {
  await locator.reset();
  locator.registerSingleton<AnimalRepository>(_Animals());
  final cropRepository = cultivationRepository ?? _Cultivations(crops);
  locator.registerSingleton<CultivationRepository>(cropRepository);
  final router = GoRouter(
    initialLocation: '/agenda',
    routes: [
      GoRoute(
        path: '/agenda',
        name: AppRoutes.nameAgenda,
        builder: (_, _) => BlocProvider(
          create: (_) => AgendaBloc(_Entries(entries))..add(const LoadAgenda()),
          child: const AgendaView(),
        ),
      ),
      GoRoute(
        path: '/agenda/nuevo',
        name: AppRoutes.nameAgendaNuevo,
        builder: (_, _) => const Scaffold(body: Text('Formulario de agenda')),
      ),
      GoRoute(
        path: '/directorio',
        name: AppRoutes.nameDirectorio,
        builder: (_, _) => const Scaffold(body: Text('Directorio abierto')),
      ),
      GoRoute(
        path: '/directorio/animales/nuevo',
        name: AppRoutes.nameAnimalNuevo,
        builder: (_, _) => const Scaffold(body: Text('Formulario animal')),
      ),
      GoRoute(
        path: '/directorio/cultivos/nuevo',
        name: AppRoutes.nameCultivoNuevo,
        builder: (_, _) => const Scaffold(body: Text('Formulario cultivo')),
      ),
    ],
  );
  addTearDown(() async {
    router.dispose();
    await cropRepository.dispose();
    await locator.reset();
  });
  await tester.pumpWidget(
    MaterialApp.router(
      routerConfig: router,
      themeMode: themeMode,
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
      locale: const Locale('es'),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(
          context,
        ).copyWith(textScaler: TextScaler.linear(textScale)),
        child: child!,
      ),
    ),
  );
  await tester.pumpAndSettle();
  return router;
}

Future<void> _scrollToActions(WidgetTester tester) async {
  await tester.drag(find.byType(CustomScrollView), const Offset(0, -600));
  await tester.pumpAndSettle();
}

void main() {
  setUpAll(() async => initializeDateFormatting('es'));

  testWidgets('first use keeps calendar and opens help and animal form', (
    tester,
  ) async {
    await _mountAgenda(tester, crops: const [], entries: const []);
    expect(find.byType(AgendaCalendar), findsOneWidget);
    expect(find.text('Tu agenda empieza aquí'), findsOneWidget);
    expect(
      tester
          .widget<ShellFabConfigScope>(find.byType(ShellFabConfigScope))
          .config,
      isNull,
    );

    await _scrollToActions(tester);
    await tester.tap(find.text('¿Cómo funciona?'));
    await tester.pumpAndSettle();
    expect(find.text('Cómo funciona la agenda'), findsOneWidget);
    Navigator.of(tester.element(find.text('Cómo funciona la agenda'))).pop();
    await tester.pumpAndSettle();

    await _scrollToActions(tester);
    await tester.tap(find.text('Agregar'));
    await tester.pumpAndSettle();
    expect(find.text('Agregar animal'), findsOneWidget);
    expect(find.text('Agregar cultivo'), findsOneWidget);
    await tester.tap(find.text('Agregar animal'));
    await tester.pumpAndSettle();
    expect(find.text('Formulario animal'), findsOneWidget);
  });

  testWidgets('short empty agenda collapses to the selected week and expands', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(360, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await _mountAgenda(tester, crops: const [], entries: const []);

    for (final mode in [CalendarMode.twoWeeks, CalendarMode.month]) {
      final current = mode == CalendarMode.twoWeeks ? 'Semanal' : 'Quincenal';
      await tester.tap(find.byTooltip('Cambiar vista: $current'));
      await tester.pumpAndSettle();
      final now = DateTime.now();
      final selected = DateTime(now.year, now.month, 15);
      tester
          .widget<AgendaCalendar>(find.byType(AgendaCalendar))
          .onDaySelected(selected);
      await tester.pumpAndSettle();
      expect(
        tester.widget<AgendaCalendar>(find.byType(AgendaCalendar)).mode,
        mode,
      );

      await tester.drag(find.byType(CustomScrollView), const Offset(0, -40));
      await tester.pumpAndSettle();
      final collapsed = tester.widget<AgendaCalendar>(
        find.byType(AgendaCalendar),
      );
      expect(collapsed.mode, CalendarMode.week);
      expect(
        AgendaCalendarPeriod.days(collapsed.mode, collapsed.visibleDate),
        contains(selected),
      );
      final header = tester.widget<SliverAppBar>(find.byType(SliverAppBar));
      expect(header.collapsedHeight, header.expandedHeight);
      expect(
        tester
            .widget<Text>(find.byKey(const ValueKey('agenda_period_label')))
            .data,
        AgendaCalendarPeriod.compactLabel(CalendarMode.week, selected, 'es'),
      );

      await tester.drag(find.byType(CustomScrollView), const Offset(0, 600));
      await tester.pumpAndSettle();
      expect(
        tester.widget<AgendaCalendar>(find.byType(AgendaCalendar)).mode,
        mode,
      );
    }
  });

  testWidgets('first-use selector also opens the cultivation form', (
    tester,
  ) async {
    await _mountAgenda(tester, crops: const [], entries: const []);
    await _scrollToActions(tester);
    await tester.tap(find.text('Agregar'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Agregar cultivo'));
    await tester.pumpAndSettle();
    expect(find.text('Formulario cultivo'), findsOneWidget);
  });

  testWidgets('registered crop and no entries opens the directory', (
    tester,
  ) async {
    await _mountAgenda(tester, crops: [_Crop()], entries: const []);
    expect(find.text('Hoy no hay actividades'), findsOneWidget);
    expect(find.text('Programar actividad'), findsOneWidget);
    await _scrollToActions(tester);
    await tester.tap(find.text('Ver mis registros'));
    await tester.pumpAndSettle();
    expect(find.text('Directorio abierto'), findsOneWidget);
  });

  testWidgets('registered crop and no entries opens the agenda form', (
    tester,
  ) async {
    await _mountAgenda(tester, crops: [_Crop()], entries: const []);
    await _scrollToActions(tester);
    await tester.tap(find.text('Programar actividad'));
    await tester.pumpAndSettle();
    expect(find.text('Formulario de agenda'), findsOneWidget);
  });

  testWidgets('archiving the last crop changes the empty state', (
    tester,
  ) async {
    final crops = _Cultivations([_Crop()]);
    await _mountAgenda(
      tester,
      crops: crops.items,
      cultivationRepository: crops,
      entries: const [],
    );
    expect(find.text('Hoy no hay actividades'), findsOneWidget);
    crops.replace(const []);
    await tester.pumpAndSettle();
    expect(find.text('Tu agenda empieza aquí'), findsOneWidget);
  });

  testWidgets('a general task remains visible without animals or crops', (
    tester,
  ) async {
    final tomorrow = DateTime.now().add(const Duration(days: 1));
    await _mountAgenda(
      tester,
      crops: const [],
      entries: [_generalTask(tomorrow)],
    );
    expect(find.text('Tu agenda empieza aquí'), findsNothing);
    expect(find.text('Tu agenda en marcha'), findsOneWidget);
    expect(find.text('Sin pendientes para este día'), findsOneWidget);
    expect(find.text('Revisar cuidados'), findsWidgets);
    expect(
      tester
          .widget<ShellFabConfigScope>(find.byType(ShellFabConfigScope))
          .config,
      isNotNull,
    );

    tester
        .widget<AgendaCalendar>(find.byType(AgendaCalendar))
        .onDaySelected(tomorrow);
    await tester.pumpAndSettle();
    expect(find.text('Sin pendientes para este día'), findsNothing);
    expect(find.text('Revisar cuidados'), findsWidgets);
  });

  testWidgets('tasks from today remain listed when another day is selected', (
    tester,
  ) async {
    final today = DateTime.now();
    final tomorrow = today.add(const Duration(days: 1));
    await _mountAgenda(
      tester,
      crops: const [],
      entries: [
        _generalTask(today),
        _generalTask(
          tomorrow,
        ).copyWith(id: 'tomorrow-task', titulo: 'Revisar mañana'),
      ],
    );
    tester
        .widget<AgendaCalendar>(find.byType(AgendaCalendar))
        .onDaySelected(tomorrow);
    await tester.pumpAndSettle();
    expect(find.text('Revisar cuidados'), findsWidgets);
    expect(find.text('Revisar mañana'), findsWidgets);
  });

  for (final themeMode in [ThemeMode.light, ThemeMode.dark]) {
    testWidgets('empty state fits a narrow screen at 200% in $themeMode', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(320, 568);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await _mountAgenda(
        tester,
        crops: [_Crop()],
        entries: const [],
        themeMode: themeMode,
        textScale: 2,
      );
      await _scrollToActions(tester);
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });
  }
}
