import 'package:flutter/foundation.dart' show kIsWeb;

/// API `image_url` ko‘pincha `APP_URL` (boshqa port/host) bilan keladi; mobil/web esa
/// `API_BASE_URL` (`…/api/v1`) orqali ulanadi. Rasmni serverning haqiqiy originidan yuklash.
///
/// `/storage/...` statik fayl local `php artisan serve` muhitida CORS yoki symlink
/// sababli 403 qaytarishi mumkin. Shu sababli public disk fayllari barcha
/// platformalarda Laravel API proksi marshrutiga yo‘naltiriladi.
String resolveApiStorageFileUrl(String apiV1Base, String? raw) {
  if (raw == null || raw.trim().isEmpty) return '';
  final t = raw.trim();
  final base = Uri.parse(apiV1Base);
  final origin = Uri(
    scheme: base.scheme,
    host: base.host,
    port: base.hasPort ? base.port : null,
  );

  late final String path;
  late final String? query;
  if (t.startsWith('http://') || t.startsWith('https://')) {
    final u = Uri.parse(t);
    path = u.path;
    query = u.hasQuery ? u.query : null;
  } else {
    path = t.startsWith('/') ? t : '/$t';
    query = null;
  }

  final mapped =
      kIsWeb ? _mapStoragePathForWebCors(path) : _mapStoragePathForNative(path);

  return Uri(
    scheme: origin.scheme,
    host: origin.host,
    port: origin.port,
    path: mapped,
    query: query,
  ).toString();
}

String _mapStoragePathForNative(String path) {
  if (path.startsWith('/api/v1/public-storage/')) {
    return path;
  }
  const legacy = '/storage/';
  if (path.startsWith(legacy)) {
    return '/api/v1/public-storage/${path.substring(legacy.length)}';
  }
  final idx = path.indexOf(legacy);
  if (idx >= 0) {
    return '/api/v1/public-storage/${path.substring(idx + legacy.length)}';
  }
  return path.startsWith('/') ? path : '/$path';
}

String _mapStoragePathForWebCors(String path) {
  if (path.startsWith('/api/v1/public-storage/')) {
    return path;
  }
  const legacy = '/storage/';
  if (path.startsWith(legacy)) {
    return '/api/v1/public-storage/${path.substring(legacy.length)}';
  }
  final idx = path.indexOf(legacy);
  if (idx >= 0) {
    return '/api/v1/public-storage/${path.substring(idx + legacy.length)}';
  }
  return path;
}
