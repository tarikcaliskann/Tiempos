import 'dart:async';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../api/api_exception.dart';
import '../api/auth_api.dart';
import '../app/app_state.dart';
import '../auth/google_sign_in_render_button.dart';
import '../config/api_config.dart';
import '../theme/app_colors.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key, required this.appState});

  final AppState appState;

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _loading = false;
  String? _error;

  String? _googleInitClientId;

  /// Web: GIS button + [authenticationEvents] (authenticate() is unsupported on web).
  StreamSubscription<GoogleSignInAuthenticationEvent>? _googleAuthSub;
  bool _googleWebSetupInProgress = false;
  bool _googleWebReady = false;
  String? _googleWebSetupError;

  @override
  void initState() {
    super.initState();
    if (kIsWeb) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        unawaited(_setupGoogleWebIfNeeded());
      });
    }
  }

  @override
  void dispose() {
    unawaited(_googleAuthSub?.cancel());
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _ensureGoogleInitialized(String clientId) async {
    if (_googleInitClientId == clientId) return;
    // google_sign_in_web: serverClientId must be null (assert in plugin).
    await GoogleSignIn.instance.initialize(
      clientId: kIsWeb ? clientId : null,
      serverClientId: kIsWeb ? null : clientId,
    );
    _googleInitClientId = clientId;
  }

  Future<void> _setupGoogleWebIfNeeded() async {
    if (!kIsWeb || !mounted) return;
    if (_googleWebReady || _googleWebSetupInProgress) return;
    setState(() {
      _googleWebSetupInProgress = true;
      _googleWebSetupError = null;
    });
    try {
      final cfg = await fetchGoogleAuthConfig();
      if (!mounted) return;
      if (cfg.clientId.isEmpty) {
        setState(() {
          _googleWebSetupError =
              'Google sign-in is not configured on the server (missing client ID).';
          _googleWebSetupInProgress = false;
        });
        return;
      }
      await GoogleSignIn.instance.initialize(
        clientId: cfg.clientId,
        serverClientId: null,
      );
      _googleInitClientId = cfg.clientId;

      _googleAuthSub ??= GoogleSignIn.instance.authenticationEvents.listen(
        _onGoogleAuthEvent,
        onError: (Object e, StackTrace _) {
          if (!mounted) return;
          setState(() {
            _error = e is GoogleSignInException
                ? (e.description ?? e.toString())
                : '$e';
          });
        },
      );

      unawaited(GoogleSignIn.instance.attemptLightweightAuthentication());

      if (!mounted) return;
      setState(() {
        _googleWebReady = true;
        _googleWebSetupInProgress = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _googleWebSetupError = '$e';
        _googleWebSetupInProgress = false;
      });
    }
  }

  Future<void> _onGoogleAuthEvent(GoogleSignInAuthenticationEvent event) async {
    switch (event) {
      case GoogleSignInAuthenticationEventSignIn(:final user):
        final idToken = user.authentication.idToken;
        if (idToken == null || idToken.isEmpty) {
          if (mounted) {
            setState(() {
              _error =
                  'Google did not return an ID token. Check OAuth web client / authorized JavaScript origins.';
            });
          }
          return;
        }
        if (!mounted) return;
        setState(() {
          _loading = true;
          _error = null;
        });
        try {
          final res = await socialLoginGoogle(idToken: idToken);
          await widget.appState.applyLoginResponse(res);
        } on ApiException catch (e) {
          if (mounted) setState(() => _error = e.message);
        } catch (e) {
          if (mounted) setState(() => _error = '$e');
        } finally {
          if (mounted) setState(() => _loading = false);
        }
      case GoogleSignInAuthenticationEventSignOut():
        return;
    }
  }

  Future<void> _submit() async {
    setState(() {
      _error = null;
      _loading = true;
    });
    try {
      await widget.appState.login(
        _email.text.trim(),
        _password.text,
      );
    } on ApiException catch (e) {
      setState(() => _error = e.message);
    } catch (e) {
      setState(() => _error = '$e');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _googleSignInMobile() async {
    setState(() {
      _error = null;
      _loading = true;
    });
    try {
      final cfg = await fetchGoogleAuthConfig();
      if (cfg.clientId.isEmpty) {
        setState(() {
          _error =
              'Google sign-in is not configured on the server (missing client ID).';
        });
        return;
      }
      await _ensureGoogleInitialized(cfg.clientId);

      if (!GoogleSignIn.instance.supportsAuthenticate()) {
        setState(() {
          _error =
              'Google sign-in is not available on this device. Try updating the app or use email sign-in.';
        });
        return;
      }

      final account = await GoogleSignIn.instance.authenticate(
        scopeHint: const ['email', 'profile'],
      );
      final idToken = account.authentication.idToken;
      if (idToken == null || idToken.isEmpty) {
        setState(() {
          _error =
              'Google did not return an ID token. For Android/iOS, ensure the Web OAuth client ID is set as serverClientId (backend GOOGLE_CLIENT_ID).';
        });
        return;
      }

      final res = await socialLoginGoogle(idToken: idToken);
      await widget.appState.applyLoginResponse(res);
    } on GoogleSignInException catch (e) {
      if (e.code == GoogleSignInExceptionCode.canceled ||
          e.code == GoogleSignInExceptionCode.interrupted) {
        return;
      }
      setState(() => _error = e.description ?? e.toString());
    } on ApiException catch (e) {
      setState(() => _error = e.message);
    } catch (e) {
      setState(() => _error = '$e');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Widget _buildGoogleEntry(ThemeData theme) {
    if (kIsWeb) {
      if (_googleWebSetupInProgress) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(
              height: 22,
              width: 22,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            const SizedBox(width: 12),
            Text(
              'Preparing Google sign-in…',
              style: GoogleFonts.inter(
                fontSize: 14,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
              ),
            ),
          ],
        );
      }
      if (_googleWebSetupError != null) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              _googleWebSetupError!,
              style: GoogleFonts.inter(
                color: theme.colorScheme.error,
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 12),
            OutlinedButton(
              onPressed: _loading
                  ? null
                  : () {
                      setState(() {
                        _googleWebReady = false;
                        _googleWebSetupError = null;
                      });
                      unawaited(_setupGoogleWebIfNeeded());
                    },
              child: Text(
                'Retry',
                style: GoogleFonts.inter(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        );
      }
      if (!_googleWebReady) {
        return const SizedBox.shrink();
      }
      return Align(
        alignment: Alignment.center,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 400),
          child: googleSignInGisButton(),
        ),
      );
    }

    return OutlinedButton.icon(
      onPressed: _loading ? null : _googleSignInMobile,
      icon: const _GoogleMark(),
      label: Text(
        'Continue with Google',
        style: GoogleFonts.inter(
          fontWeight: FontWeight.w600,
          fontSize: 15,
        ),
      ),
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 14),
        foregroundColor: theme.colorScheme.onSurface,
        side: BorderSide(
          color: theme.colorScheme.outline.withValues(alpha: 0.5),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 400),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 24),
                  Text(
                    'Tiempos',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.inter(
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Sign in to continue',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.inter(
                      fontSize: 15,
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                  const SizedBox(height: 28),
                  _buildGoogleEntry(theme),
                  const SizedBox(height: 22),
                  Row(
                    children: [
                      Expanded(
                        child: Divider(
                          color: theme.colorScheme.outline.withValues(alpha: 0.35),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: Text(
                          'or with email',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            color: theme.colorScheme.onSurface.withValues(alpha: 0.45),
                          ),
                        ),
                      ),
                      Expanded(
                        child: Divider(
                          color: theme.colorScheme.outline.withValues(alpha: 0.35),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 22),
                  TextField(
                    controller: _email,
                    keyboardType: TextInputType.emailAddress,
                    autocorrect: false,
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _password,
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: 'Password',
                      border: OutlineInputBorder(),
                    ),
                    onSubmitted: (_) => _loading ? null : _submit(),
                  ),
                  if (_error != null) ...[
                    const SizedBox(height: 16),
                    Text(
                      _error!,
                      style: GoogleFonts.inter(
                        color: theme.colorScheme.error,
                        fontSize: 13,
                      ),
                    ),
                  ],
                  const SizedBox(height: 24),
                  FilledButton(
                    onPressed: _loading ? null : _submit,
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: AppColors.primary,
                    ),
                    child: _loading
                        ? const SizedBox(
                            height: 22,
                            width: 22,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Text(
                            'Sign in',
                            style: GoogleFonts.inter(
                              fontWeight: FontWeight.w700,
                              fontSize: 15,
                            ),
                          ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'If the server was asleep, the first sign-in can take 1–2 minutes. Please wait on the loading spinner.',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      height: 1.35,
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.45),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'API: ${ApiConfig.baseUrl}',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.35),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _GoogleMark extends StatelessWidget {
  const _GoogleMark();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 22,
      height: 22,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: const Color(0x1A000000)),
      ),
      child: const Text(
        'G',
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w800,
          color: Color(0xFF4285F4),
        ),
      ),
    );
  }
}
