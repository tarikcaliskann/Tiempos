/// Web `skillForm.buildSkillDescription` ile aynı biçim (İngilizce etiketler).
String buildSkillDescriptionForApi({
  required String baseDescription,
  required List<String> sessionTypes,
  required String inPersonLocation,
  required List<String> selectedDaysDisplay,
  required List<String> dayLabels,
  required String startTime,
  required String endTime,
  required List<String> tags,
}) {
  const sessionType = 'Session Type';
  const location = 'Location';
  const availableDays = 'Available Days';
  const availableFromUntil = 'Available From–Available Until';
  const tagsLabel = 'Tags';

  final lines = <String>[];
  if (sessionTypes.isNotEmpty) {
    lines.add('$sessionType: ${sessionTypes.join(", ")}');
  }
  if (inPersonLocation.trim().isNotEmpty) {
    lines.add('$location: ${inPersonLocation.trim()}');
  }
  if (selectedDaysDisplay.isNotEmpty) {
    final dayPart = <String>[];
    for (var i = 0; i < selectedDaysDisplay.length; i++) {
      final key = selectedDaysDisplay[i];
      final idx = [
        'MONDAY',
        'TUESDAY',
        'WEDNESDAY',
        'THURSDAY',
        'FRIDAY',
        'SATURDAY',
        'SUNDAY',
      ].indexOf(key.toUpperCase());
      dayPart.add(idx >= 0 && idx < dayLabels.length ? dayLabels[idx] : key);
    }
    lines.add('$availableDays: ${dayPart.join(", ")}');
  }
  if (startTime.isNotEmpty || endTime.isNotEmpty) {
    lines.add(
      '$availableFromUntil: ${startTime.isEmpty ? "—" : startTime} – ${endTime.isEmpty ? "—" : endTime}',
    );
  }
  if (tags.isNotEmpty) {
    lines.add('$tagsLabel: ${tags.join(", ")}');
  }
  final trimmed = baseDescription.trim();
  if (lines.isEmpty) return trimmed;
  if (trimmed.isEmpty) return lines.join('\n');
  return '$trimmed\n\n———\n${lines.join('\n')}';
}
