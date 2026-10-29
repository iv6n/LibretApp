library;

import 'package:flutter/material.dart';
import 'release_features.dart';
import 'package:flutter/services.dart';
import 'package:libretapp/core/widgets/widgets.dart';
import 'package:libretapp/theme/app_theme.dart';

class PilotInformationSheet extends StatelessWidget {
  const PilotInformationSheet({super.key});
  static const supportEmail = String.fromEnvironment('LIBRET_SUPPORT_EMAIL');
  static const privacyUrl = String.fromEnvironment('LIBRET_PRIVACY_URL');
  static const responsibleName = String.fromEnvironment('LIBRET_RESPONSIBLE_NAME');

  @override
  Widget build(BuildContext context) => ConstrainedBox(
    constraints: BoxConstraints(
      maxHeight: MediaQuery.sizeOf(context).height * 0.85,
    ),
    child: ListView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      children: [
        const Align(
          alignment: Alignment.centerLeft,
          child: AppBrand(height: 36),
        ),
        const SizedBox(height: AppSpacing.lg),
        const AppPageHeader(title: 'Primeros pasos'),
        const Text(
          '1. Abre Directorio → Animales → Nuevo (+). Puedes empezar con el registro rápido y completar sus datos después.',
        ),
        const SizedBox(height: AppSpacing.sm),
        const Text(
          '2. Abre su perfil y toca Registrar para anotar peso, salud u otra actividad. El resumen y el historial se actualizan al guardar.',
        ),
        const SizedBox(height: AppSpacing.sm),
        const Text(
          '3. En Perfil → Ajustes, exporta un respaldo completo y guárdalo fuera del teléfono. Excel sirve para consultar datos; el respaldo completo conserva también fotos y relaciones.',
        ),
        const SizedBox(height: AppSpacing.lg),
        const AppPageHeader(title: 'Privacidad y datos locales'),
        const Text(
          ReleaseFeatures.cloudBackupEnabled
              ? 'Tus registros y fotografías se guardan en este dispositivo. Si verificas una cuenta por teléfono, Supabase gestiona la sesión y Twilio entrega el SMS. Puedes crear respaldos manuales o activar los automáticos cada 24 horas, solo por Wi-Fi; Android puede aplazarlos. Invitado y demo no suben datos automáticamente. Se conservan hasta cinco copias verificadas de hasta 100 MiB por cuenta. No hay sincronización continua ni pagos.'
              : 'Tus registros, fotografías y datos del rancho se guardan en este dispositivo. El piloto funciona sin conexión como invitado; también puedes explorar la demo. Tú decides cuándo exportar o compartir un archivo y con quién.',
        ),
        const SizedBox(height: AppSpacing.sm),
        const Text(
          'Puedes eliminar registros desde sus pantallas y tu cuenta desde Ajustes, con confirmación SMS reciente. Se eliminan los respaldos remotos y los datos locales del espacio en este teléfono. Otros teléfonos pueden conservar datos locales incluso después de eliminar la cuenta remota; bórralos desde cada dispositivo. Desinstalar elimina los datos locales. Los archivos que hayas exportado se eliminan desde donde los guardaste.',
        ),
        if (privacyUrl.isNotEmpty)
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Política de privacidad completa'),
            subtitle: SelectableText(privacyUrl),
            trailing: IconButton(
              tooltip: 'Copiar enlace',
              icon: const Icon(Icons.copy),
              onPressed: () => _copy(context, privacyUrl),
            ),
          ),
        if (responsibleName.isNotEmpty)
          ListTile(title: const Text('Responsable'), subtitle: SelectableText(responsibleName)),
        if (supportEmail.isNotEmpty)
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Contacto de soporte'),
            subtitle: SelectableText(supportEmail),
            trailing: IconButton(
              tooltip: 'Copiar correo',
              icon: const Icon(Icons.copy),
              onPressed: () => _copy(context, supportEmail),
            ),
          ),
      ],
    ),
  );

  Future<void> _copy(BuildContext context, String value) async {
    await Clipboard.setData(ClipboardData(text: value));
    if (context.mounted)
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Copiado')));
  }
}
