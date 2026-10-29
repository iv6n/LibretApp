/// features \u203a registro \u203a view \u203a registro_page \u2014 entry page for the registro module showing record type selection.
library;

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:libretapp/app/widgets/app_bottom_sheet.dart';
import 'package:libretapp/core/di/injection.dart';
import 'package:libretapp/core/experience/care_profile.dart';
import 'package:libretapp/core/experience/app_experience.dart';
import 'package:libretapp/core/platform/release_features.dart';
import 'package:libretapp/core/router/app_routes.dart';
import 'package:libretapp/features/agenda/data/agenda_reminder_sync_service.dart';
import 'package:libretapp/features/ubicaciones/domain/entities/crop_records.dart';
import 'package:libretapp/features/ubicaciones/domain/entities/location_entity.dart';
import 'package:libretapp/features/ubicaciones/domain/repositories/location_repository.dart';
import 'package:libretapp/features/ubicaciones/widgets/crop_sheets.dart';
import 'package:libretapp/features/directorio/cultivos/domain/cultivation_entity.dart';
import 'package:libretapp/features/directorio/cultivos/domain/cultivation_repository.dart';
import 'package:libretapp/core/widgets/record_save_scope.dart';
import 'package:libretapp/features/registro/widgets/registro_style.dart';
import 'package:libretapp/features/directorio/animales/infrastructure/animal_repository.dart';
import 'package:libretapp/features/directorio/animales/domain/entities/animal_entity.dart';
import 'package:libretapp/theme/app_theme.dart';

class RegistroPage extends StatefulWidget {
  const RegistroPage({super.key});

  @override
  State<RegistroPage> createState() => _RegistroPageState();
}

class _RegistroPageState extends State<RegistroPage> {
  late final LocationRepository _locationRepository;
  CultivationRepository? _cultivationRepository;
  int? _animalCount;
  List<AnimalEntity> _activeAnimals = const [];
  bool _showAllAnimalActions = false;

  @override
  void initState() {
    super.initState();
    _locationRepository = locator<LocationRepository>();
    if (locator.isRegistered<CultivationRepository>()) {
      _cultivationRepository = locator<CultivationRepository>();
    }
    if (locator.isRegistered<AnimalRepository>()) {
      locator<AnimalRepository>()
          .getAll()
          .then((animals) {
            if (mounted)
              setState(() {
                _activeAnimals = animals;
                _animalCount = animals.length;
              });
          })
          .catchError((Object _) {
            if (mounted) setState(() => _animalCount = -1);
          });
    }
  }

  List<_RegistroSection> _animalSections(
    BuildContext context,
    List<_RegistroSection> original,
  ) {
    final actions = {
      for (final section in original)
        for (final item in section.items) item.label: item,
    };
    final selectedProfile = AppExperienceScope.maybeOf(
      context,
    )?.value.careProfile;
    final profile = _activeAnimals.isEmpty
        ? selectedProfile
        : inferCareProfileFromAnimals(_activeAnimals) ?? selectedProfile;
    final firstLabel = profile == CareProfile.pets
        ? 'Añadir mascota'
        : 'Añadir animal';
    final animal = actions['Animal']!;
    final starter = _RegistroCardItem(
      icon: animal.icon,
      label: firstLabel,
      subtitle: 'Crear una ficha nueva',
      color: animal.color,
      onTap: animal.onTap,
    );
    final task = _RegistroCardItem(
      icon: Icons.event_available_outlined,
      label: 'Programar tarea',
      subtitle: 'Crear un recordatorio en Agenda',
      color: AppColors.secondary,
      onTap: (context) => context.pushNamed(AppRoutes.nameAgendaNuevo),
    );
    final labels = _animalCount == 0
        ? <String>[]
        : switch (profile) {
            CareProfile.pets => <String>['Sanitario', 'Peso'],
            CareProfile.livestock => <String>['Lote', 'Tratar lote', 'Peso'],
            _ => <String>['Lote', 'Sanitario', 'Peso'],
          };
    final primary = <_RegistroCardItem>[
      starter,
      task,
      for (final label in labels)
        if (actions[label] != null) actions[label]!,
    ];
    return [
      _RegistroSection(
        label: _animalCount == 0 ? 'Para empezar' : 'Acciones principales',
        items: primary,
      ),
      _RegistroSection(
        label: 'Más opciones',
        items: [
          _RegistroCardItem(
            icon: _showAllAnimalActions
                ? Icons.expand_less
                : Icons.apps_outlined,
            label: _showAllAnimalActions
                ? 'Ocultar funciones'
                : 'Ver todas las funciones',
            subtitle: 'Registros, importación y herramientas',
            color: AppColors.primary,
            onTap: (_) =>
                setState(() => _showAllAnimalActions = !_showAllAnimalActions),
          ),
        ],
      ),
      if (_showAllAnimalActions) ...original,
    ];
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Menú de registros'),
          elevation: 0,
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Animal'),
              Tab(text: 'Ubicación'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _RegistroTabContent(
              sections: _animalSections(context, [
                _RegistroSection(
                  label: 'Herramientas de captura',
                  items: [
                    if (!ReleaseFeatures.demoMode)
                      _RegistroCardItem(
                        icon: Icons.upload_file_outlined,
                        label: 'Importar hato',
                        subtitle: 'Excel o CSV con vista previa',
                        color: AppColors.primary,
                        onTap: (context) =>
                            context.pushNamed(AppRoutes.nameHerdImport),
                      ),
                    _RegistroCardItem(
                      icon: Icons.playlist_add_check_outlined,
                      label: 'Registro por lotes',
                      subtitle: 'Capturar y continuar sin señal',
                      color: AppColors.secondary,
                      onTap: (context) =>
                          context.pushNamed(AppRoutes.nameBatchRecords),
                    ),
                  ],
                ),
                _RegistroSection(
                  label: 'Nuevo',
                  items: [
                    if (ReleaseFeatures.hardwareIntegrationsEnabled)
                      _RegistroCardItem(
                        icon: Icons.sensors,
                        label: 'RFID',
                        subtitle: 'Escanear y asignar aretes',
                        color: Colors.deepOrange,
                        onTap: (context) =>
                            context.pushNamed(AppRoutes.nameRfid),
                      ),
                    _RegistroCardItem(
                      icon: Icons.pets,
                      label: 'Animal',
                      subtitle: 'Nuevo animal',
                      color: AppColors.primary,
                      onTap: (context) =>
                          context.pushNamed(AppRoutes.nameAnimalNuevo),
                    ),
                    _RegistroCardItem(
                      icon: Icons.groups,
                      label: 'Lote',
                      subtitle: 'Nuevo lote',
                      color: AppColors.secondary,
                      onTap: (context) =>
                          context.pushNamed(AppRoutes.nameLoteNuevo),
                    ),
                    _RegistroCardItem(
                      icon: Icons.child_care,
                      label: 'Parición',
                      subtitle: 'Registro de parición',
                      color: Colors.pink,
                      onTap: (context) => context.pushNamed(
                        AppRoutes.nameRegistroReproduccion,
                        queryParameters: {'preset': 'paricion'},
                      ),
                    ),
                  ],
                ),
                _RegistroSection(
                  label: 'Registrar',
                  items: [
                    _RegistroCardItem(
                      icon: Icons.vaccines,
                      label: 'Tratar lote',
                      subtitle: 'Vacunar o tratar varios animales',
                      color: Colors.teal.shade700,
                      onTap: (context) =>
                          context.pushNamed(AppRoutes.nameRegistroTratarLote),
                    ),
                    _RegistroCardItem(
                      icon: Icons.child_friendly_outlined,
                      label: 'Destete',
                      subtitle: 'Fecha y peso del becerro',
                      color: Colors.brown,
                      onTap: (context) =>
                          context.pushNamed(AppRoutes.nameRegistroDestete),
                    ),
                    _RegistroCardItem(
                      icon: Icons.monitor_weight,
                      label: 'Peso',
                      subtitle: 'Peso del animal',
                      color: Colors.green,
                      onTap: (context) =>
                          context.pushNamed(AppRoutes.nameRegistroPeso),
                    ),
                    _RegistroCardItem(
                      icon: Icons.medical_services,
                      label: 'Sanitario',
                      subtitle: 'Vacunas y tratamiento',
                      color: Colors.teal,
                      onTap: (context) =>
                          context.pushNamed(AppRoutes.nameRegistroSanitario),
                    ),
                    _RegistroCardItem(
                      icon: Icons.payments,
                      label: 'Costo',
                      subtitle: 'Costos de manejo',
                      color: Colors.brown,
                      onTap: (context) =>
                          context.pushNamed(AppRoutes.nameRegistroCosto),
                    ),
                    _RegistroCardItem(
                      icon: Icons.swap_horiz,
                      label: 'Cambio de ubicación',
                      subtitle: 'Movimiento interno',
                      color: Colors.indigo,
                      onTap: (context) =>
                          context.pushNamed(AppRoutes.nameRegistroMovimiento),
                    ),
                    _RegistroCardItem(
                      icon: Icons.analytics,
                      label: 'Producción',
                      subtitle: 'Ganancia o condición',
                      color: Colors.blue,
                      onTap: (context) =>
                          context.pushNamed(AppRoutes.nameRegistroProduccion),
                    ),
                    _RegistroCardItem(
                      icon: Icons.water_drop,
                      label: 'Ordeña',
                      subtitle: 'Leche por vaca o lote',
                      color: Colors.lightBlue.shade700,
                      onTap: (context) =>
                          context.pushNamed(AppRoutes.nameRegistroOrdena),
                    ),
                    _RegistroCardItem(
                      icon: Icons.favorite,
                      label: 'Reproducción',
                      subtitle: 'Servicio o parición',
                      color: Colors.deepOrange,
                      onTap: (context) =>
                          context.pushNamed(AppRoutes.nameRegistroReproduccion),
                    ),
                    _RegistroCardItem(
                      icon: Icons.store,
                      label: 'Comercial',
                      subtitle: 'Compra y venta',
                      color: Colors.purple,
                      onTap: (context) =>
                          context.pushNamed(AppRoutes.nameRegistroComercial),
                    ),
                  ],
                ),
              ]),
            ),
            _RegistroTabContent(
              sections: [
                _RegistroSection(
                  label: 'Nuevo',
                  items: [
                    _RegistroCardItem(
                      icon: Icons.place,
                      label: 'Ubicación',
                      subtitle: 'Nueva ubicación',
                      color: AppColors.accent,
                      onTap: (context) =>
                          context.pushNamed(AppRoutes.nameUbicacionNueva),
                    ),
                    _RegistroCardItem(
                      icon: Icons.grass,
                      label: 'Cultivo',
                      subtitle: 'Nuevo cultivo',
                      color: Colors.lightGreen,
                      onTap: (context) {
                        _handleNewCrop(context);
                      },
                    ),
                  ],
                ),
                _RegistroSection(
                  label: 'Registrar',
                  items: [
                    _RegistroCardItem(
                      icon: Icons.agriculture,
                      label: 'Cosecha',
                      subtitle: 'Rendimiento de cultivo',
                      color: Colors.orange,
                      onTap: (context) {
                        _handleCropRecord(
                          context,
                          _CropRecordMenuAction.harvest,
                        );
                      },
                    ),
                    _RegistroCardItem(
                      icon: Icons.water_drop,
                      label: 'Riego',
                      subtitle: 'Riego de cultivo',
                      color: Colors.blueAccent,
                      onTap: (context) {
                        _handleCropRecord(
                          context,
                          _CropRecordMenuAction.watering,
                        );
                      },
                    ),
                    _RegistroCardItem(
                      icon: Icons.health_and_safety,
                      label: 'Salud de cultivo',
                      subtitle: 'Problemas y tratamiento',
                      color: Colors.redAccent,
                      onTap: (context) {
                        _handleCropRecord(
                          context,
                          _CropRecordMenuAction.health,
                        );
                      },
                    ),
                    _RegistroCardItem(
                      icon: Icons.task_alt,
                      label: 'Tarea',
                      subtitle: 'Nueva tarea de cultivo',
                      color: Colors.amber,
                      onTap: (context) {
                        _handleCropRecord(context, _CropRecordMenuAction.task);
                      },
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleNewCrop(BuildContext context) async {
    final cultivationRepository = _cultivationRepository;
    if (cultivationRepository == null) {
      _showMessage('El catálogo de cultivos no está disponible.');
      return;
    }
    final locations = await _locationRepository.getAll();
    if (!mounted || !context.mounted) return;
    if (locations.isEmpty) {
      _showMessage('Primero crea una ubicacion para registrar cultivos.');
      return;
    }

    final location = await _pickLocation(context, locations);
    if (!mounted || !context.mounted || location == null) return;

    final saved = await context.pushNamed(
      AppRoutes.nameCultivoNuevo,
      queryParameters: {'location': location.uuid},
    );
    if (!mounted || !context.mounted || saved != true) return;
    if (!mounted) return;
    _showMessage('Cultivo registrado en ${location.name}.');
  }

  Future<void> _handleCropRecord(
    BuildContext context,
    _CropRecordMenuAction action,
  ) async {
    final cultivationRepository = _cultivationRepository;
    if (cultivationRepository == null) {
      _showMessage('El catálogo de cultivos no está disponible.');
      return;
    }
    final locations = await _locationRepository.getAll();
    if (!mounted || !context.mounted) return;
    final byLocation = <String, List<CultivationEntity>>{};
    final cultivations = await cultivationRepository.getAll();
    for (final cultivation in cultivations.where((item) => item.isActive)) {
      final locationUuid = cultivation.locationUuid;
      if (locationUuid == null) continue;
      (byLocation[locationUuid] ??= <CultivationEntity>[]).add(cultivation);
    }
    if (!mounted || !context.mounted) return;
    final withCrops = locations
        .where((location) => (byLocation[location.uuid] ?? const []).isNotEmpty)
        .toList();
    if (withCrops.isEmpty) {
      _showMessage('No hay cultivos disponibles para registrar.');
      return;
    }

    final selection = await _pickLocationAndCrop(
      context,
      withCrops,
      byLocation,
      action,
    );
    if (!mounted || !context.mounted || selection == null) return;

    final crop = selection.cultivation;

    switch (action) {
      case _CropRecordMenuAction.harvest:
        final harvestSaved = await showAppBottomSheet<Object?>(
          context: context,
          useRootNavigator: true,
          isScrollControlled: true,
          builder: (sheetContext) => RecordSaveScope(
            onSave: (value) async {
              await cultivationRepository.addHarvest(
                crop.uuid,
                value as HarvestRecord,
              );
              await _syncAgenda();
            },
            child: HarvestFormSheet(cropName: crop.name),
          ),
        );
        if (!mounted || !context.mounted || harvestSaved == null) return;
        break;
      case _CropRecordMenuAction.watering:
        final wateringSaved = await showAppBottomSheet<Object?>(
          context: context,
          useRootNavigator: true,
          isScrollControlled: true,
          builder: (sheetContext) => RecordSaveScope(
            onSave: (value) async {
              await cultivationRepository.addWatering(
                crop.uuid,
                value as CropWateringRecord,
              );
              await _syncAgenda();
            },
            child: CropWateringFormSheet(cropName: crop.name),
          ),
        );
        if (!mounted || !context.mounted || wateringSaved == null) return;
        break;
      case _CropRecordMenuAction.health:
        final healthSaved = await showAppBottomSheet<Object?>(
          context: context,
          useRootNavigator: true,
          isScrollControlled: true,
          builder: (sheetContext) => RecordSaveScope(
            onSave: (value) async {
              await cultivationRepository.addHealth(
                crop.uuid,
                value as CropHealthRecord,
              );
              await _syncAgenda();
            },
            child: CropHealthFormSheet(cropName: crop.name),
          ),
        );
        if (!mounted || !context.mounted || healthSaved == null) return;
        break;
      case _CropRecordMenuAction.task:
        final taskSaved = await showAppBottomSheet<Object?>(
          context: context,
          useRootNavigator: true,
          isScrollControlled: true,
          builder: (sheetContext) => RecordSaveScope(
            onSave: (value) async {
              await cultivationRepository.addTask(crop.uuid, value as CropTask);
              await _syncAgenda();
            },
            child: CropTaskFormSheet(cropName: crop.name),
          ),
        );
        if (!mounted || !context.mounted || taskSaved == null) return;
        break;
    }

    if (!mounted || !context.mounted) return;
    _showMessage('${action.successMessage} en ${crop.name}.');
  }

  Future<LocationEntity?> _pickLocation(
    BuildContext context,
    List<LocationEntity> locations,
  ) {
    String selectedUuid = locations.first.uuid;
    return showDialog<LocationEntity>(
      context: context,
      useRootNavigator: true,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (stateContext, setDialogState) => AlertDialog(
            title: const Text('Seleccionar ubicación'),
            content: DropdownButtonFormField<String>(
              initialValue: selectedUuid,
              decoration: const InputDecoration(labelText: 'Ubicación'),
              isExpanded: true,
              items: locations
                  .map(
                    (location) => DropdownMenuItem<String>(
                      value: location.uuid,
                      child: Text(location.name),
                    ),
                  )
                  .toList(),
              onChanged: (value) {
                if (value == null) return;
                setDialogState(() => selectedUuid = value);
              },
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(),
                child: const Text('Cancelar'),
              ),
              FilledButton(
                onPressed: () {
                  final selected = locations.firstWhere(
                    (location) => location.uuid == selectedUuid,
                  );
                  Navigator.of(dialogContext).pop(selected);
                },
                child: const Text('Continuar'),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<_LocationCropSelection?> _pickLocationAndCrop(
    BuildContext context,
    List<LocationEntity> locations,
    Map<String, List<CultivationEntity>> byLocation,
    _CropRecordMenuAction action,
  ) {
    String locationUuid = locations.first.uuid;
    String cropUuid = byLocation[locations.first.uuid]!.first.uuid;

    return showDialog<_LocationCropSelection>(
      context: context,
      useRootNavigator: true,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (stateContext, setDialogState) {
            final selectedLocation = locations.firstWhere(
              (location) => location.uuid == locationUuid,
            );
            final crops =
                byLocation[selectedLocation.uuid] ??
                const <CultivationEntity>[];
            if (!crops.any((crop) => crop.uuid == cropUuid)) {
              cropUuid = crops.first.uuid;
            }

            return AlertDialog(
              title: Text('Registrar ${action.label.toLowerCase()}'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButtonFormField<String>(
                    initialValue: locationUuid,
                    decoration: const InputDecoration(labelText: 'Ubicación'),
                    isExpanded: true,
                    items: locations
                        .map(
                          (location) => DropdownMenuItem<String>(
                            value: location.uuid,
                            child: Text(location.name),
                          ),
                        )
                        .toList(),
                    onChanged: (value) {
                      if (value == null) return;
                      setDialogState(() {
                        locationUuid = value;
                      });
                    },
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    initialValue: cropUuid,
                    decoration: const InputDecoration(labelText: 'Cultivo'),
                    isExpanded: true,
                    items: crops
                        .map(
                          (crop) => DropdownMenuItem<String>(
                            value: crop.uuid,
                            child: Text(crop.name),
                          ),
                        )
                        .toList(),
                    onChanged: (value) {
                      if (value == null) return;
                      setDialogState(() {
                        cropUuid = value;
                      });
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  child: const Text('Cancelar'),
                ),
                FilledButton(
                  onPressed: () {
                    final location = locations.firstWhere(
                      (item) => item.uuid == locationUuid,
                    );
                    final crop =
                        (byLocation[locationUuid] ??
                                const <CultivationEntity>[])
                            .firstWhere((item) => item.uuid == cropUuid);
                    Navigator.of(dialogContext).pop(
                      _LocationCropSelection(
                        location: location,
                        cultivation: crop,
                      ),
                    );
                  },
                  child: const Text('Continuar'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _syncAgenda() async {
    if (!locator.isRegistered<AgendaReminderSyncService>()) return;
    try {
      await locator<AgendaReminderSyncService>().sync();
    } catch (_) {
      // El registro ya quedó persistido; una sincronización posterior reintenta.
    }
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
        color: Theme.of(context).colorScheme.onSurface,
        fontWeight: FontWeight.w700,
      ),
    );
  }
}

class _RegistroTabContent extends StatelessWidget {
  const _RegistroTabContent({required this.sections});

  final List<_RegistroSection> sections;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.md,
        AppSpacing.sm,
        AppSpacing.md,
        AppSpacing.xl,
      ),
      children: [
        Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 960),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (final section in sections) ...[
                  _SectionLabel(label: section.label),
                  const SizedBox(height: AppSpacing.xs),
                  _RegistroCardGrid(items: section.items),
                  const SizedBox(height: AppSpacing.md),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _RegistroCardGrid extends StatelessWidget {
  const _RegistroCardGrid({required this.items});

  final List<_RegistroCardItem> items;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final largeText = MediaQuery.textScalerOf(context).scale(1) >= 1.5;
        if (constraints.maxWidth < 600 || largeText) {
          return Column(
            children: [
              for (final item in items) ...[
                _RegistroCard(item: item),
                if (item != items.last) const SizedBox(height: AppSpacing.xs),
              ],
            ],
          );
        }

        final rows = <Widget>[];
        int i = 0;
        while (i < items.length) {
          final next = i + 1 < items.length ? items[i + 1] : null;
          rows.add(
            Row(
              children: [
                Expanded(child: _RegistroCard(item: items[i])),
                const SizedBox(width: 10),
                if (next != null)
                  Expanded(child: _RegistroCard(item: next))
                else
                  const Expanded(child: SizedBox()),
              ],
            ),
          );
          i += next != null ? 2 : 1;
          if (i < items.length) rows.add(const SizedBox(height: 10));
        }
        return Column(children: rows);
      },
    );
  }
}

class _RegistroCard extends StatefulWidget {
  const _RegistroCard({required this.item});

  final _RegistroCardItem item;

  @override
  State<_RegistroCard> createState() => _RegistroCardState();
}

class _RegistroCardState extends State<_RegistroCard> {
  static const _navigationGuardDuration = Duration(milliseconds: 700);

  Timer? _navigationGuardTimer;
  bool _opening = false;

  @override
  void dispose() {
    _navigationGuardTimer?.cancel();
    super.dispose();
  }

  void _open() {
    if (_opening) return;

    // Close the keyboard before navigation so Android back does not pop the
    // input layer instead of the registration route.
    FocusManager.instance.primaryFocus?.unfocus();
    setState(() => _opening = true);

    try {
      widget.item.onTap(context);
    } catch (_) {
      if (mounted) {
        setState(() => _opening = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No se pudo abrir este registro.')),
        );
      }
      return;
    }

    _navigationGuardTimer?.cancel();
    _navigationGuardTimer = Timer(_navigationGuardDuration, () {
      if (mounted) setState(() => _opening = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    final item = widget.item;
    final theme = Theme.of(context);
    final baseColor = styleForRegistroAction(item.label)?.color ?? item.color;
    final color = theme.brightness == Brightness.dark
        ? Color.lerp(baseColor, Colors.white, 0.42)!
        : baseColor;
    final bgColor = theme.colorScheme.surfaceContainerLow;
    const iconSize = 44.0;
    const iconInnerSize = 24.0;
    const chevronSize = 20.0;
    const chevronIcon = 14.0;
    const hPad = AppSpacing.sm;
    const vPad = AppSpacing.xs;
    const iconGap = AppSpacing.sm;
    final titleStyle = theme.textTheme.titleSmall?.copyWith(
      fontWeight: FontWeight.w700,
    );
    return Material(
      color: bgColor,
      borderRadius: BorderRadius.circular(16),
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
          ),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: _opening ? null : _open,
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: hPad,
              vertical: vPad,
            ),
            child: Row(
              children: [
                Container(
                  width: iconSize,
                  height: iconSize,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(AppRadii.sm),
                    color: color.withValues(alpha: 0.15),
                  ),
                  child: Icon(item.icon, color: color, size: iconInnerSize),
                ),
                const SizedBox(width: iconGap),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        item.label,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: titleStyle,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        item.subtitle,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  width: chevronSize,
                  height: chevronSize,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: color.withValues(alpha: 0.15),
                  ),
                  child: Icon(
                    _opening ? Icons.hourglass_top : Icons.chevron_right,
                    color: _opening ? color.withValues(alpha: 0.55) : color,
                    size: chevronIcon,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _RegistroSection {
  const _RegistroSection({required this.label, required this.items});

  final String label;
  final List<_RegistroCardItem> items;
}

class _RegistroCardItem {
  const _RegistroCardItem({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final String subtitle;
  final Color color;
  final void Function(BuildContext context) onTap;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is _RegistroCardItem &&
        other.icon == icon &&
        other.label == label &&
        other.subtitle == subtitle &&
        other.color == color;
  }

  @override
  int get hashCode => Object.hash(icon, label, subtitle, color);
}

enum _CropRecordMenuAction {
  harvest('Cosecha', 'Cosecha guardada'),
  watering('Riego', 'Riego guardado'),
  health('Salud de cultivo', 'Registro de salud guardado'),
  task('Tarea', 'Tarea creada');

  const _CropRecordMenuAction(this.label, this.successMessage);

  final String label;
  final String successMessage;
}

class _LocationCropSelection {
  const _LocationCropSelection({
    required this.location,
    required this.cultivation,
  });

  final LocationEntity location;
  final CultivationEntity cultivation;
}
