import 'package:flutter/material.dart';

/// Web `profile` + `editProfile` (en/tr) — cihaz dili `tr` ise Türkçe.
class ProfileL10n {
  ProfileL10n._(this._tr);
  final bool _tr;

  static ProfileL10n of(BuildContext context) {
    final code = Localizations.localeOf(context).languageCode.toLowerCase();
    return ProfileL10n._(code.startsWith('tr'));
  }

  String _e(String en, String tr) => _tr ? tr : en;

  String get profileTitle => _e('Profile', 'Profil');
  String get profileHeroSubtitle => _e(
        'Your skills, sessions, and reputation in one place.',
        'Becerilerin, oturumların ve profilin tek yerde.',
      );
  String get shareProfile => _e('Share profile', 'Profili paylaş');
  String get editProfile => _e('Edit Profile', 'Profili düzenle');
  String get shareSuccess => _e('Profile shared.', 'Profil paylaşıldı.');
  String get shareCopied => _e('Profile link copied.', 'Profil bağlantısı kopyalandı.');
  String get shareError => _e('Could not share profile.', 'Profil paylaşılamadı.');
  String get noRatingsYet => _e('No ratings yet', 'Henüz değerlendirme yok');
  String get timeCreditsPrefix => _e('Time credits:', 'Saat kredisi:');
  String get tabTeaching => _e('Teaching', 'Öğretiyorum');
  String get tabLearning => _e('Learning', 'Öğreniyorum');
  String get tabReviews => _e('Reviews', 'Yorumlar');
  String get skillsTeach => _e('Skills I teach', 'Öğrettiğim beceriler');
  String get addNewSkill => _e('Add New Skill', 'Yeni beceri ekle');
  String get emptyTeaching => _e(
        'You have not added any skills yet. Add a skill to show it on your profile.',
        'Henüz beceri eklemediniz. Profilinizde görünmesi için bir beceri ekleyin.',
      );
  String get skillsLearning => _e("Skills I'm Learning", 'Öğrendiğim beceriler');
  String get emptyLearning => _e('No learning activity to show yet.', 'Gösterilecek öğrenme kaydı yok.');
  String get learningInstructor => _e('Instructor', 'Eğitmen');
  String get learningSession => _e('Session', 'Oturum');
  String learningTotalTime(String time) =>
      _e('Total time booked: $time', 'Toplam alınan süre: $time');
  String get learningStatusCompleted => _e('Completed', 'Tamamlandı');
  String get learningStatusAccepted => _e('Confirmed', 'Onaylandı');
  String get viewDetails => _e('View Details', 'Ayrıntılar');
  String get continueLearning => _e('Continue Learning', 'Öğrenmeye devam');
  String get openMessagesHint =>
      _e('Open the Messages tab from the bottom bar.', 'Mesajlar sekmesini alttan açın.');
  String get deleteLearning => _e('Delete', 'Sil');
  String get rated => _e('Rated', 'Değerlendirildi');
  String get rateSession => _e('Rate session', 'Oturumu değerlendir');
  String get studentReviews => _e('Student Reviews', 'Öğrenci yorumları');
  String get fromStudents => _e('From students', 'Öğrencilerden gelen');
  String get ratingsIGave => _e('Ratings I gave', 'Verdiğim değerlendirmeler');
  String get emptyReviews => _e('No reviews yet.', 'Henüz yorum yok.');
  String get emptyReviewsIGave =>
      _e('You have not rated any completed sessions yet.', 'Henüz tamamlanan bir oturumu değerlendirmediniz.');
  String reviewsGivenSummary(int n, String ratingAvg) =>
      _e('$n reviews · avg $ratingAvg ★', '$n değerlendirme · ort. $ratingAvg ★');
  String ratingsSummaryLine(double avg, int count) =>
      _e('${avg.toStringAsFixed(1)} ($count reviews)', '${avg.toStringAsFixed(1)} ($count değerlendirme)');
  String get buyTimeCredits => _e('Buy time credits', 'Saat kredisi satın al');
  String get paymentDisabledMobile => _e(
        'Buying time credits is not available in the mobile app for now. Please use the TimeLink website.',
        'Saat kredisi satın alma mobil uygulamada şimdilik kapalı. Lütfen TimeLink web sitesini kullanın.',
      );
  String get settings => _e('Settings', 'Ayarlar');
  String get logOut => _e('Log out', 'Çıkış yap');
  String get edit => _e('Edit', 'Düzenle');
  String studentsCount(int n) => _e('$n students', '$n öğrenci');
  String get minPerSessionSuffix => _e('min', 'dk');

  String get deleteLearningTitle => _e('Delete this learning item?', 'Bu öğrenme kaydı silinsin mi?');

  String deleteLearningBody(String skillTitle) => _e(
        'Are you sure you want to remove "$skillTitle" from your learning list? This action cannot be undone.',
        '"$skillTitle" kaydını öğrenme listenizden kaldırmak istediğinize emin misiniz? Bu işlem geri alınamaz.',
      );

  String get cancel => _e('Cancel', 'İptal');
  String get yesDelete => _e('Yes, delete', 'Evet, sil');
  String get rateInstructorTitle => _e('Rate your instructor', 'Eğitmeni değerlendir');
  String get tapStarsHint => _e('Tap 1–5 stars', '1–5 yıldız seçin');
  String get commentOptional => _e('Comment (optional)', 'Yorum (isteğe bağlı)');
  String get submitReview => _e('Submit review', 'Gönder');
  String get reviewSaveError => _e('Could not save review.', 'Yorum kaydedilemedi.');

  String memberSinceLine(String formattedDate) =>
      _e('Member since $formattedDate', '$formattedDate tarihinden beri üye');

  String? skillLevelFromApi(String? apiLevel) {
    if (apiLevel == null || apiLevel.trim().isEmpty) return null;
    final t = apiLevel.trim();
    final k = t.length <= 1
        ? t.toUpperCase()
        : '${t.substring(0, 1).toUpperCase()}${t.substring(1).toLowerCase()}';
    if (!_tr) return k;
    const trMap = {
      'Beginner': 'Başlangıç',
      'Intermediate': 'Orta',
      'Advanced': 'İleri',
      'Expert': 'Uzman',
    };
    return trMap[k] ?? k;
  }

  String sessionTypeChip(String raw) {
    final v = raw.toLowerCase().trim();
    if (v == 'online') return _tr ? 'Çevrim içi' : 'Online';
    if (v == 'in-person' || v.contains('person')) return _tr ? 'Yüz yüze' : 'In-Person';
    return raw;
  }

  // --- Edit profile (web editProfile) ---
  String get editProfileTitle => _e('Edit profile', 'Profili düzenle');
  String get editProfileSubtitle => _e('Update your personal information.', 'Kişisel bilgilerinizi güncelleyin.');
  String get saveChanges => _e('Save changes', 'Kaydet');
  String get loading => _e('Loading…', 'Yükleniyor…');
  String get photoPick => _e('Change photo', 'Fotoğraf seç');
  String get photoRemove => _e('Remove photo', 'Fotoğrafı kaldır');
  String get photoTooLarge => _e('File too large. Pick an image up to 4 MB.', 'Dosya çok büyük. En fazla 4 MB seçin.');
  String get photoInvalid => _e('Please pick an image (JPEG, PNG, WebP or GIF).', 'Lütfen bir görsel seçin (JPEG, PNG, WebP veya GIF).');
  String get fullNameLabel => _e('Full name *', 'Ad soyad *');
  String get emailLabel => _e('Email *', 'E-posta *');
  String get bioLabel => _e('Bio', 'Biyografi');
  String get bioHint => _e('Tell others about yourself…', 'Kendinizden bahsedin…');
  String get locationLabel => _e('Location', 'Konum');
  String get locationHint =>
      _e('City or region — pick from list or search', 'Şehir seçin veya arayın');
  String get phoneLabel => _e('Phone', 'Telefon');
  String get languagesLabel => _e('Languages', 'Diller');
  String get languagesHint =>
      _e('Pick from list or search — stored as canonical English names', 'Dil seçin veya arayın');
  String get picklistSearch => _e('Search…', 'Ara…');
  String get picklistEmpty => _e('No results found.', 'Sonuç bulunamadı.');
  String get websiteLabel => _e('Website / portfolio', 'Web sitesi / portföy');
  String get websiteHint => _e('https://yoursite.com', 'https://siteniz.com');
  String get linkedinLabel => _e('LinkedIn', 'LinkedIn');
  String get linkedinHint => _e('linkedin.com/in/username', 'linkedin.com/in/kullanici');
  String get twitterLabel => _e('Twitter / X', 'Twitter / X');
  String get twitterHint => _e('@username', '@kullanici');
  String get saveFailed => _e('Could not save profile.', 'Profil kaydedilemedi.');
}
