import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:libretapp/features/directorio/animales/domain/animal_domain.dart';
import 'package:libretapp/features/directorio/animales/widgets/reproduction_followup_card.dart';
import 'package:libretapp/features/registro/view/registro_reproduccion_page.dart'
    show ReproductionInitialStep;

import 'advisor/rules/rule_test_fixtures.dart';

void main() {
  final serviceDate = DateTime(2026, 1, 10);

  test('estimations use the selected animal species', () {
    const scheduler = ReproductionScheduler();
    for (final (species, days) in [
      (Species.cattle, 283),
      (Species.sheep, 147),
      (Species.goat, 150),
    ]) {
      final schedule = scheduler.estimate(
        serviceDate: serviceDate,
        species: species,
      );
      expect(schedule.dueDate, serviceDate.add(Duration(days: days)));
      expect(
        schedule.pregnancyCheckDate,
        serviceDate.add(const Duration(days: 35)),
      );
    }
  });

  test('the next action follows the latest reproductive cycle', () {
    final animal = buildAnimal(species: Species.sheep, sex: Sex.female);
    final service = ReproductionRecord(
      serviceDate: serviceDate,
      expectedCalvingDate: serviceDate.add(const Duration(days: 147)),
    );

    final empty = ReproductionFollowup.from(animal, const []);
    expect(empty.step, ReproductionInitialStep.service);

    final pending = ReproductionFollowup.from(animal, [service]);
    expect(pending.step, ReproductionInitialStep.diagnosis);
    expect(pending.status, contains('sin confirmar'));
    expect(pending.nextDate, contains('si se confirma'));

    final pregnant = ReproductionFollowup.from(animal, [
      service.copyWith(pregnancyResult: PregnancyCheckResult.positive),
    ]);
    expect(pregnant.step, ReproductionInitialStep.calving);
    expect(pregnant.status, 'Preñez confirmada');

    final negative = ReproductionFollowup.from(animal, [
      service.copyWith(pregnancyResult: PregnancyCheckResult.negative),
    ]);
    expect(negative.step, ReproductionInitialStep.service);
    expect(negative.nextDate, isNot(contains('Parto estimado')));

    final calved = ReproductionFollowup.from(animal, [
      service.copyWith(actualCalvingDate: DateTime(2026, 6, 7)),
    ]);
    expect(calved.step, ReproductionInitialStep.service);
    expect(calved.status, contains('Último parto'));
  });

  testWidgets('large text keeps the main action available', (tester) async {
    final animal = buildAnimal(species: Species.goat, sex: Sex.female);
    ReproductionInitialStep? selected;
    await tester.pumpWidget(
      MaterialApp(
        home: MediaQuery(
          data: const MediaQueryData(textScaler: TextScaler.linear(2)),
          child: Scaffold(
            body: SingleChildScrollView(
              child: ReproductionFollowupCard(
                animal: animal,
                records: const [],
                onAction: (step) => selected = step,
                onShowRecords: () {},
              ),
            ),
          ),
        ),
      ),
    );

    expect(tester.takeException(), isNull);
    await tester.tap(find.text('Registrar monta'));
    expect(selected, ReproductionInitialStep.service);
  });
}
