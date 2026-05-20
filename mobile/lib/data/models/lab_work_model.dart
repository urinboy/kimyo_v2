import '../../domain/entities/lab_work.dart';

// ─── LabWorkModel ─────────────────────────────────────────────────────────────

class LabWorkModel extends LabWorkEntity {
  const LabWorkModel({
    required super.id,
    required super.number,
    required super.status,
    super.experimentsCount,
    required super.translations,
    super.experiments,
  });

  factory LabWorkModel.fromJson(Map<String, dynamic> json) {
    return LabWorkModel(
      id: json['id'],
      number: json['number'],
      status: json['status'] ?? 'active',
      experimentsCount: json['experiments_count'],
      translations: (json['translations'] as List? ?? [])
          .map((t) => LabWorkTranslationModel.fromJson(t))
          .toList(),
      experiments: (json['experiments'] as List? ?? [])
          .map((e) => LabExperimentModel.fromJson(e))
          .toList(),
    );
  }
}

class LabWorkTranslationModel extends LabWorkTranslationEntity {
  const LabWorkTranslationModel({
    required super.languageCode,
    required super.title,
    super.description,
  });

  factory LabWorkTranslationModel.fromJson(Map<String, dynamic> json) {
    final lang = json['language'] as Map<String, dynamic>?;
    return LabWorkTranslationModel(
      languageCode: lang?['code'] ?? json['language_code'] ?? 'uz',
      title: json['title'] ?? '',
      description: json['description'],
    );
  }
}

// ─── LabExperimentModel ───────────────────────────────────────────────────────

class LabExperimentModel extends LabExperimentEntity {
  const LabExperimentModel({
    required super.id,
    required super.type,
    required super.orderIndex,
    required super.status,
    required super.translations,
    super.reactions,
    super.observations,
    super.products,
  });

  factory LabExperimentModel.fromJson(Map<String, dynamic> json) {
    return LabExperimentModel(
      id: json['id'],
      type: json['type'] ?? 'probirka',
      orderIndex: json['order_index'] ?? 1,
      status: json['status'] ?? 'active',
      translations: (json['translations'] as List? ?? [])
          .map((t) => LabExperimentTranslationModel.fromJson(t))
          .toList(),
      reactions: (json['reactions'] as List? ?? [])
          .map((r) => LabReactionModel.fromJson(r))
          .toList(),
      observations: (json['observations'] as List? ?? [])
          .map((o) => LabObservationModel.fromJson(o))
          .toList(),
      products: (json['products'] as List? ?? [])
          .map((p) => LabProductModel.fromJson(p))
          .toList(),
    );
  }
}

class LabExperimentTranslationModel extends LabExperimentTranslationEntity {
  const LabExperimentTranslationModel({
    required super.languageCode,
    required super.title,
    super.scientificExplanation,
  });

  factory LabExperimentTranslationModel.fromJson(Map<String, dynamic> json) {
    final lang = json['language'] as Map<String, dynamic>?;
    return LabExperimentTranslationModel(
      languageCode: lang?['code'] ?? json['language_code'] ?? 'uz',
      title: json['title'] ?? '',
      scientificExplanation: json['scientific_explanation'],
    );
  }
}

// ─── LabReactionModel ─────────────────────────────────────────────────────────

class LabReactionModel extends LabReactionEntity {
  const LabReactionModel({
    required super.id,
    required super.formula,
    required super.type,
    required super.orderIndex,
  });

  factory LabReactionModel.fromJson(Map<String, dynamic> json) {
    return LabReactionModel(
      id: json['id'],
      formula: json['formula'] ?? '',
      type: json['type'] ?? 'molecular',
      orderIndex: json['order_index'] ?? 1,
    );
  }
}

// ─── LabObservationModel ──────────────────────────────────────────────────────

class LabObservationModel extends LabObservationEntity {
  const LabObservationModel({
    required super.id,
    required super.orderIndex,
    required super.translations,
  });

  factory LabObservationModel.fromJson(Map<String, dynamic> json) {
    return LabObservationModel(
      id: json['id'],
      orderIndex: json['order_index'] ?? 1,
      translations: (json['translations'] as List? ?? [])
          .map((t) => LabObservationTranslationModel.fromJson(t))
          .toList(),
    );
  }
}

class LabObservationTranslationModel extends LabObservationTranslationEntity {
  const LabObservationTranslationModel({
    required super.languageCode,
    required super.text,
  });

  factory LabObservationTranslationModel.fromJson(Map<String, dynamic> json) {
    final lang = json['language'] as Map<String, dynamic>?;
    return LabObservationTranslationModel(
      languageCode: lang?['code'] ?? json['language_code'] ?? 'uz',
      text: json['text'] ?? '',
    );
  }
}

// ─── LabProductModel ──────────────────────────────────────────────────────────

class LabProductModel extends LabProductEntity {
  const LabProductModel({
    required super.id,
    required super.chemicalFormula,
    required super.state,
    required super.orderIndex,
    required super.translations,
  });

  factory LabProductModel.fromJson(Map<String, dynamic> json) {
    return LabProductModel(
      id: json['id'],
      chemicalFormula: json['chemical_formula'] ?? '',
      state: json['state'] ?? 'dissolved',
      orderIndex: json['order_index'] ?? 1,
      translations: (json['translations'] as List? ?? [])
          .map((t) => LabProductTranslationModel.fromJson(t))
          .toList(),
    );
  }
}

class LabProductTranslationModel extends LabProductTranslationEntity {
  const LabProductTranslationModel({
    required super.languageCode,
    required super.name,
  });

  factory LabProductTranslationModel.fromJson(Map<String, dynamic> json) {
    final lang = json['language'] as Map<String, dynamic>?;
    return LabProductTranslationModel(
      languageCode: lang?['code'] ?? json['language_code'] ?? 'uz',
      name: json['name'] ?? '',
    );
  }
}
