import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

import '../api/api_exception.dart';
import '../api/auth_api.dart';
import '../app/app_state.dart';
import '../config/app_web_config.dart';
import '../language/auth_l10n.dart';
import '../widgets/app_chrome.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key, required this.appState});

  final AppState appState;

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _confirm = TextEditingController();
  final _code = TextEditingController();

  bool _terms = false;
  bool _loading = false;
  String? _error;

  bool _awaitingVerification = false;
  String? _pendingEmail;
  bool _smtpOut = false;
  bool _smtpLocal = true;

  Timer? _cooldownTimer;
  int _cooldownSec = 0;

  @override
  void dispose() {
    _cooldownTimer?.cancel();
    _name.dispose();
    _email.dispose();
    _password.dispose();
    _confirm.dispose();
    _code.dispose();
    super.dispose();
  }

  void _startCooldown() {
    _cooldownTimer?.cancel();
    setState(() => _cooldownSec = 60);
    _cooldownTimer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) return;
      setState(() {
        if (_cooldownSec <= 1) {
          _cooldownSec = 0;
          t.cancel();
        } else {
          _cooldownSec--;
        }
      });
    });
  }

  String _mmSs(int total) {
    final m = total ~/ 60;
    final s = total % 60;
    return '$m:${s.toString().padLeft(2, '0')}';
  }

  Future<void> _openUrl(String path) async {
    final uri = Uri.parse(AppWebConfig.webPageUrl(path));
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  Future<void> _register(AuthL10n a) async {
    setState(() {
      _error = null;
      _loading = true;
    });
    if (!_terms) {
      setState(() {
        _error = a.errorTermsRequired;
        _loading = false;
      });
      return;
    }
    if (_password.text != _confirm.text) {
      setState(() {
        _error = a.errorPasswordMismatch;
        _loading = false;
      });
      return;
    }
    if (_password.text.length < 8) {
      setState(() {
        _error = a.errorPasswordShort;
        _loading = false;
      });
      return;
    }
    try {
      final created = await registerRequest(
        fullName: _name.text.trim(),
        email: _email.text.trim(),
        password: _password.text,
      );
      if (!mounted) return;
      if (created.id.isEmpty) {
        setState(() {
          _error = a.errorFailed;
          _loading = false;
        });
        return;
      }
      if (created.emailVerificationPending) {
        setState(() {
          _pendingEmail = _email.text.trim().toLowerCase();
          _smtpOut = created.smtpMailDeliveryEnabled;
          _smtpLocal = created.smtpLocalCapture;
          _awaitingVerification = true;
          _loading = false;
        });
        _startCooldown();
        return;
      }
      final login = await loginRequest(
        email: _email.text.trim(),
        password: _password.text,
      );
      await widget.appState.applyLoginResponse(login);
      if (mounted) setState(() => _loading = false);
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

  Future<void> _verify(AuthL10n a) async {
    final email = _pendingEmail ?? _email.text.trim().toLowerCase();
    final code = _code.text.replaceAll(RegExp(r'\D'), '');
    if (code.length < 6) {
      setState(() => _error = a.errorVerifyCodeShort);
      return;
    }
    setState(() {
      _error = null;
      _loading = true;
    });
    try {
      final res = await verifyEmailWithCode(email: email, code: code);
      await widget.appState.applyLoginResponse(res);
      if (mounted) setState(() => _loading = false);
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

  Future<void> _resend() async {
    final email = _pendingEmail ?? _email.text.trim().toLowerCase();
    if (email.isEmpty || _cooldownSec > 0) return;
    setState(() => _loading = true);
    try {
      await resendVerificationEmail(email);
    } catch (_) {
      /* sessiz */
    } finally {
      if (mounted) {
        setState(() => _loading = false);
        _startCooldown();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final a = AuthL10n.of(context);
    return Scaffold(
      appBar: AppChrome.gradientAppBar(title: a.signupTitle),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            Text(
              _awaitingVerification ? a.verifySentTitle : a.signupTitle,
              style: GoogleFonts.inter(fontSize: 22, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 8),
            Text(
              _awaitingVerification ? a.verifySentBody : a.signupSubtitle,
              style: GoogleFonts.inter(
                fontSize: 14,
                height: 1.4,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.65),
              ),
            ),
            if (_awaitingVerification) ...[
              const SizedBox(height: 12),
              Text(
                _smtpLocal && !_smtpOut ? a.verifyMailpitHint : (_smtpOut ? a.verifyRealInboxHint : a.verifyLogsHint),
                style: GoogleFonts.inter(
                  fontSize: 12,
                  height: 1.35,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.55),
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _code,
                keyboardType: TextInputType.number,
                maxLength: 6,
                decoration: InputDecoration(
                  labelText: a.codeLabel,
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
            ] else ...[
              const SizedBox(height: 20),
              TextField(
                controller: _name,
                textCapitalization: TextCapitalization.words,
                decoration: InputDecoration(
                  labelText: a.fullName,
                  border: const OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 14),
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
                controller: _password,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: a.password,
                  border: const OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: _confirm,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: a.confirmPassword,
                  border: const OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Checkbox(
                    value: _terms,
                    onChanged: (v) => setState(() => _terms = v ?? false),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 10),
                      child: Wrap(
                        crossAxisAlignment: WrapCrossAlignment.center,
                        spacing: 0,
                        runSpacing: 4,
                        children: [
                          Text('${a.termsPrefix} ', style: GoogleFonts.inter(fontSize: 13)),
                          TextButton(
                            style: TextButton.styleFrom(
                              padding: const EdgeInsets.symmetric(horizontal: 4),
                              minimumSize: Size.zero,
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                            onPressed: () => _openUrl('/terms'),
                            child: Text(a.terms, style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600)),
                          ),
                          Text(' ${a.termsAnd} ', style: GoogleFonts.inter(fontSize: 13)),
                          TextButton(
                            style: TextButton.styleFrom(
                              padding: const EdgeInsets.symmetric(horizontal: 4),
                              minimumSize: Size.zero,
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                            onPressed: () => _openUrl('/privacy'),
                            child: Text(a.privacy, style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600)),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
            if (_error != null) ...[
              const SizedBox(height: 8),
              Text(_error!, style: TextStyle(color: theme.colorScheme.error, fontSize: 13)),
            ],
            const SizedBox(height: 20),
            if (_awaitingVerification) ...[
              FilledButton(
                onPressed: _loading ? null : () => _verify(a),
                child: _loading
                    ? const SizedBox(
                        height: 22,
                        width: 22,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(a.verifyAccountBtn),
              ),
              const SizedBox(height: 10),
              OutlinedButton(
                onPressed: _loading || _cooldownSec > 0 ? null : _resend,
                child: Text(
                  _cooldownSec > 0 ? a.resendCodeWithTimer(_mmSs(_cooldownSec)) : a.resendCodeBtn,
                ),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(a.goToSignIn),
              ),
            ] else ...[
              FilledButton(
                onPressed: _loading ? null : () => _register(a),
                child: _loading
                    ? const SizedBox(
                        height: 22,
                        width: 22,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(a.createAccount),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(a.alreadyHaveAccount),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
