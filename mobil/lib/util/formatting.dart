/// Web `DashboardPage` `formatBookedDuration` (en).
String formatBookedDurationEn(int minutes) {
  final h = minutes ~/ 60;
  final m = minutes % 60;
  if (h > 0 && m == 0) return '$h h';
  if (h > 0) return '$h h $m min';
  return '$m min';
}

/// Web `formatDashCredits` (en).
String formatDashCreditsEn(int minutes) {
  final h = minutes ~/ 60;
  final m = minutes % 60;
  if (h > 0 && m == 0) return '$h h';
  if (h > 0) return '$h h $m min';
  return '$m min';
}

String firstNameFromFullName(String fullName) {
  final p = fullName.trim().split(RegExp(r'\s+')).where((e) => e.isNotEmpty).toList();
  if (p.isEmpty) return 'there';
  return p.first;
}

String initialsFromFullName(String fullName) {
  final p = fullName.trim().split(RegExp(r'\s+')).where((e) => e.isNotEmpty).toList();
  if (p.length >= 2) {
    return '${p.first[0]}${p.last[0]}'.toUpperCase();
  }
  if (p.length == 1 && p.first.length >= 2) {
    return p.first.substring(0, 2).toUpperCase();
  }
  if (p.isNotEmpty) return p.first[0].toUpperCase();
  return '?';
}

/// Navbar / küçük avatar: adın ilk harfi; yoksa e-postanın ilk harf/rakamı.
String avatarLetterFromUser(String? fullName, String? email) {
  final n = fullName?.trim();
  if (n != null && n.isNotEmpty) {
    final parts = n.split(RegExp(r'\s+')).where((e) => e.isNotEmpty).toList();
    if (parts.isNotEmpty) {
      final w = parts.first;
      for (final r in w.runes) {
        final s = String.fromCharCode(r);
        if (RegExp(r'[A-Za-z0-9]').hasMatch(s)) return s.toUpperCase();
      }
    }
  }
  final e = email?.trim();
  if (e != null && e.isNotEmpty) {
    for (final r in e.runes) {
      final s = String.fromCharCode(r);
      if (RegExp(r'[A-Za-z0-9]').hasMatch(s)) return s.toUpperCase();
    }
  }
  return '?';
}
