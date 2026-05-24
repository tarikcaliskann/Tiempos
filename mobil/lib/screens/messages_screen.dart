import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../api/exchange_api.dart';
import '../app/app_state.dart';
import '../exchange/exchange_ui_logic.dart';
import 'conversation_thread_screen.dart';

class MessagesScreen extends StatefulWidget {
  const MessagesScreen({super.key, required this.appState});

  final AppState appState;

  @override
  State<MessagesScreen> createState() => _MessagesScreenState();
}

class _MessagesScreenState extends State<MessagesScreen> {
  List<ConversationRow> _rows = [];
  bool _loading = true;
  String? _error;
  final _search = TextEditingController();

  @override
  void initState() {
    super.initState();
    widget.appState.addListener(_onAuth);
    _search.addListener(() => setState(() {}));
    _load();
  }

  @override
  void dispose() {
    widget.appState.removeListener(_onAuth);
    _search.dispose();
    super.dispose();
  }

  void _onAuth() {
    if (widget.appState.token != null) _load();
  }

  Future<void> _load() async {
    final t = widget.appState.token;
    final myId = widget.appState.userId;
    if (t == null || myId == null) return;
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

  List<ConversationRow> _filtered() {
    final q = _search.text.trim().toLowerCase();
    if (q.isEmpty) return _rows;
    return _rows.where((r) {
      if (r.otherName.toLowerCase().contains(q)) return true;
      if (r.lastPreview.toLowerCase().contains(q)) return true;
      return r.exchanges.any(
        (e) =>
            e.skillTitle.toLowerCase().contains(q) ||
            e.message.toLowerCase().contains(q),
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final list = _filtered();

    return RefreshIndicator(
      onRefresh: _load,
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(
          parent: BouncingScrollPhysics(),
        ),
        slivers: [
          SliverAppBar.large(
            title: const Text('Messages'),
            pinned: true,
            backgroundColor: theme.colorScheme.surface,
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            sliver: SliverToBoxAdapter(
              child: TextField(
                controller: _search,
                decoration: InputDecoration(
                  hintText: 'Search conversations…',
                  prefixIcon: const Icon(Icons.search_rounded),
                  filled: true,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
          ),
          if (_loading)
            const SliverFillRemaining(
              hasScrollBody: false,
              child: Center(child: CircularProgressIndicator()),
            )
          else if (_error != null)
            SliverFillRemaining(
              hasScrollBody: false,
              child: Center(child: Text(_error!)),
            )
          else if (list.isEmpty)
            SliverFillRemaining(
              hasScrollBody: false,
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.chat_bubble_outline_rounded,
                      size: 56,
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.25),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No conversations yet.',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Book a skill from Browse — threads are grouped by person.',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.55),
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, i) {
                  final conv = list[i];
                  return ListTile(
                    leading: CircleAvatar(
                      child: Text(
                        conv.otherName.isNotEmpty
                            ? conv.otherName[0].toUpperCase()
                            : '?',
                      ),
                    ),
                    title: Text(
                      conv.otherName,
                      style: GoogleFonts.inter(fontWeight: FontWeight.w600),
                    ),
                    subtitle: Text(
                      conv.lastPreview,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    trailing: Chip(
                      label: Text(
                        conv.listUiStatus,
                        style: const TextStyle(fontSize: 11),
                      ),
                    ),
                    onTap: () async {
                      await Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) => ConversationThreadScreen(
                            appState: widget.appState,
                            initialRow: conv,
                            initialExchangeId: conv.exchanges.first.id,
                          ),
                        ),
                      );
                      if (mounted) _load();
                    },
                  );
                },
                childCount: list.length,
              ),
            ),
        ],
      ),
    );
  }
}
