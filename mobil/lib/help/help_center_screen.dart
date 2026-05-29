import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import '../api/public_api.dart';
import '../app/app_state.dart';
import '../language/legal_l10n.dart';
import '../screens/signup_screen.dart';
import '../widgets/app_chrome.dart';
import 'help_bundle.dart';
import 'help_models.dart';

/// Web’deki yardım / yasal / SSS / iletişim içeriğinin tamamı — tek kaydırma + sağda bölüm seçici.
class HelpCenterScreen extends StatefulWidget {
  const HelpCenterScreen({super.key, required this.appState});

  final AppState appState;

  @override
  State<HelpCenterScreen> createState() => _HelpCenterScreenState();
}

class _HelpCenterScreenState extends State<HelpCenterScreen> {
  static const int _sectionCount = 10;

  final ScrollController _scroll = ScrollController();
  late final List<GlobalKey> _sectionKeys;
  int _railIndex = 0;

  PublicPlatformStats? _stats;
  bool _statsLoaded = false;

  final _faqSearch = TextEditingController();
  String _faqCategory = 'all';

  final _contactName = TextEditingController();
  final _contactEmail = TextEditingController();
  final _contactMessage = TextEditingController();
  final _contactFormKey = GlobalKey<FormState>();
  String _contactSubject = '';
  bool _contactSubmitting = false;
  String? _contactError;
  bool _contactSuccess = false;

  bool get _tr {
    final o = widget.appState.localeOverride?.languageCode;
    if (o != null) return o.toLowerCase().startsWith('tr');
    return Localizations.localeOf(context).languageCode.toLowerCase().startsWith('tr');
  }

  bool get _guest {
    final t = widget.appState.token;
    return t == null || t.isEmpty;
  }

  @override
  void initState() {
    super.initState();
    _sectionKeys = List.generate(_sectionCount, (_) => GlobalKey());
    _scroll.addListener(_scheduleRailSync);
    _loadStats();
  }

  Future<void> _loadStats() async {
    final s = await fetchPublicPlatformStats();
    if (!mounted) return;
    setState(() {
      _stats = s;
      _statsLoaded = true;
    });
  }

  void _scheduleRailSync() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _syncRailFromScroll();
    });
  }

  void _syncRailFromScroll() {
    if (!_scroll.hasClients) return;
    const triggerY = 112.0;
    var idx = 0;
    for (var i = 0; i < _sectionKeys.length; i++) {
      final ctx = _sectionKeys[i].currentContext;
      if (ctx == null) continue;
      final box = ctx.findRenderObject() as RenderBox?;
      if (box == null) continue;
      final y = box.localToGlobal(Offset.zero).dy;
      if (y <= triggerY) idx = i;
    }
    if (idx != _railIndex) setState(() => _railIndex = idx);
  }

  void _scrollToSection(int i) {
    final c = _sectionKeys[i].currentContext;
    if (c != null) {
      Scrollable.ensureVisible(
        c,
        duration: const Duration(milliseconds: 420),
        curve: Curves.easeOutCubic,
        alignment: 0.05,
      );
    }
  }

  @override
  void dispose() {
    _scroll.removeListener(_scheduleRailSync);
    _scroll.dispose();
    _faqSearch.dispose();
    _contactName.dispose();
    _contactEmail.dispose();
    _contactMessage.dispose();
    super.dispose();
  }

  List<String> _railLabels(LegalL10n l) => <String>[
        l.howItWorks,
        l.about,
        l.faq,
        l.community,
        l.contact,
        l.support,
        l.terms,
        l.privacy,
        l.cancellation,
        l.instructorGuide,
      ];

  @override
  Widget build(BuildContext context) {
    final l = LegalL10n.forTr(_tr);
    final bundle = helpBundleFor(context, widget.appState);
    final labels = _railLabels(l);
    final wide = MediaQuery.sizeOf(context).width >= 360;

    return Scaffold(
      appBar: AppChrome.gradientAppBar(
        title: l.screenTitle,
        actions: [
          if (!wide)
            PopupMenuButton<int>(
              icon: const Icon(Icons.list_alt_rounded),
              tooltip: l.tocMenu,
              onSelected: _scrollToSection,
              itemBuilder: (ctx) => [
                for (var i = 0; i < labels.length; i++)
                  PopupMenuItem(value: i, child: Text(labels[i], overflow: TextOverflow.ellipsis)),
              ],
            ),
        ],
      ),
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: Scrollbar(
              controller: _scroll,
              thumbVisibility: true,
              child: SingleChildScrollView(
                controller: _scroll,
                padding: const EdgeInsets.fromLTRB(16, 12, 12, 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    KeyedSubtree(key: _sectionKeys[0], child: _HowItWorksBlock(copy: bundle.howItWorks, guest: _guest, onSignup: _openSignup)),
                    const SizedBox(height: 28),
                    KeyedSubtree(
                      key: _sectionKeys[1],
                      child: _AboutBlock(
                        copy: bundle.about,
                        stats: _stats,
                        statsLoaded: _statsLoaded,
                        tr: _tr,
                        guest: _guest,
                        onSignup: _openSignup,
                      ),
                    ),
                    const SizedBox(height: 28),
                    KeyedSubtree(
                      key: _sectionKeys[2],
                      child: _FaqBlock(
                        copy: bundle.faq,
                        search: _faqSearch,
                        category: _faqCategory,
                        onCategory: (c) => setState(() => _faqCategory = c),
                        onSearchChanged: (_) => setState(() {}),
                        onScrollToContact: () => _scrollToSection(4),
                      ),
                    ),
                    const SizedBox(height: 28),
                    KeyedSubtree(key: _sectionKeys[3], child: _StaticBlock(title: bundle.community.title, body: bundle.community.body)),
                    const SizedBox(height: 28),
                    KeyedSubtree(
                      key: _sectionKeys[4],
                      child: _ContactBlock(
                        copy: bundle.contact,
                        formKey: _contactFormKey,
                        nameCtrl: _contactName,
                        emailCtrl: _contactEmail,
                        messageCtrl: _contactMessage,
                        subject: _contactSubject,
                        onSubject: (v) => setState(() => _contactSubject = v ?? ''),
                        submitting: _contactSubmitting,
                        errorText: _contactError,
                        success: _contactSuccess,
                        requiredHint: _tr ? 'Zorunlu' : 'Required',
                        onSubmit: () => _submitContact(bundle.contact),
                        onMailTap: () => _openMail(bundle.contact.emailAddress),
                        onScrollFaq: () => _scrollToSection(2),
                      ),
                    ),
                    const SizedBox(height: 28),
                    KeyedSubtree(key: _sectionKeys[5], child: _StaticBlock(title: bundle.support.title, body: bundle.support.body)),
                    const SizedBox(height: 28),
                    KeyedSubtree(key: _sectionKeys[6], child: _LegalBlock(copy: bundle.terms)),
                    const SizedBox(height: 28),
                    KeyedSubtree(key: _sectionKeys[7], child: _LegalBlock(copy: bundle.privacy)),
                    const SizedBox(height: 28),
                    KeyedSubtree(key: _sectionKeys[8], child: _LegalBlock(copy: bundle.policyCancellation)),
                    const SizedBox(height: 28),
                    KeyedSubtree(key: _sectionKeys[9], child: _StaticBlock(title: bundle.instructorGuide.title, body: bundle.instructorGuide.body)),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ),
          if (wide)
            _SectionRail(
              count: _sectionCount,
              activeIndex: _railIndex,
              labels: labels,
              onSelect: _scrollToSection,
            ),
        ],
      ),
    );
  }

  void _openSignup() {
    Navigator.of(context).push<void>(
      MaterialPageRoute<void>(builder: (_) => SignupScreen(appState: widget.appState)),
    );
  }

  Future<void> _openMail(String email) async {
    final uri = Uri.parse('mailto:$email');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  String _subjectTitle(ContactPageCopy c, String key) {
    switch (key) {
      case 'general':
        return c.subjectGeneral;
      case 'support':
        return c.subjectSupport;
      case 'billing':
        return c.subjectBilling;
      case 'partnership':
        return c.subjectPartnership;
      case 'feedback':
        return c.subjectFeedback;
      case 'other':
        return c.subjectOther;
      default:
        return key;
    }
  }

  Future<void> _submitContact(ContactPageCopy c) async {
    setState(() {
      _contactError = null;
      _contactSuccess = false;
    });
    if (!(_contactFormKey.currentState?.validate() ?? false)) return;
    if (_contactSubject.isEmpty) {
      setState(() => _contactError = c.subjectPlaceholder);
      return;
    }
    setState(() => _contactSubmitting = true);
    try {
      await submitContactForm(
        name: _contactName.text.trim(),
        email: _contactEmail.text.trim(),
        subject: _contactSubject,
        subjectTitle: _subjectTitle(c, _contactSubject),
        message: _contactMessage.text.trim(),
      );
      if (!mounted) return;
      setState(() {
        _contactSubmitting = false;
        _contactSuccess = true;
        _contactName.clear();
        _contactEmail.clear();
        _contactMessage.clear();
        _contactSubject = '';
      });
      Future<void>.delayed(const Duration(seconds: 4), () {
        if (mounted) setState(() => _contactSuccess = false);
      });
    } catch (e) {
      if (!mounted) return;
      final msg = contactSubmitErrorMessage(e, c.errorSend, tr: _tr);
      setState(() {
        _contactSubmitting = false;
        _contactError = msg;
      });
    }
  }
}

class _SectionRail extends StatelessWidget {
  const _SectionRail({
    required this.count,
    required this.activeIndex,
    required this.labels,
    required this.onSelect,
  });

  final int count;
  final int activeIndex;
  final List<String> labels;
  final ValueChanged<int> onSelect;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    return Material(
      color: cs.surfaceContainerHighest.withValues(alpha: 0.35),
      child: SizedBox(
        width: 44,
        child: Column(
          children: [
            const SizedBox(height: 8),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.only(bottom: 12),
                itemCount: count,
                itemBuilder: (context, i) {
                  final active = i == activeIndex;
                  return Tooltip(
                    message: labels[i],
                    preferBelow: false,
                    child: InkWell(
                      onTap: () => onSelect(i),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        child: Center(
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            width: active ? 10 : 7,
                            height: active ? 10 : 7,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: active ? cs.primary : cs.outline.withValues(alpha: 0.55),
                              boxShadow: active
                                  ? [BoxShadow(color: cs.primary.withValues(alpha: 0.35), blurRadius: 6)]
                                  : null,
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HowItWorksBlock extends StatelessWidget {
  const _HowItWorksBlock({required this.copy, required this.guest, required this.onSignup});

  final HowItWorksCopy copy;
  final bool guest;
  final VoidCallback onSignup;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(colors: [cs.primary, cs.tertiary]),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(copy.heroTitle, style: GoogleFonts.inter(fontSize: 24, fontWeight: FontWeight.w800, color: cs.onPrimary)),
              const SizedBox(height: 8),
              Text(copy.heroSubtitle, style: GoogleFonts.inter(fontSize: 15, height: 1.4, color: cs.onPrimary.withValues(alpha: 0.92))),
              if (guest) ...[
                const SizedBox(height: 14),
                FilledButton(
                  style: FilledButton.styleFrom(backgroundColor: cs.surface, foregroundColor: cs.primary),
                  onPressed: onSignup,
                  child: Text(copy.getStartedFree),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 20),
        Text(copy.stepsTitle, textAlign: TextAlign.center, style: GoogleFonts.inter(fontSize: 22, fontWeight: FontWeight.w700)),
        const SizedBox(height: 6),
        Text(copy.stepsSubtitle, textAlign: TextAlign.center, style: GoogleFonts.inter(fontSize: 14, color: theme.colorScheme.onSurface.withValues(alpha: 0.65))),
        const SizedBox(height: 16),
        for (var i = 0; i < copy.steps.length; i++) ...[
          Card(
            elevation: 0,
            color: cs.surfaceContainerHighest.withValues(alpha: 0.45),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(copy.steps[i].number, style: GoogleFonts.inter(fontSize: 36, fontWeight: FontWeight.w600, color: cs.onSurface.withValues(alpha: 0.22))),
                  Text(copy.steps[i].title, style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 8),
                  Text(copy.steps[i].description, style: GoogleFonts.inter(fontSize: 15, height: 1.45, color: cs.onSurface.withValues(alpha: 0.78))),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),
        ],
        const SizedBox(height: 8),
        Text(copy.creditsTitle, style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.w700)),
        const SizedBox(height: 8),
        Text(copy.creditsIntro, style: GoogleFonts.inter(fontSize: 15, height: 1.45)),
        const SizedBox(height: 12),
        _InfoLine(title: copy.teachHour, subtitle: copy.teachHourSub, color: cs.primary),
        const SizedBox(height: 8),
        _InfoLine(title: copy.learnHour, subtitle: copy.learnHourSub, color: cs.tertiary),
        const SizedBox(height: 14),
        Card(
          color: cs.primaryContainer.withValues(alpha: 0.35),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(copy.bonusTitle, style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w700)),
                const SizedBox(height: 6),
                Text(copy.bonusCredits, style: GoogleFonts.inter(fontSize: 17, fontWeight: FontWeight.w600)),
                const SizedBox(height: 6),
                Text(copy.bonusDesc, style: GoogleFonts.inter(fontSize: 14, height: 1.45)),
                if (guest) ...[
                  const SizedBox(height: 12),
                  FilledButton(onPressed: onSignup, child: Text(copy.claimBonus)),
                ],
              ],
            ),
          ),
        ),
        const SizedBox(height: 20),
        Text(copy.whyTitle, textAlign: TextAlign.center, style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.w700)),
        const SizedBox(height: 12),
        for (final b in copy.benefits)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.check_circle_rounded, size: 22, color: Colors.green.shade600),
                const SizedBox(width: 10),
                Expanded(child: Text(b, style: GoogleFonts.inter(fontSize: 15, height: 1.45))),
              ],
            ),
          ),
        const SizedBox(height: 12),
        Text(copy.faqTitle, style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w700)),
        const SizedBox(height: 10),
        for (final f in copy.miniFaqs) ...[
          _MiniFaqTile(q: f.q, a: f.a),
          const SizedBox(height: 8),
        ],
        const SizedBox(height: 16),
        if (guest)
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: LinearGradient(colors: [cs.primary, cs.tertiary]),
            ),
            child: Column(
              children: [
                Text(copy.ctaTitle, textAlign: TextAlign.center, style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.w800, color: cs.onPrimary)),
                const SizedBox(height: 8),
                Text(copy.ctaSubtitle, textAlign: TextAlign.center, style: GoogleFonts.inter(color: cs.onPrimary.withValues(alpha: 0.9))),
                const SizedBox(height: 12),
                FilledButton(
                  style: FilledButton.styleFrom(backgroundColor: cs.surface, foregroundColor: cs.primary),
                  onPressed: onSignup,
                  child: Text(copy.ctaButton),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

class _InfoLine extends StatelessWidget {
  const _InfoLine({required this.title, required this.subtitle, required this.color});

  final String title;
  final String subtitle;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: color.withValues(alpha: 0.12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: color.withValues(alpha: 0.35))),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
            Text(subtitle, style: GoogleFonts.inter(fontSize: 13, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.65))),
          ],
        ),
      ),
    );
  }
}

class _MiniFaqTile extends StatelessWidget {
  const _MiniFaqTile({required this.q, required this.a});

  final String q;
  final String a;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(q, style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
            const SizedBox(height: 6),
            Text(a, style: GoogleFonts.inter(fontSize: 14, height: 1.45, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.75))),
          ],
        ),
      ),
    );
  }
}

class _AboutBlock extends StatelessWidget {
  const _AboutBlock({
    required this.copy,
    required this.stats,
    required this.statsLoaded,
    required this.tr,
    required this.guest,
    required this.onSignup,
  });

  final AboutCopy copy;
  final PublicPlatformStats? stats;
  final bool statsLoaded;
  final bool tr;
  final bool guest;
  final VoidCallback onSignup;

  String _fmtInt(int n) {
    final loc = tr ? 'tr_TR' : 'en_US';
    return NumberFormat.decimalPattern(loc).format(n);
  }

  String _statCell(String label, String value) => '$value\n$label';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final dash = '—';
    final loading = '…';
    final members = stats != null
        ? _fmtInt(stats!.verifiedMemberCount)
        : statsLoaded
            ? dash
            : loading;
    final skills = stats != null ? _fmtInt(stats!.skillsListedCount) : statsLoaded ? dash : loading;
    final hours = stats != null ? _fmtInt((stats!.completedSessionMinutesTotal / 60).round()) : statsLoaded ? dash : loading;
    String satisfaction;
    if (stats != null && stats!.satisfactionPercent != null) {
      satisfaction = NumberFormat.decimalPattern(tr ? 'tr_TR' : 'en_US').format(stats!.satisfactionPercent!.round());
      satisfaction = '$satisfaction%';
    } else if (statsLoaded) {
      satisfaction = dash;
    } else {
      satisfaction = loading;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(copy.heroTitle, style: GoogleFonts.inter(fontSize: 26, fontWeight: FontWeight.w800)),
        const SizedBox(height: 8),
        Text(copy.heroSubtitle, style: GoogleFonts.inter(fontSize: 15, height: 1.45, color: cs.onSurface.withValues(alpha: 0.72))),
        const SizedBox(height: 18),
        Text(copy.missionTitle, style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.w700)),
        const SizedBox(height: 8),
        Text(copy.missionP1, style: GoogleFonts.inter(fontSize: 15, height: 1.5)),
        const SizedBox(height: 10),
        Text(copy.missionP2, style: GoogleFonts.inter(fontSize: 15, height: 1.5)),
        const SizedBox(height: 16),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 10,
          crossAxisSpacing: 10,
          childAspectRatio: 1.15,
          children: [
            _StatTile(text: _statCell(copy.statMembers, members)),
            _StatTile(text: _statCell(copy.statSkills, skills)),
            _StatTile(text: _statCell(copy.statHours, hours)),
            _StatTile(text: _statCell(copy.statSatisfaction, satisfaction)),
          ],
        ),
        const SizedBox(height: 20),
        Text(copy.valuesTitle, textAlign: TextAlign.center, style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.w700)),
        const SizedBox(height: 12),
        for (final v in copy.values)
          Card(
            elevation: 0,
            color: cs.surfaceContainerHighest.withValues(alpha: 0.4),
            margin: const EdgeInsets.only(bottom: 10),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(v.title, style: GoogleFonts.inter(fontWeight: FontWeight.w700)),
                  const SizedBox(height: 6),
                  Text(v.body, style: GoogleFonts.inter(fontSize: 14, height: 1.45)),
                ],
              ),
            ),
          ),
        const SizedBox(height: 8),
        Text(copy.storyTitle, textAlign: TextAlign.center, style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.w700)),
        const SizedBox(height: 10),
        for (final p in copy.storyParagraphs)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Text(p, style: GoogleFonts.inter(fontSize: 15, height: 1.55)),
          ),
        const SizedBox(height: 12),
        Card(
          color: cs.primaryContainer.withValues(alpha: 0.25),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(copy.ctaTitle, style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w700)),
                const SizedBox(height: 6),
                Text(copy.ctaSubtitle, style: GoogleFonts.inter(fontSize: 14, height: 1.45)),
                if (guest) ...[
                  const SizedBox(height: 12),
                  FilledButton(onPressed: onSignup, child: Text(copy.ctaButton)),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final parts = text.split('\n');
    final numeral = parts.first;
    final label = parts.skip(1).join('\n');
    return Card(
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(numeral, style: GoogleFonts.inter(fontSize: 22, fontWeight: FontWeight.w800)),
            const SizedBox(height: 4),
            Text(label, style: GoogleFonts.inter(fontSize: 12, height: 1.3, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7))),
          ],
        ),
      ),
    );
  }
}

class _FaqBlock extends StatelessWidget {
  const _FaqBlock({
    required this.copy,
    required this.search,
    required this.category,
    required this.onCategory,
    required this.onSearchChanged,
    required this.onScrollToContact,
  });

  final FaqPageCopy copy;
  final TextEditingController search;
  final String category;
  final ValueChanged<String> onCategory;
  final ValueChanged<String> onSearchChanged;
  final VoidCallback onScrollToContact;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final q = search.text.trim().toLowerCase();
    final items = copy.items.where((faq) {
      final catOk = category == 'all' || faq.category == category;
      final searchOk = q.isEmpty || faq.q.toLowerCase().contains(q) || faq.a.toLowerCase().contains(q);
      return catOk && searchOk;
    }).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(copy.heroTitle, style: GoogleFonts.inter(fontSize: 24, fontWeight: FontWeight.w800)),
        const SizedBox(height: 8),
        Text(copy.heroSubtitle, style: GoogleFonts.inter(fontSize: 15, height: 1.45, color: theme.colorScheme.onSurface.withValues(alpha: 0.72))),
        const SizedBox(height: 14),
        TextField(
          controller: search,
          onChanged: onSearchChanged,
          decoration: InputDecoration(
            hintText: copy.searchPlaceholder,
            prefixIcon: const Icon(Icons.search_rounded),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            isDense: true,
          ),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final c in copy.categories)
              FilterChip(
                label: Text(c.label, style: GoogleFonts.inter(fontSize: 13)),
                selected: category == c.id,
                onSelected: (_) => onCategory(c.id),
              ),
          ],
        ),
        const SizedBox(height: 12),
        if (items.isEmpty)
          Padding(
            padding: const EdgeInsets.all(24),
            child: Center(child: Text(copy.emptyText, textAlign: TextAlign.center, style: GoogleFonts.inter())),
          )
        else
          for (final faq in items)
            Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: ExpansionTile(
                title: Text(faq.q, style: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 15)),
                childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(faq.a, style: GoogleFonts.inter(fontSize: 14, height: 1.5)),
                  ),
                ],
              ),
            ),
        const SizedBox(height: 12),
        Card(
          color: theme.colorScheme.secondaryContainer.withValues(alpha: 0.25),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(copy.ctaTitle, style: GoogleFonts.inter(fontSize: 17, fontWeight: FontWeight.w700)),
                const SizedBox(height: 6),
                Text(copy.ctaText, style: GoogleFonts.inter(fontSize: 14, height: 1.45)),
                const SizedBox(height: 10),
                FilledButton.tonal(onPressed: onScrollToContact, child: Text(copy.ctaButton)),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _StaticBlock extends StatelessWidget {
  const _StaticBlock({required this.title, required this.body});

  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    final paras = body.split(RegExp(r'\n\n+')).map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(title, style: GoogleFonts.inter(fontSize: 22, fontWeight: FontWeight.w800)),
        const SizedBox(height: 10),
        for (final p in paras)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Text(p, style: GoogleFonts.inter(fontSize: 15, height: 1.55)),
          ),
      ],
    );
  }
}

class _LegalBlock extends StatelessWidget {
  const _LegalBlock({required this.copy});

  final LegalDocCopy copy;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final paras = copy.body.split(RegExp(r'\n\n+')).map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(copy.title, style: GoogleFonts.inter(fontSize: 22, fontWeight: FontWeight.w800)),
        const SizedBox(height: 6),
        Text(copy.heroSubtitle, style: GoogleFonts.inter(fontSize: 14, height: 1.45, color: theme.colorScheme.onSurface.withValues(alpha: 0.7))),
        const SizedBox(height: 12),
        Card(
          elevation: 0,
          color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.35),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (final p in paras)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Text(p, style: GoogleFonts.inter(fontSize: 14, height: 1.55)),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _ContactBlock extends StatelessWidget {
  const _ContactBlock({
    required this.copy,
    required this.formKey,
    required this.nameCtrl,
    required this.emailCtrl,
    required this.messageCtrl,
    required this.subject,
    required this.onSubject,
    required this.submitting,
    required this.errorText,
    required this.success,
    required this.requiredHint,
    required this.onSubmit,
    required this.onMailTap,
    required this.onScrollFaq,
  });

  final ContactPageCopy copy;
  final GlobalKey<FormState> formKey;
  final TextEditingController nameCtrl;
  final TextEditingController emailCtrl;
  final TextEditingController messageCtrl;
  final String subject;
  final ValueChanged<String?> onSubject;
  final bool submitting;
  final String? errorText;
  final bool success;
  final String requiredHint;
  final VoidCallback onSubmit;
  final VoidCallback onMailTap;
  final VoidCallback onScrollFaq;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(copy.heroTitle, style: GoogleFonts.inter(fontSize: 24, fontWeight: FontWeight.w800)),
        const SizedBox(height: 8),
        Text(copy.heroSubtitle, style: GoogleFonts.inter(fontSize: 15, height: 1.45, color: theme.colorScheme.onSurface.withValues(alpha: 0.72))),
        const SizedBox(height: 16),
        Text(copy.infoTitle, style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w700)),
        const SizedBox(height: 6),
        Text(copy.infoIntro, style: GoogleFonts.inter(fontSize: 14, height: 1.45)),
        const SizedBox(height: 12),
        ListTile(
          contentPadding: EdgeInsets.zero,
          leading: Icon(Icons.email_outlined, color: theme.colorScheme.primary),
          title: Text(copy.emailTitle, style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
          subtitle: InkWell(
            onTap: onMailTap,
            child: Text(copy.emailAddress, style: GoogleFonts.inter(color: theme.colorScheme.primary, decoration: TextDecoration.underline)),
          ),
        ),
        const SizedBox(height: 8),
        Text(copy.responseTitle, style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
        Text(copy.responseText, style: GoogleFonts.inter(fontSize: 14, height: 1.45)),
        const SizedBox(height: 18),
        Text(copy.formTitle, style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w700)),
        const SizedBox(height: 10),
        if (success)
          Card(
            color: theme.colorScheme.primaryContainer.withValues(alpha: 0.45),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(copy.successTitle, style: GoogleFonts.inter(fontWeight: FontWeight.w700)),
                  const SizedBox(height: 6),
                  Text(copy.successText, style: GoogleFonts.inter(fontSize: 14)),
                ],
              ),
            ),
          )
        else
          Form(
            key: formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextFormField(
                  controller: nameCtrl,
                  decoration: InputDecoration(labelText: copy.labelName, hintText: copy.placeholderName, border: const OutlineInputBorder()),
                  textInputAction: TextInputAction.next,
                  validator: (v) => (v == null || v.trim().isEmpty) ? requiredHint : null,
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: emailCtrl,
                  decoration: InputDecoration(labelText: copy.labelEmail, hintText: copy.placeholderEmail, border: const OutlineInputBorder()),
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return requiredHint;
                    if (!v.contains('@')) return requiredHint;
                    return null;
                  },
                ),
                const SizedBox(height: 10),
                DropdownButtonFormField<String>(
                  // ignore: deprecated_member_use
                  value: subject.isEmpty ? null : subject,
                  decoration: InputDecoration(labelText: copy.labelSubject, border: const OutlineInputBorder()),
                  hint: Text(copy.subjectPlaceholder),
                  items: [
                    DropdownMenuItem(value: 'general', child: Text(copy.subjectGeneral)),
                    DropdownMenuItem(value: 'support', child: Text(copy.subjectSupport)),
                    DropdownMenuItem(value: 'billing', child: Text(copy.subjectBilling)),
                    DropdownMenuItem(value: 'partnership', child: Text(copy.subjectPartnership)),
                    DropdownMenuItem(value: 'feedback', child: Text(copy.subjectFeedback)),
                    DropdownMenuItem(value: 'other', child: Text(copy.subjectOther)),
                  ],
                  onChanged: onSubject,
                  validator: (v) => (v == null || v.isEmpty) ? requiredHint : null,
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: messageCtrl,
                  decoration: InputDecoration(labelText: copy.labelMessage, hintText: copy.placeholderMessage, alignLabelWithHint: true, border: const OutlineInputBorder()),
                  minLines: 4,
                  maxLines: 8,
                  validator: (v) => (v == null || v.trim().isEmpty) ? requiredHint : null,
                ),
                const SizedBox(height: 12),
                if (errorText != null) Text(errorText!, style: GoogleFonts.inter(color: theme.colorScheme.error, fontSize: 13)),
                const SizedBox(height: 8),
                FilledButton(
                  onPressed: submitting ? null : () => onSubmit(),
                  child: submitting ? Text(copy.sending) : Text(copy.sendButton),
                ),
              ],
            ),
          ),
        const SizedBox(height: 20),
        Text(copy.faqSectionTitle, style: GoogleFonts.inter(fontSize: 17, fontWeight: FontWeight.w700)),
        const SizedBox(height: 6),
        Text(copy.faqSectionText, style: GoogleFonts.inter(fontSize: 14, height: 1.45)),
        const SizedBox(height: 8),
        OutlinedButton(onPressed: onScrollFaq, child: Text(copy.faqButton)),
      ],
    );
  }
}
