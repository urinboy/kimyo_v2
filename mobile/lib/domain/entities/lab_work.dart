import 'package:equatable/equatable.dart';

// ─── LabWork ──────────────────────────────────────────────────────────────────

class LabWorkEntity extends Equatable {
  final int id;
  final int number;
  final String status;
  final int? experimentsCount;
  final List<LabWorkTranslationEntity> translations;
  final List<LabExperimentEntity> experiments;

  const LabWorkEntity({
    required this.id,
    required this.number,
    required this.status,
    this.experimentsCount,
    required this.translations,
    this.experiments = const [],
  });

  String getTitle(String langCode) {
    if (translations.isEmpty) return '$number-Laboratoriya';
    try {
      return translations.firstWhere((t) => t.languageCode == langCode).title;
    } catch (_) {
      return translations.first.title;
    }
  }

  String? getDescription(String langCode) {
    if (translations.isEmpty) return null;
    try {
      return translations.firstWhere((t) => t.languageCode == langCode).description;
    } catch (_) {
      return translations.first.description;
    }
  }

  @override
  List<Object?> get props => [id, number, status, experimentsCount, translations, experiments];
}

class LabWorkTranslationEntity extends Equatable {
  final String languageCode;
  final String title;
  final String? description;

  const LabWorkTranslationEntity({
    required this.languageCode,
    required this.title,
    this.description,
  });

  @override
  List<Object?> get props => [languageCode, title, description];
}

// ─── LabExperiment ────────────────────────────────────────────────────────────

class LabExperimentEntity extends Equatable {
  final int id;
  final String type; // probirka | tajriba | bosqich
  final int orderIndex;
  final String status;
  final List<LabExperimentTranslationEntity> translations;
  final List<LabReactionEntity> reactions;
  final List<LabObservationEntity> observations;
  final List<LabProductEntity> products;

  const LabExperimentEntity({
    required this.id,
    required this.type,
    required this.orderIndex,
    required this.status,
    required this.translations,
    this.reactions = const [],
    this.observations = const [],
    this.products = const [],
  });

  String getTitle(String langCode) {
    if (translations.isEmpty) return '$orderIndex-$type';
    try {
      return translations.firstWhere((t) => t.languageCode == langCode).title;
    } catch (_) {
      return translations.first.title;
    }
  }

  String? getExplanation(String langCode) {
    if (translations.isEmpty) return null;
    try {
      return translations.firstWhere((t) => t.languageCode == langCode).scientificExplanation;
    } catch (_) {
      return translations.first.scientificExplanation;
    }
  }

  @override
  List<Object?> get props => [id, type, orderIndex, status, translations, reactions, observations, products];
}

class LabExperimentTranslationEntity extends Equatable {
  final String languageCode;
  final String title;
  final String? scientificExplanation;

  const LabExperimentTranslationEntity({
    required this.languageCode,
    required this.title,
    this.scientificExplanation,
  });

  @override
  List<Object?> get props => [languageCode, title, scientificExplanation];
}

// ─── LabReaction ──────────────────────────────────────────────────────────────

class LabReactionEntity extends Equatable {
  final int id;
  final String formula;
  final String type; // molecular | full_ionic | short_ionic
  final int orderIndex;

  const LabReactionEntity({
    required this.id,
    required this.formula,
    required this.type,
    required this.orderIndex,
  });

  @override
  List<Object?> get props => [id, formula, type, orderIndex];
}

// ─── LabObservation ───────────────────────────────────────────────────────────

class LabObservationEntity extends Equatable {
  final int id;
  final int orderIndex;
  final List<LabObservationTranslationEntity> translations;

  const LabObservationEntity({
    required this.id,
    required this.orderIndex,
    required this.translations,
  });

  String getText(String langCode) {
    if (translations.isEmpty) return '';
    try {
      return translations.firstWhere((t) => t.languageCode == langCode).text;
    } catch (_) {
      return translations.first.text;
    }
  }

  @override
  List<Object?> get props => [id, orderIndex, translations];
}

class LabObservationTranslationEntity extends Equatable {
  final String languageCode;
  final String text;

  const LabObservationTranslationEntity({
    required this.languageCode,
    required this.text,
  });

  @override
  List<Object?> get props => [languageCode, text];
}

// ─── LabProduct ───────────────────────────────────────────────────────────────

class LabProductEntity extends Equatable {
  final int id;
  final String chemicalFormula;
  final String state; // dissolved | precipitate | gas | solid | unknown
  final int orderIndex;
  final List<LabProductTranslationEntity> translations;

  const LabProductEntity({
    required this.id,
    required this.chemicalFormula,
    required this.state,
    required this.orderIndex,
    required this.translations,
  });

  String getName(String langCode) {
    if (translations.isEmpty) return chemicalFormula;
    try {
      return translations.firstWhere((t) => t.languageCode == langCode).name;
    } catch (_) {
      return translations.first.name;
    }
  }

  String get stateSymbol {
    switch (state) {
      case 'precipitate': return '↓';
      case 'gas':         return '↑';
      default:            return '';
    }
  }

  @override
  List<Object?> get props => [id, chemicalFormula, state, orderIndex, translations];
}

class LabProductTranslationEntity extends Equatable {
  final String languageCode;
  final String name;

  const LabProductTranslationEntity({
    required this.languageCode,
    required this.name,
  });

  @override
  List<Object?> get props => [languageCode, name];
}
