# SEROTONIN — Yaratıcı yön, oynanış ve hikâye

Tarih: 9 Ekim 2026 · Sürüm: 0.1 · Durum: İlk tasarım önerisi; oynanış henüz prototiple doğrulanmadı.

Güncel uygulama notu: Kullanıcının son kararıyla ana motor Godot, modeller Blender; geliştirme ve oynama Windows üzerinde. İlk 3D arena `godot/` altında, düzenlenebilir modeller `art/source/` altında. Mac/iPhone son platform aşamasıdır. Önceki Swift/SpriteKit deneyi `prototypes/TouchGarden` altında yalnızca referans olarak korunur. Bu kısa arena tam bölüm veya bitmiş sanat üretimi değildir.

## 1. Kullanıcının belirlediği çerçeve

- iOS için tek oyunculu, tek seferlik satın alınan premium oyun.
- Bir insanın içindeyiz. Farklı bölgelere özel kargolar taşıyarak onun mutlu olmasına yardım ediyoruz.
- Bileşik görevler, beceri isteyen savaşlar ve sürükleyici bir macera.
- Ekranı kaplayan hareket ve saldırı butonları olmadan dokunmatik deneyim.
- Sanatsal bütünlük ve Apple Design Awards düzeyinde tasarım hedefi. Ödül sonucu garanti edilemez; hedef üretim kalitesidir.
- Astra yaratıcı yönetim, önemli mimari kararlar ve kalite kontrolünden sorumlu; iyi tanımlanmış işler daha ekonomik modellere devredilir.
- Godot + Blender üretimi; önce Windows'ta oynanabilirlik, en son Mac/iPhone doğrulaması.
- Üçüncü şahıs perspektif kamera: İlmek'in arkasından takip; önceki ortografik kamera önerisinin yerine geçer.

Aşağıdaki karakterler, bölüm adları, kamera, süre ve kontrol ayrıntıları bu çerçeve için geliştirilmiş önerilerdir; kullanıcı tarafından önceden kararlaştırılmış kabul edilmez.

## 2. Beyin fırtınası ve seçilen omurga

Üç fikir oyunu taşıyabilir: bedenin içinde çevik bir kurye olmak, kopmuş bağlantıları dokumak ve yaşayan bir dünyanın ritmiyle savaşmak. Bunları aynı fiziksel araçta birleştiriyoruz: kuryenin arkasında uzanan canlı iplik.

**Oyuncunun çizdiği yol dünyada iz bırakır. Bu iz kargoyu taşır, geçitleri bağlar ve savaşın sonucunu değiştirir.**

Tek cümlelik vaat: Bir insanın içindeki küçük bir kuryeyi yönet; canlı ipliğinle kapanan yolları aç, güçlü muhafızlarla savaş ve küçük bir mutluluğun yerine ulaşmasını sağla.

Oyuncu karakterinin çalışma adı **İlmek**. İnce zar kanatları, küçük koyu yüzü ve ışık taşıyan kuyruğu olan, kolay tanınan bir silueti var. Gerçek bir molekülün anatomik modeli değil; bu bedenin masalsı sakini.

İlmek'in ipliği oyunun temel görsel motifi. Harita yollarında, kargo yuvalarında, düşmanların zırh eklerinde ve Deniz'in dış dünyasındaki müzik tellerinde aynı biçim dili tekrar eder.

## 3. Oyunun duygusal hedefi

Oyuncu yardım ettiği insanı tanısın; teslimatın onun hayatındaki küçük bir karşılığını görsün. Ustalık hissi savaşlardan, yakınlık hissi teslimatların sonucundan gelsin.

Mutluluk; merak edebilmek, nefes alabilmek, birine yaklaşabilmek ve küçük bir şeyden keyif alabilmek üzerinden anlatılır. Hüzün dünyada kalabilir. İlerlemenin işareti bütün bölgelerin sürekli neşeli görünmesi değildir.

Beden, biyolojiden esinlenen şiirsel bir dünya. Kargo isimleri ve görev ilişkileri kurmacadır; serotonin veya insan psikolojisi için tıbbi bir model sunmaz.

## 4. Kamera ve butonsuz kontrol

Güncel yön: yatay ekran, Blender modelleriyle üçüncü şahıs perspektif; kamera İlmek'in arkasından yumuşakça takip eder. Tek parmak sürükleme ve atılma kameranın yatay yönüne göre yorumlanır. Kamera yönü hareket sırasında kararlı tutulur, durunca arkaya veya yakın tehdide yönelir; azaltılmış harekette otomatik dönüş kapatılır. Windows'ta sağ fare sürüklemesi veya Q/E ile isteğe bağlı kamera dönüşü vardır. Kamera çevreye yaklaşınca içeri çekilir. Fare sürükleme dokunmanın Windows karşılığıdır; klavye alternatif kontrol sağlar. Bu kontrol varsayımları oyun testinde doğrulanacaktır.

| Oyuncunun hareketi | Oyun içindeki karşılığı | Tasarım şartı |
| --- | --- | --- |
| Ekranın rahat bir bölgesinde parmağını sürüklemek | İlmek'in hareket yönünü belirlemek | Karakter parmağın altında kalmaz; dokunma başlangıcı göreli referanstır. |
| Kısa, belirgin yön savuruşu | O yöne atılmak | Açık dikişe isabet ederse darbe; boşluğa yapılırsa kaçınma. |
| İşaretlenmiş saldırıya doğru, doğru anda atılmak | Saldırıyı saptırmak ve açıklık yaratmak | Her saldırı saptırılamaz; şekil ve hareketle ayrılır. |
| Açılmış bağ noktalarının çevresinden ilerlemek | İpliği geçirip germek | Oyuncudan kusursuz daire veya sembol çizmesi istenmez. |
| Uygun kargo yuvasında kısa süre durmak | Kargoyu teslim etmek | Dolum hareketi önizleme verir; uzaklaşmak teslimi iptal eder. |
| Parmağını kaldırmak | Hareketi durdurmak | Otomatik saldırı üretmez; tek başına dokunmayı bırakmak menü açmaz. |

Normal hızlı yön değişimini atılmadan ayırmak en büyük kontrol riski. Mesafe, süre ve hareket geçmişi birlikte değerlendirilir; eşikler cihaz ve erişilebilirlik ayarlarıyla sınanır. Tek bir dokunuştan istemeden arka arkaya atılma çıkmamalı.

Duraklatma ilk tasarımda, karakter duruyorken herhangi bir boş alana basılı tutarak çağrılan erişilebilir bir menüyle sağlanır. İlk güvenli sahne bunu gösterir. Görünür duraklatma simgesi tercihi sunulur; menü ve erişilebilirlik kontrolleri gerçek etiketli arayüz öğeleridir. Uygulama odağı kaybolduğunda oyun durur. Basılı tutmakta zorlananlar için görünür seçenek zorunlu olarak erişilebilir kalır.

Tek elle hareket, sol/sağ el yerleşimi, hassasiyet, daha geniş karşılık verme süresi, azaltılmış hareket ve isteğe bağlı kontrolcü desteği tasarım kapsamındadır. Hızlı savuruş gerektirmeyen yardımcı mod ayrıca prototiplenecek: hedef/yön seçimi ve daha yavaş, açık bir onay hareketiyle aynı oyun eylemleri yürütülecek. Normal modun zorunlu çoklu dokunma hareketi yoktur.

## 5. Savaş: akışı oku, açıklık yarat, bağı çöz

Savaşın temel eylemleri hareket, atılma ve bağ kurmadır. Derinliği yeni butonlar yerine düşman davranışları, konum, zamanlama ve kargoyu koruma üretir.

Temel karşılaşma: Muhafız hazırlanır → oyuncu yönünü ve saldırı tipini okur → kaçar veya saptırır → zırh dikişi açılır → doğru açıdan atılarak dikişi keser → açılan bağ noktaları arasından ipliği geçirir → zırh çözülür.

İlk sürümde kısa sürede iki atılmaya izin veren toparlanma sistemi sınanır. Hazır olma durumu İlmek'in kuyruğundaki iki belirgin halka ile gösterilir. Sayılar ve zamanlama geçicidir; tekrar tekrar savurmanın baskın strateji olması engellenir.

Örnek düşman aileleri:

- **Kıskaç:** yolu kapatır, doğrusal hamle yapar; saldırısı boşa gidince yanı açılır. Konumlanmayı öğretir.
- **Yankı:** oyuncunun önceki rotasını gecikmeli tekrarlar; rota değiştirmeyi ve iplik yönetimini öğretir.
- **Kabukçu:** cepheden dayanıklıdır; çevredeki iki bağ noktasını kullanarak kabuğu açılır. Kargo taşırken güvenli güzergâh kurmayı öğretir.

Bunlar korku veya hüzün gibi duyguların öldürülmesi gereken kişileştirmeleri değildir. Bedenin koruyucu mekanizmaları aşırı çalışmış, geçitleri kapatmıştır. Dövüş sonunda işlevlerine dönerler; görsel davranışları bunu açıkça anlatır.

Vuruş hissi: okunaklı hazırlık animasyonu, isabet anında kısa duraklama, yönlü tepki, dikişin fiziksel açılması, ölçülü ses ve dokunsal geri bildirim. Yoğun parçacıklar saldırı işaretlerini örtmez. Kamerayı sarsmak temel tatmin kaynağı değildir. Geri bildirim azaltılsa bile savaşın bilgisi görünür kalır.

Başarısızlıkta karşılaşmanın yakındaki başlangıcına dönülür. Teslim edilmiş kargolar korunur; tekrarlanmış uzun yolculuklarla oyuncu cezalandırılmaz. Boss aşamalarının kayıt noktaları oyun testinde kararlaştırılır.

## 6. Kargolar ve bileşik görevler

Aynı anda taşınan tek etkin kargo, oyuncunun elindeki ana karardır. Kargo ipliğe bağlanır; ayrı envanter açılması gerekmez. Her türün renk dışında belirgin şekli, hareketi ve sesi vardır.

| Kargo | Davranış | Göreve ve savaşa etkisi |
| --- | --- | --- |
| Nefes | İpliğe genleşme darbesi aktaran titreşen zar | Gerilmiş hat üzerinden dar geçidi genişletir veya muhafızın zırh dikişini aralar. |
| Sıcaklık | İpliğin temas ettiği katı bağı esneten örgülü çekirdek | Donmuş bir köprüyü çalıştırır veya muhafızın kilitli eklemini açar. |
| Yankı | İpliğe tekrar eden titreşim kazandıran halkalı kapsül | Saklı bağlantıları görünür kılar veya aynı titreşime yanıt veren zırh kilidini çözer. |

Kargo kırılganlığını her çarpışmada başa döndüren bir ceza olarak kullanmayacağız. Riskin sonucu güvenli bir yerde yeniden toplamak veya kısa bir onarım yapmak olabilir. Taşıma ile savaş arasında sürekli eşya bırakıp alma zorunluluğu oluşursa bu sistem sadeleştirilir.

Her kargo ipliğin yalnızca bir temel özelliğini değiştirir. Etkisini çevrede ve savaşta aynı görsel kuralla gösterir. İplik sonlu bir etkin uzunluğa sahiptir; eski serbest izler yavaşça söner, bilinçli bağlanmış noktalar açıkça işaretlenir. Böylece bütün ekran kalıcı çizgilerle dolmaz. Takılma ve istemsiz bağlanma davranışı ilk prototipte sınanır.

Geçici bağlantı noktaları açık halka biçimindedir: kargo hattı çalıştırır, hareket edince İlmek'le birlikte geri çıkar. Nihai teslim yuvası tam halka biçimindedir: kısa yerleşme süresinin ardından kargo kalıcı olarak bırakılır. Biçim ve animasyon bu farkı renk olmadan da gösterir. Görev bu iki etkileşimi ayrı güvenli anlarda öğretir.

Görev omurgası: ihtiyacı sez → kargoyu bul → rotayı aç → karşılaşmayı çöz → teslim et → insan üzerindeki küçük sonucu gör. Her görev bu aşamaların farklı bir neden-sonuç ilişkisini kullanır.

Örnek bileşik görev, **Boğazdaki Düğüm**: Deniz arkadaşına cevap vermek ister. Ses yolu kapalıdır. Önce akciğer bölgesinden Nefes getirip kanalı açarsın. Açılan akım eski bir muhafızı uyandırır. Muhafızın hamlesini bir bağ noktasına yönlendirir, zırhını çözersin. Ardından anı havuzundan getirdiğin Yankı'yı ses köprüsüne yerleştirirsin. Dış dünyadan ilk defa tamamlanmış bir cümle duyulur: “Bu akşam gelebilirim.”

Uzun vadeli ilerleme; sayı büyütmekten çok yeni bağlantı türleri ve önceden görülen yolların açılmasıdır. Yeni yetenek aynı hareket dilini genişletir. Her bölgeye yeni dokunma jesti eklenmez.

## 7. Hikâye: Bir günün içinde küçük bir geri dönüş

Deniz, bir zamanlar arkadaşlarıyla müzik yapan genç bir yetişkin. Son dönemde hayatının bütün boşluklarını iş ve sorumluluklarla doldurmuş. Masasında tamir edilmeyi bekleyen küçük bir telli çalgı, telefonunda cevaplanmamış mesajlar var. Arkadaşı Ekin akşam için bir ses kaydı bırakır: “Gelirsen bir sandalye daha çekeriz. Çalmak zorunda değilsin.”

Oyun bu mesajın ilk titreşimiyle açılır. Kamera Deniz'in yüzüne yaklaşır; titreşim iç dünyada bir ışık olarak belirir. Taşıma yollarının arasındaki küçük bir zarın içinde İlmek uyanır. İlk kargosu, daralan yolları açabilen Nefes kapsülüdür. Birkaç notalık anı kaydını taşıyan Yankı kargosu ilerleyen bölümlerde ortaya çıkar.

İlmek ilerledikçe yolları kapatan sistemin eskiden Deniz'i koruduğu anlaşılır. Merkezdeki **Bekçi**, incinme ihtimali olan her yeni bağlantıyı kesmeye başlamıştır. İyi anıların yolları da kapanmıştır. Bekçi bir kötü karakter gibi konuşmaz; her karşılaşmada geçidi kapatan, oyuncuyu geri iten davranışlarıyla kendini anlatır.

| Bölüm | Bedenin içindeki yer | Oynanış değişimi | Deniz'in dış dünyasında karşılık |
| --- | --- | --- | --- |
| 1 — İlk Nefes | Akciğerlerden esinlenen şişip sönen zar bahçeleri | Hareket, kargo, ilk bağ ve ilk muhafız | Pencereyi açar; sabahın seslerini duyar. |
| 2 — Nabzın Altında | Kalbin çevresinde yükselip alçalan kızıl kemerler | Hareketli zemin, ritim ve kaçınma | Uzun zamandır bekleyen çalgıyı eline alır. |
| 3 — Yankı Bahçesi | Hafızayı temsil eden su ve iplik adaları | Geçmiş rotayı kullanan düşmanlar, ses kargoları | Kusurlu ama sıcak bir prova kaydını hatırlar. |
| 4 — Boğazdaki Düğüm | Boğaz ve ses yollarından esinlenen dar, gerilen köprüler | Önceki yetenekleri birleştiren teslimat ve boss | Ekin'e cevap verir; dışarı çıkmayı seçer. |
| 5 — Bir Nota Daha | Sinir yollarını birleştiren geniş bir geçiş alanı | Taşıma, savaş ve onarımın tek finalde birleşmesi | Arkadaşlarının yanına oturur; müziğe yeniden yer açar. |

Finalde Bekçi son kargoyu da kilitler. Oyuncu saldırıları okuyup katmanlarını açar; son aşamada ortaya çıkan kopuk bağlantıyı ipliğiyle tamamlar. Kargodaki kaydın içinde bir yanlış nota ve ardından arkadaşların gülüşmesi duyulur. Teslim edilen şey, kusursuz olmanın gerekmediğini hatırlatan bir andır.

Deniz arkadaşlarının yanına oturur. Ekin eski melodiyi çalmaya başlar; bir yerde takılır ve gülümser. Deniz önce yalnızca dinler. Elindeki çalgının telini yoklar; yüzünde küçük bir gülümseme belirir. Oyunun tamamlanması Deniz'in çalmasına, alkış almasına veya belirli bir performansı başarmasına bağlı değildir. İç dünyada açılan yolların hepsi aynı renge dönmez; gölgeler, serin odalar ve sessiz bölgeler kalır. İlmek genişleyen bir yolun kenarına oturur. Gün tamamlanmıştır; bu insanın hayatı devam edecektir.

İlmek bağlantı imkânlarını açar; Deniz'in kararları kendisine aittir. İlk sürümde dallanan sonlar planlanmaz. Tek final, yanında bulunmanın ve dinlemenin de yeterli olabileceğini taşır.

Anlatım; çevre, ses, kısa dış dünya görüntüleri ve değişen beden davranışlarıyla ilerler. Uzun açıklama ekranları yerine görevlerin sonucu görülür. Anlaşılabilirlik için altyazı, tekrar dinleme ve isteğe bağlı kısa görev özeti vardır.

## 8. Açılış için kısa sahne taslağı

Karanlık. Uzakta bir buzdolabının uğultusu. Telefonun masada hafifçe titreyişini duyarız.

“Deniz… Bu akşam buradayız.”

Ekranda ince bir zar, içeriden gelen ışıkla bir an gerilir. Oyuncunun ilk dokunuşunda zar o yöne esner. Sürükleyince İlmek içinden çıkar; arkasında tek bir altın iplik kalır.

İlk koridor oyuncu ilerledikçe nefes alır. Etrafta acele eden küçük taşıyıcılar vardır. Biri taşıdığı Nefes kapsülünü düşürür. İlmek yanına geldiğinde kapsül ipliğe tutunur; kısa bir nefes sesi duyulur.

Koridorun sonundaki açık halka, kapsüle uyacak biçimdedir. Oyuncu yaklaşır, bağlanma hareketini görür ve durur. Kapsül hattı genişletir. Uzakta bir zar aralanır; iç dünyaya ince bir ışık sızar. Oyuncu ilerleyince kapsül ipliğine geri döner. Bu bir geçici bağlantıdır; nihai teslimat bölümün sonunda yapılacaktır.

Oyunun adı, aydınlanan zarın üzerinde belirir: SEROTONIN.

## 9. Sanat, ses ve Apple'a özgü özen

Görsel yön: yarı saydam organik mimari, mürekkep dokuları, dokunulduğunda esneyen zarlar ve ince altın iplik. Yakında küçük hareket ayrıntıları, uzakta insan ölçeğini hissettiren büyük yapılar. Kanlı gerçekçilik yerine dokusal, sıcak ve yer yer tekinsiz bir iç dünya.

Palet ilerleyişi: inci grisi ve soluk mercan → derin kızıl → petrol mavisi ve altın → dar mor gölgeler → birbiriyle yaşayan sıcak ve serin renkler. Tehditler yalnızca renkle ayrılmaz.

Ses tasarımı: insanın dış dünyasından gelen sesler beden içinde mekâna dönüşür. Geri gelen her bağlantı müziğe bir katman ekler. Oyuncunun ipliği germesi ve bağ çözmesi, kendi rotasından doğan kısa müzik izleri oluşturur; bunlar doğruluk puanına çevrilmez. Savaş sesleri ritmi destekler fakat temel başarı ses duymaya bağlı olmaz. Kulaklık ödüllendirici olabilir, zorunlu değildir.

Dokunsal geri bildirim iplik gerilimi, başarılı saptırma ve teslimat için farklı, kısa desenler kullanır. Donanım veya tercih nedeniyle kapalı olduğunda görsel/sesli eşdeğerler vardır. Her kalp atışında titreşim verilmez.

Apple'ın yayımladığı ADA kategorileri arasında etkileşim, görsel tasarım, kapsayıcılık ve tatmin edici deneyim yer alır. Bizim üretim karşılığımız: anlaşılır dokunma dili, tutarlı sanat yönetimi, ölçülü geri bildirim, erişilebilirlik ve gerçek cihazda kararlı performans. Bunlar jüri puanlama formülü değildir.

## 10. İlk oynanabilir bölüm: Nefesin Eşiği

Hedef süre: 12–15 dakika; test edilecek tasarım tahmini. Astra'nın değerlendirmesiyle bu süre, mekaniği acele etmeden öğretmek için seçildi.

1. İlk 90 saniye: uyanış, hareket, Nefes kargosunu alma ve ilk geçici bağlantı.
2. Sonraki iki dakika: iplikle bir kopuk geçidi bağlama ve çevresel ödül.
3. İlk savaşlar: tek düşman ailesinde iki davranış; doğrusal hamle ve alan süpürme. Saldırı hazırlığı, kaçınma ve açık dikişe atılma ayrı anlarda öğretilir.
4. Görev: Nefes kargosunu güvenli bir geçici bağlantı noktasında kullanarak akımı değiştirme. İlmek ayrılırken kapsül ipliğine geri bağlanır ve boss'a onunla birlikte gider.
5. Mini boss **Daralma**: üç okunaklı saldırı, açık dikişler ve iki bağ noktası. Önce atılmayla zırhı aç, sonra arenayı kullanarak ipliği ger. Nefes kargosunun genleşme darbesi, geçitte öğrendiğin kuralla zırhı çözer. Sakinleşen canlı gövdesini açıp son geçidi taşır; dövüşün dünyada kalıcı ve işlevsel sonucu vardır.
6. Nihai teslimat ve sakinleşme: Nefes kapsülü tam halka biçimli son yuvaya bırakılır. Zar bahçeleri genişler, dışarıdan pencere açılışı duyulur, Deniz uzun bir nefes verir.

Bu bölümün sınırı: bir bölge, bir kargo, bir normal düşman, bir mini boss, tek tamamlanabilir görev ve tek dış dünya sonucu. Beş bölümün tamamı bu ilk teslimata dahil değildir.

İlk oyun testinin geçici hedefleri, Luna incelemesinden uyarlanmıştır; bunlar elde edilmiş sonuçlar değildir:

- Kontrollü hızlı yönlendirme denemelerinin en az %95'inde istemsiz atılma olmaması; kasıtlı atılma denemelerinin en az %90'ının doğru algılanması. Ayrı ayrı yanlış pozitif ve kaçırılan girdi sayısı tutulur.
- Parmağı kaldırmanın hiçbir denemede saldırı veya atılma üretmemesi; yeniden dokunmanın mevcut harekete kararlı bağlanması.
- İlk kez oynayanların, kargonun ipliğe kattığı özelliği ve bunun savaşta neden işe yaradığını kendi sözleriyle açıklayabilmesi.
- Duraklatmanın kısa öğretimden sonra 10 saniye içinde bulunabilmesi; savaş ve menüden güvenilir şekilde devam edilebilmesi.
- Haptikler ve ses kapalıyken tehditlerin hâlâ ayırt edilebilmesi; yardımcı modla hızlı jest zorunluluğu olmadan görevin tamamlanabilmesi.
- Küçük ve büyük ekranlarda, farklı el kullanımında karakterin ve yaklaşan tehdidin parmak altında kalmaması. iOS sistem kenar hareketleriyle çakışmaların ayrıca kaydedilmesi.
- Boss'un aynı saldırıyı düşünmeden tekrarlayarak geçilememesi; oyuncunun konum ve zamanlama kararı alması.

İlk test turu az sayıda dış oyuncuyla sorun keşfine yöneliktir; yüzdeler nüfus düzeyinde istatistiksel başarı iddiası oluşturmaz. Örneklem, deneme sayısı ve yardımcı ayarlar sonuçlarla birlikte raporlanır.

## 11. Üretim sırası ve geçiş şartları

| Aşama | Somut çıktı | Bir sonraki aşamaya geçme şartı |
| --- | --- | --- |
| A — Kontrol deneyi | Windows Godot'ta sürükleme, atılma, saptırma ve duraklatma | Oyuncu hareketleri karıştırmadan temel karşılaşmayı bitirebiliyor; gerçek dokunma testi F aşamasında. |
| B — Çıplak oynanış | İplik, bir kargo, düşman ve boss içeren gri kutu bölüm | Savaş ve teslimat birlikte ilgi çekiyor; taşıma angarya oluşturmuyor. |
| C — Sanat deneyi | Blender modelleri, tek oda, İlmek animasyonu ve ses | Hareket okunaklı; Windows performansı ölçülmüş, mobil bütçeler korunmuş. |
| D — Dikey dilim | Nefesin Eşiği baştan sona bitirilebilir | Dış oyuncular yönlendirme olmadan görevi ve insana etkisini anlayabiliyor. |
| E — Tam üretim | Diğer bölümler, ilerleme, kayıt, dil ve erişilebilirlik | Bölüm başına içerik maliyeti ve kalite ölçülebilir; kapsam sürdürülebilir. |
| F — Yayın hazırlığı | Gerçek cihaz testleri ve TestFlight sürümü | Kayıt, kesinti, performans ve son kullanıcı akışı doğrulanmış. |

Ekip, bütçe ve Mac erişimi henüz bilinmediği için tam üretime takvim taahhüdü verilmez. Önce aşama A ve B'nin sonuçlarıyla kapsam doğrulanır. Tam oyun için başlangıç hipotezi 3–5 saatlik yoğun bir maceradır; süre içerik doldurarak uzatılmaz.

Seçilen motor Godot. Düzenlenebilir Blender kaynakları oyun dışındadır; çalışma zamanına GLB aktarılır. Geliştirme Windows'ta sürer. Son aşamadaki iOS derleme, imzalama, haptik entegrasyonu ve cihaz testi için Mac/Xcode erişimi gerekecek. Bu belge bir iOS build'inin çalıştığını iddia etmez; gerçek dokunmayı sona ertelemek ayrıca doğrulanacak kontrol riski taşır.

Önce çevrimdışı temel oyun ve yerel kayıt. Game Center başarımları daha sonra isteğe bağlı eklenebilir; multiplayer mevcut kapsamda yok. Tek seferlik satın alma, tam maceraya erişim sağlar; reklam veya enerji sayacı önerilmiyor.

## 12. Çalışma düzeni ve kaynaklar

Astra: yaratıcı tutarlılık, ana teknik kararlar, kritik riskler ve son değerlendirme. Ekonomik modeller: sınırları belli modüller, test senaryoları, içerik verisi ve belge işleri. Her görevin girdisi, dosya kapsamı, tamamlanma ölçütü ve doğrulama çıktısı olmalı. Küçük işlerde ajan sayısı artırılarak gereksiz maliyet yaratılmaz. Model çağrısının başarılı olması, çıktının kalite kontrolünden geçtiği anlamına gelmez.

Bu taslak hazırlanırken Astra yaratıcı denetim, Luna dokunmatik kontrol riskleri için görevlendirildi. Astra'nın kargo-iplik ilişkisi, dönüşen düşman, rota kaynaklı müzik ve Deniz'in iradesi hakkındaki önerileri taslağa işlendi; Luna'nın incelemesi kontrol testi hedeflerine dönüştürüldü. Bu, oynanabilir prototipin onaylandığı anlamına gelmez. Tasarım becerileri; oyun eylemlerini fiziksel jestlerden ayırma, tek parmak erişimi ve okunaklı, ölçülü vuruş geri bildirimini planın merkezine taşıdı.

Başvurulan resmî kaynaklar, 9 Ekim 2026:

- [Apple Design Awards](https://developer.apple.com/design/awards/): yayımlanan kategoriler ve tasarım örnekleri.
- [SpriteKit](https://developer.apple.com/documentation/spritekit/): önceki Swift kontrol deneyinin altyapısı; artık ana motor değil.
- [Core Haptics](https://developer.apple.com/documentation/corehaptics/): aday dokunsal geri bildirim altyapısı.
- [OpenAI Multi-agent](https://developers.openai.com/api/docs/guides/agents-api/multi-agent): alt ajan koordinasyonu için resmî başvuru; bu oturumdaki model adları ve çağrı desteği mevcut araç şemasıyla doğrulandı.
