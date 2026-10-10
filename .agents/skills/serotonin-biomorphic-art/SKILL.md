---
name: serotonin-biomorphic-art
description: Direct Serotonin's ethereal biomorphic concept art and translate it into Blender geometry and Godot materials. Use for cellular architecture, membranes, chitin, art briefs, and visual quality reviews in this project.
---

# Serotonin — biyomorfik sanat üretimi

Bu beceri projeye özgüdür; bir modelin yeniden eğitildiğini veya harici araçların kurulduğunu göstermez. Kullanıcı kararları için önce kökteki `AGENTS.md` ve `SEROTONIN_CREATIVE_DIRECTION.md` dosyalarını oku.

## Görsel dil

- Mimariyi süslenmiş taş olarak değil, büyümüş bir taşıyıcı ağ olarak tasarla: kalın ana kaburgalar → incelen ikincil lifler → yer yer gerilmiş zarlar. Gözenek boyutu ve lif yönü akışa, geçide ve görsel odağa hizmet etsin.
- Radyal kabuklar, bölmeli odacıklar ve segmentli kitin farklı morfoloji aileleridir; hepsine aynı rastgele hücresel desen uygulanmasın.
- Fildişi/şeftali yüzeyler, petrol mavisi derinlik ve seyrek sıcak kargo ışığı kullan. Tehdit ve etkileşimleri yalnız renkle ayırma.
- İlmek'in mevcut kimliğini koru: küçük koyu yüz, ince zar kanatları, canlı iplik ve taşınan özel kargo. Genel kapüşonlu gezgin veya fener klişesiyle değiştirme.
- Masalsı iç dünya, anatomik doğruluk iddiası taşımaz. Kanlı doku, korku estetiği ve saldırı işaretlerini örten görsel karmaşadan kaçın.
- Referans isimlerini biçim, malzeme ve kompozisyon özelliklerine çevir; yaşayan sanatçının doğrudan üslup taklidini isteme.

## Konseptten modele

Yeni hücresel geçit, zar veya kabuk brief'inde [biçim gramerini](references/form-grammar.md) oku. Bu referans morfoloji seçimini, değiştirilebilir üretim parametrelerini ve başarısızlık işaretlerini tanımlar; rastgele Voronoi veya aynı çaplı boruları bütün dünyanın ortak çözümü sayma.

1. Mevcut konsepti ve gerçek üçüncü şahıs oyun karesini karşılaştır. Kamera, ölçek, rota, kargo ve savaş açıklıklarını brief'e yaz.
2. Önce tek temsilî mimari parça seç. Ana kütle ve boşluklar başarılı değilse doku, sis veya bloom ekleyerek geçiştirme.
3. Blender'ın yerleşik Geometry Nodes/bpy araçlarını başlangıç seçeneği yap. Örnek bir yüzey ağı yaklaşımı: kontrollü üçgenleme → Dual Mesh → Mesh to Curve → Curve to Mesh. Bu, yüzeye bağlı hücresel örgüdür; gerçek hacimsel Voronoi veya kemik simülasyonu değildir. Boşlukların üzerinden zar yüzeylerini ayrıca üret.
4. Voronoi dokusu yalnız gölgelendirmedir; fiziksel delik ve siluet üretmez. Ağ birleşimlerinde kesişme, iç yüzey, normal ve gölge kusurlarını kontrol et.
5. Düzenlenebilir `.blend` dosyasını `art/source/`, çalışma zamanı GLB'yi `godot/assets/models/` altında tut. Prosedürel Blender düğümlerinin Godot'a aynen taşındığını varsayma; gereken haritaları bake et veya Godot materyali yaz.

## Işık ve çalışma zamanı

SSS, ışık geçirimi, alpha saydamlığı ve emisyon ayrı davranışlardır. Kenar parlaması tek başına SSS değildir. Kalın kaburga, ince zar ve cilalı kitin birbirinden okunmalıdır.

Renderer özelliklerini uygulama öncesi kurulu sürüm ve resmî belgeyle kontrol et. Araştırma tarihinde Compatibility ve Mobile'da yerleşik SSS/hacimsel sis yoktu; bu özellikleri açmak için renderer'ı sessizce değiştirme. Mobil odaklı alternatifler: kalınlık kontrollü stilize arka ışık, bake edilmiş ışık, derinlik sisi ve az sayıda atmosfer katmanı. Bunları fiziksel SSS/volumetrik ışık diye sunma. Saydam yüzeylerde sıralama ve overdraw riskini ölç.

## Kalite ve maliyet kapısı

- Önce bir parçayı gerçek üçüncü şahıs kamerada göster; bütün oda/karakter ailesini yeniden üretme. Yeni görsel üretim veya ağır bağımlılık kurulumu ayrı kapsam kararıdır.
- Uzakta dev ana kütleler; yakında seçilmiş malzeme ayrıntıları; savaş rotasında sakin zemin. Hücresel örgü her pikseli doldurmasın.
- Normal, gri ton ve azaltılmış efekt görünümünde İlmek, kargo, hedef ve saldırı hazırlığı seçilebilsin. Kamera çarpışması ve tek parmak hareket alanı korunsun.
- Görsel karşılaştırma dışında export üçgenleri, materyal/draw-call sayısı, texture belleği, collision proxy ve ölçülmüş frame time kaydet. Bütçeler ölçümle belirlenir; Windows sonucu iPhone performans kanıtı değildir.
- Bir uygulama turunda başarısız ana biçimi kaydet ve dar kapsamlı düzeltme öner. Konsept render'ını üretime hazır model veya kazanılmış ödül kanıtı sayma.

## Kaynak ve prompt kullanımı

Araç seçimi, doğrulanan GitHub listesi, teknik kaynaklar ve örnek prompt gerektiğinde [araştırma notunu](references/research.md) oku. Kaynak listesi bir kurulum talimatı değildir. Yeni konsept brief'i iki cümle ekosistem/anlatı, kısa malzeme-ışık tarifi ve bağımsız İngilizce prompt olarak teslim et; gerçek oyun üretimi istendiğinde ayrıca geometri ve renderer karşılığını yaz.

Prompt genişletirken değişmezleri ayrı tut: İlmek kimliği, üçüncü şahıs kamera, kargonun silueti, açık rota ve tehdit işaretleri. Genişletici yalnız varlığa özgü biçim/malzeme ayrıntısını değiştirsin; yeni karakter, görev veya kamera uydurmasın. Konsept ve runtime için aynı kabul ölçütünü kullanma: konsept görsel hedefi, runtime ise oynanabilir ve ölçülmüş karşılığıdır.

Yeni sanat düzeltmesinde [uygulamalı değerlendirme kartını](references/research.md#uygulamalı-değerlendirme-kartı) kullan. Kusuru biçim, malzeme, kompozisyon veya hareket olarak sınıflandır; önce tek baskın kusuru düzelt. İlerlemeyi yalnız üçgen sayısı veya testlerin geçmesiyle değerlendirme.

Mimariyi oynanışa veya canlı hareketlere bağlarken [uygulama derslerini](references/applied-study.md) oku: görüş çizgileri, rota/boşluk ayrımı, gerilim-dinlenme ritmi ve olay güdümlü malzeme hareketi. Bu referans araştırmadan çıkarılmış çalışma önerisidir; yeni bölüm veya efekt uygulama yetkisi değildir.
