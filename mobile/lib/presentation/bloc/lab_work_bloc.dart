import 'package:flutter_bloc/flutter_bloc.dart';
import 'lab_work_event.dart';
import 'lab_work_state.dart';
import '../../../domain/usecases/get_lab_works.dart';
import '../../../domain/usecases/get_lab_work_detail.dart';

class LabWorkBloc extends Bloc<LabWorkEvent, LabWorkState> {
  final GetLabWorksUseCase getLabWorks;
  final GetLabWorkDetailUseCase getLabWorkDetail;

  LabWorkBloc({
    required this.getLabWorks,
    required this.getLabWorkDetail,
  }) : super(LabWorkInitial()) {
    on<LoadLabWorksEvent>(_onLoadLabWorks);
    on<LoadLabWorkDetailEvent>(_onLoadDetail);
  }

  Future<void> _onLoadLabWorks(
    LoadLabWorksEvent event,
    Emitter<LabWorkState> emit,
  ) async {
    emit(LabWorkLoading());
    try {
      final labs = await getLabWorks(langCode: event.langCode);
      emit(LabWorksLoaded(labs));
    } catch (e) {
      emit(LabWorkError(e.toString()));
    }
  }

  Future<void> _onLoadDetail(
    LoadLabWorkDetailEvent event,
    Emitter<LabWorkState> emit,
  ) async {
    emit(LabWorkLoading());
    try {
      final lab = await getLabWorkDetail(event.id, langCode: event.langCode);
      emit(LabWorkDetailLoaded(lab));
    } catch (e) {
      emit(LabWorkError(e.toString()));
    }
  }
}
