import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import '../api/user_api.dart';
import '../app/app_state.dart';
import '../language/profile_l10n.dart';
import '../theme/app_colors.dart';
import '../widgets/app_chrome.dart';

class PublicProfileScreen extends StatefulWidget {
  const PublicProfileScreen({
    super.key,
    required this.appState,
    required this.userId,
  });

  final AppState appState;
  final String userId;

  @override
  State<PublicProfileScreen> createState() => _PublicProfileScreenState();
}

class _PublicProfileScreenState extends State<PublicProfileScreen> {
  PublicUserProfileDto? _profile;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final t = widget.appState.token;
    if (t == null || t.isEmpty) {
      if (!mounted) return;
      final pl = ProfileL10n.of(context);
      setState(() {
        _loading = false;
        _error = pl.publicNotSignedIn;
      });
      return;
    }
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final p = await fetchPublicUserProfile(token: t, userId: widget.userId);
      if (!mounted) return;
      setState(() {
        _profile = p;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = '$e';
        _loading = false;
      });
    }
  }

  String _memberSinceLine(String raw) {
    final dt = DateTime.tryParse(raw)?.toLocal();
    if (dt == null) return raw;
    return DateFormat.yMMMMd().format(dt);
  }

  Future<void> _openExternal(String? raw) async {
    final v = raw?.trim();
    if (v == null || v.isEmpty) return;
    final uri = v.startsWith('http://') || v.startsWith('https://')
        ? Uri.tryParse(v)
        : Uri.tryParse('https://$v');
    if (uri == null) return;
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    } catch (_) {}
  }

  Widget _avatarInner(ThemeData theme, PublicUserProfileDto p) {
    final url = p.avatarUrl?.trim();
    if (url != null && url.isNotEmpty) {
      if (url.startsWith('data:')) {
        final comma = url.indexOf(',');
        if (comma > 0) {
          try {
            final bytes = base64Decode(url.substring(comma + 1));
            return Image.memory(
              bytes,
              fit: BoxFit.cover,
              gaplessPlayback: true,
              errorBuilder: (context, error, stackTrace) => _initialsAvatar(theme, p),
            );
          } catch (_) {}
        }
      } else {
        return Image.network(
          url,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => _initialsAvatar(theme, p),
        );
      }
    }
    return _initialsAvatar(theme, p);
  }

  Widget _initialsAvatar(ThemeData theme, PublicUserProfileDto p) {
    final n = p.fullName.trim();
    final letter = n.isEmpty ? '?' : n[0].toUpperCase();
    return ColoredBox(
      color: theme.colorScheme.primary.withValues(alpha: 0.22),
      child: Center(
        child: Text(
          letter,
          style: GoogleFonts.inter(
            fontSize: 36,
            fontWeight: FontWeight.w800,
            color: theme.colorScheme.primary,
          ),
        ),
      ),
    );
  }

  Widget _avatarWithRing(ThemeData theme, PublicUserProfileDto p) {
    return AppChrome.profileAvatarRing(
      theme: theme,
      diameter: 96,
      child: _avatarInner(theme, p),
    );
  }

  Widget _sectionLabel(ThemeData theme, String text) {
    return Text(
      text,
      style: GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w800,
        letterSpacing: 0.6,
        color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
      ),
    );
  }

  Widget _surfaceCard(ThemeData theme, {required Widget child}) {
    final isDark = theme.brightness == Brightness.dark;
    return Material(
      color: isDark ? AppColors.darkCard : AppColors.lightCard,
      elevation: 0,
      shadowColor: Colors.black.withValues(alpha: 0.08),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: theme.colorScheme.outline.withValues(alpha: isDark ? 0.35 : 0.18),
        ),
      ),
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final pl = ProfileL10n.of(context);

    return Scaffold(
      appBar: AppChrome.gradientAppBar(title: pl.publicMemberTitle),
      body: _loading
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 36,
                    height: 36,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    pl.publicProfileLoading,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.55),
                    ),
                  ),
                ],
              ),
            )
          : _error != null
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: _surfaceCard(
                  theme,
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.error_outline_rounded,
                          size: 40,
                          color: theme.colorScheme.error.withValues(alpha: 0.85),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          _error!,
                          textAlign: TextAlign.center,
                          style: GoogleFonts.inter(
                            fontSize: 15,
                            height: 1.45,
                            color: theme.colorScheme.onSurface.withValues(alpha: 0.85),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            )
          : _profile == null
          ? const SizedBox.shrink()
          : RefreshIndicator(
              onRefresh: _load,
              child: CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(
                  parent: BouncingScrollPhysics(),
                ),
                slivers: [
                  SliverToBoxAdapter(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                AppColors.heroGradient[0].withValues(alpha: isDark ? 0.42 : 0.28),
                                AppColors.heroGradient[1].withValues(alpha: isDark ? 0.32 : 0.2),
                                theme.scaffoldBackgroundColor,
                              ],
                              stops: const [0.0, 0.42, 1.0],
                            ),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(24, 12, 24, 36),
                            child: Column(
                              children: [
                                _avatarWithRing(theme, _profile!),
                                const SizedBox(height: 16),
                                Text(
                                  _profile!.fullName,
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.inter(
                                    fontSize: 24,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: -0.4,
                                    color: Colors.white,
                                    height: 1.2,
                                  ),
                                ),
                                if (_profile!.location != null &&
                                    _profile!.location!.trim().isNotEmpty) ...[
                                  const SizedBox(height: 10),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.place_outlined,
                                        size: 18,
                                        color: Colors.white.withValues(alpha: 0.88),
                                      ),
                                      const SizedBox(width: 6),
                                      Flexible(
                                        child: Text(
                                          _profile!.location!.trim(),
                                          textAlign: TextAlign.center,
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                          style: GoogleFonts.inter(
                                            fontSize: 14,
                                            height: 1.35,
                                            color: Colors.white.withValues(alpha: 0.9),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ),
                        Transform.translate(
                          offset: const Offset(0, -20),
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
                            child: _surfaceCard(
                              theme,
                              child: Padding(
                                padding: const EdgeInsets.fromLTRB(18, 16, 18, 16),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Icon(
                                      Icons.star_rounded,
                                      color: Colors.amber.shade700,
                                      size: 32,
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            _profile!.averageRating.toStringAsFixed(1),
                                            style: GoogleFonts.inter(
                                              fontSize: 26,
                                              fontWeight: FontWeight.w800,
                                              height: 1.1,
                                              color: theme.colorScheme.onSurface,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            pl.reviewsCount(_profile!.totalReviews),
                                            style: GoogleFonts.inter(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w500,
                                              color: theme.colorScheme.onSurface.withValues(alpha: 0.55),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              if (_profile!.bio != null && _profile!.bio!.trim().isNotEmpty) ...[
                                _sectionLabel(theme, pl.sectionAbout),
                                const SizedBox(height: 8),
                                _surfaceCard(
                                  theme,
                                  child: Padding(
                                    padding: const EdgeInsets.fromLTRB(18, 16, 18, 18),
                                    child: Text(
                                      _profile!.bio!.trim(),
                                      style: GoogleFonts.inter(
                                        fontSize: 15,
                                        height: 1.55,
                                        color: theme.colorScheme.onSurface.withValues(alpha: 0.88),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 20),
                              ],
                              _sectionLabel(theme, pl.sectionDetails),
                              const SizedBox(height: 8),
                              _surfaceCard(
                                theme,
                                child: Column(
                                  children: [
                                    ListTile(
                                      contentPadding: const EdgeInsets.symmetric(horizontal: 18),
                                      leading: Icon(
                                        Icons.calendar_today_outlined,
                                        color: theme.colorScheme.primary.withValues(alpha: 0.9),
                                      ),
                                      title: Text(
                                        pl.memberSinceLabel,
                                        style: GoogleFonts.inter(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                          color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                                        ),
                                      ),
                                      subtitle: Text(
                                        _profile!.memberSince.trim().isEmpty
                                            ? '—'
                                            : _memberSinceLine(_profile!.memberSince),
                                        style: GoogleFonts.inter(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w600,
                                          color: theme.colorScheme.onSurface,
                                        ),
                                      ),
                                    ),
                                    if (_profile!.languages != null &&
                                        _profile!.languages!.trim().isNotEmpty) ...[
                                      Divider(
                                        height: 1,
                                        indent: 18,
                                        endIndent: 18,
                                        color: theme.colorScheme.outline.withValues(alpha: 0.2),
                                      ),
                                      ListTile(
                                        contentPadding: const EdgeInsets.symmetric(horizontal: 18),
                                        leading: Icon(
                                          Icons.language_rounded,
                                          color: theme.colorScheme.primary.withValues(alpha: 0.9),
                                        ),
                                        title: Text(
                                          pl.languagesLabel,
                                          style: GoogleFonts.inter(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600,
                                            color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                                          ),
                                        ),
                                        subtitle: Text(
                                          _profile!.languages!.trim(),
                                          style: GoogleFonts.inter(
                                            fontSize: 15,
                                            fontWeight: FontWeight.w500,
                                            color: theme.colorScheme.onSurface,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                              if (_hasAnyLink(_profile!)) ...[
                                const SizedBox(height: 20),
                                _sectionLabel(theme, pl.sectionLinks),
                                const SizedBox(height: 8),
                                _surfaceCard(
                                  theme,
                                  child: Column(
                                    children: [
                                      if (_profile!.website != null &&
                                          _profile!.website!.trim().isNotEmpty)
                                        ListTile(
                                          contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                                          leading: const Icon(Icons.link_rounded),
                                          title: Text(
                                            pl.websiteLink,
                                            style: GoogleFonts.inter(fontWeight: FontWeight.w600),
                                          ),
                                          subtitle: Text(
                                            _profile!.website!.trim(),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: GoogleFonts.inter(fontSize: 13),
                                          ),
                                          trailing: const Icon(Icons.open_in_new_rounded, size: 18),
                                          onTap: () => _openExternal(_profile!.website),
                                        ),
                                      if (_profile!.linkedin != null &&
                                          _profile!.linkedin!.trim().isNotEmpty) ...[
                                        if (_profile!.website != null &&
                                            _profile!.website!.trim().isNotEmpty)
                                          Divider(
                                            height: 1,
                                            indent: 18,
                                            endIndent: 18,
                                            color: theme.colorScheme.outline.withValues(alpha: 0.2),
                                          ),
                                        ListTile(
                                          contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                                          leading: const Icon(Icons.work_outline_rounded),
                                          title: Text(
                                            pl.linkedInLink,
                                            style: GoogleFonts.inter(fontWeight: FontWeight.w600),
                                          ),
                                          subtitle: Text(
                                            _profile!.linkedin!.trim(),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: GoogleFonts.inter(fontSize: 13),
                                          ),
                                          trailing: const Icon(Icons.open_in_new_rounded, size: 18),
                                          onTap: () => _openExternal(_profile!.linkedin),
                                        ),
                                      ],
                                      if (_profile!.twitter != null &&
                                          _profile!.twitter!.trim().isNotEmpty) ...[
                                        if ((_profile!.website != null &&
                                                _profile!.website!.trim().isNotEmpty) ||
                                            (_profile!.linkedin != null &&
                                                _profile!.linkedin!.trim().isNotEmpty))
                                          Divider(
                                            height: 1,
                                            indent: 18,
                                            endIndent: 18,
                                            color: theme.colorScheme.outline.withValues(alpha: 0.2),
                                          ),
                                        ListTile(
                                          contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                                          leading: const Icon(Icons.tag_rounded),
                                          title: Text(
                                            pl.xTwitterLink,
                                            style: GoogleFonts.inter(fontWeight: FontWeight.w600),
                                          ),
                                          subtitle: Text(
                                            _profile!.twitter!.trim(),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: GoogleFonts.inter(fontSize: 13),
                                          ),
                                          trailing: const Icon(Icons.open_in_new_rounded, size: 18),
                                          onTap: () => _openExternal(_profile!.twitter),
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                              ],
                              const SizedBox(height: 32),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  bool _hasAnyLink(PublicUserProfileDto p) {
    final w = p.website?.trim() ?? '';
    final l = p.linkedin?.trim() ?? '';
    final t = p.twitter?.trim() ?? '';
    return w.isNotEmpty || l.isNotEmpty || t.isNotEmpty;
  }
}
