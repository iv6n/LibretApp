import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:libretapp/core/security/ports/phone_auth_port.dart';
import 'package:libretapp/core/workspace/workspace_manager.dart';
import 'package:libretapp/core/security/services/supabase_phone_auth.dart';
import 'captcha_sheet.dart';
import 'package:libretapp/core/platform/release_features.dart';

Future<void> showPhoneAuth(
  BuildContext context,
  WorkspaceManager manager, {
  bool linkGuest = false,
  PhoneAccessIntent intent = PhoneAccessIntent.createAccount,
}) => showModalBottomSheet<void>(
  context: context,
  useRootNavigator: true,
  isScrollControlled: true,
  useSafeArea: true,
  isDismissible: false,
  enableDrag: false,
  builder: (_) =>
      PhoneAuthSheet(manager: manager, linkGuest: linkGuest, intent: intent),
);

class PhoneAuthSheet extends StatefulWidget {
  const PhoneAuthSheet({
    super.key,
    required this.manager,
    this.linkGuest = false,
    this.intent = PhoneAccessIntent.createAccount,
  });
  final WorkspaceManager manager;
  final bool linkGuest;
  final PhoneAccessIntent intent;
  @override
  State<PhoneAuthSheet> createState() => _PhoneAuthSheetState();
}

class _PhoneAuthSheetState extends State<PhoneAuthSheet> {
  final _phone = TextEditingController();
  final _code = TextEditingController();
  final _otherDial = TextEditingController();
  String _country = 'MX';
  String? _sentPhone;
  String? _error;
  bool _busy = false;
  int _wait = 0;
  Timer? _timer;
  static const _countries = {
    'MX': ('México', '52'),
    'US': ('Estados Unidos / Canadá', '1'),
    'GT': ('Guatemala', '502'),
    'ES': ('España', '34'),
    'OTHER': ('Otro país', ''),
  };

  @override
  void dispose() {
    _timer?.cancel();
    _phone.dispose();
    _code.dispose();
    _otherDial.dispose();
    super.dispose();
  }

  Future<void> _request() async {
    if (_busy || _wait > 0) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final phone =
          _sentPhone ??
          normalizePhone(
            _country == 'OTHER' ? _otherDial.text : _countries[_country]!.$2,
            _phone.text,
          );
      final auth = widget.manager.auth;
      if (auth is SupabasePhoneAuth) {
        if (!RegExp(r'^\+52\d{10}$').hasMatch(phone)) {
          throw const PhoneAuthFailure(
            'Esta versión admite números de México (+52).',
          );
        }
        final token = await requestCaptcha(context);
        if (token == null) return;
        await auth.requestCodeWithCaptcha(phone, token, intent: widget.intent);
      } else {
        await auth.requestCode(phone, intent: widget.intent);
      }
      if (!mounted) return;
      setState(() {
        _sentPhone = phone;
        _wait = 60;
      });
      _timer?.cancel();
      _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        if (!mounted) {
          timer.cancel();
          return;
        }
        setState(() => _wait--);
        if (_wait <= 0) timer.cancel();
      });
    } catch (error) {
      if (mounted) {
        setState(
          () => _error = error is PhoneAuthFailure
              ? error.message
              : 'No se pudo solicitar el código. Intenta de nuevo.',
        );
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _verify() async {
    if (_busy) return;
    if (!RegExp(r'^\d{6}$').hasMatch(_code.text)) {
      setState(() => _error = 'Escribe los 6 dígitos del código.');
      return;
    }
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final identity = await widget.manager.auth.verifyCode(
        _sentPhone!,
        _code.text,
      );
      if (!mounted) return;
      try {
        await widget.manager.openAccount(identity, linkGuest: widget.linkGuest);
      } on WorkspaceConflict {
        if (!mounted) return;
        final open = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Esta cuenta ya tiene registros aquí'),
            content: const Text(
              'Puedes abrir el espacio de la cuenta o regresar a tus registros de invitado. Ambos se conservarán separados.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Seguir como invitado'),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Abrir mi cuenta'),
              ),
            ],
          ),
        );
        if (open == true) {
          await widget.manager.openAccount(identity);
        } else {
          await widget.manager.auth.signOut();
          if (mounted) Navigator.pop(context);
        }
      }
    } catch (error) {
      if (mounted) {
        setState(
          () => _error = error is PhoneAuthFailure
              ? error.message
              : 'No se pudo abrir la cuenta. Tus registros siguen guardados. Intenta de nuevo.',
        );
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final available = widget.manager.auth.available;
    final theme = Theme.of(context);
    return PopScope(
      canPop: !_busy,
      child: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(
          24,
          24,
          24,
          24 + MediaQuery.viewInsetsOf(context).bottom,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    widget.linkGuest
                        ? 'Vincular mi número'
                        : widget.intent == PhoneAccessIntent.createAccount
                        ? 'Crear cuenta con teléfono'
                        : 'Iniciar sesión con teléfono',
                    style: theme.textTheme.titleLarge,
                  ),
                ),
                IconButton(
                  onPressed: _busy ? null : () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                  tooltip: 'Cerrar',
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              widget.linkGuest
                  ? 'Vincular tu número identifica tu cuenta. Tus registros siguen guardados en este teléfono. Conserva un respaldo fuera del dispositivo.'
                  : widget.intent == PhoneAccessIntent.createAccount
                  ? 'Verifica tu número para crear una cuenta. El SMS solo confirma que tienes acceso a ese teléfono.'
                  : 'Escribe el número asociado a tu cuenta. Si no existe, el acceso no creará una cuenta nueva.',
            ),
            const SizedBox(height: 16),
            if (!available)
              const Text(
                'El acceso por teléfono todavía no está disponible. Puedes cerrar esta ventana y entrar como invitado o ver la demo.',
              )
            else if (_sentPhone == null) ...[
              DropdownButtonFormField<String>(
                initialValue: _country,
                isExpanded: true,
                decoration: const InputDecoration(labelText: 'País'),
                items: _countries.entries
                    .where(
                      (entry) =>
                          !ReleaseFeatures.publicRelease || entry.key == 'MX',
                    )
                    .map(
                      (e) => DropdownMenuItem(
                        value: e.key,
                        child: Text(e.value.$1),
                      ),
                    )
                    .toList(),
                onChanged: _busy
                    ? null
                    : (value) => setState(() => _country = value!),
              ),
              if (_country == 'OTHER')
                TextField(
                  controller: _otherDial,
                  enabled: !_busy,
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(3),
                  ],
                  decoration: const InputDecoration(
                    labelText: 'Código de país',
                    prefixText: '+',
                  ),
                ),
              TextField(
                controller: _phone,
                enabled: !_busy,
                keyboardType: TextInputType.phone,
                autofillHints: const [AutofillHints.telephoneNumberNational],
                decoration: InputDecoration(
                  labelText: 'Número de teléfono',
                  prefixText: _country == 'OTHER'
                      ? null
                      : '+${_countries[_country]!.$2} ',
                  helperText: _country == 'MX' ? '10 dígitos, sin +52' : null,
                ),
              ),
              const SizedBox(height: 20),
              FilledButton(
                onPressed: _busy ? null : _request,
                child: const Text('Enviar código por SMS'),
              ),
              const SizedBox(height: 8),
              Text(
                widget.intent == PhoneAccessIntent.createAccount
                    ? 'En otro dispositivo tus registros locales no aparecerán automáticamente.'
                    : 'Si no reconocemos el número, no crearemos una cuenta.',
              ),
            ] else ...[
              Text('Enviamos un código a $_sentPhone.'),
              TextField(
                controller: _code,
                enabled: !_busy,
                keyboardType: TextInputType.number,
                autofillHints: const [AutofillHints.oneTimeCode],
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(6),
                ],
                decoration: const InputDecoration(
                  labelText: 'Código de 6 dígitos',
                ),
              ),
              const SizedBox(height: 20),
              FilledButton(
                onPressed: _busy ? null : _verify,
                child: Text(
                  widget.linkGuest
                      ? 'Verificar y vincular'
                      : 'Verificar y entrar',
                ),
              ),
              TextButton(
                onPressed: _busy || _wait > 0 ? null : _request,
                child: Text(
                  _wait > 0 ? 'Reenviar en $_wait s' : 'Reenviar código',
                ),
              ),
              TextButton(
                onPressed: _busy
                    ? null
                    : () {
                        _timer?.cancel();
                        setState(() {
                          _sentPhone = null;
                          _code.clear();
                          _error = null;
                          _wait = 0;
                        });
                      },
                child: const Text('Corregir número'),
              ),
            ],
            if (_busy)
              const Padding(
                padding: EdgeInsets.all(16),
                child: Center(child: CircularProgressIndicator()),
              ),
            if (_error != null)
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Text(
                  _error!,
                  style: TextStyle(color: theme.colorScheme.error),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
