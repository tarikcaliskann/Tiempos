/// Backend kökü — sonda `/` ve `/api` olmasın (web `getApiBaseUrl` ile aynı mantık).
///
/// Derleme: `flutter run --dart-define=API_BASE_URL=https://sunucun.com`
/// Boşsa varsayılan Render API (frontend `DEFAULT_PRODUCTION_API` ile uyumlu).
abstract final class ApiConfig {
  static const String _defaultBase =
      'https://tiempos-backend-w26e.onrender.com';

  static String get baseUrl {
    const fromEnv = String.fromEnvironment('API_BASE_URL', defaultValue: '');
    final raw = fromEnv.trim().isEmpty ? _defaultBase : fromEnv.trim();
    return _normalize(raw);
  }

  static String _normalize(String raw) {
    var s = raw.replaceAll(RegExp(r'/+$'), '');
    if (s.endsWith('/api')) {
      s = s.substring(0, s.length - 4).replaceAll(RegExp(r'/+$'), '');
    }
    return s;
  }
}
