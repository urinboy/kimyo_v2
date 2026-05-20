import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/usecases/get_elements.dart';
import 'element_event.dart';
import 'element_state.dart';

class ElementBloc extends Bloc<ElementEvent, ElementState> {
  final GetElementsUseCase getElements;

  ElementBloc({required this.getElements}) : super(ElementInitial()) {
    on<LoadElementsEvent>((event, emit) async {
      emit(ElementLoading());
      final result = await getElements();
      result.fold(
        (failure) => emit(ElementError(failure.toString())),
        (outcome) => emit(ElementLoaded(outcome.elements, fromCache: outcome.fromCache)),
      );
    });
  }
}
