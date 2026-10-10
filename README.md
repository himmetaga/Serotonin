# Serotonin

Premium, tek oyunculu iOS macerası. İnsan bedeninin içinde küçük bir kurye; farklı bölgelere özel kargolar, canlı iplikle bağ kurma ve butonsuz savaş.

- [Yaratıcı yön ve hikâye](SEROTONIN_CREATIVE_DIRECTION.md)
- [Godot oynanabilir Windows prototipi](godot/README.md)
- [Blender sanat yönü](art/ART_DIRECTION.md)
- [Çalışma kuralları](AGENTS.md)

## Durum

Ana motor **Godot**, model üretimi **Blender**. Godot'ta `godot/project.godot` dosyasını içe aktar ve **F6 değil F5** ile oyunu çalıştır. Alternatif: PowerShell'de `./launch.ps1`; editörü açmak için `./launch.ps1 -Editor`.

İlk arena: Nefes kargosunu al → yuvada dinlendir → Kıskaç'ın hamlesinden kaçıp açık dikişine iki kez atıl → iki bağ noktasını birleştir → teslim et. Fareyle sürükle/hızlı savur veya WASD/oklar + Boşluk kullan. Esc duraklatır; R başa alır. Varsayılan ekranda hareket/saldırı butonu yok.

Güncel kamera üçüncü şahıs: İlmek'in arkasından perspektif takip. Hareket ve atılma kameranın yönüne göre çalışır. Kamera durunca arkaya/yakın tehdide yönelir; Q/E veya sağ fare sürüklemesiyle döndürülebilir. Çevreye yaklaşınca içeri çekilir. [Güncel oyun görüntüsü](art/previews/third-person-runtime.png) · [Kamera kontrol kaydı](art/THIRD_PERSON_VALIDATION.md).

İlmek, Nefes ve Kıskaç modelleri ile yeni `membrane_room` zar çevresi kullanılıyor. Düzenlenebilir modeller `art/source/*.blend`, oyun karşılıkları `godot/assets/models/*.glb` altında. Önceki bahçe modeli korunuyor. İlk sanat geçişidir: rig, final animasyon, ses, haptik, kayıt ve tam bölüm henüz yok. Önceki `prototypes/TouchGarden` Swift deneyi referans olarak korunuyor, ana uygulama değil.

10 Ekim: yeni konseptin ilk oda uygulaması eklendi. Kıvrımlı zar geçitleri, katmanlı arka odalar, mat yüzeyler, derinlik sisi ve karakter temas gölgeleri. [Gerçek Godot görüntüsü](art/previews/nefes-v2-runtime.png) · [Uygulama ve kontrol kaydı](art/NEFES_V2_IMPLEMENTATION.md).

Windows geliştirme ve oyun testleri şimdi; Mac/iPhone derleme, performans ve gerçek dokunma testleri son platform aşamasında. Windows testi iOS doğrulaması sayılmaz. Ayrıntılı kontrol kaydı: [VALIDATION.md](art/VALIDATION.md).
