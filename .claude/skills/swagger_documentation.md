---
name: Swagger Documentation
description: Laravel l5-swagger orqali API dokumentatsiyasi yozish ko'rsatmalari.
---

# Swagger Dokumentatsiyasi

## O'rnatish
```bash
composer require "darkaonline/l5-swagger"
php artisan vendor:publish --provider="L5Swagger\L5SwaggerServiceProvider"
```

## Annotation Namunasi (Har Endpoint Uchun Minimal)
```php
/**
 * @OA\Get(
 *     path="/api/v1/elements",
 *     summary="Elementlar ro'yxati",
 *     tags={"Elements"},
 *     security={{"sanctum":{}}},
 *     @OA\Response(
 *         response=200,
 *         description="Muvaffaqiyatli",
 *         @OA\JsonContent(
 *             @OA\Property(property="status", type="string", example="success"),
 *             @OA\Property(property="data", type="object")
 *         )
 *     ),
 *     @OA\Response(response=401, description="Autentifikatsiya talab qilinadi"),
 *     @OA\Response(response=500, description="Server xatosi")
 * )
 */
```

## Komandalar
```bash
php artisan l5-swagger:generate          # Dokumentatsiyani yangilash
php artisan l5-swagger:generate --all    # Keshni tozalab yangilash
```

## Qoidalar
- **Har** yangi Controller yoki endpoint — Swagger annotation **majburiy**
- Barcha JSend status kodlari (200, 400, 401, 404, 500) to'liq tavsiflash
- Sanctum/Bearer Token auth konfiguratsiya qilinsin
- Annotationlar Controller metodlari **ustida** yoziladi
