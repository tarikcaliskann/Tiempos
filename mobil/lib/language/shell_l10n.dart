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

  // —— Navigation (root) ——
  String get navHome => _e('Home', 'Ana sayfa');
  String get navBrowse => _e('Browse', 'Keşfet');
  String get navMessages => _e('Messages', 'Mesajlar');
  String get navProfile => _e('Profile', 'Profil');

  // —— Browse ——
  String get browseTitle => _e('Explore Skills', 'Becerileri keşfet');
  String get browseSubtitle =>
      _e('Discover skills from the Tiempos community', 'Tiempos topluluğundan becerileri keşfedin');
  String get browseSearchHint =>
      _e('Search skills, instructors, categories…', 'Beceri, eğitmen veya kategori ara…');
  String get browseSortBy => _e('Sort by', 'Sırala');
  String get browseNewest => _e('Newest', 'En yeni');
  String get browseSortTitle => _e('A–Z', 'A–Z');
  String get browseEmptyCatalog =>
      _e('No skills are listed yet. Offer one from Home!', 'Henüz listelenen beceri yok. Ana sayfadan bir beceri ekleyin!');
  String get browseEmptySearch => _e('No matches for your search.', 'Aramanızla eşleşen sonuç yok.');
  String get browseOnline => _e('Online', 'Çevrimiçi');
  String get browseInPerson => _e('In-person', 'Yüz yüze');
  String browseMinutesPerSession(int minutes) =>
      _tr ? '$minutes dk / seans' : '$minutes min / session';
  String get browseBookNow => _e('Book now', 'Rezervasyon yap');

  // —— Messages ——
  String get messagesTitle => _e('Messages', 'Mesajlar');
  String get messagesSubtitle => _e('Chats grouped by person', 'Sohbetler kişilere göre gruplandı');
  String get messagesSearchHint => _e('Search conversations…', 'Sohbet ara…');
  String get messagesEmptyTitle => _e('No conversations yet.', 'Henüz sohbet yok.');
  String get messagesEmptyBody => _e(
        'Book a skill from Browse — threads are grouped by person.',
        'Keşfet’ten bir beceri ayırtın — konuşmalar kişiye göre gruplanır.',
      );

  // —— Notifications ——
  String get notificationsTitle => _e('Notifications', 'Bildirimler');
  String get notificationsMarkAllRead => _e('Mark all read', 'Tümünü okundu işaretle');
  String get notificationsEmpty => _e('No notifications yet.', 'Henüz bildirim yok.');

  // —— Past sessions ——
  String get pastSessionsTitle => _e('Sessions & requests', 'Seanslar ve talepler');
  String get pastSessionsEmpty => _e('No session requests yet.', 'Henüz seans talebi yok.');

  // —— Dashboard ——
  String get dashboardGuestFirstName => _e('there', 'arkadaş');
  String dashboardWelcome(String firstName) =>
      _tr ? 'Tekrar hoş geldin, $firstName! 👋' : 'Welcome back, $firstName! 👋';
  String get dashboardSubtitle => _e(
        "Here's what's happening with your learning journey",
        'Öğrenme yolculuğunda neler oluyor',
      );
  String get statHoursBalance => _e('Hours balance', 'Saat bakiyesi');
  String get statSkillsOffered => _e('Skills you offer', 'Verdiğin beceriler');
  String get statRequestsSent => _e('Requests you sent', 'Gönderdiğin talepler');
  String get statRequestsReceived => _e('Requests you received', 'Aldığın talepler');
  String get dashPlaceholderDash => '—';
  String get dashPlaceholderLoading => '…';
  String get upcomingSessions => _e('Upcoming Sessions', 'Yaklaşan seanslar');
  String get bookNew => _e('Book New', 'Yeni rezervasyon');
  String get noUpcomingSessions => _e(
        'No upcoming sessions. Book a skill from Browse when you’re ready.',
        'Yaklaşan seans yok. Hazır olduğunda Keşfet’ten bir beceri ayırtabilirsin.',
      );
  String dashWithPartner(String name) => _tr ? '$name ile' : 'With $name';
  String dashBooked(String duration) => _tr ? 'Rezervasyon: $duration' : 'Booked: $duration';
  String get viewAllSessions => _e('View All Sessions', 'Tüm seansları gör');
  String get quickActions => _e('Quick Actions', 'Hızlı işlemler');
  String get offerNewSkill => _e('Offer a New Skill', 'Yeni beceri sun');
  String get browseSkills => _e('Browse Skills', 'Becerilere göz at');
  String get buyTimeCredits => _e('Buy time credits', 'Zaman kredisi satın al');
  String get viewPastSessions => _e('View Past Sessions', 'Geçmiş seanslar');
  String get learningProgress => _e('Learning Progress', 'Öğrenme ilerlemesi');
  String get noLearningProgressYet =>
      _e('No learning progress to show yet.', 'Gösterilecek öğrenme ilerlemesi henüz yok.');
}
