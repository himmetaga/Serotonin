# Kıskaç — ayrılan kabuk parçaları

10 Ekim 2026. Önceki `KISKAC_SEAM_VALIDATION.md` işaret çalışmasının devamıdır.

## Değişiklik

Tek mercan elipsoid kabuk, aynı dış ölçüleri koruyan iki kapalı mesh'e ayrıldı. Her yarının kesitinde ayrı koyu iç yüzey var; normal yönleri yeniden hesaplandı. Aralarında daha küçük koyu gövde kalır, yüz ve kıskaçlar yerinde korunur. Kaynak `art/source/kiskac.blend`; tarif `art/tools/props.py` ve `art/tools/build_assets.py`.

Runtime `Guardian_Shell_L_Runtime` ve `Guardian_Shell_R_Runtime` gruplarını ayrı yönetir. EXPOSED hedefinde her biri yerel X'te 0,22 m dışarı, Y'de 0,07 m yukarı kayar. Normal harekette üstel easing; azaltılmış harekette doğrudan açık/kapalı duruş. Pause geçişi dondurur; reset kaynak konumlarına döndürür. Açıklık bittiğinde kabuk kapanır. Altın iplik artık enine kaş gibi değil boyuna açıklığın içinde konumlanır.

Bu gerçek parça hareketidir; kemik rig'i, yumuşak doku deformasyonu, fizik simülasyonu veya nihai kitin/plaka tasarımı değildir. Görsel parçalar oyun konumunu, isabet yarıçapını ve 1,25 saniyelik karşılık penceresini değiştirmez. Tek Kıskaç üretildi; oda veya karakter ailesi yeniden oluşturulmadı.

## Doğrulama

- Blender 5.2.1 LTS export ve Godot 4.7.2 yeniden import başarılı.
- GLB validator PASS: **4.128 üçgen, 3 materyal, 101.784 bayt**. Kaynak 10 mesh parçası, runtime 4 grup/9 materyal yüzeyi. Önceki 2 grup/5 yüzeye göre maliyet arttı; frame-time veya iPhone performansı bu turda ölçülmedi.
- Kaynak nonmanifold ve dejenere yüz sayısı sıfır. İki yeni kabuk yarısı UV içermiyor; mevcut düz materyaller için kullanılıyor, dokulu üretime hazır sayılmıyor. Rig/LOD yok.
- Genel smoke **127 kontrol PASS**, script hatası yok. Gerçek iki isabet döngüsü; iki parçanın ayrılması; normal açılma/kapanma; pause; azaltılmış harekette doğrudan duruş; reset; simülasyon konumu ve açıklık süresinin korunması sınandı.
- Aynı kamera ve azaltılmış hareketle gerçek Godot gri ton kareleri: `art/previews/kiskac-shell-closed-gray.png` ve `art/previews/kiskac-shell-final-gray.png`. Kapalı durumda dış siluet birleşik, açık durumda boyuna boşluk seçiliyor.
- İlk `kiskac-shell-open-gray.png` karesinde iplik fazla yukarıdaydı. Kaynak konumu düşürüldü; son karede boşluğun içine alındı. Bu ilk kare final değildir.

Görüntüler sentetik QA düzenidir, dış oyuncu testi değildir. Statik kare hareket zamanlamasını doğrulamaz; easing yalnız testte sınandı. Normal renk, tüm kamera açıları, kullanıcı tarafından algılanma ve gerçek iPhone testi eksik.

## Kalite değerlendirmesi

Renk dışında siluet değişimiyle açıklık anlatımı ilerledi. Buna rağmen gövde hâlâ sade ve oyuncak benzeri; konseptteki segmentli kitin, zar optiği ve eterik atmosfer yakalanmış değil. Sonraki sanat adımı küçük kabuk eklem/plaka hiyerarşisi incelemesi; oynanışın sonraki önemli kapısı bu hazırlık/hamle/açıklık bilgisinin gerçek oyuncuya metinsiz geçmesi. Bir test PASS'i sanat onayı veya ödül kanıtı değildir.
