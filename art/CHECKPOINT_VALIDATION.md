# Mevcut arena — güvenli aşama kaydı

10 Ekim 2026. `user://nefes_checkpoint_v1.json`, mevcut arena kimliği `nefes_arena_v1`.

Yedi checkpoint: başlangıç, kargo alındı, muhafız karşılaşması, muhafız sakinleşti, ilk bağ, teslimat hazır, teslimat tamamlandı. Geçişler simulate_step sonunda kaydedilir; vuruş ortası, dash süresi, kamera ve rastgele canlı Node bilgisi yazılmaz. Muhafız sırasında çıkış karşılaşmanın başına döner; birinci isabet saklanmaz. Tamamlanmış teslimatın çevre sonucu kurulur, ses tekrar çalınmaz. “Baştan başla” kayıt noktasını sıfırlar; ayar tercihlerine dokunmaz.

`checkpoint_store.gd`, ayar deposunun sınırlı JSON okuma/temp/backup mekanizmasını yeniden kullanır; checkpoint doğrulaması ve yazma şeması ayrıdır. Tür, tam sayı 0–6, version ve bölüm kimliği denetlenir. Bozuk ana kayıtta sağlam yedek; daha yeni sürümde koruma; kayıt hatası menüde mesaj. Windows güç kesintisine karşı mutlak atomiklik iddiası yok. Başarısız yazma her karede tekrar edilmez, sonraki aşamada yeniden denenir.

## Kanıt

- Ayrı Godot işlemlerinde checkpoint write **1 PASS**, read **23 PASS**. İlk karede tamamlanmış durum ve sessiz çevre sonucu; bütün noktaların dünya durumuna kurulması; kesir/yanlış bölüm/aralık reddi; bozuk kayıttan önceki yedeğe dönüş; gelecek sürümü koruma; reset sınandı.
- `assisted_flow.gd --flow-save --flow-motion`: mevcut görevin gerçek dokunma akışında altı aşama kayıt noktasını workspace QA dosyasına yazar; sonuç **38 PASS**, iki bilinçli atılma, sıfır darbe. Konum veya savaş aşaması bu akışta zorla atanmaz.
- Son genel smoke **160 PASS**. Testler kişisel kayıt yolundan izole; ayar testleri de checkpoint yolunu açıkça kapatır. `--capture=` kayıt yüklemeyi/yazmayı kapatır; sentetik QA kişisel ilerlemeye taşınmaz.

## Sınırlar

Bu tek arena için ilk checkpoint şemasıdır; tam bölüm, çoklu kayıt, bulut eşitleme veya oyunun bütün hikâyesi değildir. Sürümler arası eski checkpoint migration henüz yok; yeni kayıt korunur ve varsayılan oturum açılır. Gerçek güç kesintisi, disk doluluğu, iPhone askıya alınması ve kullanıcı testi yapılmadı. Menüde ilerleme hatası mesajı kodda bağlandı, bu tur yeni görsel yakalama yok.

`save-systems` becerisi yalnız yetkili veriyi saklama, güvenli aşama sınırları, yedek ve yeniden açılış doğrulamasını yönlendirdi. Yeni varlık üretimi/ajan ekibi yok.
