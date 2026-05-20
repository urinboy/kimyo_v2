---
name: Repository Pattern
description: Laravel da Repository Pattern implement qilish — interface, implementation, DI binding.
---

# Repository Pattern

## Laravel Tuzilishi

### 1. Interface
`app/Repositories/Interfaces/ElementRepositoryInterface.php`
```php
interface ElementRepositoryInterface {
    public function all(string $lang): Collection;
    public function find(int $id, string $lang): ?Element;
    public function create(array $data): Element;
    public function update(int $id, array $data): Element;
    public function delete(int $id): bool;
}
```

### 2. Implementation
`app/Repositories/Eloquent/ElementRepository.php`
```php
class ElementRepository implements ElementRepositoryInterface {
    // Eloquent orqali implement
}
```

### 3. Binding (`AppServiceProvider`)
```php
$this->app->bind(ElementRepositoryInterface::class, ElementRepository::class);
```

### 4. Controller
```php
public function __construct(private ElementRepositoryInterface $repo) {}
```

## Flutter (Clean Architecture)
```
domain/repositories/element_repository.dart      // Abstract class
data/repositories/element_repository_impl.dart   // Implementation
```

## Qoidalar
- Controller-lar Model bilan **to'g'ridan-to'g'ri** ishlamaydi
- Barcha Repository metodlari type-safe bo'lishi shart
