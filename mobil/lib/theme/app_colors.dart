import 'package:flutter/material.dart';

/// Web (`--primary`, `index.css` koyu zemin, auth/browse gradient) ile hizalı.
abstract final class AppColors {
  /// Web `--primary` / shadcn primary
  static const Color primary = Color(0xFF1D4ED8);

  // Light
  static const Color lightBackground = Color(0xFFF8FAFC);
  static const Color lightForeground = Color(0xFF0A0A0A);
  static const Color lightCard = Color(0xFFFFFFFF);
  static const Color lightMuted = Color(0xFFECECF0);
  static const Color lightMutedFg = Color(0xFF717182);
  static const Color lightBorder = Color(0x1A000000);

  /// `html.dark body` + web app shell (indigo gece).
  static const Color darkBackground = Color(0xFF1E1B4B);
  static const Color darkForeground = Color(0xFFF4F4F8);

  /// Kart / yüzey — web `card` üzerinde hafif yükselti.
  static const Color darkCard = Color(0xFF25204A);
  static const Color darkMuted = Color(0xFF2F2A5C);
  static const Color darkMutedFg = Color(0xFF9CA3BC);
  static const Color darkBorder = Color(0xFF3D3668);

  /// Alt nav seçili kapsül (koyu mavi).
  static const Color navIndicator = Color(0xFF252E52);
  static const Color navInactiveIcon = Color(0xFF8B90A8);
  static const Color navInactiveLabel = Color(0xFF9CA3BC);

  /// Profil avatar (mor).
  static const Color avatarPurple = Color(0xFF7C3AED);

  /// Saat dengesi — cyan ağırlıklı.
  static const List<Color> statGradient1 = [
    Color(0xFF2563EB),
    Color(0xFF22D3EE),
  ];

  /// Yetenek sayısı — pembe → mor.
  static const List<Color> statGradient2 = [
    Color(0xFFEC4899),
    Color(0xFFA855F7),
  ];
  static const List<Color> statGradient3 = [
    Color(0xFFF97316),
    Color(0xFFEF4444),
  ];
  static const List<Color> statGradient4 = [
    Color(0xFF22C55E),
    Color(0xFF10B981),
  ];

  /// Web `from-blue-500 to-purple-600` (hero / CTA / app bar şeritleri).
  static const List<Color> heroGradient = [
    Color(0xFF3B82F6),
    Color(0xFF9333EA),
  ];
}
