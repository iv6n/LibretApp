import 'package:flutter/material.dart';
import 'package:libretapp/core/maintenance/data_maintenance.dart';
import 'package:libretapp/core/utils/number_parsing.dart';

class DataReviewPage extends StatefulWidget {
  const DataReviewPage({required this.service, super.key});
  final DataMaintenance service;
  @override
  State<DataReviewPage> createState() => _DataReviewPageState();
}

class _DataReviewPageState extends State<DataReviewPage> {
  MaintenanceReview? _review;
  final _changes = <String, MaintenanceChange>{};
  bool _busy = false;
  String? _error;
  @override
  void initState() {
    super.initState();
    _scan();
  }

  Future<void> _scan() async {
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final review = await widget.service.scan();
      if (mounted)
        setState(() {
          _review = review;
          _changes.clear();
        });
    } catch (_) {
      if (mounted)
        setState(
          () => _error =
              'No se pudo revisar la base. Tus datos no se modificaron.',
        );
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _configure(MaintenanceIssue issue) async {
    if (_changes.containsKey(issue.id)) {
      setState(() => _changes.remove(issue.id));
      return;
    }
    if (issue.kind == MaintenanceIssueKind.invalidNumber) {
      final controller = TextEditingController();
      final key = GlobalKey<FormState>();
      final change = await showDialog<MaintenanceChange>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: const Text('Proponer corrección'),
          content: Form(
            key: key,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(issue.detail),
                TextFormField(
                  controller: controller,
                  decoration: const InputDecoration(
                    labelText: 'Valor correcto',
                  ),
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  validator: (raw) {
                    final value = parseFormDouble(raw ?? '');
                    return value == null || value <= 0
                        ? 'Indica un valor positivo válido.'
                        : null;
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancelar'),
            ),
            if (issue.canDelete)
              TextButton(
                onPressed: () => Navigator.pop(
                  dialogContext,
                  MaintenanceChange(issue.id, delete: true),
                ),
                child: const Text('Proponer eliminación'),
              ),
            FilledButton(
              onPressed: () {
                if (key.currentState!.validate())
                  Navigator.pop(
                    dialogContext,
                    MaintenanceChange(
                      issue.id,
                      number: parseFormDouble(controller.text),
                    ),
                  );
              },
              child: const Text('Usar valor'),
            ),
          ],
        ),
      );
      controller.dispose();
      if (change != null && mounted)
        setState(() => _changes[issue.id] = change);
    } else if (issue.kind == MaintenanceIssueKind.monitoring) {
      var observation = issue.manualObservation;
      var attention = issue.manualAttention;
      var manualVaccinated = issue.manualVaccinated;
      var manualDewormed = issue.manualDewormed;
      var manualHasVitamins = issue.manualHasVitamins;

      final change = await showDialog<MaintenanceChange>(
        context: context,
        builder: (dialogContext) => StatefulBuilder(
          builder: (_, setDialog) => AlertDialog(
            title: const Text('Alertas manuales'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Confirma cuáles marcaste manualmente. Una enfermedad en el historial puede mantener la alerta activa.',
                  ),
                  SwitchListTile(
                    title: const Text('Vacunación manual'),
                    value: manualVaccinated,
                    onChanged: (v) => setDialog(() => manualVaccinated = v),
                  ),
                  SwitchListTile(
                    title: const Text('Desparasitación manual'),
                    value: manualDewormed,
                    onChanged: (v) => setDialog(() => manualDewormed = v),
                  ),
                  SwitchListTile(
                    title: const Text('Vitaminas manuales'),
                    value: manualHasVitamins,
                    onChanged: (v) => setDialog(() => manualHasVitamins = v),
                  ),
                  SwitchListTile(
                    title: const Text('En observación manual'),
                    value: observation,
                    onChanged: (v) => setDialog(() => observation = v),
                  ),
                  SwitchListTile(
                    title: const Text('Atención manual'),
                    value: attention,
                    onChanged: (v) => setDialog(() => attention = v),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: const Text('Cancelar'),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(
                  dialogContext,
                  MaintenanceChange(
                    issue.id,
                    manualVaccinated: manualVaccinated,
                    manualDewormed: manualDewormed,
                    manualHasVitamins: manualHasVitamins,
                    manualObservation: observation,
                    manualAttention: attention,
                  ),
                ),
                child: const Text('Proponer cambio'),
              ),
            ],
          ),
        ),
      );
      if (change != null && mounted)
        setState(() => _changes[issue.id] = change);
    } else if (issue.canDelete) {
      setState(
        () => _changes[issue.id] = MaintenanceChange(issue.id, delete: true),
      );
    }
  }

  String _description(MaintenanceChange change) => change.delete
      ? 'Eliminar registro'
      : change.number != null
      ? 'Corregir valor a ${change.number}'
      : 'Actualizar alertas manuales';

  Future<void> _apply() async {
    if (_busy || _review == null || _changes.isEmpty) return;
    final selected = List<MaintenanceChange>.of(_changes.values);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text('Aplicar ${selected.length} correcciones'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Se creará primero una copia nativa recuperable. Revisa la selección; no se fusionarán animales ni genealogías.',
              ),
              const SizedBox(height: 12),
              for (final change in selected)
                Text(
                  '• ${_description(change)} · ${_review!.issues.firstWhere((i) => i.id == change.issueId).detail}',
                ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Crear copia y aplicar'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    setState(() => _busy = true);
    try {
      await widget.service.apply(_review!, selected);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Correcciones aplicadas. La copia previa está disponible en Recuperación.',
          ),
        ),
      );
      await _scan();
    } catch (error) {
      if (mounted) setState(() => _error = 'No se aplicó la selección. $error');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) => PopScope(
    canPop: !_busy,
    child: Scaffold(
      appBar: AppBar(
        title: const Text('Revisar y corregir datos'),
        actions: [
          IconButton(
            tooltip: 'Volver a revisar',
            onPressed: _busy ? null : _scan,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: _busy
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                const Text(
                  'Esta vista previa conserva tus registros. Selecciona únicamente cambios que hayas comprobado. Los casos con vínculos o ambiguos requieren revisión individual.',
                ),
                if (_error != null)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: Text(
                      _error!,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.error,
                      ),
                    ),
                  ),
                if (_review != null && _review!.issues.isEmpty)
                  const Padding(
                    padding: EdgeInsets.only(top: 24),
                    child: Text(
                      'No se encontraron incidencias en esta revisión.',
                    ),
                  ),
                for (final issue in _review?.issues ?? <MaintenanceIssue>[])
                  Card(
                    child: CheckboxListTile(
                      title: Text(issue.title),
                      subtitle: Text(
                        '${issue.detail}${_changes.containsKey(issue.id) ? '\nPropuesta: ${_description(_changes[issue.id]!)}' : ''}',
                      ),
                      value: _changes.containsKey(issue.id),
                      onChanged:
                          issue.canDelete ||
                              issue.kind ==
                                  MaintenanceIssueKind.invalidNumber ||
                              issue.kind == MaintenanceIssueKind.monitoring
                          ? (_) => _configure(issue)
                          : null,
                    ),
                  ),
              ],
            ),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.all(16),
        child: FilledButton(
          onPressed: _busy || _changes.isEmpty ? null : _apply,
          child: Text('Revisar ${_changes.length} cambios seleccionados'),
        ),
      ),
    ),
  );
}
