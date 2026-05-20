import 'package:equatable/equatable.dart';

abstract class FormulaEvent extends Equatable {
  @override
  List<Object> get props => [];
}

class LoadFormulasEvent extends FormulaEvent {}
