# Biyomorfik biçim grameri

10 Ekim 2026. Kullanıcının dört disiplininden ve `create-game-assets` sanat yönü/3D aktarım referanslarından türetilmiş üretim önerisi. Model eğitimi, eklenti kurulumu veya sanat kalitesi onayı değildir. Kaynak taraması `research.md` içinde; bu dosya kaynak listesini tekrarlamak yerine modelleme kararlarını tarif eder.

## Önce morfoloji ailesini seç

| Aile | Üretim mantığı | Kaçınılacak sonuç |
| --- | --- | --- |
| Delikli mineral kabuk | Radyal ya da odacıklı ana yüzey; taşıyıcı bölgeler kalın, açıklıklar gerçek geometri. Simetriyi seçilmiş bölgelerde boz. | Bütün yüzeye aynı boyda altıgen delikler; doku ile sahte boşluk. |
| Lifli mimari | Birkaç ana taşıyıcı hat, onlara bağlanan incelen ikincil lifler; açıklık büyüklüğü rota ve odak yakınlığına göre değişir. | Aynı çapta eşit aralıklı kemerler; rastgele boru yığını; birleşmeden kesişen lifler. |
| Gerilmiş zar | Sınır eğrileri ve bağ noktaları önce; aradaki yüzeyde kontrollü sarkma, kenara doğru kalınlaşma. | Bağsız jöle levhası; bütün yüzeyi aynı sinüsle sallama; alpha ile biçim eksikliğini gizleme. |
| Segmentli kitin | Üst üste oturan plakalar, aralarında koyu eklem boşluğu; açılacak parçanın pivotu eklemde. | Tek parlak küre; yüzeye çizilmiş ama hareketle açılmayan zırh dikişi. |

Bunlar biyolojik simülasyon değil, şiirsel biçim aileleridir. Yapıyı bir aileye oturt; ikinci aileyi yalnız işlevsel bir bağlantı için kullan.

## Blender brief'inde anlamlı parametreler

- **Taşıyıcı hatlar:** başlangıç/bitiş, dallanma noktası, eğrilik ve kalınlık profili. Tüm noktaları aynı rastgeleliğe bağlama.
- **Yoğunluk alanı:** rota, kargo odağı ve kamera görüşüne olan uzaklığı ayrı girdiler olarak düşün. Kargo arkasında sakin boşluk; seçilen tonozlarda daha yoğun örgü önerisi, fiziksel büyüme yasası değil.
- **Gözenekler:** boyut aralığı, uzama yönü ve kenar kalınlığı. Önce büyük açıklıkları siluette kur; mikrogözenek yalnız ekranda okunacağı yerde.
- **Zar:** bağ noktaları, sarkma miktarı, kenar/merkez kalınlık farkı. Kalınlık maskesi optik görünümü yönlendirebilir; fiziksel SSS olduğunu varsayma.
- **Kitin:** plaka bindirmesi, eklem boşluğu, dönüş sınırı ve açıklığın okunacağı kamera açısı.
- **Rastgelelik:** seed'i kaydet ama sabit seed'i kalite veya kimlik tutarlılığı kanıtı sayma. Kontrollü asimetri ana taşıyıcıyı ve açık rotayı bozmasın.

Yerleşik bpy/Geometry Nodes başlangıç yolu. Dual Mesh yüzeye bağlı bir örgü fikridir; gerçek hacimsel Voronoi yerine geçmez. Curve tabanlı kaburgalarda uçlar, birleşimler ve kesit incelmesi ayrıca çözülür. Bu araştırmada Dual Mesh ve Curve to Mesh belge sayfaları açılamadı; düğüm soketleri ve sürüm davranışı uygulama sırasında kurulu Blender ile doğrulanmalıdır.

## Malzeme ve kompozisyon sözleşmesi

Kalın taşıyıcı: mat fildişi, geniş yumuşak ışık geçişi. İnce zar: şeftali, kenarda lif ve kontrollü arka ışık hissi. Kitin: daha düzgün yüzey, eklemde koyu ayrım. Bu üçü aynı ışıkta ayırt edilemiyorsa ek efekt değil, yüzey ve roughness ayrımı üzerinde çalış.

Sıcaklık bütün sahneyi tek turuncuya dönüştürmesin: petrol mavisi derinlik mekânı ayırır; kargo seyrek sıcak vurgu olarak kalır. Siluet ve gri ton kontrastı renk uyumundan bağımsız kontrol edilir. Karakteri küçültmek veya kamerayı uzaklaştırmak tek başına görkem üretmez; oynanabilir görüşte dev ana kütle ve sakin negatif alan gerekir.

Konseptte istenen SSS/volumetrik ışık ile Godot'ta uygulanan yaklaşımı ayrı yaz. Proje Compatibility kullanıyor; renderer değişikliği bu sanat brief'inin örtük parçası değildir. Saydam zar için gereken alanı sınırla ve gerçek kamerada sıralama/overdraw kontrol et.

## Araştırmayı üretimde sınama

Tek varlık üzerinde, aynı kamera/ışık/oyun durumuyla karşılaştır:

1. Mat gri: ana taşıyıcı ve gerçek boşluklar seçiliyor mu?
2. Oyun ölçeği: İlmek, kargo, yol ve saldırı hazırlığı ortamdan ayrılıyor mu?
3. Malzemeli görünüm: kaburga, zar ve kitin farklı davranıyor mu?
4. GLB aktarımı: siluet, normal, pivot ve materyal ayrımı korunuyor mu?
5. Hareket gerekiyorsa: bilgi azaltılmış hareket modunda da okunuyor mu?

Teknik kontrol geçip sanat kontrolü kalabilir. Başarısızlığın baskın nedenini ve tek sonraki düzeltmeyi kaydet; o sırada model ailesini genişletme. Bu kartın yazılması, burada bir varlığın test edildiği anlamına gelmez.

## Ek araçların rolü

[Sverchok](https://github.com/nortikin/sverchok) skaler/vektör alanları ve parametrik geometriyi; [Tissue](https://github.com/alessandro-zomparelli/tissue) hesaplamalı tasarımı araştırmak için adaydır. İkisi Blender eklentisi, Codex skill paketi değil. Somut bir yerleşik araç eksikliği ve sürüm testi olmadan kurulum önerme.

Yeni incelenen [Khronos glTF-Blender-IO](https://github.com/KhronosGroup/glTF-Blender-IO) resmî aktarım kaynağıdır; README Blender'ın glTF aktarımını zaten içerdiğini ve kendi CI'ında export/round-trip doğrulaması kullandığını belirtir. Çıkarımımız: ayrıca exporter kurmak yerine mevcut Blender export'unu ve gerçek Godot import'unu kontrol etmek. README'nin sürüm tablosunu kurulu Blender sürümünün kanıtı sayma.
