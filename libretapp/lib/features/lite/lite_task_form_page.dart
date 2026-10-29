import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:libretapp/core/di/injection.dart';
import 'package:libretapp/features/agenda/data/agenda_repository.dart';
import 'package:libretapp/features/directorio/animales/domain/entities/animal_entity.dart';
import 'package:libretapp/features/directorio/animales/infrastructure/animal_repository.dart';
import 'package:libretapp/features/directorio/cultivos/domain/cultivation_entity.dart';
import 'package:libretapp/features/directorio/cultivos/domain/cultivation_repository.dart';
import 'lite_notification_service.dart';
import 'lite_task_composer.dart';
import 'lite_pet_service.dart';
import 'lite_visibility.dart';
import 'widgets/lite_artwork.dart';

String _taskTypeAsset(String type) => switch (type) {
  'Medicamento' => 'assets/images/task_vitamins.webp',
  'Riego' => 'assets/images/record_irrigation.webp',
  'Recordatorio' => 'assets/images/record_reminder.webp',
  _ => 'assets/images/record_service.webp',
};

IconData _taskTypeIcon(String type) => switch (type) {
  'Medicamento' => Icons.medication_outlined,
  'Riego' => Icons.water_drop_outlined,
  'Recordatorio' => Icons.notifications_outlined,
  _ => Icons.event_outlined,
};

class LiteTaskFormPage extends StatefulWidget {
  const LiteTaskFormPage({super.key, this.initialPetUuid});
  final String? initialPetUuid;
  @override
  State<LiteTaskFormPage> createState() => _LiteTaskFormPageState();
}

class _LiteTaskFormPageState extends State<LiteTaskFormPage> {
  final _title = TextEditingController();
  final _notes = TextEditingController();
  final _doses = TextEditingController(text: '1');
  final _interval = TextEditingController(text: '8');
  DateTime _date = DateTime.now().add(const Duration(hours: 1));
  String _type = 'Cita';
  String? _petUuid;
  String? _plantUuid;
  bool _saving = false;
  late Future<(List<AnimalEntity>, List<CultivationEntity>)> _targets =
      _loadTargets();

  Future<(List<AnimalEntity>, List<CultivationEntity>)> _loadTargets() async =>
      (
        (await locator<AnimalRepository>().getAll())
            .where(LitePetService.isPet)
            .toList(),
        (await locator<CultivationRepository>().getAll())
            .where(LiteVisibility.domesticPlant)
            .toList(),
      );

  @override
  void initState() {
    super.initState();
    _petUuid = widget.initialPetUuid;
  }

  @override
  void dispose() {
    _title.dispose();
    _notes.dispose();
    _doses.dispose();
    _interval.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final day = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (day == null || !mounted) return;
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_date),
    );
    if (time == null || !mounted) return;
    setState(
      () => _date = DateTime(
        day.year,
        day.month,
        day.day,
        time.hour,
        time.minute,
      ),
    );
  }

  Future<void> _save() async {
    if (_saving || _title.text.trim().isEmpty) return;
    if (_type == 'Riego' && _plantUuid == null) return;
    if (_type == 'Medicamento' && _petUuid == null) return;
    final doses = _type == 'Medicamento' ? int.tryParse(_doses.text) : 1;
    final interval = _type == 'Medicamento' ? int.tryParse(_interval.text) : 0;
    if (doses == null ||
        doses < 1 ||
        doses > 100 ||
        interval == null ||
        interval < 1 && doses > 1) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Revisa las tomas y el intervalo en horas.'),
        ),
      );
      return;
    }
    setState(() => _saving = true);
    try {
      final repository = locator<AgendaRepository>();
      final entries = LiteTaskComposer.compose(
        title: _title.text.trim(),
        notes: _notes.text.trim(),
        type: _type,
        firstAt: _date,
        doses: doses,
        intervalHours: interval,
        petUuid: _petUuid,
        plantUuid: _plantUuid,
      );
      await repository.saveEntries(entries);
      var alertsReady = false;
      try {
        alertsReady = await LiteNotificationService.syncFromRepository(
          requestPermission: true,
        );
      } catch (_) {
        // The dates are safely stored even when Android cannot schedule alerts.
      }
      if (mounted) {
        if (!alertsReady) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Fechas guardadas. Activa los avisos en Android para recibir recordatorios.',
              ),
            ),
          );
        }
        Navigator.of(context).pop();
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('No se pudieron guardar las fechas: $error')),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Programar fecha')),
    body: FutureBuilder<(List<AnimalEntity>, List<CultivationEntity>)>(
      future: _targets,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('No se pudieron cargar mascotas y plantas.'),
                TextButton(
                  onPressed: () => setState(() => _targets = _loadTargets()),
                  child: const Text('Reintentar'),
                ),
              ],
            ),
          );
        }
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final (pets, plants) = snapshot.data!;
        return ListView(
          padding: const EdgeInsets.all(20),
          children: [
            DropdownButtonFormField<String>(
              initialValue: _type,
              decoration: const InputDecoration(labelText: 'Tipo'),
              items: ['Cita', 'Medicamento', 'Recordatorio', 'Riego']
                  .map(
                    (v) => DropdownMenuItem(
                      value: v,
                      child: Row(
                        children: [
                          SizedBox(
                            width: 30,
                            height: 30,
                            child: v == 'Cita'
                                ? const Icon(Icons.event_outlined, size: 28)
                                : LiteArtwork(
                                    assetPath: _taskTypeAsset(v),
                                    size: 28,
                                    fallbackIcon: _taskTypeIcon(v),
                                  ),
                          ),
                          const SizedBox(width: 10),
                          Text(v),
                        ],
                      ),
                    ),
                  )
                  .toList(),
              onChanged: (v) => setState(() {
                _type = v ?? 'Cita';
                if (_type != 'Riego') _plantUuid = null;
                if (_type == 'Riego') _petUuid = null;
              }),
            ),
            TextField(
              controller: _title,
              decoration: const InputDecoration(labelText: 'Título *'),
            ),
            TextField(
              controller: _notes,
              decoration: const InputDecoration(
                labelText: 'Notas e indicaciones (opcional)',
              ),
            ),
            ListTile(
              leading: const Icon(Icons.event_outlined, size: 36),
              title: Text(
                DateFormat('EEEE d MMM yyyy, HH:mm', 'es').format(_date),
              ),
              subtitle: const Text('Fecha y hora'),
              onTap: _pickDate,
            ),
            if (_type != 'Riego')
              DropdownButtonFormField<String>(
                initialValue: _petUuid,
                decoration: const InputDecoration(
                  labelText: 'Mascota (opcional)',
                ),
                items: [
                  const DropdownMenuItem<String>(
                    value: null,
                    child: Text('Sin mascota'),
                  ),
                  ...pets.map(
                    (p) => DropdownMenuItem(
                      value: p.uuid,
                      child: Text(p.customName ?? p.uuid),
                    ),
                  ),
                ],
                onChanged: (v) => setState(() => _petUuid = v),
              ),
            if (_type == 'Riego')
              DropdownButtonFormField<String>(
                initialValue: _plantUuid,
                decoration: const InputDecoration(labelText: 'Planta o huerto'),
                items: plants
                    .map(
                      (p) => DropdownMenuItem(
                        value: p.uuid,
                        child: Row(
                          children: [
                            const SizedBox(
                              width: 30,
                              height: 30,
                              child: LiteArtwork(
                                assetPath: 'assets/images/crop_vegetative.webp',
                                size: 28,
                                fallbackIcon: Icons.eco_outlined,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Flexible(child: Text(p.name)),
                          ],
                        ),
                      ),
                    )
                    .toList(),
                onChanged: (v) => setState(() => _plantUuid = v),
              ),
            if (_type == 'Medicamento') ...[
              TextField(
                controller: _doses,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Número de tomas'),
                onChanged: (_) => setState(() {}),
              ),
              TextField(
                controller: _interval,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Horas entre tomas',
                ),
              ),
              const Text(
                'Introduce la pauta indicada por el profesional. Cada toma se confirma por separado.',
              ),
            ],
            const SizedBox(height: 24),
            FilledButton(
              onPressed: _saving ? null : _save,
              child: Text(
                _saving
                    ? 'Guardando…'
                    : _type == 'Medicamento' &&
                          (int.tryParse(_doses.text) ?? 1) > 1
                    ? 'Guardar fechas'
                    : 'Guardar fecha',
              ),
            ),
          ],
        );
      },
    ),
  );
}
