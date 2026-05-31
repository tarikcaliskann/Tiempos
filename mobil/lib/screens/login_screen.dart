import 'dart:async';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../api/api_exception.dart';
import '../api/auth_api.dart';
import '../app/app_state.dart';
import '../auth/google_sign_in_render_button.dart';
import '../language/auth_l10n.dart';
import '../util/auth_network_messages.dart';
import '../widgets/app_chrome.dart';
import '../widgets/gradient_stat_card.dart';
import '../widgets/tiempos_web_logo.dart';
import 'forgot_password_screen.dart';
import 'signup_screen.dart';

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
  String? _loginErrorHint;
  String? _errorTechnical;

  String? _googleInitClientId;

  /// Mobil / masaüstü: Google Web client id (sunucu veya --dart-define).
  bool _googleClientResolved = false;
  String _googleClientId = '';

  /// Web: GIS button + [authenticationEvents] (authenticate() is unsupported on web).
  StreamSubscription<GoogleSignInAuthenticationEvent>? _googleAuthSub;
  bool _googleWebSetupInProgress = false;
  bool _googleWebReady = false;
  String? _googleWebSetupError;
  /// Web: [fetchGoogleAuthConfig] tamamlandı (boş client, hata veya GIS hazır).
  bool _googleWebConfigResolved = false;

  @override
  void initState() {
    super.initState();
    if (kIsWeb) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        unawaited(_setupGoogleWebIfNeeded());
      });
    } else {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        unawaited(_prefetchNativeGoogleClient());
      });
    }
  }

  Future<void> _prefetchNativeGoogleClient() async {
    try {
      final id = await resolveGoogleOAuthClientId();
      if (!mounted) return;
      setState(() {
        _googleClientId = id;
        _googleClientResolved = true;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _googleClientId = '';
        _googleClientResolved = true;
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
      _googleWebConfigResolved = false;
    });
    try {
      final clientId = await resolveGoogleOAuthClientId();
      if (!mounted) return;
      if (clientId.isEmpty) {
        setState(() {
          _googleWebSetupError = null;
          _googleWebReady = false;
          _googleWebSetupInProgress = false;
          _googleWebConfigResolved = true;
        });
        return;
      }
      await GoogleSignIn.instance.initialize(
        clientId: clientId,
        serverClientId: null,
      );
      _googleInitClientId = clientId;

      _googleAuthSub ??= GoogleSignIn.instance.authenticationEvents.listen(
        _onGoogleAuthEvent,
        onError: (Object e, StackTrace _) {
          if (!mounted) return;
          if (e is GoogleSignInException && _suppressGoogleSignInException(e)) {
            return;
          }
          final l = AuthL10n.of(context);
          setState(() {
            _error = e is GoogleSignInException
                ? _googleSignInMessageForUi(e, l)
                : '$e';
          });
        },
      );

      unawaited(GoogleSignIn.instance.attemptLightweightAuthentication());

      if (!mounted) return;
      setState(() {
        _googleWebReady = true;
        _googleWebSetupInProgress = false;
        _googleWebConfigResolved = true;
      });
    } catch (e) {
      if (!mounted) return;
      final raw = '$e';
      final lower = raw.toLowerCase();
      final l = AuthL10n.of(context);
      final msg = (kIsWeb &&
              (lower.contains('failed to fetch') ||
                  lower.contains('clientexception')))
          ? '${l.googleConfigFetchFailedHint}\n\n$raw'
          : raw;
      setState(() {
        _googleWebSetupError = msg;
        _googleWebSetupInProgress = false;
        _googleWebConfigResolved = true;
      });
    }
  }

  bool _suppressGoogleSignInException(GoogleSignInException e) {
    return e.code == GoogleSignInExceptionCode.canceled ||
        e.code == GoogleSignInExceptionCode.interrupted;
  }

  String _googleSignInMessageForUi(GoogleSignInException e, AuthL10n l) {
    final raw = '${e.description ?? ''} ${e.toString()}'.toLowerCase();
    final likelyOAuthConfig = raw.contains('origin') ||
        raw.contains('mismatch') ||
        raw.contains('access_denied') ||
        raw.contains('policy') ||
        raw.contains('400');
    if (kIsWeb && likelyOAuthConfig) {
      return l.googleOAuthWebHint(Uri.base.origin);
    }
    if (kIsWeb) {
      final d = e.description?.trim();
      if (d != null && d.isNotEmpty) return d;
      return e.toString();
    }
    return e.description?.trim().isNotEmpty == true ? e.description!.trim() : e.toString();
  }

  Future<void> _onGoogleAuthEvent(GoogleSignInAuthenticationEvent event) async {
    switch (event) {
      case GoogleSignInAuthenticationEventSignIn(:final user):
        final idToken = user.authentication.idToken;
        if (idToken == null || idToken.isEmpty) {
          if (mounted) {
            setState(() {
              _error = kIsWeb
                  ? AuthL10n.of(context).googleOAuthWebHint(Uri.base.origin)
                  : AuthL10n.of(context).googleNoIdTokenWebCheck;
            });
          }
          return;
        }
        if (!mounted) return;
        setState(() {
          _loading = true;
          _error = null;
          _loginErrorHint = null;
          _errorTechnical = null;
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
    final a = AuthL10n.of(context);
    setState(() {
      _error = null;
      _loginErrorHint = null;
      _errorTechnical = null;
      _loading = true;
    });
    try {
      await widget.appState.login(
        _email.text.trim(),
        _password.text,
      );
    } on ApiException catch (e) {
      if (e.statusCode == 0 && e.message.startsWith('Network error:')) {
        final parts = humanizeAuthNetworkError(e.message, a);
        setState(() {
          _error = parts.summary;
          _loginErrorHint = parts.hint;
          _errorTechnical = parts.technical;
        });
      } else {
        final em = e.message;
        final low = em.toLowerCase();
        setState(() {
          _error = em;
          if (e.statusCode == 401) {
            _loginErrorHint = a.loginHint401;
          } else if (e.statusCode == 0) {
            _loginErrorHint = kIsWeb &&
                    (low.contains('failed to fetch') ||
                        low.contains('clientexception'))
                ? a.googleConfigFetchFailedHint
                : a.loginHintNetwork;
            _errorTechnical = null;
          } else {
            _loginErrorHint = null;
            _errorTechnical = null;
          }
        });
      }
    } catch (e) {
      final raw = '$e';
      final parts = humanizeAuthNetworkError(raw, a);
      setState(() {
        _error = parts.summary;
        _loginErrorHint = parts.hint;
        _errorTechnical = parts.technical;
      });
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _googleSignInMobile() async {
    setState(() {
      _error = null;
      _loginErrorHint = null;
      _errorTechnical = null;
      _loading = true;
    });
    try {
      final clientId = _googleClientResolved
          ? _googleClientId
          : await resolveGoogleOAuthClientId();
      if (!mounted) return;
      if (!_googleClientResolved) {
        setState(() {
          _googleClientId = clientId;
          _googleClientResolved = true;
        });
      }
      if (clientId.isEmpty) {
        return;
      }
      await _ensureGoogleInitialized(clientId);

      if (!GoogleSignIn.instance.supportsAuthenticate()) {
        setState(() {
          _error = AuthL10n.of(context).googleNotAvailableDevice;
        });
        return;
      }

      final account = await GoogleSignIn.instance.authenticate(
        scopeHint: const ['email', 'profile'],
      );
      final idToken = account.authentication.idToken;
      if (idToken == null || idToken.isEmpty) {
        setState(() {
          _error = AuthL10n.of(context).googleNoIdTokenNative;
        });
        return;
      }

      final res = await socialLoginGoogle(idToken: idToken);
      await widget.appState.applyLoginResponse(res);
    } on GoogleSignInException catch (e) {
      if (_suppressGoogleSignInException(e)) {
        return;
      }
      if (!mounted) return;
      setState(() => _error = _googleSignInMessageForUi(e, AuthL10n.of(context)));
    } on ApiException catch (e) {
      setState(() => _error = e.message);
    } catch (e) {
      setState(() => _error = '$e');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Widget _buildGoogleEntry(ThemeData theme, AuthL10n a) {
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
              a.preparingGoogle,
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
                        _googleWebConfigResolved = false;
                      });
                      unawaited(_setupGoogleWebIfNeeded());
                    },
              child: Text(
                a.retry,
                style: GoogleFonts.inter(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        );
      }
      if (_googleWebReady) {
        return Align(
          alignment: Alignment.center,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: googleSignInGisButton(),
          ),
        );
      }
      if (!_googleWebConfigResolved) {
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
              a.preparingGoogle,
              style: GoogleFonts.inter(
                fontSize: 14,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
              ),
            ),
          ],
        );
      }
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            a.googleWebMissingClientHint,
            style: GoogleFonts.inter(
              fontSize: 13,
              height: 1.4,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.72),
            ),
          ),
          const SizedBox(height: 14),
          OutlinedButton.icon(
            onPressed: _loading
                ? null
                : () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(a.googleConfigureHint)),
                    );
                  },
            icon: const _GoogleMark(),
            label: Text(
              a.continueWithGoogle,
              style: GoogleFonts.inter(
                fontWeight: FontWeight.w600,
                fontSize: 15,
              ),
            ),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 10),
              minimumSize: const Size.fromHeight(52),
              foregroundColor: theme.colorScheme.onSurface.withValues(alpha: 0.75),
              side: BorderSide(
                color: theme.colorScheme.outline.withValues(alpha: 0.4),
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.center,
            child: TextButton(
              onPressed: _loading
                  ? null
                  : () {
                      setState(() {
                        _googleWebReady = false;
                        _googleWebSetupError = null;
                        _googleWebConfigResolved = false;
                      });
                      unawaited(_setupGoogleWebIfNeeded());
                    },
              child: Text(
                a.retry,
                style: GoogleFonts.inter(fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      );
    }

    if (!_googleClientResolved) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 22,
              height: 22,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: theme.colorScheme.primary.withValues(alpha: 0.85),
              ),
            ),
            const SizedBox(width: 12),
            Text(
              a.preparingGoogle,
              style: GoogleFonts.inter(
                fontSize: 14,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.65),
              ),
            ),
          ],
        ),
      );
    }
    if (_googleClientId.isEmpty) {
      return OutlinedButton.icon(
        onPressed: _loading
            ? null
            : () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(a.googleConfigureHint)),
                );
              },
        icon: const _GoogleMark(),
        label: Text(
          a.continueWithGoogle,
          style: GoogleFonts.inter(
            fontWeight: FontWeight.w600,
            fontSize: 15,
          ),
        ),
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 10),
          minimumSize: const Size.fromHeight(52),
          foregroundColor: theme.colorScheme.onSurface.withValues(alpha: 0.75),
          side: BorderSide(
            color: theme.colorScheme.outline.withValues(alpha: 0.4),
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      );
    }

    return OutlinedButton.icon(
      onPressed: _loading ? null : _googleSignInMobile,
      icon: const _GoogleMark(),
      label: Text(
        a.continueWithGoogle,
        style: GoogleFonts.inter(
          fontWeight: FontWeight.w600,
          fontSize: 15,
        ),
      ),
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 10),
        minimumSize: const Size.fromHeight(52),
        foregroundColor: theme.colorScheme.onSurface,
        side: BorderSide(
          color: theme.colorScheme.outline.withValues(alpha: 0.45),
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final a = AuthL10n.of(context);
    final lowerTech = _errorTechnical?.toLowerCase() ?? '';
    final lowerErr = _error?.toLowerCase() ?? '';
    final looksLikeNetwork = lowerTech.contains('socket') ||
        lowerTech.contains('failed host lookup') ||
        lowerTech.contains('connection refused') ||
        lowerErr.contains('network') ||
        lowerErr.contains('ulaşılamadı') ||
        lowerErr.contains('ağ erişimi');
    final errorIcon =
        looksLikeNetwork ? Icons.wifi_off_rounded : Icons.error_outline_rounded;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: AppChrome.authScreenBackdrop(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 20, 24, 28),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Center(child: TiemposWebLogo(height: 72)),
                    const SizedBox(height: 18),
                    Text(
                      a.appBrandName,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.inter(
                        fontSize: 32,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        height: 1.05,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      a.loginSubtitle,
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
            ),
            Expanded(
              child: Align(
                alignment: Alignment.topCenter,
                child: Transform.translate(
                  offset: const Offset(0, -10),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 400),
                      child: AppChrome.webStyleAuthCard(
                        theme: theme,
                        child: SafeArea(
                          top: false,
                          child: SingleChildScrollView(
                            padding: const EdgeInsets.fromLTRB(20, 22, 20, 28),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                _buildGoogleEntry(theme, a),
                                const SizedBox(height: 26),
                                Row(
                                  children: [
                                    Expanded(
                                      child: Divider(
                                        color: theme.colorScheme.outline
                                            .withValues(alpha: 0.32),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 14,
                                      ),
                                      child: Text(
                                        a.orWithEmail,
                                        style: GoogleFonts.inter(
                                          fontSize: 12,
                                          color: theme.colorScheme.onSurface
                                              .withValues(alpha: 0.42),
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      child: Divider(
                                        color: theme.colorScheme.outline
                                            .withValues(alpha: 0.32),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 26),
                                TextField(
                                  controller: _email,
                                  keyboardType: TextInputType.emailAddress,
                                  autocorrect: false,
                                  decoration: InputDecoration(
                                    labelText: a.email,
                                    filled: true,
                                  ),
                                ),
                                const SizedBox(height: 18),
                                TextField(
                                  controller: _password,
                                  obscureText: true,
                                  decoration: InputDecoration(
                                    labelText: a.password,
                                    filled: true,
                                  ),
                                  onSubmitted: (_) =>
                                      _loading ? null : _submit(),
                                ),
                                const SizedBox(height: 14),
                                Wrap(
                                  alignment: WrapAlignment.center,
                                  spacing: 2,
                                  runSpacing: 6,
                                  children: [
                                    TextButton(
                                      onPressed: _loading
                                          ? null
                                          : () {
                                              Navigator.of(context).push(
                                                MaterialPageRoute<void>(
                                                  builder: (_) => SignupScreen(
                                                    appState: widget.appState,
                                                  ),
                                                ),
                                              );
                                            },
                                      child: Text(
                                        a.signUpCta,
                                        style: GoogleFonts.inter(
                                          fontSize: 13,
                                        ),
                                      ),
                                    ),
                                    TextButton(
                                      onPressed: _loading
                                          ? null
                                          : () {
                                              Navigator.of(context).push(
                                                MaterialPageRoute<void>(
                                                  builder: (_) =>
                                                      const ForgotPasswordScreen(),
                                                ),
                                              );
                                            },
                                      child: Text(
                                        a.forgotPassword,
                                        style: GoogleFonts.inter(
                                          fontSize: 13,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                if (_error != null) ...[
                                  const SizedBox(height: 18),
                                  DecoratedBox(
                                    decoration: BoxDecoration(
                                      color: theme.colorScheme.errorContainer
                                          .withValues(alpha: 0.35),
                                      borderRadius: BorderRadius.circular(14),
                                      border: Border.all(
                                        color: theme.colorScheme.error
                                            .withValues(alpha: 0.22),
                                      ),
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.fromLTRB(
                                        14,
                                        12,
                                        14,
                                        10,
                                      ),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.stretch,
                                        children: [
                                          Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Icon(
                                                errorIcon,
                                                size: 22,
                                                color: theme.colorScheme.error,
                                              ),
                                              const SizedBox(width: 10),
                                              Expanded(
                                                child: Text(
                                                  _error!,
                                                  style: GoogleFonts.inter(
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.w600,
                                                    height: 1.35,
                                                    color: theme
                                                        .colorScheme.onErrorContainer,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                          if (_loginErrorHint != null) ...[
                                            const SizedBox(height: 8),
                                            Text(
                                              _loginErrorHint!,
                                              style: GoogleFonts.inter(
                                                fontSize: 12.5,
                                                height: 1.45,
                                                color: theme
                                                    .colorScheme.onSurface
                                                    .withValues(alpha: 0.72),
                                              ),
                                            ),
                                          ],
                                          if (_errorTechnical != null &&
                                              _errorTechnical != _error) ...[
                                            Theme(
                                              data: theme.copyWith(
                                                dividerColor: Colors.transparent,
                                                splashColor: Colors.transparent,
                                              ),
                                              child: ExpansionTile(
                                                tilePadding: EdgeInsets.zero,
                                                childrenPadding:
                                                    const EdgeInsets.only(
                                                  bottom: 4,
                                                ),
                                                title: Text(
                                                  a.showTechnicalDetails,
                                                  style: GoogleFonts.inter(
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.w600,
                                                    color: theme
                                                        .colorScheme.primary,
                                                  ),
                                                ),
                                                children: [
                                                  SelectableText(
                                                    _errorTechnical!,
                                                    style: GoogleFonts.inter(
                                                      fontSize: 11,
                                                      height: 1.35,
                                                      color: theme.colorScheme
                                                          .onSurface
                                                          .withValues(
                                                        alpha: 0.55,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                                const SizedBox(height: 26),
                                GradientCtaButton(
                                  label: a.signIn,
                                  icon: Icons.login_rounded,
                                  busy: _loading,
                                  onPressed: _loading ? null : _submit,
                                ),
                                const SizedBox(height: 12),
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
