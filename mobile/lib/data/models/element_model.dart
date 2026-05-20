import '../../domain/entities/element.dart';

class ElementModel extends ElementEntity {
  const ElementModel({
    required super.id,
    required super.atomicNumber,
    required super.symbol,
    required super.mass,
    super.colorHex,
    required super.type,
    required super.translations,
  });

  factory ElementModel.fromJson(Map<String, dynamic> json) {
    return ElementModel(
      id: json['id'] is String ? int.parse(json['id']) : json['id'],
      atomicNumber: json['atomic_number'] is String ? int.parse(json['atomic_number']) : json['atomic_number'],
      symbol: json['symbol'],
      mass: json['mass'] is String ? double.parse(json['mass']) : (json['mass'] as num).toDouble(),
      colorHex: json['color_hex'],
      type: json['type'],
      translations: (json['translations'] as List? ?? [])
          .map((t) => ElementTranslationModel.fromJson(t))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'atomic_number': atomicNumber,
      'symbol': symbol,
      'mass': mass,
      'color_hex': colorHex,
      'type': type,
      'translations': translations
          .map((t) => (t as ElementTranslationModel).toJson())
          .toList(),
    };
  }
}

class ElementTranslationModel extends ElementTranslationEntity {
  const ElementTranslationModel({
    required super.name,
    super.description,
    required super.languageCode,
  });

  factory ElementTranslationModel.fromJson(Map<String, dynamic> json) {
    return ElementTranslationModel(
      name: json['name'],
      description: json['description'],
      languageCode: json['language']?['code'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'description': description,
      'language': {'code': languageCode},
    };
  }
}
