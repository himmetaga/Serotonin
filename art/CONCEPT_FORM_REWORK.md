# Konsept biçim düzeltmesi — 10 Ekim 2026

Kullanıcının doğrudan isteği: mevcut amatör görünümü `concepts/nefes-v2.png` doğrultusunda düzelt. Bu tur yeni bölüm veya ücretli görsel üretimi değil, mevcut Blender kaynakları üzerinde sınırlı biçim çalışmasıdır. `serotonin-biomorphic-art` ve `create-game-assets` kuralları; dolu/boş oranı, incelen lifler, kaynak/runtime ayrımı ve gerçek oyun kamerasında kontrol için kullanıldı.

## Uygulama

- Odanın üç büyük opak halka tonozu, düzensiz hücresel yaprak tonozlara dönüştürüldü. Sınırlı sayıda kapalı zar paneli bırakıldı; eski kontur süsleri kaldırıldı.
- Girişte yolu örten üç kemer ve omuz bağlantıları yerine altı dışa açılan yan kök ve çatalları üretildi. Zemin, görev noktaları ve oynanabilir sınırlar değişmedi.
- İlmek'in kalın yumurta gövdesi inceltildi; ayrı küçük baş, uzun geriye süzülen iki zar ve dar ayaklar yapıldı. Yükseklik yaklaşık aynı tutuldu. Henüz rig veya yeni animasyon yok.
- Düzenlenebilir `source/membrane_room.blend`, `source/arrival_path.blend`, `source/ilmek.blend` ile ayrı Godot GLB'leri yeniden üretildi. Diğer karakter modelleri değiştirilmedi.

## Kontrol

| Varlık | Üçgen | Materyal | GLB bayt |
| --- | ---: | ---: | ---: |
| membrane_room | 21.276 | 3 | 498.036 |
| arrival_path | 3.308 | 2 | 82.392 |
| ilmek | 3.920 | 3 | 106.680 |

Blender kapalı parça kontrolleri: sıfır nonmanifold kenar / sıfır dejenere yüz. Parçalar kasıtlı kesişir; birleşik, sürekli doku veya baskıya hazır boolean mesh değildir. İlk 6×5 hücre taslağı 22.700 üçgenle 22.000 sınırını geçti ve dışa aktarılmadan durdu; 5×5 düzen bütçeyi geçti değil, bütçe içinde kaldı. GLB doğrulayıcı üç varlıkta PASS; Godot içe aktarma başarılı.

Son birleşik kaynakla Windows smoke **194 PASS**; yardımcı dokunma tam akışı normal ve azaltılmış hareket modlarında ayrı **34 PASS**, 13,75 simülasyon saniyesi, iki onaylı atılma, sıfır darbe. Bunlar gerçek insan oynanış testi veya iPhone testi değildir.

Gerçek Godot renkli başlangıç karesi: `previews/concept-form-rework.png`. Arena gri QA karesi: `previews/concept-form-arena-gray.png` (sentetik karşılaşma konumu). Her ikisi görsel olarak incelendi. Eski görünüm: `previews/arrival-branch-runtime.png`.

Oda + giriş sonrası, **son İlmek değişiminden önceki** 120 örnek Windows AMD Compatibility kaydı: median 16,653 ms, p95 17,4 ms; anlık 145 draw call / 201.122 primitive. Bu son karakterli sahnenin profili, GPU süresi veya iOS performans kanıtı değildir.

## Sanat kapısı henüz geçmedi

Yeni geometri kalın halka ve kafesli giriş sorununu azaltıyor; konseptin yarı saydam, ışıkla büyülenmiş mimarisini henüz yakalamıyor. Hücre kenarları poligonal/tel kafes gibi, kök birleşimleri kesişmeli, gölgeler sert ve zemin fazla düz. Muhafız ile kargo kaba taslak olarak kalıyor. Malzemeler opak; gerçek SSS, hacimsel ışık veya geçirgen zar uygulandığı iddia edilmez.

Sonraki sınırlı sanat işi: mevcut lif birleşimlerini sürekli yüzey hissine yaklaştırmak ve ışık/derinlik kompozisyonunu düzeltmek; sonra muhafız silueti. Yeni aile, pahalı üretim ve iPhone doğrulaması bu kaydın kapsamında değil. Apple Design Awards hedef, kazanma garantisi değil.
