# İlk Nefes — Deniz dış dünya animatiği

10 Ekim 2026. Teslimatın insan üzerindeki sonucu artık yalnız HUD metni değil: Godot'ta çizilen kısa bir dış dünya sahnesi var. **Kaba anlatı/hareket animatiği; final karakter sanatı, Blender modeli veya bitmiş sinematik değildir.** Nihai dış dünya sanat tekniği bu denemeyle kilitlenmez.

## Davranış

`godot/scripts/deniz_vignette.gd`, pencere, sandalye, masada bekleyen telli çalgı ve oturan yetişkin profilini kodla çizer. Pencere kanadı perspektifte açılır; eli kanada bağlı ilerler. Omuz/gövde tek bir nefes döngüsüyle yükselip geri yerleşir. Sakin fildişi/şeftali ve petrol mavisi palet kullanılır; yüksek yoğunluklu efekt yok.

Gerçek `delivery_completed` olayından **1,8 saniye sonra** açılır; önce iç dünyanın teslimat tepkisi görülür. Açılış iki saniye, nefes dört saniye; sahne sonunda kendi kendine kaybolmaz. Oyuncu etiketli **İç dünyaya dön** düğmesiyle kapatır. Düğme ilk odak sahibidir; mevcut **Duraklat/Esc** menüsü erişilebilir kalır, resume odağı dönüş düğmesine verir.

Sahne açıkken görünmeyen hareket ve kamera orbit engellenir, temas sahipliği temizlenir. Dönüşte hareket tekrar açık; tamamlanmış görevde savaş atılması hâlâ kapalı. Duraklatma sahne saatini dondurur ve dönüş düğmesini devre dışı bırakır. Azaltılmış harekette pencere açık son pozda gösterilir, nefes yer değiştirmesi sıfırdır; eşdeğer yazılı sonuç korunur. Sesi kapatmak sahneyi kapatmaz.

Yinelenen teslimat sinyali veya kapanıştan sonraki kare sahneyi yeniden açmaz. Reset temizler. Checkpoint6 yüklemek ses ve animatiği tekrar oynatmaz; ayrı bir yeniden izle seçeneği henüz yok. Uygulama sahne sürerken kapatılırsa tamamlanmış teslimat kaydı korunur fakat sahne izleme süresi ayrı kaydedilmez; yeniden açınca otomatik tekrar yok.

## Kanıt

- `tests/smoke.gd`: **172 kontrol PASS**. Gerçek görev simülasyonundaki teslimat olayından sahne tetiklemesi/gecikme, pencere zamanı ilerlemesi, görünmeyen hareket kilidi, pause saati, odak dönüşü, azaltılmış hareket, dönüş düğmesi, yinelenen olay, reset ve kapandıktan sonra tek parmak yürüyüş kontrolleri var. İnsan playtest değildir.
- `tests/checkpoint_smoke.gd`, ayrı işlemler: write **1 PASS**, read **24 PASS**. Yeni kontrol tamamlanmış yükleme sonrası üç saniyelik görsel ilerlemede sahnenin açılmadığını sınar. QA dosyaları workspace içinde; kişisel kayda dokunulmaz.
- Gerçek Godot viewport karesi: `previews/deniz-story.png`, 1280×800. `--capture-story` QA yolu sentetik olarak 5,2 saniyelik sahne pozu kurar, fizik ilerlemesini durdurur; bu kare insanın oyunu bitirdiğini veya hareketin estetik kalitesini kanıtlamaz.
- Çizim 1000×500 kompozisyonu ekrana kırpmadan sığdırır; metin ve dönüş kontrolü görselin içine bake edilmez. Telefon safe-area, diğer ekran oranları, gerçek touch, VoiceOver ve iPhone performansı bu turda doğrulanmadı.

## Eksikler / sonraki kalite kapısı

Yüz, el/kol uzunluğu ve eklem hareketleri kaba; pencere perspektifi ve nefes gövdesi fiziksel rig değildir. Baş-boyun arasındaki ilk kare boşluğu düzeltildi. Sahnede özgün diyalog kaydı, ince yüz oyunculuğu ve dış dünya ses senkronu yok; mevcut teslimat ses taslağı değişmedi. Güzel veya ADA düzeyinde final olduğu iddia edilmez.

`game-ui-ux` becerisi olay güdümlü ekran açılması, dönüş odağı, duraklatma ve okunabilir etiketli kontrol seçimlerini yönlendirdi. Motor ve karakter üretim yönü hâlâ Godot + Blender; bu code-native animatik bir anlatı prototipi. Sonraki gerçek kapı: oyuncunun kargoyla pencere/nefes arasındaki neden-sonucu kendi sözleriyle anlayabilmesi; ardından final dış dünya sanatı ve sesinin sınırlı üretim planı.
