# Tiempos — mobil (Flutter)

Web `frontend` ile **aynı Spring API** (`/api/...`) üzerinden çalışan mobil istemci: giriş, token kalıcılığı, dashboard ve yaklaşan oturumlar.

## Gereksinimler

- [Flutter](https://docs.flutter.dev/get-started/install) SDK (projede `sdk: ^3.10.8`)

## Çalıştırma

```bash
cd mobil
flutter pub get
flutter run -d chrome
```

### API adresi

Varsayılan taban URL, web `getApiBaseUrl` ile uyumlu **Render** API:

`https://tiempos-backend-w26e.onrender.com`

**Not (ücretsiz Render):** API bir süre kullanılmadıysa “uyku”dan uyanması **60–120 saniye** sürebilir. İlk girişte bekleyin; uygulama giriş isteği için **3 dakikaya** kadar zaman tanır.

Yerel veya başka bir sunucu için:

```bash
flutter run --dart-define=API_BASE_URL=http://localhost:8080
```

(Sondaki `/` ve `/api` olmamalı; istek yolları zaten `/api/...` ile başlar.)

Profil paylaşımında kullanılan **web uygulaması kökü** (varsayılan `https://www.tiempos.site`, yol `/u/{kullanıcıId}`):

```bash
flutter run --dart-define=WEB_APP_ORIGIN=https://www.tiempos.site
```

### Oturum

İlk açılışta **Sign in** ekranı gelir: **Continue with Google** (`/api/auth/google-config` + `google_sign_in` + `/api/auth/social-login`) veya e-posta / şifre (`/api/auth/login`). Başarılı girişte JWT `shared_preferences` ile saklanır; **Profile → Log out** ile temizlenir (Google oturumu da kapatılmaya çalışılır).

### Google (Flutter Web — `flutter run -d chrome`)

Google Cloud Console’da **Web application** OAuth istemcisinde **Authorized JavaScript origins** listesine Flutter’ın çalıştığı kökü ekleyin, örn. `http://localhost:XXXX` (port `flutter run` çıktısındaki gibi). Aksi halde tarayıcı Google popup’ını engelleyebilir. Backend’deki `GOOGLE_CLIENT_ID` / `app.google.client-id` ile **aynı** Web client ID kullanılmalı (`/api/auth/google-config` bunu döner).

**Not:** `google_sign_in` Web’de `serverClientId` kullanmaz; yalnızca `clientId` ile `initialize` edilir. Android/iOS’ta `idToken` için `serverClientId` olarak aynı Web client ID verilir. Web’de `authenticate()` desteklenmediği için giriş, paketin **GIS `renderButton`** widget’ı + `authenticationEvents` akışı ile yapılır (`lib/auth/google_sign_in_render_button*.dart`).

### Tema

Varsayılan **koyu** (`ThemeMode.dark`). Açık tema için `lib/app/tiempos_app.dart` içinde `themeMode: ThemeMode.system` kullan.

## Kod yapısı

| Yol | Açıklama |
|-----|----------|
| `lib/config/api_config.dart` | `API_BASE_URL` (`--dart-define`) + normalizasyon |
| `lib/config/app_web_config.dart` | `WEB_APP_ORIGIN` — paylaşılan profil URL’si (`…/u/{id}`) |
| `lib/language/profile_l10n.dart` | Profil / düzenle ekranı metinleri (cihaz dili `tr` ise Türkçe) |
| `lib/api/api_client.dart` | `http` + JSON + `Authorization: Bearer` |
| `lib/api/auth_api.dart` | `POST /api/auth/login`, `GET /api/auth/google-config`, `POST /api/auth/social-login` |
| `lib/api/user_api.dart` | `GET/PUT /api/users/me/profile` (createdAt dahil), dashboard, engelleme, public profil |
| `lib/api/notifications_api.dart` | `GET /api/notifications`, okundu işaretleme |
| `lib/api/reviews_api.dart` | Aldığın / verdiğin yorumlar, özet, `POST .../reviews/exchange/{id}` |
| `lib/api/credits_api.dart` | Kredi checkout başlat / tamamla |
| `lib/data/profile_picklists.dart` | Web `profilePicklists.ts` — konum/dil JSON’ları + `mergeLegacyOption` |
| `lib/data/credit_packages.dart` | Web ile aynı paket kimlikleri |
| `lib/api/skills_api.dart` | `GET /api/skills`, `GET /api/skills/{id}`, `GET/POST/PUT /api/skills...` (mine, create, update) |
| `lib/api/exchange_api.dart` | Talepler + mesajlar: sent/received, `POST .../skill/{id}`, thread `GET/POST .../messages` |
| `lib/app/app_state.dart` | Token / kullanıcı + profil adı; tema (`ThemeMode`) ve dil (`localeOverride`, `en`/`tr`) kalıcılığı |
| `lib/screens/login_screen.dart` | E-posta/şifre + **Google** (mobilde düğme; web’de GIS düğmesi) |
| `lib/auth/google_sign_in_render_button.dart` | Web-only GIS düğmesi (koşullu import) |
| `lib/screens/dashboard_screen.dart` | Canlı istatistikler, çekerek yenileme, yaklaşan oturumlar, hızlı aksiyonlar |
| `lib/screens/browse_screen.dart` | `GET /api/skills` keşfet, arama, skill detaya git |
| `lib/screens/skill_detail_screen.dart` | `GET /api/skills/{id}`, rezervasyon `POST /api/exchange-requests/skill/{id}` |
| `lib/screens/add_skill_screen.dart` | Beceri oluştur / düzenle (web formu ile uyumlu payload) |
| `lib/screens/messages_screen.dart` | Birleşik talep listesi → `ConversationThreadScreen` |
| `lib/screens/conversation_thread_screen.dart` | Sohbet + kabul/red/karşı teklif, URL, katılım, yorum, engelle |
| `lib/screens/past_sessions_screen.dart` | Tüm talepler (durum + sohbet) |
| `lib/screens/notifications_screen.dart` | Bildirim listesi |
| `lib/screens/payment_screen.dart` | Ödeme akışı **şimdilik kapalı**; bilgilendirme metni + eski davranışın `//` özeti (tam kod: git). Paket seçimi (`buy_credits_screen`) kaldırıldı. |
| `lib/widgets/searchable_profile_combobox.dart` | Profil düzenle: aranabilir konum/dil seçici (web `SearchableCombobox`) |
| `lib/screens/settings_screen.dart` | Web `SettingsPage`: şifre (`POST .../change-password`), dil/tema (`SharedPreferences`), hesap sil (`POST .../delete`) |
| `lib/screens/edit_profile_screen.dart` | Web `EditProfilePage`: alanlar, picklist’ler veya metin fallback, foto, `PUT /api/users/me/profile` |
| `lib/screens/profile_screen.dart` | Hero (avatar, bio, konum, diller, üyelik tarihi), paylaş / düzenle, Teaching–Learning–Reviews, yorumlar, kredi |
| `lib/screens/root_scaffold.dart` | Alt gezinme; bildirimler kısayolu (`onBuyCredits` şimdilik `null`) |
| `lib/util/formatting.dart` | Kredi ve süre metinleri (EN) |
| `lib/util/booking_utils.dart` | Tarih/saat yardımcıları (rezervasyon) |
| `lib/util/skill_profile_card_display.dart` | Web `skillProfileCardDisplay`: önizleme, uygunluk, seviye / oturum / konum metinleri |
| `lib/util/skill_description.dart` | Web ile aynı `———` meta açıklama bloğu |

## Test

Widget testinde `SharedPreferences` mock ve `GoogleFonts.config.allowRuntimeFetching = false` kullanılır (`test/widget_test.dart`).

## Sonraki adımlar

- Mobil **saat kredisi satın alma** ve `PaymentScreen` checkout akışını tekrar etkinleştirmek (git geçmişindeki `buy_credits_screen` + tam `payment_screen`).
- Android/iOS için Play Console / Xcode OAuth yapılandırması (yerel `google_sign_in`).
