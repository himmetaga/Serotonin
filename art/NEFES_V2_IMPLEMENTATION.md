# Nefes V2 — ilk oda uygulaması

10 Ekim 2026. Kullanıcının konsept sonrası devam onayıyla mevcut arena yenilendi. Tek Luna çalışanı ilk Blender çevresini hazırladı; ana ajan geometriyi inceledi, açık zar odası biçimlerini düzeltti ve Godot sunumunu uyguladı. Astra bu turda çağrılmadı. Yeni görsel üretimi ve tüm karakter ailesinin yeniden üretimi yapılmadı.

## Somut çıktı

- Düzenlenebilir `source/membrane_room.blend`, çalışma zamanı `../godot/assets/models/membrane_room.glb`, tekrar üretim betiği `tools/build_membrane_room.py`.
- Kapalı ve yuvarlatılmış ana yüzey, kıvrımlı arka geçit, açık zar odaları, yan kıvrımlar ve alt bağlantı kaburgaları. Önceki oyun alanı ve görev noktaları korunur. Arka geçit bu turda dekor; yeni oynanabilir bölge değildir.
- Kaynak model 11.462 üçgen, 3 malzeme; sıfır dejenere yüz ve sıfır manifold olmayan kenar. İki uzak katmanda paylaşılan odacık mesh'leri tekrar kullanılır; gerçek sahne geometrisi kaynak model sayısından fazladır.
- `membrane_presentation.gd` sunumu oyun durumundan ayırır: mat yüzey, iki yumuşak temas gölgesi, az sayıda ışık, uzak odacıklar. Opaque shader zar kenar ışığını taklit eder; gerçek ışık geçiren cilt değildir.
- Kamera ve başlangıç yüz yönü İlmek'i daha okunaklı gösterir. Duraklatma görünür ve erişilebilir kalır; hareket/saldırı butonu eklenmedi.

## Yapılan kontroller

Godot 4.7.2 Windows Compatibility içe aktarımı başarılı. Sunum ve yüz yönü değişiklikleriyle 49/49 smoke kontrolü geçti. Son geometri değişimi sonrası yeniden içe aktarım ve GLB doğrulaması başarılı; kaynak/dışa aktarım üçgen sayısı aynı. Grafik penceresinde shader derlemesi ve son başlangıç görüntüsü incelendi; import/render loglarında hata bulunmadı.

İlk yakalamada ışık taşması ve kopuk zar biçimleri görüldü; bu nedenle tek çevre modelinde düzeltmeler ve yeni kontrol yakalamaları yapıldı. Son görüntü `previews/nefes-v2-runtime.png`. Görsel, konsept illüstrasyonu yerine gerçek motor çıktısıdır.

## Kalite sınırı

Bu teknik ve görsel ilk aktarım, konseptin büyüleyici atmosferini henüz karşılamıyor. Çevrenin biçimleri fazla sade, katman geçişleri ve gölgeler sert; mevcut karakterler ilk geçiş modelleri. Sonraki görsel iş, tek bir yakın çevre parçasında kıvrım, ışık ve yüzey kalitesini çözmeli. Yeni bölgelere geçilmemeli. İnsanla oynanış testi, kare süresi/GPU profili ve iOS cihaz kontrolü yapılmadı.

Shader API başvurusu: [Godot spatial shader](https://docs.godotengine.org/en/stable/tutorials/shaders/shader_reference/spatial_shader.html). Çevre/sis başvurusu: [Environment](https://docs.godotengine.org/en/stable/classes/class_environment.html). İnce dokusal ayrıntılar test edilmeden mobil maliyet kabulü verilmez.
