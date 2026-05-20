/// API yoki DB ba'zan `boolean` o'rniga `0`/`1` (int) yuboradi — Dart `as bool` xato beradi.
bool jsonBool(dynamic value, {bool fallback = false}) {
  if (value == null) return fallback;
  if (value is bool) return value;
  if (value is int) return value != 0;
  if (value is num) return value != 0;
  if (value is String) {
    final s = value.trim().toLowerCase();
    return s == '1' || s == 'true' || s == 'yes' || s == 'on';
  }
  return fallback;
}

/// `null` — maydon yo'q; aks holda [jsonBool] qoidasi.
bool? jsonBoolOrNull(dynamic value) {
  if (value == null) return null;
  if (value is bool) return value;
  if (value is int) return value != 0;
  if (value is num) return value != 0;
  if (value is String) {
    final s = value.trim().toLowerCase();
    if (s.isEmpty) return null;
    if (s == '1' || s == 'true' || s == 'yes' || s == 'on') return true;
    if (s == '0' || s == 'false' || s == 'no' || s == 'off') return false;
    return null;
  }
  return null;
}
