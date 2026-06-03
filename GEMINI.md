# GEMINI.md — Kimyo V2.5.20

> Bu fayl Gemini IDE extension tomonidan sessiya boshida avtomatik o'qiladi.
> Claude Code tomonidan `CLAUDE.md` o'qiladi — bu fayl esa Gemini uchun.

---

## Loyiha

9-sinf o'quvchilari uchun kimyo + Qoraqalpog'iston ta'lim platformasi.

| Qatlam | Texnologiya | Papka |
|--------|-------------|-------|
| Backend API | Laravel 13, PHP 8.3+ | `/api` |
| Admin Panel | React 19 + TypeScript + Vite | `/admin` |
| Mobil Ilova | Flutter, Clean Architecture | `/mobile` |

**API:** `http://127.0.0.1:8089/api/v1` (local) / `https://kimyo.itorda.uz/api/v1` (prod)

---

## Vazifalar taqsimoti

### Claude Code mas'ul:
- Flutter/Laravel/React kod yozish, arxitektura
- CRUD, API endpoint, migration
- UI komponentlar, BLoC, state management
- Bug fix, refactor

### Gemini mas'ul:
- **3D modellar uchun kontent**: atom/molekula tavsifi generatsiya
- **Kimyo matnlari**: element, formulalar, laboratoriya ishlar tavsifi
- **Ko'p tillilik**: uz/ru/en tarjima va tekshirish
- **Data validatsiya**: backend'dan kelgan ma'lumotlar to'g'riligini tekshirish
- **Tushuntirish**: murakkab kimyo tushunchalarini sodda tildagi ta'rif

---

## Muloqot protokoli (Claude ↔ Gemini)

### Gemini uchun so'rov:
Fayl: `D:\Buyurtmalar\kimyo_v2.5.20\.claude\gemini\request.md`

```markdown
# Gemini Request
**Tur:** content_generation | translation | validation | explanation
**Model:** 3d_models | elements | formulas | lab_works
**Til:** uz | ru | en | all

## So'rov
[Claude yoki developer yozadi]

## Kontekst
[API dan kelgan raw JSON yoki boshqa ma'lumot]
```

### Gemini javobi:
Fayl: `D:\Buyurtmalar\kimyo_v2.5.20\.claude\gemini\response.md`

```markdown
# Gemini Response
**Sana:** YYYY-MM-DD HH:MM
**So'rov_turi:** ...

## Natija
[Gemini generatsiya qilgan kontent]
```

---

## 3D Modellar (asosiy vazifa)

Backend endpoint: `GET /api/v1/3d-models`

```json
{
  "id": 1,
  "slug": "water-molecule",
  "model_url": "https://kimyo.itorda.uz/storage/3d-models/uuid.glb",
  "element_id": null,
  "name": "Suv molekulasi",
  "description": "H2O — V shakldagi molekula"
}
```

**Gemini vazifasi**: `description` maydonini 3 tilda boyitish, kimyo tushuntirish qo'shish.

---

## Fayl tuzilishi

```
kimyo_v2.5.20/
├── api/          ← Laravel backend
├── admin/        ← React admin panel
├── mobile/       ← Flutter app
├── CLAUDE.md     ← Claude instruksiyalari
├── GEMINI.md     ← bu fayl
└── .claude/
    └── gemini/
        ├── request.md   ← Claude→Gemini so'rov
        └── response.md  ← Gemini→Claude javob
```

---

## Tillar va uslub

- **O'zbek** asosiy til
- Kimyo terminlari: ilmiy, lekin 9-sinf darajasida tushunarli
- Formulalar: `H₂O`, `NaCl`, `CO₂` formatida

---

## Muhim qoidalar

- `CLAUDE.md` va `GEMINI.md` ni o'chirma yoki o'zgartirma — Claude o'qiydi
- `.claude/gemini/request.md` ga yozilgan so'rovni bajarib `response.md` ga yaz
- Kod yozma — bu Claude vazifasi; matn, kontent, tarjima — Gemini vazifasi
