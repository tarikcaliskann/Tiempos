import 'package:flutter/material.dart';

/// Web `tiempos-auth-shell` / browse bandı ile aynı mavi–mor dil.
abstract final class AppSurfaces {
  /// `bg-gradient-to-br from-blue-500 to-purple-600`
  static const LinearGradient brandBluePurple = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF3B82F6),
      Color(0xFF9333EA),
    ],
  );

  /// Koyu mod ana zemin üstünden alta hafif derinlik (web `html.dark body` + indigo).
  static const LinearGradient darkScaffoldDepth = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0xFF22205A),
      Color(0xFF1E1B4B),
      Color(0xFF17132E),
    ],
    stops: [0.0, 0.45, 1.0],
  );
}
