# Tiempos — mobil (Flutter)

Web `frontend` ile **aynı Spring API** (`/api/...`) üzerinden çalışan mobil istemci: giriş, token kalıcılığı, dashboard ve yaklaşan oturumlar.

## Gereksinimler

- [Flutter](https://docs.flutter.dev/get-started/install) SDK (projede `sdk: ^3.10.8`)

## Çalıştırma

```bash
cd mobil
flutter pub get
# Sabit port — Google ile giriş için Cloud Console'a TEK köken eklemeniz yeter: http://localhost:9339
flutter run -d chrome --web-port=9339
```

Veya kısayol: `./run_chrome.sh` (`mobil/` içinde).

### Yerel backend + mobil (tek komut)

Docker Desktop açıkken repo kökünde:

```bash
./scripts/dev-backend-and-mobile.sh
```

Önce Postgres (`docker compose up -d db`), ardından Spring Boot (`./mvnw spring-boot:run`), en sonda Flutter Web (**Chrome sabit port 9339**) — API `http://localhost:8080`.

### API adresi

Varsayılan taban URL, web `getApiBaseUrl` ile uyumlu **Render** API:

`https://tiempos-backend-w26e.onrender.com`

**Not (ücretsiz Render):** API bir süre kullanılmadıysa “uyku”dan uyanması **60–120 saniye** sürebilir. İlk girişte bekleyin; uygulama giriş isteği için **3 dakikaya** kadar zaman tanır.

Yerel veya başka bir sunucu için:

```bash
flutter run --dart-define=API_BASE_URL=http://localhost:8080
```

Backend `GET /api/auth/google-config` boş dönüyorsa (yerelde `GOOGLE_CLIENT_ID` tanımlı değilse), web ile **aynı Web OAuth istemci kimliğini** derleme anında verebilirsiniz:

```bash
flutter run -d macos \
  --dart-define=API_BASE_URL=http://127.0.0.1:8080 \
  --dart-define=GOOGLE_CLIENT_ID=YOUR_WEB_CLIENT.apps.googleusercontent.com
```

(Sondaki `/` ve `/api` olmamalı; istek yolları zaten `/api/...` ile başlar.)

Profil paylaşımında kullanılan **web uygulaması kökü** (varsayılan `https://www.tiempos.site`, yol `/u/{kullanıcıId}`):

```bash
flutter run --dart-define=WEB_APP_ORIGIN=https://www.tiempos.site
```

### Oturum

İlk açılışta **Sign in** ekranı gelir: **Google**, e-posta/şifre, **Create account** (kayıt + isteğe bağlı e-posta doğrulama), **Forgot password**, **Reset with email code**. Başarılı girişte JWT `shared_preferences` ile saklanır; **Profile → Log out** ile temizlenir.

### Google (Flutter Web — `origin_mismatch` düzeltmesi)

Google yalnızca **Cloud Console’da kayıtlı kökenlere** izin verir. `flutter run -d chrome` **rastgele port** açtığı için (`localhost:61739` gibi) sürekli **400 origin_mismatch** alırsınız.

**Çözüm (önerilen):** Bu projede web için **sabit port 9339** kullanın:

```bash
flutter run -d chrome --web-port=9339
```

Ardından [Google Cloud Console](https://console.cloud.google.com/) → **API’ler ve Hizmetler** → **Kimlik Bilgileri** → backend’deki `GOOGLE_CLIENT_ID` ile **aynı** **OAuth 2.0 Web istemcisi** → **Yetkili JavaScript kökenleri** → şunu **tek satır** ekleyin:

`http://localhost:9339`

`http://127.0.0.1:9339` ile `http://localhost:9339` **farklıdır**; uygulama hangi host’ta açılıyorsa onu ekleyin. Backend’deki Web client ID (`/api/auth/google-config`) ile uyumlu olmalı.

**CORS (Flutter Web → Render API):** `http://localhost:9339` ve `http://127.0.0.1:9339` her zaman izinlidir. Vite portları ve LAN kökenleri yalnızca `APP_CORS_BROWSER_DEV_PATTERNS=true` (varsayılan) iken eklenir; Render’da `false` ile sıkılaştırabilirsiniz, Flutter web yine çalışır.

**Giriş ekranında `GoogleSignInExceptionCode.canceled`:** Kullanıcı pencereyi kapattığında veya yukarıdaki OAuth hatası dönüşünde oluşabilir; iptal sessizce yutulur; yapılandırma hatasında ekranda `Authorized JavaScript origins` için kök URL gösterilir.

### Tema ve dil

**Profile → Settings** üzerinden açık/koyu tema ve English/Türkçe dil seçimi `SharedPreferences` ile saklanır (`AppState` + `MaterialApp`).

## Sürüm: Android (APK) ve iPhone (IPA)

| Platform | Çıktı | Komut (özet) |
|----------|--------|----------------|
| **Android** | `.apk` | `flutter build apk --release` → `build/app/outputs/flutter-apk/app-release.apk` |
| **iPhone (gerçek cihaz)** | **`.ipa`** | `flutter build ipa --release` → `build/ios/ipa/*.ipa` |

**iOS’ta APK yok:** Apple tarafında dağıtım paketi **IPA**’dır (`flutter build ipa` arşivi imzalar ve dışa aktarır).

### iPhone’a nasıl gider?

- **TestFlight / App Store (önerilen):** Apple Developer Program ($/yıl) + Xcode’da **Signing & Capabilities** ile takım ve bundle ID (`com.tiempos.tiemposMobile`) ayarlı iken arşivleyip App Store Connect’e yükleyin; test kullanıcıları **TestFlight** ile indirir. GitHub’dan doğrudan IPA indirip “her telefona tıkla kur” Android kadar kolay değildir.
- **Ad Hoc IPA:** Yalnızca Apple hesabınıza **UDID’leri kayıtlı** cihazlarda çalışır; yine imzalama gerekir.
- **Simülatör:** `flutter run -d ios` — simülatör için **IPA gerekmez** (mağaza dağıtımı değildir).

### IPA üretmek (Mac + Xcode)

1. `open ios/Runner.xcworkspace`
2. **Runner** → **Signing & Capabilities** → **Team** seçin (Apple ID ile Xcode’a giriş).
3. Proje kökünde:

```bash
cd mobil
flutter pub get
flutter build ipa --release
```

Başarılı olunca IPA genelde **`mobil/build/ios/ipa/`** altında oluşur (`.ipa` dosya adı Flutter/Xcode ayarına göre değişir).

### GitHub Release’e IPA eklemek (örnek)

Önce [GitHub CLI](https://cli.github.com/) ile giriş: `gh auth login`. Mevcut bir etikete dosya eklemek için:

```bash
gh release upload v1.0.1 path/to/Tiempos.ipa --repo beza0/Tiempo_Project
```

(Yeni release açarken APK ile birlikte aynı `gh release create` komutuna birden fazla dosya verilebilir.)

## Kod yapısı

| Yol | Açıklama |
|-----|----------|
| `lib/config/api_config.dart` | `API_BASE_URL` (`--dart-define`) + normalizasyon |
| `lib/config/app_web_config.dart` | `WEB_APP_ORIGIN` — paylaşılan profil (`…/u/{id}`) + `webPageUrl(path)` (ör. kayıt ekranı yasal linkleri) |
| `lib/language/profile_l10n.dart` | Profil / düzenle ekranı metinleri (cihaz dili `tr` ise Türkçe) |
| `lib/language/auth_l10n.dart` | Giriş / kayıt / şifre sıfırlama metinleri |
| `lib/language/legal_l10n.dart` | Yardım merkezi başlıkları / bölüm adları (`LegalL10n.forTr` ayar diliyle uyumlu) |
| `lib/help/help_models.dart` | Web `en.ts` / `tr.ts` ile hizalı yardım veri modelleri |
| `lib/help/help_bundle_en.dart` / `help_bundle_tr.dart` | Kopya metinler (`tool/generate_help_bundles.py` ile üretilir) |
| `lib/help/help_center_screen.dart` | Tek sayfa yardım: Nasıl çalışır, Hakkında (+ `GET /api/public/stats`), SSS, iletişim formu (`POST /api/public/contact`), yasal metinler |
| `lib/api/public_api.dart` | `GET /api/public/stats`, `POST /api/public/contact` |
| `tool/generate_help_bundles.py` | Web `en.ts` / `tr.ts` ile aynı yardım metnini `help_bundle_*.dart` olarak üretir |
| `lib/api/api_client.dart` | `http` + JSON + `Authorization: Bearer` |
| `lib/api/auth_api.dart` | `login`, `register`, `verify-email`, `resend-verification`, `forgot-password`, `reset-password`, `google-config`, `social-login` |
| `lib/api/user_api.dart` | `GET/PUT /api/users/me/profile` (createdAt dahil), dashboard, engelleme, public profil |
| `lib/api/notifications_api.dart` | `GET /api/notifications`, okundu işaretleme |
| `lib/api/reviews_api.dart` | Aldığın / verdiğin yorumlar, özet, `POST .../reviews/exchange/{id}` |
| `lib/api/credits_api.dart` | Kredi checkout başlat / tamamla |
| `lib/data/profile_picklists.dart` | Web `profilePicklists.ts` — konum/dil JSON’ları + `mergeLegacyOption` |
| `lib/data/credit_packages.dart` | Web ile aynı paket kimlikleri |
| `lib/api/skills_api.dart` | `GET /api/skills`, `GET /api/skills/{id}`, `GET/POST/PUT /api/skills...` (mine, create, update) |
| `lib/api/exchange_api.dart` | Talepler + mesajlar: sent/received, `POST .../skill/{id}`, thread `GET/POST .../messages` |
| `lib/app/app_state.dart` | Token / kullanıcı + profil adı; tema (`ThemeMode`) ve dil (`localeOverride`, `en`/`tr`) kalıcılığı |
| `lib/screens/login_screen.dart` | E-posta/şifre + Google; kayıt / şifre unuttum / kod ile sıfırlama yönlendirmeleri |
| `lib/screens/signup_screen.dart` | `POST /api/auth/register`, doğrulama kodu, `verify-email`, `resend-verification` |
| `lib/screens/forgot_password_screen.dart` | `POST /api/auth/forgot-password` (web ile aynı “her zaman başarılı” mesajı) |
| `lib/screens/reset_password_screen.dart` | `POST /api/auth/reset-password` |
| `lib/screens/settings_screen.dart` | Web `SettingsPage`: şifre, dil/tema, **Yardım merkezi** (`HelpCenterScreen`), hesap sil |
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
