/// Runtime permissions required by future Bluetooth readers.
library;

import 'package:permission_handler/permission_handler.dart';

class HardwarePermissionService {
  Future<bool> requestBluetooth() async {
    final statuses = await [
      Permission.bluetoothScan,
      Permission.bluetoothConnect,
    ].request();
    return statuses.values.every((status) => status.isGranted);
  }

  Future<bool> requestLocation() async {
    final status = await Permission.locationWhenInUse.request();
    return status.isGranted;
  }
}
