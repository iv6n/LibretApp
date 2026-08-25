/// Señal compartida para refrescar las vistas de Agenda después de una
/// actualización en cualquiera de los dominios que alimentan sus ocurrencias.
library;

import 'package:flutter/foundation.dart';

class AgendaRefreshSignal extends ChangeNotifier {
  void notifyChanged() => notifyListeners();
}
