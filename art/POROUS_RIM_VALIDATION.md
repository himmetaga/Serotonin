# Gözenekli zemin kenarı — ara geometri deneyi

10 Ekim 2026. `serotonin-biomorphic-art` ve `create-game-assets` ile tek çevre parçası üzerinde çalışıldı; yeni görsel üretimi, eklenti, karakter ailesi veya renderer değişikliği yapılmadı.

## Karşılaştırma ve karar

- Önceki kare: `previews/porous-rim-runtime.png`. 1,065 dış çarpan ve -0,62 Blender Z seviyesindeki kuşak opak zeminin altında saklanıyordu; gerçek takip kamerada görünürlük kapısı başarısızdı.
- Güncel: `previews/porous-rim-visible.png`; aynı guardian QA konumu, statik üçüncü şahıs kamera, ışık ve görev durumu. Dış çarpan 1,20; dış yükseklik -0,16 ±0,06. Gerçek açık hücreler artık zemin siluetinin dışında görünüyor.
- Gri ton: `previews/porous-rim-visible-gray.png`. İlmek, kargo ve koyu kenarlı saldırı üçgeni seçiliyor. Bu tek kadraj, bütün açılarda okunurluk veya insan playtest kanıtı değildir.
- **Görünürlük geçti; nihai sanat kapısı geçmedi.** Kuşak fazla düzenli üçgen/korkuluk görünümünde. Düz opak ana zemin ve oyuncak benzeri karakterler hâlâ onaylanan konseptten uzak. Kuşak ara üretim geometrisidir; bütün oda ailesini bununla çoğaltma.

## Teknik sonuç

Kaynak `source/membrane_room.blend`; runtime `../godot/assets/models/membrane_room.glb`; tarif `tools/build_membrane_room.py`. Fascia birleşik bir mesh ve bir materyal yüzeyi; borular ayrı kapalı bileşenler olarak kesişir, boolean ile kaynaşmış taşıyıcı doku değildir.

- Oda: 16.602 üçgen (22.000 yerel bütçe), üç materyal, 19 mesh, 385.368 GLB bayt.
- Source audit: non-manifold kenar 0, degenerate yüz 0, UV'li mesh 19. Bu sayılar örtüşen lif birleşimlerinin estetik kalitesini kanıtlamaz.
- Sabit hareket sınırı X ±7 / Z ±3,5 ve görev konumları değişmedi. Dekoratif dış kuşakta `CameraOnlyCollision` yok; kamera kuşağın aralarında gereksiz içeri çekilmiyor.
- Godot import ve GLB validator exit 0; `tests/smoke.gd`: **162 kontrol PASS**, yeni iki kontrol fascia import/yüzey sayısı ve collision yokluğunu sınar. Sanat değerlendirmesinin yerine geçmez.
- Windows Compatibility, AMD Radeon Graphics, statik gri ton QA, 120 örnek: medyan frame interval **16,870 ms**, p95 **22,203 ms**, 150 3D draw call snapshot, 168.915 primitive snapshot. Frame pacing dahil duvar saati aralıkları; GPU süreleri değil. Eş koşullu eski profil olmadığı için FPS iyileşmesi iddia edilmez; iPhone testi değildir.

## Sonraki gerçek sanat problemi

Görünmez alt geometriye ayrıntı eklemek yerine, ana zeminin dolu/boş kütle ilişkisini çözmek gerekiyor. Bir sonraki temsilî source düzeltmesi: oyun alanını koruyarak düz plakanın dış kıyısını büyümüş, incelen ve dallanan bir kenara dönüştürmek; tekrar eden düz çaprazları çoğaltmamak. Yeni ışık/sisle sorunu gizleme. Mevcut deneme sanatsal final değil; kabul kartı ve maliyet kaydıyla korunuyor.
