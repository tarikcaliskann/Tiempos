import 'package:flutter/material.dart';

/// Web `index.css` — `:root` / `.dark` ve Tailwind `--color-*` ile aynı hex’ler.
abstract final class AppColors {
  /// Web `--primary` / shadcn
  static const Color primary = Color(0xFF1D4ED8);

  // Light — web :root / slate shell
  static const Color lightBackground = Color(0xFFF1F5F9);
  static const Color lightForeground = Color(0xFF0F172A);
  static const Color lightCard = Color(0xFFFFFFFF);
  static const Color lightMuted = Color(0xFFE2E8F0);
  static const Color lightMutedFg = Color(0xFF64748B);
  static const Color lightBorder = Color(0xFFCBD5E1);

  /// Web `.dark` — düşük kromalı lacivert-gri (mobildeki yoğun mor yerine).
  static const Color darkBackground = Color(0xFF13131F);
  static const Color darkForeground = Color(0xFFF4F4F8);
  static const Color darkCard = Color(0xFF1F1F2E);
  static const Color darkMuted = Color(0xFF262635);
  static const Color darkMutedFg = Color(0xFFA4A4B8);
  static const Color darkBorder = Color(0xFF3A3A4D);

  /// Alt nav seçili kapsül — web `secondary` koyu tonu ile uyumlu.
  static const Color navIndicator = Color(0xFF252532);
  static const Color navInactiveIcon = Color(0xFF8B8B9E);
  static const Color navInactiveLabel = Color(0xFFA4A4B8);

  /// Web hero / butonlardaki `from-blue-500 to-purple-600` (Tailwind map: #1D4ED8 → #1D4ED8);
  /// hafif derinlik için sağ uç `blue-600` (#1E40AF).
  static const Color avatarInitials = Color(0xFF1D4ED8);

  /// Web dashboard stat: `from-blue-500 to-cyan-500`
  static const List<Color> statGradient1 = [
    Color(0xFF1D4ED8),
    Color(0xFF06B6D4),
  ];

  /// Web: `from-purple-500 to-pink-500` → `--color-purple-500` #3B82F6, pembe uç yaklaşık pink-500.
  static const List<Color> statGradient2 = [
    Color(0xFF3B82F6),
    Color(0xFFEC4899),
  ];

  /// Web: `from-orange-500 to-red-500`
  static const List<Color> statGradient3 = [
    Color(0xFFF97316),
    Color(0xFFEF4444),
  ];

  /// Web: `from-green-500 to-emerald-500`
  static const List<Color> statGradient4 = [
    Color(0xFF22C55E),
    Color(0xFF10B981),
  ];

  /// Web `bg-gradient-to-r from-blue-500 to-purple-600` (strip / app bar) — Tailwind map.
  static const List<Color> heroGradient = [
    Color(0xFF1D4ED8),
    Color(0xFF1E40AF),
  ];
}
