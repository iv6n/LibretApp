/// Profile header with avatar and ranch identity.
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
    final compactEdit =
        hasDetails &&
        onEditTap != null &&
        MediaQuery.textScalerOf(context).scale(1) < 1.4;
    final copyItems = <_CopyItem>[
      if (perfil.showUpp && perfil.upp.trim().isNotEmpty)
        _CopyItem(Icons.badge_outlined, 'UPP', perfil.upp.trim()),
      if (perfil.showTelefono && perfil.telefono.trim().isNotEmpty)
        _CopyItem(Icons.phone_outlined, 'Teléfono', perfil.telefono.trim()),
      if (perfil.showEmail && perfil.email.trim().isNotEmpty)
        _CopyItem(Icons.email_outlined, 'Correo', perfil.email.trim()),
      if (perfil.showDireccion && perfil.direccion.trim().isNotEmpty)
        _CopyItem(
          Icons.location_on_outlined,
          'Dirección',
          perfil.direccion.trim(),
        ),
    ];

    return Container(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.md,
        AppSpacing.xs,
        AppSpacing.md,
        AppSpacing.sm,
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
              ProfileAvatar(initials: _initials(), size: 60),
              const SizedBox(width: AppSpacing.sm),
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
                    if (compactEdit)
                      TextButton.icon(
                        onPressed: onEditTap,
                        style: TextButton.styleFrom(
                          alignment: Alignment.centerLeft,
                          padding: EdgeInsets.zero,
                          minimumSize: const Size(0, 48),
                        ),
                        icon: const Icon(Icons.edit_outlined, size: 18),
                        label: const Text('Editar perfil'),
                      ),
                  ],
                ),
              ),
            ],
          ),
          if (onEditTap != null && !compactEdit) ...[
            const SizedBox(height: AppSpacing.xs),
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
          if (copyItems.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.sm),
            Container(
              decoration: BoxDecoration(
                color: cs.surface.withValues(alpha: 0.92),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: cs.outlineVariant.withValues(alpha: 0.48),
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Material(
                  color: Colors.transparent,
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final pairQuickItems =
                          copyItems.length >= 2 &&
                          copyItems[0].label == 'UPP' &&
                          copyItems[1].label == 'Teléfono' &&
                          constraints.maxWidth >= 320 &&
                          MediaQuery.textScalerOf(context).scale(1) < 1.4;
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Padding(
                            padding: const EdgeInsets.fromLTRB(14, 12, 14, 6),
                            child: Text(
                              'Datos para copiar',
                              style: theme.textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                          if (pairQuickItems)
                            Padding(
                              padding: const EdgeInsets.fromLTRB(12, 0, 12, 2),
                              child: IntrinsicHeight(
                                child: Row(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: [
                                    Expanded(
                                      child: _CopyInfoRow(
                                        item: copyItems[0],
                                        compact: true,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: _CopyInfoRow(
                                        item: copyItems[1],
                                        compact: true,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          for (
                            var i = pairQuickItems ? 2 : 0;
                            i < copyItems.length;
                            i++
                          ) ...[
                            if (i > 0 && !(pairQuickItems && i == 2))
                              Divider(
                                height: 1,
                                indent: 14,
                                endIndent: 14,
                                color: cs.outlineVariant.withValues(
                                  alpha: 0.55,
                                ),
                              ),
                            _CopyInfoRow(item: copyItems[i]),
                          ],
                        ],
                      );
                    },
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _CopyItem {
  const _CopyItem(this.icon, this.label, this.value);

  final IconData icon;
  final String label;
  final String value;
}

class _CopyInfoRow extends StatelessWidget {
  const _CopyInfoRow({required this.item, this.compact = false});

  final _CopyItem item;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    return Semantics(
      button: true,
      excludeSemantics: true,
      label: 'Copiar ${item.label}: ${item.value}',
      child: Tooltip(
        message: 'Copiar ${item.label}',
        child: Material(
          color: compact
              ? cs.primaryContainer.withValues(alpha: 0.38)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () async {
              await Clipboard.setData(ClipboardData(text: item.value));
              if (!context.mounted) return;
              ScaffoldMessenger.of(context)
                ..hideCurrentSnackBar()
                ..showSnackBar(
                  SnackBar(content: Text('${item.label} copiado')),
                );
            },
            child: ConstrainedBox(
              constraints: const BoxConstraints(minHeight: 56),
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: compact ? 10 : 14,
                  vertical: compact ? 8 : 9,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        Icon(item.icon, size: 18, color: cs.primary),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            item.label,
                            style: theme.textTheme.labelMedium?.copyWith(
                              color: cs.onSurfaceVariant,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        Icon(Icons.copy_outlined, size: 18, color: cs.primary),
                      ],
                    ),
                    const SizedBox(height: 3),
                    Text(
                      item.value,
                      softWrap: true,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
