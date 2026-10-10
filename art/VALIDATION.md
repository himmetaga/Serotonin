# İlk Blender / Godot geçişi — 9 Ekim 2026

## Üretilen varlıklar

| Model | Üçgen | Malzeme | Kaynak |
| --- | ---: | ---: | --- |
| İlmek | 3.832 | 3 | `source/ilmek.blend` |
| Nefes | 576 | 1 | `source/nefes.blend` |
| Kıskaç | 2.564 | 3 | `source/kiskac.blend` |
| Bahçe | 4.192 | 3 | `source/garden.blend` |

Blender 5.2.1 LTS ile gerçek mesh üretimi, kaynak kaydı ve GLB aktarımı yapıldı. Her modelde sıfır dejenere yüz ve sıfır manifold olmayan kenar. Kapalı ayrı parçaların örtüşmesi bilinçli; bunlar 3D baskı için tek birleşik katı değil. Dış model/doku kullanılmadı.

`node art/tools/validate_glb.mjs` dört dosyada PASS: GLB başlığı, boyutları, üçgen/malzeme bütçeleri ve kaynak geometri raporu kontrol edildi. `.blend` dosyalarında stüdyo ışığı/kamera bulunur; oyun GLB'leri bu stüdyoyu içermez. Geometrinin düşük maliyeti, cihaz performans ölçümü yerine geçmez.

## Görsel kontrol

Blender renderları tek tek açıldı. İlk İlmek'te görünmeyen iplik silueti düzeltildi; kanatlar inceltilip hafif kavis verildi. Astra güncel İlmek'in ilk biçim/malzeme geçişini kabul etti. Nefes'in gerçek merkez açıklığı ve render kadrajı düzeltildi.

Godot 4.7.2 Windows/OpenGL Compatibility gerçek penceresinde görüntü alındı; modeller, zemin yüksekliği ve metin yerleşimi incelendi. İlk sarı ışık sapması Astra incelemesiyle tespit edildi ve ana ışık nötrleştirildi. Bu, bitmiş atmosfer veya üretime hazır sanat onayı değil.

Son düzeltmede oyun içindeki altın malzeme kopyalarının emisyonu kapatıldı; kaynak GLB albedo rengi korundu. Astra son `previews/godot_arena.png` ve `previews/godot_guardian.png` görüntülerini inceleyerek ilk oynanabilir görsel geçişi kabul etti. Yan açıdaki dar İlmek silueti ve yüzey parlaklığı sonraki iyileştirme turuna bırakıldı. Muhafız görüntüsü sabit QA düzenidir: saldırı ve sonraki aşamanın bağ işaretleri birlikte gösterilir; normal oynanışta bağ noktaları muhafız çözüldükten sonra görünür.

`asset_manifest.json` yeniden üretim sırasında yalnız teknik kontrolü kaydeder; otomatik olarak görsel onay vermez. İnsan/ajan gözlem kaydı bu belgedir.

## Oynanış / otomasyon

Ana ajan tarafından çalıştırılan sabit 60 Hz smoke testi: **49/49 PASS**. Dört GLB'nin yüklenmesi; kargo alma; yuvada bekleme; erken teslimat engeli; iki muhafız isabeti; bağ sırası/menzil; teslimat; sıfırlama; parmak sahipliği; tek temasta tek atılma; duraklatmada girdi temizliği; azaltılmış hareket; muhafız arena sınırı ve saptırma penceresi kontrol edildi. Geometrik süpürme testi atılma sırasında hedefin üzerinden geçilmesini de kontrol eder.

`launch.ps1` PowerShell sözdizimi kontrolünden geçti. İlk Godot içe aktarımı sandbox içinde kullanıcı ayar klasörüne erişemedi; izinli yeniden çalıştırma hatasız tamamlandı. Son smoke testi çalışma alanı içindeki log dosyasıyla çalıştırıldı.

## Açık işler / sınırlar

- İnsanla oynanış ve tek parmak kullanılabilirlik testi yapılmadı. Otomasyon eğlenceyi kanıtlamaz.
- Rig, final karakter animasyonu, ses, haptik, kayıt ve tam hikâye yok. Bahçe şu an açık merkezli arena blockout'u.
- Windows görüntüsü ve başsız testler iOS derlemesi veya cihaz testi değil. Mac/iPhone testleri kullanıcının kararıyla son aşamada.
- Düşük/büyük ekranlar, erişilebilir yardımcı kontrol ve uzun oturum performansı ayrıca doğrulanmalı.
