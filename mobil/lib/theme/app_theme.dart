import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';

abstract final class AppTheme {
  static TextTheme _interTextTheme(TextTheme base) {
    return GoogleFonts.interTextTheme(base);
  }

  static ThemeData light() {
    final base = ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: ColorScheme.light(
        surface: AppColors.lightBackground,
        onSurface: AppColors.lightForeground,
        primary: AppColors.primary,
        onPrimary: Colors.white,
        secondary: AppColors.lightMuted,
        onSecondary: AppColors.lightForeground,
        outline: AppColors.lightBorder,
      ),
    );
    return base.copyWith(
      textTheme: _interTextTheme(base.textTheme),
      scaffoldBackgroundColor: AppColors.lightBackground,
      inputDecorationTheme: _inputDecorationLight(),
      chipTheme: _chipThemeLight(),
      segmentedButtonTheme: _segmentedLight(),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        ),
      ),
      cardTheme: CardThemeData(
        color: AppColors.lightCard,
        elevation: 4,
        shadowColor: Colors.black.withValues(alpha: 0.06),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      navigationBarTheme: _navBarThemeLight(),
    );
  }

  static ThemeData dark() {
    final colorScheme = ColorScheme.dark(
      surface: AppColors.darkBackground,
      onSurface: AppColors.darkForeground,
      primary: AppColors.primary,
      onPrimary: Colors.white,
      surfaceContainerHighest: AppColors.darkCard,
      secondary: AppColors.darkMuted,
      onSecondary: AppColors.darkForeground,
      outline: AppColors.darkBorder,
    );
    final base = ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: colorScheme,
    );
    final textTheme = _interTextTheme(base.textTheme);
    return base.copyWith(
      textTheme: textTheme,
      scaffoldBackgroundColor: AppColors.darkBackground,
      inputDecorationTheme: _inputDecorationDark(),
      chipTheme: _chipThemeDark(),
      segmentedButtonTheme: _segmentedDark(),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        ),
      ),
      cardTheme: CardThemeData(
        color: AppColors.darkCard,
        elevation: 0,
        margin: EdgeInsets.zero,
        shadowColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: Colors.white.withValues(alpha: 0.06),
          ),
        ),
      ),
      navigationBarTheme: _navBarThemeDark(),
    );
  }

  static InputDecorationTheme _inputDecorationLight() {
    return InputDecorationTheme(
      filled: true,
      fillColor: AppColors.lightMuted.withValues(alpha: 0.55),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: AppColors.lightBorder.withValues(alpha: 0.35)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.primary, width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
    );
  }

  static InputDecorationTheme _inputDecorationDark() {
    return InputDecorationTheme(
      filled: true,
      fillColor: AppColors.darkMuted.withValues(alpha: 0.65),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: AppColors.darkBorder.withValues(alpha: 0.9)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.primary, width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
    );
  }

  static ChipThemeData _chipThemeLight() {
    return ChipThemeData(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      side: BorderSide(color: AppColors.primary.withValues(alpha: 0.22)),
      labelStyle: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
    );
  }

  static ChipThemeData _chipThemeDark() {
    return ChipThemeData(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      side: BorderSide(color: Colors.white.withValues(alpha: 0.12)),
      backgroundColor: AppColors.darkMuted.withValues(alpha: 0.5),
      labelStyle: GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: AppColors.darkForeground,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
    );
  }

  static SegmentedButtonThemeData _segmentedLight() {
    return SegmentedButtonThemeData(
      style: ButtonStyle(
        side: WidgetStateProperty.all(BorderSide(color: AppColors.lightBorder.withValues(alpha: 0.4))),
        shape: WidgetStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
      ),
    );
  }

  static SegmentedButtonThemeData _segmentedDark() {
    return SegmentedButtonThemeData(
      style: ButtonStyle(
        side: WidgetStateProperty.all(BorderSide(color: AppColors.darkBorder)),
        shape: WidgetStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
      ),
    );
  }

  static NavigationBarThemeData _navBarThemeLight() {
    return NavigationBarThemeData(
      backgroundColor: AppColors.lightCard,
      elevation: 8,
      shadowColor: Colors.black.withValues(alpha: 0.08),
      indicatorColor: AppColors.primary.withValues(alpha: 0.14),
      height: 72,
      labelTextStyle: WidgetStateProperty.resolveWith((states) {
        final selected = states.contains(WidgetState.selected);
        return GoogleFonts.inter(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: selected ? AppColors.lightForeground : AppColors.lightMutedFg,
        );
      }),
      iconTheme: WidgetStateProperty.resolveWith((states) {
        final selected = states.contains(WidgetState.selected);
        return IconThemeData(
          color: selected ? AppColors.primary : AppColors.lightMutedFg,
          size: 24,
        );
      }),
    );
  }

  static NavigationBarThemeData _navBarThemeDark() {
    return NavigationBarThemeData(
      backgroundColor: AppColors.darkBackground,
      elevation: 0,
      surfaceTintColor: Colors.transparent,
      shadowColor: Colors.transparent,
      indicatorColor: AppColors.navIndicator,
      height: 72,
      labelTextStyle: WidgetStateProperty.resolveWith((states) {
        final selected = states.contains(WidgetState.selected);
        return GoogleFonts.inter(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: selected ? Colors.white : AppColors.navInactiveLabel,
        );
      }),
      iconTheme: WidgetStateProperty.resolveWith((states) {
        final selected = states.contains(WidgetState.selected);
        return IconThemeData(
          color: selected ? Colors.white : AppColors.navInactiveIcon,
          size: 24,
        );
      }),
    );
  }
}
