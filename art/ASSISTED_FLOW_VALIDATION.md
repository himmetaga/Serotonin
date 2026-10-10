# Yardımcı jest — mevcut arena görevinin uçtan uca akışı

10 Ekim 2026. Windows Godot 4.7.2. Önceki yardımcı kontrol testinin devamı.

## Bulgu ve düzeltme

İlk akış testi 0,42 simülasyon saniyesinde başarısız oldu: 75 piksel normal yürüyüş sürüklemesi, eski 60 piksel eşiğini geçtiği için atılmayı hazırlıyordu. Böylece hareket için sonraki dokunuş istemsiz atılma onayı olabilirdi. Dar giriş testleri bu gerçek kullanım çakışmasını yakalamamıştı.

Hazırlık şimdi `ASSIST_PREPARE_PIXELS = 135`: normal hareketin 95 piksellik tam yön mesafesinden ayrı dış bölge. Yavaşça uzağa sürüklenebilir; hız şartı yok. Bölgeye girince mevcut ipucu hazırlığı ve geri çekerek iptali açıklar. Menü öğretimi ve ilk aşama ipucu “daha uzağa sürükle” olarak güncellendi. 0,35 sn kararlı yön, bırakmanın saldırı üretmemesi ve sonraki ayrı basışla onay korunur. Bu eşik kullanıcı testiyle onaylanmış değil; daha geniş hareket gereksinimi bazı oyuncular için ayrıca risk olabilir.

## Test kapsamı

Yeni `godot/tests/assisted_flow.gd` sahneyi normal başlangıcında açar. Tercihler test için değiştirilebilir, kişisel kayıt yolu kapalıdır. Oyuncu konumu, görev aşaması, muhafız konumu/evresi/süreleri, vuruş veya bağ sayıları test tarafından atanmaz. `start_dash` doğrudan çağrılmaz. Hareket/onay için tek parmağın InputEventScreenTouch/Drag olayları mevcut giriş metotlarına iletilir; kamera göreli dönüşüm, simulate_step ve görsel senkronizasyon 1/60 sn adımlarla yürütülür.

Akış: Nefes'e yürü → açık yuvaya yürü ve bırakıp bekle → muhafızın kilitli hamlesinden yan yola çık → gerçek EXPOSED'ı bekle → uzağa sürükle/tut/bırak/yeniden dokun ile isabet et → ikinci gerçek döngüyü çöz → iki bağa sırayla yürü → son yuvada bırakıp bekle.

## Sonuçlar

- Azaltılmış hareket açık: **32 PASS**, 10,34 sim saniye, iki onaylı atılma, sıfır oyuncu darbesi.
- `--flow-motion` ile normal hareket/otomatik kamera: **32 PASS**, 10,34 sim saniye, iki onaylı atılma, sıfır oyuncu darbesi.
- Son genel smoke: **160 PASS**, script hatası veya kaynak sızıntısı uyarısı yok.
- Test ayrıca normal yürüyüşün hazırlık oluşturmamasını, bırakmanın saldırmamasını, gerçek aşama geçişlerini ve teslimatın kargoyu bırakmasını kontrol eder.

İlk çalıştırmada testte GDScript bool tür çıkarımı hatası vardı; açık bool bildirimiyle düzeltildi. Daha sonra elde edilen gerçek davranış hatası yukarıda kaydedildi; başarısız sonuçlar PASS sayılmadı.

## Sınırlar ve sonraki kapı

Bu yalnız mevcut kısa arena görevinin kontrollü algoritmik rotasıdır; tam Nefesin Eşiği bölümü değildir. GUI'nin gerçek olay dağıtımı değil giriş metotlarına sentetik olay iletimidir. Gerçek dokunmatik ekran, parmak örtmesi, motor engelli kullanıcı, yavaş onay, yanlış olumlu/olumsuz oranı, parry stratejisi ve iOS kenar jestleri test edilmedi. 10,34 saniye mekanik simülasyon süresi; insan oynama süresi değildir. Normal modun genel testleri korunur fakat bu dosya tam görevi varsayılan savuruşla tekrar oynamaz.

`input-systems` becerisinin “eylemi ve fiziksel hareketi ayır, sahipliği koru, cihazda doğrula” yaklaşımı, normal hareketten ayrı hazırlık bölgesi ve iptal kurallarını yönlendirdi. Gerçek kullanıcıda anlaşılabilirlik hâlâ açık kapı. Yeni model/render/ücretli üretim veya ajan ekibi yok.
