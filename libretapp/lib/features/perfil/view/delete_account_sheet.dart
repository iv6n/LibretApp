import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:libretapp/core/backup/backup_operation_lock.dart';
import 'package:libretapp/core/di/injection.dart';
import 'package:libretapp/core/security/services/account_deletion_service.dart';
import 'package:libretapp/core/security/services/supabase_phone_auth.dart';
import 'package:libretapp/core/security/services/supabase_session.dart';
import 'package:libretapp/core/services/backup_service.dart';
import 'package:libretapp/core/workspace/workspace_manager.dart';
import 'package:libretapp/features/onboarding/captcha_sheet.dart';

class DeleteAccountSheet extends StatefulWidget {
  const DeleteAccountSheet({super.key, required this.manager});
  final WorkspaceManager manager;
  @override
  State<DeleteAccountSheet> createState() => _DeleteAccountSheetState();
}
class _DeleteAccountSheetState extends State<DeleteAccountSheet> {
  final _code = TextEditingController();
  bool _busy = false;
  bool _sent = false;
  int _wait = 0;
  Timer? _timer;
  String? _error;
  String get _marker => 'account.deletion.${widget.manager.current?.id}';
  String? get _pending => widget.manager.registry.preferences.getString(_marker);
  @override
  void dispose() { _timer?.cancel(); _code.dispose(); super.dispose(); }

  Future<void> _run(Future<void> Function() action) async {
    if (_busy) return;
    setState(() { _busy = true; _error = null; });
    try { await action(); }
    catch (e) { if (mounted) setState(() => _error = '$e'); }
    finally { if (mounted) setState(() => _busy = false); }
  }
  Future<void> _send() => _run(() async {
    final token = await requestCaptcha(context);
    if (token == null) return;
    final client = await SupabaseSession.client();
    final phone = client.auth.currentUser?.phone;
    if (phone == null || client.auth.currentUser?.id != widget.manager.current?.userId) {
      throw StateError('Vuelve a verificar el teléfono de esta cuenta.');
    }
    final auth = widget.manager.auth;
    if (auth is! SupabasePhoneAuth) throw StateError('Servicio SMS no disponible.');
    await auth.requestCodeWithCaptcha('+$phone', token);
    if (!mounted) return;
    setState(() { _sent = true; _wait = 60; });
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) { timer.cancel(); return; }
      setState(() => _wait--);
      if (_wait <= 0) timer.cancel();
    });
  });
  Future<void> _delete() => _run(() async {
    final pending = _pending;
    if (pending == null) {
      if (!RegExp(r'^\d{6}$').hasMatch(_code.text)) throw StateError('Escribe los seis dígitos del SMS.');
      final client = await SupabaseSession.client();
      final phone = client.auth.currentUser!.phone!;
      final identity = await widget.manager.auth.verifyCode('+$phone', _code.text);
      if (identity.userId != widget.manager.current?.userId) throw StateError('La cuenta no coincide.');
    }
    if (!mounted) return;
    final confirmed = await showDialog<bool>(context: context, builder: (context) => AlertDialog(
      title: const Text('¿Eliminar definitivamente tu cuenta?'),
      content: const Text('Se borrarán tu cuenta, los respaldos remotos y los registros, fotos y copias internas de este espacio en este teléfono. Los archivos exportados debes borrarlos desde su destino. Otros teléfonos pueden conservar datos locales incluso después de eliminar la cuenta remota; bórralos desde cada dispositivo.'),
      actions: [TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar')),
        FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Eliminar definitivamente'))],
    ));
    if (confirmed != true) return;
    final service = AccountDeletionService();
    if (pending == 'remote-complete') {
      await service.resumeLocal(widget.manager);
    } else { await service.delete(widget.manager); }
  });
  @override
  Widget build(BuildContext context) => PopScope(canPop: !_busy,
    child: Padding(padding: EdgeInsets.fromLTRB(24, 24, 24, MediaQuery.viewInsetsOf(context).bottom + 24),
      child: SingleChildScrollView(child: Column(crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min, children: [
        Text('Eliminar cuenta', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 12),
        const Text('Puedes exportar voluntariamente tus datos antes de continuar. La eliminación no se puede deshacer.'),
        OutlinedButton.icon(onPressed: _busy ? null : () => _run(() async {
          await BackupOperationLock().run(() => locator<BackupService>().exportToFile());
        }), icon: const Icon(Icons.save_alt), label: const Text('Exportar antes de eliminar')),
        if (_pending == null) ...[
          const Text('Confirma con un código SMS reciente enviado al teléfono de esta cuenta.'),
          TextButton(onPressed: _busy || _wait > 0 ? null : _send,
            child: Text(_wait > 0 ? 'Reenviar en $_wait s' : 'Enviar código de confirmación')),
          if (_sent) TextField(controller: _code, enabled: !_busy,
            keyboardType: TextInputType.number, autofillHints: const [AutofillHints.oneTimeCode],
            inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(6)],
            decoration: const InputDecoration(labelText: 'Código de 6 dígitos')),
        ] else const Text('Hay una eliminación pendiente. Reintentar continúa la misma solicitud.'),
        const SizedBox(height: 16),
        FilledButton(onPressed: _busy || (!_sent && _pending == null) ? null : _delete,
          child: Text(_pending == null ? 'Confirmar eliminación' : 'Reanudar eliminación')),
        TextButton(onPressed: _busy ? null : () => Navigator.pop(context), child: const Text('Volver')),
        if (_busy) const LinearProgressIndicator(),
        if (_error != null) Text(_error!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
      ])),
    ));
}
