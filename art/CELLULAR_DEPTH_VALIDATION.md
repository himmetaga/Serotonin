# Geçit derinliği, zemin ve renk dışı savaş okunurluğu

10 Ekim 2026. Önceki hücresel geçit uygulaması üzerine dar kapsamlı devam. `serotonin-biomorphic-art` sakin savaş zemini ve biçim hiyerarşisini; `create-game-assets` gerçek kamera ve gri ton karşılaştırmasını yönlendirdi. Yeni Blender/AI model ailesi, bağımlılık veya ajan kullanılmadı.

## Değişiklikler

- Mevcut gate GLB mesh kaynakları paylaşılır: ilk uzak katmanda kaburga/ağ, son katmanda yalnız kaburgalar. Toplam üç render instance ve **20.060 ek üçgen**; yeni texture yok. Gölgeleri ve collision'ları kapalı. Bunlar dekoratif odalardır, yürünebilir yeni yollar değildir.
- Arena ve eski causeway için ayrı opak zemin shader'ı. +X akışına paralel, değişken aralıklı düşük kontrastlı lifler; ince desenin ekran türevleriyle uzak mesafede azaltılması. Muhafızın çevresinde kontrast ayrıca düşürülür. İlk ahşap benzeri düzen gerçek render sonrası sadeleştirildi. Zemin yüksekliği veya hareket alanı değişmedi.
- Gri ton karesinde kırmızı hamle üçgeninin zeminde kaybolduğu bulundu. Geometriye koyu dış üçgen ve yükseltilmiş iç renk üçgeni eklendi; emisyon yerine vertex-color/unshaded materyal. Süre, menzil, hasar veya davranış değişmedi.
- Capture QA için `--capture-grayscale` ve `--capture-profile` seçenekleri. Gri ton yalnız 3D WorldEnvironment'a uygulanır; normal oyuna ve UI'ya kalıcı ayar yazmaz. Profil seçeneği 8 başlangıç karesinden sonra 120 wall-clock kare aralığı ve render istatistiği kaydeder.

## Gerçek kanıt

Godot 4.7.2 Compatibility, AMD Radeon(TM) Graphics, Windows, 1280×800:

- `previews/cellular-depth-runtime.png`: güncel renkli muhafız QA karesi.
- `previews/cellular-depth-grayscale.png`: koyu üçgen kenarı görünür; İlmek ve kargo zeminden ayrılır. Bu tek kadraj gözlemidir, erişilebilirlik sertifikası veya tüm saldırılar için kanıt değildir.
- `previews/cellular-depth-runtime.png.profile.json`: son ölçüm, 120 örnek; medyan **17,948 ms**, p95 **23,920 ms**; snapshot **140 3D draw call**, **146.020 render primitive**. Bu sayaçlar kaynak mesh bütçesiyle aynı şey değildir; farklı pass'ler/varlıklar görünür maliyeti artırabilir.
- Windows headless smoke **73/73 PASS**. Yeni kontroller: üç dekoratif mesh, collision eklememeleri, zeminin özel shader'ı, saldırı işaretinde parlaklık ayrımı. Önceki görev/savaş/kamera kontrolleri korunur.

Sayaç API'si: [Godot RenderingServer](https://docs.godotengine.org/en/stable/classes/class_renderingserver.html). Belge bu istatistiklerin bazılarının yalnız 3D'yi kapsadığını söylüyor; 140 sayısı UI dahil tam uygulama draw-call toplamı diye sunulmamalı.

## Açık riskler

Profil sabit telegraph karesinin kısa ölçümüdür; frame pacing ve işletim sistemi etkisini içerir. GPU frame time, uzun süreli kararlılık veya iPhone performansı değildir. Son p95 16,67 ms hedefinin üzerinde; 60 FPS sürekli sağlanıyor diye iddia edilemez. Eklemenin önce/sonra maliyeti aynı koşullarda ölçülmedi, regresyon çıkarımı yapılamaz.

Derinlik artık boş fon yerine katmanlıdır ama aynı modelin tekrarı belli olur; ana kaburgalar hâlâ çok düzenli, zar malzemesi hâlâ opak ve karakter animasyonları ilk geçiştir. ADA hedefi tamamlanmadı. Hareket sırasında shader aliasing, küçük ekran, azaltılmış hareket görünümü ve dış oyuncu testi ayrıca gerekir.

Sonraki dar öncelik: mevcut sahnenin çok parçalı karakter/oda draw-call maliyetini ölçüp azaltmak; bundan sonra aynı parçanın birleşimlerini iyileştirmek. Yeni oda ailesi veya ağır efekt eklemek değil.
