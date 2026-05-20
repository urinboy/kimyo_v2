---
name: React/Admin Coding Standards
description: Admin panel uchun kodlash standartlari va qoidalari.
---

# React / Admin Panel Coding Standards

## 1. Stack
- React 19 + Vite + TypeScript
- TailwindCSS 4
- Zustand (global state), TanStack React Query (server state)
- Ikonalar: **faqat** `lucide-react`

## 2. Premium Glassmorphism
```css
/* Glass card */
.glass-card {
  @apply bg-white/10 backdrop-blur-md border border-white/20 rounded-3xl shadow-2xl;
}
```
- Corners: `rounded-2xl` yoki `rounded-3xl`
- Blur: `backdrop-blur-md` va yuqori
- Border: `border border-white/20`
- Dark mode asosiy: to'q fon

## 3. Rang Palitasi
| Nom | Hex |
|-----|-----|
| Primary Purple | `#A855F7` |
| Primary Green | `#10B981` |

## 4. Komponent Struktura
- Komponentlar kichik va qayta ishlatiluvchi (Atomic Design)
- Props: **har doim** TypeScript interface
- API so'rovlar: `src/api/` da alohida modul (har resurs uchun)

## 5. i18n
- Barcha UI matnlar `i18next` translation key orqali — hardcode qilma

## 6. MAJBURIY QOIDA
Admin panelda **har qanday** o'zgarishdan keyin:
```bash
npm run build
```
Build output `../api/public` ga tushadi va API orqali serve bo'ladi.
