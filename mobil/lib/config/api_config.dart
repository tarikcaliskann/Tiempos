import 'package:flutter/foundation.dart'
    show TargetPlatform, defaultTargetPlatform, kIsWeb;

/// Backend kökü — sonda `/` ve `/api` olmasın (web `getApiBaseUrl` ile aynı mantık).
///
/// Derleme: `flutter run --dart-define=API_BASE_URL=https://sunucun.com`
/// Boşsa varsayılan Render API (frontend `DEFAULT_PRODUCTION_API` ile uyumlu).
///
/// [resolvedBaseUrl]: Android emülatörde `127.0.0.1`/`localhost` makineye gitmez;
/// otomatik olarak `10.0.2.2` ile değiştirilir. Gerçek cihazda bilgisayarın LAN IP’sini verin.
abstract final class ApiConfig {
  static const String _defaultBase =
      'https://tiempos-backend-w26e.onrender.com';

  static String get baseUrl {
    const fromEnv = String.fromEnvironment('API_BASE_URL', defaultValue: '');
    final raw = fromEnv.trim().isEmpty ? _defaultBase : fromEnv.trim();
    return _normalize(raw);
  }

  /// HTTP istemcisi için taban URL (Android emülatör loopback düzeltmesi dahil).
  static String get resolvedBaseUrl {
    final base = baseUrl;
    if (kIsWeb) return base;
    if (defaultTargetPlatform == TargetPlatform.android) {
      try {
        final uri = Uri.parse(base);
        final h = uri.host.toLowerCase();
        if (h == 'localhost' || h == '127.0.0.1') {
          return _normalize(uri.replace(host: '10.0.2.2').toString());
        }
      } on Object catch (_) {
        /* ignore */
      }
    }
    return base;
  }

  static String _normalize(String raw) {
    var s = raw.replaceAll(RegExp(r'/+$'), '');
    if (s.endsWith('/api')) {
      s = s.substring(0, s.length - 4).replaceAll(RegExp(r'/+$'), '');
    }
    return s;
  }
}
