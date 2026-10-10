# Giriş geçidi — Windows doğrulaması

10 Ekim 2026. Kapsam: mevcut arenaya bağlı kısa yaklaşma yolu ve bu parçanın tek sanat düzeltmesi. Tam bölüm, final sanat veya iOS doğrulaması değildir.

## Mevcut uygulama

- Yeni başlangıç `(-12, 0, 1)`; giriş hareket alanı X=-14…-6,8 / Z=0…2 ile eski arena alanının birleşimi. Aradaki boşluk yürünebilir büyük dikdörtgen yapılmadı.
- Kaynak `art/source/arrival_path.blend`, tarif `art/tools/build_arrival_path.py`, runtime `godot/assets/models/arrival_path.glb`. Oda kaynağı korunur; Side_Fold_L ve daha önce değiştirilen Side_Fold_R yalnız oyun sahnesinden kaldırılmıştır.
- Düz geçit, arena çekirdeğinin X=-7,35 sınırında biter; aynı düz yüzey üzerinde üst üste binme önlenir. Girişteki kaburgalar kamera çarpışması taşır. Kontrol, görev aşamaları ve kayıt şeması değişmedi.

## Bu turun sanat düzeltmesi

Önceki `previews/arrival-path-runtime.png` karesinde üç düzenli kemer kargo bakışını böler; eşit boru halkası hissi verir. Tek değişiklik ailesi: daha yüksek, yana eğilen ve tepede incelen ana kaburgalar; komşu kaburgaları farklı omuz yüksekliklerinden bağlayan dört ince lif. Zemin ve kamera parametreleri korunur.

Yeni kareler:

- `previews/arrival-branch-runtime.png`: gerçek Godot başlangıç kamerada normal renk, statik QA.
- `previews/arrival-branch-gray.png`: aynı başlangıç ve ışık, gri ton.
- `previews/arrival-arena-gray.png`: muhafız hazırlığı, sabit arena QA konumu `(-5,0,1)`.

Görsel sonuç: başlangıçta kargo/arena yönü ön kemerin tepesinden bağımsız okunuyor; ince bağlantılar üst/yan bölgede kalıyor. Gri karede İlmek, kargo ve yürüme şeridi ayrılıyor; karakter üzerindeki sert gölge malzeme okumasını zayıflatıyor. Arena QA karesinde koyu kenarlı hamle üçgeni görünür; bu tek hazırlık pozu bütün savaş açılarını doğrulamaz.

**Final sanat kapısı geçmedi.** Büyük opak oda kıvrımları, kalın boru dili, düz zemin, sert gölgeler ve kaba karakterler hedef `concepts/nefes-v2.png` ile hâlâ belirgin fark taşır. Lif birleşimleri kaynakta kapalı parçaların kesişmesidir; kaynatılmış sürekli ağ değildir. Non-manifold sayısının sıfır olması bu kesişimleri ya da bütün modelin tek kapalı hacim olduğunu kanıtlamaz. Gerçek zar/SSS/volumetrik ışık eklenmedi.

## QA konumu düzeltmesi

Muhafız capture'ı yeni PLAYER_START konumunu kullanınca savaşı koridordan gösteriyordu. `--capture-stage=guardian` ve açık kabuk capture'ı artık yalnız sentetik QA için eski arena konumuna ve RIGHT yönüne snap eder; hedef kilidi bundan sonra alınır. Normal başlangıç ve checkpoint davranışı değiştirilmedi. Eski `entry-arena-gray.png` arena karşılaştırma kanıtı değildir; doğru kare yukarıdaki `arrival-arena-gray.png`.

## Bu turda çalıştırılan kontroller

| Kontrol | Sonuç |
| --- | --- |
| Blender 5.2.1 LTS background export | Exit 0; 3.120 üçgen, 2 materyal, 2 grup, 2 UV mesh; 0 non-manifold kenar / 0 dejenere yüz |
| Yerel GLB kontrolü `node art/tools/validate_glb.mjs art/arrival_path_manifest.json` | PASS; 77.940 bayt; kaynak/export üçgen uyumu ve 3.500 bütçe |
| Godot 4.7.2 editor import | Exit 0 |
| `tests/smoke.gd` | 181 PASS; arena 435, giriş/birleşim 75, tam ortak sınır 5 destek örneği dahil |
| `tests/assisted_flow.gd -- --flow-motion` | 34 PASS; 13,75 simülasyon saniyesi / 2 onaylı atılma / 0 darbe |
| `tests/assisted_flow.gd` azaltılmış hareket | 34 PASS; aynı simülasyon sonucu |

Dokunma testleri girdi olaylarıyla yeni başlangıçtan teslimata ilerler; insan oyun süresi, doğal jest hata oranı veya eğlence ölçümü değildir. Ekran görüntüleri Windows Compatibility / AMD Radeon Graphics üzerinde alınmıştır. Bu turda yeni performans profili yok; önceki geçit profili eski geometriye aittir. iPhone FPS/bellek/dokunma testi yapılmadı. Blender `use_nodes` için gelecekteki 6.0 kaldırma uyarısı verdi; export hatası değil.

## Sonraki gerçek kalite kapısı

Geçidi sürekli süsleyerek tam bölüm yerine koyma. Sonraki kapsam seçimi, mevcut karşılaşmadan önce kargonun iplik özelliğini anlatan anlamlı çevresel eylem ve bölüm ritmidir; geniş üretim ayrıca onay gerektirir. Nihai mimari, karakter/savaş animasyonu, Daralma boss, insan playtest'i ve Mac/iPhone doğrulaması hâlâ eksik.

Bu çalışma `serotonin-biomorphic-art` biçim grameri ve `create-game-assets` gerçek oyun ölçeği/GLB kabul kapılarıyla yönlendirildi. Yeni ücretli görsel, harici eklenti veya ajan ekibi kullanılmadı.
