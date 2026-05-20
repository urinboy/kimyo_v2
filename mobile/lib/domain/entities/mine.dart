import 'package:equatable/equatable.dart';
import 'element.dart';

class MineEntity extends Equatable {
  final int id;
  final double latitude;
  final double longitude;
  final bool isActive;
  final List<ElementEntity> elements;
  final List<MineTranslationEntity> translations;

  const MineEntity({
    required this.id,
    required this.latitude,
    required this.longitude,
    required this.isActive,
    required this.elements,
    required this.translations,
  });

  String getName(String langCode) {
    final translation = translations.firstWhere(
      (t) => t.languageCode == langCode,
      orElse: () => translations.isNotEmpty ? translations.first : const MineTranslationEntity(name: 'N/A', languageCode: ''),
    );
    return translation.name;
  }

  String? getDescription(String langCode) {
    final translation = translations.firstWhere(
      (t) => t.languageCode == langCode,
      orElse: () => translations.isNotEmpty ? translations.first : const MineTranslationEntity(name: 'N/A', languageCode: ''),
    );
    return translation.description;
  }

  @override
  List<Object?> get props => [id, latitude, longitude, isActive, elements, translations];
}

class MineTranslationEntity extends Equatable {
  final String name;
  final String? description;
  final String languageCode;

  const MineTranslationEntity({
    required this.name,
    this.description,
    required this.languageCode,
  });

  @override
  List<Object?> get props => [name, description, languageCode];
}
