import 'package:flutter/material.dart';

class LegalL10n {
  LegalL10n._(this._tr);
  final bool _tr;

  static LegalL10n of(BuildContext context) {
    final code = Localizations.localeOf(context).languageCode.toLowerCase();
    return LegalL10n._(code.startsWith('tr'));
  }

  /// Ayarlar dili (`AppState.localeOverride`) ile uyum için.
  static LegalL10n forTr(bool tr) => LegalL10n._(tr);

  String _e(String en, String tr) => _tr ? tr : en;

  String get screenTitle => _e('Help & legal', 'Yardım ve yasal');
  String get tocMenu => _e('Sections', 'Bölümler');
  String get howItWorks => _e('How it works', 'Nasıl çalışır');
  String get about => _e('About', 'Hakkında');
  String get faq => _e('FAQ', 'SSS');
  String get community => _e('Community', 'Topluluk');
  String get contact => _e('Contact', 'İletişim');
  String get support => _e('Support', 'Destek');
  String get terms => _e('Terms of service', 'Kullanım şartları');
  String get privacy => _e('Privacy policy', 'Gizlilik politikası');
  String get cancellation => _e('Cancellation policy', 'İptal politikası');
  String get instructorGuide => _e('Instructor guide', 'Eğitmen rehberi');
}
