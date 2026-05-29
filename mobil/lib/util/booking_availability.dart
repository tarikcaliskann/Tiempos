import '../api/skills_api.dart';

const int bookingHorizonDays = 365;

int _toMinutes(String hhmm) {
  final p = hhmm.split(':');
  final h = int.tryParse(p.isNotEmpty ? p[0] : '0') ?? 0;
  final m = int.tryParse(p.length > 1 ? p[1] : '0') ?? 0;
  return h * 60 + m;
}

String _pad2(int v) => v.toString().padLeft(2, '0');

/// Web `buildHalfHourSlots` — [from, until) yarım saat dilimleri.
List<String> buildHalfHourSlots(String from, String until) {
  final out = <String>[];
  var cur = _toMinutes(from);
  final end = _toMinutes(until);
  while (cur < end) {
    final h = cur ~/ 60;
    final m = cur % 60;
    out.add('${_pad2(h)}:${_pad2(m)}');
    cur += 30;
  }
  return out;
}

String dateToYmd(DateTime d) =>
    '${d.year}-${_pad2(d.month)}-${_pad2(d.day)}';

bool hasSkillAvailabilityConstraints(SkillDto? skill) {
  if (skill == null) return false;
  return skill.availableDays.isNotEmpty &&
      (skill.availableFrom ?? '').isNotEmpty &&
      (skill.availableUntil ?? '').isNotEmpty;
}

DateTime _localDateTime(String ymd, String slot) {
  final dp = ymd.split('-').map(int.parse).toList();
  final tp = slot.split(':');
  final hh = int.tryParse(tp.isNotEmpty ? tp[0] : '0') ?? 0;
  final mm = int.tryParse(tp.length > 1 ? tp[1] : '0') ?? 0;
  return DateTime(dp[0], dp[1], dp[2], hh, mm);
}

class BookingDateOption {
  BookingDateOption({required this.value, required this.label});
  final String value;
  final String label;
}

const _dayKeys = [
  'SUNDAY',
  'MONDAY',
  'TUESDAY',
  'WEDNESDAY',
  'THURSDAY',
  'FRIDAY',
  'SATURDAY',
];

/// Web `buildSkillDateOptions` — en az 1 saat sonrası slot olan günler.
List<BookingDateOption> buildSkillDateOptions(
  SkillDto skill,
  String localeCode,
  int horizonDays,
) {
  final days = skill.availableDays;
  final from = skill.availableFrom;
  final until = skill.availableUntil;
  if (days.isEmpty || from == null || until == null || from.isEmpty || until.isEmpty) {
    return [];
  }
  final allowed = days.map((e) => e.toUpperCase()).toSet();
  final baseSlots = buildHalfHourSlots(from, until);
  final now = DateTime.now();
  final minMs = now.millisecondsSinceEpoch + 60 * 60 * 1000;
  final options = <BookingDateOption>[];
  final loc = localeCode.toLowerCase().startsWith('tr')
      ? 'tr_TR'
      : 'en_US';

  for (var i = 0; i < horizonDays; i++) {
    final d = DateTime(now.year, now.month, now.day + i);
    final dayCode = _dayKeys[d.weekday % 7];
    if (!allowed.contains(dayCode)) continue;
    final ymd = dateToYmd(d);
    var validSlotExists = false;
    for (final slot in baseSlots) {
      final candidate = _localDateTime(ymd, slot);
      if (candidate.millisecondsSinceEpoch >= minMs) {
        validSlotExists = true;
        break;
      }
    }
    if (!validSlotExists) continue;
    options.add(
      BookingDateOption(
        value: ymd,
        label: _formatDateLabel(d, loc),
      ),
    );
  }
  return options;
}

String _formatDateLabel(DateTime d, String loc) {
  const weekdaysEn = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
  const weekdaysTr = ['Pzt', 'Sal', 'Çar', 'Per', 'Cum', 'Cmt', 'Paz'];
  final w = loc.startsWith('tr')
      ? weekdaysTr[(d.weekday - 1) % 7]
      : weekdaysEn[(d.weekday - 1) % 7];
  return '$w ${_pad2(d.day)}.${_pad2(d.month)}.${d.year}';
}

/// Seçilen gün için en az 1 saat sonrası slotlar.
List<String> buildSkillTimeOptionsForDate(SkillDto skill, String bookDateYmd) {
  final from = skill.availableFrom;
  final until = skill.availableUntil;
  if (from == null || until == null || bookDateYmd.isEmpty) return [];
  final minMs = DateTime.now().millisecondsSinceEpoch + 60 * 60 * 1000;
  return buildHalfHourSlots(from, until).where((slot) {
    final candidate = _localDateTime(bookDateYmd, slot);
    return candidate.millisecondsSinceEpoch >= minMs;
  }).toList();
}

bool isWithinSkillAvailability(
  SkillDto skill,
  String dateStr,
  String timeStr,
) {
  final days = skill.availableDays;
  final from = skill.availableFrom;
  final until = skill.availableUntil;
  if (days.isEmpty || from == null || until == null || from.isEmpty || until.isEmpty) {
    return true;
  }
  final dp = dateStr.split('-').map(int.parse).toList();
  final d = DateTime(dp[0], dp[1], dp[2]);
  final weekday = _dayKeys[d.weekday % 7];
  if (!days.map((e) => e.toUpperCase()).contains(weekday)) return false;
  final t = _toMinutes(timeStr);
  return t >= _toMinutes(from) && t < _toMinutes(until);
}
