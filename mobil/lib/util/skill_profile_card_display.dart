import '../api/skills_api.dart';

/// Web `skillCardDescriptionPreview`.
String skillCardDescriptionPreview(String description) {
  const sep = '\n\n———\n';
  final idx = description.indexOf(sep);
  if (idx >= 0) {
    return description.substring(0, idx).trim();
  }

  final filtered = description
      .split('\n')
      .map((line) => line.trim())
      .where((line) => line.isNotEmpty)
      .where((line) {
        final lower = line.toLowerCase();
        return !(
            lower.startsWith('session type') ||
            lower.startsWith('oturum türü') ||
            lower.startsWith('location') ||
            lower.startsWith('konum') ||
            lower.startsWith('available days') ||
            lower.startsWith('müsait günler') ||
            lower.startsWith('available from') ||
            lower.startsWith('başlangıç') ||
            lower.startsWith('available until') ||
            lower.startsWith('bitiş') ||
            lower.startsWith('tags') ||
            lower.startsWith('etiketler'));
      });

  return filtered.join(' ').trim();
}

/// Web `fallbackSessionTypeFromDescription`.
String? fallbackSessionTypeFromDescription(String description) {
  final m = RegExp(
    r'(?:Session Type \*|Oturum türü \*)\s*:\s*([^\n]+)',
    caseSensitive: false,
  ).firstMatch(description);
  return m?.group(1)?.trim();
}

/// Web `fallbackLocationFromDescription`.
String? fallbackLocationFromDescription(String description) {
  final m = RegExp(
    r'(?:Location|Konum)\s*:\s*([^\n]+)',
    caseSensitive: false,
  ).firstMatch(description);
  return m?.group(1)?.trim();
}

const _weekdayLabelIndex = <String, int>{
  'MONDAY': 0,
  'TUESDAY': 1,
  'WEDNESDAY': 2,
  'THURSDAY': 3,
  'FRIDAY': 4,
  'SATURDAY': 5,
  'SUNDAY': 6,
};

const _weekdaySortOrder = <String, int>{
  'MONDAY': 0,
  'TUESDAY': 1,
  'WEDNESDAY': 2,
  'THURSDAY': 3,
  'FRIDAY': 4,
  'SATURDAY': 5,
  'SUNDAY': 6,
};

/// Web `SkillAvailabilityParts`.
class SkillAvailabilityParts {
  SkillAvailabilityParts({required this.days, required this.hours});

  final String days;
  final String hours;
}

String _localizeSkillDays(List<String> dayKeys, List<String> dayLabels) {
  final items = dayKeys.map((key) {
    final u = key.toUpperCase();
    final idx = _weekdayLabelIndex[u];
    final label = idx != null && idx < dayLabels.length ? dayLabels[idx] : key;
    final order = _weekdaySortOrder[u] ?? 99;
    return (order: order, label: label);
  }).where((e) => e.label.isNotEmpty).toList()
    ..sort((a, b) => a.order.compareTo(b.order));
  return items.map((e) => e.label).join(', ');
}

/// Web `getSkillAvailabilityParts`.
SkillAvailabilityParts? getSkillAvailabilityParts(
  SkillDto skill,
  List<String> dayLabels,
) {
  final days = skill.availableDays;
  final from = skill.availableFrom;
  final until = skill.availableUntil;
  if (days.isEmpty || from == null || from.isEmpty || until == null || until.isEmpty) {
    return null;
  }
  return SkillAvailabilityParts(
    days: _localizeSkillDays(days, dayLabels),
    hours: '$from – $until',
  );
}

SkillAvailabilityParts? _availabilityFromDaysRaw(
  String daysRaw,
  String from,
  String until,
  List<String> dayLabels,
) {
  final dayKeys = daysRaw
      .split(',')
      .map((d) => d.trim())
      .where((d) => d.isNotEmpty)
      .map((d) => d.toUpperCase().replaceAll(RegExp(r'\s+'), '_'))
      .toList();
  return SkillAvailabilityParts(
    days: _localizeSkillDays(dayKeys, dayLabels),
    hours: '$from – $until',
  );
}

/// Web `fallbackAvailabilityFromDescription`.
SkillAvailabilityParts? fallbackAvailabilityFromDescription(
  String description,
  List<String> dayLabels,
) {
  final re1 = RegExp(
    r'(Available Days \*|Müsait günler \*):\s*([^\n]+?)\s+(Available From \*|Başlangıç \*)[–-](Available Until \*|Bitiş \*):\s*(\d{2}:\d{2})\s*[–-]\s*(\d{2}:\d{2})',
    caseSensitive: false,
  );
  final m1 = re1.firstMatch(description);
  if (m1 != null) {
    final daysRaw = m1.group(2)?.trim();
    final from = m1.group(5)?.trim();
    final until = m1.group(6)?.trim();
    if (daysRaw != null &&
        daysRaw.isNotEmpty &&
        from != null &&
        from.isNotEmpty &&
        until != null &&
        until.isNotEmpty) {
      return _availabilityFromDaysRaw(daysRaw, from, until, dayLabels);
    }
  }
  final re2 = RegExp(
    r'(Available Days \*|Müsait günler \*):\s*([^\n]+)\n(?:.*)\s*(\d{2}:\d{2})\s*[–-]\s*(\d{2}:\d{2})',
    caseSensitive: false,
  );
  final m2 = re2.firstMatch(description);
  if (m2 != null) {
    final daysRaw = m2.group(2)?.trim();
    final from = m2.group(3)?.trim();
    final until = m2.group(4)?.trim();
    if (daysRaw != null &&
        daysRaw.isNotEmpty &&
        from != null &&
        from.isNotEmpty &&
        until != null &&
        until.isNotEmpty) {
      return _availabilityFromDaysRaw(daysRaw, from, until, dayLabels);
    }
  }
  return null;
}

/// Web `profile.skillLevels` (en) — görünen metin.
String? displaySkillLevel(String? level) {
  if (level == null || level.trim().isEmpty) return null;
  final t = level.trim();
  final k = t.length <= 1
      ? t.toUpperCase()
      : '${t.substring(0, 1).toUpperCase()}${t.substring(1).toLowerCase()}';
  const map = {
    'Beginner': 'Beginner',
    'Intermediate': 'Intermediate',
    'Advanced': 'Advanced',
    'Expert': 'Expert',
  };
  return map[k] ?? k;
}

/// Web `addSkill` inPerson / online etiketleri.
String formatSessionTypeChip(String raw) {
  final v = raw.toLowerCase().trim();
  if (v == 'online') return 'Online';
  if (v == 'in-person' || v.contains('person')) return 'In-Person';
  return raw;
}
