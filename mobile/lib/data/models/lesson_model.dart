import '../../domain/entities/lesson.dart';

class LessonModel extends LessonEntity {
  const LessonModel({
    required super.id,
    required super.type,
    required super.order,
    required super.isActive,
    required super.translations,
    super.labItemsCount,
  });

  factory LessonModel.fromJson(Map<String, dynamic> json) {
    return LessonModel(
      id: json['id'] is String ? int.parse(json['id']) : json['id'],
      type: json['type'],
      order: json['order'] is String ? int.parse(json['order']) : json['order'],
      isActive: json['is_active'] == 1 || json['is_active'] == true || json['is_active'] == '1',
      translations: (json['translations'] as List)
          .map((t) => LessonTranslationModel.fromJson(t))
          .toList(),
      labItemsCount: json['lab_items_count'] is String
          ? int.parse(json['lab_items_count'])
          : (json['lab_items_count'] ?? 0),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'order': order,
      'is_active': isActive,
      'lab_items_count': labItemsCount,
      'translations': translations
          .map((t) => (t as LessonTranslationModel).toJson())
          .toList(),
    };
  }
}

class LessonTranslationModel extends LessonTranslationEntity {
  const LessonTranslationModel({
    required super.title,
    super.content,
    required super.languageCode,
  });

  factory LessonTranslationModel.fromJson(Map<String, dynamic> json) {
    return LessonTranslationModel(
      title: json['title'],
      content: json['content'],
      languageCode: json['language']?['code'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'content': content,
      'language': {'code': languageCode},
    };
  }
}
