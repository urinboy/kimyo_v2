# Video Section UI/UX Enhancements — Implementation Plan

**Sana:** 2026-06-03
**Status:** DRAFT (tasdiq kutmoqda)
**Slug:** `video-ui-ux-enhancements`

## Maqsad

Ilovadagi **Videolar** bo'limining foydalanuvchi interfeysi va tajribasini (UI/UX) yanada jozibador, qulay va umumiy kimyo ta'lim platformasi uslubiga mos holatga keltirish. Shuningdek, ushbu o'zgarishlar haqida Claude Code tizimini xabardor qilish.

---

## Proposed Changes

### Mobile (Flutter)

#### [MODIFY] [videos_page.dart](file:///D:/Buyurtmalar/kimyo_v2.5.20/mobile/lib/presentation/pages/videos_page.dart)
- **Ro'yxat dizaynini yaxshilash**: To'liq ekran kengligidagi sodda YouTube-style kartalarni chekka paddingga ega bo'lgan yumaloq va soya effektli premium kartalarga almashtirish (`margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8)`).
- **Yumaloq burchakli Thumbnail**: Rasmning yuqori qismini yumaloqlash (`BorderRadius.vertical(top: Radius.circular(24))`).
- **Play tugmasi**: Play tugmasini yarim shaffof frosted glass (xiralashgan oyna) ko'rinishidagi aylana va oq belgi bilan dizayn qilish.
- **Yangi element: Source Badge (Manba nishoni)**: Har bir kartaning tepa-chap qismida video manbasi (YouTube yoki Server) nishonini ko'rsatish.
- **Typography & Spacing**: Matnlar o'rtasidagi masofalarni va ranglarni AppColors tizimiga muvofiqlashtirish.

#### [MODIFY] [video_detail_page.dart](file:///D:/Buyurtmalar/kimyo_v2.5.20/mobile/lib/presentation/pages/video_detail_page.dart)
- **Details sahifasi integratsiyasi**:
  - Soddalashtirilgan va zerikarli ma'lumotlar strukturasini premium karta ko'rinishidagi ma'lumotlar blokiga o'tkazish.
  - Kanal avatari va tugmalarni yagona horizontal chiziqda, yanada zamonaviyroq outlined/filled uslubda joylashtirish.
- **Manba chiplari (Source Badges)**: YouTube va Server belgilari uchun soft-colored gradientlar qo'shish.
- **Tavsif bloki (Description)**: "Kimyoviy Tavsif / Darslik haqida" sarlavhasi ostida shaffof glassmorphism kontener ichida va yoyish (`show_more`) funksiyasi bilan vizual jihatdan boyitilgan tavsif matnini ko'rsatish.

---

## Verification Plan

### Automated/Local Tests
1. **Loyiha builds**: `flutter run -d chrome` yoki mobil emulator orqali ilovani xatolarsiz ishga tushirish.

### Manual Verification
1. Ilovada **Videolar** menyusiga kirib, yangilangan premium video kartalar ro'yxatini va hover/bosing effektlarini tahlil qilish.
2. Istalgan video ustiga bosib, ichki sahifada player, sarlavha, manbalar, avtoring ma'lumotlari hamda tavsif maydonining dizayni toza va premium ekanligini tasdiqlash.
