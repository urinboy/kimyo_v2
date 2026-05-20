import '../../domain/entities/formula.dart';
import 'element_model.dart';

class FormulaModel extends FormulaEntity {
  FormulaModel({
    required super.id,
    required super.formula,
    required super.molarMass,
    super.category,
    required super.translations,
    super.elements,
  });

  factory FormulaModel.fromJson(Map<String, dynamic> json) {
    return FormulaModel(
      id: json['id'] is String ? int.parse(json['id']) : json['id'],
      formula: json['formula'],
      molarMass: json['molar_mass'] is String ? double.parse(json['molar_mass']) : (json['molar_mass'] as num).toDouble(),
      category: json['category'],
      translations: (json['translations'] as List? ?? [])
          .map((t) => FormulaTranslationModel.fromJson(t))
          .toList(),
      elements: json['elements'] != null
          ? (json['elements'] as List)
              .map((e) => ElementModel.fromJson(e))
              .toList()
          : null,
    );
  }
}

class FormulaTranslationModel extends FormulaTranslationEntity {
  FormulaTranslationModel({
    required super.id,
    required super.languageId,
    required super.languageCode,
    required super.name,
  });

  factory FormulaTranslationModel.fromJson(Map<String, dynamic> json) {
    return FormulaTranslationModel(
      id: json['id'] is String ? int.parse(json['id']) : json['id'],
      languageId: json['language_id'] is String ? int.parse(json['language_id']) : json['language_id'],
      languageCode: json['language'] != null ? json['language']['code'] : 'uz', // fallback
      name: json['name'],
    );
  }
}
