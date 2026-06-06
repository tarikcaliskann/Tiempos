import 'package:flutter/material.dart';

abstract final class AppSurfaces {
  /// Web auth / marka şeridi: yalnızca primary mavi (`#1D4ED8` → `#1E3A8A`).
  static const LinearGradient brandPrimaryBlue = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF1D4ED8),
      Color(0xFF1E3A8A),
    ],
  );

  /// Koyu mod gövde — web `.dark` `--background` civarı, hafif dikey derinlik.
  static const LinearGradient darkScaffoldDepth = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0xFF181824),
      Color(0xFF13131F),
      Color(0xFF0E0E14),
    ],
    stops: [0.0, 0.45, 1.0],
  );
}
