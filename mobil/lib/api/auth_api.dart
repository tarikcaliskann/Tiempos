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
    timeout: const Duration(seconds: 180),
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
    timeout: const Duration(seconds: 90),
  );
  if (data is! Map) {
    throw StateError('Invalid google-config response');
  }
  return GoogleAuthConfig.fromJson(Map<String, dynamic>.from(data));
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
