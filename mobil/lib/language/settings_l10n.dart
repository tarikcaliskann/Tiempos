import 'package:flutter/material.dart';

/// Web `settings` (en/tr) — `MaterialApp.locale` ile uyumlu.
class SettingsL10n {
  SettingsL10n._(this._tr);
  final bool _tr;

  static SettingsL10n of(BuildContext context) {
    final code = Localizations.localeOf(context).languageCode.toLowerCase();
    return SettingsL10n._(code.startsWith('tr'));
  }

  String _e(String en, String tr) => _tr ? tr : en;

  String get title => _e('Settings', 'Ayarlar');
  String get subtitle => _e('Account preferences and security', 'Hesap tercihleri ve güvenlik');
  String get passwordTitle => _e('Change password', 'Şifre değiştir');
  String get passwordDesc =>
      _e('Use a strong password you do not use elsewhere.', 'Başka yerde kullanmadığınız güçlü bir şifre seçin.');
  String get currentPassword => _e('Current password', 'Mevcut şifre');
  String get newPassword => _e('New password', 'Yeni şifre');
  String get confirmPassword => _e('Confirm new password', 'Yeni şifre (tekrar)');
  String get updatePassword => _e('Update password', 'Şifreyi güncelle');
  String get passwordMismatch => _e('New passwords do not match.', 'Yeni şifreler eşleşmiyor.');
  String get passwordTooShort => _e('Password must be at least 8 characters.', 'Şifre en az 8 karakter olmalıdır.');
  String get passwordSuccess => _e('Password updated successfully.', 'Şifre başarıyla güncellendi.');
  String get languageTitle => _e('Language', 'Dil');
  String get languageDesc => _e('Choose the interface language.', 'Arayüz dilini seçin.');
  String get english => _e('English', 'İngilizce');
  String get turkish => _e('Turkish', 'Türkçe');
  String get themeTitle => _e('Appearance', 'Görünüm');
  String get themeDesc => _e('Light or dark theme for the app.', 'Açık veya koyu tema.');
  String get themeLight => _e('Light', 'Açık');
  String get themeDark => _e('Dark', 'Koyu');
  String get helpLegalTitle => _e('Help & legal', 'Yardım ve yasal');
  String get helpLegalDesc => _e(
        'How it works, FAQ, contact form, terms, and policies — all inside the app.',
        'Nasıl çalışır, SSS, iletişim formu, şartlar ve politikalar — hepsi uygulama içinde.',
      );
  String get helpLegalOpen => _e('Open help center', 'Yardım merkezini aç');
  String get dangerTitle => _e('Danger zone', 'Tehlikeli alan');
  String get dangerDesc => _e(
        'Permanently delete your account and all related data (skills, requests, messages, reviews, notifications, transactions). This cannot be undone.',
        'Hesabınızı ve bağlı tüm verileri (beceriler, talepler, mesajlar, değerlendirmeler, bildirimler, işlemler) kalıcı olarak silin.',
      );
  String get deleteAccount => _e('Delete account', 'Hesabı sil');
  String get deleteAccountConfirmTitle => _e('Delete your account?', 'Hesabınız silinsin mi?');
  String get deleteAccountConfirmBody => _e(
        'Your profile, skills, exchanges, messages, reviews, notifications, and time credits history will be removed from our database. Other users may no longer see past exchanges involving you.',
        'Profiliniz, becerileriniz, talepler, mesajlar, değerlendirmeler, bildirimler ve zaman kredisi geçmişiniz veritabanından kaldırılır. Bu işlem geri alınamaz.',
      );
  String get deleteAccountConfirmButton => _e('Yes, delete everything', 'Evet, tamamen sil');
  String get deleteAccountCancel => _e('Cancel', 'Vazgeç');
  String get deleteAccountError => _e('Could not delete your account. Try again.', 'Hesap silinemedi. Tekrar deneyin.');
  String get loading => _e('Loading…', 'Yükleniyor…');
}
