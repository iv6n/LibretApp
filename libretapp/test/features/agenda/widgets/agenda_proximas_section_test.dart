import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:libretapp/features/agenda/data/agenda_model.dart';
import 'package:libretapp/features/agenda/domain/agenda_task_grouping.dart';
import 'package:libretapp/features/agenda/widgets/agenda_proximas_section.dart';
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

AgendaEntry _campaignEntry(
  String animalId,
  DateTime date, {
  String rule = 'vac',
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
    completedAnimalIds: const [],
    notas: '',
  );
}

void main() {
  final today = DateTime(2026, 8, 2);
  const grouper = AgendaTaskGrouper();

  Widget wrap(Widget child) => MaterialApp(
    theme: AppTheme.lightTheme,
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

    await tester.pumpWidget(
      wrap(
        AgendaProximasSection(
          groups: groups,
          animalsById: animals,
          today: today,
          onOpenGroup: (group) => opened = group,
        ),
      ),
    );

    expect(find.text('Sanidad'), findsOneWidget);
    expect(find.text('Vacunación'), findsNWidgets(2));
    expect(find.text('2 animales'), findsOneWidget);
    expect(find.byType(Card), findsOneWidget);
    expect(find.textContaining('Vaca T-12'), findsNothing);

    await tester.tap(
      find.byKey(const ValueKey('agenda-event-toggle-animals:vacunacion')),
    );
    await tester.pumpAndSettle();

    expect(find.textContaining('Vaca T-12'), findsOneWidget);
    expect(find.textContaining('Vaca T-45'), findsOneWidget);

    await tester.tap(find.text('Vacunación').first);
    await tester.pump();
    expect(opened?.animalCount, 2);
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

  testWidgets('la lista de más de cinco animales queda acotada y desplazable', (
    tester,
  ) async {
    final due = today.add(const Duration(days: 1));
    final entries = [for (var i = 1; i <= 8; i++) _campaignEntry('$i', due)];
    final animals = {for (var i = 1; i <= 8; i++) '$i': _cow('$i', 'T-$i')};
    final groups = grouper.group(entries, today: today);

    await tester.pumpWidget(
      wrap(
        AgendaProximasSection(
          groups: groups,
          animalsById: animals,
          today: today,
          onOpenGroup: (_) {},
        ),
      ),
    );
    await tester.tap(find.byIcon(Icons.expand_more));
    await tester.pumpAndSettle();

    expect(find.byType(Scrollbar), findsOneWidget);
    expect(find.byType(ListView), findsOneWidget);
    expect(find.textContaining('Vaca T-8'), findsNothing);

    await tester.drag(find.byType(ListView), const Offset(0, -220));
    await tester.pumpAndSettle();
    expect(find.textContaining('Vaca T-8'), findsOneWidget);
  });
}
