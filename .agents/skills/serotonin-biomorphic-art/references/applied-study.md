# Sanat araştırmasını oynanabilir dünyaya çevirme

10 Ekim 2026. Kullanıcının yedi GitHub adresi yeniden erişildi; ana sınıflandırma ve bağlantılar `research.md` içinde korunuyor. Yeni katkı: `level-design` (pacing-and-flow referansı dahil) ve `game-feel` becerilerinin tamamı okunarak biyomorfik sanat üretimine uyarlanması. Bunlar uygulama önerileridir; yeni model, shader, bölüm veya efekt üretilmedi.

## Mimari: dekor değil yönlendirme

`level-design` karşılığı:

- Ana lifler sonraki hedefe yönelsin; küçük gözenekler değil, uzaktan seçilen tek bir tonoz veya odacık yön duygusu versin. Bu işaretin üçüncü şahıs kameranın görüşünde kaldığını kontrol et.
- Gerçek yürünebilir yüzey ile dekoratif ağ farklı rollerdir. Boşluk gibi görünen ama üzerinde yürünülen yüzey veya basılabilir gibi görünen dekoratif lif oluşturma. Model brief'inde görsel yüzey, hareket sınırı ve kamera collision rolünü ayrı yaz.
- Dev yapı/ufak kurye ölçek zıtlığını savaş rotasını daraltarak üretme. Büyük yapıyı arka/orta planda, ince ayrıntıyı seçilen yakın kenarlarda kullan.
- Görkemli manzara için sakin bir an ayır; savaşa girişte daha düşük ayrıntı yoğunluğuna geç. Gerilim → mücadele → teslimat → dinlenme ritmi öneridir, otomatik bölüm genişletme kararı değildir.
- Aynı kamerada görev yönü, saldırı hazırlığı ve kargo okunmuyorsa önce görüş çizgisi ve kütleyi değiştir. Yeni yön oku veya daha parlak efekt ilk çözüm olmak zorunda değil.

## Hareket: şeklin işlevini anlatma

`game-feel` karşılığı:

- Nefes teslimatı: bağlantı kenarından başlayan sınırlı zar genleşmesi, sonra sakin duruma dönüş. Her duvara sürekli aynı sinüsü uygulama.
- Kitin isabeti: dikişte kısa yönlü tepki; açıklık bilgisi kalıcı durumla anlaşılır. Parıltı veya kamera sarsıntısı tek bilgi taşıyıcısı olmasın.
- İplik gerilimi: iki bağ arasında ölçülü eğrilik değişimi; görsel tepki simülasyon konumunu veya hitbox'ı sessizce değiştirmesin.
- Her tepkinin olay kaynağı, süre/geri dönüşü, pause/reset davranışı ve azaltılmış hareket karşılığı brief'te tanımlansın. Efekt sayısını başarı ölçütü yapma.
- Bunlar kod örneği kopyalama talimatı değildir. Genel becerideki global time-scale veya çok katmanlı impact önerilerini mevcut Godot akışına doğrulamadan taşıma.

## Araç seçimini sınırlandırma

[Tissue](https://github.com/alessandro-zomparelli/tissue), hesaplamalı tasarım için Blender eklentisidir; README Blender 5 için release yolunu gösteriyor. Bu, kurulu sürümde uyumluluk testi değildir. [Sverchok](https://github.com/nortikin/sverchok), skaler/vektör alanları ve parametrik geometriyi belgeliyor. Çıkarımımız: önce taşıyıcı/rota alanını tarif etmek, ardından gözenek yoğunluğu ve lif kalınlığını bu alana bağlamak; sırf eklenti var diye bütün üretim hattını değiştirmemek.

[Krea Palette Tools](https://github.com/SurrealByDesign/ComfyUI-Krea-Palette-Tools) yerel palet/metin yolu sunuyor; ücretli bulut yolu ayrı. Paleti çıkarmak, ışık düzenini veya mimari biçimi öğrenmek değildir. [AI Gamedev](https://github.com/mattwilliamson/comfyui-ai-gamedev) README'sindeki 10 GB şekil / 21 GB dokulu VRAM gereksinimi nedeniyle bu araştırmada kurulum önerisi yapılmadı; değerler yazarın beyanı, proje ölçümü değil.

Blender Dual Mesh resmî sayfası bu kontrol sırasında yine açılamadı; güncel node/API ayrıntıları doğrulandı sayılmayacak. Eklenti kurulmadı, kod güvenlik denetimi veya model eğitimi yapılmadı.

## Tek temsilî parça için ders kartı

1. İşlev: yol kenarı mı, geçit mi, muhafız mı? Birini seç.
2. Biçim: ana taşıyıcı → ikincil lif → zar; hangi boşluk gerçek geometri olacak?
3. Değişmezler: İlmek, kargo, üçüncü şahıs kamera, hareket alanı ve tehdit işaretleri.
4. Malzeme: kalınlık/roughness/ışık tepkisi; SSS, alpha ve emisyonu ayrı tarif et.
5. Kanıt: aynı kamera ve ışıkta normal/gri ton karşılaştırma; gerekirse kısa hareket testi.
6. Karar: görünmeyen ayrıntıya bütçe harcama. Teknik export geçse bile sanat kapısı başarısız olabilir; başarısız deneyi açıkça kaydet.

Konsept brief'i için kullanıcının üçlü formatını koru: iki cümle konsept, kısa malzeme/ışık tarifi, bağımsız İngilizce prompt. Oyun varlığı için bu altı maddelik üretim karşılığını ayrıca ekle.
