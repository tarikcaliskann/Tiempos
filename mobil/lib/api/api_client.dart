import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../config/api_config.dart';
import 'api_exception.dart';

/// Frontend `api/client.ts` ile aynı sözleşme: `baseUrl` + path (`/api/...`).
Future<dynamic> apiFetch(
  String path, {
  String method = 'GET',
  Map<String, String>? headers,
  Object? body,
  String? token,
  Duration timeout = const Duration(seconds: 90),
}) async {
  final base = ApiConfig.baseUrl;
  final p = path.startsWith('/') ? path : '/$path';
  final uri = Uri.parse('$base$p');

  final h = <String, String>{
    'Accept': 'application/json',
    ...?headers,
  };
  if (body != null && body is! String && body is! List<int>) {
    h.putIfAbsent('Content-Type', () => 'application/json');
  }
  if (token != null && token.isNotEmpty) {
    h['Authorization'] = 'Bearer $token';
  }

  final encodedBody = _encodeBody(body);
  http.Response res;
  try {
    switch (method.toUpperCase()) {
      case 'POST':
        res = await http.post(uri, headers: h, body: encodedBody).timeout(timeout);
        break;
      case 'PUT':
        res = await http.put(uri, headers: h, body: encodedBody).timeout(timeout);
        break;
      case 'DELETE':
        res = await http.delete(uri, headers: h).timeout(timeout);
        break;
      case 'GET':
      default:
        res = await http.get(uri, headers: h).timeout(timeout);
    }
  } catch (e) {
    if (e is TimeoutException) {
      throw ApiException(
        'Server did not respond in time. If the API was idle (e.g. Render free tier), wait a minute and try again — the first request can take 60–120s.',
        statusCode: 0,
      );
    }
    throw ApiException('Network error: $e', statusCode: 0);
  }

  return _parseResponse(res);
}

Object? _encodeBody(Object? body) {
  if (body == null) return null;
  if (body is String) return body;
  if (body is List<int>) return body;
  return jsonEncode(body);
}

dynamic _parseResponse(http.Response res) {
  final text = res.body;
  dynamic data;
  if (text.isNotEmpty) {
    try {
      data = jsonDecode(text) as dynamic;
    } catch (_) {
      data = text;
    }
  }

  if (res.statusCode < 200 || res.statusCode >= 300) {
    String msg = res.reasonPhrase ?? 'Request failed';
    if (data is Map && data['message'] is String) {
      final m = (data['message'] as String).trim();
      if (m.isNotEmpty) msg = m;
    }
    throw ApiException(msg, statusCode: res.statusCode, body: data);
  }
  return data;
}
