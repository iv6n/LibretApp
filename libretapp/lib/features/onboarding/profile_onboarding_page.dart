import 'package:flutter/material.dart';
import 'package:libretapp/core/experience/registration_preferences.dart';
import 'package:libretapp/core/onboarding/profile_onboarding_service.dart';
import 'package:libretapp/core/widgets/app_brand.dart';
import 'package:libretapp/features/directorio/animales/domain/enums/species.dart';
import 'package:libretapp/features/perfil/data/perfil_model.dart';
import 'package:libretapp/features/perfil/data/profile_input.dart';

class ProfileOnboardingPage extends StatefulWidget {
  const ProfileOnboardingPage({
    super.key,
    required this.service,
    required this.registrationPreferences,
    required this.onFinished,
  });

  final ProfileOnboardingService service;
  final RegistrationPreferences registrationPreferences;
  final VoidCallback onFinished;

  @override
  State<ProfileOnboardingPage> createState() => _ProfileOnboardingPageState();
}

class _ProfileOnboardingPageState extends State<ProfileOnboardingPage> {
  final _formKey = GlobalKey<FormState>();
  final _fields = <String, TextEditingController>{
    for (final field in [
      'nombre',
      'apellido',
      'email',
      'telefono',
      'finca',
      'upp',
      'direccion',
    ])
      field: TextEditingController(),
  };
  Perfil? _profile;
  bool _loading = true;
  bool _working = false;
  String? _loadError;
  String? _saveError;
  bool get _includeRanch {
    final preferences = widget.registrationPreferences;
    final livestockSelected = preferences.preferredSpecies.any(
      (species) => species != Species.canine && species != Species.feline,
    );
    final defaultAnimals =
        !preferences.configured &&
        preferences.preferredSpecies.isEmpty &&
        !preferences.includePlants;
    return livestockSelected || defaultAnimals;
  }

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _loadError = null;
    });
    try {
      final profile = await widget.service.load();
      if (!mounted) return;
      final values = profile.toJson();
      for (final entry in _fields.entries) {
        entry.value.text = values[entry.key] as String;
      }
      setState(() => _profile = profile);
    } catch (_) {
      if (mounted) {
        setState(
          () => _loadError =
              'No se pudieron leer tus datos. Puedes reintentar o hacerlo después.',
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  void dispose() {
    for (final controller in _fields.values) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _save() async {
    if (_working || _loading || _profile == null) return;
    if (!(_formKey.currentState?.validate() ?? false)) return;
    FocusScope.of(context).unfocus();
    setState(() {
      _working = true;
      _saveError = null;
    });
    try {
      await widget.service.save(
        _profile!.copyWith(
          nombre: _fields['nombre']!.text,
          apellido: _fields['apellido']!.text,
          email: _fields['email']!.text,
          telefono: _fields['telefono']!.text,
          finca: _fields['finca']!.text,
          upp: _fields['upp']!.text,
          direccion: _fields['direccion']!.text,
        ),
        includeRanch: _includeRanch,
      );
      if (mounted) widget.onFinished();
    } catch (_) {
      if (mounted) {
        setState(
          () => _saveError =
              'No se pudieron guardar tus datos. Intenta de nuevo o elige Ahora no.',
        );
      }
    } finally {
      if (mounted) setState(() => _working = false);
    }
  }

  Future<void> _skip() async {
    if (_working) return;
    FocusScope.of(context).unfocus();
    setState(() => _working = true);
    try {
      await widget.service.skip();
      if (mounted) widget.onFinished();
    } catch (_) {
      // Skipping optional data must not trap the person on this page.
      if (mounted) widget.onFinished();
    } finally {
      if (mounted) setState(() => _working = false);
    }
  }

  void _back() {
    if (_working) return;
    if (MediaQuery.viewInsetsOf(context).bottom > 0) {
      FocusScope.of(context).unfocus();
    } else {
      _skip();
    }
  }

  Widget _field(
    String field,
    String label, {
    TextInputType? keyboard,
    Iterable<String>? autofill,
    String? helper,
    String? Function(String?)? validator,
    int maxLines = 1,
  }) => Padding(
    padding: const EdgeInsets.only(bottom: 14),
    child: TextFormField(
      key: ValueKey('profile-$field'),
      controller: _fields[field],
      enabled: !_working,
      keyboardType: keyboard,
      autofillHints: autofill,
      textCapitalization: field == 'nombre' || field == 'apellido'
          ? TextCapitalization.words
          : TextCapitalization.none,
      textInputAction: maxLines > 1
          ? TextInputAction.newline
          : TextInputAction.next,
      maxLines: maxLines,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        helperText: helper,
        helperMaxLines: 3,
      ),
    ),
  );

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _back();
      },
      child: Scaffold(
        body: SafeArea(
          child: Align(
            alignment: Alignment.topCenter,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      keyboardDismissBehavior:
                          ScrollViewKeyboardDismissBehavior.onDrag,
                      padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Row(
                            children: [
                              const Expanded(
                                child: Align(
                                  alignment: Alignment.centerLeft,
                                  child: AppBrand(height: 28),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: colors.primaryContainer.withValues(
                                    alpha: .45,
                                  ),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  'Opcional',
                                  style: theme.textTheme.labelLarge,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),
                          Text(
                            'Un toque personal',
                            style: theme.textTheme.headlineMedium?.copyWith(
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Comparte solo lo que quieras. Puedes completar o cambiar tus datos después desde Perfil.',
                            style: theme.textTheme.bodyLarge?.copyWith(
                              color: colors.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(height: 20),
                          if (_loading)
                            const Center(
                              child: Padding(
                                padding: EdgeInsets.all(24),
                                child: CircularProgressIndicator(
                                  semanticsLabel: 'Leyendo tu perfil',
                                ),
                              ),
                            )
                          else if (_loadError != null) ...[
                            Semantics(
                              liveRegion: true,
                              child: Text(
                                _loadError!,
                                style: TextStyle(color: colors.error),
                              ),
                            ),
                            TextButton(
                              onPressed: _working ? null : _load,
                              child: const Text('Reintentar'),
                            ),
                          ] else
                            AutofillGroup(
                              child: Form(
                                key: _formKey,
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: [
                                    Row(
                                      children: [
                                        Image.asset(
                                          'assets/images/record_care.webp',
                                          width: 40,
                                          height: 40,
                                          excludeFromSemantics: true,
                                        ),
                                        const SizedBox(width: 10),
                                        Expanded(
                                          child: Text(
                                            'Tus datos',
                                            style: theme.textTheme.titleMedium
                                                ?.copyWith(
                                                  fontWeight: FontWeight.w700,
                                                ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 16),
                                    _field(
                                      'nombre',
                                      'Nombre',
                                      keyboard: TextInputType.name,
                                      autofill: const [AutofillHints.givenName],
                                    ),
                                    _field(
                                      'apellido',
                                      'Apellidos',
                                      keyboard: TextInputType.name,
                                      autofill: const [
                                        AutofillHints.familyName,
                                      ],
                                    ),
                                    _field(
                                      'email',
                                      'Correo',
                                      keyboard: TextInputType.emailAddress,
                                      autofill: const [AutofillHints.email],
                                      helper:
                                          'Dato de contacto. No crea una cuenta.',
                                      validator: validateOptionalProfileEmail,
                                    ),
                                    _field(
                                      'telefono',
                                      'Teléfono',
                                      keyboard: TextInputType.phone,
                                      autofill: const [
                                        AutofillHints.telephoneNumber,
                                      ],
                                      helper:
                                          'Dato de contacto. No verifica ni cambia tu cuenta.',
                                    ),
                                    if (_includeRanch)
                                      Card(
                                        margin: const EdgeInsets.only(top: 4),
                                        clipBehavior: Clip.antiAlias,
                                        child: ExpansionTile(
                                          key: const ValueKey(
                                            'profile-ranch-section',
                                          ),
                                          maintainState: true,
                                          leading: Icon(
                                            Icons.agriculture_outlined,
                                            color: colors.primary,
                                          ),
                                          title: const Text(
                                            'Añadir datos del rancho',
                                          ),
                                          childrenPadding:
                                              const EdgeInsets.fromLTRB(
                                                16,
                                                4,
                                                16,
                                                4,
                                              ),
                                          children: [
                                            _field(
                                              'finca',
                                              'Nombre del rancho',
                                            ),
                                            _field(
                                              'upp',
                                              'UPP',
                                              helper:
                                                  'Si cuentas con una UPP, puedes anotarla aquí.',
                                            ),
                                            _field(
                                              'direccion',
                                              'Dirección',
                                              keyboard: TextInputType.multiline,
                                              autofill: const [
                                                AutofillHints.fullStreetAddress,
                                              ],
                                              maxLines: 3,
                                            ),
                                          ],
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            ),
                          if (_saveError != null)
                            Padding(
                              padding: const EdgeInsets.only(top: 12),
                              child: Semantics(
                                liveRegion: true,
                                child: Text(
                                  _saveError!,
                                  style: TextStyle(color: colors.error),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 12, 24, 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        FilledButton(
                          onPressed: _working || _loading || _loadError != null
                              ? null
                              : _save,
                          style: FilledButton.styleFrom(
                            minimumSize: const Size(0, 52),
                            backgroundColor: colors.primary,
                            foregroundColor: colors.onPrimary,
                          ),
                          child: _working
                              ? SizedBox.square(
                                  dimension: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: colors.onPrimary,
                                    semanticsLabel: 'Guardando tu elección',
                                  ),
                                )
                              : const Text(
                                  'Guardar y empezar',
                                  textAlign: TextAlign.center,
                                ),
                        ),
                        const SizedBox(height: 4),
                        TextButton(
                          onPressed: _working ? null : _skip,
                          child: const Text('Ahora no'),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
