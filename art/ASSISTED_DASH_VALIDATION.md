# Yardımcı tek parmak atılma

Güncel düzeltme: normal yürüyüş hazırlık üretmesin diye mesafe eşiği 60'tan 135 UI piksele alındı. Aşağıdaki ilk uygulama kaydı tarihseldir; uçtan uca kanıt `ASSISTED_FLOW_VALIDATION.md` içindedir.

10 Ekim 2026. Windows Godot 4.7.2. Varsayılan kapalı, menüden seçilir.

## Kontrol sözleşmesi

Sürükleme hareketi korur. Başlangıçtan en az 60 UI piksel uzakta bir yönü 0,35 saniye kararlı tutmak yalnız hazırlık oluşturur. Parmağı kaldırmak hareketi durdurur, atılma üretmez. Hazırlık geçerliyken sonraki ayrı basış, hazırlanmış kamera göreli dünya yönüne atılır; savuruş hızı gerekmez. Aynı onay temasında ikinci atılma hazırlanmaz.

Yön değişimi (dot < 0,96), merkeze geri çekme, iki saniyelik hazırlık zaman aşımı, duraklatma, odak kaybı, reset ve mod değişimi hazırlığı temizler. Yalnız sahibi olan parmak bırakabilir; yabancı parmak etkisizdir. Yön hazır durumu mevcut alt ipucunda yazılır. Onay sırasında cooldown engelliyse atılma gerçekleşmez, hazırlık tüketilir; otomatik tekrar yok.

Menüde “Yardımcı atılma · savuruş gerekmez” ve moda uygun öğretim var. Hareket/saldırı butonu eklenmedi; WASD/Boşluk değişmedi. Tercih mevcut v1 JSON'a opsiyonel bool olarak eklendi; eski alanı olmayan kayıtlar kapalı yüklenir. Yanlış tür reddedilir, daha yeni şema korunur. Testler kişisel user:// ayarına yazmaz.

## Kanıt

- Genel smoke **160 PASS**: hazırlama/onay, bırakmanın saldırmaması, tek parmak sahipliği, aynı temasta tekrar olmaması, iptal, timeout, pause/focus/reset ve varsayılan moda dönüş. Önceki hızlı savuruş/savaş testleri korunur.
- Ayrı işlemler: preferences write **4 PASS**, read **22 PASS**; gerçek menü yakalamasıyla read **23 PASS**. Eski v1 uyumluluğu ve bool türü ayrıca sınandı.
- `art/previews/assisted-dash-menu.png` 1280×800 menü yerleşimini gösterir. İki test sahnesi aynı viewport'ta olduğundan arka plan ışığı/metinleri çift; sanat/perf onayı için kullanılmaz. Ekran gelecekteki şema uyarı durumudur; yardımcı seçenek kapalı görünür.
- Smoke kapanışında durdurulmuş AudioStreamWAV playback nesneleri için uyarı görüldü. Test sahnesi açıkça serbest bırakılıp audio mixer'a 0,10 saniye temizleme zamanı verildi; bu oyun mekaniği değişikliği değildir.

## Açık sınırlar

Bu erişilebilir kontrol adayıdır, motor engelli oyuncularla doğrulanmış çözüm değildir. Hareket sırasında yanlış hazırlık/onay oranı, saptırma zamanlaması, 60 piksel/0,35 saniye/iki saniye eşikleri ve iOS kenar jestleri gerçek kullanıcı/cihaz testinde sınanmalı. Yardımcı jestle bütün görevin tamamlanması henüz test edilmedi. Menü yalnız 1280×800'de incelendi; küçük telefon güvenli alan onayı yok. Kalıcı ilerleme kaydı hâlâ yok.

`input-systems` ayrı hazırlık/onay ve sahiplik kurallarını; `game-ui-ux` açık durum/öğretimi; `save-systems` eski kayıt uyumluluğu ve doğrulamayı yönlendirdi. Yeni model, ücretli görsel veya ajan ekibi kullanılmadı.
