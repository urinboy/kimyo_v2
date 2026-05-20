# Laboratoriya Javoblari Moduli — Implementation Plan
**Status:** PENDING
**Sana:** 2026-05-19

---

## Manba PDF tahlili

11 sahifali "LABORATORIYA JAVOBLARI .pdf" dan quyidagi laboratoriyalar aniqlandi:

| Lab № | Mavzu |
|-------|-------|
| 6 | Metallar faollik qatori (Cu/Ag, Fe/Cu, Cu/Pb) |
| 8 | Aluminiyning kislota va asos bilan ta'siri |
| 10 | Aluminiy gidroksid va amfoter xossalar (3 bosqich) |
| 11 | Aluminiy tuzlari gidrolizi va indikatorlar |
| 12 | Mis(II)-gidroksid olish va xossalari |
| 13 | Rux gidroksid va amfoter xossalar (3 bosqich) |
| 14 | Xrom birikmalari (3 tajriba) |
| 15 | Temir(II) va Temir(III) gidroksidlar |
| 16 | Fe²⁺ va Fe³⁺ ionlarga sifat reaksiyalari |

Har bir laboratoriya quyidagi tuzilmaga ega:
- Sub-tajribalar (probirka / tajriba / bosqich)
- Kimyoviy reaksiya tenglamalari (molekulyar / to'la ionli / qisqa ionli)
- Kuzatiladigan holatlar (bullet ro'yxati)
- Hosil bo'lgan moddalar (kimyoviy formula + nom)
- Ilmiy izoh (ixtiyoriy)

---

## Datalogik Model (9 jadval)

```
lab_works (1)
  └── lab_work_translations (∞)      — ko'p tillilik
  └── lab_experiments (∞)
        └── lab_experiment_translations (∞)
        └── lab_reactions (∞)         — kimyoviy tenglamalar
        └── lab_observations (∞)
              └── lab_observation_translations (∞)
        └── lab_products (∞)
              └── lab_product_translations (∞)
```

### Jadval spesifikatsiyalari

#### lab_works
```
id               bigIncrements  PK
number           tinyInteger    laboratoriya raqami (6, 8, 10...)
status           enum('active','inactive')  default: active
created_at / updated_at
```

#### lab_work_translations
```
id               bigIncrements  PK
lab_work_id      FK → lab_works (CASCADE)
language_id      FK → languages (CASCADE)
title            varchar(255)   — "6-Laboratoriya: Metallar faolligi"
description      text?          — umumiy kirish matni
UNIQUE(lab_work_id, language_id)
```

#### lab_experiments
```
id               bigIncrements  PK
lab_work_id      FK → lab_works (CASCADE)
type             enum('probirka','tajriba','bosqich')
order_index      tinyInteger    — tartib raqami
status           enum('active','inactive')  default: active
created_at / updated_at
```

#### lab_experiment_translations
```
id                    bigIncrements  PK
lab_experiment_id     FK → lab_experiments (CASCADE)
language_id           FK → languages (CASCADE)
title                 varchar(255)   — "1-probirka: Kumush(I)-nitrat + mis simi"
scientific_explanation text?          — "Ilmiy izoh" matni
UNIQUE(lab_experiment_id, language_id)
```

#### lab_reactions
```
id                  bigIncrements  PK
lab_experiment_id   FK → lab_experiments (CASCADE)
formula             text           — "Cu+2AgNO3→Cu(NO3)2+2Ag↓"
type                enum('molecular','full_ionic','short_ionic')
order_index         tinyInteger
```
> ℹ️ Reaksiya formulalari faqat bitta tilda (original kimyo yozuvi) — tarjima jadval kerak emas.

#### lab_observations
```
id                  bigIncrements  PK
lab_experiment_id   FK → lab_experiments (CASCADE)
order_index         tinyInteger
```

#### lab_observation_translations
```
id                   bigIncrements  PK
lab_observation_id   FK → lab_observations (CASCADE)
language_id          FK → languages (CASCADE)
text                 text           — "Mis sim yuzasida kumush rangli cho'kma hosil bo'ladi"
UNIQUE(lab_observation_id, language_id)
```

#### lab_products
```
id                  bigIncrements  PK
lab_experiment_id   FK → lab_experiments (CASCADE)
chemical_formula    varchar(100)   — "Cu(NO3)2"
state               enum('dissolved','precipitate','gas','solid','unknown')  default: dissolved
order_index         tinyInteger
```

#### lab_product_translations
```
id               bigIncrements  PK
lab_product_id   FK → lab_products (CASCADE)
language_id      FK → languages (CASCADE)
name             varchar(255)   — "Mis(II)-nitrat"
UNIQUE(lab_product_id, language_id)
```

---

## Todos

### BOSQICH 1 — Database Migrations (Laravel)
- [ ] `create_lab_works_table`
- [ ] `create_lab_work_translations_table`
- [ ] `create_lab_experiments_table`
- [ ] `create_lab_experiment_translations_table`
- [ ] `create_lab_reactions_table`
- [ ] `create_lab_observations_table`
- [ ] `create_lab_observation_translations_table`
- [ ] `create_lab_products_table`
- [ ] `create_lab_product_translations_table`

### BOSQICH 2 — Laravel Models + Repositories
- [ ] `LabWork` model (hasMany experiments, hasMany translations)
- [ ] `LabWorkTranslation` model
- [ ] `LabExperiment` model (hasMany reactions, observations, products)
- [ ] `LabExperimentTranslation` model
- [ ] `LabReaction` model
- [ ] `LabObservation` model (hasMany translations)
- [ ] `LabObservationTranslation` model
- [ ] `LabProduct` model (hasMany translations)
- [ ] `LabProductTranslation` model
- [ ] `LabWorkRepository` (index, show with nested, store, update)
- [ ] `LabWorkService` (nested create/update logic)

### BOSQICH 3 — Laravel API + Routes
- [ ] `LabWorkController` (index, show, store, update, destroy)
  - `GET /api/v1/lab-works` — barcha laboratoriyalar (translations bilan)
  - `GET /api/v1/lab-works/{id}` — to'liq ma'lumot (nested eager load)
  - `POST /api/v1/lab-works` — yangi lab yaratish (nested JSON)
  - `PUT /api/v1/lab-works/{id}` — yangilash
  - `DELETE /api/v1/lab-works/{id}` — o'chirish
- [ ] Swagger annotations (barcha endpointlar)
- [ ] `php artisan l5-swagger:generate`

**GET /api/v1/lab-works/{id} javob strukturasi:**
```json
{
  "status": "success",
  "data": {
    "lab_work": {
      "id": 1,
      "number": 6,
      "status": "active",
      "translations": [
        { "language_code": "uz", "title": "6-Laboratoriya: Metallar faolligi" }
      ],
      "experiments": [
        {
          "id": 1,
          "type": "probirka",
          "order_index": 1,
          "translations": [
            { "language_code": "uz", "title": "1-probirka", "scientific_explanation": "..." }
          ],
          "reactions": [
            { "id": 1, "formula": "Cu+2AgNO3→...", "type": "molecular", "order_index": 1 }
          ],
          "observations": [
            {
              "id": 1, "order_index": 1,
              "translations": [{ "language_code": "uz", "text": "Kumush cho'kmasi..." }]
            }
          ],
          "products": [
            {
              "id": 1, "chemical_formula": "Cu(NO3)2", "state": "dissolved",
              "translations": [{ "language_code": "uz", "name": "Mis(II)-nitrat" }]
            }
          ]
        }
      ]
    }
  }
}
```

### BOSQICH 4 — React Admin Panel
- [ ] `resources/js/api/labWorks.ts` — TypeScript interfacelari + API funksiyalar
- [ ] `resources/js/pages/LabWorksPage.tsx` — ro'yxat sahifasi (CRUD)
- [ ] `resources/js/components/lab/LabWorkForm.tsx` — nested form
- [ ] `resources/js/components/lab/LabExperimentForm.tsx`
- [ ] Router ga yangi route qo'shish
- [ ] Sidebar ga link qo'shish (FlaskConical icon)
- [ ] i18n kalitlari (uz/ru/en): `lab_works.*`
- [ ] `npm run build`

### BOSQICH 5 — Flutter Mobile
- [ ] Domain entities:
  - `LabWorkEntity`, `LabWorkTranslationEntity`
  - `LabExperimentEntity`, `LabExperimentTranslationEntity`
  - `LabReactionEntity`
  - `LabObservationEntity`
  - `LabProductEntity`
- [ ] Data models:
  - `lib/data/models/lab_work_model.dart` — fromJson/toJson
- [ ] Datasource:
  - `lib/data/datasources/lab_work_remote_datasource.dart`
- [ ] Repository:
  - `lib/domain/repositories/lab_work_repository.dart` (interface)
  - `lib/data/repositories/lab_work_repository_impl.dart`
- [ ] Use cases:
  - `GetLabWorksUseCase`, `GetLabWorkDetailUseCase`
- [ ] BLoC:
  - `lib/presentation/bloc/lab_work/lab_work_bloc.dart`
  - Events: `LoadLabWorks`, `LoadLabWorkDetail`
  - States: `LabWorkLoading`, `LabWorksLoaded`, `LabWorkDetailLoaded`, `LabWorkError`
- [ ] Pages:
  - `lib/presentation/pages/lab_works_page.dart` — glassmorphism card list
  - `lib/presentation/pages/lab_work_detail_page.dart` — experiment tabs, reaction cards, observation list
- [ ] DI registration (injection_container.dart)
- [ ] Home screen ga navigatsiya link qo'shish

---

## Ta'sirlangan Fayllar

### Yangi fayllar (Laravel)
- `database/migrations/YYYY_MM_DD_create_lab_works_table.php` (x9 migration)
- `app/Models/LabWork.php`, `LabWorkTranslation.php`
- `app/Models/LabExperiment.php`, `LabExperimentTranslation.php`
- `app/Models/LabReaction.php`
- `app/Models/LabObservation.php`, `LabObservationTranslation.php`
- `app/Models/LabProduct.php`, `LabProductTranslation.php`
- `app/Repositories/LabWorkRepository.php`
- `app/Services/LabWorkService.php`
- `app/Http/Controllers/Api/LabWorkController.php`

### O'zgartirilgan fayllar (Laravel)
- `routes/api.php` — yangi routelar

### Yangi fayllar (React)
- `resources/js/api/labWorks.ts`
- `resources/js/pages/LabWorksPage.tsx`
- `resources/js/components/lab/LabWorkForm.tsx`
- `resources/js/components/lab/LabExperimentForm.tsx`

### O'zgartirilgan fayllar (React)
- `resources/js/main.tsx` — yangi route
- `resources/js/components/layout/Sidebar.tsx` — yangi link
- `resources/js/i18n/locales/uz.json`, `ru.json`, `en.json`

### Yangi fayllar (Flutter)
- `mobile/lib/domain/entities/lab_work.dart`
- `mobile/lib/domain/repositories/lab_work_repository.dart`
- `mobile/lib/domain/usecases/get_lab_works.dart`
- `mobile/lib/domain/usecases/get_lab_work_detail.dart`
- `mobile/lib/data/models/lab_work_model.dart`
- `mobile/lib/data/datasources/lab_work_remote_datasource.dart`
- `mobile/lib/data/repositories/lab_work_repository_impl.dart`
- `mobile/lib/presentation/bloc/lab_work/lab_work_bloc.dart`
- `mobile/lib/presentation/pages/lab_works_page.dart`
- `mobile/lib/presentation/pages/lab_work_detail_page.dart`

### O'zgartirilgan fayllar (Flutter)
- `mobile/lib/injection_container.dart`
- `mobile/lib/presentation/pages/home_page.dart` yoki navigation widget

---

## Qo'shimcha eslatmalar

1. **Seeder**: Barcha 9 ta laboratoriya uchun seeder yozilib, ma'lumotlar avtomatik kiritilsin
   - `database/seeders/LabWorkSeeder.php`
2. **`lesson_lab_items` bilan aloqa**: Hozirgi `LessonLabItem` faqat lab uchun kerakli jihozlar/reagentlar ro'yxati. Bu yangi modul laboratoriya **javobi/natijasi** uchun — ikki modul parallel ishlaydi, bir-biriga tegmaydi.
3. **Reaksiya formulalari**: formula maydoni plain text sifatida saqlanadi. Mobile/web frontendda `ChemicalFormulaText`-ga o'xshash widget formula ichidagi raqamlarni subscript qilib ko'rsatadi.
4. **Eager loading**: `GET /lab-works/{id}` da barcha 4 daraja `with()` bilan eager load qilinsin — N+1 muammo bo'lmasin.
5. **API autentifikatsiya**: `GET` endpointlar ochiq (mobile uchun), `POST/PUT/DELETE` faqat `auth:sanctum`.
