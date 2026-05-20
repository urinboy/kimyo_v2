import 'dart:convert';

import '../models/element_model.dart';

/// Javob boshi/oxiridagi ortiqcha matnlar (PHP notice, proksi HTML) uchun
/// birinchi to‘liq `{ ... }` obyektini ajratadi. String ichidagi `{}`/`"` ni hisobga oladi.
String? extractFirstJsonObject(String input) {
  final start = input.indexOf('{');
  if (start < 0) return null;

  var depth = 0;
  var inStr = false;
  var i = start;

  bool isHex(int c) =>
      (c >= 48 && c <= 57) || (c >= 97 && c <= 102) || (c >= 65 && c <= 70); // 0-9 a-f A-F

  while (i < input.length) {
    final cu = input.codeUnitAt(i);

    if (inStr) {
      if (cu == 0x22) {
        // "
        inStr = false;
        i++;
        continue;
      }
      if (cu == 0x5C) {
        // \
        i++;
        if (i >= input.length) return null;
        if (input.codeUnitAt(i) == 0x75) {
          // \uXXXX
          i++;
          for (var h = 0; h < 4; h++) {
            if (i >= input.length || !isHex(input.codeUnitAt(i))) return null;
            i++;
          }
        } else {
          i++; // boshqa escape
        }
        continue;
      }
      i++;
      continue;
    }

    switch (cu) {
      case 0x22: // "
        inStr = true;
        break;
      case 0x7B: // {
        depth++;
        break;
      case 0x7D: // }
        depth--;
        if (depth == 0) {
          return input.substring(start, i + 1);
        }
        break;
      default:
        break;
    }
    i++;
  }
  return null;
}

/// JSend + HTML/proksi xatolari uchun xavfsiz ajratish.
List<ElementModel> parseElementsResponseBody(String rawBody) {
  var body = rawBody;
  if (body.isNotEmpty && body.codeUnitAt(0) == 0xFEFF) {
    body = body.substring(1);
  }
  final trimmed = body.trim();
  if (trimmed.isEmpty) {
    throw const FormatException('Empty response body');
  }
  if (trimmed.startsWith('<')) {
    throw FormatException('Server JSON emas (ehtimol HTML/xato sahifa)');
  }

  final extracted = trimmed.startsWith('{') ? trimmed : extractFirstJsonObject(trimmed);
  final toDecode = (extracted != null && extracted.isNotEmpty) ? extracted : trimmed;

  dynamic decoded;
  try {
    decoded = jsonDecode(toDecode);
  } on FormatException {
    final cut = extractFirstJsonObject(trimmed);
    if (cut != null && cut != toDecode) {
      decoded = jsonDecode(cut);
    } else {
      rethrow;
    }
  }
  if (decoded is! Map) {
    throw const FormatException('Root JSON object emas');
  }
  final map = Map<String, dynamic>.from(decoded);
  final status = map['status']?.toString();
  if (status != 'success') {
    final msg = map['message']?.toString() ?? "API status: ${status ?? 'nomaʼlum'}";
    throw FormatException(msg);
  }
  final data = map['data'];
  if (data is! Map) {
    throw const FormatException('data maydoni yo\'q');
  }
  final elementsRaw = data['elements'];
  if (elementsRaw is! List) {
    throw const FormatException('data.elements ro\'yxat emas');
  }

  return elementsRaw.map((json) {
    if (json is! Map) {
      throw const FormatException('element not object');
    }
    return ElementModel.fromJson(Map<String, dynamic>.from(json));
  }).toList();
}
