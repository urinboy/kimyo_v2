import 'package:flutter/services.dart';

import '../models/element_model.dart';
import 'element_response_parser.dart';

/// `/elements` bilan bir xil JSend JSON — `assets/data/elements_bundle.json`.
abstract class ElementBundledDataSource {
  Future<List<ElementModel>> loadBundledElements();
}

class ElementBundledDataSourceImpl implements ElementBundledDataSource {
  static const _assetPath = 'assets/data/elements_bundle.json';

  static List<ElementModel>? _memo;
  static Future<List<ElementModel>>? _inFlight;

  @override
  Future<List<ElementModel>> loadBundledElements() async {
    if (_memo != null) return _memo!;
    _inFlight ??= _parseOnce();
    try {
      final list = await _inFlight!;
      _memo = list;
      return list;
    } finally {
      _inFlight = null;
    }
  }

  Future<List<ElementModel>> _parseOnce() async {
    final raw = await rootBundle.loadString(_assetPath);
    return parseElementsResponseBody(raw);
  }
}
