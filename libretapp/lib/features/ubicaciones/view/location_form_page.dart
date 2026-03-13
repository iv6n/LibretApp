import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:libretapp/app/widgets/widgets.dart';
import 'package:libretapp/core/di/injection.dart';
import 'package:libretapp/features/ubicaciones/bloc/ubicaciones_bloc.dart';
import 'package:libretapp/features/ubicaciones/bloc/ubicaciones_event.dart';
import 'package:libretapp/features/ubicaciones/domain/entities/location_entity.dart';
import 'package:libretapp/features/ubicaciones/domain/repositories/location_repository.dart';
import 'package:libretapp/features/ubicaciones/widgets/location_form_sheet.dart';

class LocationFormPage extends StatefulWidget {
  const LocationFormPage({this.locationUuid, super.key});

  final String? locationUuid;

  bool get isEdit => locationUuid != null;

  @override
  State<LocationFormPage> createState() => _LocationFormPageState();
}

class _LocationFormPageState extends State<LocationFormPage> {
  late final LocationRepository _repository;
  Future<LocationEntity?>? _loadFuture;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _repository = locator<LocationRepository>();
    if (widget.isEdit) {
      _loadFuture = _repository.getByUuid(widget.locationUuid!);
    }
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
                    saving: _saving,
                    onSubmit: _onSubmit,
                  );
                },
              )
            : _FormBody(saving: _saving, onSubmit: _onSubmit),
      ),
    );
  }

  Future<void> _onSubmit(LocationEntity value) async {
    if (_saving) return;
    setState(() {
      _saving = true;
    });
    try {
      await _repository.upsert(value);
      if (!mounted) return;
      UbicacionesBloc? bloc;
      try {
        bloc = BlocProvider.of<UbicacionesBloc>(context, listen: false);
      } catch (_) {
        bloc = null;
      }
      bloc?.add(const LoadUbicaciones());
      Navigator.of(context).pop(true);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _saving = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No se pudo guardar la ubicación: $e')),
      );
    }
  }
}

class _FormBody extends StatelessWidget {
  const _FormBody({required this.onSubmit, required this.saving, this.initial});

  final LocationEntity? initial;
  final Future<void> Function(LocationEntity) onSubmit;
  final bool saving;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        IgnorePointer(
          ignoring: saving,
          child: LocationFormSheet(
            initial: initial,
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
