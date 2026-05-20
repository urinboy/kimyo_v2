# Laboratoriya Javoblari Moduli — Walkthrough

**Status:** COMPLETED  
**Sana:** 2026-05-19

---

## Amalga oshirilgan ish

PDF (LABORATORIYA JAVOBLARI.pdf) dagi 9 ta laboratoriya ishi uchun to'liq modul yaratildi.

---

## 1. Database (9 ta migration)

| Fayl | Jadval |
|------|--------|
| `2026_05_19_110001_create_lab_works_table.php` | `lab_works` |
| `2026_05_19_110002_create_lab_work_translations_table.php` | `lab_work_translations` |
| `2026_05_19_110003_create_lab_experiments_table.php` | `lab_experiments` |
| `2026_05_19_110004_create_lab_experiment_translations_table.php` | `lab_experiment_translations` |
| `2026_05_19_110005_create_lab_reactions_table.php` | `lab_reactions` |
| `2026_05_19_110006_create_lab_observations_table.php` | `lab_observations` |
| `2026_05_19_110007_create_lab_observation_translations_table.php` | `lab_observation_translations` |
| `2026_05_19_110008_create_lab_products_table.php` | `lab_products` |
| `2026_05_19_110009_create_lab_product_translations_table.php` | `lab_product_translations` |

---

## 2. Backend — Laravel

### Models (9 ta)
- `LabWork`, `LabWorkTranslation`
- `LabExperiment`, `LabExperimentTranslation`
- `LabReaction`
- `LabObservation`, `LabObservationTranslation`
- `LabProduct`, `LabProductTranslation`

### Repository
- Interface: `app/Repositories/Interfaces/LabWorkRepositoryInterface.php`
- Implementation: `app/Repositories/Eloquent/LabWorkRepository.php`
  - `all()`: translations + experimentsCount eager load
  - `find(int $id)`: 4-darajali nested eager load
  - `create/update`: DB::transaction + syncExperiments helper
- Binding: `RepositoryServiceProvider.php` ga qo'shildi

### Controller + Routes
- `app/Http/Controllers/Api/LabWorkController.php` — CRUD + JSend + Swagger
- `routes/api.php`: GET/POST/PUT/DELETE `/lab-works` auth:sanctum ostida

---

## 3. React Admin Panel

| Fayl | Tavsif |
|------|--------|
| `resources/js/api/labWorks.ts` | TypeScript interfaces + API functions |
| `resources/js/pages/LabWorksPage.tsx` | Stats + glassmorphism list + delete |
| `resources/js/components/lab/LabWorkModal.tsx` | To'liq nested form |
| `App.tsx` | `/lab-works` route qo'shildi |
| `Sidebar.tsx` | Kimyo bo'limiga "Lab ishlari" item qo'shildi |
| `i18n/uz.json`, `ru.json`, `en.json` | `lab_works.*` namespace |

**Build:** built in 6.69s — LabWorksPage-D4AUBR7G.js bundle yaratildi.

---

## 4. Flutter Mobile — Clean Architecture

### Domain
- `entities/lab_work.dart`: to'liq entity hierarchy
- `repositories/lab_work_repository.dart`
- `usecases/get_lab_works.dart`, `get_lab_work_detail.dart`

### Data
- `models/lab_work_model.dart`: fromJson() + language_code fallback
- `datasources/lab_work_remote_datasource.dart`: Dio + utf8.decode + JSend
- `repositories/lab_work_repository_impl.dart`

### BLoC
- `lab_work_event.dart`, `lab_work_state.dart`, `lab_work_bloc.dart`

### UI Pages
- `lab_works_page.dart`: glassmorphism list
- `lab_work_detail_page.dart`: SliverAppBar + TabController

### DI + Navigatsiya
- `injection_container.dart`: barcha DI ro'yxatga qo'shildi
- `home_page.dart`: ModuleNavListCard + BlocProvider

---

## 5. Seeder

`database/seeders/LabWorkSeeder.php` — 9 ta lab:

| Lab # | Mavzu | Tajribalar |
|-------|-------|------------|
| 6 | Metallar faollik qatori | 2 |
| 8 | Al + kislota/ishqor | 2 |
| 10 | Al(OH)3 xossalari | 3 (bosqich) |
| 11 | AlCl3 gidrolizi | 1 |
| 12 | Cu(OH)2 olish + qizdirish | 2 |
| 13 | Rux gidroksid amfoterlik | 3 |
| 14 | Xrom birikmalari | 3 |
| 15 | Fe(OH)2 va Fe(OH)3 | 3 |
| 16 | Fe2+/Fe3+ sifat reaksiyalari | 3 |

`DatabaseSeeder.php` ga `LabWorkSeeder::class` qo'shildi.
