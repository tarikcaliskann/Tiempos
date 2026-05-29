import 'package:flutter/material.dart';

/// Beceri detayı ve beceri ekleme/düzenleme formu (en/tr). API’ye giden kategori/seviye değerleri İngilizce kalır.
class SkillFlowL10n {
  SkillFlowL10n._(this._tr);
  final bool _tr;

  static SkillFlowL10n of(BuildContext context) {
    final code = Localizations.localeOf(context).languageCode.toLowerCase();
    return SkillFlowL10n._(code.startsWith('tr'));
  }

  String _e(String en, String tr) => _tr ? tr : en;

  String get signInAgainSnack => _e('Please sign in again.', 'Lütfen tekrar giriş yapın.');
  String get noBookableSlots =>
      _e('No bookable slots match this skill’s calendar. Try another day or contact the instructor.',
          'Bu becerinin takvimine uygun müsait slot yok. Başka bir gün deneyin veya eğitmenle iletişime geçin.');
  String get bookSession => _e('Book session', 'Seans ayırt');
  String get dateLabel => _e('Date', 'Tarih');
  String get startTime => _e('Start time', 'Başlangıç saati');
  String get sessionLengthMinutes => _e('Session length (minutes)', 'Seans süresi (dakika)');
  String minutesOption(int m) => _tr ? '$m dakika' : '$m minutes';
  String get messageToInstructor => _e('Message to instructor', 'Eğitmene mesaj');
  String get defaultBookMessage =>
      _e("I'd like to book a session with you.", 'Sizinle bir seans ayırtmak istiyorum.');
  String get outsideAvailability =>
      _e('Selected time is outside this skill’s published availability.', 'Seçilen zaman becerinin yayınlanan uygunluğu dışında.');
  String get sendRequest => _e('Send request', 'Talep gönder');
  String get bookingSentSnack => _e('Booking request sent. Check Messages.', 'Rezervasyon talebi gönderildi. Mesajlar’a bakın.');
  String get skillNotFound => _e('Skill not found.', 'Beceri bulunamadı.');
  String get instructor => _e('Instructor', 'Eğitmen');
  String get bookThisSkill => _e('Book this skill', 'Bu beceriyi ayırt');

  String get offerSkillTitle => _e('Offer a skill', 'Beceri sun');
  String get editSkillTitle => _e('Edit skill', 'Beceriyi düzenle');
  String get skillTitleLabel => _e('Skill title', 'Beceri başlığı');
  String get description => _e('Description', 'Açıklama');
  String get category => _e('Category', 'Kategori');
  String get customCategory => _e('Custom category', 'Özel kategori');
  String get level => _e('Level', 'Seviye');
  String get sessionType => _e('Session type', 'Oturum türü');
  String get online => _e('Online', 'Çevrimiçi');
  String get inPerson => _e('In-person', 'Yüz yüze');
  String get inPersonLocation => _e('In-person location', 'Yüz yüze konum');
  String get availableDays => _e('Available days', 'Müsait günler');
  String get availableFrom => _e('Available from', 'Müsait başlangıç');
  String get availableUntil => _e('Available until', 'Müsait bitiş');
  String get tagsOptional => _e('Tags (optional, comma-separated)', 'Etiketler (isteğe bağlı, virgülle)');
  String get publishSkill => _e('Publish skill', 'Beceriyi yayınla');
  String get saveChanges => _e('Save changes', 'Değişiklikleri kaydet');

  String get errNotSignedIn => _e('Not signed in', 'Oturum açık değil');
  String get errTitleRequired => _e('Title is required', 'Başlık zorunludur');
  String get errSessionType =>
      _e('Select at least one session type (online / in-person)', 'En az bir oturum türü seçin (çevrimiçi / yüz yüze)');
  String get errInPersonLocation =>
      _e('In-person location is required when offering in-person sessions', 'Yüz yüze sunuyorsanız konum zorunludur');
  String get errPickDay => _e('Select at least one available day', 'En az bir müsait gün seçin');
  String get errTimeOrder => _e('Available “until” time must be after “from”', '“Bitiş” saati “başlangıç”tan sonra olmalıdır');
  String get errCustomCategory => _e('Please enter a custom category', 'Lütfen özel kategori girin');

  String categoryLabelForApiValue(String apiValue) {
    const map = {
      'Sports': ('Sports', 'Spor'),
      'Arts': ('Arts', 'Sanat'),
      'Languages': ('Languages', 'Diller'),
      'Programming': ('Programming', 'Programlama'),
      'Music': ('Music', 'Müzik'),
      'Cooking': ('Cooking', 'Mutfak / yemek'),
      'Photography': ('Photography', 'Fotoğrafçılık'),
      'Writing': ('Writing', 'Yazarlık'),
      'Design': ('Design', 'Tasarım'),
      'Other': ('Other', 'Diğer'),
    };
    final m = map[apiValue];
    if (m == null) return apiValue;
    return _tr ? m.$2 : m.$1;
  }

  String levelLabelForApiValue(String apiValue) {
    switch (apiValue) {
      case 'Beginner':
        return _e('Beginner', 'Başlangıç');
      case 'Intermediate':
        return _e('Intermediate', 'Orta');
      case 'Advanced':
        return _e('Advanced', 'İleri');
      default:
        return apiValue;
    }
  }

  /// Pazartesi = 0 … Pazar = 6 (`_dayApi` sırası)
  String dayShort(int index) {
    const en = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    const tr = ['Pzt', 'Sal', 'Çar', 'Per', 'Cum', 'Cmt', 'Paz'];
    if (index < 0 || index >= en.length) return '';
    return _tr ? tr[index] : en[index];
  }
}
