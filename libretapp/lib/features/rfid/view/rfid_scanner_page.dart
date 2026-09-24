/// Field-first RFID scanning and animal binding screen.
library;

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:libretapp/core/di/injection.dart';
import 'package:libretapp/core/services/services.dart';
import 'package:libretapp/features/directorio/animales/infrastructure/animal_repository.dart';
import 'package:libretapp/features/rfid/rfid.dart';
import 'package:libretapp/theme/theme.dart';

class RfidScannerPage extends StatefulWidget {
  const RfidScannerPage({this.initialAnimalUuid, super.key});

  final String? initialAnimalUuid;

  @override
  State<RfidScannerPage> createState() => _RfidScannerPageState();
}

class _RfidScannerPageState extends State<RfidScannerPage> {
  late final RfidReaderAdapter _reader;
  late final RfidRepository _repository;
  final _manualController = TextEditingController();
  final Map<String, RfidTagRead> _reads = <String, RfidTagRead>{};
  final Map<String, RfidBindingRecord?> _bindings =
      <String, RfidBindingRecord?>{};
  List<AnimalListItem> _animals = const [];
  StreamSubscription<RfidTagRead>? _subscription;
  RfidDeviceDescriptor? _device;
  String? _selectedAnimalUuid;
  DateTime? _startedAt;
  int _rawCount = 0;
  bool _busy = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _reader = locator<RfidReaderAdapter>();
    _repository = locator<RfidRepository>();
    _selectedAnimalUuid = widget.initialAnimalUuid;
    _subscription = _reader.reads.listen(_onRead);
    _loadAnimals();
  }

  Future<void> _loadAnimals() async {
    final animals = await locator<AnimalRepository>().getAll();
    if (!mounted) return;
    setState(() {
      _animals = animals
          .map(
            (animal) => AnimalListItem(
              uuid: animal.uuid,
              label: animal.customName?.trim().isNotEmpty == true
                  ? '${animal.customName} · ${animal.earTagNumber}'
                  : animal.earTagNumber,
            ),
          )
          .toList(growable: false);
      if (_selectedAnimalUuid != null &&
          !_animals.any((item) => item.uuid == _selectedAnimalUuid)) {
        _selectedAnimalUuid = null;
      }
    });
  }

  Future<void> _onRead(RfidTagRead read) async {
    final normalized = read.normalizedEpc;
    if (normalized.isEmpty) return;
    _rawCount++;
    if (!_reads.containsKey(normalized)) {
      _reads[normalized] = read;
      _bindings[normalized] = await _repository.activeBindingForTag(normalized);
    }
    if (mounted) setState(() {});
  }

  Future<bool> _connect() async {
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final devices = await _reader.discover();
      if (devices.isEmpty) throw StateError('No hay lectores disponibles.');
      _device = devices.first;
      if (_device!.transport == 'bluetooth' &&
          !await locator<HardwarePermissionService>().requestBluetooth()) {
        throw StateError('Permiso Bluetooth rechazado.');
      }
      await _reader.connect(_device!);
      return true;
    } catch (error) {
      _error = '$error';
      return false;
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _toggleScan() async {
    if (_reader.state == HardwareConnectionState.scanning) {
      await _reader.stopScan();
      await _finishSession();
      if (mounted) setState(() {});
      return;
    }
    setState(() {
      _busy = true;
      _error = null;
      _startedAt = DateTime.now();
      _rawCount = 0;
      _reads.clear();
      _bindings.clear();
    });
    try {
      if (_reader.state != HardwareConnectionState.connected) {
        final connected = await _connect();
        if (!connected) {
          _startedAt = null;
          return;
        }
      }
      await _reader.startScan();
    } catch (error) {
      _error = '$error';
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _disconnect() async {
    if (_busy) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      if (_reader.state == HardwareConnectionState.scanning) {
        await _reader.stopScan();
        await _finishSession();
      }
      await _reader.disconnect();
      _device = null;
    } catch (error) {
      _error = '$error';
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _finishSession() async {
    final startedAt = _startedAt;
    if (startedAt == null) return;
    final geo = await locator<GpsCaptureService>().tryCapture();
    await _repository.saveScanSession(
      RfidScanSession(
        uuid: 'rfid-${DateTime.now().microsecondsSinceEpoch}',
        startedAt: startedAt,
        endedAt: DateTime.now(),
        deviceId: _device?.id ?? 'unknown',
        source: RfidBindingSource.reader,
        tagCount: _rawCount,
        uniqueTagCount: _reads.length,
        latitude: geo?.latitude,
        longitude: geo?.longitude,
        accuracyMeters: geo?.accuracyMeters,
      ),
    );
    _startedAt = null;
  }

  void _emitManualRead() {
    final value = _manualController.text.trim();
    if (value.isEmpty) return;
    final reader = _reader;
    if (reader is SimulatedRfidReaderAdapter) {
      reader.emit(value);
    } else if (reader is KeyboardWedgeRfidAdapter) {
      reader.feed(value);
    }
    _manualController.clear();
  }

  Future<void> _assign(String epc) async {
    final animalUuid = _selectedAnimalUuid;
    if (animalUuid == null) {
      _showMessage('Selecciona un animal antes de asignar la etiqueta.');
      return;
    }
    final existing = _bindings[epc];
    if (existing != null) {
      if (existing.animalUuid == animalUuid) {
        _showMessage('Esta etiqueta ya está asignada a ese animal.');
        return;
      }
      final animal = _animals
          .where((item) => item.uuid == existing.animalUuid)
          .firstOrNull;
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Reasignar etiqueta'),
          content: Text(
            'La etiqueta está asignada a ${animal?.label ?? 'otro animal'}. '
            '¿Quieres retirarla de ahí y asignarla al animal seleccionado?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Reasignar'),
            ),
          ],
        ),
      );
      if (confirmed != true) return;
      try {
        await _repository.retireBinding(existing.uuid);
      } catch (_) {
        _showMessage('No se pudo retirar la asignación anterior.');
        return;
      }
    }
    try {
      await _repository.assignTag(
        tagEpc: epc,
        animalUuid: animalUuid,
        source: RfidBindingSource.reader,
      );
      _bindings[epc] = await _repository.activeBindingForTag(epc);
      if (mounted) {
        setState(() {});
        _showMessage('Etiqueta asignada y guardada localmente.');
      }
    } on RfidBindingConflict catch (error) {
      _showMessage(error.message);
    } catch (_) {
      _showMessage('No se pudo asignar la etiqueta.');
    }
  }

  void _showMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  void dispose() {
    _subscription?.cancel();
    _manualController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scanning = _reader.state == HardwareConnectionState.scanning;
    final connected =
        _reader.state == HardwareConnectionState.connected || scanning;
    final statusColor = scanning ? Colors.green : Colors.blueGrey;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Escanear RFID'),
        actions: [
          IconButton(
            tooltip: 'Recargar animales',
            onPressed: _loadAnimals,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg,
          AppSpacing.md,
          AppSpacing.lg,
          AppSpacing.xxl,
        ),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.sensors_outlined, color: statusColor),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: Text(
                          _device?.name ?? 'Simulador RFID',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ),
                      Chip(
                        label: Text(_reader.state.name),
                        backgroundColor: statusColor.withValues(alpha: .12),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    'Etiquetas únicas: ${_reads.length} · lecturas: $_rawCount',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: _busy
                              ? null
                              : connected
                              ? _disconnect
                              : _connect,
                          icon: Icon(
                            connected
                                ? Icons.bluetooth_disabled
                                : Icons.bluetooth_searching,
                          ),
                          label: Text(connected ? 'Desconectar' : 'Conectar'),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: FilledButton.icon(
                          onPressed: _busy ? null : _toggleScan,
                          icon: Icon(scanning ? Icons.stop : Icons.play_arrow),
                          label: Text(scanning ? 'Detener' : 'Escanear'),
                        ),
                      ),
                    ],
                  ),
                  if (_error != null) ...[
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      _error!,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.error,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          DropdownButtonFormField<String>(
            isExpanded: true,
            initialValue: _selectedAnimalUuid,
            decoration: const InputDecoration(
              labelText: 'Animal para asignar',
              prefixIcon: Icon(Icons.pets_outlined),
            ),
            items: _animals
                .map(
                  (animal) => DropdownMenuItem<String>(
                    value: animal.uuid,
                    child: Text(animal.label, overflow: TextOverflow.ellipsis),
                  ),
                )
                .toList(growable: false),
            onChanged: (value) => setState(() => _selectedAnimalUuid = value),
          ),
          const SizedBox(height: AppSpacing.sm),
          TextField(
            controller: _manualController,
            textInputAction: TextInputAction.done,
            onSubmitted: (_) => _emitManualRead(),
            decoration: InputDecoration(
              labelText: 'EPC manual / lector teclado',
              prefixIcon: const Icon(Icons.keyboard_outlined),
              suffixIcon: IconButton(
                tooltip: 'Agregar lectura',
                onPressed: _emitManualRead,
                icon: const Icon(Icons.add_circle_outline),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          if (_reads.isEmpty)
            const Card(
              child: Padding(
                padding: EdgeInsets.all(AppSpacing.lg),
                child: Text(
                  'Conecta el simulador y escanea. Las etiquetas desconocidas aparecerán aquí para asignarlas.',
                ),
              ),
            )
          else
            ..._reads.entries.map((entry) {
              final binding = _bindings[entry.key];
              final animal = binding == null
                  ? null
                  : _animals
                        .where((item) => item.uuid == binding.animalUuid)
                        .firstOrNull;
              return Card(
                child: ListTile(
                  leading: const CircleAvatar(child: Icon(Icons.sell_outlined)),
                  title: Text(entry.key),
                  subtitle: Text(
                    animal == null
                        ? 'Sin asignar · RSSI ${entry.value.rssi ?? '—'}'
                        : 'Asignada a ${animal.label}',
                  ),
                  trailing: binding == null
                      ? FilledButton.tonal(
                          onPressed: () => _assign(entry.key),
                          child: const Text('Asignar'),
                        )
                      : FilledButton.tonal(
                          onPressed: () => _assign(entry.key),
                          child: const Text('Cambiar'),
                        ),
                ),
              );
            }),
        ],
      ),
    );
  }
}

class AnimalListItem {
  const AnimalListItem({required this.uuid, required this.label});

  final String uuid;
  final String label;
}
