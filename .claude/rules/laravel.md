---
name: Laravel Coding Standards
description: Backend API uchun kodlash standartlari va qoidalari.
---

# Laravel Coding Standards

## 1. API Standarti — JSend Format

```json
// Success (200, 201)
{ "status": "success", "data": { "item": { "id": 1 } } }

// Fail — validation (400, 422)
{ "status": "fail", "data": { "title": "Sarlavha kiritilishi shart" } }

// Error — server (500)
{ "status": "error", "message": "Database ulanishda xato" }
```

## 2. Arxitektura
- **Repository Pattern:** Barcha DB operatsiyalar Repository class-lari orqali
- **Service Pattern:** Murakkab business logika Service class-larida
- **Controller:** Faqat request validation + service/repository chaqirish
- **Model:** Strict type hinting, mass assignment himoyasi (`$fillable`)

## 3. Database
- Jadval va ustun nomlari: `snake_case`
- Barcha DB o'zgarishlar **faqat migrations** orqali
- Boshlang'ich ma'lumotlar uchun seeder-lar yaratish (elements, categories)

## 4. Ko'p Tillilik (Translations)
- Asosiy jadval: `id`, `status`, `created_at`, `updated_at`
- Tarjima jadval: `id`, `parent_id` (FK cascade), `language_id` (FK), `title`, `description`
- Validate: `uz.title`, `ru.title` majburiy

## 5. Dokumentatsiya
- **Har** yangi Controller yoki endpoint uchun Swagger annotation **majburiy**
- Har o'zgartirish so'ng: `php artisan l5-swagger:generate`
- Barcha JSend status kodlari (200, 400, 401, 404, 500) Swagger-da ko'rsatilsin

## 6. Xavfsizlik
- `password` yoki `token` ni API javobida hech qachon plain text qaytarma
- CORS faqat loyiha admin panel domenidan so'rovlarga ruxsat bersin
- Shaxsiy ma'lumotlar so'rovlari: `auth:sanctum` middleware
