# App Store Connect metadata

16 dil için hazır metin seti.

`metadata.json` **tek kaynaktır.** Metinleri orada düzenle, sonra

```
python3 tool/gen_fastlane_metadata.py
```

çalıştır; fastlane'in okuduğu `ios/fastlane/metadata/<locale>/*.txt`
dosyaları yeniden üretilir ve karakter limitleri doğrulanır.

## Alanlar ve limitler

| Alan | Limit | Apple araması indeksliyor mu? |
|---|---|---|
| App Name | 30 | **Evet — en ağır sinyal** |
| Subtitle | 30 | **Evet — ikinci en ağır** |
| Keywords | 100 | **Evet** |
| Promotional Text | 170 | Hayır |
| Description | 4000 | **Hayır** (App Store'da) |
| What's New | 4000 | Hayır |

Bütün alanlar limitlerin altında doğrulandı. Hiçbir keyword isim veya
subtitle'da tekrarlanmıyor — Apple üç alanı birlikte indekslediği için tekrar
karakter israfıdır.

## Google Play farkı

Play Store'un keyword alanı yoktur; onun yerine **başlık, kısa açıklama ve tam
açıklamayı** indeksler. Yani buradaki `DESCRIPTION` metinleri App Store'da
sıralamaya girmez ama Play Store'da doğrudan sıralama sinyalidir. Play'e
çıkarken açıklamaları aynen kullan.

## Yükleme

fastlane ile, `ios/` klasöründen:

```
fastlane deliver --skip_binary_upload --skip_screenshots
```

16 dilin metadata'sını tek seferde gönderir. İlk çalıştırmada Apple hesabını
sorar ve göndermeden önce tarayıcıda bir önizleme açar.

Elle girmeyi tercih edersen alanlar App Store Connect'te **iki ayrı sayfada**:
App Name ve Subtitle → App Information; Keywords, Description, Promotional Text
ve What's New → sürüm sayfası. Her ikisinin de kendi dil menüsü var ve
kaydetme otomatik değil.

**Önemli:** App Name, Subtitle ve Keywords **sürüme bağlıdır** — yalnızca yeni
bir build gönderirken değiştirilebilir. Promotional Text ise istediğin zaman,
inceleme beklemeden güncellenebilir. 16 dilin lokalizasyonu zaten yeni bir
sürüm gerektirdiği için zamanlama doğru.

## İsim değişikliği hakkında

Mevcut isim `Fingerlette: Finger Roulette`. "Fingerlette" uydurma bir kelime;
arama hacmi yok ve 30 karakterlik en değerli alanın yarısını harcıyor. Yeni
isimler her dilde gerçek arama terimleri üzerine kurulu ("kim ödeyecek",
"あみだくじ", "사다리타기", "谁买单" gibi).

Uygulama adını değiştirmek **puanları ve yorumları sıfırlamaz** — 4.8
ortalaman aynen taşınır. Yeni sürüm gönderirken App Store Connect'teki
**"Reset ratings" seçeneğine dokunma**; sıfırlama yalnızca o kutuyla olur.

## ABD mağazasında ekstra kazanç

ABD storefront'unda cihaz dili İspanyolca olan kullanıcılar `es-MX`
lokalizasyonunu görür ve Apple o dilin keyword'lerini de ABD aramasında
indeksler. İndirmelerinin 69'u ABD kaynaklı olduğu için `es-MX` setini
atlamaman özellikle önemli.

İstersen sonradan English (U.K.) ve English (Australia) lokalizasyonlarını da
ekleyebilirsin: aynı metinlerle, o storefront'lar için 100 karakterlik ek bir
keyword alanı açarlar.

## Bu metinlerin uygulamayla uyumu

Açıklamalarda söz verilen her şey mevcut sürümde var: 2–5 oyuncu, çoklu
kazanan, ses, titreşim, çevrimdışı çalışma, reklamsız. **Takım bölme ve sıra
belirleme modları henüz yok** — o yüzden hiçbir metinde geçmiyorlar. O modları
eklediğinde subtitle ve keyword setlerinin güncellenmesi gerekir.
