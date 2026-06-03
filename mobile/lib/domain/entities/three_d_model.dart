import 'package:equatable/equatable.dart';

class ElementRef extends Equatable {
  final int id;
  final String symbol;
  final int atomicNumber;

  const ElementRef({
    required this.id,
    required this.symbol,
    required this.atomicNumber,
  });

  @override
  List<Object?> get props => [id, symbol, atomicNumber];
}

class ThreeDModelEntity extends Equatable {
  final int id;
  final String slug;
  final String? modelUrl;
  final int? elementId;
  final ElementRef? element;
  final int sortOrder;
  final String? name;
  final String? description;

  const ThreeDModelEntity({
    required this.id,
    required this.slug,
    this.modelUrl,
    this.elementId,
    this.element,
    required this.sortOrder,
    this.name,
    this.description,
  });

  bool get hasModel => modelUrl != null && modelUrl!.isNotEmpty;
  bool get isGlb => modelUrl?.toLowerCase().endsWith('.glb') ?? false;

  @override
  List<Object?> get props => [id, slug, modelUrl, elementId, element, sortOrder, name, description];
}
