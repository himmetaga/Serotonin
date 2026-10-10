# Kıskaç — karşılık verme penceresi

10 Ekim 2026. Windows / Godot 4.7.2 Compatibility / Blender 5.2.1 LTS.

## Uygulama

Önceden gövdeyle birleştirilen altın dikiş sürekli görünüyordu. Artık Blender kaynağındaki altın iplik ve koyu yarık sınırı, GLB'de tek `Guardian_Seam_Runtime` grubudur; gövde ayrı kalır. Kaynak: `art/tools/props.py`, export: `art/tools/build_assets.py`. Yalnız Kıskaç `--asset kiskac --skip-render` ile üretildi; karakter ailesi ve konseptler yeniden üretilmedi.

Runtime dikişi yalnız GUARDIAN/EXPOSED evresinde gösterir, 0,12 m yükseltir. Normal harekette gövde hafifçe alçalır/genişler; azaltılmış harekette ölçek değişimi kapanır, bilgi taşıyan dikiş görünür kalır. Pause easing'i durdurur; reset dikiş ve pozu sıfırlar. Hazırlık/hamle bakışı oyuncunun son konumuna değil kilitlenmiş hamle yönüne döner. Evre ipuçları değişir. İsabet kuralları ve 1,25 saniyelik açıklık süresi korunur.

Bu, bağımsız görünür parça ve duruş işaretidir; kabuğun fiziksel olarak ayrılması, deformasyon rig'i veya son düşman sanatı değildir. Simülasyon konumu değişmez; çizgisel isabet hesabı korunur.

## Kanıt

- Godot yeniden import başarılı. Genel smoke **116 kontrol PASS**, script hatası yok. Gerçek iki isabet döngüsünde dikişin açılması/isabetten sonra kapanması da sınandı.
- GLB validator PASS: 2.896 üçgen, üç materyal, 77.324 bayt. Kaynakta sekiz düzenlenebilir mesh parçası; runtime iki mesh grubu, gövde üç/dikiş iki materyal yüzeyi. Yüzey sayısı ölçülmüş frame-time veya draw-call kazancı iddiası değildir.
- İlk test denemesinde yanlış `_hint` alan adı nedeniyle Godot script hatası vardı; konsol buna rağmen PASS yazdı. Bu sonuç geçersiz sayıldı, `_hint_label` düzeltildi; test grubunun tamamlanmasını ayrıca doğrulayan dönüş kontrolü eklendi.
- `art/previews/kiskac-closed-gray.png`: hazırlık, dikiş gizli.
- `art/previews/kiskac-exposed-gray.png`: ilk altın iplik, açık fakat gövdeyle zayıf değer kontrastı.
- `art/previews/kiskac-cleft-gray.png`: koyu sınır sonrası; aynı kamera, gri ton ve azaltılmış hareket. Crown üstündeki koyu açıklık daha belirgin; bu tek kadraj tüm açılarda okunurluk onayı değildir.

Bu kareler sentetik aşama kurulumudur, insan playtest'i değildir. Statik yakalama gövde easing'ini göstermez; davranışı otomatik test doğrular. Yeni GPU profili, iPhone dokunma/perf veya normal renk sanat onayı yapılmadı. Güncel arena hâlâ konseptteki eterik kaliteye ulaşmıyor.

## Sonraki kalite kapısı

Dikişin fiziksel açılmasını tek muhafızın kabuk/eklem geometrisiyle çözmek; önce mevcut gövdenin balonumsu ana biçimi ve plaka hiyerarşisini değerlendirmek. Yeni efekt veya düşman ailesi bu eksikleri kapatmaz. Gerçek oyuncunun hazırlık → hamle → açıklık ayrımını metinsiz okuyup okuyamadığı henüz bilinmiyor.
