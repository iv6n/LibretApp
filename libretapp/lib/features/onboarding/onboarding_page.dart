import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:libretapp/core/experience/app_experience.dart';
import 'package:libretapp/core/router/app_routes.dart';
import 'package:libretapp/core/widgets/app_brand.dart';
import 'package:libretapp/theme/app_theme.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({
    super.key,
    required this.onStartEmpty,
    required this.onInstallDemo,
    this.onCreatePhone,
    this.onSignInPhone,
    this.onProgress,
    this.initialPage = 0,
    this.initialError,
  });

  final Future<void> Function() onStartEmpty;
  final Future<void> Function(AppExperience experience) onInstallDemo;
  final Future<void> Function()? onCreatePhone;
  final Future<void> Function()? onSignInPhone;
  final Future<void> Function(int page)? onProgress;

  /// The two welcome screens use indexes 0 and 1.
  final int initialPage;
  final String? initialError;

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  static const _green = AppColors.primary;
  static const _sage = AppColors.sage;
  static const _warmBorder = LightColors.border;

  late int _page = widget.initialPage.clamp(0, 1);
  late String? _error = widget.initialError;
  bool _working = false;

  bool get _hasPhoneAccess =>
      widget.onCreatePhone != null || widget.onSignInPhone != null;

  Future<void> _goTo(int page) async {
    if (_working) return;
    final destination = page.clamp(0, 1);
    if (destination == _page) return;
    setState(() {
      _working = true;
      _error = null;
    });
    try {
      await widget.onProgress?.call(destination);
      if (mounted) setState(() => _page = destination);
    } catch (_) {
      if (mounted) {
        setState(
          () => _error = 'No se pudo guardar tu avance. Intenta de nuevo.',
        );
      }
    } finally {
      if (mounted) setState(() => _working = false);
    }
  }

  Future<void> _choose(
    Future<void> Function() action, {
    bool demo = false,
    bool navigate = true,
  }) async {
    if (_working) return;
    setState(() {
      _working = true;
      _error = null;
    });
    try {
      await action();
      if (mounted && navigate) context.go(AppRoutes.inicio);
    } catch (_) {
      if (mounted) {
        setState(
          () => _error = demo
              ? 'No se pudieron preparar los ejemplos. Intenta de nuevo.'
              : 'No se pudo abrir el espacio. Tus registros siguen guardados. Intenta de nuevo.',
        );
      }
    } finally {
      if (mounted) setState(() => _working = false);
    }
  }

  Future<void> _openPhoneAccess() async {
    if (_working || !_hasPhoneAccess) return;
    final choice = await showModalBottomSheet<_PhoneAccess>(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Accede con tu teléfono',
                style: Theme.of(
                  sheetContext,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 8),
              if (widget.onCreatePhone != null)
                ListTile(
                  leading: const Icon(Icons.person_add_alt_1_outlined),
                  title: const Text('Crear cuenta'),
                  onTap: () => Navigator.pop(sheetContext, _PhoneAccess.create),
                ),
              if (widget.onSignInPhone != null)
                ListTile(
                  leading: const Icon(Icons.login_outlined),
                  title: const Text('Ya tengo cuenta'),
                  onTap: () => Navigator.pop(sheetContext, _PhoneAccess.signIn),
                ),
            ],
          ),
        ),
      ),
    );
    if (!mounted || choice == null) return;
    final action = choice == _PhoneAccess.create
        ? widget.onCreatePhone
        : widget.onSignInPhone;
    if (action != null) await _choose(action, navigate: false);
  }

  @override
  Widget build(BuildContext context) {
    final baseTheme = Theme.of(context);
    final theme = baseTheme;
    final reducedMotion = MediaQuery.disableAnimationsOf(context);

    return Theme(
      data: theme,
      child: PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, _) {
          if (!didPop && _page == 1) _goTo(0);
        },
        child: Scaffold(
          body: SafeArea(
            child: LayoutBuilder(
              builder: (context, viewport) => Align(
                alignment: Alignment.topCenter,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 480),
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(24, 10, 24, 12),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight: math.max(0, viewport.maxHeight - 22),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              _header(context),
                              SizedBox(height: _page == 0 ? 22 : 12),
                              AnimatedSwitcher(
                                duration: Duration(
                                  milliseconds: reducedMotion ? 0 : 240,
                                ),
                                switchInCurve: Curves.easeOut,
                                switchOutCurve: Curves.easeIn,
                                transitionBuilder: (child, animation) =>
                                    FadeTransition(
                                      opacity: animation,
                                      child: child,
                                    ),
                                child: KeyedSubtree(
                                  key: ValueKey('onboarding-page-$_page'),
                                  child: _page == 0
                                      ? _welcome(context)
                                      : _preview(context),
                                ),
                              ),
                            ],
                          ),
                          Padding(
                            padding: EdgeInsets.only(top: _page == 0 ? 14 : 8),
                            child: _actions(context),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _header(BuildContext context) => Row(
    children: [
      const Expanded(
        child: Align(
          alignment: Alignment.centerLeft,
          child: AppBrand(height: 34),
        ),
      ),
      if (_page == 0)
        TextButton(
          onPressed: _working ? null : () => _goTo(1),
          child: const Text('Omitir'),
        )
      else
        TextButton.icon(
          onPressed: _working ? null : () => _goTo(0),
          icon: const Icon(Icons.arrow_back, size: 18),
          label: const Text('Volver'),
        ),
    ],
  );

  Widget _welcome(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Todo lo que cuidas,\nen un lugar.',
          style: theme.textTheme.headlineLarge?.copyWith(
            fontSize: 32,
            fontWeight: FontWeight.w800,
            height: 1.12,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          'Organiza tus animales, plantas\ny actividades con claridad.',
          style: theme.textTheme.bodyLarge?.copyWith(
            height: 1.4,
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 18),
        ClipRRect(
          borderRadius: BorderRadius.circular(AppRadii.xl),
          child: AspectRatio(
            aspectRatio: 1.5,
            child: Image.asset(
              'assets/images/onboarding_welcome_group.png',
              fit: BoxFit.cover,
              filterQuality: FilterQuality.high,
              semanticLabel: 'Vaca, perro, gato y planta juntos',
            ),
          ),
        ),
        const SizedBox(height: 18),
        const Row(
          children: [
            Expanded(
              child: _FeatureLabel(icon: Icons.badge_outlined, label: 'Fichas'),
            ),
            Expanded(
              child: _FeatureLabel(
                icon: Icons.event_note_outlined,
                label: 'Actividades',
              ),
            ),
            Expanded(
              child: _FeatureLabel(
                icon: Icons.notifications_none_outlined,
                label: 'Avisos',
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _preview(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final cardColor = isDark
        ? const Color(0xFF25463B)
        : const Color(0xFFFFFEFB);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Cada cuidado,\nbien organizado.',
          style: theme.textTheme.headlineLarge?.copyWith(
            fontSize: 30,
            fontWeight: FontWeight.w800,
            height: 1.08,
          ),
        ),
        const SizedBox(height: 7),
        Text(
          'Sus fichas, actividades y avisos,\nsiempre a la mano.',
          style: theme.textTheme.bodyLarge?.copyWith(
            height: 1.38,
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 8),
        Align(
          alignment: Alignment.centerLeft,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF2A4B3F) : _sage,
              borderRadius: BorderRadius.circular(30),
            ),
            child: Text(
              'VISTA PREVIA · DATOS FICTICIOS',
              style: theme.textTheme.labelSmall?.copyWith(
                color: isDark
                    ? const Color(0xFFC3E1D0)
                    : const Color(0xFF315A48),
                fontWeight: FontWeight.w800,
                letterSpacing: 0.45,
              ),
            ),
          ),
        ),
        const SizedBox(height: 7),
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: isDark
                ? const Color(0xFF203C33)
                : _sage.withValues(alpha: .72),
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            children: [
              _ExampleCard(
                color: cardColor,
                padding: const EdgeInsets.all(8),
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(14),
                      child: Image.asset(
                        'assets/images/vaca.webp',
                        width: 70,
                        height: 72,
                        fit: BoxFit.contain,
                        semanticLabel: 'Vaca bovina llamada Luna',
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Luna',
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          Text(
                            'Bovino · MZQ-0001',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            '4 años',
                            style: theme.textTheme.bodySmall?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 5),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: isDark
                                  ? const Color(0xFF345746)
                                  : const Color(0xFFE2F0E6),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              'Buen estado',
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: isDark
                                    ? const Color(0xFFD3EDDC)
                                    : const Color(0xFF315D46),
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 6),
              _ExampleCard(
                color: cardColor,
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.asset(
                        'assets/images/onboarding_monstera_illustration.png',
                        width: 52,
                        height: 52,
                        fit: BoxFit.contain,
                        semanticLabel: 'Planta monstera en maceta',
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Mi monstera',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          Text(
                            'Planta de interior',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 6),
              _ExampleCard(
                color: cardColor,
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 7,
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.calendar_month_outlined,
                      color: isDark ? const Color(0xFFB7DBC5) : _green,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Próxima actividad',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                          Text(
                            'Riego · Mañana',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _actions(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (_error != null)
          Semantics(
            liveRegion: true,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Text(
                _error!,
                textAlign: TextAlign.center,
                style: TextStyle(color: theme.colorScheme.error),
              ),
            ),
          ),
        if (_working)
          const Padding(
            padding: EdgeInsets.only(bottom: 9),
            child: Center(
              child: SizedBox.square(
                dimension: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  semanticsLabel: 'Preparando tu espacio',
                ),
              ),
            ),
          ),
        _ProgressDots(
          page: _page,
          selectedColor: theme.brightness == Brightness.dark
              ? const Color(0xFF9ACBB1)
              : _green,
        ),
        const SizedBox(height: 9),
        if (_page == 0)
          FilledButton(
            onPressed: _working ? null : () => _goTo(1),
            style: _primaryButtonStyle(context),
            child: const Text('Continuar'),
          )
        else ...[
          FilledButton(
            onPressed: _working ? null : () => _choose(widget.onStartEmpty),
            style: _primaryButtonStyle(context),
            child: const Text('Empezar sin cuenta'),
          ),
          const SizedBox(height: 7),
          OutlinedButton(
            onPressed: _working
                ? null
                : () => _choose(
                    () => widget.onInstallDemo(AppExperience.complete),
                    demo: true,
                  ),
            style: OutlinedButton.styleFrom(
              minimumSize: const Size.fromHeight(48),
              foregroundColor: isDark ? const Color(0xFFC3E1D0) : _green,
              side: BorderSide(
                color: isDark ? const Color(0xFF89B49C) : _green,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: const Text('Probar con ejemplos'),
          ),
          if (_hasPhoneAccess) ...[
            const SizedBox(height: 2),
            TextButton(
              onPressed: _working ? null : _openPhoneAccess,
              style: TextButton.styleFrom(
                minimumSize: const Size.fromHeight(42),
              ),
              child: const Text('Acceder con teléfono'),
            ),
          ],
          const SizedBox(height: 4),
          Text(
            'Tus registros se guardan aquí. Haz copias periódicas fuera del teléfono.',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              height: 1.3,
            ),
          ),
        ],
      ],
    );
  }

  ButtonStyle _primaryButtonStyle(BuildContext context) =>
      FilledButton.styleFrom(
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
        minimumSize: const Size.fromHeight(54),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadii.lg),
        ),
      );
}

enum _PhoneAccess { create, signIn }

class _ProgressDots extends StatelessWidget {
  const _ProgressDots({required this.page, required this.selectedColor});

  final int page;
  final Color selectedColor;

  @override
  Widget build(BuildContext context) => Semantics(
    label: 'Pantalla ${page + 1} de 2',
    child: ExcludeSemantics(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _dot(context, selected: page == 0),
          const SizedBox(width: 7),
          _dot(context, selected: page == 1),
        ],
      ),
    ),
  );

  Widget _dot(BuildContext context, {required bool selected}) =>
      AnimatedContainer(
        duration: MediaQuery.disableAnimationsOf(context)
            ? Duration.zero
            : const Duration(milliseconds: 180),
        width: selected ? 20 : 8,
        height: 8,
        decoration: BoxDecoration(
          color: selected ? selectedColor : _OnboardingPageState._warmBorder,
          borderRadius: BorderRadius.circular(10),
        ),
      );
}

class _FeatureLabel extends StatelessWidget {
  const _FeatureLabel({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 24,
          color: isDark ? const Color(0xFFB7DBC5) : _OnboardingPageState._green,
        ),
        const SizedBox(height: 4),
        Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
          style: theme.textTheme.labelMedium?.copyWith(
            color: theme.colorScheme.onSurface,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _ExampleCard extends StatelessWidget {
  const _ExampleCard({
    required this.color,
    required this.child,
    this.padding = const EdgeInsets.all(9),
  });

  final Color color;
  final Widget child;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) => Container(
    padding: padding,
    decoration: BoxDecoration(
      color: color,
      border: Border.all(
        color: _OnboardingPageState._warmBorder.withValues(alpha: .68),
      ),
      borderRadius: BorderRadius.circular(17),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: .04),
          blurRadius: 10,
          offset: const Offset(0, 3),
        ),
      ],
    ),
    child: child,
  );
}
