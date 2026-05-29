import '../config/api_config.dart';
import 'api_client.dart';

/// Web `frontend/src/api/skills.ts` — SkillDto ile uyumlu.
class SkillDto {
  SkillDto({
    required this.id,
    required this.title,
    required this.description,
    required this.durationMinutes,
    required this.category,
    required this.level,
    required this.sessionTypes,
    required this.inPersonLocation,
    required this.availableDays,
    required this.availableFrom,
    required this.availableUntil,
    required this.ownerId,
    required this.ownerName,
    required this.createdAt,
    required this.coverImageUrl,
  });

  final String id;
  final String title;
  final String description;
  final int durationMinutes;
  final String? category;
  final String? level;
  final List<String> sessionTypes;
  final String? inPersonLocation;
  final List<String> availableDays;
  final String? availableFrom;
  final String? availableUntil;
  final String ownerId;
  final String ownerName;
  final String createdAt;
  final String? coverImageUrl;

  factory SkillDto.fromJson(Map<String, dynamic> j) {
    List<String> strList(dynamic v) {
      if (v is! List) return [];
      return v.map((e) => '$e').toList();
    }

    return SkillDto(
      id: '${j['id']}',
      title: j['title'] as String? ?? '',
      description: j['description'] as String? ?? '',
      durationMinutes: (j['durationMinutes'] as num?)?.toInt() ?? 0,
      category: j['category'] as String?,
      level: j['level'] as String?,
      sessionTypes: strList(j['sessionTypes']),
      inPersonLocation: j['inPersonLocation'] as String?,
      availableDays: strList(j['availableDays']),
      availableFrom: j['availableFrom'] as String?,
      availableUntil: j['availableUntil'] as String?,
      ownerId: '${j['ownerId'] ?? ''}',
      ownerName: j['ownerName'] as String? ?? '',
      createdAt: j['createdAt'] as String? ?? '',
      coverImageUrl: j['coverImageUrl'] as String?,
    );
  }
}

/// Backend proxy kapak — web `skillCoverProxyUrl`.
String skillCoverProxyUrl(String skillId) {
  final base = ApiConfig.baseUrl;
  return '$base/api/skills/$skillId/cover';
}

Future<List<SkillDto>> fetchPublicSkills() async {
  final data = await apiFetch('/api/skills');
  if (data is! List) return [];
  return data
      .whereType<Map>()
      .map((e) => SkillDto.fromJson(Map<String, dynamic>.from(e)))
      .toList();
}

Future<SkillDto> fetchSkillById(String skillId) async {
  final data = await apiFetch('/api/skills/${Uri.encodeComponent(skillId)}');
  if (data is! Map) {
    throw StateError('Invalid skill response');
  }
  return SkillDto.fromJson(Map<String, dynamic>.from(data));
}

Future<List<SkillDto>> fetchMySkills(String token) async {
  final data = await apiFetch('/api/skills/mine', token: token);
  if (data is! List) return [];
  return data
      .whereType<Map>()
      .map((e) => SkillDto.fromJson(Map<String, dynamic>.from(e)))
      .toList();
}

Future<SkillDto> createSkill(String token, Map<String, dynamic> body) async {
  final data = await apiFetch(
    '/api/skills',
    method: 'POST',
    body: body,
    token: token,
  );
  if (data is! Map) throw StateError('Invalid create skill response');
  return SkillDto.fromJson(Map<String, dynamic>.from(data));
}

Future<SkillDto> updateSkill(
  String token,
  String skillId,
  Map<String, dynamic> body,
) async {
  final data = await apiFetch(
    '/api/skills/${Uri.encodeComponent(skillId)}',
    method: 'PUT',
    body: body,
    token: token,
  );
  if (data is! Map) throw StateError('Invalid update skill response');
  return SkillDto.fromJson(Map<String, dynamic>.from(data));
}
