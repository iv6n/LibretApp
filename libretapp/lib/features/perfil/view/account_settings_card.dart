import 'package:flutter/material.dart';
import 'package:libretapp/core/workspace/workspace_manager.dart';
import 'package:libretapp/features/onboarding/phone_auth_sheet.dart';
import 'package:libretapp/core/platform/release_features.dart';
import 'delete_account_sheet.dart';

class AccountSettingsCard extends StatefulWidget {
  const AccountSettingsCard({
    super.key,
    required this.manager,
    this.enabled = true,
  });
  final WorkspaceManager manager;
  final bool enabled;
  @override
  State<AccountSettingsCard> createState() => _AccountSettingsCardState();
}

class _AccountSettingsCardState extends State<AccountSettingsCard> {
  bool _busy = false;
  Future<void> _leave() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cerrar sesión'),
        content: const Text(
          'Tus registros permanecerán en este teléfono. Para volver a abrir esta cuenta necesitarás verificar tu número por SMS.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Cerrar sesión'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    setState(() => _busy = true);
    try {
      await widget.manager.signOut();
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No se pudo cerrar la sesión. Intenta de nuevo.'),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Cuenta', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          Text(
            widget.manager.isDemo
                ? 'La demo utiliza datos ficticios y no puede vincularse a una cuenta.'
                : widget.manager.isGuest
                ? widget.manager.auth.available
                    ? 'Estás usando un espacio de invitado. Puedes vincularlo después sin perder tus registros.'
                    : 'Estás usando un espacio de invitado. Tus registros se guardan en este dispositivo.'
                : 'Cuenta verificada por teléfono${widget.manager.current?.phoneSuffix == null ? '' : ' · termina en ${widget.manager.current!.phoneSuffix}'}.',
          ),
          const SizedBox(height: 8),
          const Text(
            'Los registros permanecen locales. Los respaldos automáticos requieren que los actives en Copias en la nube.',
          ),
          if (widget.manager.isDemo)
            TextButton(
              onPressed: () => widget.manager.exitDemo(),
              child: const Text('Salir de la demo'),
            )
          else if (widget.manager.isGuest && widget.manager.auth.available)
            FilledButton.tonalIcon(
              onPressed: !widget.enabled
                  ? null
                  : () =>
                        showPhoneAuth(context, widget.manager, linkGuest: true),
              icon: const Icon(Icons.phone_android),
              label: const Text('Vincular mi número'),
            )
          else if (!widget.manager.isGuest)
            TextButton(
              onPressed: _busy || !widget.enabled ? null : _leave,
              child: Text(_busy ? 'Cerrando sesión…' : 'Cerrar sesión'),
            ),
          if (ReleaseFeatures.cloudBackupEnabled && !widget.manager.isDemo && !widget.manager.isGuest)
            TextButton.icon(onPressed: _busy || !widget.enabled ? null : () => showModalBottomSheet<void>(
              context: context, useRootNavigator: true, isScrollControlled: true,
              useSafeArea: true, isDismissible: false, enableDrag: false,
              builder: (_) => DeleteAccountSheet(manager: widget.manager)),
              icon: const Icon(Icons.delete_forever_outlined), label: const Text('Eliminar mi cuenta')),
        ],
      ),
    ),
  );
}
