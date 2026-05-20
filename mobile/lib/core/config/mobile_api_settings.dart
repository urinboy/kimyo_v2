import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// Mobil ilova API ulanishi: kalit va base URL.
///
/// Laravel backend loyiha ildizi: repozitoriyadagi `backend/` ( `/api/v1` ).
///
/// **Ustunlik tartibi**
/// 1) build vaqtida: `flutter run --dart-define=MOBILE_API_KEY=... --dart-define=API_BASE_URL=...`
/// 2) yoki `flutter run --dart-define-from-file=mobile_api_defines.json`
/// 3) aks holda `assets/env/mobile_api.env` (masalan production: `API_BASE_URL=https://kimyo.itorda.uz/api/v1`)
///
/// Kalit **backend/.env** dagi `MOBILE_API_KEY` bilan bir xil bo‘lishi kerak.
class MobileApiSettings {
  MobileApiSettings._();

  static bool _loaded = false;
  static String _envFileKey = '';
  static String _envFileBase = '';

  /// `assets/env/mobile_api.env` ni o‘qing (main da di.init dan oldin).
  static Future<void> loadFromAssets() async {
    if (_loaded) return;
    _loaded = true;
    try {
      final raw = await rootBundle.loadString('assets/env/mobile_api.env');
      final map = _parseEnv(raw);
      _envFileKey = map['MOBILE_API_KEY'] ?? '';
      _envFileBase = map['API_BASE_URL'] ?? '';
    } on Object catch (_) {
      // Fayl yo‘q yoki noto‘g‘ri — compile-time define ishlatiladi.
    }
  }

  static Map<String, String> _parseEnv(String raw) {
    final out = <String, String>{};
    const ls = LineSplitter();
    for (final line in ls.convert(raw)) {
      var t = line.trimRight();
      if (t.isEmpty) continue;
      if (t.startsWith('#')) continue;
      final hash = t.indexOf('#');
      if (hash > 0) {
        t = t.substring(0, hash).trimRight();
      }
      final eq = t.indexOf('=');
      if (eq <= 0) continue;
      final k = t.substring(0, eq).trim();
      var v = t.substring(eq + 1).trim();
      if ((v.startsWith('"') && v.endsWith('"')) || (v.startsWith("'") && v.endsWith("'"))) {
        v = v.substring(1, v.length - 1);
      }
      if (k.isNotEmpty) out[k] = v;
    }
    return out;
  }

  static String get apiKey {
    final fromDefine = const String.fromEnvironment('MOBILE_API_KEY', defaultValue: '');
    if (fromDefine.isNotEmpty) return fromDefine;
    return _envFileKey.trim();
  }

  /// Bo‘sh bo‘lsa — DioClient ichidagi standart (web / emulyator) mantiq ishlatiladi.
  static String get baseUrlOverride {
    final fromDefine = const String.fromEnvironment('API_BASE_URL', defaultValue: '');
    if (fromDefine.isNotEmpty) return fromDefine.trim();
    return _envFileBase.trim();
  }

  static void logMisconfigHint() {
    if (apiKey.isEmpty && kDebugMode) {
      debugPrint(
        'Kimyo API: MOBILE_API_KEY bo‘sh. assets/env/mobile_api.env ni to‘ldiring yoki '
        '--dart-define=MOBILE_API_KEY=... qo‘shing (backend/.env dagi MOBILE_API_KEY bilan bir xil).',
      );
    }
  }
}
