# Nefes — geçici bağlantı geri bildirimi

10 Ekim 2026. Mevcut 0,8 saniyelik VENT etkileşiminin sunumu güçlendirildi; yeni bölüm, collision kapısı veya kargo yeteneği eklenmedi.

## Davranış

- Durma dolumu başlayınca mevcut Nefes GLB'si ilk 0,18 saniyede geçici yuvanın üzerinde 1,9m yükseklikteki bağ noktasına gider; kargo sahipliği `has_cargo` olarak korunur.
- Kurye ile kapsül arasında iplik çizgisi, açık halkada ölçülü genişleme ve %10 basamaklı dünya etiketi gösterilir.
- Hareket ya da yuvadan ayrılma dolumu iptal eder; kapsül kuryeye döner ve geçici iplik çizgisi silinir. İptalde dönüş anlıktır; ayrı dönüş animasyonu bu kapsamda yok.
- Başarı mevcut GUARDIAN aşamasına geçer; kargo yeniden kuryededir. Geçici halka 1,4 ölçeğinde görünür kalır. Yakındayken “Akım açık · Nefes sende” etiketi vardır; savaşta uzaklaşınca gizlenir.
- Bu halka bir durum işaretidir. Fiziksel hava kanalı, zar açılması veya yeni yürünebilir geçit olduğu iddia edilmez. Kapsülün gerçek çevresel/savaş işlevi ve bileşik görev kapsamı hâlâ eksiktir.
- Azaltılmış harekette bağ konumuna anında geçilir; dolum bilgisi korunur. Pause simülasyon dolumunu ve kapsülü dondurur. Restart görünümü temizler; checkpoint2 açılmış durumu mevcut aşamadan yeniden kurar, kayıt şeması değişmedi.

## Kanıt

Godot4.7.2 Windows:

- `--headless --path godot --script res://tests/smoke.gd`: **194 PASS**. Geçici sahiplik, bağ konumu, iplik, dolum, genişleme, pause, hareketle iptal, geri alma, azaltılmış hareket, başarı, checkpoint2 ve restart kontrolü dahil.
- `tests/assisted_flow.gd -- --flow-motion`: **34 PASS**,13,75sim sn,2onaylı dash,0darbe.
- `tests/assisted_flow.gd` azaltılmış hareket: **34 PASS**,aynı akış sonucu. Son görsel yükseklik/sabit uç nokta düzeltmesinden sonra iki mod da yeniden çalıştırıldı: ayrı ayrı exit0/34 PASS/13,75sim sn/2onaylı dash/0darbe. Bu kontrol önceki kayıtta açık kalan son-kaynak doğrulamasını tamamlar; insan jesti veya iPhone testi değildir.
- `previews/vent-connection.png`: gerçek Godot, gri ton, sentetik yarım dolum/çapraz yaklaşma QA. `--capture-vent --capture-static --capture-grayscale`; oyuncu VENT_POINT+(-0,35,0,0,60), dwell0,4. İnsan oynama kanıtı değildir.

İlk smoke denemesinde sunum fonksiyonu çağrılmadığı için görsel kontroller başarısızdı; test, oyundaki fizik/sunum ayrımına uygun düzeltildi. Ardından tam %50 sınırındaki float birikimi için küçük epsilon eklendi. Normal/azaltılmış hareket arasında tamamlanmış lerp'in float farkı pause kontrolünde çıktı; bağlanmış kapsül artık tam hedef konumuna atanır.

İlk QA'da etiket büyük, kapsül muhafızın önündeydi. Etiket küçültüldü, kapsül yukarı taşındı; son çapraz karede yazı ve iplik seçiliyor, kapsül muhafızın üst siluetine hâlâ yakın. Bütün açı/ekranlarda görsel kabul geçmedi; marker/sahne düzeni final sanat değildir. Kamera veya muhafız konumu normal oyunda bu kusuru saklamak için değiştirilmedi.

`game-feel` becerisi mevcut olaya bağlı, sınırlı geri bildirim ve simülasyondan bağımsız görsel hareket seçimini yönlendirdi. Ekran sarsıntısı, yeni ses, ücretli görsel, Blender model ailesi veya bağımlılık eklenmedi. Performans/insan öğrenme/iPhone doğrulaması yok. Sonraki iş kapsülün neden açılma sağladığını gerçek çevresel eylemle anlatmak; yalnız işaret büyümesini bitmiş mekanik saymamak.
