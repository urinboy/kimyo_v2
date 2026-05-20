import 'package:equatable/equatable.dart';

abstract class ElementEvent extends Equatable {
  const ElementEvent();

  @override
  List<Object?> get props => [];
}

class LoadElementsEvent extends ElementEvent {}
