import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../app/app_state.dart';
import '../language/auth_l10n.dart';
import '../language/shell_l10n.dart';
import '../theme/app_colors.dart';
import 'browse_screen.dart';

/// Giriş yapmadan keşfet: alt sekmede yalnızca Keşfet tam işlevli; diğerleri giriş ister.
class GuestRootScaffold extends StatefulWidget {
  const GuestRootScaffold({super.key, required this.appState});

  final AppState appState;

  @override
  State<GuestRootScaffold> createState() => _GuestRootScaffoldState();
}

class _GuestRootScaffoldState extends State<GuestRootScaffold> {
  /// Web’deki gibi doğrudan Keşfet (RootScaffold’ta indeks 1).
  int _index = 1;

  void _goToLoginScreen() {
    final nav = Navigator.of(context);
    while (nav.canPop()) {
      nav.pop();
    }
    widget.appState.exitGuestBrowse();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final sh = ShellL10n.of(context);

    return Scaffold(
      body: IndexedStack(
        index: _index,
        children: [
          _GuestAuthGateBody(
            onSignIn: _goToLoginScreen,
          ),
          BrowseScreen(
            appState: widget.appState,
            onRequireAuth: _goToLoginScreen,
            showGuestSignInInHeader: true,
          ),
          _GuestAuthGateBody(
            onSignIn: _goToLoginScreen,
          ),
          _GuestAuthGateBody(
            onSignIn: _goToLoginScreen,
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
            destinations: [
              NavigationDestination(
                icon: const Icon(Icons.grid_view_outlined),
                selectedIcon: const Icon(Icons.grid_view_rounded),
                label: sh.navHome,
              ),
              NavigationDestination(
                icon: const Icon(Icons.explore_outlined),
                selectedIcon: const Icon(Icons.explore_rounded),
                label: sh.navBrowse,
              ),
              NavigationDestination(
                icon: const Icon(Icons.chat_bubble_outline_rounded),
                selectedIcon: const Icon(Icons.chat_rounded),
                label: sh.navMessages,
              ),
              NavigationDestination(
                icon: const Icon(Icons.person_outline_rounded),
                selectedIcon: const Icon(Icons.person_rounded),
                label: sh.navProfile,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _GuestAuthGateBody extends StatelessWidget {
  const _GuestAuthGateBody({
    required this.onSignIn,
  });

  final VoidCallback onSignIn;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final sh = ShellL10n.of(context);
    final a = AuthL10n.of(context);

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 28),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Icon(
              Icons.lock_outline_rounded,
              size: 56,
              color: theme.colorScheme.primary.withValues(alpha: 0.85),
            ),
            const SizedBox(height: 20),
            Text(
              sh.guestNeedSignInTitle,
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                height: 1.2,
                color: theme.colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              sh.guestNeedSignInBody,
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 15,
                height: 1.45,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.62),
              ),
            ),
            const SizedBox(height: 28),
            FilledButton(
              onPressed: onSignIn,
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: theme.colorScheme.primary,
                foregroundColor: theme.colorScheme.onPrimary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: Text(
                a.signIn,
                style: GoogleFonts.inter(fontWeight: FontWeight.w800, fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
