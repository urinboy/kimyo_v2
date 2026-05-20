#!/usr/bin/env bash
# Ishlab chiqarish serverida yangi release ni joylash (backend ildizidan ishlaydi).
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

echo "==> composer install --no-dev"
composer install --no-dev --optimize-autoloader --no-interaction

if command -v npm >/dev/null 2>&1; then
  echo "==> npm ci && npm run build (devDependencies kerak: vite, typescript, tailwind)"
  npm ci
  npm run build
else
  echo "!!! npm topilmadi — assetlarni boshqa joyda build qilgan bo'lsangiz, bu qadamni o'tkazib yuboring."
fi

echo "==> storage:link (mavjud bo'lsa xatosiz)"
php artisan storage:link || true

echo "==> deploy:release (migrate + cache + swagger)"
composer run deploy:release

echo "==> tayyor."
