import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../api/exchange_api.dart';
import '../api/user_api.dart';
import '../app/app_state.dart';
import '../theme/app_colors.dart';
import '../util/formatting.dart';
import '../widgets/gradient_stat_card.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({
    super.key,
    required this.appState,
    this.onOpenNotifications,
    this.onOpenProfile,
    this.onBrowseSkills,
    this.onOfferSkill,
    this.onPastSessions,
    this.onBuyCredits,
  });

  final AppState appState;
  final VoidCallback? onOpenNotifications;
  final VoidCallback? onOpenProfile;
  final VoidCallback? onBrowseSkills;
  final VoidCallback? onOfferSkill;
  final VoidCallback? onPastSessions;
  final VoidCallback? onBuyCredits;

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  UserDashboardDto? _dash;
  List<ExchangeRequestDto> _upcoming = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    widget.appState.addListener(_onAuthChanged);
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  @override
  void dispose() {
    widget.appState.removeListener(_onAuthChanged);
    super.dispose();
  }

  void _onAuthChanged() {
    if (widget.appState.token == null) {
      setState(() {
        _dash = null;
        _upcoming = [];
        _loading = false;
        _error = null;
      });
      return;
    }
    _load();
  }

  Future<void> _load() async {
    final t = widget.appState.token;
    if (t == null) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final dash = await fetchMyDashboard(t);
      final upcoming = await fetchUpcomingAccepted(t);
      if (!mounted) return;
      setState(() {
        _dash = dash;
        _upcoming = upcoming;
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

  List<_StatRow> _statRows() {
    final d = _dash;
    if (d == null && !_loading) {
      return const [
        _StatRow('Hours balance', '—', Icons.schedule_rounded, AppColors.statGradient1),
        _StatRow('Skills you offer', '—', Icons.menu_book_rounded, AppColors.statGradient2),
        _StatRow('Requests you sent', '—', Icons.trending_up_rounded, AppColors.statGradient3),
        _StatRow('Requests you received', '—', Icons.workspace_premium_rounded, AppColors.statGradient4),
      ];
    }
    if (d == null) {
      return const [
        _StatRow('Hours balance', '…', Icons.schedule_rounded, AppColors.statGradient1),
        _StatRow('Skills you offer', '…', Icons.menu_book_rounded, AppColors.statGradient2),
        _StatRow('Requests you sent', '…', Icons.trending_up_rounded, AppColors.statGradient3),
        _StatRow('Requests you received', '…', Icons.workspace_premium_rounded, AppColors.statGradient4),
      ];
    }
    return [
      _StatRow(
        'Hours balance',
        formatDashCreditsEn(d.timeCreditMinutes),
        Icons.schedule_rounded,
        AppColors.statGradient1,
      ),
      _StatRow(
        'Skills you offer',
        '${d.mySkillsCount}',
        Icons.menu_book_rounded,
        AppColors.statGradient2,
      ),
      _StatRow(
        'Requests you sent',
        '${d.sentRequestsCount}',
        Icons.trending_up_rounded,
        AppColors.statGradient3,
      ),
      _StatRow(
        'Requests you received',
        '${d.receivedRequestsCount}',
        Icons.workspace_premium_rounded,
        AppColors.statGradient4,
      ),
    ];
  }

  String _welcomeFirstName() {
    final fromDash = _dash?.fullName;
    final fromAuth = widget.appState.fullName;
    return firstNameFromFullName((fromDash ?? fromAuth ?? '').trim().isEmpty ? 'there' : (fromDash ?? fromAuth!));
  }

  String _partnerName(ExchangeRequestDto ex) {
    final my = widget.appState.userId;
    if (my != null && ex.requesterId == my) return ex.ownerName;
    return ex.requesterName;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final stats = _statRows();

    return RefreshIndicator(
      onRefresh: _load,
      child: CustomScrollView(
        clipBehavior: Clip.none,
        physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
        slivers: [
          SliverToBoxAdapter(
            child: DashboardHero(
              title: 'Welcome back, ${_welcomeFirstName()}! 👋',
              subtitle: "Here's what's happening with your learning journey",
              onOpenNotifications: widget.onOpenNotifications,
              onOpenProfile: widget.onOpenProfile,
            ),
          ),
          if (_error != null)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
                child: Material(
                  color: theme.colorScheme.errorContainer.withValues(alpha: 0.35),
                  borderRadius: BorderRadius.circular(12),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Text(
                      _error!,
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        color: theme.colorScheme.error,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 20),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    LayoutBuilder(
                      builder: (context, c) {
                        final w = c.maxWidth;
                        return Stack(
                          children: [
                            _StatCardsBlock(
                              stats: stats,
                              twoColumns: w >= 280,
                              gap: 8,
                            ),
                            if (_loading)
                              Positioned.fill(
                                child: ColoredBox(
                                  color: theme.scaffoldBackgroundColor.withValues(alpha: 0.55),
                                  child: const Center(
                                    child: SizedBox(
                                      width: 28,
                                      height: 28,
                                      child: CircularProgressIndicator(strokeWidth: 2.5),
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        );
                      },
                    ),
                    const SizedBox(height: 6),
                    _SectionCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Expanded(
                                child: Text(
                                  'Upcoming Sessions',
                                  style: GoogleFonts.inter(
                                    fontSize: 17,
                                    fontWeight: FontWeight.w700,
                                    color: theme.colorScheme.onSurface,
                                  ),
                                ),
                              ),
                              FilledButton.tonalIcon(
                                onPressed: widget.onBrowseSkills,
                                icon: const Icon(Icons.add, size: 18),
                                label: const Text('Book New'),
                                style: FilledButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 8,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),
                          if (_upcoming.isEmpty)
                            Text(
                              'No upcoming sessions. Book a skill from Browse when you’re ready.',
                              textAlign: TextAlign.center,
                              style: GoogleFonts.inter(
                                fontSize: 14,
                                height: 1.5,
                                color: theme.colorScheme.onSurface.withValues(
                                  alpha: isDark ? 0.55 : 0.6,
                                ),
                              ),
                            )
                          else
                            ..._upcoming.map(
                              (ex) => Padding(
                                padding: const EdgeInsets.only(bottom: 10),
                                child: DecoratedBox(
                                  decoration: BoxDecoration(
                                    color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: theme.colorScheme.outline.withValues(alpha: 0.25),
                                    ),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(12),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          ex.skillTitle,
                                          style: GoogleFonts.inter(
                                            fontWeight: FontWeight.w600,
                                            fontSize: 15,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          'With ${_partnerName(ex)}',
                                          style: GoogleFonts.inter(
                                            fontSize: 13,
                                            color: theme.colorScheme.onSurface.withValues(alpha: 0.55),
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          'Booked: ${formatBookedDurationEn(ex.bookedMinutes)}',
                                          style: GoogleFonts.inter(
                                            fontSize: 12,
                                            color: theme.colorScheme.onSurface.withValues(alpha: 0.45),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          const SizedBox(height: 8),
                          TextButton(
                            onPressed: widget.onPastSessions,
                            child: Text(
                              'View All Sessions',
                              style: GoogleFonts.inter(fontWeight: FontWeight.w600),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),
                    _SectionCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            'Quick Actions',
                            style: GoogleFonts.inter(
                              fontSize: 17,
                              fontWeight: FontWeight.w700,
                              color: theme.colorScheme.onSurface,
                            ),
                          ),
                          const SizedBox(height: 14),
                          GradientCtaButton(
                            label: 'Offer a New Skill',
                            icon: Icons.add_rounded,
                            onPressed: widget.onOfferSkill,
                          ),
                          const SizedBox(height: 12),
                          _OutlineAction(
                            label: 'Browse Skills',
                            icon: Icons.menu_book_outlined,
                            onPressed: widget.onBrowseSkills,
                          ),
                          if (widget.onBuyCredits != null) ...[
                            const SizedBox(height: 10),
                            _OutlineAction(
                              label: 'Buy time credits',
                              icon: Icons.credit_card_outlined,
                              onPressed: widget.onBuyCredits,
                            ),
                          ],
                          const SizedBox(height: 10),
                          _OutlineAction(
                            label: 'View Past Sessions',
                            icon: Icons.history_rounded,
                            onPressed: widget.onPastSessions,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),
                    _SectionCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Learning Progress',
                            style: GoogleFonts.inter(
                              fontSize: 17,
                              fontWeight: FontWeight.w700,
                              color: theme.colorScheme.onSurface,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'No learning progress to show yet.',
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              height: 1.5,
                              color: theme.colorScheme.onSurface.withValues(
                                alpha: isDark ? 0.55 : 0.6,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ]),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 4)),
        ],
      ),
    );
  }
}

class _StatRow {
  const _StatRow(this.title, this.value, this.icon, this.gradient);
  final String title;
  final String value;
  final IconData icon;
  final List<Color> gradient;
}

class _StatCardsBlock extends StatelessWidget {
  const _StatCardsBlock({
    required this.stats,
    required this.twoColumns,
    required this.gap,
  });

  final List<_StatRow> stats;
  final bool twoColumns;
  final double gap;

  @override
  Widget build(BuildContext context) {
    if (!twoColumns) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (var i = 0; i < stats.length; i++) ...[
            if (i > 0) SizedBox(height: gap),
            GradientStatCard(
              title: stats[i].title,
              value: stats[i].value,
              icon: stats[i].icon,
              gradient: stats[i].gradient,
            ),
          ],
        ],
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: GradientStatCard(
                title: stats[0].title,
                value: stats[0].value,
                icon: stats[0].icon,
                gradient: stats[0].gradient,
              ),
            ),
            SizedBox(width: gap),
            Expanded(
              child: GradientStatCard(
                title: stats[1].title,
                value: stats[1].value,
                icon: stats[1].icon,
                gradient: stats[1].gradient,
              ),
            ),
          ],
        ),
        SizedBox(height: gap),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: GradientStatCard(
                title: stats[2].title,
                value: stats[2].value,
                icon: stats[2].icon,
                gradient: stats[2].gradient,
              ),
            ),
            SizedBox(width: gap),
            Expanded(
              child: GradientStatCard(
                title: stats[3].title,
                value: stats[3].value,
                icon: stats[3].icon,
                gradient: stats[3].gradient,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
        child: child,
      ),
    );
  }
}

class _OutlineAction extends StatelessWidget {
  const _OutlineAction({
    required this.label,
    required this.icon,
    this.onPressed,
  });

  final String label;
  final IconData icon;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final border = isDark
        ? Colors.white.withValues(alpha: 0.12)
        : theme.colorScheme.outline.withValues(alpha: 0.45);

    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, size: 21),
        label: Text(label, style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(double.infinity, 50),
          alignment: Alignment.centerLeft,
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          foregroundColor: theme.colorScheme.onSurface,
          side: BorderSide(color: border),
        ),
      ),
    );
  }
}
