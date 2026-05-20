---
name: Premium Glassmorphism UI
description: React va Flutter-da birxil vizual stil — glass effektlari, ranglar va komponentlar.
---

# Premium Glassmorphism UI

## Dizayn Tokenlar

| Token | Qiymat |
|-------|--------|
| Primary Purple | `#A855F7` |
| Primary Green | `#10B981` |
| Glass White | `rgba(255,255,255,0.1)` |
| Glass Border | `rgba(255,255,255,0.2)` |
| Backdrop Blur | 8px – 16px |
| Border Radius | 16px – 24px |
| Shadow | `shadow-2xl` (yumshoq, chuqur) |
| Typography | Inter yoki Outfit |

## Tailwind CSS 4 (React)
```css
.glass-card {
  @apply bg-white/10 backdrop-blur-md border border-white/20 rounded-3xl shadow-2xl;
}
```

## Flutter
```dart
ClipRRect(
  borderRadius: BorderRadius.circular(24),
  child: BackdropFilter(
    filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
    child: Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
      ),
      child: child,
    ),
  ),
)
```

## Qoidalar
- Kichik ekranlarda blur 20% kamaytirish (performance)
- Har doim dark fon ustida glass effekt ishlating
- Hover/active state-larda opacity o'zgartirish (`bg-white/20` → `bg-white/30`)
