import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../api/auth_api.dart';
import '../language/auth_l10n.dart';
import '../widgets/app_chrome.dart';
import '../widgets/gradient_stat_card.dart';
import '../widgets/tiempos_web_logo.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _email = TextEditingController();
  bool _loading = false;
  bool _sent = false;

  @override
  void dispose() {
    _email.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() => _loading = true);
    try {
      await forgotPasswordRequest(_email.text.trim());
    } catch (_) {
      /* Web ile aynı: başarısızlıkta da e-posta varlığını sızdırmayız */
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
          _sent = true;
        });
      }
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
                padding: const EdgeInsets.fromLTRB(4, 8, 8, 12),
                child: Row(
                  children: [
                    SizedBox(
                      width: 48,
                      height: 48,
                      child: IconButton(
                        padding: EdgeInsets.zero,
                        icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
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
                    _sent ? a.forgotTitleSent : a.forgotTitle,
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
                    _sent ? a.forgotSubtitleSent : a.forgotSubtitle,
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
              child: Align(
                alignment: Alignment.topCenter,
                child: Transform.translate(
                  offset: const Offset(0, -6),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 440),
                      child: AppChrome.webStyleAuthCard(
                        theme: theme,
                        child: SafeArea(
                          top: false,
                          child: SingleChildScrollView(
                            padding: const EdgeInsets.fromLTRB(22, 24, 22, 28),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                if (!_sent) ...[
                                  TextField(
                                    controller: _email,
                                    keyboardType: TextInputType.emailAddress,
                                    autocorrect: false,
                                    onChanged: (_) => setState(() {}),
                                    decoration: InputDecoration(
                                      labelText: a.email,
                                      helperText: a.enterEmail,
                                      filled: true,
                                    ),
                                  ),
                                  const SizedBox(height: 22),
                                  GradientCtaButton(
                                    label: a.sendResetLink,
                                    icon: Icons.mark_email_unread_outlined,
                                    busy: _loading,
                                    onPressed: _loading || _email.text.trim().isEmpty
                                        ? null
                                        : _submit,
                                  ),
                                ] else ...[
                                  Icon(
                                    Icons.mark_email_read_outlined,
                                    size: 44,
                                    color: theme.colorScheme.primary.withValues(alpha: 0.85),
                                  ),
                                  const SizedBox(height: 20),
                                  OutlinedButton(
                                    onPressed: () => setState(() {
                                      _sent = false;
                                      _email.clear();
                                    }),
                                    child: Text(
                                      a.useDifferentEmail,
                                      style: GoogleFonts.inter(fontWeight: FontWeight.w600),
                                    ),
                                  ),
                                ],
                                const SizedBox(height: 22),
                                TextButton(
                                  onPressed: () => Navigator.of(context).pop(),
                                  child: Text(
                                    a.backSignIn,
                                    style: GoogleFonts.inter(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 15,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
