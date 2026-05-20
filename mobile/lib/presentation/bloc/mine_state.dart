import 'package:equatable/equatable.dart';
import '../../domain/entities/mine.dart';

abstract class MineState extends Equatable {
  const MineState();

  @override
  List<Object> get props => [];
}

class MineInitial extends MineState {}

class MineLoading extends MineState {}

class MineLoaded extends MineState {
  final List<MineEntity> mines;

  const MineLoaded(this.mines);

  @override
  List<Object> get props => [mines];
}

class MineError extends MineState {
  final String message;

  const MineError(this.message);

  @override
  List<Object> get props => [message];
}
