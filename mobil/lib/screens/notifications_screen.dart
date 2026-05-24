import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../api/notifications_api.dart';
import '../app/app_state.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key, required this.appState});

  final AppState appState;

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  List<NotificationDto> _items = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
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
      final list = await fetchNotifications(t);
      if (!mounted) return;
      setState(() {
        _items = list;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = '$e';
        _items = [];
        _loading = false;
      });
    }
  }

  Future<void> _markAllRead() async {
    final t = widget.appState.token;
    if (t == null) return;
    try {
      await markAllNotificationsRead(t);
      await _load();
    } catch (_) {}
  }

  Future<void> _tap(NotificationDto n) async {
    final t = widget.appState.token;
    if (t == null) return;
    if (isNotificationUnread(n)) {
      try {
        await markNotificationRead(t, n.id);
        await _load();
      } catch (_) {}
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        actions: [
          TextButton(
            onPressed: _items.any(isNotificationUnread) ? _markAllRead : null,
            child: const Text('Mark all read'),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _load,
        child: _loading
            ? ListView(
                children: const [
                  SizedBox(height: 100),
                  Center(child: CircularProgressIndicator()),
                ],
              )
            : _error != null
            ? ListView(children: [Center(child: Text(_error!))])
            : _items.isEmpty
            ? ListView(
                children: [
                  const SizedBox(height: 80),
                  Center(
                    child: Text(
                      'No notifications yet.',
                      style: GoogleFonts.inter(
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.55),
                      ),
                    ),
                  ),
                ],
              )
            : ListView.separated(
                padding: const EdgeInsets.all(12),
                itemCount: _items.length,
                separatorBuilder: (context, index) => const Divider(height: 1),
                itemBuilder: (context, i) {
                  final n = _items[i];
                  final unread = isNotificationUnread(n);
                  return ListTile(
                    tileColor: unread
                        ? theme.colorScheme.primaryContainer.withValues(alpha: 0.25)
                        : null,
                    title: Text(
                      n.title,
                      style: GoogleFonts.inter(fontWeight: FontWeight.w700),
                    ),
                    subtitle: Text(
                      n.body,
                      style: GoogleFonts.inter(fontSize: 13, height: 1.35),
                    ),
                    trailing: unread
                        ? const Icon(Icons.circle, size: 10, color: Colors.blueAccent)
                        : null,
                    onTap: () => _tap(n),
                  );
                },
              ),
      ),
    );
  }
}
