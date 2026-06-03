# 3D Mobile Viewer UX & Visibility Fix — Implementation Plan

**Sana:** 2026-06-03
**Status:** DRAFT (tasdiq kutmoqda)
**Slug:** `3d-viewer-ux-and-cors-fix`

## Maqsad

Foydalanuvchi interfeysini yanada qulaylashtirish maqsadida Flutter mobil ilovasidagi 3D modellar ro'yxati dizaynini **ikki ustundan bitta ustunga** o'tkazish. Shuningdek, 3D model tafsilotlari (detail) sahifasini yanada premium qilish va veb (Chrome) platformasida CORS sababli **ko'rinmayotgan 3D model renderini tiklash**.

---

## User Review Required

> [!IMPORTANT]
> - **CORS Muammosi yechimi**: 3D GLB fayllari to'g'ridan-to'g'ri `/storage` papkasidan yuklanganda brauzer (CORS) tomonidan bloklanadi. Buni hal qilish uchun loyihada mavjud bo'lgan `/api/v1/public-storage/{path}` marshrutidan foydalanib, fayllarni Laravel orqali proxy qilib uzatamiz.
> - **Veb skript**: Veb brauzerda 3D render ishlashi uchun `mobile/web/index.html` fayliga Google `<model-viewer>` kutubxonasi skripti qo'shiladi.

---

## Proposed Changes

### 1. Backend

#### [MODIFY] [ThreeDModelApiFormatter.php](file:///D:/Buyurtmalar/kimyo_v2.5.20/backend/app/Support/ThreeDModelApiFormatter.php)
- `resolveModelUrl` metodida to'g'ridan-to'g'ri storage URL o'rniga API orqali chiquvchi `api/v1/public-storage/3d-models/...` URL manzilini qaytarish:
  ```php
  private static function resolveModelUrl(ThreeDModel $model): ?string
  {
      if (! $model->model_path) {
          return null;
      }
      return Storage::disk('public')->exists($model->model_path)
          ? url('api/v1/public-storage/' . $model->model_path)
          : null;
  }
  ```

#### [MODIFY] [InterestingTaskController.php](file:///D:/Buyurtmalar/kimyo_v2.5.20/backend/app/Http/Controllers/Api/InterestingTaskController.php)
- `publicStorageFile` metodi javobiga aniq CORS sarlavhalarini (Headers) qo'shish, shu orqali Flutter Web yuklayotgan GLB/GLTF fayllar brauzerda bloklanishini oldini olish:
  ```php
  return response()->file($real, [
      'Content-Type' => $mime,
      'Cache-Control' => 'public, max-age=86400',
      'Access-Control-Allow-Origin' => '*',
      'Access-Control-Allow-Methods' => 'GET, OPTIONS',
      'Access-Control-Allow-Headers' => '*',
  ]);
  ```

### 2. Mobile (Flutter)

#### [MODIFY] [index.html](file:///D:/Buyurtmalar/kimyo_v2.5.20/mobile/web/index.html)
- `<head>` qismiga `<model-viewer>` skriptini qo'shish (chunki `model_viewer_plus` kutubxonasi veb platforma uchun ushbu skriptga bog'liq):
  ```html
  <!-- ModelViewer (model_viewer_plus web uchun) -->
  <script type="module" src="https://ajax.googleapis.com/ajax/libs/model-viewer/3.1.1/model-viewer.min.js"></script>
  ```

#### [MODIFY] [three_d_models_page.dart](file:///D:/Buyurtmalar/kimyo_v2.5.20/mobile/lib/presentation/pages/three_d_models_page.dart)
- `GridView` (2 ustun) elementini `ListView.builder` (1 ustun) elementiga almashtirish.
- Har bir mineral kartasini (`_ModelCard`) gorizontal ko'rinishga keltirish (Chapda chiroyli 3D ikonka, o'ngda mineral nomi, element belgisi va 2 qatorli qisqa tavsif, eng o'ngda ochish belgisi `chevron_right`).
- Glassmorphism va visual shadow effektlarini kuchaytirish.

#### [MODIFY] [three_d_model_detail_page.dart](file:///D:/Buyurtmalar/kimyo_v2.5.20/mobile/lib/presentation/pages/three_d_model_detail_page.dart)
- 3D Model Viewer maydonini kengaytirish (taller aspect ratio yoki balandlik: 320px).
- Viewer atrofiga shaffof premium chegara (border) va soya effektlarini qo'shish.
- Foydalanuvchiga yordamchi matn ko'rsatish: *"Modelni aylantirish uchun buring · Kattalashtirish uchun chimdilang"*.
- Pastki qismdagi ma'lumotlar blokini yanada toza va tartibli joylashtirish (nomi, element belgisi, tavsif matni).

---

## Verification Plan

### Automated/Local Tests
1. **Loyiha builds**: `flutter run -d chrome` orqali Chrome-da xatolarsiz ishga tushishini tekshirish.
2. **API endpoint**: `http://localhost:8089/api/v1/3d-models` so'rovi orqali `model_url` qiymati `http://localhost:8089/api/v1/public-storage/3d-models/...` formatida kelayotganligini tekshirish.

### Manual Verification
1. Ilovada **3D Modellar** sahifasiga kirib, 1 ustunli ro'yxatni tekshirish.
2. Istalgan mineral ustiga bosib, ichki sahifada 3D model to'liq ko'rinayotganligini va aylantirib bo'layotganligini tekshirish.
