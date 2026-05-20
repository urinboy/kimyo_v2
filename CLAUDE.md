# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Strategik Majburiyat

Har bir suhbat boshlanishida `.claude/` papkasini ko'zdan kechirish **MAJBURIY**. Yangi qoidalar yoki ko'rsatmalar qo'shilgan bo'lsa, darhol inobatga ol.

**Muloqot tili:** O'zbek tili. Barcha texnik terminlar (endpoint, repository, build, state management) ingliz tilida qoladi.

---

## Loyiha Haqida

9-sinf o'quvchilari uchun metallar va Qoraqalpog'iston tabiiy resurslarini o'rganishga mo'ljallangan ta'lim platformasi.

| Qatlam | Texnologiya | Papka |
|--------|-------------|-------|
| Backend API | Laravel 13, PHP 8.3+ | `/api` |
| Admin Panel | React 19 + TypeScript + Vite | `/admin` |
| Mobil Ilova | Flutter, Clean Architecture | `/mobile` |

---

## Buyruqlar

### Backend (`/api`)
```bash
composer run setup        # To'liq boshlang'ich sozlash
composer run dev          # Laravel + queue + logs + Vite bir vaqtda
php artisan serve         # Faqat Laravel dev server
php artisan migrate       # DB migratsiyalari
composer run test         # Keshni tozalab PHPUnit testlari
php artisan test --filter TestName  # Bitta test
php artisan l5-swagger:generate     # Swagger dokumentatsiyani yangilash
npm run build             # Vite assets → ../public
```

### Admin Panel (`/admin`)
```bash
npm run dev       # Vite dev server (HMR)
npm run build     # TypeScript check + build (chiqish: ../api/public)
npm run lint      # ESLint
```

> **MAJBURIY:** Admin panelda har qanday o'zgarishdan keyin `npm run build` bajarish shart.

### Mobil (`/mobile`)
```bash
flutter pub get         # Dependencylarni o'rnatish
flutter run             # Qurilmada ishlatish
flutter run -d chrome   # Webda ishlatish
flutter build apk       # Android APK
flutter build appbundle # Android App Bundle
flutter clean           # Build artefaktlarini tozalash
```

---

## Arxitektura

### Backend (Laravel)

- **Pattern:** Repository Pattern — controllerlar to'g'ridan-to'g'ri Model bilan ishlamaydi
  - Interfacelar: `app/Repositories/Interfaces/`
  - Implementatsiyalar: `app/Repositories/Eloquent/`
  - Binding: `AppServiceProvider`
- **API versioning:** Barcha routelar `/v1` prefiksi ostida — `routes/api.php`
- **Auth:** Laravel Sanctum (token-based); `auth:sanctum` middleware
- **RBAC:** `spatie/laravel-permission`
- **API responses:** JSend standarti (success/fail/error)
- **Ko'p tillilik:** `*_translations` jadvallari; `Language` modeli (uz, ru, en)
- **API docs:** L5-Swagger; **har** yangi endpoint uchun annotation **majburiy**

### Admin Panel (React)

- **Server state:** TanStack React Query
- **Global state:** Zustand (`src/store/`)
- **API layer:** `src/api/` — har resurs uchun alohida modul
- **Routing:** React Router v7; sahifalar `src/pages/`
- **i18n:** i18next; barcha matnlar translation key orqali (`src/i18n/`)
- **Ikonalar:** **faqat** `lucide-react`
- **Build output:** `../api/public` (API orqali serve bo'ladi)

### Mobil (Flutter) — Clean Architecture

| Qatlam | Papka | Mas'uliyat |
|--------|-------|------------|
| Domain | `lib/domain/` | Entities, repo interfaces, use cases |
| Data | `lib/data/` | API datasources, JSON models, repo impls |
| Presentation | `lib/presentation/` | BLoC, pages, widgets |

- **DI:** GetIt — `lib/injection_container.dart`
- **HTTP:** Dio — `lib/core/network/`
- **State:** `flutter_bloc` (BLoC pattern)
- **Til:** `lib/core/localization/` — O'zbek (asosiy), Rus, Ingliz

---

## Dizayn Tizimi — Premium Glassmorphism

| Token | Qiymat |
|-------|--------|
| Primary Purple | `#A855F7` |
| Primary Green | `#10B981` |
| Glass White | `rgba(255,255,255,0.1)` |
| Glass Border | `rgba(255,255,255,0.2)` |
| Backdrop Blur | 8px – 16px |

**React (Tailwind):**
```css
.glass-card {
  @apply bg-white/10 backdrop-blur-md border border-white/20 rounded-3xl shadow-2xl;
}
```

**Flutter:**
```dart
ClipRRect(
  borderRadius: BorderRadius.circular(24),
  child: BackdropFilter(
    filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
    child: Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
      ),
    ),
  ),
)
```

---

## JSend API Standarti

```json
// Success (200, 201)
{ "status": "success", "data": { ... } }

// Fail — validation (400, 422)
{ "status": "fail", "data": { "field": "xato xabari" } }

// Error — server (500)
{ "status": "error", "message": "Xato tavsifi" }
```

---

## Hujjatlashtirish — Artefaktlar

| Tur | Papka |
|-----|-------|
| Implementation plans | `.claude/artifacts/implementation_plan/` |
| Tasks | `.claude/artifacts/task/` |
| Walkthroughs | `.claude/artifacts/walkthrough/` |

Fayl nomlash: `yyyy-mm-dd-HH-MM-vazifa-nomi.md` — **aniq hozirgi vaqt**, kelajak sana yo'q.

Har "Feature" oldidan → `implementation_plan`, tasdiqlangandan → `task`, yakunlangandan → `walkthrough`.

---

## `.claude/` Papkasi Tuzilishi

```
.claude/
  agents/           # Agent rol ta'riflari (miya, admin_ui, laravel_backend, flutter_architect)
  rules/            # Har texnologiya uchun kodlash standartlari (laravel, react, flutter, docs)
  knowledge/        # Loyiha baza bilimlari
  skills/           # Texnik ko'rsatmalar (jsend_api, glassmorphism_ui, crud_with_translations, ...)
  artifacts/
    implementation_plan/
    task/
    walkthrough/
```
