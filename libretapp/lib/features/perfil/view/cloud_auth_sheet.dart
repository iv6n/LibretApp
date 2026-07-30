/// Email/password account controls for optional cloud backups.
library;

import 'package:flutter/material.dart';
import 'package:libretapp/core/backup/supabase_config.dart';
import 'package:libretapp/core/di/injection.dart';
import 'package:libretapp/core/security/models/models.dart';
import 'package:libretapp/core/security/ports/auth_port.dart';

class CloudAuthSheet extends StatefulWidget {
  const CloudAuthSheet({super.key});

  @override
  State<CloudAuthSheet> createState() => _CloudAuthSheetState();
}

class _CloudAuthSheetState extends State<CloudAuthSheet> {
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _busy = false;
  String? _message;

  AuthPort get _auth => locator<AuthPort>();

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit({required bool create}) async {
    if (_email.text.trim().isEmpty || _password.text.isEmpty) {
      setState(() => _message = 'Escribe correo y contraseña.');
      return;
    }
    setState(() {
      _busy = true;
      _message = null;
    });
    final credentials = AuthCredentials(
      username: _email.text.trim(),
      secret: _password.text,
    );
    final result = create
        ? await _auth.signUp(credentials)
        : await _auth.signIn(credentials);
    if (!mounted) return;
    setState(() {
      _busy = false;
      _message = result.isSuccess
          ? 'Sesión iniciada.'
          : result.errorMessage ?? 'No se pudo continuar.';
    });
  }

  Future<void> _signOut() async {
    setState(() => _busy = true);
    await _auth.signOut();
    if (!mounted) return;
    setState(() {
      _busy = false;
      _message = 'Sesión cerrada.';
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!SupabaseConfig.isConfigured) {
      return const Padding(
        padding: EdgeInsets.all(24),
        child: Text(
          'Esta compilación no tiene configurado un proyecto de respaldo '
          'en la nube.',
        ),
      );
    }
    final signedIn = _auth.currentUserId != null;
    return Padding(
      padding: EdgeInsets.fromLTRB(
        24,
        24,
        24,
        MediaQuery.viewInsetsOf(context).bottom + 24,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Cuenta de respaldo',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              signedIn
                  ? 'Sesión activa: ${_auth.currentUserId}'
                  : 'Tu cuenta protege y separa tus copias en la nube.',
            ),
            if (!signedIn) ...[
              const SizedBox(height: 20),
              TextField(
                controller: _email,
                keyboardType: TextInputType.emailAddress,
                autofillHints: const [AutofillHints.email],
                decoration: const InputDecoration(labelText: 'Correo'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _password,
                obscureText: true,
                autofillHints: const [AutofillHints.password],
                decoration: const InputDecoration(labelText: 'Contraseña'),
              ),
            ],
            if (_message != null) ...[
              const SizedBox(height: 12),
              Text(_message!),
            ],
            const SizedBox(height: 20),
            if (_busy)
              const Center(child: CircularProgressIndicator())
            else if (signedIn)
              OutlinedButton(
                onPressed: _signOut,
                child: const Text('Cerrar sesión'),
              )
            else ...[
              FilledButton(
                onPressed: () => _submit(create: false),
                child: const Text('Iniciar sesión'),
              ),
              TextButton(
                onPressed: () => _submit(create: true),
                child: const Text('Crear cuenta'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
