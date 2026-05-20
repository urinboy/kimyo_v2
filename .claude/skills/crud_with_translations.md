---
name: CRUD with Translations
description: Ko'p tilli ma'lumotlar uchun Laravel da translations pattern asosida CRUD yaratish.
---

# Ko'p Tilli CRUD (Translations Pattern)

## Database Tuzilishi

```sql
-- Asosiy jadval
CREATE TABLE elements (
  id BIGINT PRIMARY KEY AUTO_INCREMENT,
  status BOOLEAN DEFAULT TRUE,
  created_at TIMESTAMP,
  updated_at TIMESTAMP
);

-- Tarjima jadval
CREATE TABLE element_translations (
  id BIGINT PRIMARY KEY AUTO_INCREMENT,
  element_id BIGINT REFERENCES elements(id) ON DELETE CASCADE,
  language_id BIGINT REFERENCES languages(id) ON DELETE CASCADE,
  title VARCHAR(255) NOT NULL,
  description TEXT
);
```

## Validation
```php
'uz.title' => 'required|string|max:255',
'ru.title' => 'required|string|max:255',
```

## API So'rovlar
- Joriy til: `GET /api/v1/elements` (header yoki query param `?lang=uz`)
- Barcha tillar: `GET /api/v1/elements?all_translations=true`

## Qoidalar
- FK-larda `onDelete('cascade')` **shart**
- Eager loading: `with('translations')` yoki `with('translation')` (filter by language)
- Response-da faqat tegishli tilni qaytarish (default: so'rov tili)
