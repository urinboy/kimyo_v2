import '../../domain/entities/mine.dart';
import 'element_model.dart';

class MineModel extends MineEntity {
  const MineModel({
    required super.id,
    required super.latitude,
    required super.longitude,
    required super.isActive,
    required super.elements,
    required super.translations,
  });

  factory MineModel.fromJson(Map<String, dynamic> json) {
    return MineModel(
      id: json['id'] is String ? int.parse(json['id']) : json['id'],
      latitude: json['latitude'] is String ? double.parse(json['latitude']) : (json['latitude'] as num).toDouble(),
      longitude: json['longitude'] is String ? double.parse(json['longitude']) : (json['longitude'] as num).toDouble(),
      isActive: json['is_active'] == 1 || json['is_active'] == true || json['is_active'] == '1',
      elements: (json['elements'] as List? ?? [])
          .map((e) => ElementModel.fromJson(e))
          .toList(),
      translations: (json['translations'] as List? ?? [])
          .map((t) => MineTranslationModel.fromJson(t))
          .toList(),
    );
  }
}

class MineTranslationModel extends MineTranslationEntity {
  const MineTranslationModel({
    required super.name,
    super.description,
    required super.languageCode,
  });

  factory MineTranslationModel.fromJson(Map<String, dynamic> json) {
    return MineTranslationModel(
      name: json['name'],
      description: json['description'],
      languageCode: json['language']?['code'] ?? '',
    );
  }
}
