import 'dart:convert';

import 'package:excel/excel.dart' as xlsx;
import 'package:flutter_test/flutter_test.dart';
import 'package:libretapp/core/services/herd_import_service.dart';
import 'package:libretapp/core/tenancy/tenancy.dart';
import 'package:libretapp/features/directorio/animales/domain/animal_domain.dart';
import 'package:libretapp/features/directorio/animales/infrastructure/animal_repository_isar.dart';
import 'package:libretapp/features/directorio/animales/infrastructure/animales_export_sheet.dart';

import '../../support/phase_one_fixture.dart';

class _FailingAnimals extends AnimalRepositoryIsar {
  _FailingAnimals(PhaseOneFixture fixture)
    : super(fixture.database, fixture.prefs, OfflineAnimalSource());
  int writes = 0;
  @override
  Future<AnimalEntity> save(AnimalEntity animal) async {
    if (++writes == 2) throw StateError('simulated disk failure');
    return super.save(animal);
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late PhaseOneFixture fixture;
  setUp(() async {
    fixture = PhaseOneFixture();
    await fixture.initialize();
  });
  tearDown(() => fixture.dispose());

  HerdImportDocument csv(HerdImportService service, String data) =>
      service.readDocument(utf8.encode(data), fileName: 'hato.csv');

  test(
    'preview is read-only, matches current export headers and preserves leading zeros',
    () async {
      final service = fixture.importer();
      final book = xlsx.Excel.createExcel();
      book.delete('Sheet1');
      final sheet = book['Animales'];
      sheet.appendRow([
        for (final value in [
          'UUID Animal',
          'N° Caravana',
          'Nombre',
          'Especie',
          'Categoría',
          'Sexo',
          'Raza',
          'Fecha Nac.',
          'Precisión nacimiento',
          'Edad (meses)',
          'Peso (kg)',
          'Estado',
          'Estado Salud',
          'Propietario',
        ])
          xlsx.TextCellValue(value),
      ]);
      sheet.appendRow([
        for (final value in [
          '',
          '000012345678',
          'Luna',
          'cattle',
          'cow',
          'female',
          'Criollo',
          '01/04/2022',
          'estimated',
          '48',
          '320,5',
          'active',
          'good',
          'Ana',
        ])
          xlsx.TextCellValue(value),
      ]);
      final preview = await service.preview(
        service.readDocument(book.save()!, fileName: 'exportacion.xlsx'),
      );
      expect(preview.rows.single.errors, isEmpty);
      expect(await fixture.animals.getAllIncludingInactive(), isEmpty);
      expect(preview.rows.single.proposed!.earTagNumber, '000012345678');
      expect(
        preview.rows.single.proposed!.birthDatePrecision,
        BirthDatePrecision.estimated,
      );
      final summary = await service.commit(preview, preview.defaultActions);
      expect(summary.created, 1);
      expect((await fixture.animals.getAll()).single.weight, 320.5);
    },
  );

  test(
    'the actual current Excel export can be previewed with native numeric cells and UUID columns',
    () async {
      await fixture.seedLot();
      final workbook = xlsx.Excel.createExcel();
      await AnimalesExportSheet(fixture.animals).writeTo(workbook);
      final service = fixture.importer();
      final preview = await service.preview(
        service.readDocument(workbook.save()!, fileName: 'hato-exportado.xlsx'),
      );
      expect(preview.existingCount, 2);
      expect(preview.invalidCount, 0);
      expect(preview.rows.map((r) => r.proposed!.earTagNumber).toSet(), {
        '0001',
        '0002',
      });
      expect(preview.rows.every((r) => r.proposed!.weight == 300), isTrue);
      expect(
        preview.defaultActions.values.every((a) => a == HerdImportAction.skip),
        isTrue,
      );
    },
  );

  test(
    'all duplicate rows are blocked; matching includes case, whitespace, RFID and inactive animals',
    () async {
      await fixture.seedLot();
      final current = (await fixture.animals.getByUuid('a'))!;
      await fixture.animals.update(
        current.copyWith(rfidTag: 'ABC123', status: AnimalStatus.sold),
      );
      final service = fixture.importer();
      final preview = await service.preview(
        csv(
          service,
          'Arete,RFID,Nombre\n X1 ,,Uno\nx1,,Dos\n0001,ABC123,Vendida\n,abc123,Repetida\n',
        ),
      );
      expect(
        preview.rows
            .take(2)
            .every((r) => r.errors.any((e) => e.contains('repetida'))),
        isTrue,
      );
      expect(preview.rows[2].errors.any((e) => e.contains('vendido')), isTrue);
      expect(preview.rows[3].current?.uuid, 'a');
      expect(
        preview.defaultActions.values.every((a) => a == HerdImportAction.skip),
        isTrue,
      );
    },
  );

  test(
    'updates require explicit choice and preserve empty fields, ancestry, photos and histories',
    () async {
      await fixture.seedLot();
      var animal = (await fixture.animals.getByUuid('a'))!;
      await fixture.animals.update(
        animal.copyWith(
          customName: 'Luna',
          damUuid: 'mother',
          gallery: const ['photo.jpg'],
          owner: 'Ana',
        ),
      );
      await fixture.health.addHealthRecord(
        'a',
        HealthRecord(
          date: DateTime.now(),
          type: HealthRecordType.checkup,
          product: '',
          notes: 'Consulta anterior',
        ),
      );
      animal = (await fixture.animals.getByUuid('a'))!;
      final service = fixture.importer();
      final preview = await service.preview(
        csv(service, 'Propietario,Nombre,Arete,Raza\n,,0001,Angus\n'),
      );
      expect(preview.rows.single.current!.uuid, 'a');
      expect(preview.defaultActions.values.single, HerdImportAction.skip);
      final summary = await service.commit(preview, {
        2: HerdImportAction.update,
      });
      final saved = (await fixture.animals.getByUuid('a'))!;
      expect(summary.updated, 1);
      expect(saved.customName, 'Luna');
      expect(saved.owner, 'Ana');
      expect(saved.damUuid, 'mother');
      expect(saved.gallery, ['photo.jpg']);
      expect(saved.breed, 'Angus');
      expect(await fixture.health.getHealthRecords('a'), hasLength(1));
      expect(saved.uuid, animal.uuid);
    },
  );

  test(
    'semicolon CSV supports decimal commas, quoted delimiters, BOM and multiline names',
    () async {
      final service = fixture.importer();
      final preview = await service.preview(
        csv(
          service,
          '\uFEFFArete;Nombre;Peso;Sexo\r\n0007;"Luna; primera\nsegunda";320,5;Hembra\r\n',
        ),
      );
      expect(preview.rows.single.errors, isEmpty);
      expect(
        preview.rows.single.proposed!.customName,
        'Luna; primera\nsegunda',
      );
      expect(preview.rows.single.proposed!.weight, 320.5);
      expect(
        preview.rows.single.proposed!.birthDatePrecision,
        BirthDatePrecision.unknown,
      );
    },
  );

  test(
    'invalid dates, enum values and nonfinite weights remain visible instead of being silently defaulted',
    () async {
      final service = fixture.importer();
      final preview = await service.preview(
        csv(
          service,
          'Arete,Fecha Nac.,Especie,Peso\n1,31/02/2026,cattle,300\n2,,unicornio,300\n3,,cattle,NaN\n',
        ),
      );
      expect(preview.invalidCount, 3);
      expect(await fixture.animals.getAllIncludingInactive(), isEmpty);
      await expectLater(
        service.commit(preview, {2: HerdImportAction.create}),
        throwsStateError,
      );
    },
  );

  test(
    'concurrent herd changes invalidate a preview before any selected row is written',
    () async {
      await fixture.seedLot();
      final service = fixture.importer();
      final preview = await service.preview(
        csv(service, 'Arete,Nombre\n0003,Nueva\n0001,Actualizada\n'),
      );
      final a = (await fixture.animals.getByUuid('a'))!;
      await fixture.animals.update(
        a.copyWith(notes: 'Cambió después de revisar'),
      );
      await expectLater(
        service.commit(preview, {
          2: HerdImportAction.create,
          3: HerdImportAction.update,
        }),
        throwsStateError,
      );
      expect(await fixture.animals.getAllIncludingInactive(), hasLength(2));
      expect(
        (await fixture.animals.getByUuid('a'))!.notes,
        'Cambió después de revisar',
      );
    },
  );

  test(
    'an import storage failure rolls back earlier rows and the same preview can be retried',
    () async {
      final repository = _FailingAnimals(fixture);
      final service = fixture.importer(repository: repository);
      final preview = await service.preview(
        csv(service, 'Arete,Sexo\n0001,Hembra\n0002,Macho\n'),
      );
      await expectLater(
        service.commit(preview, preview.defaultActions),
        throwsStateError,
      );
      expect(await fixture.animals.getAllIncludingInactive(), isEmpty);
      final result = await service.commit(preview, preview.defaultActions);
      expect(result.created, 2);
      await expectLater(
        service.commit(preview, preview.defaultActions),
        throwsStateError,
      );
      expect(await fixture.animals.getAllIncludingInactive(), hasLength(2));
    },
  );

  test(
    'a preview cannot be applied through another workspace service',
    () async {
      final service = fixture.importer();
      final preview = await service.preview(csv(service, 'Arete\n0001\n'));
      await expectLater(
        fixture.importer().commit(preview, preview.defaultActions),
        throwsStateError,
      );
    },
  );

  test(
    'a farm change after preview is rejected even when the same importer is reused',
    () async {
      final service = fixture.importer();
      final preview = await service.preview(csv(service, 'Arete\n0001\n'));
      await fixture.context.saveFarm(
        const Farm(uuid: 'farm-2', name: 'Otra finca'),
      );
      await fixture.context.saveMembership(
        const FarmMembership(
          uuid: 'owner-2',
          farmId: 'farm-2',
          userId: 'local-user',
          role: FarmRole.owner,
        ),
      );
      await fixture.context.select('farm-2', 'local-user');
      await expectLater(
        service.commit(preview, preview.defaultActions),
        throwsStateError,
      );
      expect(await fixture.animals.getAllIncludingInactive(), isEmpty);
    },
  );

  test(
    'quoted semicolon headers are detected without trying to parse them as comma CSV',
    () async {
      final service = fixture.importer();
      final preview = await service.preview(
        csv(service, '"Arete";"Nombre";"Sexo"\n"0009";"Luna";"Hembra"\n'),
      );
      expect(preview.rows.single.errors, isEmpty);
      expect(preview.rows.single.proposed!.earTagNumber, '0009');
    },
  );

  test(
    'a visual identifier can be imported as the animal primary identification',
    () async {
      final service = fixture.importer();
      final document = csv(
        service,
        'Identificación visual,Nombre,Sexo\nV-001,Luna,Hembra\n',
      );
      final preview = await service.preview(document);
      expect(preview.invalidCount, 0);
      await service.commit(preview, preview.defaultActions);
      expect((await fixture.animals.getAll()).single.earTagNumber, 'V-001');
      expect((await service.preview(document)).existingCount, 1);
    },
  );

  test(
    'preview rejects unrepresentable identifiers and collisions between proposed primary tags',
    () async {
      final service = fixture.importer();
      final tooManyIds = await service.preview(
        csv(
          service,
          'Arete,SINIIGA,Identificación visual\nLOCAL,000012345678,OTRO\n',
        ),
      );
      expect(tooManyIds.invalidCount, 1);
      final colliding = await service.preview(
        csv(service, 'Arete,RFID\n,RF-001\nRF-001,\n'),
      );
      expect(colliding.invalidCount, 2);
      expect(
        colliding.rows.every(
          (r) => r.errors.any((e) => e.contains('mismo arete')),
        ),
        isTrue,
      );
      expect(await fixture.animals.getAllIncludingInactive(), isEmpty);
    },
  );

  test(
    'an existing RFID and a different animal visual tag can share text without merging the animals',
    () async {
      await fixture.seedLot();
      final animal = (await fixture.animals.getByUuid('a'))!;
      await fixture.animals.update(animal.copyWith(rfidTag: 'RF-001'));
      final service = fixture.importer();
      final preview = await service.preview(
        csv(service, 'Arete,RFID\n,RF-001\nRF-001,\n'),
      );
      expect(preview.invalidCount, 0);
      expect(preview.existingCount, 1);
      expect(preview.newCount, 1);
    },
  );
}
