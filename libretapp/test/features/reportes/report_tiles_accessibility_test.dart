import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:libretapp/features/reportes/widgets/report_tiles.dart';
import 'package:libretapp/features/reportes/widgets/summary_metric_card.dart';
import 'package:libretapp/features/reportes/widgets/report_card.dart';

void main() {
  for (final width in [320.0,360.0,412.0]) {
    testWidgets('reports keep all labels at 200 percent, width $width', (tester) async {
      tester.view.physicalSize=Size(width,900); tester.view.devicePixelRatio=1;
      addTearDown(tester.view.resetPhysicalSize); addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(MaterialApp(home:MediaQuery(
        data:MediaQueryData(size:Size(width,900),textScaler:const TextScaler.linear(2)),
        child:const Scaffold(body:SingleChildScrollView(child:Padding(padding:EdgeInsets.all(16),
          child:ReportTiles(children:[
            SummaryMetricCard(label:'Alertas sanitarias',value:'1,000',icon:Icons.medical_services_outlined),
            SummaryMetricCard(label:'Próximos partos',value:'1,000',icon:Icons.pregnant_woman_outlined),
            ReportCard(icon:Icons.table_chart_outlined,title:'Exportar datos',subtitle:'Excel / respaldo'),
          ]),
        ))),
      )));
      await tester.pumpAndSettle();
      expect(tester.takeException(),isNull);
      await tester.ensureVisible(find.text('Excel / respaldo'));
      expect(tester.takeException(),isNull);
    });
  }
}
