import 'package:flutter/material.dart';

/// Web `en.ts` / `tr.ts` `auth` bölümü (mobil için gerekli alt küme).
class AuthL10n {
  AuthL10n._(this._tr);
  final bool _tr;

  static AuthL10n of(BuildContext context) {
    final code = Localizations.localeOf(context).languageCode.toLowerCase();
    return AuthL10n._(code.startsWith('tr'));
  }

  String _e(String en, String tr) => _tr ? tr : en;

  String get loginSubtitle => _e('Sign in to continue', 'Devam etmek için giriş yapın');
  String get orWithEmail => _e('or with email', 'veya e-posta ile');
  String get signIn => _e('Sign in', 'Giriş yap');
  String get email => _e('Email', 'E-posta');
  String get password => _e('Password', 'Şifre');
  String get signUpCta => _e('Create account', 'Hesap oluştur');
  String get forgotPassword => _e('Forgot password?', 'Şifrenizi mi unuttunuz?');
  String get resetWithCode => _e('Reset with email code', 'E-posta kodu ile sıfırla');
  String get alreadyHaveAccount => _e('Already have an account? Sign in', 'Zaten hesabınız var mı? Giriş yapın');
  String get continueWithGoogle => _e('Continue with Google', 'Google ile devam et');
  String googleOAuthWebHint(String origin) => _e(
        'Google blocked sign-in (often “origin_mismatch”). Add this exact origin under OAuth 2.0 Web client → Authorized JavaScript origins:\n$origin\n\nTip: use a fixed port so you only register once, e.g. flutter run -d chrome --web-port=9339',
        'Google girişi engellendi (“origin_mismatch”). OAuth 2.0 Web istemcisi → Yetkili JavaScript kökenleri listesine tam olarak şunu ekleyin:\n$origin\n\nİpucu: Sabit port kullanın (bir kez kayıt): flutter run -d chrome --web-port=9339',
      );
  /// 401 — sunucu yanıt verdi; bağlantı kopuk değil.
  String get loginHint401 => _e(
        'The server responded (not a connection failure). Check email/password for this API, or try the same account on the website.',
        'Sunucu yanıt verdi (bağlantı kopuk değil). Bu API için e-posta/şifreyi kontrol edin veya web sitesinde aynı hesapla deneyin.',
      );
  String get loginHintNetwork => _e(
        'Could not reach the API. Check the API line below and your network.',
        'API\'ye ulaşılamadı. Aşağıdaki adresi ve ağ bağlantınızı kontrol edin.',
      );
  String get serverSleepHint => _e(
        'If the server was asleep, the first sign-in can take 1–2 minutes. Please wait on the loading spinner.',
        'Sunucu uyku modundaysa ilk giriş 1–2 dakika sürebilir. Lütfen yüklenene kadar bekleyin.',
      );

  String get signupTitle => _e('Create your account', 'Hesabınızı oluşturun');
  String get signupSubtitle => _e('Start your skill exchange journey today', 'Beceri takasına bugün başlayın');
  String get fullName => _e('Full name', 'Ad soyad');
  String get confirmPassword => _e('Confirm password', 'Şifre (tekrar)');
  String get termsPrefix => _e('I agree to the', 'Kabul ediyorum:');
  String get terms => _e('Terms of Service', 'Kullanım şartları');
  String get termsAnd => _e('and', 've');
  String get privacy => _e('Privacy Policy', 'Gizlilik politikası');
  String get errorTermsRequired =>
      _e('Please accept the Terms and Privacy Policy.', 'Lütfen şartları ve gizlilik politikasını kabul edin.');
  String get createAccount => _e('Create account', 'Hesap oluştur');
  String get errorPasswordMismatch => _e('Passwords do not match.', 'Şifreler eşleşmiyor.');
  String get errorPasswordShort => _e('Password must be at least 8 characters.', 'Şifre en az 8 karakter olmalıdır.');
  String get errorFailed => _e('Could not create your account. Try again.', 'Hesap oluşturulamadı. Tekrar deneyin.');
  String get verifySentTitle => _e('Enter your verification code', 'Doğrulama kodunu girin');
  String get verifySentBody => _e(
        'We sent a 6-digit code to your email. Enter it below to open your account.',
        'E-postanıza 6 haneli bir kod gönderdik. Hesabınızı açmak için aşağıya yazın.',
      );
  String get verifyMailpitHint => _e(
        'Local Mailpit: open http://localhost:8025 to read the code (not your real inbox).',
        'Yerel Mailpit: kodu okumak için http://localhost:8025 adresini açın (gerçek gelen kutusu değil).',
      );
  String get verifyRealInboxHint => _e(
        'Check your inbox and spam folder. The code may take a few minutes.',
        'Gelen kutunuzu ve spam klasörünü kontrol edin. Kod birkaç dakika sürebilir.',
      );
  String get verifyLogsHint => _e(
        'SMTP may be off — check API logs for the code or configure mail in .env.',
        'SMTP kapalı olabilir — kod için API günlüklerine bakın veya .env ile postayı yapılandırın.',
      );
  String get codeLabel => _e('Verification code', 'Doğrulama kodu');
  String get verifyAccountBtn => _e('Verify and continue', 'Doğrula ve devam et');
  String get resendCodeBtn => _e('Resend code', 'Kodu yeniden gönder');
  String resendCodeWithTimer(String time) =>
      _e('Resend code ($time)', 'Kodu yeniden gönder ($time)');
  String get goToSignIn => _e("I'll sign in later", 'Sonra giriş yapacağım');
  String get errorVerifyCodeShort => _e('Enter the full 6-digit code.', '6 haneli kodu tam girin.');

  String get forgotTitle => _e('Forgot password?', 'Şifrenizi mi unuttunuz?');
  String get forgotTitleSent => _e('Check your email', 'E-postanızı kontrol edin');
  String get forgotSubtitle => _e("We'll email you reset instructions.", 'Size sıfırlama talimatları göndereceğiz.');
  String get forgotSubtitleSent => _e(
        'If an account exists for this address, you will receive an email shortly.',
        'Bu adres için bir hesap varsa kısa süre içinde e-posta alırsınız.',
      );
  String get sendResetLink => _e('Send reset link', 'Sıfırlama bağlantısı gönder');
  String get backSignIn => _e('Back to sign in', 'Girişe dön');
  String get enterEmail => _e('Enter your account email.', 'Hesap e-postanızı girin.');
  String get useDifferentEmail =>
      _e('Use a different email', 'Başka bir e-posta kullan');
  String get openResetWithCode => _e('Have a code from email? Use reset with code', 'E-postadan kodunuz mu var? Kod ile sıfırlamayı kullanın');

  String get resetTitle => _e('Reset password', 'Şifreyi sıfırla');
  String get resetTitleDone => _e('Password reset!', 'Şifre sıfırlandı!');
  String get resetSubtitle => _e('Enter the code from your email and choose a new password.', 'E-postadaki kodu ve yeni şifrenizi girin.');
  String get resetSubtitleDone => _e('You can now sign in with your new password.', 'Artık yeni şifrenizle giriş yapabilirsiniz.');
  String get newPassword => _e('New password', 'Yeni şifre');
  String get confirmNew => _e('Confirm new password', 'Yeni şifre (tekrar)');
  String get resetCodeLabel => _e('Reset code (6 digits)', 'Sıfırlama kodu (6 rakam)');
  String get resetBtn => _e('Reset password', 'Şifreyi sıfırla');
  String get continueSignIn => _e('Continue to sign in', 'Girişe devam et');
  String get pwdMismatch => _e('Passwords do not match.', 'Şifreler eşleşmiyor.');

  String get googleNotConfigured =>
      _e('Google sign-in is not configured on the server (missing client ID).', 'Google girişi sunucuda yapılandırılmamış (istemci kimliği eksik).');
  String get googleNotAvailableDevice => _e(
        'Google sign-in is not available on this device. Try updating the app or use email sign-in.',
        'Google girişi bu cihazda kullanılamıyor. Uygulamayı güncelleyin veya e-posta ile giriş yapın.',
      );
  String get googleNoIdTokenNative => _e(
        'Google did not return an ID token. For Android/iOS, ensure the Web OAuth client ID is set as serverClientId (backend GOOGLE_CLIENT_ID).',
        'Google kimlik jetonu döndürmedi. Android/iOS için Web OAuth istemci kimliğinin serverClientId olarak ayarlandığından emin olun (GOOGLE_CLIENT_ID).',
      );
  String get googleNoIdTokenWebCheck => _e(
        'Google did not return an ID token. Check OAuth web client / authorized JavaScript origins.',
        'Google kimlik jetonu döndürmedi. OAuth web istemcisi ve yetkili JavaScript kökenlerini kontrol edin.',
      );
  String get preparingGoogle => _e('Preparing Google sign-in…', 'Google girişi hazırlanıyor…');
  String get retry => _e('Retry', 'Yeniden dene');
  String get appBrandName => 'Tiempos';

  String get networkErrorGenericTitle => _e(
        'Could not reach the server',
        'Sunucuya ulaşılamadı',
      );
  String get networkErrorPermissionTitle => _e(
        'Network access blocked',
        'Ağ erişimi engellendi',
      );
  String get networkErrorPermissionHint => _e(
        'On macOS, the app needs outgoing network permission (fixed in current build). If you still see this, run from Terminal outside a restricted sandbox. On a physical phone, do not use 127.0.0.1 — use your computer LAN IP (same Wi‑Fi).',
        'macOS’ta uygulamanın dışarı ağa çıkış izni gerekir (güncel sürümde eklendi). Hâlâ oluyorsa kısıtlı ortam yerine Terminal’den çalıştırın. Gerçek telefonda 127.0.0.1 kullanmayın; bilgisayarınızın yerel ağ IP’sini kullanın (aynı Wi‑Fi).',
      );
  String get networkErrorRefusedTitle => _e(
        'Connection refused',
        'Bağlantı reddedildi',
      );
  String get networkErrorRefusedHint => _e(
        'Is the Spring API running on the expected port? Start the backend and try again.',
        'Spring API beklenen portta çalışıyor mu? Backend’i başlatıp tekrar deneyin.',
      );
  String get networkErrorLocalhostTitle => _e(
        'Localhost may be the wrong target',
        'Yerel adres yanlış olabilir',
      );
  String get networkErrorLocalhostHint => _e(
        'On a real device, 127.0.0.1 points to the phone itself. Use your PC LAN IP, or on Android emulator 10.0.2.2 is applied automatically when you use 127.0.0.1.',
        'Gerçek cihazda 127.0.0.1 telefonun kendisidir. Bilgisayarınızın LAN IP’sini kullanın; Android emülatörde 127.0.0.1 otomatik olarak 10.0.2.2’ye çevrilir.',
      );
  String get showTechnicalDetails => _e('Technical details', 'Teknik ayrıntı');
  String get googleConfigureHint => _e(
        'Add GOOGLE_CLIENT_ID to the backend .env or run with --dart-define=GOOGLE_CLIENT_ID=your Web client ID (same as the website).',
        'Google için backend .env içine GOOGLE_CLIENT_ID ekleyin veya web ile aynı Web istemci kimliğini şununla verin: --dart-define=GOOGLE_CLIENT_ID=....apps.googleusercontent.com',
      );
}
