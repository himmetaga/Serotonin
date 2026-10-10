# Nefes teslimatı — ses kaynağı

`nefes_delivery.wav`, `godot/tools/build_delivery_audio.gd` ile yerel olarak üretilen özgün deterministik ses taslağıdır. Harici sample, insan kaydı, yapay ses klonlama, ücretli servis veya model ağırlığı kullanılmadı. Üç sönümlü mekanik temas ve filtrelenmiş hava zarfı içerir. Pencere/uzun nefes çağrışımı hedeflenir; gerçek pencere veya insan nefesi kaydı olarak sunulmaz.

Kaynak: 22.050 Hz, 16-bit mono PCM, 4 saniye, 176.400 PCM baytı. Tohum 1701. Ölçüm `nefes_delivery.analysis.json` içinde. Godot import normalize/trim kapalı, loop kapalı; çalışma zamanı içe aktarıcının seçtiği sıkıştırılmış kaynağı kullanır. Oyundaki oynatıcı ayrıca -6 dB uygular.

Yeniden üretim: Godot console `--headless --path godot --script res://tools/build_delivery_audio.gd`, ardından `--headless --path godot --editor --import --quit`. Bu komut yalnız bu üretilmiş WAV ve analiz kaydını yeniden yazar. Runtime sentez hesaplamaz.

Durum: **taslak**, nihai ses tasarımı/dinleyici onayı değil. İnsan dış dünya sahnesi ve kaliteli saha kayıtları hâlâ ayrı üretim işi.
