# Statik birleştirme deneyi — üretime alınmadı

10 Ekim 2026. `create-game-assets` kaynakları koruma ve gerçek motor görüntüsüyle karşılaştırma yaklaşımı kullanıldı. Blender/GLB dosyaları değiştirilmedi; yeni AI görseli veya ajan yok.

## Bulgular

GLB JSON incelemesi: İlmek 1 mesh/3 surface, Nefes 1/1, Kıskaç 1/3. Blender üretim tarifi zaten parçaları export sırasında birleştiriyor. Karakterlerde çok parça olduğu varsayımı yanlış çıktı; karakter birleştirme çağrısı kaldırıldı.

Runtime SurfaceTool deneyi oda kaburgalarına uygulandı. Malzeme eşitliği gerçek saklanan özellikler ve shader uniform'larıyla karşılaştırıldı; skin/blendshape/animasyon/şeffaflık desteklenmiyor. Kaynaklar silinmedi; denemede görünürlükleri kapatıldı. Normal oyunda deneme **kapalı**, yalnız `--capture-batch-experiment` ile araştırma için açılabilir. Açıkken üretim kalitesi onaylanmış değildir.

Sabit kamera QA için `--capture-static` eklendi: azaltılmış hareket açık, physics process durdurulmuş aynı telegraph düzeni. Profil yalnız capture yolunda 120 frame aralığını örnekler.

## Aynı kodda A/B kaydı

- `previews/batch-reference.png.profile.json`: normal oda, 137 3D draw call; medyan 17,961 ms / p95 23,681 ms.
- `previews/batch-after.png.profile.json`: son alt-kaburga denemesi, 123 draw call; medyan 17,718 ms / p95 23,829 ms.
- Sayıdaki azalma (~%10) performans kazancı kanıtlamaz: p95 iyileşmedi, render primitive sayısı 145.903 → 146.419 yükseldi; birleşmiş bounds/culling maliyeti ayrı ölçülmeli.
- Gerçek görüntüde deney sırasında saldırı üçgeni kayboldu. Geniş birleştirmede ince kontur detayları da değişti. Üçgen sayısını koruyan otomatik test görsel doğruluğu kanıtlamadı. ArrayMesh ile işareti yeniden kurma denemesi de görüntü sorununu gidermedi; o değişiklik geri alındı. Kesin kök neden henüz saptanmadı; renderer hatası olduğu iddia edilmez.
- `previews/batch-restored.png`: normal uygulamada koyu kenarlı saldırı işareti yeniden görünür. Son Windows headless smoke **74/74 PASS**; deneyin default kapalı olduğunu da kontrol eder.

Bir örneklem çifti, sabit kadraj ve wall-clock ölçümü: GPU zamanı, sürekli 60 FPS, genel FPS artışı veya iPhone kanıtı değildir. Profil API başvurusu ve önceki kapsam `CELLULAR_DEPTH_VALIDATION.md` içinde.

## Sonraki karar

Bu denemeyi yeni test sayılarıyla başarılı göstermeyin veya otomatik olarak yeniden etkinleştirmeyin. Daha fazla runtime birleştirme yerine source/export tarafındaki oda gruplaması ve renderer davranışı ayrı, küçük bir deneyde incelenmeli. Savaş okunurluğu korunmadan draw-call kazancı kabul edilmez. Mevcut oyun hâlâ sanat prototipidir; genel ADA hedefi tamamlanmadı.

Kaynak API: [Godot SurfaceTool](https://docs.godotengine.org/en/4.6/classes/class_surfacetool.html). API belgesi mesh ekleme yöntemini açıklar; görsel eşdeğerlik garantisi vermez.
