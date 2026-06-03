# Gemini Request
**Status:** COMPLETED
**Tur:** content_generation
**Model:** 3d_models
**Sana:** 2026-06-03

## So'rov

Quyidagi 6 ta mineral/ruda uchun **o'zbek, rus va ingliz** tillarida tavsif yoz.

**Maqsadli auditoriya:** 9-sinf o'quvchilari (14-15 yosh)
**Uslub:** Qisqa (2-3 gap), ilmiy lekin tushunarli, qiziqarli
**Uzunlik:** har til uchun 50-80 so'z

## Minerallar ro'yxati

| id | slug | Nomi |
|----|------|------|
| 1 | halite_germany | Galit (Germaniyadan namuna) |
| 2 | hematite | Gematit |
| 3 | iron_ore | Temir rudasi |
| 4 | magnetite | Magnetit |
| 5 | rock_salt | Tosh tuzi |
| 6 | zinc_ore | Rux rudasi |

## Kontekst

Bu Qoraqalpog'iston tabiiy resurslari va metallar mavzusidagi ta'lim ilovasidagi 3D modellar.
Minerallar Qoraqalpog'iston/O'zbekiston bilan bog'liq bo'lsa yaxshi (ayniqsa temir, rux, tosh tuzi).

## Chiqish formati

JSON massiv, quyidagi struktura:

```json
[
  {
    "id": 1,
    "slug": "halite_germany",
    "translations": {
      "uz": { "name": "Galit", "description": "..." },
      "ru": { "name": "Галит", "description": "..." },
      "en": { "name": "Halite", "description": "..." }
    }
  }
]
```

Faqat JSON qaytargil — boshqa tushuntirish kerak emas.
