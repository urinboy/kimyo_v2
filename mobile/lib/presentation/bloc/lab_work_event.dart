import 'package:equatable/equatable.dart';

abstract class LabWorkEvent extends Equatable {
  const LabWorkEvent();

  @override
  List<Object?> get props => [];
}

class LoadLabWorksEvent extends LabWorkEvent {
  final String? langCode;
  const LoadLabWorksEvent({this.langCode});

  @override
  List<Object?> get props => [langCode];
}

class LoadLabWorkDetailEvent extends LabWorkEvent {
  final int id;
  final String? langCode;
  const LoadLabWorkDetailEvent(this.id, {this.langCode});

  @override
  List<Object?> get props => [id, langCode];
}
