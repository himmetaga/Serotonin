# Üçüncü şahıs kamera — 10 Ekim 2026

Kullanıcının yeni kamera kararı mevcut tek arenaya uygulandı. Sabit ortografik kamera kaldırıldı; perspektif kamera, 58 derece görüş açısı ve 7 birimlik SpringArm ile İlmek'i takip ediyor. Yeni ajan veya Blender/görsel üretimi yapılmadı.

Hareket ve atılma kamera yönüne dönüştürülür. Dünya koordinatlarıyla çalışan görev/savaş simülasyonu aynı kalır. Hareket veya dokunma devam ederken otomatik kamera dönüşü bekler; bu, yana giderken kontrol yönünün sürekli dönmesini önler. Durunca arka açı veya yakın tehdit yönü yumuşakça bulunur. Q/E ve sağ fare sürüklemesi isteğe bağlı dönüş sağlar. Azaltılmış harekette otomatik yön dönüşü kapalıdır.

Çevre mesh'lerinde yalnız kameranın gördüğü ayrı çarpışma katmanı vardır. Kamera frustumunu kullanan SpringArm engelde kısalır; engel kaldırıldığında eski mesafesine döner. Çevredeki görünür kargo ilk aşamada “Nefes” işaretiyle desteklenir; muhafız oyuncuya bakar.

## Doğrulama

Godot 4.7.2 Windows headless smoke: **62/62 PASS**. Önceki görev, savaş, girdi ve erişilebilirlik kontrollerine 13 kamera kontrolü eklendi: perspektif/kol kurulumu, dönen hareket eksenleri, çapraz hız sınırı, kamera göreli dokunmatik atılma, aktif hareket sırasında yön kararlılığı, otomatik geri dönüş ve azaltılmış hareket. Fizik dünyasına geçici gerçek bir engel eklenerek kısalma ve tekrar açılma sınandı.

Gerçek Godot penceresinde görüntü alındı; ilk kadrajda İlmek arkadan, kargo ve muhafız ileride görünür. Son kayıt `previews/third-person-runtime.png`, kargo taşınan sabit muhafız QA düzenidir. Sonraki aşamanın bağ işaretleri bu QA düzeninde birlikte gösterilir. Motor çıktısıdır; kamera veya modeller için AI konsept görseli kullanılmadı.

## Kalan doğrulama

İnsanla oynanış, küçük iPhone ekranındaki tehdit/kenar görüşü, kameranın uzun oturum konforu ve iOS performansı ayrıca sınanmalı. Dekoratif arka geçit henüz hareket alanı değil. Mevcut çevre geometrisi ve animasyonlar ilk geçiş; kamera değişikliği görsel kalite hedefinin tamamlandığı anlamına gelmez.

API başvurusu: [Godot üçüncü şahıs SpringArm rehberi](https://docs.godotengine.org/en/stable/tutorials/3d/spring_arm.html).
