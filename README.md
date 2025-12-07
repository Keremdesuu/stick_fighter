# Stick Fight - Love2D Çöp Adam Dövüş Oyunu

## Oyun Hakkında
Love2D ile geliştirilmiş 2 oyunculu çöp adam dövüş oyunu.

## Özellikler
- ✅ **Fizik Tabanlı Hareket**: Gerçekçi fizik motoru
- ✅ **Combo Sistemi**: Yumruk-Yumruk-Tekme zincirleme saldırılar
- ✅ **Silah Sistemi**: 6 farklı silah tipi (Kılıç, Balta, Sopa, Çekiç, Mızrak, Nunçaku)
- ✅ **Silah Generator'leri**: Map'te rastgele silah üretimi
- ✅ **2 Oyunculu**: Aynı klavyede iki oyuncu

## Kontroller

### Oyuncu 1
- **A/D**: Sağa-Sola hareket
- **W**: Zıplama
- **F**: Saldırı
- **E**: Silah alma

### Oyuncu 2
- **Ok Tuşları (←/→)**: Sağa-Sola hareket
- **Yukarı Ok (↑)**: Zıplama
- **Sağ Ctrl**: Saldırı
- **Sağ Shift**: Silah alma

## Combo Sistemi
1. **İlk Saldırı**: Yumruk (5 hasar)
2. **İkinci Saldırı**: Yumruk (5 hasar)
3. **Üçüncü Saldırı**: Tekme (10 hasar)
4. **Dördüncü Saldırı**: Uppercut (15 hasar)
5. **Beşinci Saldırı**: Özel Saldırı (20 hasar)

Combo'yu 1 saniye içinde devam ettirmelisiniz!

## Silahlar
- **Kılıç**: +15 hasar
- **Balta**: +20 hasar
- **Sopa**: +12 hasar
- **Çekiç**: +18 hasar
- **Mızrak**: +16 hasar
- **Nunçaku**: +14 hasar

## Nasıl Oynanır
1. Love2D'yi yükleyin: https://love2d.org/
2. Oyun klasörünü Love2D'ye sürükleyin veya komut satırından çalıştırın:
   ```
   love .
   ```

## Dosya Yapısı
- `main.lua`: Ana oyun döngüsü
- `player.lua`: Çöp adam sınıfı (hareket, saldırı, combo)
- `weapon.lua`: Silah sistemi
- `weaponGenerator.lua`: Silah üreticileri

## Geliştirme Notları
- Oyun 1200x700 çözünürlükte çalışır
- Fizik motoru: Box2D (Love2D dahili)
- Combo penceresi: 1 saniye
- Silah üretim süresi: 5-10 saniye arası rastgele

## İyileştirme Fikirleri
- [ ] Ses efektleri ekle
- [ ] Partikül sistemleri (kan, çarpışma)
- [ ] Daha fazla silah tipi
- [ ] Power-up'lar
- [ ] Farklı arenalar
- [ ] Turnam sistemi (ilk 3'ü alan kazansın)
- [ ] Yapay zeka rakip

Keyifli oyunlar!
