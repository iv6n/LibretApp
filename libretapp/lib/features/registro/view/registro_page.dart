import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:libretapp/core/router/app_routes.dart';
import 'package:libretapp/theme/app_theme.dart';

class RegistroPage extends StatelessWidget {
  const RegistroPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Nuevo registro'), elevation: 0),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text('¿Qué deseas registrar?', style: theme.textTheme.titleMedium),
          const SizedBox(height: 4),
          Text(
            'Selecciona el tipo de registro que quieres crear.',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 20),
          const _SectionLabel(label: 'Inventario'),
          const SizedBox(height: 8),
          _RegistroTile(
            icon: Icons.pets,
            label: 'Nuevo animal',
            subtitle: 'Agregar un animal al directorio',
            color: AppColors.primary,
            onTap: () => context.goNamed(AppRoutes.nameAnimalNuevo),
          ),
          _RegistroTile(
            icon: Icons.groups,
            label: 'Nuevo lote',
            subtitle: 'Crear un lote o grupo de animales',
            color: AppColors.secondary,
            onTap: () => context.goNamed(AppRoutes.nameLoteNuevo),
          ),
          const SizedBox(height: 16),
          const _SectionLabel(label: 'Registros de animal'),
          const SizedBox(height: 8),
          _RegistroTile(
            icon: Icons.medical_services,
            label: 'Registro sanitario',
            subtitle: 'Vacuna, desparasitación, tratamiento',
            color: Colors.teal,
            onTap: () => context.pushNamed(AppRoutes.nameRegistroSanitario),
          ),
          _RegistroTile(
            icon: Icons.monitor_weight,
            label: 'Registro de peso',
            subtitle: 'Pesaje en báscula o estimado',
            color: Colors.green,
            onTap: () => context.pushNamed(AppRoutes.nameRegistroPeso),
          ),
          _RegistroTile(
            icon: Icons.analytics,
            label: 'Registro de producción',
            subtitle: 'Pesaje, ganancia, condición corporal',
            color: Colors.blue,
            onTap: () => context.pushNamed(AppRoutes.nameRegistroProduccion),
          ),
          _RegistroTile(
            icon: Icons.favorite,
            label: 'Registro reproductivo',
            subtitle: 'Servicio, inseminación, parición',
            color: Colors.pink,
            onTap: () => context.pushNamed(AppRoutes.nameRegistroReproduccion),
          ),
          _RegistroTile(
            icon: Icons.store,
            label: 'Registro comercial',
            subtitle: 'Compra, venta, cambio de dueño',
            color: Colors.purple,
            onTap: () => context.pushNamed(AppRoutes.nameRegistroComercial),
          ),
          _RegistroTile(
            icon: Icons.drive_eta,
            label: 'Movimiento / Ubicación',
            subtitle: 'Traslado, rotación, reubicación',
            color: Colors.indigo,
            onTap: () => context.pushNamed(AppRoutes.nameRegistroMovimiento),
          ),
          _RegistroTile(
            icon: Icons.payments,
            label: 'Registro de costo',
            subtitle: 'Medicamento, alimentación, mano de obra',
            color: Colors.brown,
            onTap: () => context.pushNamed(AppRoutes.nameRegistroCosto),
          ),
          const SizedBox(height: 16),
          const _SectionLabel(label: 'Agenda'),
          const SizedBox(height: 8),
          _RegistroTile(
            icon: Icons.event,
            label: 'Nuevo evento',
            subtitle: 'Agendar actividad en el calendario',
            color: AppColors.accent,
            onTap: () {
              context.pop();
              context.push(AppRoutes.eventos);
            },
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: Theme.of(context).textTheme.labelLarge?.copyWith(
        color: Theme.of(context).colorScheme.primary,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}

class _RegistroTile extends StatelessWidget {
  const _RegistroTile({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: theme.colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            child: Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: color, size: 22),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(label, style: theme.textTheme.titleSmall),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.chevron_right,
                  size: 20,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
