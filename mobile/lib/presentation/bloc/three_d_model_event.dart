import 'package:equatable/equatable.dart';

abstract class ThreeDModelEvent extends Equatable {
  const ThreeDModelEvent();
  @override
  List<Object?> get props => [];
}

class LoadThreeDModelsEvent extends ThreeDModelEvent {
  final String? langCode;
  const LoadThreeDModelsEvent({this.langCode});
  @override
  List<Object?> get props => [langCode];
}

class LoadThreeDModelDetailEvent extends ThreeDModelEvent {
  final int id;
  final String? langCode;
  const LoadThreeDModelDetailEvent(this.id, {this.langCode});
  @override
  List<Object?> get props => [id, langCode];
}
