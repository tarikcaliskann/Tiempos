import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:tiempos_mobile/app/app_state.dart';
import 'package:tiempos_mobile/app/tiempos_app.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  GoogleFonts.config.allowRuntimeFetching = false;

  testWidgets('Tiempos app loads', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    final appState = AppState();
    await appState.restoreSession();
    await tester.pumpWidget(TiemposApp(appState: appState));
    expect(find.text('Tiempos'), findsWidgets);
  });
}
