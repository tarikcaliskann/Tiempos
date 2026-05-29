import 'dart:convert';

import 'api_client.dart';
import 'api_exception.dart';

/// Web `GET /api/public/stats` ile aynı.
class PublicPlatformStats {
  const PublicPlatformStats({
    required this.verifiedMemberCount,
    required this.skillsListedCount,
    required this.completedSessionMinutesTotal,
    required this.reviewCount,
    required this.satisfactionPercent,
  });

  final int verifiedMemberCount;
  final int skillsListedCount;
  final int completedSessionMinutesTotal;
  final int reviewCount;
  final double? satisfactionPercent;

  factory PublicPlatformStats.fromJson(Map<String, dynamic> j) {
    double? sat;
    final s = j['satisfactionPercent'];
    if (s is num) sat = s.toDouble();

    return PublicPlatformStats(
      verifiedMemberCount: (j['verifiedMemberCount'] as num?)?.toInt() ?? 0,
      skillsListedCount: (j['skillsListedCount'] as num?)?.toInt() ?? 0,
      completedSessionMinutesTotal: (j['completedSessionMinutesTotal'] as num?)?.toInt() ?? 0,
      reviewCount: (j['reviewCount'] as num?)?.toInt() ?? 0,
      satisfactionPercent: sat,
    );
  }
}

Future<PublicPlatformStats?> fetchPublicPlatformStats() async {
  try {
    final raw = await apiFetch('/api/public/stats', timeout: const Duration(seconds: 20));
    if (raw is Map) {
      return PublicPlatformStats.fromJson(Map<String, dynamic>.from(raw));
    }
  } catch (_) {}
  return null;
}

/// Web `POST /api/public/contact` ile aynı gövde.
Future<void> submitContactForm({
  required String name,
  required String email,
  required String subject,
  required String subjectTitle,
  required String message,
}) async {
  await apiFetch(
    '/api/public/contact',
    method: 'POST',
    body: jsonEncode(<String, String>{
      'name': name,
      'email': email,
      'subject': subject,
      'subjectTitle': subjectTitle,
      'message': message,
    }),
    timeout: const Duration(seconds: 45),
  );
}

/// İletişim formu hata mesajı — web `ContactPage` ile uyumlu kodlar.
String contactSubmitErrorMessage(Object err, String fallback, {required bool tr}) {
  if (err is ApiException) {
    final code = _contact503Code(err.body);
    if (err.statusCode == 503) {
      if (code == 'smtp_send_failed') {
        return tr ? _errSmtpSendFailedTr : _errSmtpSendFailedEn;
      }
      if (code == 'smtp_not_ready') {
        return tr ? _errSmtpNotReadyTr : _errSmtpNotReadyEn;
      }
      return tr ? _errUnavailableTr : _errUnavailableEn;
    }
    if (err.statusCode == 401 || err.statusCode == 403) {
      return tr ? _errSendAuthTr : _errSendAuthEn;
    }
    if (err.statusCode == 404) {
      return tr ? _errSendNotFoundTr : _errSendNotFoundEn;
    }
    if (err.message.trim().isNotEmpty) return err.message;
  }
  return fallback;
}

String _contact503Code(Object? body) {
  if (body is Map && body['code'] is String) {
    return (body['code'] as String).trim();
  }
  return '';
}

const _errSmtpSendFailedEn =
    'SMTP connected but sending failed or was rejected. See API logs. You can still email tiempos.site@gmail.com.';
const _errSmtpSendFailedTr =
    'SMTP bağlantısı kuruldu ama gönderim reddedildi. API loglarına bakın. Yine de tiempos.site@gmail.com adresine yazabilirsiniz.';

const _errSmtpNotReadyEn =
    'Outbound email (SMTP) is not set up on the server. You can still email tiempos.site@gmail.com.';
const _errSmtpNotReadyTr =
    'Sunucuda giden posta (SMTP) yapılandırması eksik. Yine de tiempos.site@gmail.com adresine yazabilirsiniz.';

const _errUnavailableEn =
    'Email could not be sent. Check SMTP on the API or write to tiempos.site@gmail.com.';
const _errUnavailableTr =
    'E-posta gönderilemedi. API SMTP ayarlarını kontrol edin veya tiempos.site@gmail.com yazın.';

const _errSendAuthEn =
    'The server blocked this request. You can still email us at the address below.';
const _errSendAuthTr =
    'Sunucu isteği reddetti. Yine de aşağıdaki e-posta adresine yazabilirsiniz.';

const _errSendNotFoundEn =
    'The contact endpoint was not found (404). You can still email us below.';
const _errSendNotFoundTr =
    'İletişim uç noktası bulunamadı (404). Yine de aşağıdaki e-postaya yazabilirsiniz.';
