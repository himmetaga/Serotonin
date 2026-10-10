# Son yuva — üçüncü şahıs hedef okunurluğu

10 Ekim 2026. Önceki teslimat karesinde hedef halkası belirgin değildi. Bu tur yeni model ailesi, Blender export, ücretli görsel, bağımlılık veya ajan çağrısı olmadan mevcut mekânsal işareti düzenler.

## Değişiklik

Son teslimatın düz halka ağı hacimli `TorusMesh` ile değiştirildi; alçak, koyu bir çevre kenarı eklendi. Kamera ya da oyuncu collision eklenmedi. Geçici açık yuvalar aynı kaldı. Bu bir oynanış işareti; nihai biyomorfik yuva modeli değildir.

Son yuva üstündeki `Label3D`, yalnız teslimat/sonuç aşamasında görünür. İki bağ tamamlanınca “Son yuva · Nefes”, 0,9 saniyelik bekleme sırasında %10 basamaklı “Yerleşiyor”, teslimattan sonra “Nefes ulaştı” gösterir. Yuvadan uzaklaşma veya hareket, mevcut teslimat kuralına uygun biçimde beklemeyi ve metni sıfırlar. Metin her render karesinde yeniden yazılmaz; aşama ve ilerleme değişimlerinde güncellenir. Yeni hareket/atak butonu yok.

## Kanıt

- Windows Godot 4.7.2 headless smoke: **97 kontrol PASS**, çıkış kodu 0, script hatası yok. Ek testler hedefin aşamaya göre görünmesi, kapalı halka/kenar yapısı, yüzde ilerlemesi, bekleme iptali, sonuç metni ve reset içindir. Önceki savaş ve tek parmak kontrolleri de çalıştı.
- `art/previews/socket-readable.png`: gerçek Compatibility viewport, 1280×800, gri tonlu 3D görünüm ve azaltılmış hareket. Sentetik `--capture-stage=delivery --capture-static --capture-grayscale` düzenidir; insanın oyunu tamamladığını göstermez.
- İlk düz yaklaşma kontrolünde İlmek zemindeki yuvayı örttü; üstteki hedef metni görünür kaldı. Yan yaklaşma kontrolünde açık halka yüzeyi ve koyu çevre kenarı da seçiliyor. QA konumu son yuvadan (-2, 0, -1,2) uzaklıkta; eski teslimat kayıtlarıyla birebir aynı kadraj değildir.
- İlk kenar geometrisi parlak halkayı kısmen örttü; kenar yüksekliği küçültülerek düzeltildi. Son kare elle incelendi.

## Sınırlar / sonraki iş

Etiket ve halka hedefi açıklaştırır; bu tek kare tüm kamera açılarında, farklı ekranlarda veya gerçek iPhone'da okunurluk kanıtı değildir. Kamera arkasındaki hedef için ekran kenarı işareti yok. Dünya metni şimdilik Türkçe; yerelleştirme yok. Ek kenar ve etiketin cihaz performansı ölçülmedi. Soyut halka nihai sanatsal yuva yerine geçmez.

Deniz'in dış dünyadaki sonucu hâlâ metin; pencere/nefes sesi veya insan sahnesi yok. Tam oyun, nihai karakter sanatı, kayıt ve Apple cihaz kapıları tamamlanmış sayılmıyor.

`game-ui-ux` renk dışı metin/ilerleme ve değişim bazlı güncellemeyi; `serotonin-biomorphic-art` düşük görsel karmaşa ve gerçek kamera/gri ton kontrolünü yönlendirdi.
