/// features \u203a registro \u203a view \u203a registro_page \u2014 entry page for the registro module showing record type selection.
library;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:libretapp/core/di/injection.dart';
import 'package:libretapp/core/router/app_routes.dart';
import 'package:libretapp/features/ubicaciones/domain/entities/crop_records.dart';
import 'package:libretapp/features/ubicaciones/domain/entities/location_entity.dart';
import 'package:libretapp/features/ubicaciones/domain/repositories/location_repository.dart';
import 'package:libretapp/features/ubicaciones/widgets/crop_sheets.dart';
import 'package:libretapp/theme/app_theme.dart';

class RegistroPage extends StatefulWidget {
  const RegistroPage({super.key});

  @override
  State<RegistroPage> createState() => _RegistroPageState();
}

class _RegistroPageState extends State<RegistroPage> {
  late final LocationRepository _locationRepository;

  @override
  void initState() {
    super.initState();
    _locationRepository = locator<LocationRepository>();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Menu de registros'),
          elevation: 0,
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Animal'),
              Tab(text: 'Ubicacion'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _RegistroTabContent(
              sections: [
                _RegistroSection(
                  label: 'Nuevo',
                  items: [
                    _RegistroCardItem(
                      icon: Icons.pets,
                      label: 'Animal',
                      subtitle: 'Nuevo animal',
                      color: AppColors.primary,
                      large: true,
                      onTap: (context) =>
                          context.goNamed(AppRoutes.nameAnimalNuevo),
                    ),
                    _RegistroCardItem(
                      icon: Icons.groups,
                      label: 'Lote',
                      subtitle: 'Nuevo lote',
                      color: AppColors.secondary,
                      large: true,
                      onTap: (context) =>
                          context.goNamed(AppRoutes.nameLoteNuevo),
                    ),
                    _RegistroCardItem(
                      icon: Icons.child_care,
                      label: 'Paricion',
                      subtitle: 'Registro de paricion',
                      color: Colors.pink,
                      featured: true,
                      large: true,
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
                      label: 'Cambio de ubicacion',
                      subtitle: 'Movimiento interno',
                      color: Colors.indigo,
                      onTap: (context) =>
                          context.pushNamed(AppRoutes.nameRegistroMovimiento),
                    ),
                    _RegistroCardItem(
                      icon: Icons.analytics,
                      label: 'Produccion',
                      subtitle: 'Ganancia o condicion',
                      color: Colors.blue,
                      onTap: (context) =>
                          context.pushNamed(AppRoutes.nameRegistroProduccion),
                    ),
                    _RegistroCardItem(
                      icon: Icons.water_drop,
                      label: 'Ordeña',
                      subtitle: 'Leche por vaca o lote',
                      color: Colors.lightBlue.shade700,
                      featured: true,
                      onTap: (context) =>
                          context.pushNamed(AppRoutes.nameRegistroOrdena),
                    ),
                    _RegistroCardItem(
                      icon: Icons.favorite,
                      label: 'Reproduccion',
                      subtitle: 'Servicio o paricion',
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
              ],
            ),
            _RegistroTabContent(
              sections: [
                _RegistroSection(
                  label: 'Nuevo',
                  items: [
                    _RegistroCardItem(
                      icon: Icons.place,
                      label: 'Ubicacion',
                      subtitle: 'Nueva ubicacion',
                      color: AppColors.accent,
                      onTap: (context) =>
                          context.goNamed(AppRoutes.nameUbicacionNueva),
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
    final locations = await _locationRepository.getAll();
    if (!mounted) return;
    if (locations.isEmpty) {
      _showMessage('Primero crea una ubicacion para registrar cultivos.');
      return;
    }

    final location = await _pickLocation(context, locations);
    if (!mounted || location == null) return;

    final crop = await showModalBottomSheet<CropRecord>(
      context: context,
      isScrollControlled: true,
      builder: (sheetContext) => CropFormSheet(locationName: location.name),
    );
    if (!mounted || crop == null) return;

    await _locationRepository.addCrop(location.uuid, crop);
    if (!mounted) return;
    _showMessage('Cultivo registrado en ${location.name}.');
  }

  Future<void> _handleCropRecord(
    BuildContext context,
    _CropRecordMenuAction action,
  ) async {
    final locations = await _locationRepository.getAll();
    if (!mounted) return;
    final withCrops = locations
        .where((location) => location.crops.isNotEmpty)
        .toList();
    if (withCrops.isEmpty) {
      _showMessage('No hay cultivos disponibles para registrar.');
      return;
    }

    final selection = await _pickLocationAndCrop(context, withCrops, action);
    if (!mounted || selection == null) return;

    final location = selection.location;
    final crop = selection.crop;

    switch (action) {
      case _CropRecordMenuAction.harvest:
        final record = await showModalBottomSheet<HarvestRecord>(
          context: context,
          isScrollControlled: true,
          builder: (sheetContext) => HarvestFormSheet(cropName: crop.cropName),
        );
        if (!mounted || record == null) return;
        await _locationRepository.addHarvest(location.uuid, crop.uuid, record);
        break;
      case _CropRecordMenuAction.watering:
        final record = await showModalBottomSheet<CropWateringRecord>(
          context: context,
          isScrollControlled: true,
          builder: (sheetContext) =>
              CropWateringFormSheet(cropName: crop.cropName),
        );
        if (!mounted || record == null) return;
        await _locationRepository.addCropWatering(
          location.uuid,
          crop.uuid,
          record,
        );
        break;
      case _CropRecordMenuAction.health:
        final record = await showModalBottomSheet<CropHealthRecord>(
          context: context,
          isScrollControlled: true,
          builder: (sheetContext) =>
              CropHealthFormSheet(cropName: crop.cropName),
        );
        if (!mounted || record == null) return;
        await _locationRepository.addCropHealth(
          location.uuid,
          crop.uuid,
          record,
        );
        break;
      case _CropRecordMenuAction.task:
        final task = await showModalBottomSheet<CropTask>(
          context: context,
          isScrollControlled: true,
          builder: (sheetContext) => CropTaskFormSheet(cropName: crop.cropName),
        );
        if (!mounted || task == null) return;
        await _locationRepository.addCropTask(location.uuid, crop.uuid, task);
        break;
    }

    if (!mounted) return;
    _showMessage('${action.successMessage} en ${crop.cropName}.');
  }

  Future<LocationEntity?> _pickLocation(
    BuildContext context,
    List<LocationEntity> locations,
  ) {
    String selectedUuid = locations.first.uuid;
    return showDialog<LocationEntity>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (stateContext, setDialogState) => AlertDialog(
            title: const Text('Seleccionar ubicacion'),
            content: DropdownButtonFormField<String>(
              value: selectedUuid,
              decoration: const InputDecoration(labelText: 'Ubicacion'),
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
    _CropRecordMenuAction action,
  ) {
    String locationUuid = locations.first.uuid;
    String cropUuid = locations.first.crops.first.uuid;

    return showDialog<_LocationCropSelection>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (stateContext, setDialogState) {
            final selectedLocation = locations.firstWhere(
              (location) => location.uuid == locationUuid,
            );
            final crops = selectedLocation.crops;
            if (!crops.any((crop) => crop.uuid == cropUuid)) {
              cropUuid = crops.first.uuid;
            }

            return AlertDialog(
              title: Text('Registrar ${action.label.toLowerCase()}'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButtonFormField<String>(
                    value: locationUuid,
                    decoration: const InputDecoration(labelText: 'Ubicacion'),
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
                    value: cropUuid,
                    decoration: const InputDecoration(labelText: 'Cultivo'),
                    isExpanded: true,
                    items: crops
                        .map(
                          (crop) => DropdownMenuItem<String>(
                            value: crop.uuid,
                            child: Text(crop.cropName),
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
                    final crop = location.crops.firstWhere(
                      (item) => item.uuid == cropUuid,
                    );
                    Navigator.of(dialogContext).pop(
                      _LocationCropSelection(location: location, crop: crop),
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
      padding: const EdgeInsets.all(4),
      children: [
        for (final section in sections) ...[
          _SectionLabel(label: section.label),
          const SizedBox(height: 10),
          _RegistroCardGrid(items: section.items),
          const SizedBox(height: 20),
        ],
      ],
    );
  }
}

class _RegistroCardGrid extends StatelessWidget {
  const _RegistroCardGrid({required this.items});

  final List<_RegistroCardItem> items;

  @override
  Widget build(BuildContext context) {
    final rows = <Widget>[];
    int i = 0;
    while (i < items.length) {
      final item = items[i];
      if (item.featured) {
        rows.add(_RegistroCard(item: item));
        i++;
      } else {
        final next = (i + 1 < items.length && !items[i + 1].featured)
            ? items[i + 1]
            : null;
        rows.add(
          Row(
            children: [
              Expanded(child: _RegistroCard(item: item)),
              const SizedBox(width: 10),
              if (next != null)
                Expanded(child: _RegistroCard(item: next))
              else
                const Expanded(child: SizedBox()),
            ],
          ),
        );
        i += next != null ? 2 : 1;
      }
      if (i < items.length) rows.add(const SizedBox(height: 10));
    }
    return Column(children: rows);
  }
}

class _RegistroCard extends StatelessWidget {
  const _RegistroCard({required this.item});

  final _RegistroCardItem item;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bgColor = item.featured
        ? item.color.withValues(alpha: 0.08)
        : theme.colorScheme.surfaceContainerLow;
    final iconSize = item.large ? 52.0 : 38.0;
    final iconInnerSize = item.large ? 26.0 : 20.0;
    final chevronSize = item.large ? 24.0 : 20.0;
    final chevronIcon = item.large ? 14.0 : 12.0;
    final hPad = item.large ? 10.0 : 8.0;
    final vPad = item.large ? 18.0 : 12.0;
    final iconGap = item.large ? 14.0 : 8.0;
    final titleStyle = item.large
        ? theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)
        : theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700);
    return Material(
      color: bgColor,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => item.onTap(context),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: hPad, vertical: vPad),
          child: Row(
            children: [
              Container(
                width: iconSize,
                height: iconSize,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: item.color.withValues(alpha: 0.15),
                ),
                child: Icon(item.icon, color: item.color, size: iconInnerSize),
              ),
              SizedBox(width: iconGap),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      item.label,
                      maxLines: 1,
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
                  color: item.color.withValues(alpha: 0.15),
                ),
                child: Icon(
                  Icons.chevron_right,
                  color: item.color,
                  size: chevronIcon,
                ),
              ),
            ],
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
    this.featured = false,
    this.large = false,
  });

  final IconData icon;
  final String label;
  final String subtitle;
  final Color color;
  final void Function(BuildContext context) onTap;
  final bool featured;
  final bool large;

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
  const _LocationCropSelection({required this.location, required this.crop});

  final LocationEntity location;
  final CropRecord crop;
}
