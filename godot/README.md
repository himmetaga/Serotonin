# Nefes Bahçesi — Windows kontrol ve model deneyi

Godot 4.7.2, GL Compatibility. `project.godot` dosyasını Godot ile açıp F5'e basın. Kök dizindeki `launch.ps1` oyunu, `launch.ps1 -Editor` editörü açar.

Güncel çevre: `assets/models/membrane_room.glb`; eski `garden.glb` referans olarak korunur. Zar çevresini yeniden üretmek için Blender'ı `--background --factory-startup --python art/tools/build_membrane_room.py` ile proje kökünden çalıştırın. Bu işlem mevcut zar kaynak/GLB dosyalarını yeniden yazar; PNG render üretmez. Kontrol: `node art/tools/validate_glb.mjs art/membrane_room_manifest.json`.

Hücresel geçit `assets/models/cellular_gate.glb` ile +X yönündeki opak yan duvarın runtime yerini alır. Kaynak `art/source/cellular_gate.blend`; yeniden üretim tarifi `art/tools/build_cellular_gate.py` (Blender `--background --factory-startup --python-exit-code 1 --python` ile). Kontrol: `node art/tools/validate_glb.mjs art/cellular_gate_manifest.json`. Bu parça dekoratif sanat deneyi; yürünebilir yeni bölüm değildir.

## Oynama

- Fare sol tuşunu tutup başlangıç noktasından sürükle: hareket. Yeni basıştan hemen sonra hızlı savur: atılma. Her temasta tek atılma; tekrar atılmak için bırakıp yeniden bas.
- Alternatif: WASD/oklar hareket, Boşluk son hareket yönüne atılma.
- Üçüncü şahıs takip kamera kullanılır; ileri ve sağ hareket ekran/kamera yönüne göre yorumlanır. Q/E veya sağ fare sürüklemesi kamerayı döndürür. Hareket boyunca otomatik dönüş bekler, durunca karakterin arkasına veya yakın muhafıza döner. Tek parmak kullanımında otomatik kamera yeterli olacak şekilde tasarlandı; cihazda doğrulanmadı.
- Esc veya Duraklat: duraklat; menüden azaltılmış hareket seçilebilir. R: yeniden başlat.
- İsteğe bağlı “Yardımcı atılma”: normal hareketten daha uzağa sürükle, yönü 0,35 saniye tut, bırak; sonraki ayrı dokunuş hazır yöne atılır. Bırakmak saldırı üretmez. Merkeze geri çekme/menü/odak kaybı iptal eder; hazırlık iki saniyede biter. Varsayılan hızlı savuruş korunur. Tercih kalıcıdır; güncel kayıt `art/ASSISTED_FLOW_VALIDATION.md`.
- Azaltılmış hareket karakter salınımını ve otomatik kamera dönüşünü kapatır; takip ve isteğe bağlı manuel dönüş korunur.
- Nefes'i al; beliren yuvada dur. Muhafızın çizdiği saldırı yönünden kaç, açık dikişine atıl. İki vuruştan sonra üçgen 1 ve kare 2 bağ noktalarına sırayla git; ipliğin menzilini koru. Son yuvada durarak teslim et.

## Kontroller

Mevcut arena aşamaları `user://nefes_checkpoint_v1.json` ile saklanır; yeniden açılışta son güvenli noktadan devam edilir. Muhafız sırasında yarım isabet saklanmaz. “Baştan başla” ilerlemeyi sıfırlar, ayarları korur. Tamamlanmış teslimat sesi tekrar çalmaz. QA capture kişisel kayda dokunmaz. Ayrıntı `art/CHECKPOINT_VALIDATION.md`; eski kayıtsızlık notları tarihseldir.

Godot çalıştırılabilir dosyasını `$godotExe` değişkenine atadıktan sonra:

```powershell
& $godotExe --headless --path godot --editor --import --quit
& $godotExe --headless --path godot --script res://tests/smoke.gd
& $godotExe --headless --path godot --script res://tests/assisted_flow.gd
& $godotExe --headless --path godot --script res://tests/assisted_flow.gd -- --flow-motion
& $godotExe --headless --path godot --script res://tests/assisted_flow.gd -- --flow-save --flow-motion
& $godotExe --headless --path godot --script res://tests/checkpoint_smoke.gd -- --checkpoint-write
& $godotExe --headless --path godot --script res://tests/checkpoint_smoke.gd
& $godotExe --headless --path godot --script res://tests/audio_smoke.gd
& $godotExe --headless --path godot --script res://tests/preferences_smoke.gd -- --prefs-phase=write
& $godotExe --headless --path godot --script res://tests/preferences_smoke.gd -- --prefs-phase=read
node art/tools/validate_glb.mjs
```

Gerçek render yakalama (başsız değil): `--path godot -- --capture=C:/tam/yol/arena.png`.

QA seçenekleri: `--capture-stage=guardian` sabit muhafız düzeni; `--capture-grayscale` 3D renk dışı okunurluk; `--capture-profile` 120 kare aralığı ve 3D render istatistiğini PNG yanında `.profile.json` dosyasına kaydeder. Bu kısa Windows ölçümü GPU zamanı veya iPhone testi değildir. Profil yalnız `--capture=` ile çalışır; normal oyunda ek örnekleme yok.

`--capture-stage=exposed` aynı düzenin açık dikiş evresidir. Kıskaç'ın iki kabuk parçası karşılık verme penceresinde ayrılır; altın iplik açıklık içinde belirir. Azaltılmış harekette doğrudan açık/kapalı duruş kullanılır. Hazırlık/hamle sırasında bakışı kilitli saldırı yönünü izler. Bu görsel parça animasyonudur; kemik rig'i ve fiziksel deformasyon yok. Kayıt: `art/KISKAC_SHELL_VALIDATION.md`.

Saptırma/dikiş isabeti/oyuncu darbesi farklı kısa görsel tepkiler ve olay mesajları üretir. Azaltılmış harekette mesaj kalır; ölçek ve geri esneme kapanır. QA yakalamaya `--capture-impact=parry`, `hit` veya `damage` eklenebilir; normal oyun olaylarından ayrı sentetik kurulumdur. `art/COMBAT_FEEDBACK_VALIDATION.md`.

`--capture-static` karşılaştırma için hareket salınımını ve fizik güncellemelerini durdurur. `--capture-batch-experiment` başarısız görsel doğrulaması bulunan oda birleştirme araştırmasını açar; normal oyunda kapalıdır ve yayın ayarı olarak kullanılmamalıdır. Ayrıntı: `art/BATCH_EXPERIMENT.md`.

`--capture-stage=delivery` ve `--capture-stage=complete` aynı kamera düzeninde teslimat öncesi/sonrası sentetik QA karesi hazırlar. Bunlar oyuncu testi değildir. Teslimat tepkisi 1,8 saniyede sakinleşir; azaltılmış harekette doğrudan sonuca geçer. Kargo son yuvanın üzerinde kalır; teslimattan sonra sürükleme/klavye ile yürümek mümkündür, savaş atılması kapanır. Kayıt sistemi olmadığı için bu sonuç oturumlar arasında saklanmaz.

Son yuva kapalı, koyu kenarlı hacimli halkadır. Teslimat aşamasında üstünde “Son yuva · Nefes” görünür; beklemenin ilerlemesi yüzdeyle, bitişi “Nefes ulaştı” ile belirtilir. Yuvadan uzaklaşmak ilerlemeyi iptal eder. Bu mekânsal metin bir dokunmatik buton değildir. QA kamera konumu yan yaklaşma okunurluğunu kontrol eder; kayıt `art/SOCKET_READABILITY_VALIDATION.md`.

Teslimatta dört saniyelik özgün pencere/hava çağrışımı **ses taslağı** bir kez çalar. Pause/focus kaybında durur; reset keser. Menüde “Ses açık” seçeneği var; sessizken anlatının yazılı karşılığı korunur. Sesi açmak geçmiş teslimatı yeniden çalmaz. `--capture-pause` menü QA görüntüsü içindir. Üretim ve doğrulama: `art/DELIVERY_AUDIO_VALIDATION.md`.

Ses ve azaltılmış hareket tercihleri `user://preferences_v1.json` içinde saklanır; sağlam önceki kayıt `.bak` olarak korunur. Hata/uyumsuz sürüm menüde bildirilir. Oyun reseti tercihleri silmez. Bu ayar kaydıdır; görev ilerlemesi kaydı değildir. Ayrıntı: `art/PREFERENCES_VALIDATION.md`.

Blender kaynaklarını yeniden üretmek:

```powershell
& 'C:\Program Files\Blender Foundation\Blender 5.2\blender.exe' --background --factory-startup --python art/tools/build_assets.py
```

`-- --asset ilmek` yalnız o modeli; `-- --skip-render` PNG renderı olmadan tüm aileyi üretir. Script mevcut Blender oturumuna dokunmaz; kendi açtığı boş işlemde üretir. Çıktı yollarındaki proje modellerini yeniden yazar.

## Sınırlar

Bu tek arenalık mekanik ve sanat deneyi. Otomatik test oyuncu deneyimini veya iPhone dokunmasını doğrulamaz. Rig/kemik animasyonu, final ışık, tam ses dünyası, ilerleme kaydı, yardımcı kontrol modu, haptikler ve tam hikâye henüz yok. iOS dışa aktarım ve imzalama yapılmadı.
