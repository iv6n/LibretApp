/// RFID and field hardware feature barrel.
library;

export 'domain/rfid_models.dart';
export 'domain/rfid_capture_service.dart';
export 'infrastructure/isar_rfid.dart'
    if (dart.library.html) 'infrastructure/web_rfid_infrastructure_stub.dart';
export 'infrastructure/hardware_permission_service.dart';
export 'infrastructure/rfid_repository_isar.dart'
    if (dart.library.html) 'infrastructure/web_rfid_infrastructure_stub.dart';
export 'infrastructure/simulated_hardware.dart';
export 'infrastructure/rfid_transport.dart';
export 'view/rfid_scanner_page.dart';
