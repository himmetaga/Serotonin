# İlk süpürme — güvenli öğretim

10 Ekim 2026. `level-design` becerisinin güvenli tanıtım → uygulama → baskı ilkesi ve `game-ai` FSM ayrımı mevcut Kıskaç karşılaşmasına uygulandı. Yeni bölüm/varlık veya pahalı sanat hattı açılmadı.

## İşleyiş

İlk dikiş isabetinden sonra seçilen ilk süpürme TELEGRAPH aşamasında bekler. Yelpaze en az **1,2 saniye** gösterilir. Oyuncu gösterilen alan içindeyken saldırı saati ilerlemez ve hasar oluşmaz; hareket/atılma/duraklatma kullanılabilir. İpucu: “İlk süpürme saptırılamaz. Yelpazeden çık; Kıskaç seni bekliyor.”

Oyuncu dışına veya arkasına çıkınca öğretim tamamlanır, **tam 0,82 saniyelik** normal hazırlık başlar; yön tekrar oyuncuya çevrilmez. Oyuncu tehlikeli alana yeniden girerse artık normal saldırı isabet edebilir. Dikiş açıklığı kaçırılırsa sonraki süpürmeler öğretim beklemesini tekrarlamaz. Reset öğretimi temizler; mevcut guardian checkpoint yarım isabeti tutmadığından karşılaşmanın ilk hamlesinden tekrar başlar. Ayrı kullanıcı profili/kalıcı öğretim kaydı yok.

## Uyarı ve hasar uyumu

`guardian_sweep.gd` içindeki `in_warning`, çizilen2,47m/±70° yelpazeyle aynı sınırı kullanır. Hasar kapsülü örnekleri, oyuncu segmentindeki en yakın noktası bu alanın dışında ise isabet üretmez. Böylece duran oyuncuya görsel yelpaze dışındaki kapsül taşmasından darbe gelmez. Hareket segmenti hâlâ sınanır: iki uç dışarıda olsa da tehlikeden geçen rota güvensiz olabilir. Bu örneklenmiş proxy; her hız/timestep için sürekli collision ispatı değil.

## Kanıt

- Genel smoke **172 PASS**. İki isabetli gerçek FSM döngüsünün ikinci aşaması artık öğretimde dışarı çıkıp hazırlığı bekler; bu testte konum fixture'ları kullanılır.
- Odaklı sweep **24 PASS**. Yeni yedi kontrol: uyarı açısının hemen dışındaki duran noktada taşma hasarı yok; erken güvenli konumda minimum gösterim; alan içinde üç saniye beklemede saldırı/hasar yok; pause öğretim saati; flag/timer atamadan normal hareketle çıkıp tam hazırlık; sonradan geri girince normal darbe/EXPOSED; reset.
- Yardımcı dokunma akışı normal ve azaltılmış hareket ayrı koşularda **34 PASS**, **11,54 sim saniye**, iki bilinçli atılma, sıfır darbe. Konum/aşama/isabet atamadan girişten teslimata gider. Önceki10,34sn akıştan1,2sn uzunluk öğretim beklemesine karşılık gelir; gerçek oyuncu süresi değildir.
- `previews/kiskac-sweep-lesson.png`: gerçek Godot üçüncü şahıs gri ton karesinde yelpaze ve bekleme/saptırılamama ipucu. Sentetik/static QA; insanın ipucunu anladığının kanıtı değildir.

## Eksikler

Bu yalnız ikinci saldırı için güvenli ilk gösterim; tam hareket/parry/kargo öğretimi veya12–15 dakikalık Nefesin Eşiği bölümü değil. İnsan playtest'i, gerçek parmak altında işaret okunurluğu, farklı ekranlar ve iPhone doğrulaması yok. Boss, bölüm akışı ve final sanat hedefleri sürüyor. Öğretim alan içinde süresiz bekler: bilerek güvenli, fakat oyuncu ne yapacağını anlayamazsa akış durur; sonraki gerçek oyuncu testinde bu anlaşılabilirlik özellikle gözlenmeli.
