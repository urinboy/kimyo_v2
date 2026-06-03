import '../../domain/entities/three_d_model.dart';

class ThreeDModelModel extends ThreeDModelEntity {
  const ThreeDModelModel({
    required super.id,
    required super.slug,
    super.modelUrl,
    super.elementId,
    super.element,
    required super.sortOrder,
    super.name,
    super.description,
  });

  factory ThreeDModelModel.fromJson(Map<String, dynamic> json) {
    ElementRef? elementRef;
    final rawElement = json['element'];
    if (rawElement is Map<String, dynamic>) {
      elementRef = ElementRef(
        id: rawElement['id'] as int,
        symbol: rawElement['symbol'] as String? ?? '',
        atomicNumber: rawElement['atomic_number'] as int? ?? 0,
      );
    }

    return ThreeDModelModel(
      id: json['id'] as int,
      slug: json['slug'] as String? ?? '',
      modelUrl: json['model_url'] as String?,
      elementId: json['element_id'] as int?,
      element: elementRef,
      sortOrder: json['sort_order'] as int? ?? 0,
      name: json['name'] as String?,
      description: json['description'] as String?,
    );
  }
}
