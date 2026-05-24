import 'package:flutter/material.dart';

/// Web + mobil dashboard referansı (koyu lacivert zemin, mavi–mor vurgular).
abstract final class AppColors {
  static const Color primary = Color(0xFF1D4ED8);

  // Light
  static const Color lightBackground = Color(0xFFFFFFFF);
  static const Color lightForeground = Color(0xFF0A0A0A);
  static const Color lightCard = Color(0xFFFFFFFF);
  static const Color lightMuted = Color(0xFFECECF0);
  static const Color lightMutedFg = Color(0xFF717182);
  static const Color lightBorder = Color(0x1A000000);

  /// Ana scaffold — ekran görüntüsüne yakın koyu lacivert.
  static const Color darkBackground = Color(0xFF1A1C2C);
  static const Color darkForeground = Color(0xFFF4F4F8);

  /// Kartlar zeminden hafif açık.
  static const Color darkCard = Color(0xFF242838);
  static const Color darkMuted = Color(0xFF2E3148);
  static const Color darkMutedFg = Color(0xFF9CA3BC);
  static const Color darkBorder = Color(0xFF383C52);

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

  static const List<Color> heroGradient = [
    Color(0xFF2563EB),
    Color(0xFF6D28D9),
  ];
}
