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
