import 'package:equatable/equatable.dart';
import '../../domain/entities/mine.dart';

abstract class MineEvent extends Equatable {
  const MineEvent();

  @override
  List<Object> get props => [];
}

class LoadMinesEvent extends MineEvent {}
