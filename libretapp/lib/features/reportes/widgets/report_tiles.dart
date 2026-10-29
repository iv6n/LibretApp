import 'package:flutter/material.dart';
import 'package:libretapp/theme/app_theme.dart';

/// Natural height tiles keep labels readable with large system text.
class ReportTiles extends StatelessWidget {
  const ReportTiles({super.key, required this.children});
  final List<Widget> children;
  @override
  Widget build(BuildContext context) => LayoutBuilder(builder: (context, constraints) {
    final columns = constraints.maxWidth >= 340 && MediaQuery.textScalerOf(context).scale(1) < 1.4 ? 2 : 1;
    final width = (constraints.maxWidth - AppSpacing.sm * (columns - 1)) / columns;
    return Wrap(spacing: AppSpacing.sm, runSpacing: AppSpacing.sm,
      children: children.map((child) => SizedBox(width: width, child: child)).toList());
  });
}
