import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:libretapp/features/agenda/data/agenda_model.dart';
import 'package:libretapp/features/agenda/domain/agenda_task_grouping.dart';
import 'package:libretapp/features/agenda/widgets/agenda_proximas_section.dart';
import 'package:libretapp/features/agenda/widgets/agenda_style.dart';
import 'package:libretapp/features/directorio/animales/domain/animal_domain.dart';
import 'package:libretapp/features/directorio/animales/domain/enums/production_stage.dart';
import 'package:libretapp/features/directorio/animales/domain/enums/production_system.dart';
import 'package:libretapp/theme/theme.dart';

AnimalEntity _cow(String uuid, String tag) {
  final now = DateTime(2026, 1, 1);
  return AnimalEntity(
    uuid: uuid,
    earTagNumber: tag,
    customName: 'Vaca $tag',
    species: Species.cattle,
    category: Category.cow,
    lifeStage: LifeStage.cow,
    sex: Sex.female,
    breed: 'Brahman',
    birthDate: DateTime(2023, 1, 1),
    ageMonths: 36,
    healthStatus: HealthStatus.good,
    vaccinated: false,
    dewormed: false,
    hasVitamins: false,
    hasChronicIssues: false,
    reproductiveStatus: ReproductiveStatus.active,
    productionPurpose: ProductionPurpose.breeding,
    productionStage: ProductionStage.reproductive,
    productionSystem: ProductionSystem.extensive,
    underObservation: false,
    requiresAttention: false,
    riskLevel: RiskLevel.none,
    gallery: const [],
    status: AnimalStatus.active,
    synced: true,
    creationDate: now,
    lastUpdateDate: now,
  );
}

AnimalEntity _goat(String uuid, String tag) => _cow(uuid, tag).copyWith(
  species: Species.goat,
  category: Category.production,
  lifeStage: LifeStage.goat,
  productionPurpose: ProductionPurpose.dairy,
);

AgendaEntry _campaignEntry(
  String animalId,
  DateTime date, {
  String rule = 'vac',
  List<String> completedAnimalIds = const [],
}) {
  final day =
      '${date.year}${date.month.toString().padLeft(2, '0')}'
      '${date.day.toString().padLeft(2, '0')}';
  return AgendaEntry(
    id: 'auto:care:$animalId:$rule:$day',
    titulo: 'Vacunación - Vaca $animalId',
    descripcion: '',
    fecha: date,
    tipo: 'Vacunación',
    animalIds: [animalId],
    loteIds: const [],
    ubicacion: 'Sin ubicación',
    estado: AgendaEstado.pendiente,
    completedAnimalIds: completedAnimalIds,
    notas: '',
  );
}

AgendaEntry _ranchEntry(DateTime date) => AgendaEntry(
  id: 'ranch-task-1',
  titulo: 'Mantenimiento general',
  descripcion: '',
  fecha: date,
  tipo: 'Mantenimiento',
  animalIds: const [],
  loteIds: const [],
  ubicacion: '',
  estado: AgendaEstado.pendiente,
  completedAnimalIds: const [],
  notas: '',
);

void main() {
  final today = DateTime(2026, 8, 2);
  const grouper = AgendaTaskGrouper();

  Widget wrap(Widget child, {ThemeData? theme, double textScale = 1}) =>
      MaterialApp(
        theme: theme ?? AppTheme.lightTheme,
        builder: (context, appChild) => MediaQuery(
          data: MediaQuery.of(
            context,
          ).copyWith(textScaler: TextScaler.linear(textScale)),
          child: appChild!,
        ),
        home: Scaffold(body: SingleChildScrollView(child: child)),
      );

  testWidgets('una campaña de dos vacas se muestra como una sola tarjeta', (
    tester,
  ) async {
    final due = today.add(const Duration(days: 1));
    final groups = grouper.group([
      _campaignEntry('12', due),
      _campaignEntry('45', due),
    ], today: today);
    final animals = {'12': _cow('12', 'T-12'), '45': _cow('45', 'T-45')};
    AgendaEventGroup? opened;
    AgendaEventGroup? completedGroup;
    List<AgendaTaskRow> completedRows = const [];

    await tester.pumpWidget(
      wrap(
        AgendaProximasSection(
          groups: groups,
          animalsById: animals,
          today: today,
          onOpenGroup: (group) => opened = group,
          onRegisterGroup: (group, rows) async {
            completedGroup = group;
            completedRows = rows;
          },
        ),
      ),
    );

    expect(find.text('Sanidad'), findsNothing);
    expect(find.text('Vacunación'), findsOneWidget);
    expect(find.text('Sanitario'), findsOneWidget);
    expect(find.text('2 animales'), findsOneWidget);
    expect(
      find.text('0 de 2 registrados · Toca para ver animales'),
      findsOneWidget,
    );
    expect(find.byType(Card), findsOneWidget);
    expect(find.textContaining('Vaca T-12'), findsNothing);
    expect(find.byType(Checkbox), findsNothing);
    await tester.tap(
      find.byKey(const ValueKey('agenda-event-header-animals:vacunacion')),
    );
    await tester.pumpAndSettle();
    expect(find.text('ANIMALES'), findsOneWidget);
    expect(find.text('0/2 registrados'), findsOneWidget);
    expect(find.textContaining('Vaca T-12'), findsOneWidget);
    expect(find.text('VACA'), findsNWidgets(2));
    expect(find.byType(Checkbox), findsNWidgets(2));
    expect(
      tester.getSize(find.byType(Checkbox).first).height,
      greaterThanOrEqualTo(48),
    );
    expect(
      find.byKey(
        const ValueKey('agenda-animal-list-surface-animals:vacunacion'),
      ),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey('agenda-event-header-animals:vacunacion')),
      findsOneWidget,
    );
    final completeButton = find.byKey(
      const ValueKey('agenda-event-register-animals:vacunacion'),
    );
    expect(tester.widget<FilledButton>(completeButton).onPressed, isNull);

    await tester.tap(find.byKey(const ValueKey('agenda-animal-checkbox-12')));
    await tester.pump();
    expect(find.text('Registrar (1)'), findsOneWidget);
    expect(completedGroup, isNull);
    expect(opened, isNull);

    await tester.tap(find.byKey(const ValueKey('agenda-animal-checkbox-45')));
    await tester.pump();
    expect(find.text('Registrar (2)'), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('agenda-animal-checkbox-45')));
    await tester.pump();
    expect(find.text('Registrar (1)'), findsOneWidget);

    await tester.tap(completeButton);
    await tester.pump();
    expect(completedGroup?.animalCount, 2);
    expect(completedRows, hasLength(1));
    expect(completedRows.single.animalId, '12');
    expect(completedRows.single.entry.id, contains('12'));

    expect(find.textContaining('Vaca T-12'), findsOneWidget);
    expect(find.textContaining('Vaca T-45'), findsOneWidget);

    await tester.tap(find.textContaining('Vaca T-12').first);
    await tester.pump();
    expect(opened?.animalCount, 2);
  });

  testWidgets('la cabecera de animales usa icono y contraste de agenda', (
    tester,
  ) async {
    final due = today.add(const Duration(days: 1));
    final entries = [
      _campaignEntry('1', due),
      _campaignEntry('2', due),
      _campaignEntry('3', due),
    ];
    final animals = {for (var i = 1; i <= 3; i++) '$i': _cow('$i', 'T-$i')};

    await tester.pumpWidget(
      wrap(
        AgendaProximasSection(
          groups: grouper.group(entries, today: today),
          animalsById: animals,
          today: today,
          onOpenGroup: (_) {},
        ),
      ),
    );

    await tester.tap(
      find.byKey(const ValueKey('agenda-event-header-animals:vacunacion')),
    );
    await tester.pumpAndSettle();

    final theme = AppTheme.lightTheme;
    final taskIcon = tester.widget<AgendaAssetIcon>(
      find.byType(AgendaAssetIcon),
    );
    expect(taskIcon.size, 25);

    final iconContainer = tester.widget<Container>(
      find
          .ancestor(
            of: find.byType(AgendaAssetIcon),
            matching: find.byType(Container),
          )
          .first,
    );
    final decoration = iconContainer.decoration! as BoxDecoration;
    expect(
      decoration.color,
      theme.colorScheme.primaryContainer.withValues(alpha: 0.55),
    );

    final animalsLabel = tester.widget<Text>(find.text('ANIMALES'));
    expect(animalsLabel.style?.color, theme.colorScheme.onSurfaceVariant);

    expect(find.text('Ver más animales'), findsNothing);
  });

  testWidgets('el mismo tipo con distinta fecha permanece en una tarjeta', (
    tester,
  ) async {
    final groups = grouper.group([
      _campaignEntry('12', today.add(const Duration(days: 1))),
      _campaignEntry('45', today.add(const Duration(days: 2))),
    ], today: today);

    await tester.pumpWidget(
      wrap(
        AgendaProximasSection(
          groups: groups,
          animalsById: {'12': _cow('12', 'T-12'), '45': _cow('45', 'T-45')},
          today: today,
          onOpenGroup: (_) {},
        ),
      ),
    );

    expect(find.byType(Card), findsOneWidget);
    expect(find.text('2 animales'), findsOneWidget);
    expect(
      find.text('0 de 2 registrados · Toca para ver animales'),
      findsOneWidget,
    );
    await tester.tap(
      find.byKey(const ValueKey('agenda-event-header-animals:vacunacion')),
    );
    await tester.pumpAndSettle();
    expect(find.text('ANIMALES'), findsOneWidget);
  });

  testWidgets('una categoría sin pendientes no se renderiza', (tester) async {
    await tester.pumpWidget(
      wrap(
        AgendaProximasSection(
          groups: const [],
          animalsById: const {},
          today: today,
          onOpenGroup: (_) {},
        ),
      ),
    );

    expect(find.text('Sanidad'), findsNothing);
    expect(find.text('Sin pendientes'), findsOneWidget);
  });

  testWidgets('una tarea sin animales conserva su fila de tarea', (
    tester,
  ) async {
    final groups = grouper.group([_ranchEntry(today)], today: today);
    AgendaEventGroup? completedGroup;
    List<AgendaTaskRow>? completedRows;

    await tester.pumpWidget(
      wrap(
        AgendaProximasSection(
          groups: groups,
          animalsById: const {},
          today: today,
          onOpenGroup: (_) {},
          onRegisterGroup: (group, rows) async {
            completedGroup = group;
            completedRows = rows;
          },
        ),
      ),
    );

    expect(find.text('Mantenimiento general'), findsOneWidget);
    expect(find.byType(Checkbox), findsNothing);
    expect(find.text('Administración'), findsNWidgets(2));
    expect(find.text('Toca para ver detalles y registrar'), findsOneWidget);
    final completeButton = find.byKey(
      const ValueKey('agenda-event-register-entry:ranch-task-1'),
    );
    expect(completeButton, findsNothing);
    await tester.tap(
      find.byKey(const ValueKey('agenda-event-header-entry:ranch-task-1')),
    );
    await tester.pumpAndSettle();
    expect(find.text('Mantenimiento general'), findsNWidgets(2));
    expect(find.text('0/1 pendiente'), findsOneWidget);
    expect(tester.widget<FilledButton>(completeButton).onPressed, isNotNull);
    expect(find.byIcon(Icons.expand_more), findsNothing);

    await tester.tap(completeButton);
    await tester.pump();
    expect(completedGroup?.primaryEntry.id, 'ranch-task-1');
    expect(completedRows, hasLength(1));
    expect(completedRows!.single.animalId, isNull);
  });

  testWidgets('la lista de más de cinco animales queda acotada y desplazable', (
    tester,
  ) async {
    final due = today.add(const Duration(days: 1));
    final entries = [for (var i = 1; i <= 8; i++) _campaignEntry('$i', due)];
    final animals = {for (var i = 1; i <= 8; i++) '$i': _cow('$i', 'T-$i')};
    final groups = grouper.group(entries, today: today);
    AgendaEventGroup? opened;
    List<AgendaTaskRow> completedRows = const [];

    await tester.pumpWidget(
      wrap(
        AgendaProximasSection(
          groups: groups,
          animalsById: animals,
          today: today,
          onOpenGroup: (group) => opened = group,
          onRegisterGroup: (_, rows) async => completedRows = rows,
        ),
      ),
    );
    expect(find.byType(ListView), findsNothing);
    expect(find.byType(Checkbox), findsNothing);
    await tester.tap(
      find.byKey(const ValueKey('agenda-event-header-animals:vacunacion')),
    );
    await tester.pumpAndSettle();
    expect(tester.getSize(find.byType(ListView)).height, 170);
    expect(find.byType(Checkbox), findsNWidgets(3));
    expect(find.text('Ver más animales'), findsOneWidget);
    final completeButton = find.byKey(
      const ValueKey('agenda-event-register-animals:vacunacion'),
    );
    expect(completeButton, findsOneWidget);
    expect(tester.widget<FilledButton>(completeButton).onPressed, isNull);

    expect(find.byType(Scrollbar), findsNothing);
    expect(find.byType(ListView), findsOneWidget);
    expect(tester.getSize(find.byType(ListView)).height, 170);
    expect(find.byType(Checkbox), findsNWidgets(3));
    expect(find.textContaining('Vaca T-8'), findsNothing);

    await tester.tap(find.text('Ver más animales'));
    await tester.pumpAndSettle();
    expect(find.byType(Scrollbar), findsOneWidget);
    expect(tester.getSize(find.byType(ListView)).height, 284);
    expect(find.byType(Checkbox), findsNWidgets(5));

    await tester.tap(find.byKey(const ValueKey('agenda-animal-checkbox-1')));
    await tester.pump();
    expect(find.text('Registrar (1)'), findsOneWidget);

    final eventHeader = find.byKey(
      const ValueKey('agenda-event-header-animals:vacunacion'),
    );
    await tester.tap(eventHeader);
    await tester.pumpAndSettle();
    expect(find.byType(ListView), findsNothing);
    expect(find.byType(Checkbox), findsNothing);
    await tester.tap(eventHeader);
    await tester.pumpAndSettle();
    expect(find.text('Registrar (1)'), findsOneWidget);
    expect(
      tester
          .widget<Checkbox>(
            find.byKey(const ValueKey('agenda-animal-checkbox-1')),
          )
          .value,
      isTrue,
    );

    await tester.tap(find.text('Ver menos animales'));
    await tester.pumpAndSettle();
    expect(find.byType(Checkbox), findsNWidgets(3));
    expect(find.text('Registrar (1)'), findsOneWidget);

    await tester.tap(find.text('Ver más animales'));
    await tester.pumpAndSettle();
    expect(find.byType(Checkbox), findsNWidgets(5));
    expect(
      tester
          .widget<Checkbox>(
            find.byKey(const ValueKey('agenda-animal-checkbox-1')),
          )
          .value,
      isTrue,
    );

    await tester.tap(find.textContaining('Vaca T-1').first);
    await tester.pump();
    expect(opened?.animalCount, 8);

    await tester.tap(
      find.byKey(const ValueKey('agenda-event-register-animals:vacunacion')),
    );
    await tester.pump();
    expect(completedRows, hasLength(1));
    expect(completedRows.single.animalId, '1');

    await tester.drag(find.byType(ListView), const Offset(0, -220));
    await tester.pumpAndSettle();
    expect(find.textContaining('Vaca T-8'), findsOneWidget);
  });

  testWidgets('muestra progreso persistido sin duplicar animales', (
    tester,
  ) async {
    final due = today.add(const Duration(days: 1));
    final groups = grouper.group([
      _campaignEntry('12', due, completedAnimalIds: ['12']),
      _campaignEntry('45', due),
    ], today: today);

    await tester.pumpWidget(
      wrap(
        AgendaProximasSection(
          groups: groups,
          animalsById: {'45': _cow('45', 'T-45')},
          today: today,
          onOpenGroup: (_) {},
        ),
      ),
    );

    expect(
      find.text('1 de 2 registrados · Toca para ver animales'),
      findsOneWidget,
    );
    expect(find.textContaining('Vaca T-12'), findsNothing);
    await tester.tap(
      find.byKey(const ValueKey('agenda-event-header-animals:vacunacion')),
    );
    await tester.pumpAndSettle();
    expect(find.textContaining('Vaca T-45'), findsOneWidget);
  });

  testWidgets('el chip de un caprino muestra su etapa y no su proposito', (
    tester,
  ) async {
    final due = today.add(const Duration(days: 1));
    final groups = grouper.group([_campaignEntry('goat-1', due)], today: today);

    await tester.pumpWidget(
      wrap(
        AgendaProximasSection(
          groups: groups,
          animalsById: {'goat-1': _goat('goat-1', 'G-1')},
          today: today,
          onOpenGroup: (_) {},
        ),
      ),
    );

    await tester.tap(
      find.byKey(const ValueKey('agenda-event-header-animals:vacunacion')),
    );
    await tester.pumpAndSettle();

    expect(find.text('CABRA'), findsOneWidget);
    expect(find.text('LECHERÍA'), findsNothing);
  });

  testWidgets('un solo animal oculta el check y permite completarlo directo', (
    tester,
  ) async {
    final due = today.add(const Duration(days: 1));
    final groups = grouper.group([_campaignEntry('12', due)], today: today);
    List<AgendaTaskRow> completedRows = const [];

    await tester.pumpWidget(
      wrap(
        AgendaProximasSection(
          groups: groups,
          animalsById: {'12': _cow('12', 'T-12')},
          today: today,
          onOpenGroup: (_) {},
          onRegisterGroup: (_, rows) async => completedRows = rows,
        ),
      ),
    );

    expect(find.byType(Checkbox), findsNothing);
    expect(
      find.text('0 de 1 registrado · Toca para ver animales'),
      findsOneWidget,
    );
    final completeButton = find.byKey(
      const ValueKey('agenda-event-register-animals:vacunacion'),
    );
    expect(completeButton, findsNothing);
    await tester.tap(
      find.byKey(const ValueKey('agenda-event-header-animals:vacunacion')),
    );
    await tester.pumpAndSettle();
    final expandedCompleteButton = find.byKey(
      const ValueKey('agenda-event-register-animals:vacunacion'),
    );
    expect(find.text('Registrar'), findsOneWidget);
    expect(
      tester.widget<FilledButton>(expandedCompleteButton).onPressed,
      isNotNull,
    );

    await tester.tap(expandedCompleteButton);
    await tester.pump();

    expect(completedRows, hasLength(1));
    expect(completedRows.single.animalId, '12');
  });

  testWidgets('la tarjeta conserva legibilidad y acciones con texto al 200%', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(360, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final due = today.add(const Duration(days: 1));
    final entries = [for (var i = 1; i <= 4; i++) _campaignEntry('$i', due)];
    final animals = {for (var i = 1; i <= 4; i++) '$i': _cow('$i', 'T-$i')};
    const headerKey = ValueKey('agenda-event-header-animals:vacunacion');

    await tester.pumpWidget(
      wrap(
        AgendaProximasSection(
          groups: grouper.group(entries, today: today),
          animalsById: animals,
          today: today,
          onOpenGroup: (_) {},
        ),
        textScale: 2,
      ),
    );
    await tester.tap(find.byKey(headerKey));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(
      tester.getSize(find.byKey(headerKey)).height,
      greaterThanOrEqualTo(48),
    );
    final moreButton = find.ancestor(
      of: find.text('Ver más animales'),
      matching: find.byType(TextButton),
    );
    expect(tester.getSize(moreButton).height, greaterThanOrEqualTo(48));
  });

  testWidgets('la tarjeta expandida respeta el tema oscuro', (tester) async {
    final due = today.add(const Duration(days: 1));
    final entries = [_campaignEntry('1', due), _campaignEntry('2', due)];
    final group = grouper.group(entries, today: today);

    await tester.pumpWidget(
      wrap(
        AgendaProximasSection(
          groups: group,
          animalsById: {'1': _cow('1', 'T-1'), '2': _cow('2', 'T-2')},
          today: today,
          onOpenGroup: (_) {},
        ),
        theme: AppTheme.darkTheme,
      ),
    );
    await tester.tap(
      find.byKey(const ValueKey('agenda-event-header-animals:vacunacion')),
    );
    await tester.pumpAndSettle();

    expect(find.text('ANIMALES'), findsOneWidget);
    expect(tester.takeException(), isNull);
    expect(
      tester.widget<Card>(find.byType(Card)).color,
      AppTheme.darkTheme.colorScheme.surfaceContainerLow,
    );
  });
}
