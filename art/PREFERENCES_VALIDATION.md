# Kalıcı erişilebilirlik ve ses tercihleri

10 Ekim 2026. Yalnız iki tercih: `reduce_motion` ve `audio_enabled`. Görev ilerlemesi, teslimatlar veya karakter konumu kaydedilmez.

## Uygulama

Normal oyun `user://preferences_v1.json` okur. İlk açılışta eksik dosya varsayılanlarla çalışır ve otomatik dosya yaratmaz. Menü değişiminde version=1 JSON snapshot yazılır; açılışta oyun ve checkbox durumları birlikte yüklenir. Oyun reseti tercihleri değiştirmez. QA `--capture-static` kutuyu da eşler, fakat görsel QA ayarını kalıcı yazmaz.

Yeni veri `.tmp` dosyasına yazılır, flush/close sonrası asıl dosyaya rename yapılır. Geçerli önceki ana kayıt aynı yöntemle `.bak` olarak tutulur. Windows'ta rename'in güç kesintisine karşı mutlak atomiklik garantisi olduğu iddia edilmez; yedek kurtarma yolu vardır. Bozuk ana dosya sağlam yedeğin üstüne kopyalanmaz. Yazma başarısız olursa tercih o oturumda çalışır ve menüde kayıt uyarısı görünür.

Okuma 4 KB ile sınırlı; JSON sözlük, numeric version=1 ve iki gerçek bool alan şart. Yanlış tür, kırık JSON veya eksik alanlarda yedek/varsayılan kullanılır. version>1 ana veya yedek kayıt korunur: yeni sürüm verisi üzerine yazılmaz, menü bu oturumluk değişikliği bildirir. Önceki yayımlanmış ayar şeması olmadığı için bu tur eski sürüm migrasyonu yok.

Godot dosya API başvurusu: [DirAccess](https://docs.godotengine.org/en/stable/classes/class_diraccess.html). Kalıcı veri motor nesnesi değil düz veri; ağ, cloud veya Game Center yok.

## Doğrulama

- Genel Windows headless smoke: **97 kontrol PASS**.
- Ses smoke: **13 kontrol PASS**, tercih testleri kullanıcının kaydını değiştirmeyecek şekilde izole edildi.
- `preferences_smoke.gd -- --prefs-phase=write`: **3 kontrol PASS**; ilk Godot işlemi kapandı.
- Ayrı yeni Godot işlemi `--prefs-phase=read`: **18 kontrol PASS**. Azaltılmış hareket/sessiz tercih geri geldi, menü eşleşti, ilk karede azaltılmış hareket uygulandı, reset korudu.
- Aynı test eksik/yanlış tür, yarım `.tmp`, bozuk ana dosya, yedekten kurtarma, sağlam yedeğin korunması, gelecek version alanının değiştirilmemesi, oturumluk tercih ve yazma hatasını kapsar. Bunlar hata girdisi simülasyonlarıdır; fiziksel güç kesintisi testi değildir.
- GUI read + uyarı yakalama: **19 kontrol PASS**. `art/previews/preferences-warning-menu.png` içinde 1280×800 uyarı metni menüye sığıyor. İki test sahnesinin bulunduğu sentetik fixture düzeni olduğundan bu kare sanat/ışık veya performans değerlendirmesi için kullanılmamalı.
- Test kayıtları yalnız `art/previews/preferences-relaunch-test.json*` adlı QA dosyalarıdır. Gerçek `user://preferences_v1.json` yazılmadı, kişisel ayarlar değiştirilmedi. Test çıktıları sonraki tekrarlar için korundu.

## Açık işler

Oyun ilerlemesi kaydı hâlâ yok. iPhone dosya/yaşam döngüsü, depolama doluluğu, eşzamanlı yazıcılar, gerçek kapanma/güç kaybı ve farklı ekranlar doğrulanmadı. Nihai sanat, insan sahnesi ve macera içeriği bu adımla tamamlanmış değil.

`save-systems` sürüm doğrulama, temp+backup ve ayrı işlem yeniden açılış testini; `game-ui-ux` checkbox eşleşmesini ve hata görünürlüğünü yönlendirdi. Yeni ajan, ücretli üretim veya kurulum yapılmadı.
