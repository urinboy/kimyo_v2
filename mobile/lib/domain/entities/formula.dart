import 'element.dart';

class FormulaEntity {
  final int id;
  final String formula;
  final double molarMass;
  final String? category;
  final List<FormulaTranslationEntity> translations;
  final List<ElementEntity>? elements;

  FormulaEntity({
    required this.id,
    required this.formula,
    required this.molarMass,
    this.category,
    required this.translations,
    this.elements,
  });

  String getName(String languageCode) {
    if (translations.isEmpty) return formula;
    for (var t in translations) {
      if (t.languageCode == languageCode) return t.name;
    }
    return translations.first.name;
  }
}

class FormulaTranslationEntity {
  final int id;
  final int languageId;
  final String languageCode;
  final String name;

  FormulaTranslationEntity({
    required this.id,
    required this.languageId,
    required this.languageCode,
    required this.name,
  });
}
