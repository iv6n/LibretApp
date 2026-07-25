/// Ranch summary card with KPI grid and vector landscape illustration.
library;

import 'package:flutter/material.dart';
import 'package:libretapp/features/inicio/data/inicio_dashboard_models.dart';
import 'package:libretapp/theme/app_theme.dart';

class RanchSummaryCard extends StatelessWidget {
  const RanchSummaryCard({required this.data, super.key});

  final InicioDashboardData data;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: cs.outlineVariant.withValues(alpha: 0.55),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 14,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 10),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'Resumen del rancho',
                    style: tt.titleSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF174332),
                    ),
                  ),
                ),
                Text(
                  '${data.totalAnimals} animales',
                  style: tt.labelSmall?.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Row(
              children: [
                Expanded(
                  child: _RanchKpiTile(
                    label: 'Animales',
                    value: '${data.totalAnimals}',
                    icon: Icons.pets_outlined,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _RanchKpiTile(
                    label: 'Capacidad',
                    value: '${data.totalAnimalCapacity}',
                    icon: Icons.square_foot_outlined,
                    color: AppColors.secondary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Row(
              children: [
                Expanded(
                  child: _RanchKpiTile(
                    label: 'Lotes',
                    value: '${data.activeLotes}',
                    icon: Icons.layers_outlined,
                    color: AppColors.accent,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _RanchKpiTile(
                    label: 'Ubicaciones',
                    value: '${data.totalLocations}',
                    icon: Icons.location_on_outlined,
                    color: const Color(0xFF5A8F6B),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          const SizedBox(
            height: 118,
            width: double.infinity,
            child: RanchLandscapeIllustration(),
          ),
        ],
      ),
    );
  }
}

class _RanchKpiTile extends StatelessWidget {
  const _RanchKpiTile({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: 0.18)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: tt.titleLarge?.copyWith(
                    color: color,
                    fontWeight: FontWeight.w800,
                    height: 1,
                  ),
                ),
                Text(
                  label,
                  style: tt.labelSmall?.copyWith(
                    color: const Color(0xFF455A50),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Soft vector-style ranch landscape (hills, barn, sun, trees).
class RanchLandscapeIllustration extends StatelessWidget {
  const RanchLandscapeIllustration({super.key});

  @override
  Widget build(BuildContext context) {
    return const CustomPaint(
      painter: _RanchLandscapePainter(),
      child: SizedBox.expand(),
    );
  }
}

class _RanchLandscapePainter extends CustomPainter {
  const _RanchLandscapePainter();

  @override
  void paint(Canvas canvas, Size size) {
    final sky = Rect.fromLTWH(0, 0, size.width, size.height);
    final skyPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFFB9D9F2), Color(0xFFE8F4EA)],
      ).createShader(sky);
    canvas.drawRect(sky, skyPaint);

    final sunPaint = Paint()..color = const Color(0xFFF2C94C);
    canvas.drawCircle(Offset(size.width * 0.82, size.height * 0.22), 14, sunPaint);

    final backHill = Path()
      ..moveTo(0, size.height * 0.72)
      ..quadraticBezierTo(
        size.width * 0.25,
        size.height * 0.48,
        size.width * 0.52,
        size.height * 0.66,
      )
      ..quadraticBezierTo(
        size.width * 0.78,
        size.height * 0.82,
        size.width,
        size.height * 0.58,
      )
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(backHill, Paint()..color = const Color(0xFF7BAF84));

    final frontHill = Path()
      ..moveTo(0, size.height * 0.82)
      ..quadraticBezierTo(
        size.width * 0.35,
        size.height * 0.62,
        size.width * 0.68,
        size.height * 0.78,
      )
      ..quadraticBezierTo(
        size.width * 0.88,
        size.height * 0.88,
        size.width,
        size.height * 0.74,
      )
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(frontHill, Paint()..color = const Color(0xFF5F9468));

    _drawBarn(canvas, Offset(size.width * 0.42, size.height * 0.52));
    _drawTree(canvas, Offset(size.width * 0.18, size.height * 0.58));
    _drawTree(canvas, Offset(size.width * 0.72, size.height * 0.56), scale: 0.85);
    _drawFence(canvas, size);
  }

  void _drawBarn(Canvas canvas, Offset origin) {
    final body = RRect.fromRectAndRadius(
      Rect.fromLTWH(origin.dx - 28, origin.dy, 56, 34),
      const Radius.circular(3),
    );
    canvas.drawRRect(body, Paint()..color = const Color(0xFFB56A45));

    final roof = Path()
      ..moveTo(origin.dx - 34, origin.dy)
      ..lineTo(origin.dx, origin.dy - 22)
      ..lineTo(origin.dx + 34, origin.dy)
      ..close();
    canvas.drawPath(roof, Paint()..color = const Color(0xFF8D4E31));

    canvas.drawRect(
      Rect.fromLTWH(origin.dx - 8, origin.dy + 12, 16, 22),
      Paint()..color = const Color(0xFF6D3C24),
    );
  }

  void _drawTree(Canvas canvas, Offset base, {double scale = 1}) {
    final trunkPaint = Paint()..color = const Color(0xFF7B4B2A);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(base.dx, base.dy + 8 * scale),
          width: 8 * scale,
          height: 18 * scale,
        ),
        Radius.circular(2 * scale),
      ),
      trunkPaint,
    );

    canvas.drawCircle(
      Offset(base.dx, base.dy - 4 * scale),
      14 * scale,
      Paint()..color = const Color(0xFF4F8B57),
    );
    canvas.drawCircle(
      Offset(base.dx - 8 * scale, base.dy + 2 * scale),
      10 * scale,
      Paint()..color = const Color(0xFF5F9A67),
    );
    canvas.drawCircle(
      Offset(base.dx + 8 * scale, base.dy + 2 * scale),
      10 * scale,
      Paint()..color = const Color(0xFF5F9A67),
    );
  }

  void _drawFence(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFD8C3A5)
      ..strokeWidth = 2.2
      ..style = PaintingStyle.stroke;

    final y = size.height * 0.86;
    canvas.drawLine(Offset(size.width * 0.08, y), Offset(size.width * 0.92, y), paint);

    for (var x = size.width * 0.12; x < size.width * 0.9; x += 18) {
      canvas.drawLine(Offset(x, y - 10), Offset(x, y + 4), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
