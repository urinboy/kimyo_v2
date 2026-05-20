import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';

import '../models/element_model.dart';

abstract class ElementLocalDataSource {
  Future<void> saveElements(List<ElementModel> elements);

  /// Oxirgi muvaffaqiyatli saqlangan ro‘yxat; fayl yo‘q yoki buzilsa `null`.
  Future<List<ElementModel>?> loadElements();
}

class ElementLocalDataSourceImpl implements ElementLocalDataSource {
  static const _fileName = 'elements_cache_v1.json';

  File? _file;

  Future<File> _cacheFile() async {
    if (_file != null) return _file!;
    final dir = await getApplicationSupportDirectory();
    _file = File('${dir.path}/$_fileName');
    return _file!;
  }

  @override
  Future<void> saveElements(List<ElementModel> elements) async {
    final f = await _cacheFile();
    final payload = <String, dynamic>{
      'version': 1,
      'cachedAt': DateTime.now().toUtc().toIso8601String(),
      'elements': elements.map((e) => e.toJson()).toList(),
    };
    await f.writeAsString(jsonEncode(payload));
  }

  @override
  Future<List<ElementModel>?> loadElements() async {
    try {
      final f = await _cacheFile();
      if (!await f.exists()) return null;
      final raw = await f.readAsString();
      final decoded = jsonDecode(raw);
      if (decoded is! Map) return null;
      final list = decoded['elements'];
      if (list is! List) return null;
      return list.map((e) {
        if (e is! Map) throw const FormatException('element item');
        return ElementModel.fromJson(Map<String, dynamic>.from(e));
      }).toList();
    } catch (_) {
      return null;
    }
  }
}
