/// Profile header with avatar and ranch identity.
library;

import 'package:flutter/material.dart';
import 'package:libretapp/features/perfil/data/perfil_model.dart';
import 'package:libretapp/features/perfil/data/profile_input.dart';
import 'package:libretapp/features/perfil/widgets/profile_avatar.dart';
import 'package:libretapp/theme/app_theme.dart';

class ProfileHeaderCard extends StatelessWidget {
  const ProfileHeaderCard({required this.perfil, this.onEditTap, super.key});

  final Perfil perfil;
  final VoidCallback? onEditTap;

  String _initials() {
    final n = perfil.nombre.isNotEmpty ? perfil.nombre[0] : '';
    final a = perfil.apellido.isNotEmpty ? perfil.apellido[0] : '';
    return (n + a).toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final hasDetails = hasProfileDetails(perfil);
    final name = perfil.fullName.trim().isEmpty ? 'Mi perfil' : perfil.fullName;

    return Container(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.md,
        AppSpacing.sm,
        AppSpacing.md,
        AppSpacing.md,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primary.withValues(alpha: 0.16),
            AppColors.earth.withValues(alpha: 0.08),
            cs.surface,
          ],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              ProfileAvatar(initials: _initials(), size: 100),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w900,
                        height: 1.05,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      perfil.finca.trim().isEmpty
                          ? 'Ganado y campo'
                          : perfil.finca,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleSmall?.copyWith(
                        color: perfil.finca.trim().isEmpty
                            ? cs.onSurfaceVariant
                            : cs.primary,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (onEditTap != null) ...[
            const SizedBox(height: AppSpacing.sm),
            Align(
              alignment: Alignment.centerLeft,
              child: OutlinedButton.icon(
                onPressed: onEditTap,
                icon: const Icon(Icons.edit_outlined),
                label: Text(
                  hasDetails ? 'Editar perfil' : 'Añadir datos opcionales',
                ),
              ),
            ),
          ],
          if (perfil.upp.isNotEmpty ||
              perfil.email.isNotEmpty ||
              perfil.telefono.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.md),
            Container(
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 8),
              decoration: BoxDecoration(
                color: cs.surface.withValues(alpha: 0.82),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: cs.outlineVariant.withValues(alpha: 0.48),
                ),
              ),
              child: Column(
                children: [
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      if (perfil.upp.isNotEmpty)
                        _IdentityChip(
                          icon: Icons.badge_outlined,
                          label: 'UPP',
                          value: perfil.upp,
                        ),
                      if (perfil.email.isNotEmpty)
                        _IdentityChip(
                          icon: Icons.email_outlined,
                          label: 'Correo',
                          value: perfil.email,
                        ),
                      if (perfil.telefono.isNotEmpty)
                        _IdentityChip(
                          icon: Icons.phone_outlined,
                          label: 'Teléfono',
                          value: perfil.telefono,
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _IdentityChip extends StatelessWidget {
  const _IdentityChip({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      constraints: const BoxConstraints(minWidth: 118, maxWidth: 240),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: AppColors.primary),
          const SizedBox(width: 7),
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  label,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w700,
                    height: 1,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.labelMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    height: 1.1,
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
