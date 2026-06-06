import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../api/api_exception.dart';
import '../api/auth_api.dart';
import '../language/auth_l10n.dart';
import '../widgets/app_chrome.dart';
import '../widgets/gradient_stat_card.dart';
import '../widgets/tiempos_web_logo.dart';

class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({super.key});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final _email = TextEditingController();
  final _code = TextEditingController();
  final _password = TextEditingController();
  final _confirm = TextEditingController();
  bool _loading = false;
  bool _done = false;
  String? _error;
  bool _showPw = false;
  bool _showPw2 = false;

  @override
  void dispose() {
    _email.dispose();
    _code.dispose();
    _password.dispose();
    _confirm.dispose();
    super.dispose();
  }

  Future<void> _submit(AuthL10n a) async {
    setState(() {
      _error = null;
      _loading = true;
    });
    if (_password.text.length < 8) {
      setState(() {
        _error = a.errorPasswordShort;
        _loading = false;
      });
      return;
    }
    if (_password.text != _confirm.text) {
      setState(() {
        _error = a.pwdMismatch;
        _loading = false;
      });
      return;
    }
    try {
      await resetPasswordRequest(
        email: _email.text.trim(),
        token: _code.text.trim(),
        newPassword: _password.text,
      );
      if (!mounted) return;
      setState(() {
        _done = true;
        _loading = false;
        _error = null;
      });
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.message;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = '$e';
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final a = AuthL10n.of(context);
    final loc = MaterialLocalizations.of(context);

    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: AppChrome.authScreenBackdrop(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(4, 8, 8, 0),
                child: Row(
                  children: [
                    SizedBox(
                      width: 48,
                      height: 48,
                      child: IconButton(
                        padding: EdgeInsets.zero,
                        icon: const Icon(
                          Icons.arrow_back_rounded,
                          color: Colors.white,
                        ),
                        tooltip: loc.backButtonTooltip,
                        onPressed: () => Navigator.of(context).maybePop(),
                      ),
                    ),
                    const Spacer(),
                    const SizedBox(width: 48),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  const TiemposWebLogo(height: 64),
                  const SizedBox(height: 16),
                  Text(
                    _done ? a.resetTitleDone : a.resetTitle,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.inter(
                      fontSize: 26,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      height: 1.2,
                      letterSpacing: -0.4,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    _done ? a.resetSubtitleDone : a.resetSubtitle,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.inter(
                      fontSize: 15,
                      height: 1.45,
                      color: Colors.white.withValues(alpha: 0.92),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            Expanded(
              child: AppChrome.authFormSheetPanel(
                theme: theme,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (!_done) ...[
                      TextField(
                        controller: _email,
                        keyboardType: TextInputType.emailAddress,
                        autocorrect: false,
                        decoration: InputDecoration(
                          labelText: a.email,
                          filled: true,
                        ),
                      ),
                      const SizedBox(height: 14),
                      TextField(
                        controller: _code,
                        keyboardType: TextInputType.number,
                        maxLength: 6,
                        decoration: InputDecoration(
                          labelText: a.resetCodeLabel,
                          counterText: '',
                          filled: true,
                        ),
                        onChanged: (v) {
                          final d = v.replaceAll(RegExp(r'\D'), '');
                          if (d != v) {
                            _code.value = TextEditingValue(
                              text: d.length > 6 ? d.substring(0, 6) : d,
                              selection: TextSelection.collapsed(
                                offset: (d.length > 6 ? 6 : d.length),
                              ),
                            );
                          }
                        },
                      ),
                      const SizedBox(height: 14),
                      TextField(
                        controller: _password,
                        obscureText: !_showPw,
                        decoration: InputDecoration(
                          labelText: a.newPassword,
                          filled: true,
                          suffixIcon: IconButton(
                            icon: Icon(
                              _showPw
                                  ? Icons.visibility_off_outlined
                                  : Icons.visibility_outlined,
                            ),
                            onPressed: () => setState(() => _showPw = !_showPw),
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),
                      TextField(
                        controller: _confirm,
                        obscureText: !_showPw2,
                        decoration: InputDecoration(
                          labelText: a.confirmNew,
                          filled: true,
                          suffixIcon: IconButton(
                            icon: Icon(
                              _showPw2
                                  ? Icons.visibility_off_outlined
                                  : Icons.visibility_outlined,
                            ),
                            onPressed: () =>
                                setState(() => _showPw2 = !_showPw2),
                          ),
                        ),
                      ),
                    ] else ...[
                      Icon(
                        Icons.check_circle_outline_rounded,
                        size: 48,
                        color: theme.colorScheme.primary.withValues(alpha: 0.9),
                      ),
                    ],
                    if (_error != null) ...[
                      const SizedBox(height: 12),
                      Text(
                        _error!,
                        style: TextStyle(
                          color: theme.colorScheme.error,
                          fontSize: 13,
                        ),
                      ),
                    ],
                    if (!_done) ...[
                      const SizedBox(height: 20),
                      GradientCtaButton(
                        label: a.resetBtn,
                        icon: Icons.lock_reset_rounded,
                        busy: _loading,
                        onPressed: _loading ? null : () => _submit(a),
                      ),
                    ] else ...[
                      const SizedBox(height: 24),
                      GradientCtaButton(
                        label: a.continueSignIn,
                        icon: Icons.login_rounded,
                        onPressed: () {
                          Navigator.of(
                            context,
                          ).popUntil((route) => route.isFirst);
                        },
                      ),
                    ],
                    const SizedBox(height: 16),
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: Text(a.backSignIn),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
