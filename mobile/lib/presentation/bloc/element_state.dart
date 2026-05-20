import 'package:equatable/equatable.dart';

import '../../../domain/entities/element.dart';

abstract class ElementState extends Equatable {
  const ElementState();

  @override
  List<Object?> get props => [];
}

class ElementInitial extends ElementState {}

class ElementLoading extends ElementState {}

class ElementLoaded extends ElementState {
  final List<ElementEntity> elements;
  /// `true` — tarmoqdan olinmadi, o‘xshash fayldagi oxirgi muvaffaqiyatli saqlangan maʼlumot.
  final bool fromCache;

  const ElementLoaded(this.elements, {this.fromCache = false});

  @override
  List<Object?> get props => [elements, fromCache];
}

class ElementError extends ElementState {
  final String message;

  const ElementError(this.message);

  @override
  List<Object?> get props => [message];
}
