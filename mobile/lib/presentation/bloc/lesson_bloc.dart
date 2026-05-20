import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/get_lessons.dart';
import 'lesson_event.dart';
import 'lesson_state.dart';

class LessonBloc extends Bloc<LessonEvent, LessonState> {
  final GetLessonsUseCase getLessons;

  LessonBloc({required this.getLessons}) : super(LessonInitial()) {
    on<LoadLessonsEvent>((event, emit) async {
      emit(LessonLoading());
      final result = await getLessons();
      result.fold(
        (failure) => emit(LessonError(failure.toString())),
        (lessons) => emit(LessonLoaded(lessons)),
      );
    });
  }
}
