// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../api/api_exception.dart';
import '../api/exchange_api.dart';
import '../api/reviews_api.dart';
import '../api/skills_api.dart';
import '../api/user_api.dart';
import '../app/app_state.dart';
import '../exchange/exchange_ui_logic.dart';
import '../util/booking_availability.dart' hide buildHalfHourSlots;
import '../util/booking_utils.dart';
import 'public_profile_screen.dart';

/// Web `MessagesPage` konuşma paneli: bir kişiyle tüm talepler + aksiyonlar + thread.
class ConversationThreadScreen extends StatefulWidget {
  const ConversationThreadScreen({
    super.key,
    required this.appState,
    required this.initialRow,
    this.initialExchangeId,
  });

  final AppState appState;
  final ConversationRow initialRow;
  final String? initialExchangeId;

  @override
  State<ConversationThreadScreen> createState() => _ConversationThreadScreenState();
}

class _ConversationThreadScreenState extends State<ConversationThreadScreen> {
  ConversationRow? _row;
  String? _activeExchangeId;
  final _composer = TextEditingController();
  final _meetingUrlCtrl = TextEditingController();
  List<_TimelineItem> _timeline = [];
  bool _loading = true;
  bool _sending = false;
  String? _error;
  UserBlockStateDto? _blocks;
  bool _blockBusy = false;

  @override
  void initState() {
    super.initState();
    _row = widget.initialRow;
    final id = widget.initialExchangeId?.trim();
    _activeExchangeId = (id != null && id.isNotEmpty)
        ? id
        : widget.initialRow.exchanges.first.id;
    _loadBlocks();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _bootstrap();
    });
  }

  Future<void> _bootstrap() async {
    _meetingUrlCtrl.text = _active.sessionMeetingUrl?.trim() ?? '';
    await _buildTimeline();
    await _refresh();
  }

  @override
  void dispose() {
    _composer.dispose();
    _meetingUrlCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadBlocks() async {
    final t = widget.appState.token;
    if (t == null) return;
    try {
      final b = await fetchMyBlockState(t);
      if (mounted) setState(() => _blocks = b);
    } catch (_) {}
  }

  String? get _myId => widget.appState.userId;

  ExchangeRequestDto get _active {
    final r = _row!;
    final id = _activeExchangeId ?? r.exchanges.first.id;
    for (final e in r.exchanges) {
      if (e.id.toLowerCase() == id.toLowerCase()) return e;
    }
    return r.exchanges.first;
  }

  bool get _composerOn => composerAllowsSend(_active);

  Future<void> _refresh() async {
    final t = widget.appState.token;
    if (t == null || _myId == null) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final sent = await fetchSentExchangeRequests(t);
      final received = await fetchReceivedExchangeRequests(t);
      final rows = mergeExchanges(sent, received, _myId);
      ConversationRow? next;
      for (final r in rows) {
        if (r.otherUserId.toLowerCase() ==
            widget.initialRow.otherUserId.toLowerCase()) {
          next = r;
          break;
        }
      }
      if (!mounted) return;
      if (next != null) {
        var aid = _activeExchangeId;
        if (aid == null ||
            !next.exchanges.any((e) => e.id.toLowerCase() == aid!.toLowerCase())) {
          aid = next.exchanges.first.id;
        }
        setState(() {
          _row = next;
          _activeExchangeId = aid;
          _loading = false;
        });
        _meetingUrlCtrl.text = _active.sessionMeetingUrl?.trim() ?? '';
        await _buildTimeline();
      } else {
        setState(() {
          _row = null;
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = '$e';
          _loading = false;
        });
      }
    }
  }

  Future<void> _buildTimeline() async {
    final t = widget.appState.token;
    final r = _row;
    if (t == null || r == null || _myId == null) {
      setState(() => _timeline = []);
      return;
    }
    final chrono = List<ExchangeRequestDto>.from(r.exchanges)
      ..sort((a, b) => a.createdAt.compareTo(b.createdAt));
    final items = <_TimelineItem>[];
    for (final ex in chrono) {
      final createdMs = DateTime.tryParse(ex.createdAt)?.millisecondsSinceEpoch ?? 0;
      final timeLabel = _fmtTime(ex.createdAt);
      items.add(
        _TimelineItem(
          id: 'init-${ex.id}',
          isOffer: false,
          isMine: isInitialMessageFromMe(ex, _myId),
          title: ex.skillTitle,
          body: ex.message,
          timeLabel: timeLabel,
          sortMs: createdMs,
        ),
      );
      final st = toUiStatus(ex, _myId);
      if (st == 'rejected' ||
          st == 'pending-incoming' ||
          st == 'pending-outgoing') {
        items.add(
          _TimelineItem(
            id: 'offer-${ex.id}',
            isOffer: true,
            isMine: false,
            title: ex.skillTitle,
            body:
                'Offer · ${_fmtSchedule(ex.scheduledStartAt)} · ${ex.bookedMinutes} min',
            timeLabel: timeLabel,
            sortMs: createdMs + 1,
            offerStatus: st,
          ),
        );
      }
      final canFetch = isMessageEnabledStatus(ex.status) ||
          (isPendingExchangeStatus(ex.status) &&
              (ex.pendingFromOwner || ex.inquiryOnly));
      if (!canFetch) continue;
      try {
        final msgs = await fetchExchangeMessages(token: t, exchangeRequestId: ex.id);
        for (final m in msgs) {
          final ms = DateTime.tryParse(m.createdAt)?.millisecondsSinceEpoch ?? 0;
          items.add(
            _TimelineItem(
              id: m.id,
              isOffer: false,
              isMine: sameUserId(m.senderId, _myId),
              title: m.senderName,
              body: m.body,
              timeLabel: _fmtTime(m.createdAt),
              sortMs: ms,
            ),
          );
        }
      } catch (_) {}
    }
    items.sort((a, b) => a.sortMs.compareTo(b.sortMs));
    if (mounted) setState(() => _timeline = items);
  }

  String _fmtTime(String iso) {
    final d = DateTime.tryParse(iso);
    if (d == null) return iso;
    return '${d.day}/${d.month} ${d.hour.toString().padLeft(2, "0")}:${d.minute.toString().padLeft(2, "0")}';
  }

  String _fmtSchedule(String? iso) {
    if (iso == null || iso.isEmpty) return '—';
    final d = DateTime.tryParse(iso);
    if (d == null) return iso;
    return d.toLocal().toString().split('.').first;
  }

  Future<void> _send() async {
    final t = widget.appState.token;
    final text = _composer.text.trim();
    if (t == null || text.isEmpty || !_composerOn) return;
    setState(() => _sending = true);
    try {
      await postExchangeMessage(
        token: t,
        exchangeRequestId: _active.id,
        body: text,
      );
      _composer.clear();
      await _refresh();
    } on ApiException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
      }
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  Future<void> _accept() async {
    final t = widget.appState.token;
    if (t == null) return;
    try {
      await acceptExchangeRequest(t, _active.id);
      await _refresh();
    } on ApiException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
      }
    }
  }

  Future<void> _reject() async {
    final t = widget.appState.token;
    if (t == null) return;
    try {
      await rejectExchangeRequest(t, _active.id);
      await _refresh();
    } on ApiException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
      }
    }
  }

  Future<void> _rejectAndCounter() async {
    final t = widget.appState.token;
    if (t == null) return;
    try {
      await rejectExchangeRequest(t, _active.id);
      await _refresh();
      if (!mounted) return;
      await _openBookingCounterSheet();
    } on ApiException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
      }
    }
  }

  Future<void> _cancel() async {
    final t = widget.appState.token;
    if (t == null) return;
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Cancel request?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('No')),
          FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Yes')),
        ],
      ),
    );
    if (ok != true) return;
    try {
      await cancelExchangeRequest(t, _active.id);
      await _refresh();
    } on ApiException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
      }
    }
  }

  Future<void> _openBookingCounterSheet() async {
    final t = widget.appState.token;
    if (t == null) return;
    SkillDto? skill;
    try {
      skill = await fetchSkillById(_active.skillId);
    } catch (_) {}
    if (!mounted) return;
    var bookDate = tomorrowDateStr();
    var bookTime = '10:00';
    var bookMinutes = _active.bookedMinutes > 0 ? _active.bookedMinutes : 60;
    final msgCtrl = TextEditingController(
      text: 'Alternative time for ${_active.skillTitle}',
    );

    List<String> timeOpts() {
      if (skill != null && hasSkillAvailabilityConstraints(skill)) {
        final opts = buildSkillTimeOptionsForDate(skill, bookDate);
        if (opts.isNotEmpty) return opts;
      }
      return buildHalfHourSlots('08:00', '20:00');
    }

    List<String> dateOpts() {
      if (skill != null && hasSkillAvailabilityConstraints(skill)) {
        return buildSkillDateOptions(skill, 'en', bookingHorizonDays)
            .map((e) => e.value)
            .toList();
      }
      return [];
    }

    final dates0 = dateOpts();
    if (dates0.isNotEmpty && !dates0.contains(bookDate)) {
      bookDate = dates0.first;
    }

    final ok = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setModal) {
            final slots = timeOpts();
            final effTime = slots.contains(bookTime) ? bookTime : slots.first;
            final dates = dateOpts();
            final within = skill == null ||
                isWithinSkillAvailability(skill, bookDate, effTime);
            final bottom = MediaQuery.of(ctx).viewInsets.bottom;
            return Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 8,
                bottom: 16 + bottom,
              ),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Propose new time',
                      style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w800),
                    ),
                    if (dates.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      DropdownButtonFormField<String>(
                        decoration: const InputDecoration(
                          labelText: 'Date',
                          border: OutlineInputBorder(),
                        ),
                        value: dates.contains(bookDate) ? bookDate : dates.first,
                        items: dates
                            .map((d) => DropdownMenuItem(value: d, child: Text(d)))
                            .toList(),
                        onChanged: (v) {
                          if (v != null) setModal(() => bookDate = v);
                        },
                      ),
                    ] else ...[
                      ListTile(
                        title: const Text('Date'),
                        subtitle: Text(bookDate),
                        trailing: const Icon(Icons.calendar_today_rounded),
                        onTap: () async {
                          final parts = bookDate.split('-').map(int.parse).toList();
                          final initial = DateTime(parts[0], parts[1], parts[2]);
                          final picked = await showDatePicker(
                            context: ctx,
                            initialDate: initial,
                            firstDate: DateTime.now(),
                            lastDate: DateTime.now().add(const Duration(days: 365)),
                          );
                          if (picked != null) {
                            setModal(() {
                              bookDate =
                                  '${picked.year}-${picked.month.toString().padLeft(2, "0")}-${picked.day.toString().padLeft(2, "0")}';
                            });
                          }
                        },
                      ),
                    ],
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      decoration: const InputDecoration(
                        labelText: 'Time',
                        border: OutlineInputBorder(),
                      ),
                      value: effTime,
                      items: slots
                          .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                          .toList(),
                      onChanged: (v) {
                        if (v != null) setModal(() => bookTime = v);
                      },
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<int>(
                      decoration: const InputDecoration(
                        labelText: 'Minutes',
                        border: OutlineInputBorder(),
                      ),
                      value: [30, 45, 60, 90, 120].contains(bookMinutes)
                          ? bookMinutes
                          : 60,
                      items: const [30, 45, 60, 90, 120]
                          .map(
                            (m) => DropdownMenuItem(value: m, child: Text('$m')),
                          )
                          .toList(),
                      onChanged: (v) {
                        if (v != null) setModal(() => bookMinutes = v);
                      },
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: msgCtrl,
                      maxLines: 3,
                      decoration: const InputDecoration(
                        labelText: 'Message',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    if (!within)
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(
                          'Outside skill availability window.',
                          style: TextStyle(color: Theme.of(ctx).colorScheme.error),
                        ),
                      ),
                    const SizedBox(height: 16),
                    FilledButton(
                      onPressed: !within
                          ? null
                          : () {
                              bookTime = effTime;
                              Navigator.pop(ctx, true);
                            },
                      child: const Text('Send counter-offer'),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
    final msg = msgCtrl.text.trim();
    msgCtrl.dispose();
    if (ok != true) return;

    final scheduledStartAt = localDateTimeToUtcIso(bookDate, bookTime);
    final myId = _myId;
    if (myId == null) return;
    try {
      final ex = _active;
      final isRejected = normalizeExchangeStatus(ex.status) == 'REJECTED';
      final ownerCounter =
          isRejected && sameUserId(ex.ownerId, myId);
      final requesterCounter = isRejected &&
          ex.pendingFromOwner &&
          isRequesterSkillBookingSide(ex, myId);
      if (ownerCounter) {
        await createCounterOffer(
          token: t,
          requestId: ex.id,
          message: msg,
          bookedMinutes: bookMinutes,
          scheduledStartAt: scheduledStartAt,
        );
      } else if (requesterCounter) {
        await createRequesterCounterOffer(
          token: t,
          requestId: ex.id,
          message: msg,
          bookedMinutes: bookMinutes,
          scheduledStartAt: scheduledStartAt,
        );
      } else {
        await createExchangeRequest(
          token: t,
          skillId: ex.skillId,
          message: msg,
          bookedMinutes: bookMinutes,
          scheduledStartAt: scheduledStartAt,
        );
      }
      await _refresh();
    } on ApiException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
      }
    }
  }

  Future<void> _saveMeeting() async {
    final t = widget.appState.token;
    if (t == null) return;
    try {
      await updateExchangeSessionMeeting(
        token: t,
        exchangeId: _active.id,
        meetingUrl: _meetingUrlCtrl.text,
      );
      await _refresh();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Meeting link saved')),
        );
      }
    } on ApiException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
      }
    }
  }

  Future<void> _ackRequester() async {
    final t = widget.appState.token;
    if (t == null) return;
    try {
      await acknowledgeRequesterAttendance(t, _active.id);
      await _refresh();
    } on ApiException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
      }
    }
  }

  Future<void> _ackOwner() async {
    final t = widget.appState.token;
    if (t == null) return;
    try {
      await acknowledgeOwnerAttendance(t, _active.id);
      await _refresh();
    } on ApiException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
      }
    }
  }

  Future<void> _leaveReview() async {
    final t = widget.appState.token;
    if (t == null) return;
    var rating = 5;
    final commentCtrl = TextEditingController();
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setD) {
            return AlertDialog(
            title: const Text('Rate this session'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(5, (i) {
                    final v = i + 1;
                    return IconButton(
                      onPressed: () => setD(() => rating = v),
                      icon: Icon(
                        v <= rating ? Icons.star_rounded : Icons.star_border_rounded,
                        color: Colors.amber,
                        size: 32,
                      ),
                    );
                  }),
                ),
                TextField(
                  controller: commentCtrl,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Comment (optional)',
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
              FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Submit')),
            ],
          );
        },
      );
    },
    );
    final c = commentCtrl.text.trim();
    commentCtrl.dispose();
    if (ok != true) return;
    try {
      await createReview(
        token: t,
        exchangeRequestId: _active.id,
        rating: rating,
        comment: c.isEmpty ? null : c,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Thank you for your review')),
        );
      }
    } on ApiException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
      }
    }
  }

  Future<void> _toggleBlock() async {
    final t = widget.appState.token;
    final oid = _row?.otherUserId;
    if (t == null || oid == null || _blockBusy) return;
    setState(() => _blockBusy = true);
    try {
      final lower = oid.toLowerCase();
      final blocked = _blocks?.blockedUserIds.contains(lower) ?? false;
      if (blocked) {
        final s = await unblockUser(t, oid);
        if (mounted) setState(() => _blocks = s);
      } else {
        final s = await blockUser(t, oid);
        if (mounted) setState(() => _blocks = s);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e')));
      }
    } finally {
      if (mounted) setState(() => _blockBusy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    if (_row == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: Text('Conversation not found')),
      );
    }
    final r = _row!;
    final ui = toUiStatus(_active, _myId);
    final canCancel = canCancelExchange(_active, _myId);
    final isOwner = sameUserId(_active.ownerId, _myId);
    final isRequester = sameUserId(_active.requesterId, _myId);
    final blocked =
        _blocks?.blockedUserIds.contains(r.otherUserId.toLowerCase()) ?? false;

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(r.otherName, maxLines: 1, overflow: TextOverflow.ellipsis),
            if (r.exchanges.length > 1)
              Text(
                '${r.exchanges.length} requests',
                style: TextStyle(
                  fontSize: 11,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.65),
                ),
              ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Profile',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => PublicProfileScreen(
                    appState: widget.appState,
                    userId: r.otherUserId,
                  ),
                ),
              );
            },
            icon: const Icon(Icons.person_outline_rounded),
          ),
          if (_blockBusy)
            const Padding(
              padding: EdgeInsets.all(12),
              child: SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            )
          else
            TextButton(
              onPressed: _toggleBlock,
              child: Text(blocked ? 'Unblock' : 'Block'),
            ),
        ],
      ),
      body: Column(
        children: [
          if (_loading)
            const LinearProgressIndicator(minHeight: 2),
          if (r.exchanges.length > 1)
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
              child: DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: 'Active request',
                  border: OutlineInputBorder(),
                  isDense: true,
                ),
                value: _active.id,
                items: r.exchanges
                    .map(
                      (e) => DropdownMenuItem(
                        value: e.id,
                        child: Text(
                          '${e.skillTitle} · ${e.status}',
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    )
                    .toList(),
                onChanged: (v) {
                  if (v != null) {
                    setState(() {
                      _activeExchangeId = v;
                      _meetingUrlCtrl.text =
                          _active.sessionMeetingUrl?.trim() ?? '';
                    });
                    _buildTimeline();
                  }
                },
              ),
            ),
          if (_error != null)
            Padding(
              padding: const EdgeInsets.all(8),
              child: Text(_error!, style: TextStyle(color: theme.colorScheme.error)),
            ),
          _buildActionBanner(
            ui,
            canCancel,
            isOwner,
            isRequester,
            theme,
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async {
                await _refresh();
                await _buildTimeline();
              },
              child: ListView.builder(
                padding: const EdgeInsets.all(12),
                itemCount: _timeline.length,
                itemBuilder: (context, i) {
                  final it = _timeline[i];
                  if (it.isOffer) {
                    return Card(
                      color: theme.colorScheme.secondaryContainer.withValues(alpha: 0.35),
                      child: ListTile(
                        title: Text(it.title),
                        subtitle: Text('${it.body}\n${it.offerStatus ?? ""}'),
                        isThreeLine: true,
                      ),
                    );
                  }
                  final mine = it.isMine;
                  return Align(
                    alignment: mine ? Alignment.centerRight : Alignment.centerLeft,
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.all(12),
                      constraints: BoxConstraints(
                        maxWidth: MediaQuery.of(context).size.width * 0.82,
                      ),
                      decoration: BoxDecoration(
                        color: mine
                            ? theme.colorScheme.primaryContainer
                            : theme.colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            it.title,
                            style: GoogleFonts.inter(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(it.body, style: GoogleFonts.inter(fontSize: 14)),
                          const SizedBox(height: 4),
                          Text(
                            it.timeLabel,
                            style: GoogleFonts.inter(
                              fontSize: 10,
                              color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          if (normalizeExchangeStatus(_active.status) == 'ACCEPTED') ...[
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
              child: TextField(
                controller: _meetingUrlCtrl,
                decoration: InputDecoration(
                  labelText: 'Meeting URL (Zoom, Meet…)',
                  border: const OutlineInputBorder(),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.save_outlined),
                    onPressed: _saveMeeting,
                  ),
                ),
              ),
            ),
          ],
          if (_composerOn)
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _composer,
                        minLines: 1,
                        maxLines: 4,
                        decoration: const InputDecoration(
                          hintText: 'Message…',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    IconButton.filled(
                      onPressed: _sending ? null : _send,
                      icon: _sending
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.send_rounded),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildActionBanner(
    String ui,
    bool canCancel,
    bool isOwner,
    bool isRequester,
    ThemeData theme,
  ) {
    if (ui == 'pending-incoming') {
      return Material(
        color: theme.colorScheme.primaryContainer.withValues(alpha: 0.4),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                _active.pendingFromOwner
                    ? 'The instructor proposed a new time slot.'
                    : '${_row!.otherName} wants to connect.',
                style: GoogleFonts.inter(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  FilledButton(onPressed: _accept, child: const Text('Accept')),
                  OutlinedButton(onPressed: _reject, child: const Text('Decline')),
                  OutlinedButton(
                    onPressed: _rejectAndCounter,
                    child: const Text('Decline & propose time'),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    }
    if (ui == 'pending-outgoing') {
      return Material(
        color: Colors.amber.withValues(alpha: 0.15),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Waiting for ${_row!.otherName} to respond.',
                style: GoogleFonts.inter(),
              ),
              if (canCancel &&
                  normalizeExchangeStatus(_active.status) == 'PENDING') ...[
                const SizedBox(height: 8),
                OutlinedButton(onPressed: _cancel, child: const Text('Cancel request')),
              ],
            ],
          ),
        ),
      );
    }
    if (ui == 'rejected') {
      return Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'This request was declined. You can send a new proposal.',
              style: GoogleFonts.inter(color: theme.colorScheme.onSurfaceVariant),
            ),
            const SizedBox(height: 8),
            OutlinedButton(
              onPressed: _openBookingCounterSheet,
              child: const Text('Send new proposal'),
            ),
          ],
        ),
      );
    }
    if (ui == 'accepted') {
      return Padding(
        padding: const EdgeInsets.all(8),
        child: Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            if (canCancel)
              OutlinedButton(
                onPressed: _cancel,
                child: const Text('Cancel session'),
              ),
            if (isRequester && (_active.requesterAttendanceAckAt == null))
              FilledButton.tonal(
                onPressed: _ackRequester,
                child: const Text('I started (learner)'),
              ),
            if (isOwner && (_active.ownerAttendanceAckAt == null))
              FilledButton.tonal(
                onPressed: _ackOwner,
                child: const Text('I started (instructor)'),
              ),
          ],
        ),
      );
    }
    if (ui == 'completed') {
      return Padding(
        padding: const EdgeInsets.all(8),
        child: OutlinedButton.icon(
          onPressed: _leaveReview,
          icon: const Icon(Icons.rate_review_outlined),
          label: const Text('Leave a review'),
        ),
      );
    }
    return const SizedBox.shrink();
  }
}

class _TimelineItem {
  _TimelineItem({
    required this.id,
    required this.isOffer,
    required this.isMine,
    required this.title,
    required this.body,
    required this.timeLabel,
    required this.sortMs,
    this.offerStatus,
  });

  final String id;
  final bool isOffer;
  final bool isMine;
  final String title;
  final String body;
  final String timeLabel;
  final int sortMs;
  final String? offerStatus;
}
