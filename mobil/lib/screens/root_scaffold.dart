import 'package:flutter/material.dart';

import '../app/app_state.dart';
import '../theme/app_colors.dart';
import 'add_skill_screen.dart';
import 'browse_screen.dart';
import 'dashboard_screen.dart';
import 'messages_screen.dart';
import 'notifications_screen.dart';
import 'past_sessions_screen.dart';
import 'profile_screen.dart';

class RootScaffold extends StatefulWidget {
  const RootScaffold({super.key, required this.appState});

  final AppState appState;

  @override
  State<RootScaffold> createState() => _RootScaffoldState();
}

class _RootScaffoldState extends State<RootScaffold> {
  int _index = 0;

  void _openAddSkill() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => AddSkillScreen(appState: widget.appState),
      ),
    );
  }

  void _openPastSessions() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => PastSessionsScreen(appState: widget.appState),
      ),
    );
  }

  void _openNotifications() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => NotificationsScreen(appState: widget.appState),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: IndexedStack(
        index: _index,
        children: [
          DashboardScreen(
            appState: widget.appState,
            onOpenNotifications: _openNotifications,
            onOpenProfile: () => setState(() => _index = 3),
            onBrowseSkills: () => setState(() => _index = 1),
            onOfferSkill: _openAddSkill,
            onPastSessions: _openPastSessions,
            // Ödeme / kredi satın alma mobilde şimdilik kapalı (payment_screen.dart üstündeki not).
            onBuyCredits: null,
          ),
          BrowseScreen(appState: widget.appState),
          MessagesScreen(appState: widget.appState),
          ProfileScreen(
            appState: widget.appState,
            onOpenMessages: () => setState(() => _index = 2),
          ),
        ],
      ),
      bottomNavigationBar: DecoratedBox(
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkBackground : Theme.of(context).colorScheme.surface,
          border: Border(
            top: BorderSide(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.08)
                  : Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
            ),
          ),
        ),
        child: SafeArea(
          top: false,
          child: NavigationBar(
            selectedIndex: _index,
            backgroundColor: Colors.transparent,
            surfaceTintColor: Colors.transparent,
            shadowColor: Colors.transparent,
            elevation: 0,
            indicatorShape: const StadiumBorder(),
            onDestinationSelected: (i) => setState(() => _index = i),
            destinations: const [
              NavigationDestination(
                icon: Icon(Icons.grid_view_outlined),
                selectedIcon: Icon(Icons.grid_view_rounded),
                label: 'Home',
              ),
              NavigationDestination(
                icon: Icon(Icons.explore_outlined),
                selectedIcon: Icon(Icons.explore_rounded),
                label: 'Browse',
              ),
              NavigationDestination(
                icon: Icon(Icons.chat_bubble_outline_rounded),
                selectedIcon: Icon(Icons.chat_rounded),
                label: 'Messages',
              ),
              NavigationDestination(
                icon: Icon(Icons.person_outline_rounded),
                selectedIcon: Icon(Icons.person_rounded),
                label: 'Profile',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
