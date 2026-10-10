# Nefesin Eşiği — native iOS kontrol prototipi

SwiftUI uygulama kabuğu, SpriteKit sahnesi ve Foundation tabanlı `SerotoninCore` girdi paketi. Harici oyun motoru veya backend gerektirmez. Hedef iPhone, iOS 17+, yatay ekran.

## Çalıştırma — Mac gerekli

Önce Xcode 15 veya üzerini kurup ilk açılış kurulumunu tamamlayın. Command Line Tools seçiminin tam Xcode'a işaret ettiğini kontrol edin. [XcodeGen](https://github.com/yonaskolb/XcodeGen) 2.46.0 veya üzeri gerekir. Homebrew kullanıyorsanız `brew install xcodegen` ile kurulabilir; bu proje kurulumu kendiliğinden çalıştırmaz.

Depo kökünden:

```sh
cd prototypes/TouchGarden
swift test --package-path Core
xcodegen generate --spec project.yml
open Serotonin.xcodeproj
```

Xcode'da **Serotonin** scheme'ini seçin. Simülatör için bir iPhone hedefi seçip Run yapın. Fiziksel iPhone için Signing & Capabilities altında kendi geliştirme ekibinizi seçin; gerekirse bundle identifier'ı kendinize ait benzersiz bir değere değiştirin. Bu depoda sertifika, profil veya geliştirici hesabı yoktur.

Komut satırında paketi test edip uygulamayı simülatör için imzasız derlemek için:

```sh
bash scripts/verify-macos.sh
```

Script kaynakları veya kullanıcı imzalama ayarlarını silmez. Üretilen Xcode projesi `project.yml` dosyasından yeniden üretilebilir; kalıcı proje değişikliklerini bu dosyada yapın.

## İlk deneme

1. Başlangıç ekranındaki hareket açıklamasını okuyup **İlk nefesi taşı** seçeneğine dokunun.
2. Sürükleyerek İlmek'i yönlendirin. Parmağınızı kaldırmak hareketi durdurur.
3. Atılmak için parmağınızı yeniden koyup kısa, belirgin ve hızlı bir yönde savurun. Uzun süreli sürükleme sırasında hızlı yön değiştirme atılma üretmemelidir.
4. Nefes kargosunu alın. Açık halkada kısa süre durarak geçici bağlantıyı tamamlayın. Kargo sizde kalır.
5. Muhafızın işaretlediği saldırıdan kaçının; açık kaldığı anda atılarak zırhına vurun. Saptırma için hazırlığın son anındaki yönü ve zamanlamayı kullanın.
6. Açılan iki bağlantıyı sırasıyla kullanın. Sonra Nefes'i tam halka biçimindeki son yuvaya götürün.

Bu kısa akış, tasarım belgesindeki tam bölümün kontrol deneyidir. Hikâyenin dış dünya sahneleri, final sanat, müzik, ek bölgeler, kayıt sistemi ve App Store paketi bu denemeye dahil değildir. Yeniden başlatma mevcut denemeyi sıfırlar; uygulama kapanırsa görev baştan başlar.

## Duraklatma ve yardımcı seçenekler

- Görünür duraklatma simgesi varsayılan olarak açık. İsterseniz menüden gizleyebilirsiniz.
- İlmek durmuşken bir noktaya basılı tutmak menüyü açar; hızlı hareket veya bırakma saldırı üretmez.
- Uygulama etkinliğini kaybedince oyun durur. Geri geldiğinizde **Devam et** seçilmeden devam etmez.
- **Yumuşak kontrol:** hızlı savuruş devre dışıdır. Belirgin yönde dışarı çekip sabit tutma, kısa hazırlıktan sonra bir atılma üretir. Yön değiştirmek hazırlığı yeniden başlatır; bırakmak iptal eder. Her dokunmada en fazla bir atılma. Muhafızın süreleri de uzar.
- Hareket hassasiyeti, azaltılmış hareket ve haptik aç/kapat ayarları vardır. Sistem Reduce Motion tercihi de uygulanır.
- Menüler native, etiketli SwiftUI kontrolleridir. Tam görme dışı oyun navigasyonu ve kontrolcü desteği henüz uygulanmadı; bu prototip için tam erişilebilirlik iddiası yoktur.
- Tercihler mevcut oturumda korunur; kalıcı ayar kaydı bu deneyin kapsamı dışındadır.

## Yapı

```text
App/
  SerotoninApp.swift   Uygulama giriş noktası
  GardenView.swift     Güvenli alan, görev metni, başlangıç ve duraklatma
  GameSession.swift    Tek sahne sahibi, yaşam döngüsü ve basit haptikler
  GameScene.swift      Hareket, kargo, muhafız, bağlar ve sahne çizimi
Core/
  Package.swift        Apple UI türlerinden bağımsız Swift paketi
  Sources/            Vektör ve dokunma eylemleri
  Tests/              Jest sözleşmesi testleri
project.yml           XcodeGen proje kaynağı
scripts/verify-macos.sh
```

Kontrol eşikleri ekran noktalarında, oyun simülasyonu 1000×600 mantıksal alanda çalışır. Aspect-fit boşlukları oyun girdisi almamalıdır. Telefonun güvenli alanı native kabuk tarafından korunur. İnceleme sırasında bunlar kaynak düzeyinde kontrol edilir; gerçek farklı ekranlarda ayrıca sınanmalıdır.

## Doğrulama durumu

Windows geliştirme ortamında `swift` ve `xcodebuild` bulunamadı. Bu nedenle XCTest, proje üretimi, simülatör build'i ve gerçek iPhone testi henüz çalıştırılmadı. Testlerin yazılı olması geçtikleri anlamına gelmez. Güncel kontrol listesi [DEVICE_CHECKLIST.md](DEVICE_CHECKLIST.md) dosyasındadır.

9 Ekim 2026 kaynak kontrolü: Astra mimari ve entegrasyon incelemesi yaptı; Sol sahneyi, Luna girdi paketini ve testlerini hazırladı. Başlatıcı imzası, yeniden başlatma durumu, hassasiyetin iki kez uygulanması, dokunma/render saatlerinin karışması ve kesin kayan nokta karşılaştırması düzeltildi. Proje YAML'ı ayrıştırıldı; temel hedef/paket bağlantısı ve kaynak yolları kontrol edildi. Mac betiği `bash -n` sözdizimi kontrolünden geçti. Bu kontroller Swift derleme doğrulaması değildir.

Önce imzasız simülatör build'i, ardından gerçek iPhone'da uçtan uca görev ve kesinti testi yapılmalı. Başarısız olan kontroller giderilmeden bu deneme tam oyuna temel kabul edilmez.

Kaynaklar: [SpriteView](https://developer.apple.com/documentation/spritekit/spriteview), [ScenePhase](https://developer.apple.com/documentation/swiftui/scenephase), [XcodeGen proje biçimi](https://github.com/yonaskolb/XcodeGen/blob/master/Docs/ProjectSpec.md).
