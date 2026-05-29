import 'api_client.dart';

class NotificationDto {
  NotificationDto({
    required this.id,
    required this.title,
    required this.body,
    required this.createdAt,
    this.readAt,
    this.exchangeRequestId,
    this.skillTitle,
  });

  final String id;
  final String title;
  final String body;
  final String createdAt;
  final String? readAt;
  final String? exchangeRequestId;
  final String? skillTitle;

  factory NotificationDto.fromJson(Map<String, dynamic> j) {
    final readRaw = j['readAt'] ?? j['read_at'];
    final readAt = readRaw == null
        ? null
        : (readRaw is String ? readRaw : '$readRaw').trim().isEmpty
            ? null
            : (readRaw is String ? readRaw : '$readRaw');
    return NotificationDto(
      id: '${j['id'] ?? ''}'.trim(),
      title: j['title'] as String? ?? '',
      body: j['body'] as String? ?? '',
      createdAt: '${j['createdAt'] ?? j['created_at'] ?? ''}',
      readAt: readAt,
      exchangeRequestId: j['exchangeRequestId'] != null || j['exchange_request_id'] != null
          ? '${j['exchangeRequestId'] ?? j['exchange_request_id']}'
          : null,
      skillTitle: j['skillTitle'] != null || j['skill_title'] != null
          ? '${j['skillTitle'] ?? j['skill_title']}'
          : null,
    );
  }
}

bool isNotificationUnread(NotificationDto n) {
  final r = n.readAt;
  if (r == null) return true;
  return r.trim().isEmpty;
}

Future<List<NotificationDto>> fetchNotifications(String token) async {
  final data = await apiFetch('/api/notifications', token: token);
  if (data is! List) return [];
  return data
      .whereType<Map>()
      .map((e) => NotificationDto.fromJson(Map<String, dynamic>.from(e)))
      .toList();
}

Future<int> fetchUnreadNotificationCount(String token) async {
  final data = await apiFetch('/api/notifications/unread-count', token: token);
  if (data is! Map) return 0;
  final c = data['count'] ?? data['Count'];
  final n = c is num ? c.toInt() : int.tryParse('$c') ?? 0;
  return n;
}

Future<void> markNotificationRead(String token, String id) async {
  final q = Uri.encodeComponent(id.trim());
  await apiFetch('/api/notifications/mark-one-read?id=$q', method: 'POST', token: token);
}

Future<void> markAllNotificationsRead(String token) async {
  await apiFetch('/api/notifications/mark-all-read', method: 'POST', token: token);
}
