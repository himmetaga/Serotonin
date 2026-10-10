# Teslimat sesi — ilk dış dünya çağrışımı

10 Ekim 2026. Dar kapsam: mevcut Nefes teslimatına dört saniyelik özgün, yerel prosedürel ses taslağı. Yeni görsel/3D varlık, ajan veya ücretli üretim yok. Nihai kayıt ve Deniz sahnesinin yerine geçmez.

## Davranış

Gerçek `delivery_completed` sinyali `DeliveryAudio` oynatıcısını bir kez başlatır. Ses döngüsüz, mono, -6 dB; tekrar sinyal başa sarmaz. Custom pause/focus kaybı `stream_paused` ile sesi de durdurur. Reset aktif sesi keser ve olay kilidini temizler. Ses tercihi oturumdaki resetlerde korunur; uygulama kapatılınca kaydedilmez.

Duraklatma menüsünde “Ses açık” seçeneği vardır. Kapatınca aktif ses kesilir; yeniden açınca geçmiş olay otomatik çalmaz. Sessiz modda görev akışı ve “Pencere açılır; uzun bir nefes” yazılı karşılığı kalır. Bu yazı anlatı niyetidir; insan sahnesi veya gerçek insan kaydı yapılmış değildir.

Sentez offline bake edilir: üç sönümlü temas ardından yükselip sönen filtreli hava. Godot API kontrolü: [AudioStreamWAV](https://docs.godotengine.org/en/stable/classes/class_audiostreamwav.html), [AudioStreamPlayer](https://docs.godotengine.org/en/stable/classes/class_audiostreamplayer.html). Kaynak/provenans: `godot/assets/audio/README.md`.

## Kanıt

- WAV üretimi: 22.050 Hz, 16-bit mono, 4 saniye; 176.400 PCM baytı. Peak 0,361511, RMS 0,051764, DC ortalaması 0,00000698. Bunlar kaynak PCM ölçümleridir; hoparlör ses basıncı veya dinleyici konforu ölçümü değildir.
- Genel headless smoke **97 kontrol PASS**, script hatası yok.
- `tests/audio_smoke.gd`: **13 kontrol PASS**. İçe aktarım/süre, başlangıç sessizliği, gerçek teslimat tetiklemesi, pause konumunun korunması, resume, mute/menu eşleşmesi, unmute-replay olmaması, reset, sessiz teslimat, yazılı karşılık, tercih korunması, tekrarsız tetik ve kendiliğinden bitiş.
- Aynı ses testi başsız mod dışında Windows'ta da çalıştırıldı: **AUDIO PASS: 13 kontrol**, çıkış 0, script hatası yok. Oynatıcının çalışması insan dinleme/estetik onayı değildir.
- `art/previews/delivery-audio-menu.png`, 1280×800 gerçek Compatibility viewport: ses seçeneği, başlangıç odağı ve iki satırlı sonuç metni sığıyor. Sentetik tamamlanma + pause QA düzeni; farklı ekran/iPhone testi değil.

## Açık kapılar

Kulaklık/hoparlör dinleme değerlendirmesi, cihaz sesi ve kesintileri, iOS sessiz anahtarı/audio session, kalıcı ayarlar, erişilebilir ses seviyesi ve daha küçük ekranlar test edilmedi. Taslak sesin “pencere/nefes” olarak tanınıp tanınmadığı kanıtlanmış değil. Teslimatın insanla duygusal bağlantısı için hâlâ gerçek sahne ve kaliteli ses tasarımı gerekiyor. Bu adım tam macera veya ödül standardı doğrulaması değildir.

`game-feel` tek olay ve ölçülü ek ses katmanını; `game-ui-ux` sessiz seçenek/yazılı eşdeğer ve menü düzenini yönlendirdi. Ayrı audio-design becerisi mevcut oturum kataloğunda yoktu.
