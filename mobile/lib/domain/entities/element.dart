import 'package:equatable/equatable.dart';

class ElementEntity extends Equatable {
  final int id;
  final int atomicNumber;
  final String symbol;
  final double mass;
  final String? colorHex;
  final String type;
  final List<ElementTranslationEntity> translations;

  const ElementEntity({
    required this.id,
    required this.atomicNumber,
    required this.symbol,
    required this.mass,
    this.colorHex,
    required this.type,
    required this.translations,
  });

  String getName(String languageCode) {
    if (translations.isEmpty) return 'N/A';
    for (var t in translations) {
      if (t.languageCode == languageCode) return t.name;
    }
    return translations.first.name;
  }

  String getDescription(String languageCode) {
    if (translations.isEmpty) return '';
    for (var t in translations) {
      if (t.languageCode == languageCode) return t.description ?? '';
    }
    return translations.first.description ?? '';
  }

  @override
  List<Object?> get props => [id, atomicNumber, symbol, mass, colorHex, type, translations];

  int get row => _getRow(atomicNumber);
  int get column => _getColumn(atomicNumber);

  static int _getRow(int atomicNumber) {
    if (atomicNumber == 1 || atomicNumber == 2) return 1;
    if (atomicNumber >= 3 && atomicNumber <= 10) return 2;
    if (atomicNumber >= 11 && atomicNumber <= 18) return 3;
    if (atomicNumber >= 19 && atomicNumber <= 36) return 4;
    if (atomicNumber >= 37 && atomicNumber <= 54) return 5;
    if (atomicNumber >= 55 && atomicNumber <= 86) {
      if (atomicNumber >= 57 && atomicNumber <= 71) return 8; // Lanthanides
      return 6;
    }
    if (atomicNumber >= 87 && atomicNumber <= 118) {
      if (atomicNumber >= 89 && atomicNumber <= 103) return 9; // Actinides
      return 7;
    }
    return 1;
  }

  static int _getColumn(int atomicNumber) {
    if (atomicNumber == 1) return 1;
    if (atomicNumber == 2) return 18;
    if (atomicNumber >= 3 && atomicNumber <= 4) return atomicNumber - 2;
    if (atomicNumber >= 5 && atomicNumber <= 10) return atomicNumber + 8;
    if (atomicNumber >= 11 && atomicNumber <= 12) return atomicNumber - 10;
    if (atomicNumber >= 13 && atomicNumber <= 18) return atomicNumber;
    if (atomicNumber >= 19 && atomicNumber <= 36) return atomicNumber - 18;
    if (atomicNumber >= 37 && atomicNumber <= 54) return atomicNumber - 36;
    if (atomicNumber >= 55 && atomicNumber <= 86) {
      if (atomicNumber >= 57 && atomicNumber <= 71) return atomicNumber - 54; // Lanthanides (starts from col 3)
      if (atomicNumber > 71) return atomicNumber - 68; // After Lanthanides
      return atomicNumber - 54;
    }
    if (atomicNumber >= 87 && atomicNumber <= 118) {
      if (atomicNumber >= 89 && atomicNumber <= 103) return atomicNumber - 86; // Actinides (starts from col 3)
      if (atomicNumber > 103) return atomicNumber - 100; // After Actinides
      return atomicNumber - 86;
    }
    return 1;
  }
}

class ElementTranslationEntity extends Equatable {
  final String name;
  final String? description;
  final String languageCode;

  const ElementTranslationEntity({
    required this.name,
    this.description,
    required this.languageCode,
  });

  @override
  List<Object?> get props => [name, description, languageCode];
}
