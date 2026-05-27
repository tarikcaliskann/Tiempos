import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../api/notifications_api.dart';
import '../app/app_state.dart';
import '../theme/app_colors.dart';
import '../widgets/app_chrome.dart';

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
      appBar: AppChrome.gradientAppBar(
        title: 'Notifications',
        actions: [
          TextButton(
            style: TextButton.styleFrom(foregroundColor: Colors.white),
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
                padding: const EdgeInsets.fromLTRB(12, 12, 12, 24),
                itemCount: _items.length,
                separatorBuilder: (context, index) => const SizedBox(height: 10),
                itemBuilder: (context, i) {
                  final n = _items[i];
                  final unread = isNotificationUnread(n);
                  return Material(
                    color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: unread ? 0.55 : 0.35),
                    borderRadius: BorderRadius.circular(14),
                    child: ListTile(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                        side: BorderSide(
                          color: unread
                              ? theme.colorScheme.primary.withValues(alpha: 0.45)
                              : theme.colorScheme.outline.withValues(alpha: 0.15),
                        ),
                      ),
                    title: Text(
                      n.title,
                      style: GoogleFonts.inter(fontWeight: FontWeight.w700),
                    ),
                    subtitle: Text(
                      n.body,
                      style: GoogleFonts.inter(fontSize: 13, height: 1.35),
                    ),
                    trailing: unread
                        ? Icon(Icons.circle, size: 10, color: AppColors.primary)
                        : null,
                    onTap: () => _tap(n),
                  ),
                  );
                },
              ),
      ),
    );
  }
}
