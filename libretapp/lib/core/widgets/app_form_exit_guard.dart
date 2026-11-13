/// Optional navigation guard for forms that can lose unsaved field edits.
library;

import 'package:flutter/material.dart';

class AppFormExitGuard extends StatefulWidget {
  const AppFormExitGuard({
    required this.enabled,
    required this.saving,
    required this.child,
    this.onExitWithinFlow,
    this.initiallyChanged = false,
    this.currentSignature,
    this.initialSignature,
    this.exitConfirmationMessage,
    super.key,
  });

  final bool enabled;
  final bool saving;
  final Widget child;

  /// Handles navigation that stays inside a multi-step form.
  final VoidCallback? onExitWithinFlow;
  final bool initiallyChanged;
  final String Function()? currentSignature;
  final String? initialSignature;
  final String? exitConfirmationMessage;

  @override
  State<AppFormExitGuard> createState() => _AppFormExitGuardState();

  static final Expando<_AppFormExitGuardState> _routes =
      Expando<_AppFormExitGuardState>('app-form-exit-guard');

  static _AppFormExitGuardState? _for(BuildContext context) {
    final route = ModalRoute.of(context);
    return route == null ? null : _routes[route];
  }

  static void markChanged(BuildContext context) {
    final guard = _for(context);
    if (guard == null) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (context.mounted) {
        guard.markChanged(manual: true, forceManual: false);
      }
    });
  }

  /// Marks a custom control whose value is not represented by a FormField.
  static void markCustomChanged(BuildContext context) =>
      _for(context)?.markChanged(manual: true, forceManual: true);

  /// Rechecks FormField values against the snapshot captured after the form
  /// first appears with its loaded or initial data.
  static void refreshFromForm(BuildContext context) =>
      _for(context)?.refreshFromForm();

  static void reset(BuildContext context) => _for(context)?.resetChanged();

  static Future<void> requestExit(
    BuildContext context, {
    Object? result,
  }) async {
    final guard = _for(context);
    if (guard == null) {
      Navigator.of(context).pop(result);
      return;
    }
    await guard.requestExit(result: result);
  }

  static void complete(BuildContext context, [Object? result]) {
    final guard = _for(context);
    if (guard == null) {
      Navigator.of(context).pop(result);
      return;
    }
    guard.complete(result: result);
  }
}

class _AppFormExitGuardState extends State<AppFormExitGuard> {
  bool _changed = false;
  bool _manualChange = false;
  bool _allowPop = false;
  bool _confirmingExit = false;
  bool _snapshotReady = false;
  bool _snapshotCaptureScheduled = false;
  List<Object?>? _initialValues;
  String? _initialSignature;
  ModalRoute<dynamic>? _route;

  @override
  void initState() {
    super.initState();
    _changed = widget.initiallyChanged;
    _manualChange = widget.initiallyChanged;
  }

  @override
  void didUpdateWidget(covariant AppFormExitGuard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initiallyChanged && !oldWidget.initiallyChanged) {
      _changed = true;
      _manualChange = true;
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final route = ModalRoute.of(context);
    if (identical(_route, route)) return;
    if (_route != null && identical(AppFormExitGuard._routes[_route!], this)) {
      AppFormExitGuard._routes[_route!] = null;
    }
    _route = route;
    if (route != null) AppFormExitGuard._routes[route] = this;
    _scheduleSnapshotCapture();
  }

  void _scheduleSnapshotCapture() {
    if (!widget.enabled || _snapshotReady || _snapshotCaptureScheduled) return;
    _snapshotCaptureScheduled = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _snapshotCaptureScheduled = false;
      if (!mounted || _snapshotReady) return;
      final values = _readFormValues();
      final signature = widget.currentSignature?.call();
      if (values == null && widget.currentSignature == null) return;
      _initialValues = values;
      _initialSignature = widget.initialSignature ?? signature;
      _snapshotReady = true;
      final changed = _manualChange || signature != _initialSignature;
      if (_changed != changed) setState(() => _changed = changed);
    });
  }

  List<Object?>? _readFormValues() {
    Element? formElement;

    void findForm(Element element) {
      if (formElement != null) return;
      if (element.widget is Form) {
        formElement = element;
        return;
      }
      element.visitChildElements(findForm);
    }

    context.visitChildElements(findForm);
    final root = formElement;
    if (root == null) return null;

    final values = <Object?>[];
    void collectFields(Element element) {
      if (element is StatefulElement &&
          element.state is FormFieldState<dynamic>) {
        final field = element.state as FormFieldState<dynamic>;
        values.add(field.value);
      }
      element.visitChildElements(collectFields);
    }

    root.visitChildElements(collectFields);
    return values;
  }

  bool _matchesInitialValues(List<Object?> currentValues) {
    final initialValues = _initialValues;
    if (!_snapshotReady || initialValues == null) return false;
    if (initialValues.length != currentValues.length) return false;
    for (var index = 0; index < initialValues.length; index++) {
      if (initialValues[index] != currentValues[index]) return false;
    }
    return true;
  }

  bool _matchesInitialState() {
    if (!_snapshotReady) return false;
    final currentValues = _readFormValues();
    final initialValues = _initialValues;
    if (initialValues == null) {
      if (currentValues != null) return false;
    } else if (currentValues == null || !_matchesInitialValues(currentValues)) {
      return false;
    }
    return widget.currentSignature?.call() == _initialSignature;
  }

  void refreshFromForm() {
    if (!mounted || !widget.enabled) return;
    final values = _readFormValues();
    if (!_snapshotReady ||
        (values == null && widget.currentSignature == null)) {
      return;
    }
    final changed = _manualChange || !_matchesInitialState();
    if (_changed == changed) return;
    setState(() => _changed = changed);
  }

  @override
  void dispose() {
    if (_route != null && identical(AppFormExitGuard._routes[_route!], this)) {
      AppFormExitGuard._routes[_route!] = null;
    }
    super.dispose();
  }

  void markChanged({required bool manual, required bool forceManual}) {
    if (!mounted || !widget.enabled) return;
    final changedFromSnapshot = _snapshotReady && !_matchesInitialState();
    if (manual && (forceManual || !changedFromSnapshot)) {
      _manualChange = true;
    }
    final changed = _manualChange || changedFromSnapshot || !_snapshotReady;
    if (_changed == changed) return;
    setState(() => _changed = changed);
  }

  void resetChanged() {
    if (!mounted) return;
    final values = _readFormValues();
    final signature = widget.currentSignature?.call();
    if (values != null || widget.currentSignature != null) {
      _initialValues = values;
      _initialSignature = signature;
      _snapshotReady = true;
    }
    _manualChange = false;
    if (!_changed && !_allowPop) return;
    setState(() {
      _changed = false;
      _allowPop = false;
    });
  }

  Future<void> requestExit({Object? result}) async {
    if (!mounted || !widget.enabled || widget.saving) return;
    refreshFromForm();
    final withinFlow = widget.onExitWithinFlow;
    if (withinFlow != null) {
      withinFlow();
      return;
    }
    if (_changed) {
      if (_confirmingExit) return;
      _confirmingExit = true;
      bool? discard;
      try {
        discard = await showDialog<bool>(
          context: context,
          builder: (dialogContext) => AlertDialog(
            title: const Text('¿Descartar los cambios?'),
            content: Text(
              widget.exitConfirmationMessage ??
                  'La información que capturaste no se guardará.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(false),
                child: const Text('Seguir capturando'),
              ),
              FilledButton(
                onPressed: () => Navigator.of(dialogContext).pop(true),
                child: const Text('Salir sin guardar'),
              ),
            ],
          ),
        );
      } finally {
        if (mounted) _confirmingExit = false;
      }
      if (!mounted || discard != true) return;
    }
    complete(result: result);
  }

  void complete({Object? result}) {
    if (!mounted) return;
    setState(() => _allowPop = true);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) Navigator.of(context).pop(result);
    });
  }

  @override
  Widget build(BuildContext context) {
    _scheduleSnapshotCapture();
    return PopScope<Object?>(
      canPop: !widget.enabled || _allowPop,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop && widget.enabled) requestExit(result: result);
      },
      child: widget.child,
    );
  }
}
