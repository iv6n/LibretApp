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
            if (mounted) {
              setState(() {
                _activeAnimals = animals;
                _animalCount = animals.length;
              });
            }
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
      onTap: (context) =>
          context.pushNamed(AppRoutes.nameRegistroMenuAgendaNuevo),
    );
    final labels = _animalCount == 0 ? <String>[] : <String>['Peso'];
    final primary = <_RegistroCardItem>[
      starter,
      task,
      for (final label in labels)
        if (actions[label] != null) actions[label]!,
    ];
    final primaryLabels = <String>{
      'Animal',
      ...primary.map((item) => item.label),
    };
    final remaining = [
      for (final section in original)
        _RegistroSection(
          label: section.label,
          items: section.items
              .where((item) => !primaryLabels.contains(item.label))
              .toList(),
        ),
    ].where((section) => section.items.isNotEmpty).toList();
    final moreCount = remaining.fold<int>(
      0,
      (total, section) => total + section.items.length,
    );
    return [
      _RegistroSection(label: 'Animal', items: primary, isCategory: true),
      _RegistroSection(
        label: 'Más opciones',
        items: [
          _RegistroCardItem(
            icon: _showAllAnimalActions
                ? Icons.expand_less
                : Icons.apps_outlined,
            label: _showAllAnimalActions
                ? 'Ocultar funciones'
                : 'Ver $moreCount funciones más',
            subtitle: 'Registros y herramientas de captura',
            hint: _showAllAnimalActions
                ? 'Ocultar opciones de registro'
                : 'Mostrar más opciones de registro',
            color: AppColors.primary,
            onTap: (_) =>
                setState(() => _showAllAnimalActions = !_showAllAnimalActions),
          ),
        ],
      ),
      if (_showAllAnimalActions) ...remaining,
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Menú de registros'), elevation: 0),
      body: _RegistroMenuContent(
        sections: [
          ..._animalSections(context, [
            _RegistroSection(
              label: 'Herramientas de captura',
              items: [
                if (!ReleaseFeatures.demoMode)
                  _RegistroCardItem(
                    icon: Icons.upload_file_outlined,
                    label: 'Importar hato',
                    subtitle: 'Cargar animales desde Excel o CSV',
                    color: AppColors.primary,
                    onTap: (context) =>
                        context.pushNamed(AppRoutes.nameHerdImport),
                  ),
                _RegistroCardItem(
                  icon: Icons.playlist_add_check_outlined,
                  label: 'Registro por lotes',
                  subtitle: 'Capturar varios registros en una sesión',
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
                    subtitle: 'Leer y asignar aretes electrónicos',
                    color: Colors.deepOrange,
                    onTap: (context) => context.pushNamed(AppRoutes.nameRfid),
                  ),
                _RegistroCardItem(
                  icon: Icons.pets,
                  label: 'Animal',
                  subtitle: 'Crear una ficha nueva',
                  color: AppColors.primary,
                  onTap: (context) =>
                      context.pushNamed(AppRoutes.nameRegistroMenuAnimalNuevo),
                ),
                _RegistroCardItem(
                  icon: Icons.playlist_add_outlined,
                  label: 'Alta de varios animales',
                  subtitle: 'Crear varias fichas en menos pasos',
                  color: AppColors.primary,
                  onTap: (context) => context.pushNamed(
                    AppRoutes.nameRegistroMenuAnimalMultiple,
                  ),
                ),
                _RegistroCardItem(
                  icon: Icons.groups,
                  label: 'Lote',
                  subtitle: 'Agrupar animales para su manejo',
                  color: AppColors.secondary,
                  onTap: (context) =>
                      context.pushNamed(AppRoutes.nameRegistroMenuLoteNuevo),
                ),
                _RegistroCardItem(
                  icon: Icons.child_care,
                  label: 'Parición',
                  subtitle: 'Registrar el nacimiento de becerros',
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
                  subtitle: 'Registrar vacunas o tratamientos grupales',
                  color: Colors.teal.shade700,
                  onTap: (context) =>
                      context.pushNamed(AppRoutes.nameRegistroTratarLote),
                ),
                _RegistroCardItem(
                  icon: Icons.child_friendly_outlined,
                  label: 'Destete',
                  subtitle: 'Anotar fecha y peso del becerro',
                  color: Colors.brown,
                  onTap: (context) =>
                      context.pushNamed(AppRoutes.nameRegistroDestete),
                ),
                _RegistroCardItem(
                  icon: Icons.monitor_weight,
                  label: 'Peso',
                  subtitle: 'Guardar el peso y la fecha de medición',
                  color: Colors.green,
                  onTap: (context) =>
                      context.pushNamed(AppRoutes.nameRegistroPeso),
                ),
                _RegistroCardItem(
                  icon: Icons.medical_services,
                  label: 'Sanitario',
                  subtitle: 'Registrar vacuna, tratamiento o revisión',
                  color: Colors.teal,
                  onTap: (context) =>
                      context.pushNamed(AppRoutes.nameRegistroSanitario),
                ),
                _RegistroCardItem(
                  icon: Icons.payments,
                  label: 'Costo',
                  subtitle: 'Anotar un gasto asociado al animal',
                  color: Colors.brown,
                  onTap: (context) =>
                      context.pushNamed(AppRoutes.nameRegistroCosto),
                ),
                _RegistroCardItem(
                  icon: Icons.swap_horiz,
                  label: 'Cambio de ubicación',
                  subtitle: 'Mover el animal a otro rancho o potrero',
                  color: Colors.indigo,
                  onTap: (context) =>
                      context.pushNamed(AppRoutes.nameRegistroMovimiento),
                ),
                _RegistroCardItem(
                  icon: Icons.analytics,
                  label: 'Producción',
                  subtitle: 'Registrar ganancia o condición corporal',
                  color: Colors.blue,
                  onTap: (context) =>
                      context.pushNamed(AppRoutes.nameRegistroProduccion),
                ),
                _RegistroCardItem(
                  icon: Icons.water_drop,
                  label: 'Ordeña',
                  subtitle: 'Anotar leche por vaca o por lote',
                  color: Colors.lightBlue.shade700,
                  onTap: (context) =>
                      context.pushNamed(AppRoutes.nameRegistroOrdena),
                ),
                _RegistroCardItem(
                  icon: Icons.favorite,
                  label: 'Reproducción',
                  subtitle: 'Registrar servicio, diagnóstico o parto',
                  color: Colors.deepOrange,
                  onTap: (context) =>
                      context.pushNamed(AppRoutes.nameRegistroReproduccion),
                ),
                _RegistroCardItem(
                  icon: Icons.store,
                  label: 'Comercial',
                  subtitle: 'Guardar una compra o venta',
                  color: Colors.purple,
                  onTap: (context) =>
                      context.pushNamed(AppRoutes.nameRegistroComercial),
                ),
              ],
            ),
          ]),
          _RegistroSection(
            label: 'Plantas',
            isCategory: true,
            items: [
              _RegistroCardItem(
                icon: Icons.grass,
                label: 'Añadir planta o cultivo',
                subtitle: 'Crear una ficha de cultivo',
                color: Colors.lightGreen,
                onTap: _handleNewCrop,
              ),
              _RegistroCardItem(
                icon: Icons.agriculture,
                label: 'Cosecha',
                subtitle: 'Registrar cantidad y rendimiento',
                color: Colors.orange,
                onTap: (context) {
                  _handleCropRecord(context, _CropRecordMenuAction.harvest);
                },
              ),
              _RegistroCardItem(
                icon: Icons.water_drop,
                label: 'Riego',
                subtitle: 'Anotar riego y cantidad de agua',
                color: Colors.blueAccent,
                onTap: (context) {
                  _handleCropRecord(context, _CropRecordMenuAction.watering);
                },
              ),
              _RegistroCardItem(
                icon: Icons.health_and_safety,
                label: 'Salud de cultivo',
                subtitle: 'Registrar plagas, enfermedad o tratamiento',
                color: Colors.redAccent,
                onTap: (context) {
                  _handleCropRecord(context, _CropRecordMenuAction.health);
                },
              ),
              _RegistroCardItem(
                icon: Icons.task_alt,
                label: 'Tarea',
                subtitle: 'Programar una labor para el cultivo',
                color: Colors.amber,
                onTap: (context) {
                  _handleCropRecord(context, _CropRecordMenuAction.task);
                },
              ),
            ],
          ),
          _RegistroSection(
            label: 'Ubicaciones',
            isCategory: true,
            items: [
              _RegistroCardItem(
                icon: Icons.place,
                label: 'Nueva ubicación',
                subtitle: 'Crear un rancho, potrero o área de cultivo',
                color: AppColors.accent,
                onTap: (context) =>
                    context.pushNamed(AppRoutes.nameRegistroMenuUbicacionNueva),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _handleNewCrop(BuildContext context) {
    if (_cultivationRepository == null) {
      _showMessage('El catálogo de cultivos no está disponible.');
      return;
    }
    context.pushNamed(AppRoutes.nameRegistroMenuCultivoNuevo);
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
  const _SectionLabel({required this.label, required this.isCategory});
  final String label;
  final bool isCategory;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      header: true,
      child: Text(
        label,
        style:
            (isCategory
                    ? Theme.of(context).textTheme.titleLarge
                    : Theme.of(context).textTheme.titleMedium)
                ?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface,
                  fontWeight: FontWeight.w700,
                ),
      ),
    );
  }
}

class _RegistroMenuContent extends StatelessWidget {
  const _RegistroMenuContent({required this.sections});

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
                  if (section.isCategory && section != sections.first)
                    const SizedBox(height: AppSpacing.sm),
                  _SectionLabel(
                    label: section.label,
                    isCategory: section.isCategory,
                  ),
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
        final width = MediaQuery.sizeOf(context).width;
        final columns = largeText
            ? 1
            : (width >= 960 ? 3 : (width >= 600 ? 2 : 1));
        if (columns == 1) {
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
        for (var i = 0; i < items.length; i += columns) {
          rows.add(
            Row(
              children: [
                for (var column = 0; column < columns; column++) ...[
                  if (column > 0) const SizedBox(width: 12),
                  Expanded(
                    child: i + column < items.length
                        ? _RegistroCard(item: items[i + column])
                        : const SizedBox(),
                  ),
                ],
              ],
            ),
          );
          if (i + columns < items.length) {
            rows.add(const SizedBox(height: 12));
          }
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
    const iconSize = 16.0;
    const iconInnerSize = 16.0;
    const chevronSize = 20.0;
    const chevronIcon = 14.0;
    const hPad = AppSpacing.md;
    const vPad = AppSpacing.xs;
    const iconGap = AppSpacing.sm;
    final titleStyle = theme.textTheme.titleSmall?.copyWith(
      fontWeight: FontWeight.w700,
      fontSize: 14,
    );
    final largeText = MediaQuery.textScalerOf(context).scale(1) >= 1.5;
    return Material(
      color: bgColor,
      borderRadius: BorderRadius.circular(16),
      child: Semantics(
        key: ValueKey('registro-card-${item.label}'),
        button: true,
        enabled: !_opening,
        label: '${item.label}. ${item.subtitle}',
        hint: item.hint,
        onTap: _opening ? null : _open,
        child: ExcludeSemantics(
          child: DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
              ),
            ),
            child: InkWell(
              excludeFromSemantics: true,
              borderRadius: BorderRadius.circular(16),
              onTap: _opening ? null : _open,
              child: ConstrainedBox(
                constraints: const BoxConstraints(minHeight: 64),
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
                        child: Icon(
                          item.icon,
                          color: color,
                          size: iconInnerSize,
                        ),
                      ),
                      const SizedBox(width: iconGap),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              item.label,
                              maxLines: largeText ? null : 2,
                              overflow: TextOverflow.ellipsis,
                              style: titleStyle,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              item.subtitle,
                              maxLines: largeText ? null : 2,
                              overflow: TextOverflow.ellipsis,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                                fontSize: 12,
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
                          color: _opening
                              ? color.withValues(alpha: 0.55)
                              : color,
                          size: chevronIcon,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _RegistroSection {
  const _RegistroSection({
    required this.label,
    required this.items,
    this.isCategory = false,
  });

  final String label;
  final List<_RegistroCardItem> items;
  final bool isCategory;
}

class _RegistroCardItem {
  const _RegistroCardItem({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.color,
    required this.onTap,
    this.hint = 'Abrir formulario',
  });

  final IconData icon;
  final String label;
  final String subtitle;
  final Color color;
  final void Function(BuildContext context) onTap;
  final String hint;

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
