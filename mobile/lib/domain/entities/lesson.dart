import 'package:equatable/equatable.dart';

class LessonEntity extends Equatable {
  final int id;
  final String type;
  final int order;
  final bool isActive;
  final List<LessonTranslationEntity> translations;
  final int labItemsCount;

  const LessonEntity({
    required this.id,
    required this.type,
    required this.order,
    required this.isActive,
    required this.translations,
    this.labItemsCount = 0,
  });

  String getTitle(String langCode) {
    if (translations.isEmpty) return 'Untitled';
    try {
      return translations
          .firstWhere((t) => t.languageCode == langCode)
          .title;
    } catch (_) {
      return translations.first.title;
    }
  }

  String? getContent(String langCode) {
    if (translations.isEmpty) return '';
    try {
      return translations
          .firstWhere((t) => t.languageCode == langCode)
          .content;
    } catch (_) {
      return translations.first.content;
    }
  }

  @override
  List<Object?> get props => [id, type, order, isActive, translations, labItemsCount];
}

class LessonTranslationEntity extends Equatable {
  final String title;
  final String? content;
  final String languageCode;

  const LessonTranslationEntity({
    required this.title,
    this.content,
    required this.languageCode,
  });

  @override
  List<Object?> get props => [title, content, languageCode];
}
