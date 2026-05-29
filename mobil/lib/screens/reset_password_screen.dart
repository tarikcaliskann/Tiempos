import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../api/api_exception.dart';
import '../api/auth_api.dart';
import '../language/auth_l10n.dart';
import '../widgets/app_chrome.dart';

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
    return Scaffold(
      appBar: AppChrome.gradientAppBar(title: a.resetTitle),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            Text(
              _done ? a.resetTitleDone : a.resetTitle,
              style: GoogleFonts.inter(fontSize: 22, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 8),
            Text(
              _done ? a.resetSubtitleDone : a.resetSubtitle,
              style: GoogleFonts.inter(
                fontSize: 14,
                height: 1.4,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.65),
              ),
            ),
            if (!_done) ...[
              const SizedBox(height: 24),
              TextField(
                controller: _email,
                keyboardType: TextInputType.emailAddress,
                autocorrect: false,
                decoration: InputDecoration(
                  labelText: a.email,
                  border: const OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: _code,
                keyboardType: TextInputType.number,
                maxLength: 6,
                decoration: InputDecoration(
                  labelText: a.resetCodeLabel,
                  border: const OutlineInputBorder(),
                  counterText: '',
                ),
                onChanged: (v) {
                  final d = v.replaceAll(RegExp(r'\D'), '');
                  if (d != v) {
                    _code.value = TextEditingValue(
                      text: d.length > 6 ? d.substring(0, 6) : d,
                      selection: TextSelection.collapsed(offset: (d.length > 6 ? 6 : d.length)),
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
                  border: const OutlineInputBorder(),
                  suffixIcon: IconButton(
                    icon: Icon(_showPw ? Icons.visibility_off_outlined : Icons.visibility_outlined),
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
                  border: const OutlineInputBorder(),
                  suffixIcon: IconButton(
                    icon: Icon(_showPw2 ? Icons.visibility_off_outlined : Icons.visibility_outlined),
                    onPressed: () => setState(() => _showPw2 = !_showPw2),
                  ),
                ),
              ),
              if (_error != null) ...[
                const SizedBox(height: 12),
                Text(_error!, style: TextStyle(color: theme.colorScheme.error, fontSize: 13)),
              ],
              const SizedBox(height: 20),
              FilledButton(
                onPressed: _loading ? null : () => _submit(a),
                child: _loading
                    ? const SizedBox(
                        height: 22,
                        width: 22,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(a.resetBtn),
              ),
            ] else ...[
              const SizedBox(height: 24),
              FilledButton(
                onPressed: () {
                  Navigator.of(context).popUntil((route) => route.isFirst);
                },
                child: Text(a.continueSignIn),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
