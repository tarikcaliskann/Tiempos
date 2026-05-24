import 'package:flutter/material.dart';

import 'app/app_state.dart';
import 'app/tiempos_app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final appState = AppState();
  await appState.restoreSession();
  runApp(TiemposApp(appState: appState));
}
