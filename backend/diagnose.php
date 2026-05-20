<?php
/**
 * Laravel Hosting Diagnostic Script
 * Place this in your Laravel root directory and access it via browser: yourdomain.com/diagnose.php
 */

define('LARAVEL_START', microtime(true));

$results = [];

// 1. Check PHP Version
$results['PHP Version'] = PHP_VERSION;
if (version_compare(PHP_VERSION, '8.2.0', '<')) {
    $results['PHP Version Status'] = '❌ Error: Laravel 11 requires PHP 8.2 or higher.';
} else {
    $results['PHP Version Status'] = '✅ OK';
}

// 2. Check Extensions
$extensions = ['bcmath', 'ctype', 'fileinfo', 'json', 'mbstring', 'openssl', 'pcre', 'pdo', 'tokenizer', 'xml', 'pdo_mysql'];
foreach ($extensions as $ext) {
    $results["Extension: $ext"] = extension_loaded($ext) ? '✅ Loaded' : '❌ Missing';
}

// 3. Check Writable Directories
$dirs = ['storage', 'storage/logs', 'storage/framework', 'bootstrap/cache'];
foreach ($dirs as $dir) {
    $path = __DIR__ . '/' . $dir;
    if (is_dir($path)) {
        $results["Directory: $dir"] = is_writable($path) ? '✅ Writable' : '❌ Not Writable (Run chmod -R 775 ' . $dir . ')';
    } else {
        $results["Directory: $dir"] = '❌ Missing';
    }
}

// 4. Check .env file
if (file_exists(__DIR__ . '/.env')) {
    $results['.env File'] = '✅ Exists';
    $env = parse_ini_file(__DIR__ . '/.env');
    $results['APP_DEBUG'] = isset($env['APP_DEBUG']) ? $env['APP_DEBUG'] : 'Not set';
    $results['DB_CONNECTION'] = isset($env['DB_CONNECTION']) ? $env['DB_CONNECTION'] : 'Not set';
} else {
    $results['.env File'] = '❌ Missing';
}

// 5. Test DB Connection
try {
    if (isset($env)) {
        $dsn = "mysql:host={$env['DB_HOST']};port={$env['DB_PORT']};dbname={$env['DB_DATABASE']}";
        $pdo = new PDO($dsn, $env['DB_USERNAME'], $env['DB_PASSWORD'], [PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION]);
        $results['Database Connection'] = '✅ Connected Successfully';
    }
} catch (Exception $e) {
    $results['Database Connection'] = '❌ Failed: ' . $e->getMessage();
}

// 6. Check Vendor
if (is_dir(__DIR__ . '/vendor') && file_exists(__DIR__ . '/vendor/autoload.php')) {
    $results['Vendor Folder'] = '✅ OK';
} else {
    $results['Vendor Folder'] = '❌ Missing or incomplete (Run composer install)';
}

echo "<h1>Laravel Diagnostic Results</h1><pre>";
foreach ($results as $key => $value) {
    echo str_pad($key, 30) . ": $value\n";
}
echo "</pre>";
