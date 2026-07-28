/// features \u203a ubicaciones \u203a view \u203a location_form_page \u2014 form page for creating or editing a location.
library;

import 'package:flutter/material.dart';
import 'package:libretapp/app/widgets/widgets.dart';
import 'package:libretapp/core/di/injection.dart';
import 'package:libretapp/core/extensions/context_extensions.dart';
import 'package:libretapp/features/ubicaciones/domain/entities/location_entity.dart';
import 'package:libretapp/features/ubicaciones/domain/repositories/location_repository.dart';
import 'package:libretapp/features/ubicaciones/widgets/location_form_sheet.dart';
import 'package:libretapp/features/ubicaciones/widgets/location_hierarchy_validation.dart';

class LocationFormPage extends StatefulWidget {
  const LocationFormPage({this.locationUuid, this.presetParentUuid, super.key});

  final String? locationUuid;
  final String? presetParentUuid;

  bool get isEdit => locationUuid != null;

  @override
  State<LocationFormPage> createState() => _LocationFormPageState();
}

class _LocationFormPageState extends State<LocationFormPage> {
  late final LocationRepository _repository;
  Future<LocationEntity?>? _loadFuture;
  List<LocationEntity> _allLocations = [];
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _repository = locator<LocationRepository>();
    _loadAllLocations();
    if (widget.isEdit) {
      _loadFuture = _repository.getByUuid(widget.locationUuid!);
    }
  }

  Future<void> _loadAllLocations() async {
    final all = await _repository.getAll();
    if (!mounted) return;
    setState(() {
      _allLocations = all;
    });
  }

  @override
  Widget build(BuildContext context) {
    return ShellChromeScope(
      visible: false,
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.isEdit ? 'Editar ubicación' : 'Nueva ubicación'),
        ),
        body: widget.isEdit
            ? FutureBuilder<LocationEntity?>(
                future: _loadFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return _ErrorState(
                      message: 'Error al cargar ubicación: ${snapshot.error}',
                    );
                  }

                  final initial = snapshot.data;
                  if (initial == null) {
                    return const _ErrorState(
                      message: 'Ubicación no encontrada',
                    );
                  }

                  return _FormBody(
                    initial: initial,
                    allLocations: _allLocations,
                    saving: _saving,
                    onSubmit: _onSubmit,
                  );
                },
              )
            : _FormBody(
                allLocations: _allLocations,
                saving: _saving,
                onSubmit: _onSubmit,
                presetParentUuid: widget.presetParentUuid,
              ),
      ),
    );
  }

  Future<void> _onSubmit(LocationEntity value) async {
    if (_saving) return;
    final validationError = validateLocationParent(value, _allLocations);
    if (validationError != null) {
      context.showErrorSnackBar(validationError);
      return;
    }
    setState(() {
      _saving = true;
    });
    try {
      await _repository.upsert(value);
      if (!mounted) return;
      Navigator.of(context).pop(true);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _saving = false;
      });
      context.showErrorSnackBar('No se pudo guardar la ubicación: $e');
    }
  }
}

class _FormBody extends StatelessWidget {
  const _FormBody({
    required this.onSubmit,
    required this.saving,
    required this.allLocations,
    this.initial,
    this.presetParentUuid,
  });

  final LocationEntity? initial;
  final Future<void> Function(LocationEntity) onSubmit;
  final bool saving;
  final List<LocationEntity> allLocations;
  final String? presetParentUuid;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        IgnorePointer(
          ignoring: saving,
          child: LocationFormSheet(
            initial: initial,
            allLocations: allLocations,
            presetParentUuid: presetParentUuid,
            onSubmit: (value) {
              onSubmit(value);
            },
          ),
        ),
        if (saving)
          const ColoredBox(
            color: Color(0x55000000),
            child: Center(child: CircularProgressIndicator()),
          ),
      ],
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Text(message, textAlign: TextAlign.center),
      ),
    );
  }
}
