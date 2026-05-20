import 'lesson_local_data_source.dart';
import 'lesson_local_data_source_io.dart' if (dart.library.html) 'lesson_local_data_source_web.dart';

LessonLocalDataSource createLessonLocalDataSource() => LessonLocalDataSourceImpl();
