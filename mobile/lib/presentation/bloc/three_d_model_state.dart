import 'package:equatable/equatable.dart';
import '../../domain/entities/three_d_model.dart';

abstract class ThreeDModelState extends Equatable {
  const ThreeDModelState();
  @override
  List<Object?> get props => [];
}

class ThreeDModelInitial extends ThreeDModelState {
  const ThreeDModelInitial();
}

class ThreeDModelLoading extends ThreeDModelState {
  const ThreeDModelLoading();
}

class ThreeDModelsLoaded extends ThreeDModelState {
  final List<ThreeDModelEntity> models;
  const ThreeDModelsLoaded(this.models);
  @override
  List<Object?> get props => [models];
}

class ThreeDModelDetailLoaded extends ThreeDModelState {
  final ThreeDModelEntity model;
  const ThreeDModelDetailLoaded(this.model);
  @override
  List<Object?> get props => [model];
}

class ThreeDModelError extends ThreeDModelState {
  final String message;
  const ThreeDModelError(this.message);
  @override
  List<Object?> get props => [message];
}
