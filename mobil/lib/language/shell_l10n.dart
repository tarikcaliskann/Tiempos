import 'package:flutter/material.dart';

/// Alt sekme, keşfet, mesajlar, ana sayfa gibi ortak arayüz metinleri (en/tr).
/// `MaterialApp.locale` / `Localizations` ile uyumlu.
class ShellL10n {
  ShellL10n._(this._tr);
  final bool _tr;

  static ShellL10n of(BuildContext context) {
    final code = Localizations.localeOf(context).languageCode.toLowerCase();
    return ShellL10n._(code.startsWith('tr'));
  }

  String _e(String en, String tr) => _tr ? tr : en;

  // —— Navigation (root) —— web `nav.dashboard` / `nav.browseSkills`
  String get navHome => _e('Dashboard', 'Panel');
  /// Alt sekme — web `browse.title` kısaltması.
  String get navBrowse => _e('Explore', 'Keşfet');
  String get navMessages => _e('Messages', 'Mesajlar');
  String get navProfile => _e('Profile', 'Profil');

  // —— Browse ——
  String get browseTitle => _e('Explore Skills', 'Becerileri keşfet');
  String get browseSubtitle =>
      _e('Find the perfect skill to learn from our community of experts', 'Uzman topluluğumuzdan öğrenmek için doğru beceriyi bulun');
  String get browseSearchHint =>
      _e('Search for skills, instructors, or categories...', 'Beceri, eğitmen veya kategori ara…');
  String get browseSortBy => _e('Sort by', 'Sırala');
  String get browseNewest => _e('Newest', 'En yeni');
  String get browseSortTitle => _e('A–Z', 'A–Z');
  String get browseEmptyCatalog =>
      _e('No skills are listed yet. Add yours to get started!', 'Henüz listelenen beceri yok. İlk ilanı sen ekle!');
  String get browseEmptySearch => _e('No matches for your search.', 'Aramanızla eşleşen sonuç yok.');
  String get browseOnlyOwnSkills => _e(
        'No other members\' skills to show yet. When others publish skills, they will appear here.',
        'Şu an yalnızca sizin becerileriniz listeleniyor; başkaları ilan verince burada görünecek.',
      );
  String get browseOnline => _e('Online', 'Çevrim içi');
  String get browseInPerson => _e('In-Person', 'Yüz yüze');
  String browseMinutesPerSession(int minutes) =>
      _tr ? 'Oturum: $minutes dk' : '$minutes min / session';
  String get browseBookNow => _e('Book Now', 'Rezervasyon');
  String get browseOwnListing => _e('Your listing', 'Senin ilanın');

  // —— Messages ——
  String get messagesTitle => _e('Messages', 'Mesajlar');
  String get messagesSubtitle => _e('Search conversations...', 'Sohbet ara…');
  String get messagesSearchHint => _e('Search conversations...', 'Sohbet ara…');
  String get messagesEmptyTitle => _e('No conversations yet.', 'Henüz konuşma yok.');
  String get messagesEmptyBody => _e(
        'Book a skill from Browse to start a conversation.',
        'Sohbete başlamak için Keşfet’ten bir beceri ayırtın.',
      );

  // —— Notifications ——
  String get notificationsTitle => _e('Notifications', 'Bildirimler');
  String get notificationsMarkAllRead => _e('Mark all as read', 'Tümünü okundu işaretle');
  String get notificationsEmpty => _e('No notifications yet.', 'Henüz bildirim yok.');

  // —— Past sessions ——
  String get pastSessionsTitle => _e('Session History', 'Oturum geçmişi');
  String get pastSessionsEmpty =>
      _e('No sessions in your history yet.', 'Henüz oturum geçmişin yok.');

  // —— Dashboard ——
  String get dashboardGuestFirstName => _e('there', 'arkadaş');
  String dashboardWelcome(String firstName) =>
      _tr ? 'Tekrar hoş geldin, $firstName! 👋' : 'Welcome back, $firstName! 👋';
  String get dashboardSubtitle => _e(
        "Here's what's happening with your learning journey",
        'Öğrenme yolculuğunda neler oluyor',
      );
  String get statHoursBalance => _e('Hours balance', 'Saat bakiyesi');
  String get statSkillsOffered => _e('Skills you offer', 'Sunduğun beceriler');
  String get statRequestsSent => _e('Requests you sent', 'Gönderdiğin talepler');
  String get statRequestsReceived => _e('Requests you received', 'Aldığın talepler');
  String get dashPlaceholderDash => '—';
  String get dashPlaceholderLoading => '…';
  String get upcomingSessions => _e('Upcoming Sessions', 'Yaklaşan oturumlar');
  String get bookNew => _e('Book New', 'Yeni rezervasyon');
  String get noUpcomingSessions => _e(
        'No upcoming sessions. Book a skill from Browse when you’re ready.',
        'Yaklaşan oturum yok. Hazır olduğunda Keşfet’ten rezervasyon yapabilirsin.',
      );
  String dashWithPartner(String name) => _tr ? '$name ile' : 'With $name';
  String dashBooked(String duration) => _tr ? 'Rezervasyon: $duration' : 'Booked: $duration';
  String get viewAllSessions => _e('View All Sessions', 'Tüm oturumlar');
  String get quickActions => _e('Quick Actions', 'Hızlı işlemler');
  String get offerNewSkill => _e('Offer a New Skill', 'Yeni beceri sun');
  String get browseSkills => _e('Browse Skills', 'Becerilere göz at');
  String get buyTimeCredits => _e('Buy Time Credits', 'Zaman kredisi satın al');
  String get viewPastSessions => _e('View Past Sessions', 'Geçmiş oturumlar');
  String get learningProgress => _e('Learning Progress', 'Öğrenme ilerlemesi');
  String get noLearningProgressYet =>
      _e('No learning progress to show yet.', 'Gösterilecek öğrenme ilerlemesi yok.');
}
