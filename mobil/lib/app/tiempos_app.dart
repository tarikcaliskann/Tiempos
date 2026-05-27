import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import '../screens/login_screen.dart';
import '../screens/root_scaffold.dart';
import '../theme/app_theme.dart';
import 'app_state.dart';

class TiemposApp extends StatelessWidget {
  const TiemposApp({super.key, required this.appState});

  final AppState appState;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: appState,
      builder: (context, _) {
        return MaterialApp(
          title: 'Tiempos',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light(),
          darkTheme: AppTheme.dark(),
          themeMode: appState.themeMode,
          locale: appState.localeOverride,
          supportedLocales: const [
            Locale('en'),
            Locale('tr'),
          ],
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          home: appState.isAuthenticated
              ? RootScaffold(appState: appState)
              : LoginScreen(appState: appState),
        );
      },
    );
  }
}
