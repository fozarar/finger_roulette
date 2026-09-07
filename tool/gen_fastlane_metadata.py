#!/usr/bin/env python3
"""app_store_metadata/metadata.json → ios/fastlane/metadata/<locale>/*.txt

metadata.json tek kaynaktır. Metinleri orada düzenle, sonra bu scripti
çalıştır; fastlane'in okuduğu dosyalar yeniden üretilir. İki yeri elle
güncellemeye çalışma — ayrışırlar.

    python3 tool/gen_fastlane_metadata.py

Apple'ın karakter limitlerini de doğrular; aşan bir alan varsa hiçbir
dosya yazılmadan hata verir.
"""
import io
import json
import os
import sys

SRC = 'app_store_metadata/metadata.json'
DST = 'ios/fastlane/metadata'

# metadata.json anahtarı -> (deliver dosya adı, App Store karakter limiti)
FIELDS = {
    'name':        ('name.txt',              30),
    'subtitle':    ('subtitle.txt',          30),
    'keywords':    ('keywords.txt',         100),
    'description': ('description.txt',      4000),
    'promo':       ('promotional_text.txt',  170),
    'whatsnew':    ('release_notes.txt',    4000),
}


def main():
    meta = json.load(io.open(SRC, encoding='utf-8'))

    # Önce tamamını doğrula — kısmen yazılmış bir ağaç bırakmayalım
    errors = []
    for loc, d in meta.items():
        for key, (fname, limit) in FIELDS.items():
            if key not in d:
                errors.append(f'{loc}: "{key}" alanı yok')
                continue
            value = d[key]
            if len(value) > limit:
                errors.append(f'{loc}/{fname}: {len(value)} karakter > {limit}')
            if value != value.strip():
                errors.append(f'{loc}/{fname}: baştaki/sondaki boşluk')
        if ', ' in d.get('keywords', ''):
            errors.append(f'{loc}/keywords.txt: virgülden sonra boşluk — '
                          f'100 karakterlik bütçeyi israf eder')

    if errors:
        print('Doğrulama başarısız, hiçbir dosya yazılmadı:', file=sys.stderr)
        for e in errors:
            print('  ✗', e, file=sys.stderr)
        return 1

    count = 0
    for loc, d in meta.items():
        os.makedirs(f'{DST}/{loc}', exist_ok=True)
        for key, (fname, _) in FIELDS.items():
            # Sondaki newline yok: karakter limitli alanlarda riske girme
            io.open(f'{DST}/{loc}/{fname}', 'w', encoding='utf-8').write(d[key])
            count += 1

    print(f'{len(meta)} locale × {len(FIELDS)} alan = {count} dosya → {DST}/')
    return 0


if __name__ == '__main__':
    sys.exit(main())
