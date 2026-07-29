/// Minimal email/password sheet for the optional cloud-backup account
/// (Supabase Auth). Only meaningful when cloud backup is configured — see
/// [SupabaseConfig.isConfigured].
library;

import 'package:flutter/material.dart';
import 'package:libretapp/core/di/injection.dart';
import 'package:libretapp/core/security/models/models.dart';
import 'package:libretapp/core/security/ports/ports.dart';
import 'package:libretapp/core/sync/supabase_config.dart';
import 'package:libretapp/theme/app_theme.dart';

class CloudAuthSheet extends StatefulWidget {
  const CloudAuthSheet({super.key});

  @override
  State<CloudAuthSheet> createState() => _CloudAuthSheetState();
}

class _CloudAuthSheetState extends State<CloudAuthSheet> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _loading = false;
  String? _error;
  late bool _signedIn = locator<AuthPort>().currentUserId != null;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit({required bool isSignUp}) async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    final auth = locator<AuthPort>();
    final credentials = AuthCredentials(
      username: _email.text.trim(),
      secret: _password.text,
    );
    final result = isSignUp
        ? await auth.signUp(credentials)
        : await auth.signIn(credentials);
    if (!mounted) return;
    if (result.isSuccess) {
      Navigator.of(context).pop();
    } else {
      setState(() {
        _loading = false;
        _error = result.errorMessage ?? 'No se pudo completar la operación.';
      });
    }
  }

  Future<void> _signOut() async {
    setState(() => _loading = true);
    await locator<AuthPort>().signOut();
    if (!mounted) return;
    setState(() {
      _loading = false;
      _signedIn = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (!SupabaseConfig.isConfigured) {
      return Padding(
        padding: EdgeInsets.fromLTRB(
          16,
          16,
          16,
          MediaQuery.viewInsetsOf(context).bottom + 24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Respaldo en la nube', style: theme.textTheme.titleLarge),
            const SizedBox(height: AppSpacing.sm),
            const Text(
              'Esta compilación no tiene configurado un proyecto de respaldo '
              'en la nube.',
            ),
          ],
        ),
      );
    }

    if (_signedIn) {
      final userId = locator<AuthPort>().currentUserId;
      return Padding(
        padding: EdgeInsets.fromLTRB(
          16,
          16,
          16,
          MediaQuery.viewInsetsOf(context).bottom + 24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Cuenta en la nube', style: theme.textTheme.titleLarge),
            const SizedBox(height: AppSpacing.sm),
            Text('Sesión activa ($userId).'),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: _loading ? null : _signOut,
              child: _loading
                  ? const SizedBox(
                      height: 16,
                      width: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Cerrar sesión'),
            ),
          ],
        ),
      );
    }

    return Padding(
      padding: EdgeInsets.fromLTRB(
        16,
        16,
        16,
        MediaQuery.viewInsetsOf(context).bottom + 24,
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Cuenta en la nube', style: theme.textTheme.titleLarge),
            const SizedBox(height: AppSpacing.sm),
            const Text('Inicia sesión o crea una cuenta para respaldar tus datos.'),
            const SizedBox(height: 16),
            TextFormField(
              controller: _email,
              decoration: const InputDecoration(labelText: 'Correo'),
              keyboardType: TextInputType.emailAddress,
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Requerido' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _password,
              decoration: const InputDecoration(labelText: 'Contraseña'),
              obscureText: true,
              validator: (v) =>
                  (v == null || v.length < 6) ? 'Mínimo 6 caracteres' : null,
            ),
            if (_error != null) ...[
              const SizedBox(height: 12),
              Text(_error!, style: TextStyle(color: theme.colorScheme.error)),
            ],
            const SizedBox(height: 20),
            FilledButton(
              onPressed: _loading ? null : () => _submit(isSignUp: false),
              child: _loading
                  ? const SizedBox(
                      height: 16,
                      width: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Iniciar sesión'),
            ),
            const SizedBox(height: 8),
            OutlinedButton(
              onPressed: _loading ? null : () => _submit(isSignUp: true),
              child: const Text('Crear cuenta'),
            ),
          ],
        ),
      ),
    );
  }
}
