import '../api/exchange_api.dart';

String normalizeExchangeStatus(String? status) =>
    (status ?? '').trim().toUpperCase();

bool isPendingExchangeStatus(String? status) =>
    normalizeExchangeStatus(status) == 'PENDING';

bool isMessageEnabledStatus(String? status) {
  final st = normalizeExchangeStatus(status);
  return st == 'ACCEPTED' ||
      st == 'REJECTED' ||
      st == 'CANCELLED' ||
      st == 'COMPLETED';
}

bool sameUserId(String? a, String? b) {
  if (a == null || b == null) return false;
  return a.toLowerCase() == b.toLowerCase();
}

String getOtherUserId(ExchangeRequestDto ex, String? myId) {
  return sameUserId(ex.requesterId, myId) ? ex.ownerId : ex.requesterId;
}

bool isPendingOutgoingForMe(ExchangeRequestDto ex, String? myId) {
  if (ex.pendingFromOwner) {
    return sameUserId(ex.ownerId, myId);
  }
  return sameUserId(ex.requesterId, myId);
}

bool isRequesterSkillBookingSide(ExchangeRequestDto ex, String? myId) {
  if (myId == null) return false;
  if (sameUserId(ex.requesterId, myId)) return true;
  final st = normalizeExchangeStatus(ex.status);
  if (ex.pendingFromOwner &&
      (st == 'PENDING' || st == 'REJECTED') &&
      !sameUserId(ex.ownerId, myId)) {
    return true;
  }
  return false;
}

bool isInitialMessageFromMe(ExchangeRequestDto ex, String? myId) {
  if (normalizeExchangeStatus(ex.status) == 'PENDING' && ex.pendingFromOwner) {
    return sameUserId(ex.ownerId, myId);
  }
  return sameUserId(ex.requesterId, myId);
}

/// Web `toUiStatus` — liste / aksiyon çubuğu için.
String toUiStatus(ExchangeRequestDto ex, String? myId) {
  final st = normalizeExchangeStatus(ex.status);
  if (st == 'CANCELLED') return 'cancelled';
  if (st == 'ACCEPTED') return 'accepted';
  if (st == 'REJECTED') return 'rejected';
  if (st == 'COMPLETED') return 'completed';
  if (st == 'PENDING') {
    if (myId == null) return 'pending-outgoing';
    return isPendingOutgoingForMe(ex, myId)
        ? 'pending-outgoing'
        : 'pending-incoming';
  }
  return 'completed';
}

bool canCancelExchange(ExchangeRequestDto ex, String? myId) {
  if (myId == null) return false;
  final st = normalizeExchangeStatus(ex.status);
  if (st == 'PENDING' && sameUserId(ex.requesterId, myId)) return true;
  if (st == 'ACCEPTED') {
    if (!sameUserId(ex.requesterId, myId) && !sameUserId(ex.ownerId, myId)) {
      return false;
    }
    if (ex.scheduledStartAt == null || ex.scheduledStartAt!.isEmpty) {
      return true;
    }
    final t = DateTime.tryParse(ex.scheduledStartAt!);
    if (t == null) return true;
    return DateTime.now().millisecondsSinceEpoch < t.millisecondsSinceEpoch;
  }
  return false;
}

bool composerAllowsSend(ExchangeRequestDto ex) {
  return isMessageEnabledStatus(ex.status) ||
      (isPendingExchangeStatus(ex.status) &&
          (ex.pendingFromOwner || ex.inquiryOnly));
}

class ConversationRow {
  ConversationRow({
    required this.otherUserId,
    required this.otherName,
    required this.exchanges,
    required this.lastPreview,
    required this.sortTime,
    required this.listUiStatus,
  });

  final String otherUserId;
  final String otherName;
  final List<ExchangeRequestDto> exchanges;
  final String lastPreview;
  final int sortTime;
  final String listUiStatus;
}

List<ConversationRow> mergeExchanges(
  List<ExchangeRequestDto> sent,
  List<ExchangeRequestDto> received,
  String? myId,
) {
  final map = <String, ExchangeRequestDto>{};
  for (final e in sent) {
    map[e.id] = e;
  }
  for (final e in received) {
    map[e.id] = e;
  }
  final byOther = <String, List<ExchangeRequestDto>>{};
  for (final ex in map.values) {
    final oid = getOtherUserId(ex, myId);
    byOther.putIfAbsent(oid, () => []).add(ex);
  }
  final rows = <ConversationRow>[];
  for (final entry in byOther.entries) {
    final oid = entry.key;
    final exs = List<ExchangeRequestDto>.from(entry.value);
    exs.sort(
      (a, b) => b.createdAt.compareTo(a.createdAt),
    );
    final latest = exs.first;
    final otherName = sameUserId(latest.requesterId, myId)
        ? latest.ownerName
        : latest.requesterName;
    final sortTime = exs
        .map((e) => DateTime.tryParse(e.createdAt)?.millisecondsSinceEpoch ?? 0)
        .reduce((a, b) => a > b ? a : b);
    var last = latest.message;
    if (last.length > 100) last = '${last.substring(0, 100)}…';
    rows.add(
      ConversationRow(
        otherUserId: oid,
        otherName: otherName,
        exchanges: exs,
        lastPreview: last,
        sortTime: sortTime,
        listUiStatus: toUiStatus(latest, myId),
      ),
    );
  }
  rows.sort((a, b) => b.sortTime.compareTo(a.sortTime));
  return rows;
}

ExchangeRequestDto? findExchangeInRows(
  List<ConversationRow> rows,
  String exchangeId,
) {
  final id = exchangeId.toLowerCase();
  for (final r in rows) {
    for (final e in r.exchanges) {
      if (e.id.toLowerCase() == id) return e;
    }
  }
  return null;
}
