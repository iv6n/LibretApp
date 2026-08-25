/// benchmark › list_render_bench — cost of rebuilding the directory list.
///
/// Run with:
///   flutter test benchmark/list_render_bench.dart --dart-define=BENCH_OUT=<file>
///
/// The directory builds its rows with `ListView(children: [...])`, so every
/// animal in the herd gets its row widgets constructed on every rebuild — and
/// the list rebuilds on every database change, filter tap and selection
/// toggle. This measures that against the lazy `ListView.builder`.
///
/// What is measured is a *rebuild*, not the first frame: the first pump is
/// dominated by one-time warm-up, which at these sizes is larger than the
/// effect under test. Rows use the same wrapping the screen uses — a
/// [Slidable] with both action panes around the real [AnimalCard] — so the
/// per-row construction cost is the app's own.
library;

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:libretapp/features/directorio/animales/domain/animal_domain.dart';
import 'package:libretapp/features/directorio/animales/domain/enums/production_stage.dart';
import 'package:libretapp/features/directorio/animales/domain/enums/production_system.dart';
import 'package:libretapp/features/directorio/animales/widgets/animal_card.dart';
import 'package:libretapp/l10n/app_localizations.dart';

import 'support/bench_runner.dart';

AnimalEntity _animal(int i) => AnimalEntity(
  uuid: 'render-$i',
  earTagNumber: 'A${i.toString().padLeft(5, '0')}',
  species: Species.cattle,
  category: i.isEven ? Category.cow : Category.steer,
  lifeStage: i.isEven ? LifeStage.cow : LifeStage.steer,
  sex: i.isEven ? Sex.female : Sex.male,
  breed: 'Brahman',
  birthDate: DateTime(2021, 1, 1).subtract(Duration(days: i % 900)),
  ageMonths: 24 + (i % 80),
  weight: 300.0 + (i % 250),
  healthStatus: i % 17 == 0 ? HealthStatus.poor : HealthStatus.good,
  vaccinated: true,
  dewormed: true,
  hasVitamins: false,
  hasChronicIssues: false,
  reproductiveStatus: ReproductiveStatus.active,
  productionPurpose: ProductionPurpose.dual,
  productionStage: ProductionStage.idle,
  productionSystem: ProductionSystem.extensive,
  underObservation: i % 23 == 0,
  requiresAttention: i % 19 == 0,
  riskLevel: i % 31 == 0 ? RiskLevel.high : RiskLevel.low,
  gallery: const [],
  synced: true,
  creationDate: DateTime(2024, 1, 1),
  lastUpdateDate: DateTime(2024, 6, 1).add(Duration(days: i % 90)),
);

/// One directory row, wrapped the way `animales_list_view` wraps it.
Widget _row(AnimalEntity animal) => Padding(
  padding: const EdgeInsets.symmetric(horizontal: 2),
  child: Slidable(
    key: ValueKey('slide_${animal.uuid}'),
    startActionPane: ActionPane(
      motion: const DrawerMotion(),
      extentRatio: 0.22,
      children: [
        SlidableAction(
          onPressed: (_) {},
          backgroundColor: Colors.green.shade600,
          foregroundColor: Colors.white,
          icon: Icons.monitor_weight_outlined,
          label: 'Pesar',
        ),
      ],
    ),
    endActionPane: ActionPane(
      motion: const DrawerMotion(),
      extentRatio: 0.22,
      children: [
        SlidableAction(
          onPressed: (_) {},
          backgroundColor: Colors.blue.shade700,
          foregroundColor: Colors.white,
          icon: Icons.medical_services_outlined,
          label: 'Salud',
        ),
      ],
    ),
    child: AnimalCard(key: ValueKey('card_${animal.uuid}'), animal: animal),
  ),
);

/// Rebuilds its list body whenever [notifier] ticks, the way a bloc emission
/// rebuilds the directory.
class _Rebuildable extends StatelessWidget {
  const _Rebuildable({required this.notifier, required this.body});

  final ValueNotifier<int> notifier;
  final Widget Function() body;

  @override
  Widget build(BuildContext context) => MaterialApp(
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: Scaffold(
      body: ValueListenableBuilder<int>(
        valueListenable: notifier,
        builder: (context, _, _) => body(),
      ),
    ),
  );
}

void main() {
  final suite = BenchSuite('list-rebuild');
  const outPath = String.fromEnvironment(
    'BENCH_OUT',
    defaultValue: 'benchmark/results/list_render.json',
  );

  tearDownAll(() => suite.writeJson(outPath));

  Future<void> run(
    WidgetTester tester,
    String name,
    int herd,
    Widget Function(List<AnimalEntity>) listBuilder,
  ) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.reset);

    final animals = List.generate(herd, _animal, growable: false);
    final tick = ValueNotifier<int>(0);
    addTearDown(tick.dispose);

    await tester.pumpWidget(
      _Rebuildable(notifier: tick, body: () => listBuilder(animals)),
    );

    await suite.measure(
      name,
      scale: '$herd animals',
      iterations: 15,
      warmup: 10,
      body: () async {
        tick.value++;
        await tester.pump();
      },
    );

    stdout.writeln(
      '      ${find.byType(AnimalCard).evaluate().length} of $herd cards live '
      'in the element tree',
    );
  }

  // The first measured pump in the file otherwise pays for JIT-compiling the
  // whole card tree, which at these sizes dwarfs the effect under test. Burn
  // that cost here instead, on both flavours, before anything is recorded.
  testWidgets('warm up', (tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.reset);

    final animals = List.generate(2000, _animal, growable: false);
    final tick = ValueNotifier<int>(0);
    addTearDown(tick.dispose);

    for (final list in <Widget Function(List<AnimalEntity>)>[
      (a) => ListView(children: [for (final one in a) _row(one)]),
      (a) => ListView.builder(
        itemCount: a.length,
        itemBuilder: (context, index) => _row(a[index]),
      ),
    ]) {
      await tester.pumpWidget(
        _Rebuildable(notifier: tick, body: () => list(animals)),
      );
      for (var i = 0; i < 20; i++) {
        tick.value++;
        await tester.pump();
      }
    }
  });

  for (final herd in const [200, 1000, 2000]) {
    testWidgets('eager rebuild — $herd animals', (tester) async {
      await run(
        tester,
        'eager ListView(children:) rebuild',
        herd,
        (animals) => ListView(children: [for (final a in animals) _row(a)]),
      );
    });

    testWidgets('lazy rebuild — $herd animals', (tester) async {
      await run(
        tester,
        'lazy ListView.builder rebuild',
        herd,
        (animals) => ListView.builder(
          itemCount: animals.length,
          itemBuilder: (context, index) => _row(animals[index]),
        ),
      );
    });
  }
}
