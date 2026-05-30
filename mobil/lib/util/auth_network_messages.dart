import '../language/auth_l10n.dart';

/// Uzun SocketException metnini kısa kullanıcı mesajına çevirir; ham metin ayrıntıda kalır.
({String summary, String hint, String technical}) humanizeAuthNetworkError(
  String raw,
  AuthL10n a,
) {
  final lower = raw.toLowerCase();
  final technical = raw.trim();

  if (lower.contains('operation not permitted') ||
      (lower.contains('socketexception') && lower.contains('errno = 1'))) {
    return (
      summary: a.networkErrorPermissionTitle,
      hint: a.networkErrorPermissionHint,
      technical: technical,
    );
  }

  if (lower.contains('connection refused') ||
      lower.contains('connection reset')) {
    return (
      summary: a.networkErrorRefusedTitle,
      hint: a.networkErrorRefusedHint,
      technical: technical,
    );
  }

  if ((lower.contains('127.0.0.1') || lower.contains('localhost')) &&
      (lower.contains('failed') ||
          lower.contains('socket') ||
          lower.contains('connection'))) {
    return (
      summary: a.networkErrorLocalhostTitle,
      hint: a.networkErrorLocalhostHint,
      technical: technical,
    );
  }

  return (
    summary: a.networkErrorGenericTitle,
    hint: a.loginHintNetwork,
    technical: technical,
  );
}
