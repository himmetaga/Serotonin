# Beden içi doku odası — 10 Ekim 2026

Doğrudan kullanıcı isteği: konsept görsele göre, insanın bedeninin içinde hissedilen büyüleyici tasarım. Bu tur tek mevcut çevre varlığı üzerinde sınırlı çalışma; ücretli görsel, yeni model ailesi, renderer değişimi veya dış bağımlılık yok.

## Değerlendirme kartı

- Önce: `previews/concept-form-rework.png`. Baskın kusur: kuru dal benzeri giriş; beden yerine dekoratif kafes okunması.
- Değişmezler: üçüncü şahıs kamera, İlmek, kargo, görev/savaş noktaları, düz oynanabilir zemin, tek parmak kontrol ve azaltılmış hareket.
- Düzeltme: girişteki altı çıplak üst kök/çatallar kaldırıldı. Yerine iki büyük kıvrımlı şeftali doku tabakası, gerçek oval açıklıklar ve gömülü sınır lifleri yapıldı. Dekoratif duvarlar arena/rota dışında; kamera çarpışması mevcut oda sistemiyle üretilir. Zemin ve görevler değiştirilmedi.
- İlk deneme `previews/body-chamber-first.png`: basamaklı açıklıklar, karakteri karartan duvar gölgesi; başarısız. Açıklık sınırları elipse izdüşürüldü, yalnız doku üzerinde bir Catmull-Clark yumuşatma uygulanıp GLB'ye bake edildi. Büyük dekoratif doku gölge atmaz, ışık alır. Karakter/savaş gölgeleri korunur.
- Son: `previews/body-chamber-final.png`, aynı başlangıç kamera/oyun durumu. `previews/body-chamber-arena-gray.png` sentetik arena gri kontrolü. İki kare görsel incelendi.

## Sonuç ve kalan kusur

Oval boşluk ve büyük sıcak yüzeyler beden içi hissini artırıyor. **Büyüleyici konsept kalite kapısı geçmedi.** Tabakalar fazla tekdüze duvar gibi; uzak mimari hâlâ kafes, muhafız ve kargo kaba taslak. İnce gömülü lifler ile doku arasında birleşim kesişmesi sürer. Sonraki sınırlı sanat önceliği farklı mesafelerdeki odacıkların ve doku bağlantılarının ana kütle kompozisyonu; daha fazla paralel çizgi veya bloom değil.

`serotonin-biomorphic-art` ve `create-game-assets`, baskın kusuru önce ana geometriyle düzeltme, gerçek açıklık, kaynak/GLB ayrımı ve oyun ölçeğinde kontrol kararını yönlendirdi. Yüzeyler opaktır; malzeme lif varyasyonu stilizedir. Gerçek SSS, ışık geçirimi veya hacimsel sis uygulanmış değildir. Anatomi biyolojik doğruluk iddiası taşımaz; kanlı/korku estetiği kullanılmaz.

## Teknik kayıt

- `source/arrival_path.blend`, `godot/assets/models/arrival_path.glb`; tarif `tools/build_arrival_path.py`.
- Son GLB: 8.212 üçgen, 3 materyal/mesh grubu, 190.728 bayt; 3 UV mesh. Nonmanifold/dejenere sıfır. Ayrı kapalı parçalar kesişebilir; boolean birleştirme/rig/LOD yok.
- Önceki giriş sınırı 3.500 üçgendi. Yalnız doku yumuşatması için bu varlığın sınırı 9.000'e çıkarıldı; kontrol kafesi değil gerçek export üçgenleri denetlendi. Kaynaklar yeniden yazıldı, Blender önceki `.blend1` yedeğini otomatik tutar.
- GLB doğrulayıcı PASS; Godot import başarılı. Smoke son kaynakla 196 PASS. Tam yardımcı dokunma normal ve azaltılmış hareket ayrı 34 PASS /13,75 sim sn /2 onaylı atılma /0 darbe. Gerçek insan veya iPhone testi değildir.
- Son Windows AMD Compatibility 120 kare örneği: median 16,625 ms, p95 17,589 ms; anlık 146 draw call /200.266 primitive. Wall-clock frame pacing dahil; GPU zamanı ve iOS kanıtı değil. Gösterim alanı/overdraw için ayrı GPU ölçümü yapılmadı; opak yüzey kullanımı tek başına mobil performans onayı değildir.
