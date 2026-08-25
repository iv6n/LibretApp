library;

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:libretapp/core/di/injection.dart';
import 'package:libretapp/features/agenda/bloc/agenda_bloc.dart';
import 'package:libretapp/features/agenda/domain/agenda_realize_strategy.dart';
import 'package:libretapp/features/agenda/domain/agenda_registration.dart';
import 'package:libretapp/features/agenda/domain/agenda_registration_coordinator.dart';
import 'package:libretapp/features/agenda/domain/agenda_registration_read_service.dart';
import 'package:libretapp/features/agenda/domain/agenda_task_grouping.dart';
import 'package:libretapp/features/agenda/domain/operational_work.dart';
import 'package:libretapp/features/directorio/animales/domain/entities/animal_entity.dart';
import 'package:libretapp/features/directorio/animales/domain/entities/health_record.dart';
import 'package:libretapp/features/directorio/animales/domain/entities/movement_record.dart';
import 'package:libretapp/features/directorio/animales/domain/entities/reproduction_record.dart';
import 'package:libretapp/features/directorio/animales/domain/entities/weight_record.dart';
import 'package:libretapp/features/directorio/animales/domain/repositories/reproduction_record_repository.dart';
import 'package:libretapp/features/directorio/animales/domain/services/animal_presentation.dart';
import 'package:libretapp/theme/theme.dart';

/// Arguments passed to the root overlay route used by the Agenda register
/// flow. Keeping the bloc instance here preserves the current branch state
/// while the shell chrome is hidden by the route policy.
class AgendaRegistrationRouteArgs {
  const AgendaRegistrationRouteArgs({
    required this.agendaBloc,
    required this.group,
    required this.rows,
    required this.animalsById,
    this.existingRegistration,
  });

  final AgendaBloc agendaBloc;
  final AgendaEventGroup group;
  final List<AgendaTaskRow> rows;
  final Map<String, AnimalEntity> animalsById;
  final AgendaRegistration? existingRegistration;
}

class AgendaRegistrationFlowPage extends StatefulWidget {
  const AgendaRegistrationFlowPage({
    required this.group,
    required this.rows,
    required this.animalsById,
    this.existingRegistration,
    super.key,
  });

  final AgendaEventGroup group;
  final List<AgendaTaskRow> rows;
  final Map<String, AnimalEntity> animalsById;
  final AgendaRegistration? existingRegistration;

  bool get editing => existingRegistration != null;

  @override
  State<AgendaRegistrationFlowPage> createState() =>
      _AgendaRegistrationFlowPageState();
}

class _AgendaRegistrationFlowPageState
    extends State<AgendaRegistrationFlowPage> {
  final _formKey = GlobalKey<FormState>();
  final _productController = TextEditingController();
  final _doseController = TextEditingController();
  final _fromController = TextEditingController();
  final _toController = TextEditingController();
  final _responsibleController = TextEditingController();
  final _notesController = TextEditingController();

  final Map<String, TextEditingController> _weightControllers = {};
  final Map<String, WeightMethod> _weightMethods = {};
  final Map<String, TextEditingController> _sireControllers = {};
  final Map<String, ServiceType> _serviceTypes = {};
  final Map<String, PregnancyCheckResult> _pregnancyResults = {};
  final Map<String, CalvingOutcome> _calvingOutcomes = {};
  final Map<String, int?> _calvingEase = {};
  final Map<String, ReproductionRecord> _reproductionBases = {};
  final Map<String, _HealthOverride> _healthOverrides = {};
  final Map<String, _MovementOverride> _movementOverrides = {};

  late AgendaRegistrationKind _kind;
  late List<AgendaTaskRow> _activeRows;
  HealthRecordType _healthType = HealthRecordType.vaccine;
  MovementReason _movementReason = MovementReason.paddockRotation;
  DateTime _performedAt = DateTime.now();
  int _step = 0;
  bool _loading = false;
  bool _saving = false;
  Object? _editingRecord;
  List<String> _evidencePaths = [];

  bool get _isReproductionCheck => _activeRows.any(
    (row) =>
        row.entry.workAction == WorkActionType.reproductionCheck ||
        row.entry.tipo.toLowerCase() == 'chequeo reproductivo',
  );

  bool get _isCalving => _activeRows.any(
    (row) =>
        row.entry.workAction == WorkActionType.calving ||
        row.entry.tipo.toLowerCase() == 'parto',
  );

  @override
  void initState() {
    super.initState();
    _activeRows = List.of(widget.rows);
    _kind =
        widget.existingRegistration?.kind ??
        registrationKindForEntry(_activeRows.first.entry);
    _healthType =
        healthRecordTypeForAgendaTipo(widget.group.tipo) ??
        HealthRecordType.vaccine;
    for (final row in _activeRows) {
      final id = row.animalId;
      if (id == null) continue;
      _weightControllers[id] = TextEditingController();
      _weightMethods[id] = WeightMethod.scale;
      _sireControllers[id] = TextEditingController();
      _serviceTypes[id] = widget.group.tipo.toLowerCase() == 'inseminación'
          ? ServiceType.artificialInsemination
          : ServiceType.naturalService;
      _pregnancyResults[id] = PregnancyCheckResult.positive;
      _calvingOutcomes[id] = CalvingOutcome.liveBirth;
    }
    _loadInitialData();
  }

  @override
  void dispose() {
    _productController.dispose();
    _doseController.dispose();
    _fromController.dispose();
    _toController.dispose();
    _responsibleController.dispose();
    _notesController.dispose();
    for (final controller in _weightControllers.values) {
      controller.dispose();
    }
    for (final controller in _sireControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _loadInitialData() async {
    if (widget.editing || _kind == AgendaRegistrationKind.reproduction) {
      setState(() => _loading = true);
    }
    try {
      if (widget.existingRegistration case final registration?) {
        _editingRecord = await locator<AgendaRegistrationReadService>()
            .loadRecord(registration);
        _applyExisting(registration, _editingRecord);
      }
      if (_kind == AgendaRegistrationKind.reproduction && !widget.editing) {
        await _loadReproductionBases();
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _applyExisting(AgendaRegistration registration, Object? record) {
    _performedAt = registration.performedAt;
    _evidencePaths = List.of(registration.evidencePaths);
    switch (record) {
      case final HealthRecord value:
        _healthType = value.type;
        _productController.text = value.product;
        _doseController.text = value.dose ?? '';
        _responsibleController.text = value.appliedBy ?? '';
        _notesController.text = value.notes ?? '';
      case final WeightRecord value:
        final id = _activeRows.first.animalId;
        if (id != null) {
          _weightControllers[id]?.text = value.weight.toString();
          _weightMethods[id] = value.method;
        }
        _responsibleController.text = value.measuredBy ?? '';
        _notesController.text = value.notes ?? '';
      case final MovementRecord value:
        _fromController.text = value.fromLocation ?? '';
        _toController.text = value.toLocation;
        _movementReason = value.reason;
        _responsibleController.text = value.movedBy ?? '';
        _notesController.text = value.notes ?? '';
      case final ReproductionRecord value:
        final id = _activeRows.first.animalId;
        if (id != null) {
          _reproductionBases[id] = value;
          _serviceTypes[id] = value.serviceType;
          _sireControllers[id]?.text = value.maleSireIdentifier ?? '';
          _pregnancyResults[id] =
              value.pregnancyResult ?? PregnancyCheckResult.positive;
          _calvingOutcomes[id] =
              value.calvingOutcome ?? CalvingOutcome.liveBirth;
          _calvingEase[id] = value.calvingEase;
        }
        _responsibleController.text = value.servicedBy ?? '';
        _notesController.text = value.notes ?? value.calvingNotes ?? '';
      case null:
        _responsibleController.text = registration.data['responsible'] ?? '';
        _notesController.text = registration.data['notes'] ?? '';
      default:
        break;
    }
  }

  Future<void> _loadReproductionBases() async {
    if (!_isReproductionCheck && !_isCalving) return;
    final repository = locator<ReproductionRecordRepository>();
    for (final row in _activeRows) {
      final animalId = row.animalId;
      if (animalId == null) continue;
      final records = await repository.getReproductionRecords(animalId);
      ReproductionRecord? base;
      if (_isCalving) {
        base = records
            .where(
              (record) =>
                  record.pregnancyResult == PregnancyCheckResult.positive &&
                  record.actualCalvingDate == null,
            )
            .firstOrNull;
      } else {
        base = records
            .where(
              (record) =>
                  record.pregnancyCheckDate == null &&
                  record.actualCalvingDate == null,
            )
            .firstOrNull;
      }
      if (base != null) _reproductionBases[animalId] = base;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.editing ? 'Editar registro' : 'Registrar tarea'),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                  child: Row(
                    children: [
                      _StepIndicator(
                        number: 1,
                        label: 'Datos',
                        active: _step == 0,
                        completed: _step > 0,
                      ),
                      Expanded(
                        child: Divider(
                          color: _step > 0
                              ? theme.colorScheme.primary
                              : theme.colorScheme.outlineVariant,
                        ),
                      ),
                      _StepIndicator(
                        number: 2,
                        label: 'Revisar',
                        active: _step == 1,
                        completed: false,
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: _step == 0 ? _buildForm() : _buildReview(),
                  ),
                ),
                SafeArea(
                  top: false,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                    child: Row(
                      children: [
                        if (_step == 1) ...[
                          Expanded(
                            child: OutlinedButton(
                              onPressed: _saving
                                  ? null
                                  : () => setState(() => _step = 0),
                              child: const Text('Atrás'),
                            ),
                          ),
                          const SizedBox(width: 12),
                        ],
                        Expanded(
                          flex: 2,
                          child: FilledButton.icon(
                            key: ValueKey(
                              _step == 0
                                  ? 'agenda-registration-review'
                                  : 'agenda-registration-confirm',
                            ),
                            onPressed: _saving
                                ? null
                                : _step == 0
                                ? _continueToReview
                                : _confirm,
                            icon: _saving
                                ? const SizedBox.square(
                                    dimension: 18,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  )
                                : Icon(
                                    _step == 0
                                        ? Icons.arrow_forward
                                        : Icons.check_circle_outline,
                                  ),
                            label: Text(
                              _step == 0
                                  ? 'Revisar'
                                  : widget.editing
                                  ? 'Confirmar cambios'
                                  : 'Confirmar y registrar',
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildForm() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.group.titulo,
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 4),
          Text(
            '${_activeRows.length} ${_activeRows.length == 1 ? 'registro' : 'registros'}',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.outline,
            ),
          ),
          const SizedBox(height: 16),
          _DateField(date: _performedAt, onChanged: _pickDate),
          const SizedBox(height: 16),
          switch (_kind) {
            AgendaRegistrationKind.health => _buildHealthForm(),
            AgendaRegistrationKind.weight => _buildWeightForm(),
            AgendaRegistrationKind.movement => _buildMovementForm(),
            AgendaRegistrationKind.reproduction => _buildReproductionForm(),
            AgendaRegistrationKind.general => _buildGeneralForm(),
          },
        ],
      ),
    );
  }

  Widget _buildHealthForm() => Column(
    children: [
      DropdownButtonFormField<HealthRecordType>(
        initialValue: _healthType,
        decoration: const InputDecoration(
          labelText: 'Tipo sanitario',
          border: OutlineInputBorder(),
        ),
        items: [
          for (final type in HealthRecordType.values)
            DropdownMenuItem(value: type, child: Text(type.displayName)),
        ],
        onChanged: (value) => setState(() => _healthType = value!),
      ),
      const SizedBox(height: 12),
      TextFormField(
        controller: _productController,
        decoration: const InputDecoration(
          labelText: 'Producto o tratamiento',
          border: OutlineInputBorder(),
        ),
        validator: _required,
      ),
      const SizedBox(height: 12),
      TextFormField(
        controller: _doseController,
        decoration: const InputDecoration(
          labelText: 'Dosis',
          border: OutlineInputBorder(),
        ),
      ),
      const SizedBox(height: 12),
      _responsibleAndNotes(),
    ],
  );

  Widget _buildWeightForm() => Column(
    children: [
      for (final row in _activeRows)
        if (row.animalId case final animalId?)
          Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _animalLabel(row),
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          key: ValueKey('agenda-weight-$animalId'),
                          controller: _weightControllers[animalId],
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          decoration: const InputDecoration(
                            labelText: 'Peso (kg)',
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) {
                            final parsed = double.tryParse(
                              (value ?? '').replaceAll(',', '.'),
                            );
                            return parsed == null || parsed <= 0
                                ? 'Peso inválido'
                                : null;
                          },
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: DropdownButtonFormField<WeightMethod>(
                          initialValue: _weightMethods[animalId],
                          decoration: const InputDecoration(
                            labelText: 'Método',
                            border: OutlineInputBorder(),
                          ),
                          items: const [
                            DropdownMenuItem(
                              value: WeightMethod.scale,
                              child: Text('Báscula'),
                            ),
                            DropdownMenuItem(
                              value: WeightMethod.estimated,
                              child: Text('Estimado'),
                            ),
                          ],
                          onChanged: (value) =>
                              setState(() => _weightMethods[animalId] = value!),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
      _responsibleAndNotes(),
    ],
  );

  Widget _buildMovementForm() => Column(
    children: [
      TextFormField(
        controller: _fromController,
        decoration: const InputDecoration(
          labelText: 'Origen',
          border: OutlineInputBorder(),
        ),
      ),
      const SizedBox(height: 12),
      TextFormField(
        controller: _toController,
        decoration: const InputDecoration(
          labelText: 'Destino',
          border: OutlineInputBorder(),
        ),
        validator: _required,
      ),
      const SizedBox(height: 12),
      DropdownButtonFormField<MovementReason>(
        initialValue: _movementReason,
        decoration: const InputDecoration(
          labelText: 'Motivo',
          border: OutlineInputBorder(),
        ),
        items: [
          for (final reason in MovementReason.values)
            DropdownMenuItem(value: reason, child: Text(reason.displayName)),
        ],
        onChanged: (value) => setState(() => _movementReason = value!),
      ),
      const SizedBox(height: 12),
      _responsibleAndNotes(),
    ],
  );

  Widget _buildReproductionForm() => Column(
    children: [
      for (final row in _activeRows)
        if (row.animalId case final animalId?)
          Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _animalLabel(row),
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 10),
                  if ((_isReproductionCheck || _isCalving) &&
                      !_reproductionBases.containsKey(animalId))
                    Text(
                      _isCalving
                          ? 'No hay una gestación abierta para registrar el parto.'
                          : 'No hay un servicio pendiente de diagnóstico.',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.error,
                      ),
                    )
                  else if (_isCalving) ...[
                    DropdownButtonFormField<CalvingOutcome>(
                      initialValue: _calvingOutcomes[animalId],
                      decoration: const InputDecoration(
                        labelText: 'Resultado del parto',
                        border: OutlineInputBorder(),
                      ),
                      items: [
                        for (final outcome in CalvingOutcome.values)
                          DropdownMenuItem(
                            value: outcome,
                            child: Text(outcome.displayName),
                          ),
                      ],
                      onChanged: (value) =>
                          setState(() => _calvingOutcomes[animalId] = value!),
                    ),
                    const SizedBox(height: 10),
                    DropdownButtonFormField<int?>(
                      initialValue: _calvingEase[animalId],
                      decoration: const InputDecoration(
                        labelText: 'Dificultad (opcional)',
                        border: OutlineInputBorder(),
                      ),
                      items: const [
                        DropdownMenuItem(value: null, child: Text('Sin dato')),
                        DropdownMenuItem(
                          value: 1,
                          child: Text('1 · Sin ayuda'),
                        ),
                        DropdownMenuItem(
                          value: 2,
                          child: Text('2 · Ayuda leve'),
                        ),
                        DropdownMenuItem(value: 3, child: Text('3 · Mecánica')),
                        DropdownMenuItem(value: 4, child: Text('4 · Distocia')),
                        DropdownMenuItem(value: 5, child: Text('5 · Cesárea')),
                      ],
                      onChanged: (value) =>
                          setState(() => _calvingEase[animalId] = value),
                    ),
                  ] else if (_isReproductionCheck)
                    DropdownButtonFormField<PregnancyCheckResult>(
                      initialValue: _pregnancyResults[animalId],
                      decoration: const InputDecoration(
                        labelText: 'Resultado',
                        border: OutlineInputBorder(),
                      ),
                      items: const [
                        DropdownMenuItem(
                          value: PregnancyCheckResult.positive,
                          child: Text('Positivo'),
                        ),
                        DropdownMenuItem(
                          value: PregnancyCheckResult.negative,
                          child: Text('Negativo'),
                        ),
                        DropdownMenuItem(
                          value: PregnancyCheckResult.uncertain,
                          child: Text('Incierto'),
                        ),
                      ],
                      onChanged: (value) =>
                          setState(() => _pregnancyResults[animalId] = value!),
                    )
                  else ...[
                    DropdownButtonFormField<ServiceType>(
                      initialValue: _serviceTypes[animalId],
                      decoration: const InputDecoration(
                        labelText: 'Tipo de servicio',
                        border: OutlineInputBorder(),
                      ),
                      items: const [
                        DropdownMenuItem(
                          value: ServiceType.naturalService,
                          child: Text('Monta natural'),
                        ),
                        DropdownMenuItem(
                          value: ServiceType.artificialInsemination,
                          child: Text('Inseminación artificial'),
                        ),
                        DropdownMenuItem(
                          value: ServiceType.ivf,
                          child: Text('FIV'),
                        ),
                      ],
                      onChanged: (value) =>
                          setState(() => _serviceTypes[animalId] = value!),
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      controller: _sireControllers[animalId],
                      decoration: const InputDecoration(
                        labelText: 'Semental o pajilla',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
      _responsibleAndNotes(),
    ],
  );

  Widget _buildGeneralForm() => Column(
    children: [
      _responsibleAndNotes(responsibleRequired: true),
      const SizedBox(height: 12),
      Align(
        alignment: Alignment.centerLeft,
        child: OutlinedButton.icon(
          onPressed: _pickEvidence,
          icon: const Icon(Icons.add_a_photo_outlined),
          label: Text(
            _evidencePaths.isEmpty
                ? 'Agregar evidencia'
                : '${_evidencePaths.length} evidencia(s)',
          ),
        ),
      ),
    ],
  );

  Widget _responsibleAndNotes({bool responsibleRequired = false}) => Column(
    children: [
      TextFormField(
        controller: _responsibleController,
        decoration: const InputDecoration(
          labelText: 'Responsable',
          border: OutlineInputBorder(),
        ),
        validator: responsibleRequired ? _required : null,
      ),
      const SizedBox(height: 12),
      TextFormField(
        controller: _notesController,
        minLines: 2,
        maxLines: 4,
        decoration: const InputDecoration(
          labelText: 'Notas',
          border: OutlineInputBorder(),
        ),
      ),
    ],
  );

  Widget _buildReview() {
    final columns = _reviewColumns();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.editing ? 'Revisa los cambios' : 'Revisa antes de confirmar',
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 4),
        Text(
          'La confirmación guardará ${_activeRows.length} '
          '${_activeRows.length == 1 ? 'registro' : 'registros'} y actualizará Agenda.',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Theme.of(context).colorScheme.outline,
          ),
        ),
        const SizedBox(height: 14),
        Card(
          clipBehavior: Clip.antiAlias,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              key: const ValueKey('agenda-registration-review-table'),
              columns: [
                for (final column in columns) DataColumn(label: Text(column)),
                if (_kind == AgendaRegistrationKind.health ||
                    _kind == AgendaRegistrationKind.movement)
                  const DataColumn(label: Text('')),
              ],
              rows: [for (final row in _activeRows) _reviewRow(row, columns)],
            ),
          ),
        ),
        const SizedBox(height: 12),
        Card(
          color: Theme.of(context).colorScheme.primaryContainer,
          child: const ListTile(
            leading: Icon(Icons.info_outline),
            title: Text('Confirmación final'),
            subtitle: Text(
              'Cada animal quedará vinculado al registro real y podrá editarse individualmente.',
            ),
          ),
        ),
      ],
    );
  }

  List<String> _reviewColumns() => switch (_kind) {
    AgendaRegistrationKind.health => ['Animal', 'Producto', 'Dosis', 'Fecha'],
    AgendaRegistrationKind.weight => ['Animal', 'Peso', 'Método', 'Fecha'],
    AgendaRegistrationKind.movement => ['Animal', 'Destino', 'Motivo', 'Fecha'],
    AgendaRegistrationKind.reproduction => [
      'Animal',
      'Evento',
      'Resultado',
      'Fecha',
    ],
    AgendaRegistrationKind.general => [
      'Tarea',
      'Responsable',
      'Fecha',
      'Notas',
    ],
  };

  DataRow _reviewRow(AgendaTaskRow row, List<String> columns) {
    final id = row.animalId;
    final values = switch (_kind) {
      AgendaRegistrationKind.health => [
        _animalLabel(row),
        _healthOverrides[id]?.product ?? _productController.text.trim(),
        _healthOverrides[id]?.dose ?? _doseController.text.trim(),
        _date(_performedAt),
      ],
      AgendaRegistrationKind.weight => [
        _animalLabel(row),
        '${_weightControllers[id]?.text.trim() ?? ''} kg',
        _weightMethods[id] == WeightMethod.scale ? 'Báscula' : 'Estimado',
        _date(_performedAt),
      ],
      AgendaRegistrationKind.movement => [
        _animalLabel(row),
        _movementOverrides[id]?.destination ?? _toController.text.trim(),
        (_movementOverrides[id]?.reason ?? _movementReason).displayName,
        _date(_performedAt),
      ],
      AgendaRegistrationKind.reproduction => [
        _animalLabel(row),
        _isCalving
            ? 'Parto'
            : _isReproductionCheck
            ? 'Chequeo'
            : 'Servicio',
        _reproductionSummary(id),
        _date(_performedAt),
      ],
      AgendaRegistrationKind.general => [
        row.entry.titulo,
        _responsibleController.text.trim(),
        _date(_performedAt),
        _notesController.text.trim(),
      ],
    };
    return DataRow(
      cells: [
        for (final value in values) DataCell(Text(value)),
        if (_kind == AgendaRegistrationKind.health ||
            _kind == AgendaRegistrationKind.movement)
          DataCell(
            IconButton(
              tooltip: 'Ajustar solo este animal',
              icon: const Icon(Icons.edit_outlined, size: 18),
              onPressed: id == null ? null : () => _editRowOverride(id),
            ),
          ),
      ],
    );
  }

  Future<void> _editRowOverride(String animalId) async {
    if (_kind == AgendaRegistrationKind.health) {
      final current = _healthOverrides[animalId];
      final product = TextEditingController(
        text: current?.product ?? _productController.text,
      );
      final dose = TextEditingController(
        text: current?.dose ?? _doseController.text,
      );
      final saved = await showDialog<_HealthOverride>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Ajustar registro'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: product,
                decoration: const InputDecoration(labelText: 'Producto'),
              ),
              TextField(
                controller: dose,
                decoration: const InputDecoration(labelText: 'Dosis'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(
                context,
                _HealthOverride(product.text.trim(), dose.text.trim()),
              ),
              child: const Text('Aplicar'),
            ),
          ],
        ),
      );
      product.dispose();
      dose.dispose();
      if (saved != null) setState(() => _healthOverrides[animalId] = saved);
      return;
    }

    final current = _movementOverrides[animalId];
    final destination = TextEditingController(
      text: current?.destination ?? _toController.text,
    );
    var reason = current?.reason ?? _movementReason;
    final saved = await showDialog<_MovementOverride>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Ajustar movimiento'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: destination,
                decoration: const InputDecoration(labelText: 'Destino'),
              ),
              const SizedBox(height: 10),
              DropdownButtonFormField<MovementReason>(
                initialValue: reason,
                items: [
                  for (final value in MovementReason.values)
                    DropdownMenuItem(
                      value: value,
                      child: Text(value.displayName),
                    ),
                ],
                onChanged: (value) => setDialogState(() => reason = value!),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(
                context,
                _MovementOverride(destination.text.trim(), reason),
              ),
              child: const Text('Aplicar'),
            ),
          ],
        ),
      ),
    );
    destination.dispose();
    if (saved != null) setState(() => _movementOverrides[animalId] = saved);
  }

  void _continueToReview() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    if (_kind == AgendaRegistrationKind.reproduction &&
        (_isCalving || _isReproductionCheck)) {
      final missing = _activeRows.any(
        (row) =>
            row.animalId != null &&
            !_reproductionBases.containsKey(row.animalId),
      );
      if (missing) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Hay animales sin un ciclo reproductivo compatible.'),
          ),
        );
        return;
      }
    }
    setState(() => _step = 1);
  }

  Future<void> _confirm() async {
    setState(() => _saving = true);
    final result = await locator<AgendaRegistrationCoordinator>().register(
      AgendaRegistrationRequest(
        eventKey: widget.group.key,
        rows: _buildDrafts(),
        batchId: widget.existingRegistration?.batchId,
      ),
    );
    if (!mounted) return;
    if (result.allSucceeded) {
      Navigator.of(context).pop(result);
      return;
    }
    setState(() {
      _saving = false;
      _activeRows = result.failures
          .map((failure) => failure.draft.row)
          .toList();
    });
    final firstError = result.failures.first.error ?? 'No se pudo guardar.';
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '${result.successes.length} guardado(s). '
          '${result.failures.length} pendiente(s): $firstError',
        ),
      ),
    );
  }

  List<AgendaRegistrationRowDraft> _buildDrafts() => [
    for (final row in _activeRows) _draftFor(row),
  ];

  AgendaRegistrationRowDraft _draftFor(AgendaTaskRow row) {
    final animalId = row.animalId;
    final existing = widget.existingRegistration;
    switch (_kind) {
      case AgendaRegistrationKind.health:
        final override = _healthOverrides[animalId];
        final base = _editingRecord is HealthRecord
            ? _editingRecord! as HealthRecord
            : null;
        final record =
            base?.copyWith(
              date: _performedAt,
              type: _healthType,
              product: override?.product ?? _productController.text.trim(),
              dose: override?.dose ?? _nullable(_doseController.text),
              appliedBy: _nullable(_responsibleController.text),
              notes: _nullable(_notesController.text),
            ) ??
            HealthRecord(
              date: _performedAt,
              type: _healthType,
              product: override?.product ?? _productController.text.trim(),
              dose: override?.dose ?? _nullable(_doseController.text),
              appliedBy: _nullable(_responsibleController.text),
              notes: _nullable(_notesController.text),
            );
        return AgendaRegistrationRowDraft(
          row: row,
          kind: _kind,
          performedAt: _performedAt,
          healthRecord: record,
          existingRegistration: existing,
        );
      case AgendaRegistrationKind.weight:
        final parsed = double.parse(
          _weightControllers[animalId]!.text.replaceAll(',', '.'),
        );
        final base = _editingRecord is WeightRecord
            ? _editingRecord! as WeightRecord
            : null;
        final record =
            base?.copyWith(
              date: _performedAt,
              weight: parsed,
              method: _weightMethods[animalId],
              measuredBy: _nullable(_responsibleController.text),
              notes: _nullable(_notesController.text),
            ) ??
            WeightRecord(
              date: _performedAt,
              weight: parsed,
              method: _weightMethods[animalId]!,
              measuredBy: _nullable(_responsibleController.text),
              notes: _nullable(_notesController.text),
            );
        return AgendaRegistrationRowDraft(
          row: row,
          kind: _kind,
          performedAt: _performedAt,
          weightRecord: record,
          existingRegistration: existing,
        );
      case AgendaRegistrationKind.movement:
        final override = _movementOverrides[animalId];
        final base = _editingRecord is MovementRecord
            ? _editingRecord! as MovementRecord
            : null;
        final record =
            base?.copyWith(
              date: _performedAt,
              fromLocation: _nullable(_fromController.text),
              toLocation: override?.destination ?? _toController.text.trim(),
              reason: override?.reason ?? _movementReason,
              movedBy: _nullable(_responsibleController.text),
              notes: _nullable(_notesController.text),
            ) ??
            MovementRecord(
              date: _performedAt,
              fromLocation: _nullable(_fromController.text),
              toLocation: override?.destination ?? _toController.text.trim(),
              reason: override?.reason ?? _movementReason,
              movedBy: _nullable(_responsibleController.text),
              notes: _nullable(_notesController.text),
            );
        return AgendaRegistrationRowDraft(
          row: row,
          kind: _kind,
          performedAt: _performedAt,
          movementRecord: record,
          existingRegistration: existing,
        );
      case AgendaRegistrationKind.reproduction:
        final base = animalId == null ? null : _reproductionBases[animalId];
        late ReproductionRecord record;
        if (_isCalving) {
          record = base!.copyWith(
            actualCalvingDate: _performedAt,
            calvingOutcome: _calvingOutcomes[animalId],
            calvingEase: _calvingEase[animalId],
            calvingNotes: _nullable(_notesController.text),
            servicedBy: _nullable(_responsibleController.text),
          );
        } else if (_isReproductionCheck) {
          record = base!.copyWith(
            pregnancyCheckDate: _performedAt,
            pregnancyResult: _pregnancyResults[animalId],
            notes: _nullable(_notesController.text),
            servicedBy: _nullable(_responsibleController.text),
          );
        } else {
          final existingRecord = _editingRecord is ReproductionRecord
              ? _editingRecord! as ReproductionRecord
              : null;
          record =
              existingRecord?.copyWith(
                serviceDate: _performedAt,
                serviceType: _serviceTypes[animalId],
                maleSireIdentifier: _nullable(
                  _sireControllers[animalId]?.text ?? '',
                ),
                notes: _nullable(_notesController.text),
                servicedBy: _nullable(_responsibleController.text),
              ) ??
              ReproductionRecord(
                serviceDate: _performedAt,
                serviceType: _serviceTypes[animalId]!,
                maleSireIdentifier: _nullable(
                  _sireControllers[animalId]?.text ?? '',
                ),
                notes: _nullable(_notesController.text),
                servicedBy: _nullable(_responsibleController.text),
              );
        }
        return AgendaRegistrationRowDraft(
          row: row,
          kind: _kind,
          performedAt: _performedAt,
          reproductionRecord: record,
          existingRegistration: existing,
        );
      case AgendaRegistrationKind.general:
        return AgendaRegistrationRowDraft(
          row: row,
          kind: _kind,
          performedAt: _performedAt,
          generalData: {
            'responsible': _responsibleController.text.trim(),
            'notes': _notesController.text.trim(),
          },
          evidencePaths: _evidencePaths,
          existingRegistration: existing,
        );
    }
  }

  Future<void> _pickDate() async {
    final value = await showDatePicker(
      context: context,
      initialDate: _performedAt,
      firstDate: DateTime(_performedAt.year - 5),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (value != null) setState(() => _performedAt = value);
  }

  Future<void> _pickEvidence() async {
    final image = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (image != null && mounted) {
      setState(() => _evidencePaths = [..._evidencePaths, image.path]);
    }
  }

  String? _required(String? value) => value == null || value.trim().isEmpty
      ? 'Este campo es obligatorio'
      : null;

  String? _nullable(String value) {
    final trimmed = value.trim();
    return trimmed.isEmpty ? null : trimmed;
  }

  String _animalLabel(AgendaTaskRow row) {
    final animal = row.animalId == null
        ? null
        : widget.animalsById[row.animalId];
    return animal == null
        ? row.animalId ?? row.entry.titulo
        : primaryAnimalLabel(animal);
  }

  String _reproductionSummary(String? animalId) {
    if (_isCalving) {
      return _calvingOutcomes[animalId]?.displayName ?? 'Sin resultado';
    }
    if (_isReproductionCheck) {
      return switch (_pregnancyResults[animalId]) {
        PregnancyCheckResult.positive => 'Positivo',
        PregnancyCheckResult.negative => 'Negativo',
        PregnancyCheckResult.uncertain => 'Incierto',
        _ => 'Sin resultado',
      };
    }
    return switch (_serviceTypes[animalId]) {
      ServiceType.artificialInsemination => 'Inseminación',
      ServiceType.ivf => 'FIV',
      _ => 'Monta natural',
    };
  }

  String _date(DateTime value) => DateFormat('dd/MM/yyyy').format(value);
}

class _StepIndicator extends StatelessWidget {
  const _StepIndicator({
    required this.number,
    required this.label,
    required this.active,
    required this.completed,
  });

  final int number;
  final String label;
  final bool active;
  final bool completed;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final highlighted = active || completed;
    return Column(
      children: [
        CircleAvatar(
          radius: 15,
          backgroundColor: highlighted
              ? scheme.primary
              : scheme.surfaceContainerHighest,
          foregroundColor: highlighted ? scheme.onPrimary : scheme.outline,
          child: completed
              ? const Icon(Icons.check, size: 17)
              : Text('$number'),
        ),
        const SizedBox(height: 3),
        Text(
          label,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
            color: highlighted ? scheme.primary : scheme.outline,
            fontWeight: highlighted ? FontWeight.w700 : FontWeight.normal,
          ),
        ),
      ],
    );
  }
}

class _DateField extends StatelessWidget {
  const _DateField({required this.date, required this.onChanged});

  final DateTime date;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) => InkWell(
    onTap: onChanged,
    borderRadius: BorderRadius.circular(AppRadii.sm),
    child: InputDecorator(
      decoration: const InputDecoration(
        labelText: 'Fecha realizada',
        border: OutlineInputBorder(),
        suffixIcon: Icon(Icons.calendar_today_outlined),
      ),
      child: Text(DateFormat('dd/MM/yyyy').format(date)),
    ),
  );
}

class _HealthOverride {
  const _HealthOverride(this.product, this.dose);
  final String product;
  final String dose;
}

class _MovementOverride {
  const _MovementOverride(this.destination, this.reason);
  final String destination;
  final MovementReason reason;
}
