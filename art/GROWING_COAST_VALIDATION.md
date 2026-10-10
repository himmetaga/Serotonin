# Dallanan kıyı — ana geometri düzeltmesi

10 Ekim 2026. Önceki `POROUS_RIM_VALIDATION.md` görünür fakat korkuluk benzeri ara denemeydi; bu kayıt onun yerine geçen güncel source/runtime durumunu açıklar. `serotonin-biomorphic-art` ana biçim/boşluk ilkesi ve `create-game-assets` gerçek motor/3D kabul kontrolleri kullanıldı.

## Değişiklik

`tools/build_membrane_room.py`: tek sabit superellipse platform yerine korunmuş düz çekirdek ve loblu dış kıyı. Çekirdek X ±7,35 / Blender Y ±3,85 sınırına kadar düzdür; üç dış halka kıyıyı aşağı doğru inceltir. Dış kalınlık 0,10 m, merkez 0,35 m. Üst yüzeydeki negatif kıyı eğimi gerçek hareket dikdörtgeninin dışında kalır.

Önceki iki çevresel ray ve düz çaprazlar çıkarıldı. Yirmi farklı uzunluk/yönlü ana kök, komşu kıyıdan gelen ikincil köklerle birleşir; cubic Bézier örneklemesi ile kavisli ve uca doğru incelen lifler. Tek `Growing_Costal_Roots` mesh'i, bir yüzey/materyal; kamera collision yok. Borular kapalı ayrı bileşenlerdir; kesişimler boolean kaynaşma veya biyolojik büyüme simülasyonu değildir.

Düzenlenebilir `source/membrane_room.blend` ve runtime `../godot/assets/models/membrane_room.glb` yeniden üretildi. Konsept, kamera/ışık, karakter, shader, kargo, görev noktaları, hareket sınırı ve düşman davranışı değişmedi. Yeni doku veya dış eklenti kullanılmadı.

## Gerçek kamera sonucu

- Önce: `previews/porous-rim-visible.png` ve `-gray.png`.
- Sonra: `previews/growing-coast-runtime.png` ve `growing-coast-gray.png`.
- Aynı guardian QA durumu, statik üçüncü şahıs kamera ve ışık. Kıyı kırılıyor; kesintisiz dış korkuluk yerine incelen lifler ve boşluklar görülüyor. Gri tonda İlmek/kargo/saldırı üçgeni seçilebilir.
- **Kısmi biçim ilerlemesi; nihai sanat onayı değil.** Yakında kesik lif birleşimleri ve fazla tekrarlayan kök ritmi var. Geniş düz merkez, kalın halka tonozlar ve oyuncak benzeri karakterler hâlâ konseptin incelik/ölçek hissini taşımıyor. Kamera açısını değiştirmeden ana sorunun ne kadar sürdüğü açıkça görülebilir.
- Bu bir insan playtest'i veya animasyon değerlendirmesi değil. İki tek kadraj bütün açı/mesafe/ekranlarda okunurluk kanıtlamaz.

## Kontroller ve maliyet

- Blender source audit: **17.102 üçgen**, 22.000 yerel bütçenin altında; üç materyal, 19 mesh/UV, non-manifold 0, degenerate 0.
- GLB validator PASS: **371.408 bayt**. Önceki kuşak 16.602 üçgen / 385.368 bayt idi; +500 üçgen ve daha az export baytı estetik başarı veya GPU kazanımı sayılmaz.
- Godot import exit 0; genel smoke **163 kontrol PASS**. Yeni `_floor_supports_grid` kontrolü, import edilen gerçek zemin üçgenlerini dünya koordinatına dönüştürüp X[-7,7]/Z[-3,5,3,5] alanında 0,5 m adımlı **435 nokta** üzerinde ray/triangle kesişiminin Y=0 olduğunu sınar. Köşeler dâhil; bütün sürekli yüzeyin matematiksel ispatı değil, hareket alanı regresyon kontrolüdür.
- Tek kök yüzeyi ve dekoratif kamera collision yokluğu mevcut smoke içinde doğrulanır. Görev/savaş/pause/yardımcı jest kontrolleri de geçer.
- Statik gri ton Windows Compatibility / AMD Radeon Graphics, 120 örnek: medyan interval **16,708 ms**, p95 **22,884 ms**, draw-call snapshot **150**, primitive snapshot **175.735**. Önceki aynı tür kısa yakalama 16,870/22,203 ms ve 150 draw call idi; medyan/p95 farklı yönlere gitti, FPS kazanımı çıkarılmadı. Frame pacing dahil; GPU veya iPhone testi değildir.

## Devam önceliği

Bu ara oda üzerinde mikro ayrıntı ekleme döngüsüne girme. Ana görsel fark artık korunmuş geniş savaş zemini ile konseptin dar taşıyıcı geçitleri arasındaki mekânsal farktır. Bunu çözmek, yalnız kenar süslemek değil, oynanabilir bölümün geçit/manzara/savaş açıklığı ritmini tasarlamak gerektirir. Bir sonraki kapsamlı bölüm düzeni önce rota, görüş çizgisi ve savaş ölçüleriyle ele alınmalı; mevcut güvenli arena ve checkpoint akışı korunmalı. Tam bölüm, Deniz'in görsel sonucu, final karakter sanatı ve Mac/iPhone kapıları hâlâ eksik.
