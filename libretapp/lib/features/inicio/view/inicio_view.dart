import 'package:flutter/material.dart';
import 'package:libretapp/app/app_shell.dart';
import 'package:libretapp/features/inicio/widgets/widgets.dart';

class InicioView extends StatelessWidget {
  const InicioView({super.key});

  @override
  Widget build(BuildContext context) {
    final bottomInset = AppShell.bottomSafePadding(context);

    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(16, 16, 16, bottomInset + 2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          Text(
            'Bienvenido a LIBRETAPP',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 8),
          Text(
            'Sistema Integral Ganadero',
            style: Theme.of(
              context,
            ).textTheme.bodyLarge?.copyWith(color: Colors.grey),
          ),
          const SizedBox(height: 32),
          const QuickActions(),
          const SizedBox(height: 24),
          const DashboardCard(
            icon: Icons.pets,
            title: 'Animales',
            subtitle: 'Gestiona tu rebaño',
            count: '8',
          ),
          const SizedBox(height: 16),
          const DashboardCard(
            icon: Icons.event,
            title: 'Eventos',
            subtitle: 'Próximas actividades',
            count: '3',
          ),
          const SizedBox(height: 16),
          const DashboardCard(
            icon: Icons.location_on,
            title: 'Ubicaciones',
            subtitle: 'Potreros y espacios',
            count: '4',
          ),
        ],
      ),
    );
  }
}
