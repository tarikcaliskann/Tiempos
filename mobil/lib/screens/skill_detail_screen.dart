// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../api/api_exception.dart';
import '../api/exchange_api.dart';
import '../api/skills_api.dart';
import '../widgets/skill_cover_image.dart';
import '../app/app_state.dart';
import '../language/skill_flow_l10n.dart';
import '../widgets/app_chrome.dart';
import '../util/booking_availability.dart' hide buildHalfHourSlots;
import '../util/booking_utils.dart';
import 'public_profile_screen.dart';

class SkillDetailScreen extends StatefulWidget {
  const SkillDetailScreen({
    super.key,
    required this.appState,
    required this.skillId,
    this.onLoginRequired,
  });

  final AppState appState;
  final String skillId;
  /// Token yokken rezervasyon / eğitmen profili: girişe yönlendir (misafir keşfet).
  final VoidCallback? onLoginRequired;

  @override
  State<SkillDetailScreen> createState() => _SkillDetailScreenState();
}

class _SkillDetailScreenState extends State<SkillDetailScreen> {
  SkillDto? _skill;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final s = await fetchSkillById(widget.skillId);
      if (!mounted) return;
      setState(() {
        _skill = s;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _skill = null;
        _error = '$e';
        _loading = false;
      });
    }
  }

  String _descriptionMain(String desc) {
    const sep = '\n\n———\n';
    final i = desc.indexOf(sep);
    return (i >= 0 ? desc.substring(0, i) : desc).trim();
  }

  Future<void> _openBook(SkillDto s) async {
    final sf = SkillFlowL10n.of(context);
    final lang =
        Localizations.localeOf(
          context,
        ).languageCode.toLowerCase().startsWith('tr')
        ? 'tr'
        : 'en';
    final token = widget.appState.token;
    if (token == null || token.isEmpty) {
      if (widget.onLoginRequired != null) {
        widget.onLoginRequired!();
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(sf.signInAgainSnack)));
      }
      return;
    }
    final myId = widget.appState.userId;
    if (myId != null && myId == s.ownerId) return;

    var bookDate = tomorrowDateStr();
    if (hasSkillAvailabilityConstraints(s)) {
      final ds = buildSkillDateOptions(s, lang, bookingHorizonDays);
      if (ds.isNotEmpty) bookDate = ds.first.value;
    }
    var bookMinutes = s.durationMinutes > 0 ? s.durationMinutes : 60;
    final messageCtrl = TextEditingController(text: sf.defaultBookMessage);
    List<String> initialChoices() {
      if (hasSkillAvailabilityConstraints(s)) {
        final o = buildSkillTimeOptionsForDate(s, bookDate);
        if (o.isNotEmpty) return o;
        return <String>[];
      }
      return buildHalfHourSlots('08:00', '20:00');
    }

    final initialSlots = initialChoices();
    if (initialSlots.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(sf.noBookableSlots)));
      return;
    }
    var bookTime = initialSlots.contains('10:00')
        ? '10:00'
        : initialSlots.first;
    final ok = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setModal) {
            final bottomInset = MediaQuery.of(ctx).viewInsets.bottom;
            List<String> timeChoices() {
              if (hasSkillAvailabilityConstraints(s)) {
                final o = buildSkillTimeOptionsForDate(s, bookDate);
                if (o.isNotEmpty) return o;
              }
              return buildHalfHourSlots('08:00', '20:00');
            }

            final choices = timeChoices();
            final effTime = choices.contains(bookTime)
                ? bookTime
                : choices.first;
            final inAvail = isWithinSkillAvailability(s, bookDate, effTime);
            final startLocal = DateTime(
              int.parse(bookDate.split('-')[0]),
              int.parse(bookDate.split('-')[1]),
              int.parse(bookDate.split('-')[2]),
              int.parse(effTime.split(':')[0]),
              int.parse(effTime.split(':')[1]),
            );
            final within =
                inAvail &&
                startLocal.millisecondsSinceEpoch >=
                    DateTime.now().millisecondsSinceEpoch + 60 * 60 * 1000;

            return Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 8,
                bottom: 16 + bottomInset,
              ),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      sf.bookSession,
                      style: GoogleFonts.inter(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 16),
                    if (hasSkillAvailabilityConstraints(s)) ...[
                      DropdownButtonFormField<String>(
                        decoration: InputDecoration(labelText: sf.dateLabel),
                        value: () {
                          final opts = buildSkillDateOptions(
                            s,
                            lang,
                            bookingHorizonDays,
                          );
                          final vals = opts.map((e) => e.value).toList();
                          if (vals.contains(bookDate)) return bookDate;
                          return vals.isNotEmpty ? vals.first : bookDate;
                        }(),
                        items:
                            buildSkillDateOptions(s, lang, bookingHorizonDays)
                                .map(
                                  (o) => DropdownMenuItem(
                                    value: o.value,
                                    child: Text(o.label),
                                  ),
                                )
                                .toList(),
                        onChanged: (v) {
                          if (v != null) setModal(() => bookDate = v);
                        },
                      ),
                      const SizedBox(height: 12),
                    ] else
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text(sf.dateLabel),
                        subtitle: Text(bookDate),
                        trailing: const Icon(Icons.calendar_today_rounded),
                        onTap: () async {
                          final parts = bookDate
                              .split('-')
                              .map(int.parse)
                              .toList();
                          final initial = DateTime(
                            parts[0],
                            parts[1],
                            parts[2],
                          );
                          final picked = await showDatePicker(
                            context: ctx,
                            initialDate: initial,
                            firstDate: DateTime.now(),
                            lastDate: DateTime.now().add(
                              const Duration(days: 365),
                            ),
                          );
                          if (picked != null) {
                            setModal(() {
                              bookDate =
                                  '${picked.year}-${picked.month.toString().padLeft(2, "0")}-${picked.day.toString().padLeft(2, "0")}';
                            });
                          }
                        },
                      ),
                    DropdownButtonFormField<String>(
                      decoration: InputDecoration(labelText: sf.startTime),
                      value: choices.contains(bookTime)
                          ? bookTime
                          : choices.first,
                      items: choices
                          .map(
                            (t) => DropdownMenuItem(value: t, child: Text(t)),
                          )
                          .toList(),
                      onChanged: (v) {
                        if (v != null) setModal(() => bookTime = v);
                      },
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<int>(
                      decoration: InputDecoration(
                        labelText: sf.sessionLengthMinutes,
                      ),
                      value: [30, 45, 60, 90, 120].contains(bookMinutes)
                          ? bookMinutes
                          : 60,
                      items: const [30, 45, 60, 90, 120]
                          .map(
                            (m) => DropdownMenuItem(
                              value: m,
                              child: Text(sf.minutesOption(m)),
                            ),
                          )
                          .toList(),
                      onChanged: (v) {
                        if (v != null) setModal(() => bookMinutes = v);
                      },
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: messageCtrl,
                      maxLines: 3,
                      decoration: InputDecoration(
                        labelText: sf.messageToInstructor,
                      ),
                    ),
                    if (!within) ...[
                      const SizedBox(height: 12),
                      Text(
                        sf.outsideAvailability,
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: Theme.of(ctx).colorScheme.error,
                        ),
                      ),
                    ],
                    const SizedBox(height: 20),
                    FilledButton(
                      onPressed: !within
                          ? null
                          : () {
                              bookTime = effTime;
                              Navigator.of(ctx).pop(true);
                            },
                      child: Text(sf.sendRequest),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );

    final msg = messageCtrl.text.trim();
    messageCtrl.dispose();
    if (ok != true || !mounted) return;

    final scheduledStartAt = localDateTimeToUtcIso(bookDate, bookTime);
    try {
      await createExchangeRequest(
        token: token,
        skillId: s.id,
        message: msg,
        bookedMinutes: bookMinutes,
        scheduledStartAt: scheduledStartAt,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(SkillFlowL10n.of(context).bookingSentSnack)),
      );
      Navigator.of(context).pop();
    } on ApiException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.message)));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final sf = SkillFlowL10n.of(context);
    final s = _skill;
    final myId = widget.appState.userId;
    final isOwner = s != null && myId != null && myId == s.ownerId;

    return Scaffold(
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : s == null
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  _error ?? sf.skillNotFound,
                  textAlign: TextAlign.center,
                ),
              ),
            )
          : CustomScrollView(
              slivers: [
                AppChrome.gradientSliverHeader(
                  context: context,
                  title: s.title,
                  subtitle: s.ownerName,
                  leading: IconButton(
                    icon: const Icon(
                      Icons.arrow_back_rounded,
                      color: Colors.white,
                    ),
                    tooltip: MaterialLocalizations.of(
                      context,
                    ).backButtonTooltip,
                    onPressed: () => Navigator.of(context).maybePop(),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(
                      AppChrome.heroHeaderPaddingH,
                      16,
                      AppChrome.heroHeaderPaddingH,
                      16,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(14),
                          child: AspectRatio(
                            aspectRatio: 16 / 9,
                            child: SkillCoverImage(
                              skillId: s.id,
                              fallbackUrl: s.coverImageUrl,
                              errorWidget: ColoredBox(
                                color: theme
                                    .colorScheme.surfaceContainerHighest,
                                child: Icon(
                                  Icons.image_not_supported_outlined,
                                  size: 48,
                                  color: theme.colorScheme.onSurface
                                      .withValues(alpha: 0.25),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: CircleAvatar(
                            child: Text(
                              s.ownerName.isNotEmpty
                                  ? s.ownerName[0].toUpperCase()
                                  : '?',
                            ),
                          ),
                          title: Text(s.ownerName),
                          subtitle: Text(sf.instructor),
                          trailing: const Icon(Icons.chevron_right_rounded),
                          onTap: () {
                            final t = widget.appState.token;
                            if (t == null || t.isEmpty) {
                              if (widget.onLoginRequired != null) {
                                widget.onLoginRequired!();
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      SkillFlowL10n.of(context).signInAgainSnack,
                                    ),
                                  ),
                                );
                              }
                              return;
                            }
                            Navigator.of(context).push(
                              MaterialPageRoute<void>(
                                builder: (ctx) => PublicProfileScreen(
                                  appState: widget.appState,
                                  userId: s.ownerId,
                                ),
                              ),
                            );
                          },
                        ),
                        const Divider(),
                        if (s.category != null && s.category!.trim().isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Chip(label: Text(s.category!)),
                          ),
                        Text(
                          _descriptionMain(s.description),
                          style: GoogleFonts.inter(
                            fontSize: 15,
                            height: 1.45,
                            color: theme.colorScheme.onSurface.withValues(
                              alpha: 0.85,
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        if (!isOwner)
                          FilledButton(
                            onPressed: () => _openBook(s),
                            child: Text(sf.bookThisSkill),
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
