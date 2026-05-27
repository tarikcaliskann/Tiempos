/// Paylaşılabilir web uygulaması kökü (profil URL’leri).
/// `.env` içindeki `APP_PUBLIC_BASE_URL` ile uyumlu varsayılan.
///
/// Derleme: `flutter run --dart-define=WEB_APP_ORIGIN=https://www.tiempos.site`
abstract final class AppWebConfig {
  static const String _defaultOrigin = 'https://www.tiempos.site';

  static String get origin {
    const fromEnv = String.fromEnvironment('WEB_APP_ORIGIN', defaultValue: '');
    final raw = fromEnv.trim().isEmpty ? _defaultOrigin : fromEnv.trim();
    return raw.replaceAll(RegExp(r'/+$'), '');
  }

  /// Web `PATHS.user(id)` → `/u/{id}`.
  static String publicProfileUrl(String userId) {
    final id = userId.trim();
    return '$origin/u/${Uri.encodeComponent(id)}';
  }

  /// Web `paths.ts` ile aynı kök + yol (yardım / yasal sayfalar tarayıcıda açılır).
  static String webPageUrl(String path) {
    final p = path.trim().isEmpty ? '/' : (path.startsWith('/') ? path : '/$path');
    return '$origin$p';
  }
}
