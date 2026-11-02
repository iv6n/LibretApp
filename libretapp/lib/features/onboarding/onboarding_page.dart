import 'dart:async';
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
    this.onAccessPhone,
    this.onProgress,
    this.initialPage = 0,
    this.initialError,
  });

  final Future<void> Function() onStartEmpty;
  final Future<void> Function(AppExperience experience) onInstallDemo;
  final Future<void> Function()? onAccessPhone;
  final Future<void> Function(int page)? onProgress;

  /// The three welcome screens use indexes 0, 1, and 2.
  final int initialPage;
  final String? initialError;

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  static const _green = AppColors.primary;
  static const _sage = AppColors.sage;
  static const _warmBorder = LightColors.border;
  static const _pageCount = 3;

  late int _page = widget.initialPage.clamp(0, _pageCount - 1);
  late final PageController _pageController = PageController(
    initialPage: _page,
  );
  late String? _error = widget.initialError;
  Future<void> _progressWrites = Future<void>.value();
  bool _working = false;
  int? _skipDestination;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onPageChanged(int page) {
    if (!mounted || page == _page) return;
    final isSkippedIntermediate =
        _skipDestination != null && page != _skipDestination;
    if (page == _skipDestination) _skipDestination = null;
    setState(() {
      _page = page;
      _error = null;
    });
    if (isSkippedIntermediate) return;
    _progressWrites = _saveProgressAfter(_progressWrites, page);
  }

  Future<void> _saveProgressAfter(Future<void> previous, int page) async {
    try {
      await previous;
      await widget.onProgress?.call(page);
    } catch (_) {
      if (mounted) {
        setState(
          () => _error = 'No se pudo guardar tu avance. Intenta de nuevo.',
        );
      }
    }
  }

  Future<void> _goTo(int page, {bool skip = false}) async {
    if (_working || !_pageController.hasClients) return;
    final destination = page.clamp(0, _pageCount - 1);
    if (destination == _page) return;
    if (skip) _skipDestination = destination;
    if (MediaQuery.disableAnimationsOf(context)) {
      _pageController.jumpToPage(destination);
      return;
    }
    await _pageController.animateToPage(
      destination,
      duration: const Duration(milliseconds: 260),
      curve: Curves.easeInOutCubic,
    );
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
    final action = widget.onAccessPhone;
    if (_working || action == null) return;
    await _choose(action, navigate: false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: PageView(
          controller: _pageController,
          physics: _working
              ? const NeverScrollableScrollPhysics()
              : const PageScrollPhysics(),
          onPageChanged: _onPageChanged,
          children: [
            _slide(context, page: 0, content: _welcome(context)),
            _slide(context, page: 1, content: _preview(context)),
            _slide(context, page: 2, content: _accessIntro(context)),
          ],
        ),
      ),
    );
  }

  Widget _slide(
    BuildContext context, {
    required int page,
    required Widget content,
  }) => LayoutBuilder(
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
                    _header(context, page),
                    SizedBox(height: page == 0 ? 20 : 12),
                    content,
                  ],
                ),
                Padding(
                  padding: EdgeInsets.only(top: page == 0 ? 14 : 10),
                  child: _actions(context, page),
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );

  Widget _header(BuildContext context, int page) {
    final compactBrand =
        MediaQuery.sizeOf(context).width < 360 ||
        MediaQuery.textScalerOf(context).scale(16) >= 24;
    return Row(
      children: [
        Expanded(
          child: Align(
            alignment: Alignment.centerLeft,
            child: AppBrand(
              variant: compactBrand
                  ? AppBrandVariant.symbol
                  : AppBrandVariant.logo,
              height: 34,
            ),
          ),
        ),
        if (page < 2)
          TextButton(
            onPressed: _working ? null : () => _goTo(2, skip: true),
            child: const Text('Omitir'),
          )
        else
          TextButton.icon(
            onPressed: _working ? null : () => _goTo(1),
            icon: const Icon(Icons.arrow_back, size: 18),
            label: const Text('Volver'),
          ),
      ],
    );
  }

  Widget _welcome(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'De la casa al campo,\ntodo lo que cuidas\nen un lugar.',
          style: theme.textTheme.headlineLarge?.copyWith(
            fontSize: 32,
            fontWeight: FontWeight.w800,
            height: 1.1,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          'Registra animales, mascotas, siembras y plantas. Organiza sus cuidados y próximas tareas en un solo lugar.',
          style: theme.textTheme.bodyLarge?.copyWith(
            height: 1.38,
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 16),
        ClipRRect(
          borderRadius: BorderRadius.circular(AppRadii.xl),
          child: AspectRatio(
            aspectRatio: 1.55,
            child: Image.asset(
              'assets/images/onboarding_welcome_group_v2.jpg',
              fit: BoxFit.cover,
              filterQuality: FilterQuality.high,
              semanticLabel:
                  'Vaca, perro, gato y planta frente a una siembra, con un caballo y una cabra al fondo',
            ),
          ),
        ),
        const SizedBox(height: 15),
        const Wrap(
          spacing: 8,
          runSpacing: 8,
          alignment: WrapAlignment.spaceBetween,
          children: [
            _FeatureChip(icon: Icons.history, label: 'Guarda su historia'),
            _FeatureChip(
              icon: Icons.event_note_outlined,
              label: 'Planea cuidados',
            ),
            _FeatureChip(
              icon: Icons.notifications_none_outlined,
              label: 'Recibe avisos',
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
          'Tus cuidados, de un vistazo.',
          style: theme.textTheme.headlineLarge?.copyWith(
            fontSize: 30,
            fontWeight: FontWeight.w800,
            height: 1.08,
          ),
        ),
        const SizedBox(height: 7),
        Text(
          'Consulta fichas y próximos cuidados en un solo lugar.',
          style: theme.textTheme.bodyLarge?.copyWith(
            height: 1.38,
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 10),
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
        const SizedBox(height: 9),
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
              _PreviewRecord(
                color: cardColor,
                image: 'assets/images/vaca.webp',
                imageLabel: 'Vaca Prieta',
                title: 'Prieta',
                detail: 'Vaca · Salud al día',
              ),
              const SizedBox(height: 6),
              _PreviewRecord(
                color: cardColor,
                image: 'assets/images/canino.webp',
                imageLabel: 'Perro Capitán',
                title: 'Capitán',
                detail: 'Perro · Próxima revisión',
              ),
              const SizedBox(height: 6),
              _PreviewRecord(
                color: cardColor,
                image: 'assets/images/crop_field.webp',
                imageLabel: 'Siembra de maíz',
                title: 'Maíz blanco',
                detail: 'Siembra · En crecimiento',
              ),
              const SizedBox(height: 6),
              _PreviewRecord(
                color: cardColor,
                image: 'assets/images/onboarding_monstera_illustration.png',
                imageLabel: 'Planta monstera en maceta',
                title: 'Mi monstera',
                detail: 'Planta · Riego mañana',
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _accessIntro(BuildContext context) {
    final theme = Theme.of(context);
    final compactArtwork =
        MediaQuery.sizeOf(context).height < 650 ||
        MediaQuery.textScalerOf(context).scale(16) >= 24;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Empieza a tu manera.',
          style: theme.textTheme.headlineLarge?.copyWith(
            fontSize: 32,
            fontWeight: FontWeight.w800,
            height: 1.1,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          widget.onAccessPhone == null
              ? 'Empieza como invitado o explora la app con ejemplos.'
              : 'Accede con tu teléfono, empieza como invitado o explora la app con ejemplos.',
          style: theme.textTheme.bodyLarge?.copyWith(
            height: 1.4,
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 14),
        ClipRRect(
          borderRadius: BorderRadius.circular(AppRadii.xl),
          child: Container(
            height: compactArtwork ? 120 : 170,
            color: theme.colorScheme.surfaceContainerHighest,
            child: Image.asset(
              'assets/images/onboarding_start_options.jpg',
              fit: compactArtwork ? BoxFit.contain : BoxFit.cover,
              alignment: Alignment.topCenter,
              filterQuality: FilterQuality.high,
              semanticLabel:
                  'Persona organizando cuidados desde su teléfono junto a un perro y una siembra',
            ),
          ),
        ),
      ],
    );
  }

  Widget _actions(BuildContext context, int page) {
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
          selectedColor: isDark ? const Color(0xFF9ACBB1) : _green,
        ),
        const SizedBox(height: 9),
        if (page == 0)
          FilledButton(
            onPressed: _working ? null : () => _goTo(1),
            style: _primaryButtonStyle(context),
            child: const Text('Continuar'),
          )
        else if (page == 1 &&
            (MediaQuery.sizeOf(context).width < 360 ||
                MediaQuery.textScalerOf(context).scale(16) >= 24))
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: _working ? null : () => _goTo(0),
                  child: const Text('Volver'),
                ),
              ),
              FilledButton(
                onPressed: _working ? null : () => _goTo(2),
                style: _primaryButtonStyle(context),
                child: const Text('Continuar'),
              ),
            ],
          )
        else if (page == 1)
          Row(
            children: [
              TextButton(
                onPressed: _working ? null : () => _goTo(0),
                child: const Text('Volver'),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: FilledButton(
                  onPressed: _working ? null : () => _goTo(2),
                  style: _primaryButtonStyle(context),
                  child: const Text('Continuar'),
                ),
              ),
            ],
          )
        else ...[
          FilledButton.icon(
            onPressed: _working || widget.onAccessPhone == null
                ? null
                : _openPhoneAccess,
            style: _primaryButtonStyle(context),
            icon: const Icon(Icons.phone_android_outlined),
            label: const Text('Acceder con teléfono'),
          ),
          if (widget.onAccessPhone == null)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                'El acceso por teléfono no está disponible en esta versión.',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          const SizedBox(height: 7),
          OutlinedButton(
            onPressed: _working ? null : () => _choose(widget.onStartEmpty),
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
            child: const Text('Continuar como invitado'),
          ),
          const SizedBox(height: 10),
          _demoSection(context),
          const SizedBox(height: 8),
          Text(
            'Tus registros se guardan en este dispositivo. Haz copias de seguridad periódicas.',
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

  Widget _demoSection(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final compact =
        MediaQuery.sizeOf(context).width < 360 ||
        MediaQuery.textScalerOf(context).scale(16) >= 24;
    final details = Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Explorar con ejemplos',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
          Text(
            'Prueba fichas y actividades ficticias en un espacio separado.',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
    final action = TextButton(
      onPressed: _working
          ? null
          : () => _choose(
              () => widget.onInstallDemo(AppExperience.complete),
              demo: true,
            ),
      child: const Text('Ver demo'),
    );
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 10, 10, 10),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF203C33) : _sage.withValues(alpha: .55),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _warmBorder.withValues(alpha: .8)),
      ),
      child: compact
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.auto_awesome_outlined,
                      color: theme.colorScheme.primary,
                    ),
                    const SizedBox(width: 10),
                    details,
                  ],
                ),
                Align(alignment: Alignment.centerRight, child: action),
              ],
            )
          : Row(
              children: [
                Icon(
                  Icons.auto_awesome_outlined,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: 10),
                details,
                action,
              ],
            ),
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

class _ProgressDots extends StatelessWidget {
  const _ProgressDots({required this.page, required this.selectedColor});

  final int page;
  final Color selectedColor;

  @override
  Widget build(BuildContext context) => Semantics(
    label: 'Pantalla ${page + 1} de 3',
    child: ExcludeSemantics(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _dot(context, selected: page == 0),
          const SizedBox(width: 7),
          _dot(context, selected: page == 1),
          const SizedBox(width: 7),
          _dot(context, selected: page == 2),
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

class _FeatureChip extends StatelessWidget {
  const _FeatureChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF25463B) : _OnboardingPageState._sage,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 18,
            color: isDark
                ? const Color(0xFFB7DBC5)
                : _OnboardingPageState._green,
          ),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              label,
              softWrap: true,
              style: theme.textTheme.labelMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PreviewRecord extends StatelessWidget {
  const _PreviewRecord({
    required this.color,
    required this.image,
    required this.imageLabel,
    required this.title,
    required this.detail,
  });

  final Color color;
  final String image;
  final String imageLabel;
  final String title;
  final String detail;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return _ExampleCard(
      color: color,
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.asset(
              image,
              width: 52,
              height: 56,
              fit: BoxFit.contain,
              semanticLabel: imageLabel,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                Text(
                  detail,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ExampleCard extends StatelessWidget {
  const _ExampleCard({required this.color, required this.child});

  final Color color;
  final Widget child;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(8),
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
