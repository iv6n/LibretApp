/// Illustrated, themed empty states for the agenda.
library;

import 'package:flutter/material.dart';
import 'package:libretapp/core/widgets/app_button.dart';
import 'package:libretapp/theme/theme.dart';

class AgendaEmptyPanel extends StatelessWidget {
  const AgendaEmptyPanel({
    required this.firstUse,
    required this.onPrimary,
    required this.onSecondary,
    super.key,
  });

  final bool firstUse;
  final VoidCallback onPrimary;
  final VoidCallback onSecondary;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final title = firstUse
        ? 'Tu agenda empieza aquí'
        : 'Hoy no hay actividades';
    final message = firstUse
        ? 'Agrega un animal o una planta para organizar sus cuidados.'
        : 'Programa el próximo cuidado para tus animales o plantas.';

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 440),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: scheme.primaryContainer.withValues(alpha: 0.62),
                borderRadius: BorderRadius.circular(AppRadii.lg),
              ),
              child: Row(
                children: [
                  Icon(
                    firstUse
                        ? Icons.calendar_month_outlined
                        : Icons.check_circle_outline,
                    size: 28,
                    color: scheme.primary,
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          firstUse
                              ? 'Tu agenda está lista'
                              : 'Un día libre de pendientes',
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: scheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xxs),
                        Text(
                          firstUse
                              ? 'Cuando agregues tus animales o plantas, verás aquí sus cuidados.'
                              : 'No hay actividades programadas por ahora.',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: scheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            ExcludeSemantics(
              child: SizedBox(
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
            const SizedBox(height: AppSpacing.lg),
            Text(
              title,
              key: const ValueKey('agenda-empty-title'),
              textAlign: TextAlign.center,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w800,
                color: scheme.onSurface,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              message,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: scheme.onSurfaceVariant,
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
            const SizedBox(height: AppSpacing.xxs),
            TextButton(
              key: const ValueKey('agenda-empty-secondary'),
              onPressed: onSecondary,
              child: Text(
                firstUse ? '¿Cómo funciona?' : 'Ver mis registros',
                style: const TextStyle(decoration: TextDecoration.underline),
              ),
            ),
          ],
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
