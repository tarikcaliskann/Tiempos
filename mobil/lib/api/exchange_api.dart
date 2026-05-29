import 'api_client.dart';

class ExchangeRequestDto {
  ExchangeRequestDto({
    required this.id,
    required this.skillId,
    required this.skillTitle,
    required this.requesterId,
    required this.requesterName,
    required this.ownerId,
    required this.ownerName,
    required this.message,
    required this.bookedMinutes,
    this.scheduledStartAt,
    required this.status,
    required this.createdAt,
    this.pendingFromOwner = false,
    this.inquiryOnly = false,
    this.sessionMeetingUrl,
    this.requesterAttendanceAckAt,
    this.ownerAttendanceAckAt,
  });

  final String id;
  final String skillId;
  final String skillTitle;
  final String requesterId;
  final String requesterName;
  final String ownerId;
  final String ownerName;
  final String message;
  final int bookedMinutes;
  final String? scheduledStartAt;
  final String status;
  final String createdAt;
  final bool pendingFromOwner;
  final bool inquiryOnly;
  final String? sessionMeetingUrl;
  final String? requesterAttendanceAckAt;
  final String? ownerAttendanceAckAt;

  factory ExchangeRequestDto.fromJson(Map<String, dynamic> j) {
    return ExchangeRequestDto(
      id: '${j['id']}',
      skillId: '${j['skillId'] ?? ''}',
      skillTitle: j['skillTitle'] as String? ?? '',
      requesterId: '${j['requesterId'] ?? ''}',
      requesterName: j['requesterName'] as String? ?? '',
      ownerId: '${j['ownerId'] ?? ''}',
      ownerName: j['ownerName'] as String? ?? '',
      message: j['message'] as String? ?? '',
      bookedMinutes: (j['bookedMinutes'] as num?)?.toInt() ?? 0,
      scheduledStartAt: j['scheduledStartAt'] != null
          ? '${j['scheduledStartAt']}'
          : null,
      status: j['status'] as String? ?? '',
      createdAt: j['createdAt'] != null ? '${j['createdAt']}' : '',
      pendingFromOwner: j['pendingFromOwner'] == true,
      inquiryOnly: j['inquiryOnly'] == true,
      sessionMeetingUrl: j['sessionMeetingUrl'] as String?,
      requesterAttendanceAckAt: j['requesterAttendanceAckAt'] != null
          ? '${j['requesterAttendanceAckAt']}'
          : null,
      ownerAttendanceAckAt: j['ownerAttendanceAckAt'] != null
          ? '${j['ownerAttendanceAckAt']}'
          : null,
    );
  }
}

class ExchangeMessageDto {
  ExchangeMessageDto({
    required this.id,
    required this.senderId,
    required this.senderName,
    required this.body,
    required this.createdAt,
  });

  final String id;
  final String senderId;
  final String senderName;
  final String body;
  final String createdAt;

  factory ExchangeMessageDto.fromJson(Map<String, dynamic> j) {
    return ExchangeMessageDto(
      id: '${j['id']}',
      senderId: '${j['senderId'] ?? ''}',
      senderName: j['senderName'] as String? ?? '',
      body: j['body'] as String? ?? '',
      createdAt: j['createdAt'] != null ? '${j['createdAt']}' : '',
    );
  }
}

Future<List<ExchangeRequestDto>> fetchSentExchangeRequests(String token) async {
  final data = await apiFetch('/api/exchange-requests/sent', token: token);
  return _parseList(data);
}

Future<List<ExchangeRequestDto>> fetchReceivedExchangeRequests(String token) async {
  final data = await apiFetch('/api/exchange-requests/received', token: token);
  return _parseList(data);
}

List<ExchangeRequestDto> _parseList(dynamic data) {
  if (data is! List) return [];
  return data
      .whereType<Map>()
      .map((e) => ExchangeRequestDto.fromJson(Map<String, dynamic>.from(e)))
      .toList();
}

Future<List<ExchangeRequestDto>> fetchUpcomingAccepted(String token) async {
  final sent = await fetchSentExchangeRequests(token);
  final received = await fetchReceivedExchangeRequests(token);
  final map = <String, ExchangeRequestDto>{};
  for (final e in sent) {
    map[e.id] = e;
  }
  for (final e in received) {
    map[e.id] = e;
  }
  final accepted =
      map.values.where((e) => e.status.toUpperCase() == 'ACCEPTED').toList();
  accepted.sort((a, b) => b.createdAt.compareTo(a.createdAt));
  return accepted;
}

Future<ExchangeRequestDto> createExchangeRequest({
  required String token,
  required String skillId,
  required String message,
  required int bookedMinutes,
  required String scheduledStartAt,
  bool inquiryOnly = false,
}) async {
  final body = <String, dynamic>{
    'message': message,
    'bookedMinutes': bookedMinutes,
    'scheduledStartAt': scheduledStartAt,
    if (inquiryOnly) 'inquiryOnly': true,
  };
  final data = await apiFetch(
    '/api/exchange-requests/skill/${Uri.encodeComponent(skillId)}',
    method: 'POST',
    body: body,
    token: token,
  );
  if (data is! Map) throw StateError('Invalid exchange create response');
  return ExchangeRequestDto.fromJson(Map<String, dynamic>.from(data));
}

Future<List<ExchangeMessageDto>> fetchExchangeMessages({
  required String token,
  required String exchangeRequestId,
}) async {
  final data = await apiFetch(
    '/api/exchange-requests/${Uri.encodeComponent(exchangeRequestId)}/messages',
    token: token,
  );
  if (data is! List) return [];
  return data
      .whereType<Map>()
      .map((e) => ExchangeMessageDto.fromJson(Map<String, dynamic>.from(e)))
      .toList();
}

Future<ExchangeMessageDto> postExchangeMessage({
  required String token,
  required String exchangeRequestId,
  required String body,
}) async {
  final data = await apiFetch(
    '/api/exchange-requests/${Uri.encodeComponent(exchangeRequestId)}/messages',
    method: 'POST',
    body: {'body': body},
    token: token,
  );
  if (data is! Map) throw StateError('Invalid message response');
  return ExchangeMessageDto.fromJson(Map<String, dynamic>.from(data));
}

Future<List<ExchangeRequestDto>> fetchAllExchangeRequests(String token) async {
  final sent = await fetchSentExchangeRequests(token);
  final received = await fetchReceivedExchangeRequests(token);
  final map = <String, ExchangeRequestDto>{};
  for (final e in sent) {
    map[e.id] = e;
  }
  for (final e in received) {
    map[e.id] = e;
  }
  final list = map.values.toList();
  list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
  return list;
}

Future<ExchangeRequestDto> acceptExchangeRequest(String token, String id) async {
  final data = await apiFetch(
    '/api/exchange-requests/${Uri.encodeComponent(id)}/accept',
    method: 'PUT',
    token: token,
  );
  if (data is! Map) throw StateError('Invalid accept response');
  return ExchangeRequestDto.fromJson(Map<String, dynamic>.from(data));
}

Future<ExchangeRequestDto> rejectExchangeRequest(String token, String id) async {
  final data = await apiFetch(
    '/api/exchange-requests/${Uri.encodeComponent(id)}/reject',
    method: 'PUT',
    token: token,
  );
  if (data is! Map) throw StateError('Invalid reject response');
  return ExchangeRequestDto.fromJson(Map<String, dynamic>.from(data));
}

Future<ExchangeRequestDto> cancelExchangeRequest(String token, String id) async {
  final data = await apiFetch(
    '/api/exchange-requests/${Uri.encodeComponent(id)}/cancel',
    method: 'PUT',
    token: token,
  );
  if (data is! Map) throw StateError('Invalid cancel response');
  return ExchangeRequestDto.fromJson(Map<String, dynamic>.from(data));
}

Future<ExchangeRequestDto> createCounterOffer({
  required String token,
  required String requestId,
  required String message,
  required int bookedMinutes,
  required String scheduledStartAt,
}) async {
  final data = await apiFetch(
    '/api/exchange-requests/${Uri.encodeComponent(requestId)}/counter-offer',
    method: 'POST',
    body: {
      'message': message,
      'bookedMinutes': bookedMinutes,
      'scheduledStartAt': scheduledStartAt,
    },
    token: token,
  );
  if (data is! Map) throw StateError('Invalid counter-offer response');
  return ExchangeRequestDto.fromJson(Map<String, dynamic>.from(data));
}

Future<ExchangeRequestDto> createRequesterCounterOffer({
  required String token,
  required String requestId,
  required String message,
  required int bookedMinutes,
  required String scheduledStartAt,
}) async {
  final data = await apiFetch(
    '/api/exchange-requests/${Uri.encodeComponent(requestId)}/requester-counter-offer',
    method: 'POST',
    body: {
      'message': message,
      'bookedMinutes': bookedMinutes,
      'scheduledStartAt': scheduledStartAt,
    },
    token: token,
  );
  if (data is! Map) throw StateError('Invalid requester counter-offer response');
  return ExchangeRequestDto.fromJson(Map<String, dynamic>.from(data));
}

Future<ExchangeRequestDto> updateExchangeSessionMeeting({
  required String token,
  required String exchangeId,
  required String meetingUrl,
}) async {
  final data = await apiFetch(
    '/api/exchange-requests/${Uri.encodeComponent(exchangeId)}/meeting',
    method: 'PUT',
    body: {'meetingUrl': meetingUrl.trim()},
    token: token,
  );
  if (data is! Map) throw StateError('Invalid meeting response');
  return ExchangeRequestDto.fromJson(Map<String, dynamic>.from(data));
}

Future<ExchangeRequestDto> acknowledgeRequesterAttendance(
  String token,
  String exchangeId,
) async {
  final data = await apiFetch(
    '/api/exchange-requests/${Uri.encodeComponent(exchangeId)}/ack-attendance',
    method: 'POST',
    token: token,
  );
  if (data is! Map) throw StateError('Invalid ack response');
  return ExchangeRequestDto.fromJson(Map<String, dynamic>.from(data));
}

Future<ExchangeRequestDto> acknowledgeOwnerAttendance(
  String token,
  String exchangeId,
) async {
  final data = await apiFetch(
    '/api/exchange-requests/${Uri.encodeComponent(exchangeId)}/ack-owner-attendance',
    method: 'POST',
    token: token,
  );
  if (data is! Map) throw StateError('Invalid owner ack response');
  return ExchangeRequestDto.fromJson(Map<String, dynamic>.from(data));
}
