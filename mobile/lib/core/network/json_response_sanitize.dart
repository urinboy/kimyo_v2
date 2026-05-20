import 'dart:convert';

/// Raw JSON matnini [jsonDecode] oldidan tozalash.
///
/// **Eslatma:** Dart `switch` da `break` bo‘lmasa, keyingi `case`lar ham bajariladi
/// (implicit fall-through). Shuning uchun nazorat belgilari branchida `switch`
/// ishlatilmaydi — bitta `\t` uchun `\b\t\n\f\r\u0009` yozilmasligi kerak.
class JsonResponseSanitize {
  JsonResponseSanitize._();

  /// JSON string ichidagi literal nazorat belgilari va yaroqsiz `\` escape-lar.
  static String forJsonDecode(String raw) {
    if (raw.isEmpty) return raw;

    final buf = StringBuffer();
    var inString = false;
    var escaped = false;
    var i = 0;

    while (i < raw.length) {
      final ch = raw[i];
      final code = ch.codeUnitAt(0);

      if (!inString) {
        buf.write(ch);
        if (ch == '"') inString = true;
        i++;
      } else if (escaped) {
        if ('"\\/bfnrt'.contains(ch)) {
          buf.write('\\');
          buf.write(ch);
        } else if (ch == 'u') {
          final rest = (i + 4 < raw.length) ? raw.substring(i + 1, i + 5) : '';
          if (rest.length == 4 &&
              _isHex(rest[0]) &&
              _isHex(rest[1]) &&
              _isHex(rest[2]) &&
              _isHex(rest[3])) {
            buf.write('\\u');
            buf.write(rest);
            i += 4;
          } else {
            buf.write('\\\\u');
          }
        } else {
          buf.write('\\\\');
          buf.write(ch);
        }
        escaped = false;
        i++;
      } else {
        if (ch == '"') {
          buf.write('"');
          inString = false;
          i++;
        } else if (ch == '\\') {
          escaped = true;
          i++;
        } else if (code < 0x20) {
          if (code == 0x08) {
            buf.write(r'\b');
          } else if (code == 0x09) {
            buf.write(r'\t');
          } else if (code == 0x0A) {
            buf.write(r'\n');
          } else if (code == 0x0C) {
            buf.write(r'\f');
          } else if (code == 0x0D) {
            buf.write(r'\r');
          } else {
            buf.write('\\u${code.toRadixString(16).padLeft(4, '0')}');
          }
          i++;
        } else {
          buf.write(ch);
          i++;
        }
      }
    }

    // Input `\` bilan tugagan bo‘lsa (string ichida to‘liq escape yo‘q)
    if (escaped) {
      buf.write('\\\\');
    }

    return buf.toString();
  }

  static bool _isHex(String c) {
    final code = c.codeUnitAt(0);
    return (code >= 0x30 && code <= 0x39) ||
        (code >= 0x41 && code <= 0x46) ||
        (code >= 0x61 && code <= 0x66);
  }

  /// Birinchi to‘liq JSON obyektini ajratadi (oldingi matn yoki ortda qo‘shimcha bo‘lsa).
  static String? extractBalancedJsonObject(String s) {
    var start = s.indexOf('{"status"');
    if (start < 0) start = s.indexOf('{');
    if (start < 0) return null;
    var depth = 0;
    var inStr = false;
    var esc = false;
    for (var i = start; i < s.length; i++) {
      final ch = s[i];
      if (inStr) {
        if (esc) {
          esc = false;
          continue;
        }
        if (ch == '\\') {
          esc = true;
          continue;
        }
        if (ch == '"') inStr = false;
        continue;
      }
      if (ch == '"') {
        inStr = true;
        continue;
      }
      if (ch == '{') {
        depth++;
      } else if (ch == '}') {
        depth--;
        if (depth == 0) return s.substring(start, i + 1);
      }
    }
    return null;
  }

  /// PHP warning / chiqindi oldidan `{"status"` boshlanishiga tutash.
  static String trimLeadingJsonNoise(String s) {
    final idx = s.indexOf('{"status"');
    if (idx > 0) return s.substring(idx);
    final j = s.indexOf('{');
    if (j > 0) return s.substring(j);
    return s;
  }

  /// `"2026-05-07T...Z""updated_at":` → vergul bilan.
  static String repairMissingCommaAfterIsoTimestamps(String json) {
    return json.replaceAllMapped(
      RegExp(
        r'"(\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}(?:\.\d+)?Z)""([a-zA-Z_][a-zA-Z0-9_]*)"\s*:',
      ),
      (m) => '"${m[1]}","${m[2]}":',
    );
  }

  /// Darslar/API katta JSON: avval sanitizatsiya, keyin extract + tuzatish.
  static Map<String, dynamic> decodeJsonMap(String raw) {
    final trimmed = trimLeadingJsonNoise(raw.trim());
    var s = forJsonDecode(trimmed);

    Object? lastError;
    try {
      return jsonDecode(s) as Map<String, dynamic>;
    } on FormatException catch (e) {
      lastError = e;
    }

    try {
      final fixed = repairMissingCommaAfterIsoTimestamps(s);
      if (fixed != s) {
        s = forJsonDecode(fixed);
        return jsonDecode(s) as Map<String, dynamic>;
      }
    } on FormatException catch (e) {
      lastError = e;
    }

    final extracted = extractBalancedJsonObject(trimmed) ??
        extractBalancedJsonObject(s);
    if (extracted != null && extracted != trimmed) {
      s = forJsonDecode(extracted);
      try {
        return jsonDecode(s) as Map<String, dynamic>;
      } on FormatException catch (e) {
        lastError = e;
      }
      try {
        final fixed2 = repairMissingCommaAfterIsoTimestamps(s);
        if (fixed2 != s) {
          return jsonDecode(forJsonDecode(fixed2)) as Map<String, dynamic>;
        }
      } on FormatException catch (e) {
        lastError = e;
      }
    }

    if (lastError is FormatException) throw lastError;
    throw FormatException('JSON tahlil qilib bo\'lmadi');
  }
}
