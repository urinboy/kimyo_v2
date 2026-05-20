import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/get_formulas.dart';
import 'formula_event.dart';
import 'formula_state.dart';

class FormulaBloc extends Bloc<FormulaEvent, FormulaState> {
  final GetFormulasUseCase getFormulas;

  FormulaBloc({required this.getFormulas}) : super(FormulaInitial()) {
    on<LoadFormulasEvent>((event, emit) async {
      emit(FormulaLoading());
      final result = await getFormulas();
      result.fold(
        (error) => emit(FormulaError(message: error.toString())),
        (formulas) => emit(FormulaLoaded(formulas: formulas)),
      );
    });
  }
}
