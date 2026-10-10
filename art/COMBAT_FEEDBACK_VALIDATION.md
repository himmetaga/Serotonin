# Savaş — kısa olay tepkileri

10 Ekim 2026. Windows Godot 4.7.2 Compatibility. Model export veya ücretli üretim yapılmadı.

## Uygulama

`main.gd` gerçek karşılaşmada `combat_impact(kind, direction)` yayar. Başarılı saptırma, açık dikişe isabet ve oyuncunun darbe alması ayrı olaylardır. `_guard_lunge_hit` / `_dash_hit_this_dash` korumaları tekrar tetiklemeyi sınırlar. Son isabetin mesajı muhafızın sakinleşip bağ noktalarının açıldığını anlatır.

Yeni `godot/scripts/combat_feedback.gd` bileşeni 0,18 saniyelik karesel sönümle, saptırmada muhafıza 0,12 m/dikiş isabetinde 0,22 m yönlü görsel geri esneme uygular. İlmek saptırmada dikleşir; darbe alınca kısa sıkışma ve 0,12 m görsel geri tepme gösterir. Bunlar simülasyon konumu veya hitbox değişimi değildir; mevcut darbe sonrası güvenli noktaya alma davranışı korunmuştur.

Olayın yazılı karşılığı mevcut alt görev ipucunda 0,65 saniye kalır; ardından güncel aşamanın ipucu geri döner. Azaltılmış hareket görsel kayma/ölçek tepkisini kapatır, yazıyı korur. Pause tepki saatini dondurur; reset pozu ve mesajı siler. Tepki sırasında girdiye kilit eklenmez.

Kamera sarsıntısı, tam ekran flash, parçacık, savaş sesi, haptik ve hit-stop eklenmedi. Bunların eksikliği, savaş hissinin tamamlandığı anlamına gelmez. Metin süresi ve tepkilerin oyuncu tarafından ayırt edilmesi gerçek oyun testinde değerlendirilecek.

## Kanıt ve sınırlar

- Genel smoke **144 kontrol PASS**, son çalıştırmada script hatası/sızıntı uyarısı yok. Gerçek iki dikiş isabeti, saptırma ve geç saptırmada oyuncu darbesi olayları ayrı kontrol edildi. Görsel/simülasyon ayrımı, sönüm, normal ipucuna dönüş, pause, reduced motion, hareketin açık kalması ve reset sınandı.
- İlk lambda sinyal bağlantısı çıkışta kaynak sızıntısı uyarısı verdi; adlandırılmış `_on_combat_impact` metot bağlantısına geçildi. Son testte uyarı yok.
- Gerçek Godot sentetik QA karesi `art/previews/combat-parry-feedback.png`: açıklık ve saptırma pozu, mevcut alt yazı alanında olay mesajı. İlk yakalamada görsel saat ilerlemediğinden kabuk kapalıydı; QA artık 0,06 saniye görsel ilerletip donduruyor. Kare bir insanın saptırma yaptığının kanıtı değildir.
- `--capture-impact=parry|hit|damage` yalnız `--capture=` ile QA olayı üretir. Statik seçenek yoksa QA için azaltılmış hareket kapatılır; tercihler dosyasına yazılmaz. `--capture-static` ile hareket kapalı/mesaj açık karşılık incelenebilir.
- Yeni model/material/mesh veya sürekli olay dinleyicisi eklenmedi. GPU ölçümü, animasyon videosu, iPhone dokunması ve dış oyuncu testi yapılmadı.

`game-feel` becerisi tepkilerin tek olaydan başlamasını, kısa sürede normal duruşa dönmesini ve simülasyondan ayrı kalmasını yönlendirdi. Görsel tasarım hâlâ ilk geçiş; ödül veya sanatsal final onayı değildir.
