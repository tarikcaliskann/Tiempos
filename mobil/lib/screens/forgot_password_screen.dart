import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../api/auth_api.dart';
import '../language/auth_l10n.dart';
import '../widgets/app_chrome.dart';
import 'reset_password_screen.dart';

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
    return Scaffold(
      appBar: AppChrome.gradientAppBar(title: a.forgotTitle),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            Text(
              _sent ? a.forgotTitleSent : a.forgotTitle,
              style: GoogleFonts.inter(fontSize: 22, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 8),
            Text(
              _sent ? a.forgotSubtitleSent : a.forgotSubtitle,
              style: GoogleFonts.inter(
                fontSize: 14,
                height: 1.4,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.65),
              ),
            ),
            const SizedBox(height: 24),
            if (!_sent) ...[
              TextField(
                controller: _email,
                keyboardType: TextInputType.emailAddress,
                autocorrect: false,
                onChanged: (_) => setState(() {}),
                decoration: InputDecoration(
                  labelText: a.email,
                  border: const OutlineInputBorder(),
                  helperText: a.enterEmail,
                ),
              ),
              const SizedBox(height: 20),
              FilledButton(
                onPressed: _loading || _email.text.trim().isEmpty ? null : _submit,
                child: _loading
                    ? const SizedBox(
                        height: 22,
                        width: 22,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(a.sendResetLink),
              ),
            ] else ...[
              TextButton.icon(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(builder: (_) => const ResetPasswordScreen()),
                  );
                },
                icon: const Icon(Icons.pin_outlined),
                label: Text(a.openResetWithCode),
              ),
              TextButton(
                onPressed: () => setState(() => _sent = false),
                child: Text(a.sendResetLink),
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
    );
  }
}
