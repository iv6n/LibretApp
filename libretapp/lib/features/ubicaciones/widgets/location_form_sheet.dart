/// features › ubicaciones › widgets › location_form_sheet — bottom sheet form for creating or editing a location.
library;

import 'package:flutter/material.dart';
import 'package:libretapp/core/utils/id_generator.dart';
import 'package:libretapp/features/ubicaciones/domain/entities/location_entity.dart';
import 'package:libretapp/features/ubicaciones/domain/enums/location_status.dart';
import 'package:libretapp/features/ubicaciones/domain/enums/location_type.dart';

class LocationFormSheet extends StatefulWidget {
  const LocationFormSheet({
    super.key,
    this.initial,
    this.onSubmit,
    this.ranchos = const [],
  });

  final LocationEntity? initial;
  final ValueChanged<LocationEntity>? onSubmit;
  final List<LocationEntity> ranchos;

  @override
  State<LocationFormSheet> createState() => _LocationFormSheetState();
}

class _LocationFormSheetState extends State<LocationFormSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _surfaceController;
  late final TextEditingController _capacityController;
  late final TextEditingController _waterController;
  late final TextEditingController _terrainController;
  late LocationType _type;
  late LocationStatus _status;
  String? _parentUuid;

  @override
  void initState() {
    super.initState();
    final initial = widget.initial;
    _type = initial?.type ?? LocationType.potrero;
    _status = initial?.status ?? LocationStatus.disponible;
    _parentUuid = initial?.parentUuid;
    _nameController = TextEditingController(text: initial?.name ?? '');
    _surfaceController = TextEditingController(
      text: initial?.surfaceArea.toString() ?? '',
    );
    _capacityController = TextEditingController(
      text: initial?.capacity.toString() ?? '',
    );
    _waterController = TextEditingController(text: initial?.waterSource ?? '');
    _terrainController = TextEditingController(
      text: initial?.terrainType ?? '',
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _surfaceController.dispose();
    _capacityController.dispose();
    _waterController.dispose();
    _terrainController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.initial != null;

    final viewInsets = MediaQuery.of(context).viewInsets.bottom;

    return SafeArea(
      child: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(20, 16, 20, 20 + viewInsets),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    isEditing ? 'Editar ubicación' : 'Nueva ubicación',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Nombre',
                  prefixIcon: Icon(Icons.place_outlined),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Ingresa un nombre';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<LocationType>(
                initialValue: _type,
                decoration: const InputDecoration(
                  labelText: 'Tipo',
                  prefixIcon: Icon(Icons.category_outlined),
                ),
                items: LocationType.values
                    .map(
                      (type) => DropdownMenuItem(
                        value: type,
                        child: Text(type.label),
                      ),
                    )
                    .toList(),
                onChanged: (value) {
                  if (value != null) setState(() => _type = value);
                },
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _surfaceController,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      decoration: const InputDecoration(
                        labelText: 'Superficie (ha)',
                        prefixIcon: Icon(Icons.straighten),
                      ),
                      validator: (value) {
                        final parsed = double.tryParse(
                          value?.replaceAll(',', '.') ?? '',
                        );
                        if (parsed == null || parsed <= 0) {
                          return 'Ingresa una superficie';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _capacityController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Capacidad (animales)',
                        prefixIcon: Icon(Icons.groups_outlined),
                      ),
                      validator: (value) {
                        final parsed = int.tryParse(value ?? '');
                        if (parsed == null || parsed < 0) {
                          return 'Ingresa una capacidad';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _waterController,
                decoration: const InputDecoration(
                  labelText: 'Fuente de agua',
                  prefixIcon: Icon(Icons.water_drop_outlined),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Ingresa la fuente de agua';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _terrainController,
                decoration: const InputDecoration(
                  labelText: 'Tipo de terreno',
                  prefixIcon: Icon(Icons.terrain),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Ingresa el tipo de terreno';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<LocationStatus>(
                initialValue: _status,
                decoration: const InputDecoration(
                  labelText: 'Estado',
                  prefixIcon: Icon(Icons.brightness_medium_outlined),
                ),
                items: LocationStatus.values
                    .map(
                      (s) => DropdownMenuItem(value: s, child: Text(s.label)),
                    )
                    .toList(),
                onChanged: (value) => setState(
                  () => _status = value ?? LocationStatus.disponible,
                ),
              ),
              if (!_type.isRootType && widget.ranchos.isNotEmpty) ...[
                const SizedBox(height: 12),
                DropdownButtonFormField<String?>(
                  value: _parentUuid,
                  decoration: const InputDecoration(
                    labelText: 'Rancho (opcional)',
                    prefixIcon: Icon(Icons.home_work_outlined),
                  ),
                  items: [
                    const DropdownMenuItem(
                      value: null,
                      child: Text('Sin rancho'),
                    ),
                    ...widget.ranchos.map(
                      (r) =>
                          DropdownMenuItem(value: r.uuid, child: Text(r.name)),
                    ),
                  ],
                  onChanged: (value) => setState(() => _parentUuid = value),
                ),
              ],
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  icon: Icon(
                    isEditing ? Icons.save_outlined : Icons.add_location_alt,
                  ),
                  label: Text(
                    isEditing ? 'Guardar cambios' : 'Crear ubicación',
                  ),
                  onPressed: _submit,
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    final surface = double.parse(_surfaceController.text.replaceAll(',', '.'));
    final capacity = int.parse(_capacityController.text);

    final entity = LocationEntity(
      id: widget.initial?.id,
      uuid: widget.initial?.uuid ?? _randomId(),
      name: _nameController.text.trim(),
      type: _type,
      surfaceArea: surface,
      capacity: capacity,
      waterSource: _waterController.text.trim(),
      terrainType: _terrainController.text.trim(),
      parentUuid: _type.isRootType ? null : _parentUuid,
      status: _status,
      visits: widget.initial?.visits ?? const [],
      waters: widget.initial?.waters ?? const [],
      salts: widget.initial?.salts ?? const [],
      shades: widget.initial?.shades ?? const [],
      pastures: widget.initial?.pastures ?? const [],
      seedings: widget.initial?.seedings ?? const [],
      irrigations: widget.initial?.irrigations ?? const [],
      rains: widget.initial?.rains ?? const [],
      costs: widget.initial?.costs ?? const [],
    );

    if (widget.onSubmit != null) {
      widget.onSubmit!(entity);
      return;
    }

    Navigator.of(context).pop(entity);
  }
}

String _randomId() => generateId();
