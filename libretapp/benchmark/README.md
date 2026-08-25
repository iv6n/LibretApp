# Benchmarks

Timings for the paths a breeder waits on. Everything runs under `flutter test`
because that is what supplies a Flutter binding and the native Isar library —
the "tests" assert nothing, they measure.

## Running

```bash
flutter test benchmark/data_layer_bench.dart --dart-define=BENCH_OUT=benchmark/results/after.json
flutter test benchmark/list_render_bench.dart --dart-define=BENCH_OUT=benchmark/results/list_rebuild.json
python benchmark/compare.py benchmark/results/before.json benchmark/results/after.json
```

**Run them on an idle machine.** These numbers move by 3-10x under CPU
contention; a benchmark run alongside a `flutter test` sweep is measuring the
sweep, not the code.

## What is here

| File | Measures |
| --- | --- |
| `data_layer_bench.dart` | Isar reads and writes against a seeded herd: opening the directory, opening one animal, saving a treatment, deleting a record. |
| `list_render_bench.dart` | Cost of *rebuilding* the directory list, eager `ListView(children:)` versus lazy `ListView.builder`, using the real `AnimalCard` inside the same `Slidable` wrapping the screen uses. |
| `support/bench_db.dart` | Opens a throwaway Isar and seeds a fixed herd (2 000 animals, 46 000 child records by default). Seeds Isar models directly so the data is identical run to run. |
| `support/bench_runner.dart` | Warm-up, repeat, median/p90, and a JSON dump so runs can be diffed. |
| `compare.py` | Prints a before/after table from two result files. |

## Reading the output

Each line reports the **median** over N timed iterations after a warm-up, plus
p90. Compare medians; p90 catches the odd GC pause and is noisy at these
sample counts.

`results/index_map.json` and `results/accessor_map.json` are generated
inventories of which `(collection, field)` pairs the Isar codegen actually
exposes an index-backed `where()` clause for. Regenerate them after changing an
`@Index` and re-running `build_runner`; they are what tells you whether a query
can be an index seek rather than a collection scan.
