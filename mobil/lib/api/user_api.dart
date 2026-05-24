import 'api_client.dart';

class UserDashboardDto {
  UserDashboardDto({
    required this.fullName,
    required this.timeCreditMinutes,
    required this.mySkillsCount,
    required this.sentRequestsCount,
    required this.receivedRequestsCount,
  });

  final String fullName;
  final int timeCreditMinutes;
  final int mySkillsCount;
  final int sentRequestsCount;
  final int receivedRequestsCount;

  factory UserDashboardDto.fromJson(Map<String, dynamic> j) {
    return UserDashboardDto(
      fullName: j['fullName'] as String? ?? '',
      timeCreditMinutes: (j['timeCreditMinutes'] as num?)?.toInt() ?? 0,
      mySkillsCount: (j['mySkillsCount'] as num?)?.toInt() ?? 0,
      sentRequestsCount: (j['sentRequestsCount'] as num?)?.toInt() ?? 0,
      receivedRequestsCount: (j['receivedRequestsCount'] as num?)?.toInt() ?? 0,
    );
  }
}

Future<UserDashboardDto> fetchMyDashboard(String token) async {
  final data = await apiFetch('/api/users/me/dashboard', token: token);
  if (data is! Map) {
    throw StateError('Invalid dashboard response');
  }
  return UserDashboardDto.fromJson(Map<String, dynamic>.from(data));
}

class UserProfileDto {
  UserProfileDto({
    required this.id,
    required this.fullName,
    required this.email,
    required this.bio,
    required this.phone,
    required this.location,
    required this.languages,
    required this.website,
    required this.linkedin,
    required this.twitter,
    required this.avatarUrl,
    required this.timeCreditMinutes,
    this.createdAt,
  });

  final String id;
  final String fullName;
  final String email;
  final String? bio;
  final String? phone;
  final String? location;
  final String? languages;
  final String? website;
  final String? linkedin;
  final String? twitter;
  final String? avatarUrl;
  final int timeCreditMinutes;
  final String? createdAt;

  factory UserProfileDto.fromJson(Map<String, dynamic> j) {
    return UserProfileDto(
      id: '${j['id'] ?? ''}',
      fullName: j['fullName'] as String? ?? '',
      email: j['email'] as String? ?? '',
      bio: j['bio'] as String?,
      phone: j['phone'] as String?,
      location: j['location'] as String?,
      languages: j['languages'] as String?,
      website: j['website'] as String?,
      linkedin: j['linkedin'] as String?,
      twitter: j['twitter'] as String?,
      avatarUrl: j['avatarUrl'] as String?,
      timeCreditMinutes: (j['timeCreditMinutes'] as num?)?.toInt() ?? 0,
      createdAt: j['createdAt'] != null ? '${j['createdAt']}' : null,
    );
  }
}

Future<UserProfileDto> fetchMyProfile(String token) async {
  final data = await apiFetch('/api/users/me/profile', token: token);
  if (data is! Map) throw StateError('Invalid profile response');
  return UserProfileDto.fromJson(Map<String, dynamic>.from(data));
}

Future<UserProfileDto> updateMyProfile({
  required String token,
  required String fullName,
  String? bio,
  String? phone,
  String? location,
  String? languages,
  String? website,
  String? linkedin,
  String? twitter,
  String? avatarUrl,
}) async {
  final data = await apiFetch(
    '/api/users/me/profile',
    method: 'PUT',
    token: token,
    body: {
      'fullName': fullName,
      'bio': bio,
      'phone': phone,
      'location': location,
      'languages': languages,
      'website': website,
      'linkedin': linkedin,
      'twitter': twitter,
      'avatarUrl': avatarUrl,
    },
  );
  if (data is! Map) throw StateError('Invalid profile update response');
  return UserProfileDto.fromJson(Map<String, dynamic>.from(data));
}

class PublicUserProfileDto {
  PublicUserProfileDto({
    required this.id,
    required this.fullName,
    required this.bio,
    required this.location,
    required this.languages,
    required this.website,
    required this.linkedin,
    required this.twitter,
    required this.avatarUrl,
    required this.memberSince,
    required this.averageRating,
    required this.totalReviews,
  });

  final String id;
  final String fullName;
  final String? bio;
  final String? location;
  final String? languages;
  final String? website;
  final String? linkedin;
  final String? twitter;
  final String? avatarUrl;
  final String memberSince;
  final double averageRating;
  final int totalReviews;

  factory PublicUserProfileDto.fromJson(Map<String, dynamic> j) {
    return PublicUserProfileDto(
      id: '${j['id'] ?? ''}',
      fullName: j['fullName'] as String? ?? '',
      bio: j['bio'] as String?,
      location: j['location'] as String?,
      languages: j['languages'] as String?,
      website: j['website'] as String?,
      linkedin: j['linkedin'] as String?,
      twitter: j['twitter'] as String?,
      avatarUrl: j['avatarUrl'] as String?,
      memberSince: j['memberSince'] as String? ?? '',
      averageRating: (j['averageRating'] as num?)?.toDouble() ?? 0,
      totalReviews: (j['totalReviews'] as num?)?.toInt() ?? 0,
    );
  }
}

Future<PublicUserProfileDto> fetchPublicUserProfile({
  required String token,
  required String userId,
}) async {
  final data = await apiFetch(
    '/api/users/${Uri.encodeComponent(userId)}/public',
    token: token,
  );
  if (data is! Map) throw StateError('Invalid public profile response');
  return PublicUserProfileDto.fromJson(Map<String, dynamic>.from(data));
}

class UserBlockStateDto {
  UserBlockStateDto({
    required this.blockedUserIds,
    required this.blockedByUserIds,
  });

  final List<String> blockedUserIds;
  final List<String> blockedByUserIds;

  factory UserBlockStateDto.fromJson(Map<String, dynamic> j) {
    List<String> ids(dynamic v) {
      if (v is! List) return [];
      return v.map((e) => '$e'.toLowerCase()).toList();
    }

    return UserBlockStateDto(
      blockedUserIds: ids(j['blockedUserIds'] ?? j['blocked_user_ids']),
      blockedByUserIds: ids(j['blockedByUserIds'] ?? j['blocked_by_user_ids']),
    );
  }
}

Future<UserBlockStateDto> fetchMyBlockState(String token) async {
  final data = await apiFetch('/api/users/me/blocks', token: token);
  if (data is! Map) throw StateError('Invalid blocks response');
  return UserBlockStateDto.fromJson(Map<String, dynamic>.from(data));
}

Future<UserBlockStateDto> blockUser(String token, String userId) async {
  final data = await apiFetch(
    '/api/users/${Uri.encodeComponent(userId)}/block',
    method: 'POST',
    token: token,
  );
  if (data is! Map) throw StateError('Invalid block response');
  return UserBlockStateDto.fromJson(Map<String, dynamic>.from(data));
}

Future<UserBlockStateDto> unblockUser(String token, String userId) async {
  final data = await apiFetch(
    '/api/users/${Uri.encodeComponent(userId)}/block',
    method: 'DELETE',
    token: token,
  );
  if (data is! Map) throw StateError('Invalid unblock response');
  return UserBlockStateDto.fromJson(Map<String, dynamic>.from(data));
}

/// Web `changePassword` — `POST /api/users/me/change-password`.
Future<void> changePassword({
  required String token,
  required String currentPassword,
  required String newPassword,
}) async {
  await apiFetch(
    '/api/users/me/change-password',
    method: 'POST',
    token: token,
    body: {
      'currentPassword': currentPassword,
      'newPassword': newPassword,
    },
  );
}

/// Web `deleteMyAccount` — `POST /api/users/me/delete`.
Future<void> deleteMyAccount(String token) async {
  await apiFetch(
    '/api/users/me/delete',
    method: 'POST',
    token: token,
  );
}
