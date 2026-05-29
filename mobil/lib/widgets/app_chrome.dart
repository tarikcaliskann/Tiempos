import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../theme/app_colors.dart';
import '../theme/app_surfaces.dart';

/// Web’deki mavi–mor gradient ve tipografi ile hizalı ortak üst çubuk / şerit.
abstract final class AppChrome {
  static const LinearGradient heroGradientLinear = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: AppColors.heroGradient,
  );

  static TextStyle _titleStyle() => GoogleFonts.inter(
        fontWeight: FontWeight.w800,
        fontSize: 18,
        letterSpacing: -0.3,
        color: Colors.white,
      );

  /// `Scaffold.appBar` için — geri düğmesi ve aksiyonlar beyaz ikon kullanır.
  static PreferredSizeWidget gradientAppBar({
    String? title,
    Widget? titleWidget,
    List<Widget>? actions,
    Widget? leading,
    bool automaticallyImplyLeading = true,
  }) {
    assert(title != null || titleWidget != null, 'title or titleWidget required');
    final Widget t = titleWidget ??
        Text(
          title!,
          style: _titleStyle(),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        );
    return AppBar(
      elevation: 0,
      scrolledUnderElevation: 0,
      surfaceTintColor: Colors.transparent,
      backgroundColor: Colors.transparent,
      foregroundColor: Colors.white,
      iconTheme: const IconThemeData(color: Colors.white),
      leading: leading,
      automaticallyImplyLeading: automaticallyImplyLeading,
      flexibleSpace: const DecoratedBox(
        decoration: BoxDecoration(gradient: heroGradientLinear),
      ),
      title: titleWidget != null
          ? t
          : DefaultTextStyle(
              style: _titleStyle(),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              child: t,
            ),
      actions: actions,
    );
  }

  /// Ana sekmeler (Browse, Messages, Profile) — üst güvenli alan + gradient şerit.
  static Widget gradientSliverHeader({
    required BuildContext context,
    required String title,
    String? subtitle,
    Widget? trailing,
  }) {
    final top = MediaQuery.paddingOf(context).top;
    return SliverToBoxAdapter(
      child: DecoratedBox(
        decoration: const BoxDecoration(gradient: heroGradientLinear),
        child: Padding(
          padding: EdgeInsets.fromLTRB(20, top + 14, 20, 30),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.inter(
                        fontWeight: FontWeight.w800,
                        fontSize: 26,
                        color: Colors.white,
                        height: 1.15,
                        letterSpacing: -0.6,
                      ),
                    ),
                    if (subtitle != null && subtitle.isNotEmpty) ...[
                      const SizedBox(height: 10),
                      Text(
                        subtitle,
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          height: 1.5,
                          color: Colors.white.withValues(alpha: 0.9),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              ?trailing,
            ],
          ),
        ),
      ),
    );
  }

  /// Üye avatarı — web hero ile aynı mavi–mor gradient halka.
  static Widget profileAvatarRing({
    required ThemeData theme,
    required double diameter,
    required Widget child,
  }) {
    return Container(
      padding: const EdgeInsets.all(3),
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        gradient: heroGradientLinear,
      ),
      child: Container(
        padding: const EdgeInsets.all(3),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: theme.scaffoldBackgroundColor,
        ),
        child: ClipOval(
          child: SizedBox(width: diameter, height: diameter, child: child),
        ),
      ),
    );
  }

  /// Giriş / kayıt gövdesi — web `tiempos-auth-shell` tam ekran gradient.
  static Widget authScreenBackdrop({required Widget child}) {
    return DecoratedBox(
      decoration: const BoxDecoration(gradient: AppSurfaces.brandBluePurple),
      child: child,
    );
  }

  /// Web’deki `rounded-3xl` kart + ince border + gölge.
  static Widget webStyleAuthCard({
    required ThemeData theme,
    required Widget child,
  }) {
    final isDark = theme.brightness == Brightness.dark;
    return Material(
      color: theme.colorScheme.surface,
      elevation: isDark ? 18 : 12,
      shadowColor: Colors.black.withValues(alpha: 0.38),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: BorderSide(
          color: isDark
              ? Colors.white.withValues(alpha: 0.12)
              : theme.colorScheme.outline.withValues(alpha: 0.14),
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: child,
    );
  }

  /// Browse / liste kartları — web `rounded-2xl` + ince border + hafif gölge.
  static Widget webStyleSurfaceCard({
    required ThemeData theme,
    required Widget child,
    double borderRadius = 20,
  }) {
    final isDark = theme.brightness == Brightness.dark;
    return Material(
      color: theme.colorScheme.surface,
      elevation: isDark ? 14 : 8,
      shadowColor: Colors.black.withValues(alpha: 0.22),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(borderRadius),
        side: BorderSide(
          color: isDark
              ? Colors.white.withValues(alpha: 0.10)
              : theme.colorScheme.outline.withValues(alpha: 0.12),
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: child,
    );
  }

  /// Arama alanları — web’deki dolu, yuvarlak köşeli input’a yakın.
  static InputDecoration searchDecoration(
    BuildContext context, {
    required String hintText,
  }) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return InputDecoration(
      hintText: hintText,
      prefixIcon: Icon(Icons.search_rounded, color: cs.primary.withValues(alpha: 0.85)),
      filled: true,
      fillColor: isDark ? AppColors.darkCard.withValues(alpha: 0.92) : Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 4, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.35)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(
          color: isDark ? AppColors.darkBorder : cs.outline.withValues(alpha: 0.25),
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: cs.primary, width: 2),
      ),
    );
  }
}
