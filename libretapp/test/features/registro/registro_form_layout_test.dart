import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:libretapp/core/widgets/widgets.dart';
import 'package:libretapp/features/ubicaciones/widgets/crop_sheets.dart';
import 'package:libretapp/theme/app_theme.dart';

void main() {
  final forms = [
    (
      style: RecordFormStyle.crop,
      page: const CropFormSheet(locationName: 'Parcela norte'),
      save: 'Crear cultivo',
    ),
    (
      style: RecordFormStyle.harvest,
      page: const HarvestFormSheet(cropName: 'Maíz de temporal'),
      save: 'Guardar cosecha',
    ),
    (
      style: RecordFormStyle.watering,
      page: const CropWateringFormSheet(cropName: 'Maíz de temporal'),
      save: 'Guardar riego',
    ),
    (
      style: RecordFormStyle.cropHealth,
      page: const CropHealthFormSheet(cropName: 'Maíz de temporal'),
      save: 'Guardar',
    ),
    (
      style: RecordFormStyle.task,
      page: const CropTaskFormSheet(cropName: 'Maíz de temporal'),
      save: 'Crear tarea',
    ),
  ];

  for (final dark in [false, true]) {
    for (final form in forms) {
      testWidgets('${form.style.name}: 320dp, texto 2x y teclado, dark=$dark', (
        tester,
      ) async {
        tester.view.physicalSize = const Size(320, 900);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        await tester.pumpWidget(
          MaterialApp(
            theme: dark ? AppTheme.darkTheme : AppTheme.lightTheme,
            builder: (context, child) => MediaQuery(
              data: MediaQuery.of(context).copyWith(
                textScaler: const TextScaler.linear(2),
                viewInsets: const EdgeInsets.only(bottom: 260),
              ),
              child: child!,
            ),
            home: Scaffold(body: form.page),
          ),
        );
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
        expect(
          tester.widget<AppRecordHeader>(find.byType(AppRecordHeader)).style,
          form.style,
        );
        final save = find.widgetWithText(FilledButton, form.save);
        await tester.ensureVisible(save);
        await tester.pumpAndSettle();
        expect(save.hitTestable(), findsOneWidget);
        expect(tester.takeException(), isNull);
        final cancel = find.widgetWithText(OutlinedButton, 'Cancelar');
        await tester.ensureVisible(cancel);
        await tester.pumpAndSettle();
        expect(cancel.hitTestable(), findsOneWidget);
      });
    }
  }

  testWidgets('guardar bloquea acciones y campos mientras está en curso', (
    tester,
  ) async {
    var calls = 0;
    await tester.pumpWidget(
      MaterialApp(
        home: AppFormScaffold(
          title: 'Registrar peso',
          recordStyle: RecordFormStyle.weight,
          saving: true,
          onSave: () => calls++,
          onCancel: () => calls++,
          saveLabel: 'Guardar',
          fields: const [AppTextField(labelText: 'Peso (kg)')],
        ),
      ),
    );
    await tester.pump();
    final save = tester.widget<FilledButton>(find.byType(FilledButton));
    final cancel = tester.widget<OutlinedButton>(find.byType(OutlinedButton));
    expect(save.onPressed, isNull);
    expect(cancel.onPressed, isNull);
    expect(
      tester
          .widgetList<AbsorbPointer>(
            find.ancestor(
              of: find.byType(AppTextField),
              matching: find.byType(AbsorbPointer),
            ),
          )
          .any((pointer) => pointer.absorbing),
      isTrue,
    );
    expect(calls, 0);
  });

  testWidgets('los campos conservan un ancho de lectura en escritorio', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1440, 1000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      MaterialApp(
        home: AppFormScaffold(
          title: 'Registrar peso',
          recordStyle: RecordFormStyle.weight,
          saving: false,
          onSave: () {},
          saveLabel: 'Guardar',
          fields: const [AppTextField(labelText: 'Peso (kg)')],
        ),
      ),
    );
    await tester.pumpAndSettle();
    final field = tester.getRect(find.byType(AppTextField));
    expect(field.width, lessThanOrEqualTo(720));
    expect(field.center.dx, 720);
    expect(tester.takeException(), isNull);
  });
}
