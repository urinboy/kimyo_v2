---
name: JSend API Standard
description: Barcha API response-larni JSend formatida yozish uchun ko'rsatmalar.
---

# JSend API Standarti

## Response Formatlari

### Success (200, 201)
```json
{
  "status": "success",
  "data": {
    "item": { "id": 1, "name": "Element" }
  }
}
```

### Fail — Validation (400, 422)
```json
{
  "status": "fail",
  "data": {
    "title": "Sarlavha kiritilishi shart",
    "email": "Email noto'g'ri formatda"
  }
}
```

### Error — Server (500)
```json
{
  "status": "error",
  "message": "Database ulanishda xato yuz berdi"
}
```

## Laravel Controller Namunasi
```php
// Success
return response()->json(['status' => 'success', 'data' => $data]);

// Fail
return response()->json(['status' => 'fail', 'data' => $errors], 400);

// Error
return response()->json(['status' => 'error', 'message' => 'Server xatosi'], 500);
```

## Swagger Sxemalari (Global)
- `JSuccess`: status="success", data=object
- `JFail`: status="fail", data=object (validation xatolari)
- `JError`: status="error", message=string
