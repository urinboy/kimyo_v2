---
name: Flutter Coding Standards
description: Mobile ilova uchun kodlash standartlari va qoidalari.
---

# Flutter Coding Standards

## 1. Arxitektura — Clean Architecture
- **Domain:** Entities, repository interfaces, use cases
- **Data:** Datasources, JSON models (`json_serializable`), repo implementations
- **Presentation:** BLoC, pages, widgets

## 2. State Management — BLoC
- `flutter_bloc` kutubxonasi
- Events: Foydalanuvchi harakatlarini ifodalaydi (`LoadElements`, `NextQuestion`)
- States: Ma'lumot holatini ifodalaydi (`Loading`, `Loaded`, `Error`)
- States **immutable** (`final`) bo'lishi shart
- UI qatlamida `setState` **hech qachon** ishlatilmaydi

## 3. UI — Premium Glassmorphism
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
- Kichik ekranlarda blur-ni 20% kamaytirish (performance)

## 4. Responsive
- `LayoutBuilder` yoki `MediaQuery` ishlatish
- Piksellarni hardcode qilma

## 5. Kutubxonalar
| Vazifa | Kutubxona |
|--------|-----------|
| HTTP | `dio` |
| Serialization | `json_serializable` |
| DI | `get_it` |
| State | `flutter_bloc` |
| Localization | `flutter_localizations` + `intl` |

## 6. Ko'p Tillilik
- Tillar: O'zbek (asosiy), Rus, Ingliz
- `LocaleService` singleton — `SharedPreferences` da saqlash
