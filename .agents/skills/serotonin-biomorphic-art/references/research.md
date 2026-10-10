# Biyomorfik ve eterik sanat — araştırma kaydı

Tarih: 10 Ekim 2026. Kapsam: kaynakların erişilebilirliği ve belgelenen amacı; kurulum, kod çalıştırma, model eğitimi veya yeni görsel üretimi yapılmadı. Depo README'si ürünün kalitesini, güvenliğini veya bizim donanımda çalışmasını kanıtlamaz.

## Kullanıcının verdiği yedi depo

| Kaynak | Doğrulanan amaç ve Serotonin kararı |
| --- | --- |
| [pinkpixel-dev/comfyui-llm-prompt-enhancer](https://github.com/pinkpixel-dev/comfyui-llm-prompt-enhancer) | ComfyUI'de LLM ile prompt genişletme; yerel Ollama ve API sağlayıcıları. MIT etiketi mevcut. Şimdilik gereksiz ek kurulum/çağrı; aynı brief mevcut oturumda hazırlanabilir. |
| [AnthusAI/openai-midjourney-prompt-generator](https://github.com/AnthusAI/openai-midjourney-prompt-generator) | GPT-3.5 tabanlı Jupyter prompt örneği, MIT. Deterministik görsel/3D üretim altyapısı değil. Yapılandırılmış brief fikri yararlı; notebook/API hattını taşımıyoruz. |
| [altryne/awesome-ai-art-image-synthesis](https://github.com/altryne/awesome-ai-art-image-synthesis) | Araç ve prompt kaynak koleksiyonu. Keşif dizini; her bağlantının güncelliği ve lisansı ayrıca kontrol edilmeli. Hazır üretim pipeline'ı değil. |
| [dair-ai/Prompt-Engineering-Guide](https://github.com/dair-ai/Prompt-Engineering-Guide) | Prompt teknikleri, örnek ve değerlendirme kaynakları. Serotonin karşılığı: rol + açık kısıt + örnek + kabul ölçütü. Sanat veya mesh kalitesini otomatik garanti etmez. |
| [f/awesome-chatgpt-prompts](https://github.com/f/awesome-chatgpt-prompts) | `f/prompts.chat` adresine yönleniyor. Topluluk prompt kütüphanesi; doğrudan bir Blender/Godot becerisi değil. Genel rol metinleri yerine proje kimliği sabitlenmeli. |
| [mattwilliamson/comfyui-ai-gamedev](https://github.com/mattwilliamson/comfyui-ai-gamedev) | Hunyuan3D 2.1, video kareleri ve prompt araçları. README şekil için 10 GB, dokularla 21 GB VRAM belirtiyor; bunlar yazarın gereksinimleri, bizim testimiz değil. README MIT bildiriyor ve model ağırlıklarının farklı şartları olabileceğini söylüyor. Şimdilik ertelendi: donanım, lisans ve mesh temizliği maliyeti incelenmeden kullanılmayacak. |
| [SurrealByDesign/ComfyUI-Krea-Palette-Tools](https://github.com/SurrealByDesign/ComfyUI-Krea-Palette-Tools) | Referanstan palet/swatch ve renk cümlesi çıkarma. MIT. Yerel renk yolu API çağırmıyor; cloud üretim ayrı. Tüm ışık dağılımını veya stil tutarlılığını çözdüğü varsayılmamalı. Palet çıkarımı gerektiğinde aday. |

Yedisinin de proje sayfası erişildi. “İncelendi” burada kaynak taraması anlamındadır; bütün kodları denetlendi veya araçları kullanmayı pratikte doğruladık anlamında değildir. Yazılım lisansını eğitim verisi, model ağırlığı, referans görsel veya üretilen varlığın haklarıyla karıştırma.

## Ek kaynaklar ve yeni beceri başlıkları

- [Sverchok](https://github.com/nortikin/sverchok): düğüm tabanlı parametrik geometri, yüzeyler ve alanlar; GPL-3.0 etiketi mevcut. Karmaşık geometri için aday, başlangıç zorunluluğu değil. Yerleşik Geometry Nodes yeterliyse bağımlılık ekleme. Kurulu Blender sürümüyle uyumluluk henüz test edilmedi.
- [Tissue](https://github.com/alessandro-zomparelli/tissue): hesaplamalı tasarım eklentisi; depoda tessellation, dual mesh ve reaction-diffusion bileşenleri var. Yüzeye uyarlanan tekrar ve hücresel biçim araştırması için aday. Kurulum, lisans ayrıntıları ve sürüm uyumluluğu bu turda doğrulanmadı; kullanımdan önce kontrol edilmeli.
- [Godot resmî demo projeleri](https://github.com/godotengine/godot-demo-projects): sahne ve efekt uygulaması için başvuru. README sürüme uygun dal kullanılmasını söylüyor; `master` geliştirme sürümüne ait. Oyuna bütün depoyu veya ileri renderer örneklerini körlemesine taşımayacağız.
- [Haeckel, Kunstformen der Natur — BHL](https://www.biodiversitylibrary.org/item/104650): tarihsel morfoloji kaynağı. Öğrenilecek özellikler: radyal simetri, odacık ritmi, delikli kabuk ile ana taşıyıcı arasındaki oran. Tarihsel illüstrasyon oyun için anatomik doğruluk kanıtı değildir; kullanılan taramanın hak kaydı ayrıca tutulur.
- [Silk Pavilion I — proje sahibinin açıklaması](https://www.oxman.com/projects/silk-pavillion-i): dijital ve biyolojik üretim, değişken lif yoğunluğu ve çevre koşulları ilişkisi. Serotonin için çıkarımımız: aynı kalınlıkta rastgele ağ yerine kontrollü yoğunluk/kalınlık değişimi. Eserin görüntülerini kopyalamak veya sanatçı üslubunu doğrudan taklit etmek değil.

Dört ana beceriye eklenen disiplinler: **alan güdümlü geometri**, **ana/ikincil/mikro biçim hiyerarşisi**, **malzeme optiği**, **üçüncü şahıs kompozisyonu**, **GLB/bake üretimi**, **mobil overdraw ve profil çıkarma**, **oynanış okunurluğu**, **hak/provenans kaydı**. Bunlar isim listesi değil; SKILL.md içinde çalışma ve kabul kurallarına dönüştürüldü.

## Renderer gerçeği

Projenin `godot/project.godot` dosyasında hem normal hem mobil rendering method `gl_compatibility`. Mevcut `membrane.gdshader` opak diffuse, rim ve düşük emisyon kullanıyor; gerçek SSS veya saydam zar üretmiyor.

[Godot'un resmî özellik tablosu](https://docs.godotengine.org/en/stable/tutorials/rendering/renderers.html) araştırma tarihinde şunları bildiriyor:

| Özellik | Compatibility | Mobile | Forward+ |
| --- | --- | --- | --- |
| Yerleşik SSS | Yok | Yok | Var |
| Hacimsel sis | Yok | Yok | Var |
| Derinlik/yükseklik sisi | Var | Var | Var |
| Glow | Var | Var | Var |

Destek, aynı sonuç veya aynı maliyet demek değildir. Forward+ mobilde desteklense de belgede mobil için kötü optimize edilmiş olarak işaretleniyor. Bu yüzden yalnız konsepte benzemek için proje renderer'ını değiştirmek bir sonraki adım değildir.

Üretim önerisi: ana kaburgaları opak tut; ince zarların ışık hissini kalınlık maskesi ve stilize ışık tepkisiyle ayrı ele al; uzak katmanlarda derinlik sisi ve düşük ayrıntı kullan. Gerçek saydamlık gereken alanı sınırlı tut. Bunlar fiziksel SSS'nin eşdeğeri değildir; gerçek kamerada görsel/profil testi gerektirir.

Blender belgeleri için bulunan resmî başvurular: [Dual Mesh](https://docs.blender.org/manual/id/5.0/modeling/geometry_nodes/mesh/operations/dual_mesh.html), [Principled BSDF](https://docs.blender.org/manual/uk/5.0/render/shader_nodes/shader/principled.html), [glTF aktarımı](https://docs.blender.org/manual/en/5.3/addons/scene_gltf2.html). Arama özetleri bulundu; tam sayfa açılışları erişim hatası verdi. Bu nedenle ayrıntılı sürüm/API doğrulaması tamamlandı sayılmaz. Uygulamada kurulu Blender sürümünün düğüm/API bilgisi ve export sonucuyla kontrol edilmelidir.

## Somut geometri ve malzeme ayrımı

- **Hücresel örgü:** siluette gerçek boşluk, dallanan kaburga ve kalınlık farkı. Yalnız Voronoi renk haritası yeterli değil.
- **Gerilmiş zar:** belirgin sınır halkası, merkezde incelen yüzey, kuvvet yönünde lifler; şekil dekoratif rastgele dalgalanma olmamalı.
- **Kitin:** birbirine oturan plakalar ve görünür eklem dikişleri; bütün varlığın tek parlak balon gibi görünmemesi.
- **SSS:** yüzey altında saçılma. **Transmission:** yüzeyden geçiş/kırılma. **Alpha:** görünürlük karışımı. **Emission:** ışık yayma görünümü. Bunlar aynı ayar değil.
- **GLB:** Blender node ağını oyun motoruna taşıyan genel shader formatı değil. Desteklenen PBR verileri, bake haritaları veya yeniden yazılan motor materyali gerekir; export sonrası karşılaştırma şart.

## Serotonin'e uyarlanmış brief örneği

Bu örnek öneridir; yeni bölüm veya karakter kararı değildir.

**Konsept:** Nefes yolunun kıyısında, kalın taşıyıcı liflerden ince zarlara açılan canlı bir geçit. İlmek'in kargosu karanlık açıklıkta sıcak bir odak oluşturur; sakinleşen muhafız geçidin doğal parçası olarak kalır.

**Malzeme/ışık:** mat fildişi kaburgalar, şeftali tonlu ince zarlar, daha düzgün ve koyu kitin; mavi-yeşil derinlik, tek yönlü yumuşak sıcak ışık. Ortam ışığı kargo ve açık zırh dikişlerinden daha baskın olmaz.

**Bağımsız İngilizce konsept prompt'u:**

```text
Concept art for Serotonin, a gentle single-player adventure inside a human.
Landscape 16:9, third-person perspective from behind Ilmek, a small pearl-bodied
courier with delicate membrane wings, a dark face and one luminous living thread
carrying a breathing capsule. Preserve a clear playable path and an uncluttered
combat clearing. A colossal living passage grows from thick branching ivory ribs
into finer cellular lattices and stretched peach membranes; pores vary in size
and fibers follow the structure rather than forming uniform decorative rings.
A calm segmented chitin guardian rests beside the passage. Warm light grazes thin
membrane edges; abyssal teal recesses and restrained atmospheric layers create
depth. Concentrate fine detail near selected surfaces, leave quiet negative space
around the courier and cargo. Painterly edges, tactile matte surfaces, restrained
bioluminescence, no gore, no industrial metal, no text, no HUD. This is a visual
target, not a claim of real-time mobile rendering.
```

Aspect ratio burada üretim niyetidir; kullanılacak aracın gerçek boyut seçeneği ayrıca ayarlanır. Midjourney bayraklarını veya Stable Diffusion negatif-prompt sözdizimini başka modele aynen yapıştırma. Sabit seed tek başına kimlik ve kompozisyon tutarlılığı garantisi değildir.

## Sonraki uygulama deneyi — henüz yapılmadı

Tek bir kaburga/zar geçit parçasını, mevcut üçüncü şahıs kameranın yakın ve orta mesafelerinde sınamak. Kabul: büyümüş mimari hissi; gerçek hücresel boşluk; kaburga/zar/kitin ayrımı; kargo ve saldırıların temiz okunması. Bir Blender karşılaştırma karesi ve gerçek Godot karesi yeterli başlangıç; tam oda ailesi üretmek kapsam dışı. Sonuç yetersizse önce ana geometriyi düzelt, efekt sayısını artırma.

## Ek inceleme — 10 Ekim 2026

Yedi depo sayfası yeniden erişilerek önceki kaynak kaydı kontrol edildi; yeni paket, model ağırlığı, API hattı veya eklenti kurulmadı. Bu çalışma model eğitimi değil, projede tekrar kullanılabilir araştırma ve üretim kurallarıdır. Yukarıdaki “henüz yapılmadı” başlığı ilk araştırma anına aittir; mevcut uygulamanın durumunu göstermez.

### Ek beceri seçimi

| Beceri / disiplin | Kullanım ve durum |
| --- | --- |
| `serotonin-biomorphic-art` | Projede mevcut; hücresel mimari, zar/kitin ayrımı ve temsilî parça kalite kapısı. Bu turda tamamı okundu. |
| `create-game-assets` | Mevcut; sanat yönü, 3D pipeline ve provenans referansları okundu. Konseptten mesh'e geçişte kamera, ölçek, normal, UV, pivot, collision ve kaynak kaydını birlikte kontrol etmek için kullanılacak. |
| `level-design` | Mevcut katalogda; görsel ölçek ile oynanabilir rota ve savaş boşluğunu birlikte tasarlamak için sonraki bölüm çalışmasına aday. Bu turda içeriği incelenmedi. |
| `game-feel` | Mevcut; zar hareketi ve teslimat tepkisini oyun olayına bağlamak için aday. Yeni efekt uygulanmadı. |
| `input-systems` ve `game-ui-ux` | Mevcut katalogda; tek parmak kontrol, güvenli ekran alanı ve azaltılmış hareket kontrollerinde kullanılacak. Bu turda yeni uygulama veya içerik incelemesi yok. |
| Godot shader / animasyon / profil çıkarma | Ayrı uzman beceriler mevcut oturumun kullanılabilir kataloğunda yok. Router'ın bu isimlerden söz etmesi kurulu olduklarını kanıtlamaz; gerektiğinde resmî belge ve kurulu motorla dar test yapılacak. |

### Parametrik üretim için araştırma sonucu

[Sverchok README](https://github.com/nortikin/sverchok), düğüm tabanlı parametrik geometri ile skaler/vektör alanlarını belgeliyor; listelenen Blender sürümleri 5.1, 4.5, 3.6 ve 2.8. Bu, projedeki Blender 5.2 ile test edildiği anlamına gelmez. [Tissue](https://github.com/alessandro-zomparelli/tissue) hesaplamalı tasarım için alternatif aday olarak kaldı. Öncelik yerleşik Blender araçları: ayrı kurulum ancak somut bir eksikliği giderirse değerlendirilecek.

Blender'ın İngilizce `latest` Dual Mesh, Curve to Mesh ve glTF belge adresleri bu turda da açılmadı (erişim aracında 402). Dolayısıyla bu sayfaların ayrıntıları okunmuş veya güncel API'leri doğrulanmış sayılmıyor. Kaynak uygulamaya alınırken kurulu Blender üzerinde test şart.

### Maliyet ve tutarlılık kararı

- [Prompt Enhancer](https://github.com/pinkpixel-dev/comfyui-llm-prompt-enhancer) isteği CLIP öncesinde genişletir. Her görsel için ikinci LLM çağrısı yapmak şimdilik gerekli değil; sabit proje brief'i yeniden kullanılacak.
- [AnthusAI notebook](https://github.com/AnthusAI/openai-midjourney-prompt-generator) GPT-3.5 ile prompt üretim örneğidir; deterministik oyun-varlığı üreticisi olarak değerlendirilmedi.
- [Krea Palette Tools](https://github.com/SurrealByDesign/ComfyUI-Krea-Palette-Tools) yerel palet çıkarımı ve metin yolu sunuyor; bu renk tutarlılığına yardımcı olur, ışık dağılımını ve geometriyi sabitlemez. Bulut üretimi ayrı ve ücretli yol olarak belgelenmiş.
- [AI Gamedev README](https://github.com/mattwilliamson/comfyui-ai-gamedev) şekil için 10 GB, dokulu hat için 21 GB VRAM belirtiyor. Donanım ve temiz mesh sonucu doğrulanmadan bu hattı kurmak maliyet açısından gerekçelendirilmiş değil.

Üretim sırası: tek temsilî geometri → Blender malzeme ayrımı → GLB aktarım kontrolü → gerçek Godot kamera karesi → gerekirse dar düzeltme. Daha ayrıntılı prompt veya daha fazla efekt, başarısız ana biçimin yerine geçmez.

## Uygulamalı değerlendirme kartı

Bu kart Serotonin'e özgü üretim önerisidir; biyolojik simülasyon, tamamlanmış uygulama veya kazanılmış kalite onayı değildir. `create-game-assets` sanat yönü, 3D pipeline ve provenans referanslarından uyarlanmıştır.

| Öğrenilecek beceri | Üretimde somut karşılığı | Kabul kontrolü |
| --- | --- | --- |
| Morfolojik sınıflandırma | Radyolarya için radyal kafes; odacıklı kabuk için kademeli bölmeler; kitin için üst üste oturan plakalar. Referansları tek rastgele Voronoi desenine indirgeme. | Mat gri görünümde, dokusuzken bile farklı biçim aileleri seçilebiliyor mu? |
| Alan güdümlü parametrik tasarım | Taşıyıcı hatlarda kalınlaşan kaburgalar; geçit ve ışık yönünde değişen gözenekler. Yoğunluk ve yönü ayrı parametreler olarak ele al. | Ağın neden o yönde büyüdüğü okunuyor mu; eşit boy halkalar veya rastgele boru yığınına mı dönüşmüş? |
| Ana/ikincil/mikro biçim hiyerarşisi | Önce dev tonoz ve boşluk; sonra kaburga ve zar; yalnız seçilen yüzeylerde mikro ayrıntı. | Küçük oyun karesinde ana kütle hâlâ güçlü mü? Yakın ayrıntı eksik ana biçimi saklamıyor mu? |
| Malzeme optiği | Kalın mat fildişi, ince gergin zar, daha düzgün kitin. SSS/transmission/alpha/emission davranışlarını ayrı tarif et. | Aynı ışık altında üç malzeme birbirinden ayrılıyor mu; hepsi parlak plastik gibi mi? |
| Anlatısal kompozisyon | Dev yapının karşısında küçük İlmek; kargo yakın odak; rota boyunca sakin boşluk. Mimari hatlar hedefe yönlendirir. | Normal ve gri ton karede karakter, kargo, yol ve tehdit ayrı seçilebiliyor mu? Sahne oynanabilir kamerada etkili mi? |
| Biyolojik hareket dili | Kaburgaya göre esneyen zar, eklemden açılan kitin, olayla başlayan nefes tepkisi. Bütün yüzeyi aynı sinüsle sallama. | Hareket anlam taşıyor mu? Azaltılmış hareket modunda oyun bilgisi korunuyor mu? |
| Konseptten runtime'a aktarım | Düzenlenebilir kaynak, anlamlı pivot, temiz normal, basit collision, materyal ve kaynak kaydı; GLB sonrası karşılaştırma. | Güzel Blender render'ı dışında gerçek Godot görüntüsü ve teknik rapor var mı? |

Bir düzeltme kartına yalnız şunları yaz: mevcut kare → baskın kusur → değişmeyecek kimlik/oynanış öğeleri → tek düzeltme → aynı kamera/ışıkla karşılaştırma → geçti/kaldı ve gerekçe. Kareler arasında poz/ışık değiştirerek geometri iyileşmiş izlenimi yaratma. Sanat kararı görsel inceleme gerektirir; otomatik test bunu ikame etmez.

### Prompt genişletme sözleşmesi

Değişmez blok: Serotonin, İlmek'in mevcut silueti, özel kargo, üçüncü şahıs kamera, sıcak fildişi/şeftali ile petrol mavisi derinlik, okunaklı savaş alanı. Değişken blok: tek varlığın morfoloji ailesi, gözenek yönü, malzeme kalınlığı, anlatıdaki işlevi. Modelden yeni bir dünyayı her defasında yeniden icat etmesini isteme. Bir prompt veya seed, kimlik tutarlılığının kanıtı değildir; aynı oyun ölçeğinde karşılaştır.

Kullanıcının üç parçalı çıktı yapısı korunur: iki cümle konsept, kısa malzeme/ışık spesifikasyonu, bağımsız İngilizce görsel prompt. Modelleme brief'ine ayrıca gerçek geometri, hareketli parçalar ve renderer sınırlamalarını ekle. Bu aşamada görsel üretimi veya shader uygulaması yapılmadı.

### Kaynakların yeniden kontrolü ve güvenlik

10 Ekim 2026: verilen yedi GitHub adresi ve Tissue/Sverchok sayfaları erişildi. Mevcut kayıt korundu; tüm kodlar incelendi veya araçlar pratikte öğrenilip doğrulandı denmiyor. Ek Blender Dual Mesh ve Principled belge açılışları yine başarısız oldu; sürüm/API ayrıntıları bu turda doğrulanamadı.

- [Prompt Enhancer README](https://github.com/pinkpixel-dev/comfyui-llm-prompt-enhancer#about-your-api-keys), anahtarların normal node girdisi olarak workflow JSON'una kaydedildiğini açıkça belirtiyor. Böyle bir hat ileride kullanılırsa paylaşılan JSON ve ekran görüntülerinde anahtar bırakma; mevcut turda anahtar girilmedi ve araç kurulmadı.
- [Sverchok](https://github.com/nortikin/sverchok), alanlar ve parametrik geometri için; [Tissue](https://github.com/alessandro-zomparelli/tissue), yüzeye bağlı tessellation/dual mesh ve reaction-diffusion araştırması için aday. Bunlar Codex `SKILL.md` paketleri değil, Blender eklentileridir. “Depo incelendi” ile “skill kuruldu” ifadelerini ayır.
- [AnthusAI](https://github.com/AnthusAI/openai-midjourney-prompt-generator) bir prompt notebook'u; [altryne](https://github.com/altryne/awesome-ai-art-image-synthesis) keşif listesi; [dair-ai](https://github.com/dair-ai/Prompt-Engineering-Guide) teknik rehber; [f/prompts.chat](https://github.com/f/prompts.chat) prompt topluluğu. Bunları üretime hazır oyun sanatı veya güvenliği denetlenmiş bağımlılık sayma.

Sonuç: yeni ağır kurulum yerine mevcut proje becerisini, gözlenebilir kalite kapılarıyla güçlendirmek seçildi. Ücretsiz yerel çalıştırma da donanım/zaman maliyetini ortadan kaldırmaz. Ekonomik yol, aynı brief'i tekrar kullanmak ve yalnız başarısız temsilî parçayı düzeltmektir.
