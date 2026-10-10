# Hücresel geçit — küçük sanat uygulaması

10 Ekim 2026. `serotonin-biomorphic-art` biçim/malzeme ayrımını; `create-game-assets` kaynak → GLB → gerçek kamera doğrulamasını yönlendirdi. Harici paket, yeni AI görseli veya ajan kullanılmadı.

## Yapılan değişiklik

Blender'da tek bir +X geçit parçası üretildi: incelen ana kaburgalar, yüzey üçgenlemesinin dualinden türetilmiş 70 açık hücre ve seçilmiş altı kapalı ince zar. Üç mesh/materyal grubuna birleştirildi. Bu gerçek hacimsel Voronoi veya biyolojik simülasyon değildir. Kapalı süpürme parçaları birleşimlerde kesişir; boolean ile tek yüzeye kaynaştırılmadı.

Kaynak `source/cellular_gate.blend`, tarif `tools/build_cellular_gate.py`, runtime `../godot/assets/models/cellular_gate.glb`. Eski oda Blender kaynağı korunuyor. Çalışma zamanında yalnız +X yönündeki `Side_Fold_R` kaldırılıp yerine açık geçit konuyor; görünmez kamera engeli kalmaması için bu işlem collision üretiminden önce yapılıyor. Oynanabilir alan veya görev rotası genişletilmedi.

İlk Godot karesi eski duvarın modeli örttüğünü ve ayakların zeminden kopuk kaldığını gösterdi. Duvar seçimi ve platforma bağlanan kökler düzeltildi. Son görüntü `previews/cellular-gate-runtime.png`: İlmek/kargo ön planda, muhafız ve hamle işareti ortada, açık ağ arkada. Bu mevcut muhafız QA karesi; insan oynanış testi değil.

## Doğrulama kapsamı

- Blender kaynak: **16.196 üçgen**, bütçe 18.000; üç materyal, harici texture yok. Kaynakta non-manifold kenar ve dejenere yüz sayısı sıfır. Bu kontrol birleşim kesişmelerini veya görsel kusursuzluğu kanıtlamaz.
- GLB doğrulayıcısı: export/source üçgen eşleşmesi, GLB bütünlüğü, üç materyal, eksik texture bağımlılığı olmaması ve uygulanmış ölçek.
- Godot 4.7.2 Compatibility'de içe aktarım ve gerçek Windows görüntüsü alındı. Kamera engeli yalnız ana kaburga grubunda; ince ağ dekoratif ve çarpışmasız. Mevcut oda collision düzeni dışında yeni gameplay collision yok.
- Smoke testine GLB yükleme, üç görünür grup, ana kaburga kamera engeli ve eski duvarın kaldırılması kontrolleri eklendi. Son koşu: **69/69 PASS**, Godot 4.7.2 Windows headless. Bunlar mevcut tek arena akışı için kontrollerdir; sanat hedefinin veya tam oyunun tamamlandığını kanıtlamaz.

## Kalite dürüstlüğü ve sıradaki iş

Ana boşluk/siluet eski düz duvara göre daha güçlü; kargo ve saldırı işareti bu tek kadrajda örtülmüyor. Ancak bu görüntü hâlâ hedef konseptin çok altında: ileri geçidin içi boş, mimari daha derin ve yumuşak bir büyüme dili gerektiriyor; zemin düz, zarlar opak, karakter ve muhafız hâlâ ilk model kalitesinde. Bu bir ADA kalite onayı değildir.

Yakın mesafe malzeme, gri ton, azaltılmış efekt, uzun oturum kamera konforu ve ölçülmüş frame time bu turda doğrulanmadı. Üç mesh üç toplam sahne draw call demek değildir; gölge ve diğer varlıklar ayrı maliyet getirir. iPhone build/dokunma/performans yok.

Sonraki görsel öncelik: yeni model ailesi eklemek yerine aynı parçanın birleşimlerini ve derinlik içindeki uzantılarını çözmek; ardından zemini sakin lif yönleriyle birleştirmek. Başarılı screenshot, tamamlanmış macera yerine geçmez.
