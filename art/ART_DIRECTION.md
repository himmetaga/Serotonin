# Serotonin — Blender / Godot görsel sözleşmesi

9 Ekim 2026. `create-game-assets` becerisinin sanat yönü ve 3D üretim rehberleri uygulanmıştır. İlk görsel yön kullanıcı tarafından Astra'ya devredilen yaratıcı denetimle seçildi; nihai oyun sanatı onayı değildir.

## Game frame

- Fantezi: bir insanın içindeki küçük, şefkatli kurye.
- Eylemler: süzül, atıl, taşı, bağla, zırhı çöz.
- Motor: yerelde bulunan Godot 4.7.2; ilk doğrulama Windows, nihai hedef iOS.
- Modelleme: yerelde bulunan Blender 5.2.1 LTS; düzenlenebilir `.blend`, çalışma zamanı `.glb`.
- Kamera: sabit ortografik üç çeyrek üst görünüş; ilk oyun görüntüsü 1280×800.
- Birim: 1 Blender metre = 1 Godot birimi. Blender Z yukarı / -Y ön, GLB sonrası Godot +Y yukarı / +Z ön.
- İlmek yaklaşık 1.4 birim yüksek; ekran üzerinde yaklaşık 70–100 piksel hedefi test edilecek.

## Visual system

- Dil: elde biçimlendirilmiş, ışık taşıyan zar bahçesi. İnce ayrıntıdan önce okunaklı oran ve siluet.
- İlmek: damla gövde, küçük koyu yüz, yanlara ayrılan zar kanatları ve altın iplik. Yönünü kanatlar ve yüz anlatır.
- Nefes: boş merkezli üç lob; işlevi genleşme. Karakterden farklı siluet.
- Kıskaç: alçak ve geniş mercan kabuk, iki kemerli kol, belirgin altın dikiş.
- Çevre: açık merkez; kenarlarda az sayıda organik tomurcuk ve katlanmış zar.
- Palet rolleri: inci `#E8E1D5` karakter; petrol `#244B50` çevre/yüz; mercan `#D99689` muhafız; altın `#E8BD64` bağlantı ve yük; koyu mürekkep `#102E34` odak kontrastı.
- Malzemeler: opak mat sedef ve saten yüzey. İlk sürümde saydamlık, shader tabanlı cilt ve doku indirmesi yok.
- Işık: yumuşak sıcak ana ışık, serin dolgu; görev işaretleri ışık efektine bağımlı değil.
- Hareket: küçük soluma ve yumuşak yön dönüşü; saldırı hazırlığı okunaklı. İlk meshler rig'siz; çalışma zamanı düğüm hareketi ile canlandırılır.

## Technical contract

- İlmek <=6000, Nefes <=2000, Kıskaç <=8000, tek bahçe <=12000 üçgen başlangıç bütçesi.
- Model başına en fazla 3 ortak PBR malzeme; ilk sette bitmap doku yok, bu nedenle UV atlas zorunlu değil. UV varsa raporlanır, yoksa doku üretimine geçmeden açılır.
- Kök pivot ayak/zemin merkezinde; negatif veya uygulanmamış mesh ölçeği bulunmamalı.
- Model kaynağı `art/source/`, GLB `godot/assets/models/`, betikler `art/tools/`, renderlar `art/previews/`.
- Çarpışma görsel mesh'ten ayrı, oyunda basit hacim/mesafe ile tanımlanır. İlk sette skin rig ve LOD bulunmaz; nihai üretimden önce hareket ve profil ihtiyacına göre eklenir.

## Visual target

- İlk hedef: `art/previews/ilmek.png`; aynı paletle diğer üç varlık.
- Son kontrol: Blender renderı + Godot çalışma zamanı görüntüsü + GLB geometri raporu.
- Kaynak: proje için bpy ile yazılmış geometri, harici model/texture yok. Oluşturma kaydı üretici betik ve `asset_manifest.json` içinde.
- Teknik rapor ve motor içi gözlem yapılmadan production-ready etiketi kullanılmaz.
