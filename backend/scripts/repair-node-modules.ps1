# Windows: npm ci EPERM (tailwindcss-oxide *.node qulflashgan) yoki buzilgan node_modules.
# Vite / boshqa terminaldagi `npm run dev` ni avval to'xtating.

$ErrorActionPreference = 'Stop'
$Root = Split-Path $PSScriptRoot -Parent
Set-Location $Root

Get-Process node -ErrorAction SilentlyContinue | Stop-Process -Force -ErrorAction SilentlyContinue
Start-Sleep -Seconds 2

if (Test-Path node_modules) {
    $bak = 'node_modules_old_{0:yyyyMMdd_HHmmss}' -f (Get-Date)
    try {
        Rename-Item -Path node_modules -NewName $bak
        Write-Host "OK: node_modules -> $bak (keyinroq PC restartidan keyin bu papkani qo'lda o'chiring agar qolgan bo'lsa)."
    }
    catch {
        Write-Error "node_modules ni qayta nomlab bo'lmadi (hali ham qulflashgan). Cursor ni yoping yoki Defender dan papkani istisno qiling, keyin qayta urinib ko'ring: $_"
        exit 1
    }
}

npm ci
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }

npm run build
exit $LASTEXITCODE
