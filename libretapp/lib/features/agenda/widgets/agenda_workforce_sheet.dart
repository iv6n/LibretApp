/// Workforce management and assignment sheets for operational agenda tasks.
library;

import 'package:flutter/material.dart';
import 'package:libretapp/core/di/injection.dart';
import 'package:libretapp/core/utils/id_generator.dart';
import 'package:libretapp/features/agenda/data/workforce_model.dart';
import 'package:libretapp/features/agenda/data/workforce_repository.dart';

class WorkforceSelection {
  const WorkforceSelection({
    this.assigneeId,
    this.teamId,
    this.collaboratorIds = const [],
  });

  final String? assigneeId;
  final String? teamId;
  final List<String> collaboratorIds;
}

Future<WorkforceSelection?> showWorkforceSelector({
  required BuildContext context,
  String? assigneeId,
  String? teamId,
  List<String> collaboratorIds = const [],
}) async {
  final repository = locator<WorkforceRepository>();
  final results = await Future.wait([
    repository.fetchWorkers(),
    repository.fetchTeams(),
  ]);
  if (!context.mounted) return null;

  return showModalBottomSheet<WorkforceSelection>(
    context: context,
    useRootNavigator: true,
    isScrollControlled: true,
    builder: (_) => _WorkforceSelectorSheet(
      workers: results[0] as List<WorkerProfile>,
      teams: results[1] as List<WorkTeam>,
      initialAssigneeId: assigneeId,
      initialTeamId: teamId,
      initialCollaboratorIds: collaboratorIds,
    ),
  );
}

Future<void> showWorkforceManager(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    useRootNavigator: true,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (_) => const _WorkforceManagerSheet(),
  );
}

class _WorkforceSelectorSheet extends StatefulWidget {
  const _WorkforceSelectorSheet({
    required this.workers,
    required this.teams,
    required this.initialAssigneeId,
    required this.initialTeamId,
    required this.initialCollaboratorIds,
  });

  final List<WorkerProfile> workers;
  final List<WorkTeam> teams;
  final String? initialAssigneeId;
  final String? initialTeamId;
  final List<String> initialCollaboratorIds;

  @override
  State<_WorkforceSelectorSheet> createState() =>
      _WorkforceSelectorSheetState();
}

class _WorkforceSelectorSheetState extends State<_WorkforceSelectorSheet> {
  late String? _assigneeId = widget.initialAssigneeId;
  late String? _teamId = widget.initialTeamId;
  late final Set<String> _collaborators = {
    ...widget.initialCollaboratorIds,
  };

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Asignar trabajo', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            DropdownButtonFormField<String?>(
              initialValue: _teamId,
              decoration: const InputDecoration(
                labelText: 'Cuadrilla',
                prefixIcon: Icon(Icons.groups_outlined),
              ),
              items: [
                const DropdownMenuItem(value: null, child: Text('Sin cuadrilla')),
                ...widget.teams.map(
                  (team) => DropdownMenuItem(value: team.id, child: Text(team.name)),
                ),
              ],
              onChanged: (value) => setState(() => _teamId = value),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String?>(
              initialValue: _assigneeId,
              decoration: const InputDecoration(
                labelText: 'Responsable principal',
                prefixIcon: Icon(Icons.person_outline),
              ),
              items: [
                const DropdownMenuItem(value: null, child: Text('Sin responsable')),
                ...widget.workers.map(
                  (worker) => DropdownMenuItem(
                    value: worker.id,
                    child: Text(worker.name),
                  ),
                ),
              ],
              onChanged: (value) => setState(() {
                _assigneeId = value;
                if (value != null) _collaborators.remove(value);
              }),
            ),
            const SizedBox(height: 16),
            Text('Colaboradores', style: Theme.of(context).textTheme.titleSmall),
            if (widget.workers.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 16),
                child: Text('Primero agrega integrantes desde Agenda.'),
              )
            else
              ...widget.workers
                  .where((worker) => worker.id != _assigneeId)
                  .map(
                    (worker) => CheckboxListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(worker.name),
                      subtitle: Text(_roleLabel(worker.role)),
                      value: _collaborators.contains(worker.id),
                      onChanged: (selected) => setState(() {
                        if (selected == true) {
                          _collaborators.add(worker.id);
                        } else {
                          _collaborators.remove(worker.id);
                        }
                      }),
                    ),
                  ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: () => Navigator.of(context).pop(
                  WorkforceSelection(
                    assigneeId: _assigneeId,
                    teamId: _teamId,
                    collaboratorIds: _collaborators.toList(growable: false),
                  ),
                ),
                icon: const Icon(Icons.check),
                label: const Text('Aplicar asignación'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _WorkforceManagerSheet extends StatefulWidget {
  const _WorkforceManagerSheet();

  @override
  State<_WorkforceManagerSheet> createState() => _WorkforceManagerSheetState();
}

class _WorkforceManagerSheetState extends State<_WorkforceManagerSheet> {
  final WorkforceRepository _repository = locator<WorkforceRepository>();
  List<WorkerProfile> _workers = const [];
  List<WorkTeam> _teams = const [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _reload();
  }

  Future<void> _reload() async {
    final results = await Future.wait([
      _repository.fetchWorkers(),
      _repository.fetchTeams(),
    ]);
    if (!mounted) return;
    setState(() {
      _workers = results[0] as List<WorkerProfile>;
      _teams = results[1] as List<WorkTeam>;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Personal y cuadrillas'),
        actions: [
          IconButton(
            onPressed: _addWorker,
            icon: const Icon(Icons.person_add_alt),
            tooltip: 'Agregar integrante',
          ),
          IconButton(
            onPressed: _workers.isEmpty ? null : _addTeam,
            icon: const Icon(Icons.group_add_outlined),
            tooltip: 'Crear cuadrilla',
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Text('Integrantes', style: Theme.of(context).textTheme.titleMedium),
                if (_workers.isEmpty)
                  const ListTile(title: Text('Aún no hay integrantes'))
                else
                  ..._workers.map(
                    (worker) => ListTile(
                      leading: const CircleAvatar(child: Icon(Icons.person_outline)),
                      title: Text(worker.name),
                      subtitle: Text([
                        _roleLabel(worker.role),
                        if (worker.phone?.isNotEmpty == true) worker.phone!,
                      ].join(' · ')),
                      trailing: IconButton(
                        onPressed: () async {
                          await _repository.archiveWorker(worker.id);
                          await _reload();
                        },
                        icon: const Icon(Icons.archive_outlined),
                        tooltip: 'Archivar',
                      ),
                    ),
                  ),
                const Divider(height: 32),
                Text('Cuadrillas', style: Theme.of(context).textTheme.titleMedium),
                if (_teams.isEmpty)
                  const ListTile(title: Text('Aún no hay cuadrillas'))
                else
                  ..._teams.map(
                    (team) => ListTile(
                      leading: const CircleAvatar(child: Icon(Icons.groups_outlined)),
                      title: Text(team.name),
                      subtitle: Text('${team.memberIds.length} integrante(s)'),
                      trailing: IconButton(
                        onPressed: () async {
                          await _repository.archiveTeam(team.id);
                          await _reload();
                        },
                        icon: const Icon(Icons.archive_outlined),
                        tooltip: 'Archivar',
                      ),
                    ),
                  ),
              ],
            ),
    );
  }

  Future<void> _addWorker() async {
    final nameController = TextEditingController();
    final phoneController = TextEditingController();
    var role = WorkerRole.worker;
    final save = await showDialog<bool>(
      context: context,
      useRootNavigator: true,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Nuevo integrante'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                autofocus: true,
                decoration: const InputDecoration(labelText: 'Nombre'),
              ),
              TextField(
                controller: phoneController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(labelText: 'Teléfono (opcional)'),
              ),
              DropdownButtonFormField<String>(
                initialValue: role,
                decoration: const InputDecoration(labelText: 'Rol'),
                items: const [
                  DropdownMenuItem(value: WorkerRole.owner, child: Text('Propietario')),
                  DropdownMenuItem(value: WorkerRole.supervisor, child: Text('Supervisor')),
                  DropdownMenuItem(value: WorkerRole.worker, child: Text('Trabajador')),
                ],
                onChanged: (value) => setDialogState(() {
                  role = value ?? WorkerRole.worker;
                }),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(dialogContext, false), child: const Text('Cancelar')),
            FilledButton(onPressed: () => Navigator.pop(dialogContext, true), child: const Text('Guardar')),
          ],
        ),
      ),
    );
    final name = nameController.text.trim();
    nameController.dispose();
    final phone = phoneController.text.trim();
    phoneController.dispose();
    if (save != true || name.isEmpty) return;
    final now = DateTime.now();
    await _repository.saveWorker(
      WorkerProfile(
        id: generateId(),
        name: name,
        role: role,
        phone: phone.isEmpty ? null : phone,
        active: true,
        createdAt: now,
        updatedAt: now,
      ),
    );
    await _reload();
  }

  Future<void> _addTeam() async {
    final nameController = TextEditingController();
    final selected = <String>{};
    final save = await showDialog<bool>(
      context: context,
      useRootNavigator: true,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Nueva cuadrilla'),
          content: SizedBox(
            width: 420,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nameController,
                    autofocus: true,
                    decoration: const InputDecoration(labelText: 'Nombre'),
                  ),
                  ..._workers.map(
                    (worker) => CheckboxListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(worker.name),
                      value: selected.contains(worker.id),
                      onChanged: (value) => setDialogState(() {
                        if (value == true) {
                          selected.add(worker.id);
                        } else {
                          selected.remove(worker.id);
                        }
                      }),
                    ),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(dialogContext, false), child: const Text('Cancelar')),
            FilledButton(onPressed: () => Navigator.pop(dialogContext, true), child: const Text('Guardar')),
          ],
        ),
      ),
    );
    final name = nameController.text.trim();
    nameController.dispose();
    if (save != true || name.isEmpty) return;
    final now = DateTime.now();
    await _repository.saveTeam(
      WorkTeam(
        id: generateId(),
        name: name,
        memberIds: selected.toList(growable: false),
        active: true,
        createdAt: now,
        updatedAt: now,
      ),
    );
    await _reload();
  }
}

String _roleLabel(String role) {
  switch (role) {
    case WorkerRole.owner:
      return 'Propietario';
    case WorkerRole.supervisor:
      return 'Supervisor';
    default:
      return 'Trabajador';
  }
}
