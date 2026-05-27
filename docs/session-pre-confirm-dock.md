# Seans öncesi onay (sağ alt kart)

## Nerede görünür?

`SessionPreConfirmDock` → `App.tsx` içinde **tüm sayfalarda**, giriş yapmış kullanıcı için. Sayfa ortasında modal veya tam yükseklik sidebar değil; **sağ altta yüzen kompakt kart** (`#tiempos-overlays` portal).

## İş kuralları (özet)

| Durum | Sonuç |
|--------|--------|
| İki taraf **Katılacağım** | Kart kapanır; her iki tarafa bildirim; **saat aktarımı** (öğrenciden düşüm zaten askıda, eğitmene kredi + defter kaydı). Oturum durumu `ACCEPTED` kalır; oturum sonrası katılım onayı ile `COMPLETED`. |
| İki taraf **Katılmıyorum** | Rezervasyon **iptal**; askıdaki saat **iade**; iki tarafa bildirim. |
| Biri onay biri red | İptal + iade + bildirim. |
| Biri yanıtladı, diğeri bekliyor | Kart açık kalır; karşı tarafın durumu (Bekleniyor / Katılacak / Reddetti) gösterilir. |

## Kredi zamanlaması

1. **Rezervasyon (book):** Bakiye yeterliliği kontrol edilir; **düşüm yapılmaz** (`requesterCreditHeld = false`).
2. **Eğitmen kabulü:** Öğrenci bakiyesinden düşülür, `requesterCreditHeld = true` (askıda).
3. **Seans öncesi çift onay:** Yalnızca katılım mutabakatı; **saat aktarımı yapılmaz**.
4. **Ders bitimi:** Tam süre eğitmene aktarılır (`settleDueSessionsAtEnd` scheduler).
5. **Sorun bildirimi (ders sırasında):** Başlangıçtan o ana kadar geçen dakika aktarılır, kalan askı iade; mesaj thread’e yazılır.
6. **Çift red / çelişki (ders öncesi):** İptal + tam iade.

## Kart fazları (`sessionDockPhase`)

| Faz | UI |
|-----|-----|
| `PRE_CONFIRM` | Kabul / Reddet |
| `WAITING_START` | Derse geri sayım |
| `LIVE` | Bitişe geri sayım + sorun bildir |
| `DONE` | Kart kapanır |

Kart: dersden **10 dk önce** → ders **bitene** kadar (veya saat kesinleşene kadar).

## Değerlendirme (puan + yorum)

Seans **tamamlandığında** veya **kısmi/erken bitişte** (saat aktarımı yapıldıysa) sağ dock’ta ikinci bir kart açılır:

- `GET /api/reviews/pending-dock` — bekleyen değerlendirmeler
- `POST /api/reviews/exchange/{id}` — 1–5 yıldız + yorum → karşı tarafın **profiline** işlenir
- Öğrenci **ve** eğitmen karşılıklı değerlendirebilir (oturum başına bir yorum / kişi)
- Sadece ön iptal (hiç saat aktarımı yok) için kart çıkmaz

## Ön iptal anketi (profile yansımaz)

Saat aktarımı **olmayan** seans öncesi iptallerde gri kart:

- `GET /api/exchange-requests/pending-cancel-survey`
- `POST /api/exchange-requests/{id}/cancel-survey` — `SCHEDULE` | `NOT_NEEDED` | `OTHER` (+ isteğe bağlı not)
- Veri `exchange_cancel_surveys` tablosunda; **public profilde gösterilmez**

## Seans sonu “Nasıldı?” (hızlı puan)

Tamamlanan oturumlarda (`uiMode: QUICK`): büyük yıldızlar, **Yorumsuz gönder** veya isteğe bağlı uzun yorum.

## Normal / üretim ön yüz

Sağ dock yalnızca API’den gelen gerçek verilerle açılır (açık seans, bekleyen değerlendirme veya iptal anketi). Demo/önizleme kartı yoktur.

## Backend

- `POST /api/exchange-requests/{id}/pre-session-response` — `CONFIRM` | `DECLINE`
- `GET /api/exchange-requests/pre-session-open`
- `tiempos.pre-session-demo` — yerel zaman penceresi (üretimde `false`)
