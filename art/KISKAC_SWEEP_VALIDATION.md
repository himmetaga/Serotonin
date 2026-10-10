# Kıskaç — ikinci saldırı: süpürme

10 Ekim 2026. Yeni düşman/Blender varlığı veya boss üretilmeden mevcut FSM'e ikinci saldırı niyeti eklendi. `game-ai` becerisi basit FSM'i koruma, karar/hasar proxy/görsel karşılık ayrımını yönlendirdi. Bu, Daralma mini boss'unun tamamlandığı anlamına gelmez.

## Oynanış

İlk saldırı mevcut düz hamle: üçgen hazırlık, zamanlı karşı atılmayla saptırma. İlk dikiş isabetinden sonraki hazırlıkta **SWEEP** seçilir; aynı 0,82 sn hazırlık ve 0,40 sn eylem süresinde, muhafız ilerlemeden önündeki 140 derecelik alanı süpürür. Yön hazırlık başında kilitlenir, oyuncuyu sonradan takip etmez. Açık dikiş yine 1,25 sn kalır.

Yelpaze süpürmeyi, üçgen düz hamleyi gösterir; yalnız renk farkına dayanılmaz. Yelpazenin koyu dış sınırı ve yazılı “bu saldırı saptırılamaz” karşılığı var. Oyuncu yelpazenin dışına veya arkasına geçebilir. Süpürme içinde karşı atılma parry üretmez; darbe sonrası mevcut güvenli noktaya dönüş/temas temizliği uygulanır. Tek eylem tek darbe olayı üretir. Kargo veya tamamlanmış teslimat değişmedi.

`guardian_sweep.gd` açı/erişim ve hasar örneklemesini tanımlar. Reach2,05m + radius0,42m; uyarı dış erişimi2,47m. Geçen kareyle mevcut kare arasındaki açılarda13, radyalde4 nokta ve oyuncu hareket segmenti sınanır. Bu örneklenmiş oyun proxy'sidir, sürekli geometrik ispat veya fiziksel kıskaç collision'ı değil. Büyük timestep'te zaman-mekân eşleşmesi yaklaşık olabilir; gerçek akış testi1/60sn adımlıdır.

Normal hareket gövde yönü eylem açısını gecikmesiz izler. Azaltılmış harekette gövde döndürülmez, kilitli yön korunur; yelpaze ve hareketli eylem çizgisi oyun bilgisi olarak kalır. Kabuk açılması/isabet ve pause/reset davranışı korunur. Yeni rig, ses/haptik veya final kıskaç animasyonu yok.

## Kanıt

- Genel `tests/smoke.gd`: **172 PASS**.
- Yeni `tests/sweep_smoke.gd`: **17 PASS**. Sentetik FSM/proxy testleri: ön isabet, güvenli arka/uzak konum, erken yanlış isabet yokluğu, hareket segmenti, düz hamle koridoru dışındaki yeni yan tehlike, ilk isabet sonrası seçim, yön kilidi,108 vertex koyu sınır/dolgu, pause, eylem pozu/proxy eşleşmesi, azaltılmış hareket bilgisi, saptırma yok/tek darbe, eylem sonrası dikiş ve reset.
- `tests/assisted_flow.gd`, normal ve azaltılmış hareket ayrı koşularında **34 PASS**; iki gerçek saldırı türünün seçimi, baştan sona dokunma olaylarıyla mevcut görev,10,34 sim sn, iki bilinçli atılma, sıfır darbe. Konum/aşama/isabet doğrudan atanmaz. İnsan veya iPhone testi değildir.
- Gerçek üçüncü şahıs gri ton QA karesi `previews/kiskac-sweep-warning.png`. `--capture-stage=guardian --capture-attack=sweep --capture-static --capture-grayscale` sentetik hazırlık karesi kurar; eylem animasyonunu veya tüm açılarda okunurluğu kanıtlamaz. Çıplak model/oda sanatı hâlâ kaba.

## Kalan kapı

Aynı otomatik kaçış rotası iki saldırıdan da kaçabiliyor; bunun gerçek oyuncuyu farklı konum kararı almaya teşvik ettiği henüz kanıtlanmadı. Yelpaze biçimi farklı bir tehlike alanı getirir fakat savaş kalitesini tek başına garanti etmez. Güvenli öğretim ve gerçek oyuncu testinde “üçgen/yelpaze farkı ve hangisinin saptırılabildiği” açıklanabilmeli. Yavaş yardımcı hazırlığın açıklık penceresine sığması mevcut akışta doğrulandı; insan reaksiyon/touch testi yok. Tam bölüm ritmi, Daralma'nın üç saldırısı, compound görev genişliği, final sanat ve Apple cihaz kapıları sürüyor.
