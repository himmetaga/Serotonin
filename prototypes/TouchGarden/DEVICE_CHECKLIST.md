# Gerçek cihaz kalite kapısı

Durum: BEKLİYOR — bu oturumda iOS çalıştırılmadı. Aşağıdaki kutular test sonucu değildir.

Test kaydına iPhone modeli, iOS/Xcode sürümü, tarih, commit veya kaynak sürümü ve yardımcı kontrol ayarları yazılmalı.

## Derleme ve temel akış

- [ ] `swift test --package-path Core` başarılı.
- [ ] XcodeGen proje üretimi başarılı.
- [ ] İmzasız simülatör derlemesi başarılı.
- [ ] Gerçek iPhone'a yükleme ve ilk açılış başarılı.
- [ ] Nefes → geçici bağlantı → muhafız → iki bağ → nihai teslimat bitiriliyor.
- [ ] Nihai teslimat önkoşullar tamamlanmadan gerçekleşmiyor.
- [ ] Yeniden başlatma görev, kargo, düşman, bağ, iplik, sayaç ve dokunma durumlarını sıfırlıyor.

## Dokunma

- [ ] Yavaş ve hızlı sıradan yön değişimleri istemsiz atılma üretmiyor.
- [ ] Yeni dokunmayla kasıtlı atılma yönü doğru.
- [ ] Bırakma, iptal ve ikinci parmak hiçbir zaman saldırı üretmiyor.
- [ ] Çoklu dokunmada ilk etkin parmak sahipliği değişmiyor.
- [ ] Aspect-fit boşluklar ve güvenli alan dışı dokunuşlar hareket başlatmıyor.
- [ ] Bir dokunuş en fazla bir atılma üretiyor; toparlanma kendi başına yeniden atılma başlatmıyor.
- [ ] Yumuşak kontrolle hızlı savuruş olmadan bütün görev tamamlanıyor.
- [ ] Atılma animasyonu sırasında bırakınca beklenmeyen devam hareketi veya yeni saldırı yok.

## Savaş ve bağlar

- [ ] Saldırı işareti gerçek saldırı yönü ve alanıyla örtüşüyor.
- [ ] Muhafız hazırlık sonrası kilitlediği yönü gizlice değiştirmiyor.
- [ ] Atılma düşmanın içinden geçerse isabet segment boyunca hesaplanıyor.
- [ ] Tek atılma birden fazla zırh hasarı vermiyor.
- [ ] Saptırma yalnızca uygun zaman ve yönde oluyor; arkadan veya uzaktan işlemiyor.
- [ ] Gövde hasarı kare başına tekrarlanmıyor; kısa dokunulmazlık çalışıyor.
- [ ] Birinci bağdan ayrılınca iplik uzunluğu sınırı doğru uygulanıyor.
- [ ] Yanlış sıradaki bağ ve son yuva oyuncuyu görev dışı bir duruma sokmuyor.

## Yaşam döngüsü ve sunum

- [ ] Bildirim merkezi, uygulama değişimi ve ekran kilidi oyunu durduruyor.
- [ ] Geri dönünce hareket, düşman, teslimat sayacı veya atılma kendiliğinden sürmüyor.
- [ ] Duraklatma, ayarlar ve yeniden başlatma sırasında gizli dokunuş kalmıyor.
- [ ] Küçük/büyük ekran, sol/sağ el ve iki yatay yönde görev/karakter okunabiliyor.
- [ ] Büyük metin boyutunda menüler kaydırılabiliyor ve kontroller erişilebilir kalıyor.
- [ ] Ses/haptik kapalı ve Reduce Motion açıkken tehdidin bilgisi korunuyor.
- [ ] 15 dakikalık tekrarda bellek/nesne sayısı sürekli büyümüyor, cihaz ısısı kontrol ediliyor.
- [ ] Seçilen en düşük destek cihazında hedef 60 FPS ölçülüyor; sağlanmazsa sahne sadeleştiriliyor.

## İlk dış oyuncu deneyi

Deneme sayısı ve ayarlar kaydedilerek sıradan hızlı yönlendirmelerde yanlış atılma oranı, kasıtlı atılmaların algılanma oranı, duraklatmayı bulma süresi ve yardımsız görev tamamlama gözlenir. Tasarım belgesindeki %95/%90 eşikleri geçici hedeflerdir. Kullanıcıların ne yapmak istediği sorulmadan telemetriye bakıp yanlış girdi kararı verilmez.

Son karar: **bekliyor**. Gerçek cihaz verisi olmadan “oyun hissi doğrulandı” veya “dikey dilim tamamlandı” denmez.
