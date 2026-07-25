/// features › ubicaciones › widgets › location_form_sheet — bottom sheet form for creating or editing a location.
library;

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:libretapp/core/utils/id_generator.dart';
import 'package:libretapp/features/ubicaciones/domain/entities/dynamic_attribute.dart';
import 'package:libretapp/features/ubicaciones/domain/entities/location_entity.dart';
import 'package:libretapp/features/ubicaciones/domain/enums/location_category.dart';
import 'package:libretapp/features/ubicaciones/domain/enums/location_status.dart';
import 'package:libretapp/features/ubicaciones/domain/enums/location_type.dart';
import 'package:libretapp/features/ubicaciones/widgets/location_labels.dart';

class LocationFormSheet extends StatefulWidget {
  const LocationFormSheet({
    super.key,
    this.initial,
    this.onSubmit,
    this.allLocations = const [],
    this.presetParentUuid,
  });

  final LocationEntity? initial;
  final ValueChanged<LocationEntity>? onSubmit;
  final List<LocationEntity> allLocations;
  final String? presetParentUuid;

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
  final Map<String, TextEditingController> _adaptiveTextControllers = {};
  final Map<String, bool> _adaptiveBoolValues = {};
  late LocationType _type;
  late LocationCategory _selectedCategory;
  late LocationStatus _status;
  String? _parentUuid;
  late List<String> _imagePaths;

  @override
  void initState() {
    super.initState();
    final initial = widget.initial;
    _type = initial?.type ?? LocationType.pasture;
    _selectedCategory = _type.category;
    _status = initial?.status ?? LocationStatus.available;
    _parentUuid = initial?.parentUuid ?? widget.presetParentUuid;
    _imagePaths = List<String>.from(initial?.imagePaths ?? const []);
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

    for (final field in _adaptiveFieldsForType(_type)) {
      _ensureAdaptiveFieldState(field);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _surfaceController.dispose();
    _capacityController.dispose();
    _waterController.dispose();
    _terrainController.dispose();
    for (final controller in _adaptiveTextControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  List<LocationEntity> get _validParents {
    final selfUuid = widget.initial?.uuid ?? '';
    if (_type == LocationType.ejido) {
      return widget.allLocations
          .where(
            (l) =>
                l.uuid != selfUuid &&
                l.type == LocationType.monte &&
                l.isCommunal,
          )
          .toList(growable: false);
    }
    // Water resources can be placed under any location.
    if (_type.category == LocationCategory.water) {
      return widget.allLocations
          .where((l) => l.uuid != selfUuid)
          .toList(growable: false);
    }
    return widget.allLocations
        .where((l) => l.type.isRootType && l.uuid != selfUuid)
        .toList(growable: false);
  }

  List<LocationType> get _typesInSelectedCategory => LocationType.values
      .where((type) => type.category == _selectedCategory)
      .toList(growable: false);

  List<_AdaptiveFieldSpec> get _adaptiveFields => _adaptiveFieldsForType(_type);

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.initial != null;
    final theme = Theme.of(context);

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
                    isEditing ? 'Editar ubicacion' : 'Nueva ubicacion',
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
              _buildImagesSection(theme),
              const SizedBox(height: 12),
              Text(
                'Categoria',
                style: theme.textTheme.labelMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                height: 36,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: LocationCategory.values.length,
                  separatorBuilder: (_, i) => const SizedBox(width: 6),
                  itemBuilder: (context, index) {
                    final category = LocationCategory.values[index];
                    final selected = _selectedCategory == category;
                    return ChoiceChip(
                      label: Text(locationCategoryLabel(context, category)),
                      selected: selected,
                      visualDensity: VisualDensity.compact,
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      onSelected: (_) {
                        if (selected) return;
                        final firstType = LocationType.values.firstWhere(
                          (type) => type.category == category,
                        );
                        setState(() {
                          _selectedCategory = category;
                          _type = firstType;
                          for (final field in _adaptiveFieldsForType(_type)) {
                            _ensureAdaptiveFieldState(field);
                          }
                          if (_parentUuid != null) {
                            final stillValid = _validParents.any(
                              (location) => location.uuid == _parentUuid,
                            );
                            if (!stillValid) _parentUuid = null;
                          }
                        });
                      },
                    );
                  },
                ),
              ),
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: theme.colorScheme.outlineVariant.withValues(
                      alpha: 0.5,
                    ),
                  ),
                ),
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _typesInSelectedCategory
                      .map((type) {
                        final selected = _type == type;
                        return FilterChip(
                          label: Text(locationTypeLabel(context, type)),
                          selected: selected,
                          visualDensity: VisualDensity.compact,
                          materialTapTargetSize:
                              MaterialTapTargetSize.shrinkWrap,
                          onSelected: (_) {
                            if (selected) return;
                            setState(() {
                              _type = type;
                              _selectedCategory = type.category;
                              for (final field in _adaptiveFieldsForType(
                                _type,
                              )) {
                                _ensureAdaptiveFieldState(field);
                              }
                              if (_parentUuid != null) {
                                final stillValid = _validParents.any(
                                  (location) => location.uuid == _parentUuid,
                                );
                                if (!stillValid) _parentUuid = null;
                              }
                            });
                          },
                        );
                      })
                      .toList(growable: false),
                ),
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
                      (s) => DropdownMenuItem(
                        value: s,
                        child: Text(locationStatusLabel(context, s)),
                      ),
                    )
                    .toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _status = value;
                    });
                  }
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
                        final raw = value?.trim() ?? '';
                        if (raw.isEmpty) return null;
                        final parsed = double.tryParse(
                          raw.replaceAll(',', '.'),
                        );
                        if (parsed == null || parsed < 0) {
                          return 'Ingresa una superficie valida';
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
                        final raw = value?.trim() ?? '';
                        if (raw.isEmpty) return null;
                        final parsed = int.tryParse(raw);
                        if (parsed == null || parsed < 0) {
                          return 'Ingresa una capacidad valida';
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
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _terrainController,
                decoration: const InputDecoration(
                  labelText: 'Tipo de terreno',
                  prefixIcon: Icon(Icons.terrain),
                ),
              ),
              const SizedBox(height: 12),
              _buildAdaptivePropertiesSection(theme),
              if (_type.canNestAsSubLocation || !_type.isRootType) ...[
                const SizedBox(height: 12),
                DropdownButtonFormField<String?>(
                  value: _parentUuid,
                  decoration: const InputDecoration(
                    labelText: 'Ubicación padre (opcional)',
                    prefixIcon: Icon(Icons.account_tree_outlined),
                  ),
                  items: [
                    const DropdownMenuItem(
                      value: null,
                      child: Text('Sin ubicación padre'),
                    ),
                    ..._validParents.map(
                      (r) => DropdownMenuItem(
                        value: r.uuid,
                        child: Text(
                          '${locationTypeLabel(context, r.type)} · ${r.name}',
                        ),
                      ),
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

  Widget _buildImagesSection(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Imágenes',
              style: theme.textTheme.labelMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w600,
              ),
            ),
            const Spacer(),
            TextButton.icon(
              onPressed: () { _pickImage(); },
              icon: const Icon(Icons.add_photo_alternate_outlined, size: 18),
              label: const Text('Agregar'),
              style: TextButton.styleFrom(
                visualDensity: VisualDensity.compact,
              ),
            ),
          ],
        ),
        if (_imagePaths.isEmpty)
          GestureDetector(
            onTap: () { _pickImage(); },
            child: Container(
              height: 90,
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerLow,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
                  style: BorderStyle.solid,
                ),
              ),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.add_a_photo_outlined,
                      size: 28,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Toca para agregar fotos',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          )
        else
          SizedBox(
            height: 90,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _imagePaths.length + 1,
              separatorBuilder: (_, i) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                if (index == _imagePaths.length) {
                  return GestureDetector(
                    onTap: () { _pickImage(); },
                    child: Container(
                      width: 90,
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surfaceContainerLow,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: theme.colorScheme.outlineVariant
                              .withValues(alpha: 0.5),
                        ),
                      ),
                      child: Icon(
                        Icons.add_photo_alternate_outlined,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  );
                }
                final path = _imagePaths[index];
                return Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.file(
                        File(path),
                        width: 90,
                        height: 90,
                        fit: BoxFit.cover,
                        errorBuilder: (_, err, __) => Container(
                          width: 90,
                          height: 90,
                          decoration: BoxDecoration(
                            color: theme.colorScheme.surfaceContainerLow,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(Icons.broken_image_outlined),
                        ),
                      ),
                    ),
                    Positioned(
                      top: 4,
                      right: 4,
                      child: GestureDetector(
                        onTap: () => setState(() => _imagePaths.removeAt(index)),
                        child: Container(
                          width: 22,
                          height: 22,
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.6),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.close,
                            size: 14,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
      ],
    );
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickMultiImage(imageQuality: 80);
    if (picked.isEmpty) return;
    setState(() {
      for (final img in picked) {
        if (!_imagePaths.contains(img.path)) {
          _imagePaths.add(img.path);
        }
      }
    });
  }

  Widget _buildAdaptivePropertiesSection(ThemeData theme) {
    final fields = _adaptiveFields;
    if (fields.isEmpty) {
      return const SizedBox.shrink();
    }

    for (final field in fields) {
      _ensureAdaptiveFieldState(field);
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Propiedades de ${locationTypeLabel(context, _type)}',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Completa solo lo que aplique para esta ubicacion.',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 12),
          ...fields.map(_buildAdaptiveField),
        ],
      ),
    );
  }

  Widget _buildAdaptiveField(_AdaptiveFieldSpec field) {
    switch (field.kind) {
      case _AdaptiveFieldKind.boolean:
        return SwitchListTile.adaptive(
          contentPadding: EdgeInsets.zero,
          dense: true,
          title: Text(locationPropertyLabel(context, field.key)),
          value: _adaptiveBoolValues[field.key] ?? false,
          onChanged: (value) {
            setState(() {
              _adaptiveBoolValues[field.key] = value;
            });
          },
        );
      case _AdaptiveFieldKind.text:
      case _AdaptiveFieldKind.number:
      case _AdaptiveFieldKind.integer:
        final controller = _adaptiveTextControllers[field.key]!;
        final keyboardType = switch (field.kind) {
          _AdaptiveFieldKind.number => const TextInputType.numberWithOptions(
            decimal: true,
          ),
          _AdaptiveFieldKind.integer => TextInputType.number,
          _AdaptiveFieldKind.text ||
          _AdaptiveFieldKind.boolean => TextInputType.text,
        };

        return Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: TextFormField(
            controller: controller,
            keyboardType: keyboardType,
            decoration: InputDecoration(
              labelText: locationPropertyLabel(context, field.key),
              suffixText: field.unit,
            ),
            validator: (value) {
              final raw = value?.trim() ?? '';
              if (raw.isEmpty) return null;
              if (field.kind == _AdaptiveFieldKind.number) {
                final parsed = double.tryParse(raw.replaceAll(',', '.'));
                if (parsed == null) {
                  return 'Valor numerico invalido';
                }
              }
              if (field.kind == _AdaptiveFieldKind.integer) {
                final parsed = int.tryParse(raw);
                if (parsed == null) {
                  return 'Valor entero invalido';
                }
              }
              return null;
            },
          ),
        );
    }
  }

  void _ensureAdaptiveFieldState(_AdaptiveFieldSpec field) {
    if (field.kind == _AdaptiveFieldKind.boolean) {
      _adaptiveBoolValues[field.key] ??= _initialBoolValueForKey(field);
      return;
    }
    _adaptiveTextControllers.putIfAbsent(
      field.key,
      () => TextEditingController(text: _initialTextValueForKey(field)),
    );
  }

  String _initialTextValueForKey(_AdaptiveFieldSpec field) {
    final initial = widget.initial;
    if (initial == null) return '';

    final dedicated = field.dedicatedField;
    if (dedicated == _DedicatedField.geometry) {
      return initial.geometry ?? '';
    }

    DynamicAttribute? attribute;
    for (final item in initial.attributes) {
      if (item.key == field.key) {
        attribute = item;
        break;
      }
    }

    if (attribute == null) return '';

    switch (attribute.type) {
      case DynamicAttributeType.text:
        return attribute.textValue ?? '';
      case DynamicAttributeType.integer:
      case DynamicAttributeType.number:
        return attribute.numberValue?.toString() ?? '';
      case DynamicAttributeType.boolean:
        return (attribute.boolValue ?? false) ? 'Si' : 'No';
    }
  }

  bool _initialBoolValueForKey(_AdaptiveFieldSpec field) {
    final initial = widget.initial;
    if (initial == null) return false;

    final dedicated = field.dedicatedField;
    if (dedicated == _DedicatedField.isShared) {
      return initial.isShared;
    }
    if (dedicated == _DedicatedField.isCommunal) {
      return initial.isCommunal;
    }

    for (final item in initial.attributes) {
      if (item.key == field.key && item.type == DynamicAttributeType.boolean) {
        return item.boolValue ?? false;
      }
    }

    return false;
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    final surfaceRaw = _surfaceController.text.trim();
    final capacityRaw = _capacityController.text.trim();

    final surface = surfaceRaw.isEmpty
        ? (widget.initial?.surfaceArea ?? 0)
        : (double.tryParse(surfaceRaw.replaceAll(',', '.')) ?? 0);
    final capacity = capacityRaw.isEmpty
        ? (widget.initial?.capacity ?? 0)
        : (int.tryParse(capacityRaw) ?? 0);

    final now = DateTime.now();
    final fields = _adaptiveFields;
    final activeFieldKeys = fields.map((field) => field.key).toSet();

    final preservedAttributes =
        widget.initial?.attributes
            .where((item) => !activeFieldKeys.contains(item.key))
            .toList(growable: true) ??
        <DynamicAttribute>[];

    bool isShared = widget.initial?.isShared ?? false;
    bool isCommunal = widget.initial?.isCommunal ?? false;
    String? geometry = widget.initial?.geometry;

    for (final field in fields) {
      switch (field.kind) {
        case _AdaptiveFieldKind.boolean:
          final boolValue = _adaptiveBoolValues[field.key] ?? false;

          if (field.dedicatedField == _DedicatedField.isShared) {
            isShared = boolValue;
          }
          if (field.dedicatedField == _DedicatedField.isCommunal) {
            isCommunal = boolValue;
          }

          preservedAttributes.add(
            DynamicAttribute.boolean(
              key: field.key,
              label: locationPropertyLabel(context, field.key),
              value: boolValue,
              updatedAt: now,
            ),
          );
        case _AdaptiveFieldKind.number:
          final raw = _adaptiveTextControllers[field.key]?.text.trim() ?? '';
          if (raw.isEmpty) {
            if (field.dedicatedField == _DedicatedField.geometry) {
              geometry = null;
            }
            continue;
          }
          final value = double.tryParse(raw.replaceAll(',', '.'));
          if (value == null) continue;

          preservedAttributes.add(
            DynamicAttribute.number(
              key: field.key,
              label: locationPropertyLabel(context, field.key),
              value: value,
              unit: field.unit,
              updatedAt: now,
            ),
          );
        case _AdaptiveFieldKind.integer:
          final raw = _adaptiveTextControllers[field.key]?.text.trim() ?? '';
          if (raw.isEmpty) {
            if (field.dedicatedField == _DedicatedField.geometry) {
              geometry = null;
            }
            continue;
          }
          final value = int.tryParse(raw);
          if (value == null) continue;

          preservedAttributes.add(
            DynamicAttribute.integer(
              key: field.key,
              label: locationPropertyLabel(context, field.key),
              value: value,
              unit: field.unit,
              updatedAt: now,
            ),
          );
        case _AdaptiveFieldKind.text:
          final value = _adaptiveTextControllers[field.key]?.text.trim() ?? '';
          if (field.dedicatedField == _DedicatedField.geometry) {
            geometry = value.isEmpty ? null : value;
          }
          if (value.isEmpty) continue;

          preservedAttributes.add(
            DynamicAttribute.text(
              key: field.key,
              label: locationPropertyLabel(context, field.key),
              value: value,
              unit: field.unit,
              updatedAt: now,
            ),
          );
      }
    }

    final entity = LocationEntity(
      id: widget.initial?.id,
      uuid: widget.initial?.uuid ?? _randomId(),
      name: _nameController.text.trim(),
      type: _type,
      surfaceArea: surface,
      capacity: capacity,
      waterSource: _waterController.text.trim(),
      terrainType: _terrainController.text.trim(),
      category: _selectedCategory,
      geometry: geometry,
      isShared: isShared,
      isCommunal: isCommunal,
      imagePaths: List<String>.from(_imagePaths),
      attributes: preservedAttributes,
      parentUuid: _resolveParentUuid(),
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

  String? _resolveParentUuid() {
    if (_type.canNestAsSubLocation) return _parentUuid;
    if (_type.isRootType) return null;
    return _parentUuid;
  }
}

List<_AdaptiveFieldSpec> _adaptiveFieldsForType(LocationType type) {
  final base = List<_AdaptiveFieldSpec>.of(
    _baseAdaptiveFieldsByCategory[type.category] ?? const [],
  );
  base.addAll(_typeSpecificAdaptiveFields[type] ?? const []);
  return base;
}

enum _AdaptiveFieldKind { text, number, integer, boolean }

enum _DedicatedField { geometry, isShared, isCommunal }

class _AdaptiveFieldSpec {
  const _AdaptiveFieldSpec({
    required this.key,
    required this.kind,
    this.unit,
    this.dedicatedField,
  });

  final String key;
  final _AdaptiveFieldKind kind;
  final String? unit;
  final _DedicatedField? dedicatedField;
}

const Map<LocationCategory, List<_AdaptiveFieldSpec>>
_baseAdaptiveFieldsByCategory = {
  LocationCategory.macro: [
    _AdaptiveFieldSpec(key: 'registryCode', kind: _AdaptiveFieldKind.text),
    _AdaptiveFieldSpec(key: 'ownerName', kind: _AdaptiveFieldKind.text),
    _AdaptiveFieldSpec(
      key: 'isShared',
      kind: _AdaptiveFieldKind.boolean,
      dedicatedField: _DedicatedField.isShared,
    ),
    _AdaptiveFieldSpec(
      key: 'isCommunal',
      kind: _AdaptiveFieldKind.boolean,
      dedicatedField: _DedicatedField.isCommunal,
    ),
    _AdaptiveFieldSpec(
      key: 'geometry',
      kind: _AdaptiveFieldKind.text,
      dedicatedField: _DedicatedField.geometry,
    ),
  ],
  LocationCategory.livestock: [
    _AdaptiveFieldSpec(key: 'fenceCondition', kind: _AdaptiveFieldKind.text),
    _AdaptiveFieldSpec(
      key: 'shadeCoverage',
      kind: _AdaptiveFieldKind.number,
      unit: '%',
    ),
    _AdaptiveFieldSpec(key: 'handlingEase', kind: _AdaptiveFieldKind.text),
    _AdaptiveFieldSpec(key: 'hasWaterPoint', kind: _AdaptiveFieldKind.boolean),
    _AdaptiveFieldSpec(
      key: 'isShared',
      kind: _AdaptiveFieldKind.boolean,
      dedicatedField: _DedicatedField.isShared,
    ),
  ],
  LocationCategory.handling: [
    _AdaptiveFieldSpec(
      key: 'throughputPerHour',
      kind: _AdaptiveFieldKind.integer,
      unit: 'anim/h',
    ),
    _AdaptiveFieldSpec(key: 'floorType', kind: _AdaptiveFieldKind.text),
    _AdaptiveFieldSpec(key: 'roofed', kind: _AdaptiveFieldKind.boolean),
    _AdaptiveFieldSpec(
      key: 'geometry',
      kind: _AdaptiveFieldKind.text,
      dedicatedField: _DedicatedField.geometry,
    ),
  ],
  LocationCategory.agricultural: [
    _AdaptiveFieldSpec(key: 'soilClass', kind: _AdaptiveFieldKind.text),
    _AdaptiveFieldSpec(key: 'irrigationType', kind: _AdaptiveFieldKind.text),
    _AdaptiveFieldSpec(key: 'cropRotation', kind: _AdaptiveFieldKind.text),
    _AdaptiveFieldSpec(
      key: 'geometry',
      kind: _AdaptiveFieldKind.text,
      dedicatedField: _DedicatedField.geometry,
    ),
  ],
  LocationCategory.natural: [
    _AdaptiveFieldSpec(
      key: 'conservationStatus',
      kind: _AdaptiveFieldKind.text,
    ),
    _AdaptiveFieldSpec(key: 'biodiversityNotes', kind: _AdaptiveFieldKind.text),
    _AdaptiveFieldSpec(key: 'accessLevel', kind: _AdaptiveFieldKind.text),
    _AdaptiveFieldSpec(
      key: 'geometry',
      kind: _AdaptiveFieldKind.text,
      dedicatedField: _DedicatedField.geometry,
    ),
  ],
  LocationCategory.infrastructure: [
    _AdaptiveFieldSpec(key: 'serviceState', kind: _AdaptiveFieldKind.text),
    _AdaptiveFieldSpec(
      key: 'electricityAvailable',
      kind: _AdaptiveFieldKind.boolean,
    ),
    _AdaptiveFieldSpec(key: 'securityLevel', kind: _AdaptiveFieldKind.text),
    _AdaptiveFieldSpec(
      key: 'geometry',
      kind: _AdaptiveFieldKind.text,
      dedicatedField: _DedicatedField.geometry,
    ),
  ],
  LocationCategory.water: [
    _AdaptiveFieldSpec(key: 'waterQuality', kind: _AdaptiveFieldKind.text),
    _AdaptiveFieldSpec(
      key: 'flowRate',
      kind: _AdaptiveFieldKind.number,
      unit: 'l/s',
    ),
    _AdaptiveFieldSpec(
      key: 'storageVolume',
      kind: _AdaptiveFieldKind.number,
      unit: 'm3',
    ),
    _AdaptiveFieldSpec(
      key: 'geometry',
      kind: _AdaptiveFieldKind.text,
      dedicatedField: _DedicatedField.geometry,
    ),
  ],
};

const Map<LocationType, List<_AdaptiveFieldSpec>>
_typeSpecificAdaptiveFields = {
  LocationType.ranch: [
    _AdaptiveFieldSpec(key: 'herdManager', kind: _AdaptiveFieldKind.text),
  ],
  LocationType.farm: [
    _AdaptiveFieldSpec(key: 'productionFocus', kind: _AdaptiveFieldKind.text),
  ],
  LocationType.finca: [
    _AdaptiveFieldSpec(key: 'lotCount', kind: _AdaptiveFieldKind.integer),
  ],
  LocationType.hacienda: [
    _AdaptiveFieldSpec(key: 'historicalName', kind: _AdaptiveFieldKind.text),
  ],
  LocationType.plantation: [
    _AdaptiveFieldSpec(key: 'mainCrop', kind: _AdaptiveFieldKind.text),
  ],
  LocationType.ejido: [
    _AdaptiveFieldSpec(key: 'assemblyContact', kind: _AdaptiveFieldKind.text),
  ],
  LocationType.property: [
    _AdaptiveFieldSpec(key: 'cadastralId', kind: _AdaptiveFieldKind.text),
  ],
  LocationType.homestead: [
    _AdaptiveFieldSpec(key: 'householdCount', kind: _AdaptiveFieldKind.integer),
  ],
  LocationType.pasture: [
    _AdaptiveFieldSpec(key: 'pastureCondition', kind: _AdaptiveFieldKind.text),
  ],
  LocationType.corral: [
    _AdaptiveFieldSpec(key: 'corralMaterial', kind: _AdaptiveFieldKind.text),
  ],
  LocationType.feedlot: [
    _AdaptiveFieldSpec(key: 'feedlotStage', kind: _AdaptiveFieldKind.text),
  ],
  LocationType.barn: [
    _AdaptiveFieldSpec(key: 'ventilationType', kind: _AdaptiveFieldKind.text),
  ],
  LocationType.stable: [
    _AdaptiveFieldSpec(key: 'stallCount', kind: _AdaptiveFieldKind.integer),
  ],
  LocationType.pen: [
    _AdaptiveFieldSpec(key: 'penPurpose', kind: _AdaptiveFieldKind.text),
  ],
  LocationType.chute: [
    _AdaptiveFieldSpec(
      key: 'chuteLength',
      kind: _AdaptiveFieldKind.number,
      unit: 'm',
    ),
  ],
  LocationType.quarantineArea: [
    _AdaptiveFieldSpec(
      key: 'quarantineDays',
      kind: _AdaptiveFieldKind.integer,
      unit: 'dias',
    ),
  ],
  LocationType.loadingArea: [
    _AdaptiveFieldSpec(key: 'rampType', kind: _AdaptiveFieldKind.text),
  ],
  LocationType.weighingArea: [
    _AdaptiveFieldSpec(key: 'scaleType', kind: _AdaptiveFieldKind.text),
  ],
  LocationType.field: [
    _AdaptiveFieldSpec(key: 'currentCrop', kind: _AdaptiveFieldKind.text),
  ],
  LocationType.plot: [
    _AdaptiveFieldSpec(key: 'plotNumber', kind: _AdaptiveFieldKind.text),
  ],
  LocationType.milpa: [
    _AdaptiveFieldSpec(key: 'companionCrops', kind: _AdaptiveFieldKind.text),
  ],
  LocationType.orchard: [
    _AdaptiveFieldSpec(
      key: 'treeDensity',
      kind: _AdaptiveFieldKind.number,
      unit: 'arb/ha',
    ),
  ],
  LocationType.greenhouse: [
    _AdaptiveFieldSpec(key: 'greenhouseType', kind: _AdaptiveFieldKind.text),
  ],
  LocationType.nursery: [
    _AdaptiveFieldSpec(
      key: 'seedlingCapacity',
      kind: _AdaptiveFieldKind.integer,
    ),
  ],
  LocationType.garden: [
    _AdaptiveFieldSpec(key: 'gardenPurpose', kind: _AdaptiveFieldKind.text),
  ],
  LocationType.monte: [
    _AdaptiveFieldSpec(key: 'forageSpecies', kind: _AdaptiveFieldKind.text),
  ],
  LocationType.forest: [
    _AdaptiveFieldSpec(
      key: 'canopyCoverage',
      kind: _AdaptiveFieldKind.number,
      unit: '%',
    ),
  ],
  LocationType.lagoon: [
    _AdaptiveFieldSpec(
      key: 'lagoonDepth',
      kind: _AdaptiveFieldKind.number,
      unit: 'm',
    ),
  ],
  LocationType.river: [
    _AdaptiveFieldSpec(key: 'riverFlowSeason', kind: _AdaptiveFieldKind.text),
  ],
  LocationType.wetland: [
    _AdaptiveFieldSpec(key: 'wetlandType', kind: _AdaptiveFieldKind.text),
  ],
  LocationType.protectedArea: [
    _AdaptiveFieldSpec(
      key: 'protectionCategory',
      kind: _AdaptiveFieldKind.text,
    ),
  ],
  LocationType.warehouse: [
    _AdaptiveFieldSpec(key: 'storageClass', kind: _AdaptiveFieldKind.text),
  ],
  LocationType.workshop: [
    _AdaptiveFieldSpec(key: 'toolSpecialty', kind: _AdaptiveFieldKind.text),
  ],
  LocationType.office: [
    _AdaptiveFieldSpec(key: 'officeUse', kind: _AdaptiveFieldKind.text),
  ],
  LocationType.house: [
    _AdaptiveFieldSpec(key: 'occupancyType', kind: _AdaptiveFieldKind.text),
  ],
  LocationType.road: [
    _AdaptiveFieldSpec(key: 'roadSurface', kind: _AdaptiveFieldKind.text),
  ],
  LocationType.waterTank: [
    _AdaptiveFieldSpec(key: 'tankMaterial', kind: _AdaptiveFieldKind.text),
  ],
  LocationType.gate: [
    _AdaptiveFieldSpec(key: 'gateType', kind: _AdaptiveFieldKind.text),
  ],
  LocationType.well: [
    _AdaptiveFieldSpec(
      key: 'wellDepth',
      kind: _AdaptiveFieldKind.number,
      unit: 'm',
    ),
  ],
  LocationType.dam: [
    _AdaptiveFieldSpec(key: 'damType', kind: _AdaptiveFieldKind.text),
  ],
  LocationType.spring: [
    _AdaptiveFieldSpec(key: 'springProtection', kind: _AdaptiveFieldKind.text),
  ],
  LocationType.pond: [
    _AdaptiveFieldSpec(key: 'pondUse', kind: _AdaptiveFieldKind.text),
  ],
  LocationType.trough: [
    _AdaptiveFieldSpec(key: 'troughMaterial', kind: _AdaptiveFieldKind.text),
  ],
  LocationType.canal: [
    _AdaptiveFieldSpec(key: 'canalLining', kind: _AdaptiveFieldKind.text),
  ],
  LocationType.reservoir: [
    _AdaptiveFieldSpec(key: 'reservoirUse', kind: _AdaptiveFieldKind.text),
  ],
};

String _randomId() => generateId();
