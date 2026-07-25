/// Profile header with avatar and ranch identity.
library;

import 'package:flutter/material.dart';
import 'package:libretapp/features/perfil/data/perfil_model.dart';
import 'package:libretapp/features/perfil/widgets/profile_avatar.dart';
import 'package:libretapp/features/perfil/widgets/profile_info_row.dart';
import 'package:libretapp/theme/app_theme.dart';

class ProfileHeaderCard extends StatelessWidget {
  const ProfileHeaderCard({
    required this.perfil,
    this.onSettingsTap,
    super.key,
  });

  final Perfil perfil;
  final VoidCallback? onSettingsTap;

  String _initials() {
    final n = perfil.nombre.isNotEmpty ? perfil.nombre[0] : '';
    final a = perfil.apellido.isNotEmpty ? perfil.apellido[0] : '';
    return (n + a).toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final name = perfil.fullName.isEmpty ? 'Sin nombre' : perfil.fullName;

    return Container(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.md,
        MediaQuery.of(context).padding.top + AppSpacing.sm,
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
              ProfileAvatar(initials: _initials()),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w900,
                        height: 1.05,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      perfil.finca.isEmpty ? 'Rancho sin nombre' : perfil.finca,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleSmall?.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
              if (onSettingsTap != null) ...[
                const SizedBox(width: AppSpacing.xs),
                DecoratedBox(
                  decoration: BoxDecoration(
                    color: cs.surface.withValues(alpha: 0.78),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: cs.outlineVariant.withValues(alpha: 0.5),
                    ),
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.settings_outlined),
                    tooltip: 'Ajustes',
                    onPressed: onSettingsTap,
                  ),
                ),
              ],
            ],
          ),
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
                    _IdentityChip(
                      icon: Icons.email_outlined,
                      label: 'Correo',
                      value: perfil.email.isEmpty ? 'Sin correo' : perfil.email,
                    ),
                    _IdentityChip(
                      icon: Icons.phone_outlined,
                      label: 'Telefono',
                      value: perfil.telefono.isEmpty
                          ? 'Sin telefono'
                          : perfil.telefono,
                    ),
                  ],
                ),
                if (perfil.upp.isEmpty) ...[
                  const SizedBox(height: 8),
                  const ProfileInfoRow(
                    icon: Icons.info_outline,
                    label: 'Identidad',
                    value: 'Agrega UPP desde ajustes para completar el perfil.',
                    isLast: true,
                  ),
                ],
              ],
            ),
          ),
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
      constraints: const BoxConstraints(minWidth: 118, maxWidth: 190),
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
                  maxLines: 1,
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
