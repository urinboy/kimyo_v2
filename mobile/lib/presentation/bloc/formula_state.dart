import 'package:equatable/equatable.dart';
import '../../domain/entities/formula.dart';

abstract class FormulaState extends Equatable {
  @override
  List<Object> get props => [];
}

class FormulaInitial extends FormulaState {}

class FormulaLoading extends FormulaState {}

class FormulaLoaded extends FormulaState {
  final List<FormulaEntity> formulas;

  FormulaLoaded({required this.formulas});

  @override
  List<Object> get props => [formulas];
}

class FormulaError extends FormulaState {
  final String message;

  FormulaError({required this.message});

  @override
  List<Object> get props => [message];
}
