# Backend — ishlab chiqarishga joylash (deploy)

Web server **document root** kalitlari ichidagi `public/` papkasi bo‘lishi kerak (Laravel ildizi emas).

## Talablar

| Komponent | Minimal |
|-----------|---------|
| PHP | 8.3+ (`ext`: bcmath, ctype, curl, fileinfo, json, mbstring, openssl, pdo_mysql yoki pdo_pgsql, tokenizer, xml) |
| Composer | 2.x |
| Node.js | LTS (faqat serverda `npm run build` qilisangiz; tayyor build boshqa joyda bo‘lsa kerak emas) |
| Ma’lumotlar bazasi | MySQL 8 / PostgreSQL (prod da SQLite tavsiya etilmaydi) |

## Bir martalik sozlash

1. Repozitoriyni serverga chiqaring; ish papkasi masalan `/var/www/kimyo-backend`.
2. `.env` ni yarating: `.env.example` dan nusxa; `APP_KEY` uchun `php artisan key:generate --show` yoki `--force`.
3. Ishlab chiqarish qiymatlari:
   - `APP_ENV=production`
   - `APP_DEBUG=false`
   - `APP_URL=https://sizning-domen.uz`
   - `LOG_LEVEL=error` (ixtiyoriy)
   - `MOBILE_API_KEY` — `openssl rand -hex 32` bilan yangi kalit
   - `DB_*` — prod bazasi
4. Huquqlar:
   ```bash
   chmod -R ug+rwx storage bootstrap/cache
   ```
5. Statik havola:
   ```bash
   php artisan storage:link
   ```
6. Frontend assetlar (admin panel build `public/` ga yoziladi):
   ```bash
   composer install --no-dev --optimize-autoloader --no-interaction
   npm ci
   npm run build
   ```
   **Muhim:** `vite`, `typescript`, `tailwindcss` **devDependencies** da — `npm ci --omit=dev` bilan build **ishlamaydi** (`tsc` / `vite` topilmaydi). Builddan keyin diskni tejash uchun ixtiyoriy: `npm prune --omit=dev`.

   **Windows da `EPERM` ... unlink `tailwindcss-oxide.*.node`:** odatda bir nechta `node.exe` (Vite, boshqa terminal) `.node` faylni ushlab turadi. Boshqa terminalda `npm run dev` ni to‘xtating, keyin:
   ```powershell
   taskkill /F /IM node.exe
   ```
   Agar `Remove-Item node_modules` yoki `npm ci` baribir `EPERM` bersa — **`node_modules` ni o‘chirish o‘rniga qayta nomlash** ko‘pincha ishlaydi, so‘ng yangi qovluqqa `npm ci`:
   ```powershell
   cd D:\...\backend
   ren node_modules node_modules_old
   npm ci
   npm run build
   ```
   Yoki yordamchi skript: `powershell -ExecutionPolicy Bypass -File scripts/repair-node-modules.ps1`. Eski `node_modules_old*` papkasi qulflashgan bo‘lsa, kompyuterni qayta yuklagach qo‘lda o‘chiring.

## Har bir release (yangilanish)

Quyidagi tartib — kod yangilangandan keyin:

```bash
composer install --no-dev --optimize-autoloader --no-interaction
npm ci && npm run build
composer run deploy:release
```

Yoki qadam-baqadam:

```bash
php artisan optimize:clear
php artisan migrate --force
php artisan config:cache
php artisan view:cache
php artisan event:cache
php artisan l5-swagger:generate
```

### `route:cache` haqida

`routes/web.php` da closure marshrutlar bor bo‘lishi mumkin. Laravel bunday holatda **`php artisan route:cache` ishlamaydi** yoki xato beradi — shuning uchun bu loyiha uchun route cache **ishlatilmaydi**. `config`, `view`, `event` cache yetarli.

## Cron va navbatlar

- **Scheduler** (`app/Console/Kernel.php` dagi jadval): server crontab ga qo‘shing:

  ```cron
  * * * * * cd /var/www/kimyo-backend && php artisan schedule:run >> /dev/null 2>&1
  ```

- **Queue worker** (agar ishlatilsa): `php artisan queue:work` ni systemd yoki Supervisor bilan doimiy ishga tushiring.

## Sanctum va SPA

Admin panel boshqa domen/subdomen orqali cookie bilan ishlayotgan bo‘lsa, `.env` da:

```env
SANCTUM_STATEFUL_DOMAINS=admin.example.com,localhost
SESSION_DOMAIN=.example.com
```

Mobil ilova faqat `Authorization: Bearer` + `X-API-Key` bilan ishlayotgan bo‘lsa, ko‘pincha faqat `APP_URL` va HTTPS yetarli.

## Tekshiruv ro‘yxati

- [ ] `public/` document root
- [ ] `APP_DEBUG=false`, `APP_ENV=production`
- [ ] `MOBILE_API_KEY` prod qiymati
- [ ] Migratsiya: `migrate --force`
- [ ] `storage:link`
- [ ] `storage/`, `bootstrap/cache/` yozuv huquqi
- [ ] Build: `npm run build` (yoki CI artefakti)
- [ ] Swagger: `l5-swagger:generate` (API docs yangilangan bo‘lsa)
- [ ] HTTPS va `APP_URL` mosligi

## Skript

Ma’lum bir Linux server uchun ketma-ket buyruqlar: `scripts/deploy-release.sh`.
