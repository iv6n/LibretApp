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
    final upp = perfil.showUpp ? perfil.upp.trim() : '';
    final copyItems = <_CopyItem>[
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
                    if (perfil.finca.trim().isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        perfil.finca,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.titleSmall?.copyWith(
                          color: cs.primary,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (compactEdit)
                IconButton.filledTonal(
                  tooltip: 'Editar perfil',
                  icon: const Icon(Icons.edit_outlined, size: 20),
                  onPressed: onEditTap,
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
          if (upp.isNotEmpty || copyItems.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.sm),
            _CopyPanel(key: ValueKey(perfil.id), upp: upp, items: copyItems),
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

class _CopyPanel extends StatefulWidget {
  const _CopyPanel({required this.upp, required this.items, super.key});

  final String upp;
  final List<_CopyItem> items;

  @override
  State<_CopyPanel> createState() => _CopyPanelState();
}

class _CopyPanelState extends State<_CopyPanel> {
  bool expanded = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final hasUpp = widget.upp.isNotEmpty;
    final canExpand = widget.items.isNotEmpty;
    final heading = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          hasUpp ? 'Datos para copiar: UPP' : 'Datos para copiar',
          style: theme.textTheme.labelLarge?.copyWith(
            color: cs.onSurfaceVariant,
          ),
        ),
        if (hasUpp)
          Text(
            widget.upp,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w800,
              letterSpacing: 0.5,
            ),
          ),
      ],
    );
    void toggle() => setState(() => expanded = !expanded);
    final toggleLabel = expanded ? 'Ocultar datos' : 'Mostrar datos';
    return Material(
      color: cs.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: cs.outlineVariant),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Tooltip(
                  message: hasUpp ? 'Copiar UPP' : toggleLabel,
                  child: InkWell(
                    onTap: hasUpp
                        ? () => _copy(context, 'UPP', widget.upp)
                        : toggle,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 10,
                      ),
                      child: Row(
                        children: [
                          Expanded(child: heading),
                          if (hasUpp)
                            Icon(
                              Icons.copy_outlined,
                              size: 18,
                              color: cs.primary,
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              if (canExpand)
                IconButton(
                  tooltip: toggleLabel,
                  onPressed: toggle,
                  icon: Icon(expanded ? Icons.expand_less : Icons.expand_more),
                ),
            ],
          ),
          if (expanded && canExpand)
            for (final item in widget.items) ...[
              const Divider(height: 1, indent: 14, endIndent: 14),
              ListTile(
                leading: Icon(item.icon, size: 20),
                title: Text(item.label, style: theme.textTheme.labelMedium),
                subtitle: Text(item.value, style: theme.textTheme.bodyMedium),
                trailing: const Icon(Icons.copy_outlined, size: 18),
                onTap: () => _copy(context, item.label, item.value),
              ),
            ],
        ],
      ),
    );
  }
}

Future<void> _copy(BuildContext context, String label, String value) async {
  await Clipboard.setData(ClipboardData(text: value));
  if (!context.mounted) return;
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text('$label copiado')));
}
