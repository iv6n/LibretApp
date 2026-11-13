/// One clear action for an empty agenda.
library;

import 'package:flutter/material.dart';
import 'package:libretapp/core/widgets/app_button.dart';
import 'package:libretapp/theme/theme.dart';

class AgendaEmptyPanel extends StatelessWidget {
  const AgendaEmptyPanel({
    required this.firstUse,
    required this.onPrimary,
    super.key,
  });

  final bool firstUse;
  final VoidCallback onPrimary;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 440),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ExcludeSemantics(
                child: Center(
                  child: SizedBox(
                    key: const ValueKey('agenda-empty-illustration'),
                    width: 206,
                    height: 126,
                    child: CustomPaint(
                      painter: _AgendaIllustrationPainter(
                        firstUse: firstUse,
                        main: scheme.primary,
                        pale: scheme.primaryContainer,
                        muted: scheme.onSurfaceVariant,
                        paper: scheme.surface,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              Semantics(
                header: true,
                child: Text(
                  firstUse
                      ? 'Tu agenda empieza aquí'
                      : 'Hoy no hay actividades',
                  key: const ValueKey('agenda-empty-title'),
                  textAlign: TextAlign.center,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              AppButton(
                key: const ValueKey('agenda-empty-primary'),
                label: firstUse ? 'Agregar' : 'Programar actividad',
                icon: Icons.add,
                expanded: true,
                onPressed: onPrimary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AgendaIllustrationPainter extends CustomPainter {
  const _AgendaIllustrationPainter({
    required this.firstUse,
    required this.main,
    required this.pale,
    required this.muted,
    required this.paper,
  });

  final bool firstUse;
  final Color main;
  final Color pale;
  final Color muted;
  final Color paper;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.scale(size.width / 206, size.height / 126);
    final soft = Paint()..color = pale.withValues(alpha: 0.55);
    canvas.drawOval(const Rect.fromLTWH(26, 10, 154, 108), soft);

    final stroke = Paint()
      ..color = muted.withValues(alpha: 0.48)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round;
    final leaf = Paint()..color = muted.withValues(alpha: 0.5);
    _sprig(canvas, const Offset(28, 105), false, stroke, leaf);
    _sprig(canvas, const Offset(178, 105), true, stroke, leaf);

    final shadow = Paint()..color = muted.withValues(alpha: 0.14);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(63, 34, 84, 79),
        const Radius.circular(10),
      ),
      shadow,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(59, 30, 84, 79),
        const Radius.circular(10),
      ),
      Paint()..color = paper,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(59, 30, 84, 79),
        const Radius.circular(10),
      ),
      Paint()
        ..color = muted.withValues(alpha: 0.3)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(59, 30, 84, 16),
        const Radius.circular(9),
      ),
      Paint()..color = muted.withValues(alpha: 0.58),
    );
    for (final x in [76.0, 124.0]) {
      canvas.drawLine(
        Offset(x, 25),
        Offset(x, 35),
        Paint()
          ..color = main
          ..strokeWidth = 5
          ..strokeCap = StrokeCap.round,
      );
    }
    canvas.drawLine(const Offset(100, 13), const Offset(100, 19), stroke);

    if (firstUse) {
      final mark = Paint()..color = main;
      canvas.drawCircle(const Offset(84, 77), 8, mark);
      for (final point in const [
        Offset(75, 63),
        Offset(84, 59),
        Offset(94, 61),
        Offset(99, 69),
      ]) {
        canvas.drawCircle(point, 3.3, mark);
      }
      final leafPath = Path()
        ..moveTo(109, 98)
        ..quadraticBezierTo(98, 73, 128, 54)
        ..quadraticBezierTo(134, 79, 109, 98);
      canvas.drawPath(leafPath, Paint()..color = main.withValues(alpha: 0.78));
      canvas.drawLine(
        const Offset(107, 103),
        const Offset(124, 64),
        Paint()
          ..color = pale
          ..strokeWidth = 2,
      );
    } else {
      canvas.drawCircle(const Offset(101, 75), 19, Paint()..color = main);
      final plus = Paint()
        ..color = paper
        ..strokeWidth = 3.5
        ..strokeCap = StrokeCap.round;
      canvas.drawLine(const Offset(91, 75), const Offset(111, 75), plus);
      canvas.drawLine(const Offset(101, 65), const Offset(101, 85), plus);
    }
    canvas.restore();
  }

  void _sprig(
    Canvas canvas,
    Offset base,
    bool mirrored,
    Paint stroke,
    Paint leaf,
  ) {
    final sign = mirrored ? -1.0 : 1.0;
    canvas.drawLine(base, base + Offset(9 * sign, -42), stroke);
    for (final item in const [(2.0, -16.0), (8.0, -29.0), (12.0, -40.0)]) {
      final x = item.$1 * sign;
      final y = item.$2;
      canvas.drawOval(
        Rect.fromCenter(center: base + Offset(x, y), width: 11, height: 20),
        leaf,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _AgendaIllustrationPainter oldDelegate) =>
      oldDelegate.firstUse != firstUse ||
      oldDelegate.main != main ||
      oldDelegate.pale != pale ||
      oldDelegate.muted != muted ||
      oldDelegate.paper != paper;
}
