import 'api_client.dart';

class LoginResponse {
  LoginResponse({
    required this.token,
    required this.userId,
    required this.email,
    required this.fullName,
    required this.role,
  });

  final String token;
  final String userId;
  final String email;
  final String fullName;
  final String role;

  factory LoginResponse.fromJson(Map<String, dynamic> j) {
    return LoginResponse(
      token: j['token'] as String,
      userId: '${j['userId']}',
      email: j['email'] as String,
      fullName: j['fullName'] as String,
      role: j['role'] as String? ?? 'USER',
    );
  }
}

Future<LoginResponse> loginRequest({
  required String email,
  required String password,
}) async {
  final data = await apiFetch(
    '/api/auth/login',
    method: 'POST',
    body: {'email': email.trim(), 'password': password},
    timeout: const Duration(seconds: 240),
  );
  if (data is! Map) {
    throw StateError('Invalid login response');
  }
  return LoginResponse.fromJson(Map<String, dynamic>.from(data));
}

class GoogleAuthConfig {
  const GoogleAuthConfig({required this.clientId});

  final String clientId;

  factory GoogleAuthConfig.fromJson(Map<String, dynamic> j) {
    return GoogleAuthConfig(
      clientId: (j['clientId'] as String?)?.trim() ?? '',
    );
  }
}

Future<GoogleAuthConfig> fetchGoogleAuthConfig() async {
  final data = await apiFetch(
    '/api/auth/google-config',
    timeout: const Duration(seconds: 180),
  );
  if (data is! Map) {
    throw StateError('Invalid google-config response');
  }
  return GoogleAuthConfig.fromJson(Map<String, dynamic>.from(data));
}

/// Sunucudaki `GOOGLE_CLIENT_ID` boşsa web ile aynı kimliği derleme anında verebilirsiniz:
/// `flutter run --dart-define=GOOGLE_CLIENT_ID=xxx.apps.googleusercontent.com`
Future<String> resolveGoogleOAuthClientId() async {
  final fromApi = (await fetchGoogleAuthConfig()).clientId.trim();
  if (fromApi.isNotEmpty) return fromApi;
  const fromCompile = String.fromEnvironment(
    'GOOGLE_CLIENT_ID',
    defaultValue: '',
  );
  return fromCompile.trim();
}

Future<LoginResponse> socialLoginGoogle({
  String? idToken,
  String? accessToken,
}) async {
  final id = idToken?.trim() ?? '';
  final acc = accessToken?.trim() ?? '';
  if (id.isEmpty && acc.isEmpty) {
    throw StateError('Google idToken or accessToken required');
  }
  final body = <String, dynamic>{
    'provider': 'google',
    if (id.isNotEmpty) 'idToken': id,
    if (acc.isNotEmpty) 'accessToken': acc,
  };
  final data = await apiFetch(
    '/api/auth/social-login',
    method: 'POST',
    body: body,
    timeout: const Duration(seconds: 180),
  );
  if (data is! Map) {
    throw StateError('Invalid social-login response');
  }
  return LoginResponse.fromJson(Map<String, dynamic>.from(data));
}

/// Web `RegisterResponse` / `POST /api/auth/register`.
class RegisterResponse {
  RegisterResponse({
    required this.id,
    required this.fullName,
    required this.email,
    required this.timeCreditMinutes,
    required this.emailVerificationPending,
    required this.smtpMailDeliveryEnabled,
    required this.smtpLocalCapture,
  });

  final String id;
  final String fullName;
  final String email;
  final int timeCreditMinutes;
  final bool emailVerificationPending;
  final bool smtpMailDeliveryEnabled;
  final bool smtpLocalCapture;

  factory RegisterResponse.fromJson(Map<String, dynamic> j) {
    return RegisterResponse(
      id: '${j['id'] ?? ''}',
      fullName: j['fullName'] as String? ?? '',
      email: j['email'] as String? ?? '',
      timeCreditMinutes: (j['timeCreditMinutes'] as num?)?.toInt() ?? 0,
      emailVerificationPending: j['emailVerificationPending'] == true,
      smtpMailDeliveryEnabled: j['smtpMailDeliveryEnabled'] == true,
      smtpLocalCapture: j['smtpLocalCapture'] != false,
    );
  }
}

Future<RegisterResponse> registerRequest({
  required String fullName,
  required String email,
  required String password,
}) async {
  final data = await apiFetch(
    '/api/auth/register',
    method: 'POST',
    body: {
      'fullName': fullName.trim(),
      'email': email.trim(),
      'password': password,
    },
    timeout: const Duration(seconds: 180),
  );
  if (data is! Map) {
    throw StateError('Invalid register response');
  }
  return RegisterResponse.fromJson(Map<String, dynamic>.from(data));
}

Future<LoginResponse> verifyEmailWithCode({
  required String email,
  required String code,
}) async {
  final digits = code.replaceAll(RegExp(r'\D'), '');
  final normalized = digits.length > 6 ? digits.substring(0, 6) : digits;
  final data = await apiFetch(
    '/api/auth/verify-email',
    method: 'POST',
    body: {
      'email': email.trim().toLowerCase(),
      'code': normalized,
    },
    timeout: const Duration(seconds: 120),
  );
  if (data is! Map) {
    throw StateError('Invalid verify-email response');
  }
  return LoginResponse.fromJson(Map<String, dynamic>.from(data));
}

Future<void> resendVerificationEmail(String email) async {
  await apiFetch(
    '/api/auth/resend-verification',
    method: 'POST',
    body: {'email': email.trim().toLowerCase()},
    timeout: const Duration(seconds: 90),
  );
}

Future<void> forgotPasswordRequest(String email) async {
  await apiFetch(
    '/api/auth/forgot-password',
    method: 'POST',
    body: {'email': email.trim().toLowerCase()},
    timeout: const Duration(seconds: 90),
  );
}

Future<void> resetPasswordRequest({
  required String email,
  required String token,
  required String newPassword,
}) async {
  await apiFetch(
    '/api/auth/reset-password',
    method: 'POST',
    body: {
      'email': email.trim().toLowerCase(),
      'token': token.trim(),
      'newPassword': newPassword,
    },
    timeout: const Duration(seconds: 90),
  );
}
