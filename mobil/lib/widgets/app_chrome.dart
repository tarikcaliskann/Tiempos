import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../theme/app_colors.dart';
import '../theme/app_surfaces.dart';

/// Web’deki primary mavi gradient ve tipografi ile hizalı ortak üst çubuk / şerit.
abstract final class AppChrome {
  /// Gradient başlık metni — ana sayfa arama / liste kolonu ile aynı yatay hizalama.
  static const double heroHeaderPaddingH = 20;

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
    assert(
      title != null || titleWidget != null,
      'title or titleWidget required',
    );
    final Widget t =
        titleWidget ??
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
      shadowColor: Colors.transparent,
      // M3 varsayılan opak `surface` gradient’i kapatabilir — şeffaf bırak.
      backgroundColor: Colors.transparent,
      foregroundColor: Colors.white,
      iconTheme: const IconThemeData(color: Colors.white),
      leading: leading,
      automaticallyImplyLeading: automaticallyImplyLeading,
      centerTitle: true,
      titleSpacing: 0,
      flexibleSpace: Stack(
        fit: StackFit.expand,
        children: [
          Container(
            decoration: const BoxDecoration(gradient: heroGradientLinear),
          ),
        ],
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
    Widget? leading,
    Widget? trailing,
  }) {
    final top = MediaQuery.paddingOf(context).top;
    final hasLeading = leading != null;
    final hasTrailing = trailing != null;

    /// Dikeyde ortalanmış şerit; başlık metni solda hizalı.
    const minStripHeight = 100.0;

    return SliverToBoxAdapter(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final narrow = constraints.maxWidth < 380;
          final padH = narrow ? 14.0 : heroHeaderPaddingH;
          return DecoratedBox(
            decoration: const BoxDecoration(gradient: heroGradientLinear),
            child: Padding(
              padding: EdgeInsets.fromLTRB(
                padH,
                top + 14,
                padH,
                14,
              ),
              child: ConstrainedBox(
                constraints: const BoxConstraints(minHeight: minStripHeight),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    if (hasLeading)
                      SizedBox(
                        width: 48,
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: leading,
                        ),
                      ),
                    Expanded(
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Padding(
                          padding: EdgeInsets.only(right: hasTrailing ? 6 : 0),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                title,
                                textAlign: TextAlign.start,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.inter(
                                  fontWeight: FontWeight.w800,
                                  fontSize: narrow ? 21 : 24,
                                  color: Colors.white,
                                  height: 1.15,
                                  letterSpacing: -0.5,
                                ),
                              ),
                              if (subtitle != null && subtitle.isNotEmpty) ...[
                                const SizedBox(height: 8),
                                Text(
                                  subtitle,
                                  textAlign: TextAlign.start,
                                  maxLines: narrow ? 3 : 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: GoogleFonts.inter(
                                    fontSize: narrow ? 12.5 : 13,
                                    height: 1.45,
                                    color: Colors.white.withValues(alpha: 0.9),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                    ),
                    if (hasTrailing)
                      Flexible(
                        fit: FlexFit.loose,
                        child: Align(
                          alignment: Alignment.centerRight,
                          child: trailing,
                        ),
                      ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  /// Üye avatarı — web hero ile aynı primary mavi gradient halka.
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
  ///
  /// Scaffold gövdesinde gevşek yükseklik varken yalnızca [DecoratedBox] kullanılırsa
  /// gradient içerik kadar uzar; alt kısım tema rengine (genelde siyah) kalır.
  /// [LayoutBuilder] + [SizedBox.expand] ile gradient her zaman kalan alanı doldurur.
  static Widget authScreenBackdrop({required Widget child}) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final bounded =
            constraints.hasBoundedWidth && constraints.hasBoundedHeight;
        return DecoratedBox(
          decoration: const BoxDecoration(
            gradient: AppSurfaces.brandPrimaryBlue,
          ),
          child: bounded ? SizedBox.expand(child: child) : child,
        );
      },
    );
  }

  /// Login ekranındaki gibi: üst köşeleri yuvarlatılmış, gradient altında tam genişlik form alanı.
  ///
  /// [Column] / [Expanded] içinde `Expanded(child: authFormSheetPanel(...))` olarak kullanın.
  static Widget authFormSheetPanel({
    required ThemeData theme,
    required Widget child,
    EdgeInsets scrollPadding = const EdgeInsets.fromLTRB(22, 26, 22, 32),
    double maxContentWidth = 420,
  }) {
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      child: Material(
        color: theme.brightness == Brightness.dark
            ? AppColors.darkCard
            : AppColors.lightCard,
        elevation: 0,
        shadowColor: Colors.transparent,
        child: DecoratedBox(
          decoration: BoxDecoration(
            border: Border(
              top: BorderSide(
                color: theme.brightness == Brightness.dark
                    ? Colors.white.withValues(alpha: 0.1)
                    : AppColors.lightBorder.withValues(alpha: 0.85),
              ),
            ),
            boxShadow: theme.brightness == Brightness.light
                ? [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.06),
                      blurRadius: 24,
                      offset: const Offset(0, -8),
                    ),
                  ]
                : null,
          ),
          child: SafeArea(
            top: false,
            child: Align(
              alignment: Alignment.topCenter,
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: maxContentWidth),
                child: SingleChildScrollView(
                  padding: scrollPadding,
                  child: child,
                ),
              ),
            ),
          ),
        ),
      ),
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
      prefixIcon: Icon(
        Icons.search_rounded,
        color: cs.primary.withValues(alpha: 0.85),
      ),
      filled: true,
      fillColor: isDark
          ? AppColors.darkCard.withValues(alpha: 0.92)
          : AppColors.lightCard,
      contentPadding: const EdgeInsets.symmetric(horizontal: 4, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.35)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(
          color: isDark
              ? AppColors.darkBorder
              : cs.outline.withValues(alpha: 0.25),
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: cs.primary, width: 2),
      ),
    );
  }
}
