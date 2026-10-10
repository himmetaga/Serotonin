# Nefes — yeni görsel hedef

10 Ekim 2026. Kullanıcı “Tamam devam et” diyerek bu görsel yönün uygulanmasını istedi. Kapsam: mevcut Godot arenasında tek Blender zar odası, ışık ve yüzey deneyi.

## Tasarım kararı

İç dünya, birbirine bağlı kıvrımlı zar mimarisiyle anlatılır. Nefes odaları, ince kılcal hatlar ve ışık geçiren bir kapak aynı biçim diline aittir. Ana duygu, büyük ve yaşayan bir bedenin içindeki küçük kuryenin şefkatli yolculuğudur.

- Kompozisyon: üstten üç çeyrek oyun kamerası, üç derinlik katmanı, geniş ve okunabilir orta alan. Ön kıvrımlar çerçeve oluşturur; uzak zarlar ölçeyi büyütür.
- Odak: önce inci İlmek ve altın iplik, sonra teslimat kapağı, ardından çevre. Karakter yüksekliği görüntünün yaklaşık %7'si.
- Biçim: asimetrik uzun kıvrımlar, yumuşak kemerler, dallanan kılcal çizgiler. İlmek'in yüzü, ince kanatları ve ipliği küçük ölçekte ayrışmalı.
- Yüzey: saten inci gövde, ince ışık geçiren zar kenarı, mat koyu boşluk, ölçülü kabuk parlaklığı. Yakın biçimlerde ince doku; oynanabilir zeminde düşük ayrıntı.
- Palet: inci, soluk mercan, petrol, mürekkep; gölgelerde az miktarda mor. Altın yalnız iplik ve etkileşimde güçlü vurgu.
- Işık: tek zar kapağından sıcak yayılmış ışık, serin ortam dolgusu, temas gölgeleri. Zemin ve karakterlerde orta tonlar korunmalı.

## Üretim sınırı

Tek yerleşik görsel üretim çağrısı. Ayrı ajan, varyant serisi veya Blender yeniden üretimi yok. Tam prompt `nefes-v2-prompt.txt` içinde. Eski oynanabilir prototip ve modeller korunur.

Bu kare Blender/Godot uygulaması için hedef olabilir; geometrisi, kamera eşleşmesi, mobil shader maliyeti ve hareket okunaklılığı ayrıca sınanmalıdır. İnce zar etkisi uygulamada az sayıda yüzeyle veya opak kenar ışığıyla çözülebilir. Görseldeki ışık ve kompozisyonu elde etmek için yüksek poligon sayısı şart değildir.

## Üretilen kare ve inceleme

`nefes-v2.png`, yerleşik `image_gen` aracıyla tek çağrıda üretildi; harici referans görsel kullanılmadı. Tam prompt yan dosyada saklandı. Kaynak görselin proje kopyası oluşturuldu. Görsel yön kullanıcı tarafından ilerletilmek üzere kabul edildi; konseptin birebir teknik üretim onayı olduğu varsayılmaz.

Gözlem: İlmek, Nefes kapsülü ve iplik karanlık boşluk üzerinde ayrışıyor; kıvrımlı yol muhafızdan ışıklı kapağa kadar yön gösteriyor. Katmanlı zar kemerleri beden ölçeğini güçlendiriyor; koyu boşluk ile sıcak zemin arasında değer farkı var. Metin ve arayüz yok.

Prompttan sapmalar: kamera istenen ortografik oyun açısına göre daha alçak ve perspektifli; çevredeki kılcal detay yoğunluğu hareketli oyunda dikkat dağıtabilir. Konseptin tüm detaylarını modellemek yerine üst oyun açısında ana kıvrımlar, boşluklar ve ışık hiyerarşisi korunmalı. Bu görüntü motor renderı, Blender mesh'i veya mobil performans kanıtı olarak sunulmaz.
