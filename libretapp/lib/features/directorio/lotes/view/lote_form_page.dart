/// features \u203a directorio \u203a lotes \u203a view \u203a lote_form_page \u2014 form page for creating or editing a lote.
library;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:libretapp/app/widgets/widgets.dart';
import 'package:libretapp/core/di/injection.dart';
import 'package:libretapp/core/extensions/context_extensions.dart';
import 'package:libretapp/features/directorio/lotes/bloc/lotes_bloc.dart';
import 'package:libretapp/features/directorio/lotes/bloc/lotes_event.dart';
import 'package:libretapp/features/directorio/lotes/bloc/lotes_state.dart';
import 'package:libretapp/features/directorio/lotes/domain/entities/lote_entity.dart';
import 'package:libretapp/features/directorio/lotes/infrastructure/lotes_repository.dart';

class LoteFormPage extends StatefulWidget {
  LoteFormPage({this.loteUuid, LotesRepository? repository, super.key})
    : repository = repository ?? locator<LotesRepository>();

  final String? loteUuid;
  final LotesRepository repository;

  bool get isEdit => loteUuid != null;

  @override
  State<LoteFormPage> createState() => _LoteFormPageState();
}

class _LoteFormPageState extends State<LoteFormPage> {
  late final TextEditingController _nombreController;
  late final TextEditingController _descripcionController;
  late final TextEditingController _notasController;
  late final TextEditingController _feedPriceController;
  late final TextEditingController _dailyFeedController;
  late final TextEditingController _livePriceController;
  Future<LoteEntity?>? _editFuture;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _nombreController = TextEditingController();
    _descripcionController = TextEditingController();
    _notasController = TextEditingController();
    _feedPriceController = TextEditingController();
    _dailyFeedController = TextEditingController();
    _livePriceController = TextEditingController();
    if (widget.isEdit) {
      _editFuture = widget.repository.getByUuid(widget.loteUuid!);
    }
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _descripcionController.dispose();
    _notasController.dispose();
    _feedPriceController.dispose();
    _dailyFeedController.dispose();
    _livePriceController.dispose();
    super.dispose();
  }

  Future<bool> _dispatchAndAwait(LotesEvent event) async {
    final bloc = context.read<LotesBloc>();
    final future = bloc.stream
        .skip(1)
        .firstWhere(
          (state) => state is! LotesActionInProgress,
          orElse: () => bloc.state,
        );

    bloc.add(event);
    final nextState = await future;

    if (!mounted) return false;
    if (nextState is LotesError) {
      context.showErrorSnackBar(nextState.message);
      return false;
    }

    return true;
  }

  Future<void> _submit({LoteEntity? current}) async {
    final nombre = _nombreController.text.trim();
    if (nombre.isEmpty) {
      context.showErrorSnackBar('Por favor ingresa un nombre para el lote');
      return;
    }

    final economics = _readEconomics();
    if (economics == null) return;

    setState(() {
      _saving = true;
    });

    bool ok;
    if (widget.isEdit) {
      if (current == null) {
        if (mounted) {
          context.showErrorSnackBar('No se encontró el lote para editar');
        }
        setState(() {
          _saving = false;
        });
        return;
      }

      final updated = current.copyWith(
        name: nombre,
        description: _descripcionController.text.trim(),
        notes: _notasController.text.trim(),
        feedPricePerKg: economics.feedPricePerKg,
        dailyFeedKgPerHead: economics.dailyFeedKgPerHead,
        liveWeightPricePerKg: economics.liveWeightPricePerKg,
        lastUpdateDate: DateTime.now(),
        synced: false,
      );
      ok = await _dispatchAndAwait(UpdateLote(updated));
    } else {
      ok = await _dispatchAndAwait(
        CreateLote(
          name: nombre,
          description: _descripcionController.text.trim(),
          notes: _notasController.text.trim(),
          feedPricePerKg: economics.feedPricePerKg,
          dailyFeedKgPerHead: economics.dailyFeedKgPerHead,
          liveWeightPricePerKg: economics.liveWeightPricePerKg,
        ),
      );
    }

    if (!mounted) return;
    setState(() {
      _saving = false;
    });

    if (ok) {
      Navigator.of(context).pop(true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final title = widget.isEdit ? 'Editar lote' : 'Crear lote';

    return ShellChromeScope(
      visible: false,
      child: Scaffold(
        appBar: AppBar(title: Text(title)),
        body: widget.isEdit
            ? FutureBuilder<LoteEntity?>(
                future: _editFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    return _FormErrorState(
                      message: 'Error al cargar el lote: ${snapshot.error}',
                    );
                  }

                  final lote = snapshot.data;
                  if (lote == null) {
                    return const _FormErrorState(message: 'Lote no encontrado');
                  }

                  _syncControllers(lote);
                  return _buildForm(current: lote);
                },
              )
            : _buildForm(),
      ),
    );
  }

  Widget _buildForm({LoteEntity? current}) {
    return SafeArea(
      top: false,
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _nombreController,
              key: const ValueKey('lote-name'),
              textInputAction: TextInputAction.next,
              decoration: const InputDecoration(
                labelText: 'Nombre del lote',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _descripcionController,
              textInputAction: TextInputAction.next,
              maxLines: 2,
              decoration: const InputDecoration(
                labelText: 'Descripción (opcional)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _notasController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Notas (opcional)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Economía del lote (opcional)',
              style: Theme.of(
                context,
              ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _feedPriceController,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: const InputDecoration(
                labelText: 'Precio alimento / kg',
                prefixText: '\$ ',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _dailyFeedController,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: const InputDecoration(
                labelText: 'Consumo diario / cabeza (kg)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _livePriceController,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: const InputDecoration(
                labelText: 'Precio kg vivo (opcional)',
                prefixText: '\$ ',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                key: const ValueKey('lote-save'),
                onPressed: _saving ? null : () => _submit(current: current),
                icon: Icon(widget.isEdit ? Icons.save : Icons.add),
                label: Text(_saving ? 'Guardando...' : 'Guardar'),
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: _saving ? null : () => Navigator.of(context).pop(),
                child: const Text('Cancelar'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _syncControllers(LoteEntity lote) {
    if (_nombreController.text.isEmpty) {
      _nombreController.text = lote.name;
    }
    if (_descripcionController.text.isEmpty) {
      _descripcionController.text = lote.description ?? '';
    }
    if (_notasController.text.isEmpty) {
      _notasController.text = lote.notes ?? '';
    }
    if (_feedPriceController.text.isEmpty && lote.feedPricePerKg != null) {
      _feedPriceController.text = _formatEconomic(lote.feedPricePerKg!);
    }
    if (_dailyFeedController.text.isEmpty && lote.dailyFeedKgPerHead != null) {
      _dailyFeedController.text = _formatEconomic(lote.dailyFeedKgPerHead!);
    }
    if (_livePriceController.text.isEmpty &&
        lote.liveWeightPricePerKg != null) {
      _livePriceController.text = _formatEconomic(lote.liveWeightPricePerKg!);
    }
  }

  _LotEconomics? _readEconomics() {
    final values = <double?>[];
    for (final entry in [
      (_feedPriceController, 'precio del alimento'),
      (_dailyFeedController, 'consumo diario'),
      (_livePriceController, 'precio del kg vivo'),
    ]) {
      final value = _parseEconomic(entry.$1.text);
      if (entry.$1.text.trim().isNotEmpty &&
          (value == null || value < 0 || !value.isFinite)) {
        context.showErrorSnackBar('Revisa el ${entry.$2}.');
        return null;
      }
      values.add(value);
    }
    return _LotEconomics(
      feedPricePerKg: values[0],
      dailyFeedKgPerHead: values[1],
      liveWeightPricePerKg: values[2],
    );
  }

  double? _parseEconomic(String value) => value.trim().isEmpty
      ? null
      : double.tryParse(value.trim().replaceAll(',', '.'));

  String _formatEconomic(double value) =>
      value.toStringAsFixed(value == value.roundToDouble() ? 0 : 2);
}

class _LotEconomics {
  const _LotEconomics({
    required this.feedPricePerKg,
    required this.dailyFeedKgPerHead,
    required this.liveWeightPricePerKg,
  });

  final double? feedPricePerKg;
  final double? dailyFeedKgPerHead;
  final double? liveWeightPricePerKg;
}

class _FormErrorState extends StatelessWidget {
  const _FormErrorState({required this.message});

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
