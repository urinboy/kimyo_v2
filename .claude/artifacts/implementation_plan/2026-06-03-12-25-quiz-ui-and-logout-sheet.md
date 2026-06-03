# Mobile UI & Admin Panel Dark Mode & Settings Tabs — Implementation Plan

**Sana:** 2026-06-03
**Status:** DRAFT (tasdiq kutmoqda)
**Slug:** `ui-ux-and-settings-tabs`

## Maqsad

Ushbu reja mobil ilova va admin panelidagi UI/UX dizayn yaxshilanishlarini hamda sozlamalar sahifasidagi description maydonlarini tabs ko'rinishiga o'tkazishni o'z ichiga oladi:
1. **Mobil (Flutter)**:
   - Kimyo testlari ro'yxatini to'liq bosiladigan premium kartaga o'tkazish (o'ngda chevron bilan).
   - Profil sahifasidagi "Chiqish" dialogini pastdan chiquvchi premium bottom sheet modalga o'tkazish.
2. **Admin Panel (React + Tailwind v4)**:
   - Tailwind v4 dagi class-based dark mode variantini yoqish.
   - Sarlavhalardagi o'qib bo'lmaydigan dark gradientlarni clean `text-app-primary` solid klasslariga moslab chiqish.
   - Sozlamalar sahifasidagi stacked ko'rinishidagi uchta til tavsifini (about_app_uz/ru/en) premium o'tish animatsiyasiga ega bo'lgan **Tabs (tillar) tizimiga** o'tkazish.

---

## Proposed Changes

### Component 1: Mobile App (Flutter)

#### [MODIFY] [quiz_list_page.dart](file:///d:/Buyurtmalar/kimyo_v2.5.20/mobile/lib/presentation/pages/quiz_list_page.dart)
- `_buildApiCard` va `_buildFallbackCard` dagi "Boshlash" tugmalari o'chirilib, kartaning butun yuzasi `InkWell` orqali bosiladigan qilinadi.
- Kartaning o'ng chetiga `Icons.chevron_right_rounded` belgisi qo'shiladi.

#### [NEW] [logout_confirm_bottom_sheet.dart](file:///d:/Buyurtmalar/kimyo_v2.5.20/mobile/lib/presentation/widgets/logout_confirm_bottom_sheet.dart)
- Standart dialog o'rniga pastdan chiquvchi premium bottom sheet:
  - Tepa qismida drag handle chizig'i.
  - Sarlavha va tasdiqlovchi savol matni.
  - Row ko'rinishidagi ikkita premium yumaloqlangan tugmalar ("Yo'q" / "Ha, chiqish").

#### [DELETE] [logout_confirm_dialog.dart](file:///d:/Buyurtmalar/kimyo_v2.5.20/mobile/lib/presentation/widgets/logout_confirm_dialog.dart)
- Eski dialog widget fayli o'chiriladi.

#### [MODIFY] [profile_page.dart](file:///d:/Buyurtmalar/kimyo_v2.5.20/mobile/lib/presentation/pages/profile_page.dart)
- Chiqish tugmasi bosilganda `showDialog` o'rniga `showModalBottomSheet` chaqirilib, yangi `LogoutConfirmBottomSheet` widgeti ko'rsatiladi.

---

### Component 2: Admin Panel (React 19 + TypeScript + Vite)

#### [MODIFY] [index.css](file:///d:/Buyurtmalar/kimyo_v2.5.20/backend/resources/js/index.css)
- Tailwind v4 class-based dark mode ishga tushishi uchun `@import "tailwindcss";` dan keyin `@custom-variant dark (&:where(.dark, .dark *));` qo'shiladi.

#### [MODIFY] [LabWorksPage.tsx](file:///d:/Buyurtmalar/kimyo_v2.5.20/backend/resources/js/pages/LabWorksPage.tsx)
- Sahifa `h1` sarlavhasi `text-4xl font-black tracking-tight text-app-primary` klassiga o'zgartiriladi.

#### [MODIFY] [VideosPage.tsx](file:///d:/Buyurtmalar/kimyo_v2.5.20/backend/resources/js/pages/videos/VideosPage.tsx)
- Sahifa `h1` sarlavhasi `text-4xl font-black tracking-tight text-app-primary` klassiga o'tkaziladi.

#### [MODIFY] [ProfilePage.tsx](file:///d:/Buyurtmalar/kimyo_v2.5.20/backend/resources/js/pages/ProfilePage.tsx)
- Profil sahifasidagi gradientli `h1` sarlavhasi ham `text-4xl font-black tracking-tight text-app-primary` ga o'zgartiriladi.

#### [MODIFY] [SettingsPage.tsx](file:///d:/Buyurtmalar/kimyo_v2.5.20/backend/resources/js/pages/SettingsPage.tsx)
- Ilova haqida (about_app) description tavsiflari uchun `aboutLang` state'i qo'shiladi.
- Vertikal joylashgan uchta til maydoni o'rniga dinamik `aboutLang` varianti asosida mos keladigan til tahrirlash maydonini (UZ / RU / EN) ko'rsatuvchi premium tabs panel chiziladi.

---

## Verification Plan

### Automated & Build Verification
1. **React Admin Build**: `npm run build` or `vite build` orqali TypeScript kompilyatsiyasi va admin panel assets buildini tekshirish.
2. **Flutter Mobile Build**: `flutter run -d chrome` orqali mobil kodni muvaffaqiyatli build qilish.

### Manual Verification
1. **Admin Panel Sozlamalari**:
   - Sozlamalar sahifasini ochish.
   - "Ilova haqida" bo'limida UZ, RU, EN tabs boshqaruv paneli chiroyli ko'rinishda ekanligini va har bir tab bosilganda faqat mos til textarea tavsifi ochilishini tekshirish.
