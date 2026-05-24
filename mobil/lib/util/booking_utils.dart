/// Yerel tarih + saat → ISO-8601 UTC (web SkillDetailPage ile aynı mantık).
String localDateTimeToUtcIso(String dateYmd, String timeHm) {
  final dp = dateYmd.split('-').map(int.parse).toList();
  final tp = timeHm.split(':');
  final hh = int.tryParse(tp.isNotEmpty ? tp[0] : '0') ?? 0;
  final mm = int.tryParse(tp.length > 1 ? tp[1] : '0') ?? 0;
  final local = DateTime(dp[0], dp[1], dp[2], hh, mm);
  return local.toUtc().toIso8601String();
}

String tomorrowDateStr() {
  final t = DateTime.now().add(const Duration(days: 1));
  return '${t.year.toString().padLeft(4, "0")}-${t.month.toString().padLeft(2, "0")}-${t.day.toString().padLeft(2, "0")}';
}

bool isWithinAvailability({
  required List<String> availableDaysUpper,
  required String? availableFrom,
  required String? availableUntil,
  required String dateYmd,
  required String timeHm,
}) {
  if (availableDaysUpper.isEmpty ||
      availableFrom == null ||
      availableUntil == null ||
      availableFrom.isEmpty ||
      availableUntil.isEmpty) {
    return true;
  }
  final dp = dateYmd.split('-').map(int.parse).toList();
  final d = DateTime(dp[0], dp[1], dp[2]);
  const keys = [
    'MONDAY',
    'TUESDAY',
    'WEDNESDAY',
    'THURSDAY',
    'FRIDAY',
    'SATURDAY',
    'SUNDAY',
  ];
  final weekday = keys[(d.weekday - 1) % 7];
  final upper = availableDaysUpper.map((e) => e.toUpperCase()).toList();
  if (!upper.contains(weekday)) return false;
  return timeHm.compareTo(availableFrom) >= 0 &&
      timeHm.compareTo(availableUntil) < 0;
}

List<String> buildHalfHourSlots(String from, String until) {
  int toMin(String t) {
    final p = t.split(':');
    final h = int.tryParse(p.isNotEmpty ? p[0] : '0') ?? 0;
    final m = int.tryParse(p.length > 1 ? p[1] : '0') ?? 0;
    return h * 60 + m;
  }

  String pad2(int v) => v.toString().padLeft(2, '0');
  final out = <String>[];
  var cur = toMin(from);
  final end = toMin(until);
  while (cur < end) {
    final h = cur ~/ 60;
    final m = cur % 60;
    out.add('${pad2(h)}:${pad2(m)}');
    cur += 30;
  }
  return out;
}
