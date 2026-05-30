import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../api/api_exception.dart';
import '../api/exchange_api.dart';
import '../api/reviews_api.dart';
import '../api/skills_api.dart';
import '../api/user_api.dart';
import '../app/app_state.dart';
import '../config/app_web_config.dart';
import '../language/profile_l10n.dart';
import '../util/formatting.dart';
import '../util/skill_profile_card_display.dart';
import '../widgets/app_chrome.dart';
import 'add_skill_screen.dart';
import 'edit_profile_screen.dart';
import 'public_profile_screen.dart';
import 'settings_screen.dart';
import 'skill_detail_screen.dart';

Widget _profileTabSegmentLabel(String text) {
  return FittedBox(
    fit: BoxFit.scaleDown,
    alignment: Alignment.center,
    child: Text(
      text,
      maxLines: 1,
      textAlign: TextAlign.center,
      style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600),
    ),
  );
}

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({
    super.key,
    required this.appState,
    this.onOpenMessages,
  });

  final AppState appState;
  /// Web profil “Continue learning” → Mesajlar sekmesi.
  final VoidCallback? onOpenMessages;

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  /// Web `addSkill.days` (en) — `getSkillAvailabilityParts` ile uyumlu.
  static const _profileDayLabels = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday',
  ];

  UserProfileDto? _profile;
  List<SkillDto> _skills = [];
  bool _loading = true;
  List<ReviewDto> _receivedReviews = [];
  List<ReviewDto> _givenReviews = [];
  UserRatingSummaryDto? _summaryReceived;
  UserRatingSummaryDto? _summaryGiven;
  String? _error;
  List<ExchangeRequestDto> _receivedBookings = [];
  List<ExchangeRequestDto> _sentBookings = [];
  List<String> _hiddenLearningIds = [];
  /// 0 Teaching, 1 Learning, 2 Reviews — web `ProfilePage` `mainTab`.
  int _mainTab = 0;
  String? _shareFeedback;
  Timer? _shareFeedbackTimer;

  @override
  void initState() {
    super.initState();
    widget.appState.addListener(_onAuth);
    _loadHiddenLearningIds();
    _load();
  }

  @override
  void dispose() {
    _shareFeedbackTimer?.cancel();
    widget.appState.removeListener(_onAuth);
    super.dispose();
  }

  void _onAuth() {
    if (widget.appState.token != null) {
      _loadHiddenLearningIds();
      _load();
    }
  }

  Future<void> _loadHiddenLearningIds() async {
    final uid = widget.appState.userId?.trim().toLowerCase();
    if (uid == null || uid.isEmpty) {
      if (mounted) setState(() => _hiddenLearningIds = []);
      return;
    }
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString('tiempos_hidden_learning:$uid');
    if (raw == null || raw.trim().isEmpty) {
      if (mounted) setState(() => _hiddenLearningIds = []);
      return;
    }
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! List) {
        if (mounted) setState(() => _hiddenLearningIds = []);
        return;
      }
      final ids = decoded.map((e) => '$e'.trim()).where((e) => e.isNotEmpty).toList();
      if (mounted) setState(() => _hiddenLearningIds = ids);
    } catch (_) {
      if (mounted) setState(() => _hiddenLearningIds = []);
    }
  }

  Future<void> _persistHiddenLearningIds() async {
    final uid = widget.appState.userId?.trim().toLowerCase();
    if (uid == null || uid.isEmpty) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('tiempos_hidden_learning:$uid', jsonEncode(_hiddenLearningIds));
  }

  Future<void> _load() async {
    final t = widget.appState.token;
    if (t == null) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final results = await Future.wait([
        fetchMyProfile(t),
        fetchMySkills(t),
        fetchReceivedExchangeRequests(t),
        fetchSentExchangeRequests(t),
      ]);
      final profile = results[0] as UserProfileDto;
      final skills = results[1] as List<SkillDto>;
      final receivedBookings = results[2] as List<ExchangeRequestDto>;
      final sentBookings = results[3] as List<ExchangeRequestDto>;
      var receivedReviews = <ReviewDto>[];
      UserRatingSummaryDto? summaryReceived;
      var givenReviews = <ReviewDto>[];
      UserRatingSummaryDto? summaryGiven;
      try {
        receivedReviews = await fetchMyReceivedReviews(t);
        summaryReceived = await fetchMyRatingSummary(t);
      } catch (_) {}
      try {
        givenReviews = await fetchMyGivenReviews(t);
        summaryGiven = await fetchMyGivenRatingSummary(t);
      } catch (_) {}
      if (!mounted) return;
      setState(() {
        _profile = profile;
        _skills = skills;
        _receivedBookings = receivedBookings;
        _sentBookings = sentBookings;
        _receivedReviews = receivedReviews;
        _summaryReceived = summaryReceived;
        _givenReviews = givenReviews;
        _summaryGiven = summaryGiven;
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

  /// Web `teachingBookingsBySkill`: ACCEPTED veya COMPLETED gelen talepler.
  Map<String, List<ExchangeRequestDto>> _teachingBookingsBySkill() {
    final map = <String, List<ExchangeRequestDto>>{};
    for (final b in _receivedBookings) {
      if (b.status != 'ACCEPTED' && b.status != 'COMPLETED') continue;
      map.putIfAbsent(b.skillId, () => []).add(b);
    }
    return map;
  }

  /// Web `learningBookings`: gönderilen ve COMPLETED, gizlenmemiş.
  List<ExchangeRequestDto> get _learningBookings {
    return _sentBookings
        .where(
          (b) => b.status == 'COMPLETED' && !_hiddenLearningIds.contains(b.id),
        )
        .toList();
  }

  Map<String, ReviewDto> _givenReviewByExchangeId() {
    final m = <String, ReviewDto>{};
    for (final r in _givenReviews) {
      m[r.exchangeRequestId] = r;
    }
    return m;
  }

  String _formatSessionTime(BuildContext context, String? iso) {
    if (iso == null || iso.trim().isEmpty) return '—';
    final dt = DateTime.tryParse(iso)?.toLocal();
    if (dt == null) return iso;
    final date = MaterialLocalizations.of(context).formatMediumDate(dt);
    final tod = TimeOfDay.fromDateTime(dt);
    final time = tod.format(context);
    return '$date $time';
  }

  Future<void> _hideLearningBooking(String bookingId) async {
    if (!mounted) return;
    setState(() {
      _hiddenLearningIds = {..._hiddenLearningIds, bookingId}.toList();
    });
    await _persistHiddenLearningIds();
  }

  Future<void> _openDeleteLearningDialog(ExchangeRequestDto booking, ProfileL10n l10n) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.deleteLearningTitle),
        content: Text(l10n.deleteLearningBody(booking.skillTitle)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(l10n.cancel)),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(l10n.yesDelete),
          ),
        ],
      ),
    );
    if (ok == true) await _hideLearningBooking(booking.id);
  }

  Future<void> _openReviewDialog(ExchangeRequestDto booking) async {
    final t = widget.appState.token;
    if (t == null) return;
    final l10n = ProfileL10n.of(context);
    var rating = 0;
    final commentCtrl = TextEditingController();
    String? err;
    var saving = false;

    final submitted = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setD) {
          return AlertDialog(
            title: Text(l10n.rateInstructorTitle),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    booking.skillTitle,
                    style: GoogleFonts.inter(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    booking.ownerName,
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      color: Theme.of(ctx).colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(5, (i) {
                      final v = i + 1;
                      return IconButton(
                        onPressed: saving ? null : () => setD(() => rating = v),
                        icon: Icon(
                          v <= rating ? Icons.star_rounded : Icons.star_border_rounded,
                          color: Colors.amber.shade700,
                          size: 36,
                        ),
                      );
                    }),
                  ),
                  if (rating < 1)
                    Text(
                      l10n.tapStarsHint,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Theme.of(ctx).colorScheme.onSurface.withValues(alpha: 0.55),
                        fontSize: 12,
                      ),
                    ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: commentCtrl,
                    maxLines: 3,
                    enabled: !saving,
                    decoration: InputDecoration(
                      labelText: l10n.commentOptional,
                      border: const OutlineInputBorder(),
                    ),
                  ),
                  if (err != null) ...[
                    const SizedBox(height: 8),
                    Text(err!, style: TextStyle(color: Theme.of(ctx).colorScheme.error, fontSize: 13)),
                  ],
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: saving ? null : () => Navigator.pop(ctx, false),
                child: Text(l10n.cancel),
              ),
              FilledButton(
                onPressed: saving || rating < 1
                    ? null
                    : () async {
                        setD(() {
                          saving = true;
                          err = null;
                        });
                        try {
                          await createReview(
                            token: t,
                            exchangeRequestId: booking.id,
                            rating: rating,
                            comment: commentCtrl.text.trim().isEmpty ? null : commentCtrl.text.trim(),
                          );
                          if (ctx.mounted) Navigator.pop(ctx, true);
                        } on ApiException catch (e) {
                          setD(() {
                            err = e.message;
                            saving = false;
                          });
                        } catch (e) {
                          setD(() {
                            err = '$e';
                            saving = false;
                          });
                        }
                      },
                child: saving
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(l10n.submitReview),
              ),
            ],
          );
        },
      ),
    );
    commentCtrl.dispose();
    if (submitted == true && mounted) await _load();
  }

  String _initials() {
    final name = _profile?.fullName ?? widget.appState.fullName ?? 'Member';
    return initialsFromFullName(name);
  }

  bool get _showReceivedSummary =>
      _summaryReceived != null &&
      _summaryReceived!.totalReviews > 0 &&
      _summaryReceived!.averageRating.isFinite;

  bool get _showGivenSummary =>
      _summaryGiven != null &&
      _summaryGiven!.totalReviews > 0 &&
      _summaryGiven!.averageRating.isFinite;

  String _formatReviewDate(BuildContext context, String iso) {
    final dt = DateTime.tryParse(iso)?.toLocal();
    if (dt == null) return iso;
    return MaterialLocalizations.of(context).formatMediumDate(dt);
  }

  Widget _starRow(int rating) {
    final n = rating.clamp(0, 5);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(
        n,
        (_) => Icon(Icons.star_rounded, size: 18, color: Colors.amber.shade700),
      ),
    );
  }

  /// Web `ProfilePage` reviews tab — received (from students).
  Widget _receivedReviewCard(BuildContext context, ReviewDto r) {
    final theme = Theme.of(context);
    final muted = theme.colorScheme.onSurface.withValues(alpha: 0.55);
    final dateStr = _formatReviewDate(context, r.createdAt);
    final skill = r.skillTitle?.trim();
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.35),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: theme.colorScheme.outlineVariant),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: r.reviewerId.isEmpty
            ? null
            : () {
                Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => PublicProfileScreen(
                      appState: widget.appState,
                      userId: r.reviewerId,
                    ),
                  ),
                );
              },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                backgroundColor: theme.colorScheme.surfaceContainerHighest,
                child: Text(
                  initialsFromFullName(r.reviewerName),
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: muted,
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                r.reviewerName,
                                style: GoogleFonts.inter(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 15,
                                ),
                              ),
                              if (skill != null && skill.isNotEmpty)
                                Padding(
                                  padding: const EdgeInsets.only(top: 2),
                                  child: Text(
                                    skill,
                                    style: GoogleFonts.inter(
                                      fontSize: 12,
                                      color: muted,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                        _starRow(r.rating),
                      ],
                    ),
                    if (r.comment != null && r.comment!.trim().isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Text(
                        r.comment!.trim(),
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          height: 1.35,
                          color: theme.colorScheme.onSurface.withValues(alpha: 0.9),
                        ),
                      ),
                    ],
                    const SizedBox(height: 8),
                    Text(
                      dateStr,
                      style: GoogleFonts.inter(fontSize: 12, color: muted),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Web `ProfilePage` reviews tab — given (ratings I gave).
  Widget _givenReviewCard(BuildContext context, ReviewDto r) {
    final theme = Theme.of(context);
    final muted = theme.colorScheme.onSurface.withValues(alpha: 0.55);
    final dateStr = _formatReviewDate(context, r.createdAt);
    final skill = r.skillTitle?.trim();
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.35),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: theme.colorScheme.outlineVariant),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: r.reviewedUserId.isEmpty
            ? null
            : () {
                Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => PublicProfileScreen(
                      appState: widget.appState,
                      userId: r.reviewedUserId,
                    ),
                  ),
                );
              },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                backgroundColor: theme.colorScheme.surfaceContainerHighest,
                child: Text(
                  initialsFromFullName(r.reviewedUserName),
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: muted,
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                r.reviewedUserName,
                                style: GoogleFonts.inter(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 15,
                                ),
                              ),
                              if (skill != null && skill.isNotEmpty)
                                Padding(
                                  padding: const EdgeInsets.only(top: 2),
                                  child: Text(
                                    skill,
                                    style: GoogleFonts.inter(
                                      fontSize: 12,
                                      color: muted,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                        _starRow(r.rating),
                      ],
                    ),
                    if (r.comment != null && r.comment!.trim().isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Text(
                        r.comment!.trim(),
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          height: 1.35,
                          color: theme.colorScheme.onSurface.withValues(alpha: 0.9),
                        ),
                      ),
                    ],
                    const SizedBox(height: 8),
                    Text(
                      dateStr,
                      style: GoogleFonts.inter(fontSize: 12, color: muted),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _buildTeachingSlivers(BuildContext context, ThemeData theme, ProfileL10n l10n) {
    final bySkill = _teachingBookingsBySkill();
    return [
      SliverToBoxAdapter(
        child: Padding(
          padding: EdgeInsets.fromLTRB(AppChrome.heroHeaderPaddingH, 0, AppChrome.heroHeaderPaddingH, 8),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  l10n.skillsTeach,
                  style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w800),
                ),
              ),
              FilledButton(
                onPressed: () async {
                  final ok = await Navigator.of(context).push<bool>(
                    MaterialPageRoute(
                      builder: (_) => AddSkillScreen(appState: widget.appState),
                    ),
                  );
                  if (ok == true && mounted) _load();
                },
                child: Text(l10n.addNewSkill),
              ),
            ],
          ),
        ),
      ),
      if (_skills.isEmpty)
        SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.fromLTRB(AppChrome.heroHeaderPaddingH, 8, AppChrome.heroHeaderPaddingH, 24),
            child: Text(
              l10n.emptyTeaching,
              style: GoogleFonts.inter(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.55),
              ),
            ),
          ),
        )
      else
        SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, i) {
              final s = _skills[i];
              final bookings = bySkill[s.id] ?? [];
              final learners = bookings.map((b) => b.requesterId.toLowerCase()).toSet().length;
              final muted = theme.colorScheme.onSurface.withValues(alpha: 0.55);
              final coverUrl = skillCoverProxyUrl(s.id);
              final levelText = l10n.skillLevelFromApi(s.level);
              final sessionTypeText = s.sessionTypes.isNotEmpty
                  ? s.sessionTypes.map(l10n.sessionTypeChip).join(', ')
                  : (fallbackSessionTypeFromDescription(s.description) ?? '');
              final locationText = (s.inPersonLocation ?? '').trim().isNotEmpty
                  ? s.inPersonLocation!.trim()
                  : (fallbackLocationFromDescription(s.description) ?? '');
              final availability = getSkillAvailabilityParts(s, _profileDayLabels) ??
                  fallbackAvailabilityFromDescription(s.description, _profileDayLabels);
              final preview = skillCardDescriptionPreview(s.description);
              final category = s.category?.trim();

              return Card(
                margin: EdgeInsets.symmetric(horizontal: AppChrome.heroHeaderPaddingH, vertical: 8),
                clipBehavior: Clip.antiAlias,
                elevation: 0,
                color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.25),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(color: theme.colorScheme.outlineVariant),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    AspectRatio(
                      aspectRatio: 16 / 9,
                      child: Image.network(
                        coverUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => ColoredBox(
                          color: theme.colorScheme.primary.withValues(alpha: 0.12),
                          child: Icon(
                            Icons.auto_awesome_mosaic_rounded,
                            size: 48,
                            color: theme.colorScheme.primary.withValues(alpha: 0.35),
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      s.title,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: GoogleFonts.inter(
                                        fontWeight: FontWeight.w700,
                                        fontSize: 17,
                                      ),
                                    ),
                                    if (category != null && category.isNotEmpty)
                                      Padding(
                                        padding: const EdgeInsets.only(top: 4),
                                        child: Text(
                                          category,
                                          style: GoogleFonts.inter(
                                            fontSize: 12,
                                            color: muted,
                                          ),
                                        ),
                                      ),
                                    const SizedBox(height: 8),
                                    Wrap(
                                      spacing: 6,
                                      runSpacing: 6,
                                      children: [
                                        if (levelText != null && levelText.isNotEmpty)
                                          Chip(
                                            label: Text(
                                              levelText,
                                              style: const TextStyle(fontSize: 12),
                                            ),
                                            visualDensity: VisualDensity.compact,
                                            padding: EdgeInsets.zero,
                                          ),
                                        if (sessionTypeText.isNotEmpty)
                                          Chip(
                                            label: Text(
                                              sessionTypeText,
                                              style: const TextStyle(fontSize: 12),
                                            ),
                                            visualDensity: VisualDensity.compact,
                                            side: BorderSide(color: theme.colorScheme.outline),
                                            padding: EdgeInsets.zero,
                                          ),
                                        if (locationText.isNotEmpty)
                                          Chip(
                                            label: Text(
                                              locationText,
                                              style: const TextStyle(fontSize: 12),
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            visualDensity: VisualDensity.compact,
                                            side: BorderSide(color: theme.colorScheme.outline),
                                            padding: EdgeInsets.zero,
                                          ),
                                        if (availability != null) ...[
                                          Chip(
                                            label: Text(
                                              availability.days,
                                              style: const TextStyle(fontSize: 11, height: 1.2),
                                            ),
                                            visualDensity: VisualDensity.compact,
                                            side: BorderSide(color: theme.colorScheme.outline),
                                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                          ),
                                          Chip(
                                            label: Text(
                                              availability.hours,
                                              style: const TextStyle(fontSize: 12),
                                            ),
                                            visualDensity: VisualDensity.compact,
                                            side: BorderSide(color: theme.colorScheme.outline),
                                            padding: EdgeInsets.zero,
                                          ),
                                        ],
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              Column(
                                children: [
                                  Icon(
                                    Icons.star_rounded,
                                    size: 18,
                                    color: Colors.amber.shade700.withValues(alpha: 0.5),
                                  ),
                                  Text(
                                    '—',
                                    style: GoogleFonts.inter(
                                      fontSize: 12,
                                      color: muted,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              Icon(Icons.menu_book_outlined, size: 16, color: muted),
                              const SizedBox(width: 6),
                              Text(
                                '${l10n.studentsCount(learners)} · ${s.durationMinutes} ${l10n.minPerSessionSuffix}',
                                style: GoogleFonts.inter(fontSize: 13, color: muted),
                              ),
                            ],
                          ),
                          if (preview.isNotEmpty) ...[
                            const SizedBox(height: 10),
                            Text(
                              preview,
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.inter(
                                fontSize: 13,
                                height: 1.35,
                                color: theme.colorScheme.onSurface.withValues(alpha: 0.72),
                              ),
                            ),
                          ],
                          const SizedBox(height: 14),
                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton(
                                  onPressed: () async {
                                    final ok = await Navigator.of(context).push<bool>(
                                      MaterialPageRoute(
                                        builder: (_) => AddSkillScreen(
                                          appState: widget.appState,
                                          skillId: s.id,
                                        ),
                                      ),
                                    );
                                    if (ok == true && mounted) _load();
                                  },
                                  child: Text(l10n.edit),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: OutlinedButton(
                                  onPressed: () {
                                    Navigator.of(context).push(
                                      MaterialPageRoute<void>(
                                        builder: (_) => SkillDetailScreen(
                                          appState: widget.appState,
                                          skillId: s.id,
                                        ),
                                      ),
                                    );
                                  },
                                  child: Text(l10n.viewDetails),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
            childCount: _skills.length,
          ),
        ),
    ];
  }

  List<Widget> _buildLearningSlivers(BuildContext context, ThemeData theme, ProfileL10n l10n) {
    final bookings = _learningBookings;
    final givenMap = _givenReviewByExchangeId();
    return [
      SliverToBoxAdapter(
        child: Padding(
          padding: EdgeInsets.fromLTRB(AppChrome.heroHeaderPaddingH, 0, AppChrome.heroHeaderPaddingH, 8),
          child: Text(
            l10n.skillsLearning,
            style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w800),
          ),
        ),
      ),
      if (bookings.isEmpty)
        SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.fromLTRB(AppChrome.heroHeaderPaddingH, 8, AppChrome.heroHeaderPaddingH, 24),
            child: Text(
              l10n.emptyLearning,
              style: GoogleFonts.inter(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.55),
              ),
            ),
          ),
        )
      else
        SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, i) {
              final b = bookings[i];
              final statusLabel =
                  b.status == 'COMPLETED' ? l10n.learningStatusCompleted : l10n.learningStatusAccepted;
              final totalTime = formatBookedDurationEn(b.bookedMinutes);
              final existing = givenMap[b.id];
              return Card(
                margin: EdgeInsets.symmetric(horizontal: AppChrome.heroHeaderPaddingH, vertical: 8),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  b.skillTitle,
                                  style: GoogleFonts.inter(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 17,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${l10n.learningInstructor}: ${b.ownerName}',
                                  style: GoogleFonts.inter(
                                    fontSize: 13,
                                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Chip(
                            label: Text(statusLabel, style: const TextStyle(fontSize: 12)),
                            visualDensity: VisualDensity.compact,
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text(
                        '${l10n.learningSession}: ${_formatSessionTime(context, b.scheduledStartAt)}',
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        l10n.learningTotalTime(totalTime),
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                        ),
                      ),
                      const SizedBox(height: 14),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute<void>(
                                    builder: (_) => SkillDetailScreen(
                                      appState: widget.appState,
                                      skillId: b.skillId,
                                    ),
                                  ),
                                );
                              },
                              child: Text(l10n.viewDetails),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: FilledButton(
                              onPressed: widget.onOpenMessages ??
                                  () {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(l10n.openMessagesHint),
                                      ),
                                    );
                                  },
                              child: Text(l10n.continueLearning),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            foregroundColor: theme.colorScheme.error,
                            side: BorderSide(color: theme.colorScheme.error.withValues(alpha: 0.5)),
                          ),
                          onPressed: () => _openDeleteLearningDialog(b, l10n),
                          child: Text(l10n.deleteLearning),
                        ),
                      ),
                      if (b.status == 'COMPLETED') ...[
                        const SizedBox(height: 10),
                        if (existing != null)
                          Row(
                            children: [
                              Text(
                                l10n.rated,
                                style: GoogleFonts.inter(
                                  fontSize: 13,
                                  color: theme.colorScheme.onSurface.withValues(alpha: 0.55),
                                ),
                              ),
                              const SizedBox(width: 8),
                              _starRow(existing.rating),
                            ],
                          )
                        else
                          SizedBox(
                            width: double.infinity,
                            child: FilledButton.tonal(
                              onPressed: () => _openReviewDialog(b),
                              child: Text(l10n.rateSession),
                            ),
                          ),
                      ],
                    ],
                  ),
                ),
              );
            },
            childCount: bookings.length,
          ),
        ),
    ];
  }

  void _flashShareFeedback(String message) {
    _shareFeedbackTimer?.cancel();
    if (!mounted) return;
    setState(() => _shareFeedback = message);
    _shareFeedbackTimer = Timer(const Duration(milliseconds: 2600), () {
      if (mounted) setState(() => _shareFeedback = null);
    });
  }

  Future<void> _shareProfile(ProfileL10n l10n) async {
    final id = _profile?.id.trim();
    if (id == null || id.isEmpty) {
      _flashShareFeedback(l10n.shareError);
      return;
    }
    final url = AppWebConfig.publicProfileUrl(id);
    try {
      await SharePlus.instance.share(ShareParams(text: url));
      _flashShareFeedback(l10n.shareSuccess);
    } catch (_) {
      await Clipboard.setData(ClipboardData(text: url));
      _flashShareFeedback(l10n.shareCopied);
    }
  }

  String? _memberSinceText(BuildContext context) {
    final raw = _profile?.createdAt?.trim();
    if (raw == null || raw.isEmpty) return null;
    final dt = DateTime.tryParse(raw)?.toLocal();
    if (dt == null) return null;
    final formatted = MaterialLocalizations.of(context).formatFullDate(dt);
    return ProfileL10n.of(context).memberSinceLine(formatted);
  }

  Widget _heroInitials(ThemeData theme) {
    return CircleAvatar(
      radius: 48,
      backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.2),
      child: Text(
        _initials(),
        style: theme.textTheme.headlineSmall?.copyWith(
          color: theme.colorScheme.primary,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  Widget _heroAvatar(ThemeData theme) {
    final url = _profile?.avatarUrl?.trim();
    if (url != null && url.isNotEmpty) {
      if (url.startsWith('data:')) {
        final comma = url.indexOf(',');
        if (comma > 0) {
          try {
            final bytes = base64Decode(url.substring(comma + 1));
            return CircleAvatar(
              radius: 48,
              backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.2),
              child: ClipOval(
                child: Image.memory(
                  bytes,
                  width: 96,
                  height: 96,
                  fit: BoxFit.cover,
                  gaplessPlayback: true,
                  errorBuilder: (context, error, stackTrace) => _heroInitials(theme),
                ),
              ),
            );
          } catch (_) {
            /* fall through */
          }
        }
      } else {
        return CircleAvatar(
          radius: 48,
          backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.2),
          child: ClipOval(
            child: Image.network(
              url,
              width: 96,
              height: 96,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => _heroInitials(theme),
            ),
          ),
        );
      }
    }
    return _heroInitials(theme);
  }

  Widget _reviewsTabContent(BuildContext context, ThemeData theme, ProfileL10n l10n) {
    return Padding(
      padding: EdgeInsets.fromLTRB(AppChrome.heroHeaderPaddingH, 8, AppChrome.heroHeaderPaddingH, 12),
      child: Card(
        child: Padding(
          padding: EdgeInsets.fromLTRB(AppChrome.heroHeaderPaddingH, 20, AppChrome.heroHeaderPaddingH, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                l10n.studentReviews,
                style: GoogleFonts.inter(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                l10n.fromStudents,
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.6,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.55),
                ),
              ),
              const SizedBox(height: 8),
              if (_receivedReviews.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  child: Text(
                    l10n.emptyReviews,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.inter(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.55),
                    ),
                  ),
                )
              else
                ..._receivedReviews.map((r) => _receivedReviewCard(context, r)),
              const SizedBox(height: 28),
              Text(
                l10n.ratingsIGave,
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.6,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.55),
                ),
              ),
              if (_showGivenSummary) ...[
                const SizedBox(height: 8),
                Text(
                  l10n.reviewsGivenSummary(
                    _summaryGiven!.totalReviews,
                    _summaryGiven!.averageRating.toStringAsFixed(1),
                  ),
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.55),
                  ),
                ),
              ],
              const SizedBox(height: 8),
              if (_givenReviews.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  child: Text(
                    l10n.emptyReviewsIGave,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.inter(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.55),
                    ),
                  ),
                )
              else
                ..._givenReviews.map((r) => _givenReviewCard(context, r)),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = ProfileL10n.of(context);
    final name = _profile?.fullName ?? widget.appState.fullName ?? 'Member';
    final email = _profile?.email ?? widget.appState.email ?? '';
    // TODO(beyza): Saat kredisi — UI açılınca kullan
    // final credits = _profile?.timeCreditMinutes;
    final bio = _profile?.bio?.trim();
    final location = _profile?.location?.trim();
    final languages = _profile?.languages?.trim();
    final memberSince = _memberSinceText(context);

    return RefreshIndicator(
      onRefresh: _load,
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(
          parent: BouncingScrollPhysics(),
        ),
        slivers: [
          if (_loading)
            SliverFillRemaining(
              hasScrollBody: false,
              child: Padding(
                padding: EdgeInsets.only(top: MediaQuery.paddingOf(context).top),
                child: const Center(child: CircularProgressIndicator()),
              ),
            )
          else ...[
            SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  DecoratedBox(
                    decoration: const BoxDecoration(gradient: AppChrome.heroGradientLinear),
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(
                        AppChrome.heroHeaderPaddingH,
                        8 + MediaQuery.paddingOf(context).top,
                        AppChrome.heroHeaderPaddingH,
                        22,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Center(
                            child: AppChrome.profileAvatarRing(
                              theme: theme,
                              diameter: 96,
                              child: _heroAvatar(theme),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            name,
                            textAlign: TextAlign.center,
                            style: GoogleFonts.inter(
                              fontSize: 22,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            email,
                            textAlign: TextAlign.center,
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              color: Colors.white.withValues(alpha: 0.88),
                            ),
                          ),
                          // TODO(beyza): Saat kredisi satırı — sonra tekrar açılacak
                          // if (credits != null) ...[
                          //   const SizedBox(height: 8),
                          //   Text(
                          //     '${l10n.timeCreditsPrefix} ${formatDashCreditsEn(credits)}',
                          //     style: GoogleFonts.inter(
                          //       fontWeight: FontWeight.w600,
                          //       color: theme.colorScheme.primary,
                          //     ),
                          //   ),
                          // ],
                          const SizedBox(height: 12),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (_showReceivedSummary) ...[
                                Icon(Icons.star_rounded, color: Colors.amber.shade200, size: 22),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    l10n.ratingsSummaryLine(
                                      _summaryReceived!.averageRating,
                                      _summaryReceived!.totalReviews,
                                    ),
                                    style: GoogleFonts.inter(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white.withValues(alpha: 0.95),
                                    ),
                                  ),
                                ),
                              ] else
                                Expanded(
                                  child: Text(
                                    l10n.noRatingsYet,
                                    style: GoogleFonts.inter(
                                      fontSize: 16,
                                      color: Colors.white.withValues(alpha: 0.92),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton.icon(
                                  onPressed: () => _shareProfile(l10n),
                                  icon: const Icon(Icons.share_rounded, size: 18),
                                  label: Text(l10n.shareProfile),
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: Colors.white,
                                    side: BorderSide(color: Colors.white.withValues(alpha: 0.55)),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: FilledButton.icon(
                                  onPressed: () async {
                                    final ok = await Navigator.of(context).push<bool>(
                                      MaterialPageRoute(
                                        builder: (_) => EditProfileScreen(appState: widget.appState),
                                      ),
                                    );
                                    if (ok == true && mounted) await _load();
                                  },
                                  icon: const Icon(Icons.edit_outlined, size: 18),
                                  label: Text(l10n.editProfile),
                                ),
                              ),
                            ],
                          ),
                          if (_shareFeedback != null) ...[
                            const SizedBox(height: 8),
                            Text(
                              _shareFeedback!,
                              textAlign: TextAlign.center,
                              style: GoogleFonts.inter(
                                fontSize: 13,
                                color: Colors.white.withValues(alpha: 0.95),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                          if (bio != null && bio.isNotEmpty) ...[
                            const SizedBox(height: 14),
                            Text(
                              bio,
                              textAlign: TextAlign.center,
                              style: GoogleFonts.inter(
                                fontSize: 14,
                                height: 1.4,
                                color: Colors.white.withValues(alpha: 0.92),
                              ),
                            ),
                          ],
                          if (location != null && location.isNotEmpty) ...[
                            const SizedBox(height: 10),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.place_outlined, size: 18, color: Colors.white.withValues(alpha: 0.75)),
                                const SizedBox(width: 6),
                                Flexible(
                                  child: Text(
                                    location,
                                    textAlign: TextAlign.center,
                                    style: GoogleFonts.inter(
                                      fontSize: 13,
                                      color: Colors.white.withValues(alpha: 0.88),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                          if (languages != null && languages.isNotEmpty) ...[
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.translate_rounded, size: 18, color: Colors.white.withValues(alpha: 0.75)),
                                const SizedBox(width: 6),
                                Flexible(
                                  child: Text(
                                    languages,
                                    textAlign: TextAlign.center,
                                    style: GoogleFonts.inter(
                                      fontSize: 13,
                                      color: Colors.white.withValues(alpha: 0.88),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                          if (memberSince != null) ...[
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.calendar_today_outlined, size: 16, color: Colors.white.withValues(alpha: 0.75)),
                                const SizedBox(width: 6),
                                Flexible(
                                  child: Text(
                                    memberSince,
                                    textAlign: TextAlign.center,
                                    style: GoogleFonts.inter(
                                      fontSize: 13,
                                      color: Colors.white.withValues(alpha: 0.88),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                          if (_error != null) ...[
                            const SizedBox(height: 12),
                            Text(
                              _error!,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: const Color(0xFFFFCDD2),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: AppChrome.heroHeaderPaddingH),
                    child: Theme(
                      data: theme.copyWith(
                        segmentedButtonTheme: SegmentedButtonThemeData(
                          style: ButtonStyle(
                            visualDensity: VisualDensity.compact,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            padding: const WidgetStatePropertyAll(
                              EdgeInsets.symmetric(horizontal: 4, vertical: 10),
                            ),
                            minimumSize:
                                const WidgetStatePropertyAll(Size(0, 40)),
                          ),
                        ),
                      ),
                      child: SegmentedButton<int>(
                        segments: [
                          ButtonSegment<int>(
                            value: 0,
                            label: _profileTabSegmentLabel(l10n.tabTeaching),
                            icon: const Icon(Icons.school_outlined, size: 18),
                          ),
                          ButtonSegment<int>(
                            value: 1,
                            label: _profileTabSegmentLabel(l10n.tabLearning),
                            icon: const Icon(Icons.menu_book_outlined, size: 18),
                          ),
                          ButtonSegment<int>(
                            value: 2,
                            label: _profileTabSegmentLabel(l10n.tabReviews),
                            icon: const Icon(Icons.star_outline, size: 18),
                          ),
                        ],
                        selected: {_mainTab},
                        onSelectionChanged: (next) {
                          setState(() => _mainTab = next.first);
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
            if (_mainTab == 0) ..._buildTeachingSlivers(context, theme, l10n),
            if (_mainTab == 1) ..._buildLearningSlivers(context, theme, l10n),
            if (_mainTab == 2)
              SliverToBoxAdapter(child: _reviewsTabContent(context, theme, l10n)),
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(AppChrome.heroHeaderPaddingH, 8, AppChrome.heroHeaderPaddingH, 24),
                child: Card(
                  child: Column(
                    children: [
                      // TODO(beyza): Saat kredisi satın al — sonra açılacak
                      // ListTile(
                      //   leading: const Icon(Icons.credit_card_outlined),
                      //   title: Text(l10n.buyTimeCredits),
                      //   trailing: const Icon(Icons.chevron_right_rounded),
                      //   onTap: () {
                      //     ScaffoldMessenger.of(context).showSnackBar(
                      //       SnackBar(content: Text(l10n.paymentDisabledMobile)),
                      //     );
                      //   },
                      // ),
                      // const Divider(height: 1),
                      ListTile(
                        leading: const Icon(Icons.settings_outlined),
                        title: Text(l10n.settings),
                        trailing: const Icon(Icons.chevron_right_rounded),
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute<void>(
                              builder: (_) => SettingsScreen(appState: widget.appState),
                            ),
                          );
                        },
                      ),
                      const Divider(height: 1),
                      ListTile(
                        leading: const Icon(Icons.logout_rounded),
                        title: Text(l10n.logOut),
                        onTap: () => widget.appState.logout(),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
