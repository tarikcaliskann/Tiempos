import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../api/exchange_api.dart';
import '../app/app_state.dart';
import '../exchange/exchange_ui_logic.dart';
import '../language/conversation_l10n.dart';
import '../language/shell_l10n.dart';
import '../widgets/app_chrome.dart';
import 'conversation_thread_screen.dart';

/// Tüm talepler — konuşma ile aynı birleştirme mantığı.
class PastSessionsScreen extends StatefulWidget {
  const PastSessionsScreen({super.key, required this.appState});

  final AppState appState;

  @override
  State<PastSessionsScreen> createState() => _PastSessionsScreenState();
}

class _PastSessionsScreenState extends State<PastSessionsScreen> {
  List<ConversationRow> _rows = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final t = widget.appState.token;
    final myId = widget.appState.userId;
    if (t == null || myId == null) {
      if (!mounted) return;
      setState(() {
        _rows = [];
        _loading = false;
        _error = null;
      });
      return;
    }
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final sent = await fetchSentExchangeRequests(t);
      final received = await fetchReceivedExchangeRequests(t);
      final rows = mergeExchanges(sent, received, myId);
      if (!mounted) return;
      setState(() {
        _rows = rows;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = '$e';
        _rows = [];
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final sh = ShellL10n.of(context);
    final convL10n = ConversationL10n.of(context);
    return Scaffold(
      appBar: AppChrome.gradientAppBar(title: sh.pastSessionsTitle),
      body: RefreshIndicator(
        onRefresh: _load,
        child: _loading
            ? ListView(
                children: const [
                  SizedBox(height: 120),
                  Center(child: CircularProgressIndicator()),
                ],
              )
            : _error != null
            ? ListView(
                children: [
                  const SizedBox(height: 80),
                  Center(child: Text(_error!)),
                ],
              )
            : _rows.isEmpty
            ? ListView(
                children: [
                  const SizedBox(height: 80),
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Text(
                        sh.pastSessionsEmpty,
                        style: GoogleFonts.inter(
                          fontSize: 15,
                          color: theme.colorScheme.onSurface.withValues(alpha: 0.55),
                        ),
                      ),
                    ),
                  ),
                ],
              )
            : ListView.separated(
                padding: const EdgeInsets.all(12),
                itemCount: _rows.length,
                separatorBuilder: (context, index) => const SizedBox(height: 8),
                itemBuilder: (context, i) {
                  final conv = _rows[i];
                  final latest = conv.exchanges.first;
                  return Card(
                    child: ListTile(
                      title: Text(
                        conv.otherName,
                        style: GoogleFonts.inter(fontWeight: FontWeight.w700),
                      ),
                      subtitle: Text(
                        '${latest.skillTitle}\n${convL10n.apiExchangeStatus(latest.status)} · ${convL10n.bookedMinutesShort(latest.bookedMinutes)}',
                        style: GoogleFonts.inter(fontSize: 12, height: 1.35),
                      ),
                      isThreeLine: true,
                      trailing: const Icon(Icons.chat_outlined),
                      onTap: () async {
                        await Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder: (_) => ConversationThreadScreen(
                              appState: widget.appState,
                              initialRow: conv,
                              initialExchangeId: latest.id,
                            ),
                          ),
                        );
                        if (mounted) _load();
                      },
                    ),
                  );
                },
              ),
      ),
    );
  }
}
