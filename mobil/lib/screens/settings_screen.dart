import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../api/api_exception.dart';
import '../api/user_api.dart';
import '../app/app_state.dart';
import '../language/settings_l10n.dart';
import '../help/help_center_screen.dart';
import '../widgets/app_chrome.dart';

/// Web `SettingsPage` ile aynı: şifre, dil, tema, hesap silme (`user_api`).
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key, required this.appState});

  final AppState appState;

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _currentPw = TextEditingController();
  final _newPw = TextEditingController();
  final _confirmPw = TextEditingController();

  bool _passwordLoading = false;
  String? _passwordError;
  bool _passwordSuccess = false;

  @override
  void dispose() {
    _currentPw.dispose();
    _newPw.dispose();
    _confirmPw.dispose();
    super.dispose();
  }

  String _effectiveLang(BuildContext context) {
    final o = widget.appState.localeOverride?.languageCode;
    if (o != null) {
      return o.toLowerCase().startsWith('tr') ? 'tr' : 'en';
    }
    final d = Localizations.localeOf(context).languageCode.toLowerCase();
    return d.startsWith('tr') ? 'tr' : 'en';
  }

  Future<void> _submitPassword(SettingsL10n s) async {
    final token = widget.appState.token;
    setState(() {
      _passwordSuccess = false;
      _passwordError = null;
    });
    if (_newPw.text.length < 8) {
      setState(() => _passwordError = s.passwordTooShort);
      return;
    }
    if (_newPw.text != _confirmPw.text) {
      setState(() => _passwordError = s.passwordMismatch);
      return;
    }
    if (token == null || token.isEmpty) {
      setState(() => _passwordError = s.passwordMismatch);
      return;
    }
    setState(() => _passwordLoading = true);
    try {
      await changePassword(
        token: token,
        currentPassword: _currentPw.text,
        newPassword: _newPw.text,
      );
      if (!mounted) return;
      setState(() {
        _passwordSuccess = true;
        _currentPw.clear();
        _newPw.clear();
        _confirmPw.clear();
      });
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() => _passwordError = e.message);
    } catch (e) {
      if (!mounted) return;
      setState(() => _passwordError = '$e');
    } finally {
      if (mounted) setState(() => _passwordLoading = false);
    }
  }

  Future<void> _deleteAccount(String token) async {
    await deleteMyAccount(token);
  }

  Future<void> _openDeleteDialog(SettingsL10n s) async {
    var loading = false;
    String? err;

    await showDialog<void>(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text(s.deleteAccountConfirmTitle),
              content: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(s.deleteAccountConfirmBody),
                    if (err != null) ...[
                      const SizedBox(height: 12),
                      Text(
                        err!,
                        style: TextStyle(color: Theme.of(context).colorScheme.error, fontSize: 13),
                      ),
                    ],
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: loading ? null : () => Navigator.pop(ctx),
                  child: Text(s.deleteAccountCancel),
                ),
                FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.error,
                    foregroundColor: Theme.of(context).colorScheme.onError,
                  ),
                  onPressed: loading
                      ? null
                      : () async {
                          setDialogState(() {
                            loading = true;
                            err = null;
                          });
                          final token = widget.appState.token;
                          if (token == null || token.isEmpty) {
                            setDialogState(() {
                              err = s.deleteAccountError;
                              loading = false;
                            });
                            return;
                          }
                          try {
                            await _deleteAccount(token);
                            if (ctx.mounted) Navigator.pop(ctx);
                            await widget.appState.logout();
                          } on ApiException catch (e) {
                            setDialogState(() {
                              err = e.message;
                              loading = false;
                            });
                          } catch (e) {
                            setDialogState(() {
                              err = '$e';
                              loading = false;
                            });
                          }
                        },
                  child: Text(loading ? s.loading : s.deleteAccountConfirmButton),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final s = SettingsL10n.of(context);
    final lang = _effectiveLang(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppChrome.gradientAppBar(title: s.title),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
        children: [
          Text(
            s.subtitle,
            style: GoogleFonts.inter(
              fontSize: 14,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.65),
            ),
          ),
          const SizedBox(height: 20),
          _SettingsCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(s.passwordTitle, style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w700)),
                const SizedBox(height: 6),
                Text(
                  s.passwordDesc,
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _currentPw,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: s.currentPassword,
                    border: const OutlineInputBorder(),
                  ),
                  onChanged: (_) => setState(() {
                    _passwordError = null;
                    _passwordSuccess = false;
                  }),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _newPw,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: s.newPassword,
                    border: const OutlineInputBorder(),
                  ),
                  onChanged: (_) => setState(() {
                    _passwordError = null;
                    _passwordSuccess = false;
                  }),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _confirmPw,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: s.confirmPassword,
                    border: const OutlineInputBorder(),
                  ),
                  onChanged: (_) => setState(() {
                    _passwordError = null;
                    _passwordSuccess = false;
                  }),
                ),
                if (_passwordError != null) ...[
                  const SizedBox(height: 10),
                  Text(_passwordError!, style: TextStyle(color: theme.colorScheme.error, fontSize: 13)),
                ],
                if (_passwordSuccess) ...[
                  const SizedBox(height: 10),
                  Text(
                    s.passwordSuccess,
                    style: TextStyle(color: theme.colorScheme.primary, fontSize: 13, fontWeight: FontWeight.w600),
                  ),
                ],
                const SizedBox(height: 16),
                FilledButton(
                  onPressed: _passwordLoading ? null : () => _submitPassword(s),
                  child: _passwordLoading
                      ? SizedBox(
                          height: 22,
                          width: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: theme.colorScheme.onPrimary,
                          ),
                        )
                      : Text(s.updatePassword),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _SettingsCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(s.languageTitle, style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w700)),
                const SizedBox(height: 6),
                Text(
                  s.languageDesc,
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
                const SizedBox(height: 14),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    _ChoiceChip(
                      label: s.english,
                      selected: lang == 'en',
                      onSelected: () => widget.appState.setAppLanguageCode('en'),
                    ),
                    _ChoiceChip(
                      label: s.turkish,
                      selected: lang == 'tr',
                      onSelected: () => widget.appState.setAppLanguageCode('tr'),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _SettingsCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(s.themeTitle, style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w700)),
                const SizedBox(height: 6),
                Text(
                  s.themeDesc,
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
                const SizedBox(height: 14),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    _ChoiceChip(
                      label: s.themeLight,
                      selected: widget.appState.themeMode == ThemeMode.light,
                      onSelected: () => widget.appState.setThemeMode(ThemeMode.light),
                    ),
                    _ChoiceChip(
                      label: s.themeDark,
                      selected: widget.appState.themeMode == ThemeMode.dark,
                      onSelected: () => widget.appState.setThemeMode(ThemeMode.dark),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _SettingsCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(s.helpLegalTitle, style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w700)),
                const SizedBox(height: 6),
                Text(
                  s.helpLegalDesc,
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
                const SizedBox(height: 14),
                OutlinedButton.icon(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute<void>(builder: (_) => HelpCenterScreen(appState: widget.appState)),
                    );
                  },
                  icon: const Icon(Icons.menu_book_outlined, size: 20),
                  label: Text(s.helpLegalOpen),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _SettingsCard(
            borderColor: theme.colorScheme.error.withValues(alpha: 0.45),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  s.dangerTitle,
                  style: GoogleFonts.inter(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: theme.colorScheme.error,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  s.dangerDesc,
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    color: theme.colorScheme.onSurface.withValues(alpha: isDark ? 0.7 : 0.65),
                  ),
                ),
                const SizedBox(height: 16),
                FilledButton.icon(
                  style: FilledButton.styleFrom(
                    backgroundColor: theme.colorScheme.error,
                    foregroundColor: theme.colorScheme.onError,
                  ),
                  onPressed: () => _openDeleteDialog(s),
                  icon: const Icon(Icons.delete_outline_rounded, size: 20),
                  label: Text(s.deleteAccount),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SettingsCard extends StatelessWidget {
  const _SettingsCard({required this.child, this.borderColor});

  final Widget child;
  final Color? borderColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final border = borderColor ?? theme.colorScheme.outline.withValues(alpha: 0.22);
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(17),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            theme.colorScheme.primary.withValues(alpha: 0.45),
            theme.colorScheme.tertiary.withValues(alpha: 0.35),
          ],
        ),
      ),
      padding: const EdgeInsets.all(1.2),
      child: Material(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: border),
          ),
          child: child,
        ),
      ),
    );
  }
}

class _ChoiceChip extends StatelessWidget {
  const _ChoiceChip({
    required this.label,
    required this.selected,
    required this.onSelected,
  });

  final String label;
  final bool selected;
  final VoidCallback onSelected;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      color: selected
          ? theme.colorScheme.primaryContainer.withValues(alpha: 0.5)
          : theme.colorScheme.surfaceContainerHigh.withValues(alpha: 0.6),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onSelected,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
          child: Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: selected ? theme.colorScheme.primary : theme.colorScheme.onSurface.withValues(alpha: 0.75),
            ),
          ),
        ),
      ),
    );
  }
}
