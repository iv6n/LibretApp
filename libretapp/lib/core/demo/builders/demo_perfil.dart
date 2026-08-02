/// core › demo › builders › demo_perfil — fictional ranch profile.
///
/// No real PII: name, farm, phone and UPP are all clearly fictional and
/// scoped to this scenario. [Perfil] is a single global record (not a list
/// keyed by `demo-*` uuid), so `DemoScenarioService` only ever writes this
/// value when the currently-stored profile is blank or already equals it —
/// never over a real breeder's own profile. See the caller for that guard.
library;

import 'package:libretapp/features/perfil/data/perfil_model.dart';

const Perfil demoPerfil = Perfil(
  id: 'demo-perfil-el-mezquite',
  nombre: 'Rodrigo',
  apellido: 'Valenzuela (DEMO)',
  email: 'demo@ranchoelmezquite.example',
  telefono: '662-000-0001',
  finca: 'Rancho El Mezquite — DEMO',
  direccion:
      'Zona rural de Hermosillo, Sonora, México (escenario de demostración)',
  upp: 'DEMO-UPP-0000000',
);
