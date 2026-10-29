/// Progressive create/edit form for cultivations of every scale.
library;

import 'package:flutter/material.dart';
import 'package:libretapp/core/widgets/widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:libretapp/app/widgets/widgets.dart';
import 'package:libretapp/core/di/injection.dart';
import 'package:libretapp/core/router/app_routes.dart';
import 'package:libretapp/core/utils/number_parsing.dart';
import 'package:libretapp/features/directorio/cultivos/domain/cultivation_entity.dart';
import 'package:libretapp/features/directorio/cultivos/domain/cultivation_repository.dart';
import 'package:libretapp/features/ubicaciones/domain/crop_template.dart';
import 'package:libretapp/features/ubicaciones/domain/entities/location_entity.dart';
import 'package:libretapp/features/ubicaciones/domain/enums/crop_growth_stage.dart';
import 'package:libretapp/features/ubicaciones/domain/enums/crop_status.dart';
import 'package:libretapp/features/ubicaciones/domain/repositories/location_repository.dart';
import 'package:libretapp/features/ubicaciones/view/location_form_page.dart';

class CultivationFormPage extends StatefulWidget {
  CultivationFormPage({
    super.key,
    this.cultivationUuid,
    this.presetLocationUuid,
    CultivationRepository? repository,
    LocationRepository? locationRepository,
  }) : repository = repository ?? locator<CultivationRepository>(),
       locationRepository = locationRepository ?? locator<LocationRepository>();

  final String? cultivationUuid;
  final String? presetLocationUuid;
  final CultivationRepository repository;
  final LocationRepository locationRepository;

  bool get isEditing => cultivationUuid != null;

  @override
  State<CultivationFormPage> createState() => _CultivationFormPageState();
}

class _CultivationFormPageState extends State<CultivationFormPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _varietyController;
  late final TextEditingController _quantityController;
  late final TextEditingController _areaController;
  late final TextEditingController _frequencyController;
  late final TextEditingController _notesController;
  late final Future<_CultivationFormData> _loadFuture;

  CultivationScale _scale = CultivationScale.individual;
  CultivationAreaUnit _areaUnit = CultivationAreaUnit.squareMeters;
  CropGrowthStage _stage = CropGrowthStage.planted;
  CropStatus _status = CropStatus.active;
  DateTime _plantingDate = DateTime.now();
  DateTime? _expectedHarvestDate;
  String? _selectedLocationUuid;
  String? _templateKey;
  List<LocationEntity> _locations = const [];
  List<CultivationEntity> _allCultivations = const [];
  CultivationEntity? _initial;
  bool _hydrated = false;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _varietyController = TextEditingController();
    _quantityController = TextEditingController(text: '1');
    _areaController = TextEditingController();
    _frequencyController = TextEditingController(text: '3');
    _notesController = TextEditingController();
    _selectedLocationUuid = widget.presetLocationUuid;
    _loadFuture = _load();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _varietyController.dispose();
    _quantityController.dispose();
    _areaController.dispose();
    _frequencyController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<_CultivationFormData> _load() async {
    final results = await Future.wait<Object?>([
      widget.cultivationUuid == null
          ? Future<CultivationEntity?>.value()
          : widget.repository.getByUuid(widget.cultivationUuid!),
      widget.locationRepository.getAll(),
      widget.repository.getAll(),
    ]);
    return _CultivationFormData(
      cultivation: results[0] as CultivationEntity?,
      locations: results[1] as List<LocationEntity>,
      allCultivations: results[2] as List<CultivationEntity>,
    );
  }

  void _hydrate(_CultivationFormData data) {
    if (_hydrated) return;
    _hydrated = true;
    _locations = data.locations;
    _allCultivations = data.allCultivations;
    _initial = data.cultivation;
    final value = data.cultivation;
    if (value == null) return;
    _nameController.text = value.name;
    _varietyController.text = value.variety;
    _quantityController.text = value.quantity.toString();
    _areaController.text = value.displayArea == 0
        ? ''
        : value.displayArea.toString();
    _frequencyController.text = value.wateringFrequencyDays.toString();
    _notesController.text = value.notes ?? '';
    _scale = value.scale;
    _areaUnit = value.preferredAreaUnit;
    _stage = value.growthStage;
    _status = value.status;
    _plantingDate = value.plantingDate;
    _expectedHarvestDate = value.expectedHarvestDate;
    _selectedLocationUuid = value.locationUuid;
  }

  @override
  Widget build(BuildContext context) {
    return ShellChromeScope(
      visible: false,
      child: Scaffold(
        appBar: AppBar(
          title: GeneratedAssetTitle(
            title: widget.isEditing
                ? 'Editar planta o cultivo'
                : 'Nueva planta o cultivo',
            assetPath: RecordFormStyle.crop.assetPath,
            fallbackIcon: RecordFormStyle.crop.icon,
          ),
        ),
        body: FutureBuilder<_CultivationFormData>(
          future: _loadFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text(
                    'No se pudo abrir el formulario: ${snapshot.error}',
                  ),
                ),
              );
            }
            _hydrate(snapshot.data!);
            if (widget.isEditing && _initial == null) {
              return const Center(child: Text('Cultivo no encontrado'));
            }
            return _buildForm();
          },
        ),
      ),
    );
  }

  Widget _buildForm() {
    return AppFormBody(
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const AppRecordHeader(style: RecordFormStyle.crop),
            const SizedBox(height: 16),
            Text(
              '¿Qué vas a seguir?',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final scale in CultivationScale.values)
                  ChoiceChip(
                    selected: _scale == scale,
                    label: Text(scale.displayName),
                    avatar: Icon(_scaleIcon(scale), size: 18),
                    onSelected: (_) => setState(() => _scale = scale),
                  ),
              ],
            ),
            const SizedBox(height: 18),
            DropdownButtonFormField<String?>(
              initialValue: _templateKey,
              isExpanded: true,
              decoration: const InputDecoration(
                labelText: 'Plantilla de manejo (opcional)',
                prefixIcon: Icon(Icons.auto_awesome_outlined),
              ),
              items: [
                const DropdownMenuItem<String?>(
                  value: null,
                  child: Text('Sin plantilla'),
                ),
                for (final template in CropTemplateLibrary.templates)
                  DropdownMenuItem<String?>(
                    value: template.key,
                    child: Text('${template.name} · ${template.cycleType}'),
                  ),
              ],
              onChanged: _applyTemplate,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _nameController,
              textInputAction: TextInputAction.next,
              decoration: const InputDecoration(
                labelText: 'Nombre o especie *',
                prefixIcon: Icon(Icons.eco_outlined),
              ),
              validator: (value) => value == null || value.trim().isEmpty
                  ? 'Ingresa el nombre del cultivo'
                  : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _varietyController,
              textInputAction: TextInputAction.next,
              decoration: const InputDecoration(
                labelText: 'Variedad (opcional)',
                prefixIcon: Icon(Icons.category_outlined),
              ),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String?>(
              key: ValueKey(_selectedLocationUuid),
              initialValue: _selectedLocationUuid,
              isExpanded: true,
              decoration: const InputDecoration(
                labelText: 'Ubicación (opcional)',
                prefixIcon: Icon(Icons.location_on_outlined),
              ),
              items: [
                const DropdownMenuItem<String?>(
                  value: null,
                  child: Text('Sin ubicación'),
                ),
                for (final location in _locations)
                  DropdownMenuItem<String?>(
                    value: location.uuid,
                    child: Text(location.name),
                  ),
              ],
              onChanged: (value) =>
                  setState(() => _selectedLocationUuid = value),
            ),
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton.icon(
                onPressed: _createLocation,
                icon: const Icon(Icons.add_location_alt_outlined),
                label: const Text('Crear ubicación'),
              ),
            ),
            if (_scale == CultivationScale.group) ...[
              TextFormField(
                controller: _quantityController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Cantidad de plantas *',
                  prefixIcon: Icon(Icons.numbers),
                ),
                validator: (value) {
                  final quantity = int.tryParse(value ?? '');
                  return quantity == null || quantity < 1
                      ? 'Ingresa una cantidad válida'
                      : null;
                },
              ),
              const SizedBox(height: 12),
            ],
            if (_scale == CultivationScale.area) ...[
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _areaController,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      decoration: const InputDecoration(
                        labelText: 'Superficie *',
                        prefixIcon: Icon(Icons.straighten_outlined),
                      ),
                      onChanged: (_) => setState(() {}),
                      validator: (value) {
                        final area = parseFormDouble(value ?? '');
                        return area == null || area <= 0
                            ? 'Ingresa una superficie'
                            : null;
                      },
                    ),
                  ),
                  const SizedBox(width: 10),
                  SizedBox(
                    width: 100,
                    child: DropdownButtonFormField<CultivationAreaUnit>(
                      initialValue: _areaUnit,
                      isExpanded: true,
                      decoration: const InputDecoration(labelText: 'Unidad'),
                      items: [
                        for (final unit in CultivationAreaUnit.values)
                          DropdownMenuItem(
                            value: unit,
                            child: Text(unit.displayName),
                          ),
                      ],
                      onChanged: (value) =>
                          setState(() => _areaUnit = value ?? _areaUnit),
                    ),
                  ),
                ],
              ),
              if (_capacityWarning case final warning?) ...[
                const SizedBox(height: 6),
                Text(
                  warning,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.orange.shade800,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
              const SizedBox(height: 12),
            ],
            AppDateField(
              value: _plantingDate,
              labelText: 'Fecha de inicio',
              requiredField: true,
              onChanged: (value) {
                if (value != null) setState(() => _plantingDate = value);
              },
            ),
            const SizedBox(height: 12),
            AppDateField(
              value: _expectedHarvestDate,
              labelText: 'Cosecha esperada (opcional)',
              emptyLabel: 'Sin fecha de cosecha',
              allowClear: true,
              clearTooltip: 'Quitar fecha',
              onChanged: (value) =>
                  setState(() => _expectedHarvestDate = value),
            ),
            const SizedBox(height: 12),
            if (widget.isEditing) ...[
              DropdownButtonFormField<CropGrowthStage>(
                initialValue: _stage,
                isExpanded: true,
                decoration: const InputDecoration(
                  labelText: 'Etapa',
                  prefixIcon: Icon(Icons.trending_up),
                ),
                items: [
                  for (final stage in CropGrowthStage.values)
                    DropdownMenuItem(
                      value: stage,
                      child: Text(stage.displayName),
                    ),
                ],
                onChanged: (value) => setState(() => _stage = value ?? _stage),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<CropStatus>(
                initialValue: _status,
                isExpanded: true,
                decoration: const InputDecoration(
                  labelText: 'Estado',
                  prefixIcon: Icon(Icons.flag_outlined),
                ),
                items: [
                  for (final status in CropStatus.values)
                    DropdownMenuItem(
                      value: status,
                      child: Text(status.displayName),
                    ),
                ],
                onChanged: (value) =>
                    setState(() => _status = value ?? _status),
              ),
              const SizedBox(height: 12),
            ],
            TextFormField(
              controller: _frequencyController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Riego cada cuántos días *',
                prefixIcon: Icon(Icons.water_drop_outlined),
              ),
              validator: (value) {
                final days = int.tryParse(value ?? '');
                return days == null || days < 1 ? 'El mínimo es un día' : null;
              },
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _notesController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Notas (opcional)',
                prefixIcon: Icon(Icons.notes_outlined),
              ),
            ),
            const SizedBox(height: 20),
            AppFormActions(
              onSave: _save,
              saving: _saving,
              saveLabel: 'Guardar cultivo',
              onCancel: () => Navigator.of(context).pop(),
            ),
          ],
        ),
      ),
    );
  }

  String? get _capacityWarning {
    if (_scale != CultivationScale.area || _selectedLocationUuid == null) {
      return null;
    }
    final location = _locations
        .where((item) => item.uuid == _selectedLocationUuid)
        .firstOrNull;
    if (location == null || location.surfaceArea <= 0) return null;
    final requested = parseFormDouble(_areaController.text);
    if (requested == null) return null;
    final requestedSquareMeters = _areaUnit.toSquareMeters(requested);
    final used = _allCultivations
        .where(
          (item) =>
              item.uuid != _initial?.uuid &&
              item.isActive &&
              item.locationUuid == location.uuid,
        )
        .fold<double>(0, (total, item) => total + item.areaSquareMeters);
    final available = location.surfaceArea * 10000 - used;
    if (requestedSquareMeters <= available) return null;
    return 'La superficie supera lo disponible. Puedes guardar si es un cultivo intercalado.';
  }

  void _applyTemplate(String? key) {
    final template = key == null ? null : CropTemplateLibrary.byKey(key);
    setState(() {
      _templateKey = key;
      if (template == null) return;
      if (_nameController.text.trim().isEmpty) {
        _nameController.text = template.name;
      }
      _frequencyController.text = template.wateringFrequencyDays.toString();
      _expectedHarvestDate = template.expectedHarvestDays == null
          ? null
          : _plantingDate.add(Duration(days: template.expectedHarvestDays!));
    });
  }

  Future<void> _createLocation() async {
    final createdUuid = await context.pushNamed<String>(
      AppRoutes.nameUbicacionNueva,
      extra: const LocationFormRouteArgs(returnCreatedUuid: true),
    );
    if (!mounted || createdUuid == null) return;
    final created = await widget.locationRepository.getByUuid(createdUuid);
    if (!mounted || created == null) return;
    setState(() {
      _locations = [..._locations, created];
      _selectedLocationUuid = created.uuid;
    });
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate() || _saving) return;
    setState(() => _saving = true);
    try {
      final rawArea = parseFormDouble(_areaController.text) ?? 0;
      final initial = _initial;
      final value = CultivationEntity(
        uuid: initial?.uuid,
        name: _nameController.text.trim(),
        variety: _varietyController.text.trim(),
        scale: _scale,
        locationUuid: _selectedLocationUuid,
        plantingDate: _plantingDate,
        expectedHarvestDate: _expectedHarvestDate,
        growthStage: _stage,
        wateringFrequencyDays: int.parse(_frequencyController.text),
        lastWateredDate: initial?.lastWateredDate,
        status: _status,
        quantity: _scale == CultivationScale.group
            ? int.parse(_quantityController.text)
            : 1,
        areaSquareMeters: _scale == CultivationScale.area
            ? _areaUnit.toSquareMeters(rawArea)
            : 0,
        preferredAreaUnit: _areaUnit,
        notes: _notesController.text.trim().isEmpty
            ? null
            : _notesController.text.trim(),
        harvests: initial?.harvests ?? const [],
        waterings: initial?.waterings ?? const [],
        healthRecords: initial?.healthRecords ?? const [],
        tasks: initial?.tasks ?? const [],
        createdAt: initial?.createdAt,
      );
      await widget.repository.upsert(value);
      if (!mounted) return;
      Navigator.of(context).pop(true);
    } catch (error) {
      if (!mounted) return;
      setState(() => _saving = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('No se pudo guardar: $error')));
    }
  }

  IconData _scaleIcon(CultivationScale scale) => switch (scale) {
    CultivationScale.individual => Icons.local_florist_outlined,
    CultivationScale.group => Icons.yard_outlined,
    CultivationScale.area => Icons.grass_outlined,
  };
}

class _CultivationFormData {
  const _CultivationFormData({
    required this.cultivation,
    required this.locations,
    required this.allCultivations,
  });

  final CultivationEntity? cultivation;
  final List<LocationEntity> locations;
  final List<CultivationEntity> allCultivations;
}
