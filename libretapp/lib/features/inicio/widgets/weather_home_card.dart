import 'package:flutter/material.dart';
import 'dart:async';
import 'package:intl/intl.dart';
import 'package:libretapp/core/di/injection.dart';
import 'package:libretapp/core/experience/app_experience.dart';
import 'package:libretapp/core/workspace/workspace_manager.dart';
import 'package:libretapp/features/inicio/data/weather_alerts_service.dart';
import 'package:libretapp/features/inicio/data/weather_preferences_service.dart';

class WeatherHomeCard extends StatefulWidget {
  const WeatherHomeCard({super.key});

  @override
  State<WeatherHomeCard> createState() => _WeatherHomeCardState();
}

class _WeatherHomeCardState extends State<WeatherHomeCard> {
  late final WeatherPreferencesService _service =
      locator<WeatherPreferencesService>();
  WeatherSnapshot? _snapshot;
  bool _loading = false;
  String? _error;
  bool get _demo => locator<WorkspaceManager>().isDemo;
  AppExperience? _lastSyncedExperience;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final experience = AppExperienceScope.of(context).experience;
    if (_lastSyncedExperience == experience) return;
    _lastSyncedExperience = experience;
    if (_service.alertsEnabled && !_demo) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        unawaited(
          locator<WeatherAlertsService>().syncExisting(
            workspace: locator<WorkspaceManager>().current!,
            experience: experience,
          ),
        );
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _snapshot = _service.cached;
    if (_service.location != null && !_demo) _refresh();
  }

  Future<void> _refresh() async {
    if (_loading || _demo) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    final result = await _service.refresh();
    if (!mounted) return;
    setState(() {
      _snapshot = result;
      if (result == null) {
        _error = 'No se pudo consultar el clima. Revisa tu conexión.';
      }
      _loading = false;
    });
  }

  Future<void> _configure() async {
    final changed = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (context) => _WeatherSetupSheet(
        service: _service,
        alerts: locator<WeatherAlertsService>(),
        workspaceManager: locator<WorkspaceManager>(),
        experience: AppExperienceScope.of(context).experience,
        demo: _demo,
      ),
    );
    if (changed == true && mounted) {
      _snapshot = _service.cached;
      await _refresh();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final location = _service.location;
    return Card(
      key: const ValueKey('weather-home-card'),
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: location == null
            ? Row(
                children: [
                  Icon(
                    Icons.wb_sunny_outlined,
                    color: colors.primary,
                    size: 30,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Clima para cuidar mejor',
                          style: theme.textTheme.titleMedium,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _demo
                              ? 'La demo no configura ubicaciones ni avisos reales.'
                              : 'Configura una ciudad o ubicación aproximada para ver el pronóstico y activar avisos.',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colors.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (!_demo)
                    IconButton(
                      onPressed: _configure,
                      tooltip: 'Configurar clima',
                      icon: const Icon(Icons.add_location_alt_outlined),
                    ),
                ],
              )
            : Row(
                children: [
                  Icon(
                    Icons.wb_sunny_outlined,
                    color: colors.primary,
                    size: 32,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          location.label,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.labelLarge?.copyWith(
                            color: colors.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 2),
                        if (_snapshot case final snapshot?) ...[
                          Text(
                            '${snapshot.weather.temperature}° · ${snapshot.weather.condition}',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          Text(
                            'Máx. ${snapshot.weather.maxTemperature}°  ·  Hum. ${snapshot.weather.humidity}%',
                            style: theme.textTheme.bodySmall,
                          ),
                          Text(
                            '${snapshot.isStale ? 'Dato anterior' : 'Actualizado'} · ${DateFormat('HH:mm').format(snapshot.updatedAt)}',
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: colors.onSurfaceVariant,
                            ),
                          ),
                        ] else
                          Text(
                            _error ??
                                (_loading
                                    ? 'Consultando el clima…'
                                    : 'Aún no hay datos del clima.'),
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: _error == null
                                  ? colors.onSurfaceVariant
                                  : colors.error,
                            ),
                          ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: _demo || _loading ? null : _refresh,
                    tooltip: 'Actualizar clima',
                    icon: _loading
                        ? const SizedBox.square(
                            dimension: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.refresh),
                  ),
                  IconButton(
                    onPressed: _demo ? null : _configure,
                    tooltip: 'Ubicación y avisos del clima',
                    icon: const Icon(Icons.settings_outlined),
                  ),
                ],
              ),
      ),
    );
  }
}

class _WeatherSetupSheet extends StatefulWidget {
  const _WeatherSetupSheet({
    required this.service,
    required this.alerts,
    required this.workspaceManager,
    required this.experience,
    required this.demo,
  });

  final WeatherPreferencesService service;
  final WeatherAlertsService alerts;
  final WorkspaceManager workspaceManager;
  final AppExperience experience;
  final bool demo;

  @override
  State<_WeatherSetupSheet> createState() => _WeatherSetupSheetState();
}

class _WeatherSetupSheetState extends State<_WeatherSetupSheet> {
  final _city = TextEditingController();
  bool _busy = false;
  bool _enabled = false;
  String? _error;
  WeatherSavedLocation? get _location => widget.service.location;

  @override
  void initState() {
    super.initState();
    _enabled = widget.service.alertsEnabled;
    _city.text = _location?.label ?? '';
  }

  @override
  void dispose() {
    _city.dispose();
    super.dispose();
  }

  Future<void> _withBusy(Future<void> Function() action) async {
    if (_busy) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await action();
    } catch (error) {
      if (mounted) {
        setState(
          () => _error = error is StateError
              ? error.message.toString()
              : 'No se pudo guardar la configuración del clima. Intenta de nuevo.',
        );
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _saveCity() => _withBusy(() async {
    final label = _city.text.trim();
    if (label.isEmpty) {
      throw StateError('Escribe una ciudad.');
    }
    final coordinates = await widget.service.weatherService.coordinatesForCity(
      label,
    );
    if (coordinates == null) {
      throw StateError(
        'No encontramos esa ciudad. Revisa el nombre e intenta otra vez.',
      );
    }
    await widget.service.saveLocation(
      WeatherSavedLocation(
        label: label,
        latitude: coordinates.latitude,
        longitude: coordinates.longitude,
      ),
    );
    if (_enabled) {
      await widget.alerts.setEnabled(
        enabled: true,
        workspace: widget.workspaceManager.current!,
        experience: widget.experience,
      );
    }
    if (mounted) {
      Navigator.pop(context, true);
    }
  });

  Future<void> _useGps() => _withBusy(() async {
    final coordinates = await widget.service.weatherService
        .requestCurrentCoordinates();
    if (coordinates == null) {
      throw StateError(
        'No se pudo obtener la ubicación. Revisa el permiso y los servicios de ubicación.',
      );
    }
    await widget.service.saveLocation(
      WeatherSavedLocation(
        label: 'Ubicación aproximada',
        latitude: coordinates.latitude,
        longitude: coordinates.longitude,
      ),
    );
    if (_enabled) {
      await widget.alerts.setEnabled(
        enabled: true,
        workspace: widget.workspaceManager.current!,
        experience: widget.experience,
      );
    }
    if (mounted) {
      Navigator.pop(context, true);
    }
  });

  Future<void> _toggleAlerts(bool value) async {
    await _withBusy(() async {
      final workspace = widget.workspaceManager.current;
      if (workspace == null) return;
      final enabled = await widget.alerts.setEnabled(
        enabled: value,
        workspace: workspace,
        experience: widget.experience,
      );
      if (!enabled && value) {
        throw StateError(
          'Permite las notificaciones para activar los avisos meteorológicos.',
        );
      }
      if (mounted) setState(() => _enabled = value);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final location = _location;
    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(
        24,
        20,
        24,
        24 + MediaQuery.viewInsetsOf(context).bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Configurar clima',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Elige una ciudad o guarda una ubicación aproximada. La ubicación solo se solicita al tocar GPS.',
          ),
          if (location != null) ...[
            const SizedBox(height: 12),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.place_outlined),
              title: Text(location.label),
              subtitle: const Text('Ubicación guardada en este espacio'),
            ),
          ],
          const SizedBox(height: 8),
          TextField(
            controller: _city,
            enabled: !_busy && !widget.demo,
            textCapitalization: TextCapitalization.words,
            textInputAction: TextInputAction.search,
            onSubmitted: (_) => _saveCity(),
            decoration: const InputDecoration(
              labelText: 'Ciudad',
              hintText: 'Ej. Guadalajara',
            ),
          ),
          const SizedBox(height: 10),
          OutlinedButton.icon(
            onPressed: _busy || widget.demo ? null : _saveCity,
            icon: const Icon(Icons.search),
            label: const Text('Guardar ciudad'),
          ),
          OutlinedButton.icon(
            onPressed: _busy || widget.demo ? null : _useGps,
            icon: const Icon(Icons.my_location_outlined),
            label: const Text('Usar ubicación aproximada (GPS)'),
          ),
          const SizedBox(height: 8),
          SwitchListTile.adaptive(
            contentPadding: EdgeInsets.zero,
            value: _enabled,
            onChanged: _busy || widget.demo ? null : _toggleAlerts,
            title: const Text('Avisos del clima'),
            subtitle: const Text(
              'Frío ≤10 °C, calor ≥32 °C, lluvia fuerte o tormenta. Android revisa aproximadamente cada 6 horas; puede demorar el aviso.',
            ),
          ),
          if (_error != null)
            Semantics(
              liveRegion: true,
              child: Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  _error!,
                  style: TextStyle(color: theme.colorScheme.error),
                ),
              ),
            ),
          if (_busy)
            const Padding(
              padding: EdgeInsets.all(12),
              child: Center(child: CircularProgressIndicator()),
            ),
          if (widget.demo)
            const Text(
              'Los ejemplos no solicitan permisos ni envían avisos reales.',
            ),
        ],
      ),
    );
  }
}
