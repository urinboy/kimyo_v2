import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/get_three_d_models.dart';
import '../../domain/usecases/get_three_d_model_detail.dart';
import 'three_d_model_event.dart';
import 'three_d_model_state.dart';

class ThreeDModelBloc extends Bloc<ThreeDModelEvent, ThreeDModelState> {
  final GetThreeDModelsUseCase getThreeDModels;
  final GetThreeDModelDetailUseCase getThreeDModelDetail;

  ThreeDModelBloc({
    required this.getThreeDModels,
    required this.getThreeDModelDetail,
  }) : super(const ThreeDModelInitial()) {
    on<LoadThreeDModelsEvent>(_onLoadModels);
    on<LoadThreeDModelDetailEvent>(_onLoadDetail);
  }

  Future<void> _onLoadModels(LoadThreeDModelsEvent event, Emitter<ThreeDModelState> emit) async {
    emit(const ThreeDModelLoading());
    try {
      final list = await getThreeDModels(langCode: event.langCode);
      emit(ThreeDModelsLoaded(list));
    } catch (e) {
      emit(ThreeDModelError(e.toString()));
    }
  }

  Future<void> _onLoadDetail(LoadThreeDModelDetailEvent event, Emitter<ThreeDModelState> emit) async {
    emit(const ThreeDModelLoading());
    try {
      final model = await getThreeDModelDetail(event.id, langCode: event.langCode);
      emit(ThreeDModelDetailLoaded(model));
    } catch (e) {
      emit(ThreeDModelError(e.toString()));
    }
  }
}
