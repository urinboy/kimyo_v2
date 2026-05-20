import 'package:equatable/equatable.dart';
import '../../../domain/entities/lab_work.dart';

abstract class LabWorkState extends Equatable {
  const LabWorkState();

  @override
  List<Object?> get props => [];
}

class LabWorkInitial extends LabWorkState {
  const LabWorkInitial();
}

class LabWorkLoading extends LabWorkState {
  const LabWorkLoading();
}

class LabWorksLoaded extends LabWorkState {
  final List<LabWorkEntity> labWorks;
  const LabWorksLoaded(this.labWorks);

  @override
  List<Object?> get props => [labWorks];
}

class LabWorkDetailLoaded extends LabWorkState {
  final LabWorkEntity labWork;
  const LabWorkDetailLoaded(this.labWork);

  @override
  List<Object?> get props => [labWork];
}

class LabWorkError extends LabWorkState {
  final String message;
  const LabWorkError(this.message);

  @override
  List<Object?> get props => [message];
}
