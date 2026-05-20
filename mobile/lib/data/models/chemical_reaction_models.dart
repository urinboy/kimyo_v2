import 'package:flutter/material.dart';

class ChemicalReactionsBundle {
  const ChemicalReactionsBundle({
    required this.types,
    required this.symbols,
  });

  final List<ChemicalReactionTypeDto> types;
  final List<ChemicalReactionSymbolDto> symbols;
}

Color _hexColor(String hex) {
  var s = hex.trim();
  if (s.startsWith('#')) s = s.substring(1);
  if (s.length == 6) s = 'FF$s';
  return Color(int.parse(s, radix: 16));
}

class ChemicalReactionTypeDto {
  const ChemicalReactionTypeDto({
    required this.id,
    required this.nameUz,
    this.nameRu,
    this.nameEn,
    this.nameKaa,
    required this.formula,
    this.descriptionUz,
    this.descriptionRu,
    this.descriptionEn,
    this.descriptionKaa,
    this.modalFormula,
    this.modalBadgeUz,
    this.modalBadgeRu,
    this.modalBadgeEn,
    this.modalBadgeKaa,
    required this.examples,
    required this.colorHex,
    required this.iconColorHex,
    required this.order,
  });

  final int id;
  final String nameUz;
  final String? nameRu;
  final String? nameEn;
  final String? nameKaa;
  final String formula;
  final String? descriptionUz;
  final String? descriptionRu;
  final String? descriptionEn;
  final String? descriptionKaa;
  final String? modalFormula;
  final String? modalBadgeUz;
  final String? modalBadgeRu;
  final String? modalBadgeEn;
  final String? modalBadgeKaa;
  final List<String> examples;
  final String colorHex;
  final String iconColorHex;
  final int order;

  static List<String> _parseExamples(dynamic v) {
    if (v == null) return [];
    if (v is List) return v.map((e) => e.toString()).toList();
    return [];
  }

  factory ChemicalReactionTypeDto.fromJson(Map<String, dynamic> json) {
    return ChemicalReactionTypeDto(
      id: (json['id'] as num).toInt(),
      nameUz: json['name_uz'] as String,
      nameRu: json['name_ru'] as String?,
      nameEn: json['name_en'] as String?,
      nameKaa: json['name_kaa'] as String?,
      formula: json['formula'] as String,
      descriptionUz: json['description_uz'] as String?,
      descriptionRu: json['description_ru'] as String?,
      descriptionEn: json['description_en'] as String?,
      descriptionKaa: json['description_kaa'] as String?,
      modalFormula: json['modal_formula'] as String?,
      modalBadgeUz: json['modal_badge_uz'] as String?,
      modalBadgeRu: json['modal_badge_ru'] as String?,
      modalBadgeEn: json['modal_badge_en'] as String?,
      modalBadgeKaa: json['modal_badge_kaa'] as String?,
      examples: _parseExamples(json['examples']),
      colorHex: json['color_hex'] as String,
      iconColorHex: json['icon_color_hex'] as String,
      order: (json['order'] as num?)?.toInt() ?? 0,
    );
  }

  String nameFor(String lang) {
    switch (lang) {
      case 'ru':
        return nameRu?.isNotEmpty == true ? nameRu! : nameUz;
      case 'en':
        return nameEn?.isNotEmpty == true ? nameEn! : nameUz;
      default:
        return nameUz;
    }
  }

  String? descriptionFor(String lang) {
    switch (lang) {
      case 'ru':
        return descriptionRu?.isNotEmpty == true ? descriptionRu : descriptionUz;
      case 'en':
        return descriptionEn?.isNotEmpty == true ? descriptionEn : descriptionUz;
      default:
        return descriptionUz;
    }
  }

  String? badgeFor(String lang) {
    switch (lang) {
      case 'ru':
        return modalBadgeRu?.isNotEmpty == true ? modalBadgeRu : modalBadgeUz;
      case 'en':
        return modalBadgeEn?.isNotEmpty == true ? modalBadgeEn : modalBadgeUz;
      default:
        return modalBadgeUz;
    }
  }

  Color get cardTint => _hexColor(colorHex);
  Color get iconTint => _hexColor(iconColorHex);
}

class ChemicalReactionSymbolDto {
  const ChemicalReactionSymbolDto({
    required this.symbol,
    required this.descUz,
    this.descRu,
    this.descEn,
    this.descKaa,
    required this.order,
  });

  final String symbol;
  final String descUz;
  final String? descRu;
  final String? descEn;
  final String? descKaa;
  final int order;

  factory ChemicalReactionSymbolDto.fromJson(Map<String, dynamic> json) {
    return ChemicalReactionSymbolDto(
      symbol: json['symbol'] as String,
      descUz: json['desc_uz'] as String,
      descRu: json['desc_ru'] as String?,
      descEn: json['desc_en'] as String?,
      descKaa: json['desc_kaa'] as String?,
      order: (json['order'] as num?)?.toInt() ?? 0,
    );
  }

  String descFor(String lang) {
    switch (lang) {
      case 'ru':
        return descRu?.isNotEmpty == true ? descRu! : descUz;
      case 'en':
        return descEn?.isNotEmpty == true ? descEn! : descUz;
      default:
        return descUz;
    }
  }
}
