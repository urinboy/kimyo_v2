import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/get_mines.dart';
import 'mine_event.dart';
import 'mine_state.dart';

class MineBloc extends Bloc<MineEvent, MineState> {
  final GetMinesUseCase getMines;

  MineBloc({required this.getMines}) : super(MineInitial()) {
    on<LoadMinesEvent>((event, emit) async {
      emit(MineLoading());
      final result = await getMines();
      result.fold(
        (failure) => emit(MineError(failure.toString())),
        (mines) => emit(MineLoaded(mines)),
      );
    });
  }
}
