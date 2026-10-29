import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:libretapp/app/widgets/app_segmented_tab_bar.dart';
import 'package:libretapp/core/maintenance/data_maintenance.dart';
import 'package:libretapp/core/utils/color_contrast.dart';
import 'package:libretapp/features/perfil/view/data_review_page.dart';
import 'package:libretapp/features/perfil/view/recovery_copies_page.dart';
import 'package:libretapp/features/finanzas/widgets/record_tile.dart';
import 'package:libretapp/theme/app_theme.dart';

class _Maintenance implements DataMaintenance {
  int writes=0;
  @override
  Future<MaintenanceReview> scan() async => const MaintenanceReview('preview',[
    MaintenanceIssue(id:'duplicate',collection:'weightRecords',rowId:2,kind:MaintenanceIssueKind.duplicate,
      title:'Peso duplicado',detail:'Mismo animal, fecha y peso. Conserva el registro original.',canDelete:true),
  ]);
  @override
  Future<String> apply(MaintenanceReview review,List<MaintenanceChange> changes) async { writes++; return 'copy'; }
  @override
  Future<List<RecoverySnapshot>> snapshots() async => [RecoverySnapshot(id:'native-copy',createdAt:DateTime(2026),native:true)];
  @override
  dynamic noSuchMethod(Invocation invocation)=>super.noSuchMethod(invocation);
}

void main() {
  setUpAll(() => initializeDateFormatting('es'));
  test('dark text, metadata, button and selection tokens reach 4.5:1', () {
    final theme=AppTheme.darkTheme;
    final surface=theme.colorScheme.surface;
    expect(textContrast(theme.colorScheme.primary,surface),greaterThanOrEqualTo(4.5));
    expect(textContrast(theme.colorScheme.onSurface,surface),greaterThanOrEqualTo(4.5));
    expect(textContrast(theme.colorScheme.onSurfaceVariant,surface),greaterThanOrEqualTo(4.5));
    expect(textContrast(theme.textButtonTheme.style!.foregroundColor!.resolve({})!,surface),greaterThanOrEqualTo(4.5));
  });
  for(final width in [320.0,360.0,412.0]) {
    for(final dark in [false,true]) {
      testWidgets('selection and finances ${width}dp dark=$dark text200', (tester) async {
        tester.view..physicalSize=Size(width,900)..devicePixelRatio=1;
        addTearDown(tester.view.resetPhysicalSize);addTearDown(tester.view.resetDevicePixelRatio);
        final controller=TabController(length:3,vsync:tester);addTearDown(controller.dispose);
        var deleted=false;
        const imageKey=ValueKey('qa-accessibility');
        await tester.pumpWidget(MaterialApp(theme:dark?AppTheme.darkTheme:AppTheme.lightTheme,
          builder:(context,child)=>MediaQuery(data:MediaQuery.of(context).copyWith(textScaler:const TextScaler.linear(2)),child:child!),
          home:Scaffold(body:RepaintBoundary(key:imageKey,child:ListView(padding:const EdgeInsets.all(12),children:[
            AppSegmentedTabBar(controller:controller,textScale:2,variant:AppSegmentedTabBarVariant.colorAccented,
              items:const [AppSegmentedTabItem(label:'Animales',icon:Icons.pets,accentColor:AppColors.primary),
                AppSegmentedTabItem(label:'Lotes',icon:Icons.group_work,accentColor:AppColors.secondary),
                AppSegmentedTabItem(label:'Cultivos',icon:Icons.grass,accentColor:AppColors.accent)]),
            const SizedBox(height:16),
            RecordTile(title:'Ingreso por venta de leche',date:DateTime(2026,10,19),amount:'1,250.00',currency:'MXN',
              amountColor:AppColors.success,subtitle:'Registro corregido y guardado en el dispositivo.',onDelete:()=>deleted=true),
          ])))));
        await tester.pumpAndSettle();
        final text=tester.widget<Text>(find.text('Animales'));
        final background=(tester.widget<AnimatedContainer>(find.byKey(const ValueKey('segmented_tab_background_0'))).decoration! as BoxDecoration).color!;
        expect(textContrast(text.style!.color!,background),greaterThanOrEqualTo(4.5));
        expect(tester.takeException(),isNull);
        if(width==320 && dark) {
          await tester.runAsync(() async {
          final boundary=tester.renderObject<RenderRepaintBoundary>(find.byKey(imageKey));
          final bitmap=await boundary.toImage(pixelRatio:1);
          final bytes=await bitmap.toByteData(format:ui.ImageByteFormat.png);
          final directory=Directory('artifacts/implementacion-2026-10-19/ui');await directory.create(recursive:true);
          await File('${directory.path}/dark-320-text200.png').writeAsBytes(bytes!.buffer.asUint8List());bitmap.dispose();
          });
        }
        await tester.tap(find.byTooltip('Acciones del movimiento'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Eliminar'));
        await tester.pumpAndSettle();
        expect(deleted,false);
        await tester.tap(find.text('Cancelar'));
        await tester.pumpAndSettle();
        expect(deleted,false);
      });
    }
  }
  testWidgets('cleanup needs selection and final confirmation before writing', (tester) async {
    final service=_Maintenance();
    await tester.pumpWidget(MaterialApp(home:DataReviewPage(service:service)));
    await tester.pumpAndSettle();expect(service.writes,0);
    await tester.tap(find.byType(CheckboxListTile));await tester.pumpAndSettle();expect(service.writes,0);
    await tester.tap(find.text('Revisar 1 cambios seleccionados'));await tester.pumpAndSettle();expect(service.writes,0);
    await tester.tap(find.text('Cancelar'));await tester.pumpAndSettle();expect(service.writes,0);
    await tester.tap(find.text('Revisar 1 cambios seleccionados'));await tester.pumpAndSettle();
    await tester.tap(find.text('Crear copia y aplicar'));await tester.pumpAndSettle();expect(service.writes,1);
  });
  testWidgets('recovery list remains usable at 320dp and text200', (tester) async {
    tester.view..physicalSize=const Size(320,900)..devicePixelRatio=1;
    addTearDown(tester.view.resetPhysicalSize);addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(MaterialApp(theme:AppTheme.darkTheme,
      builder:(context,child)=>MediaQuery(data:MediaQuery.of(context).copyWith(textScaler:const TextScaler.linear(2)),child:child!),
      home:RecoveryCopiesPage(service:_Maintenance())));
    await tester.pumpAndSettle();expect(tester.takeException(),isNull);
    await tester.scrollUntilVisible(find.text('Exportar'),300);
    expect(find.text('Exportar'),findsOneWidget);
    expect(tester.takeException(),isNull);
  });
}
