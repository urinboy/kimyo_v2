import 'package:get_it/get_it.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'core/network/dio_client.dart';
import 'core/localization/locale_service.dart';
import 'core/theme/theme_service.dart';
import 'presentation/bloc/element_bloc.dart';
import 'presentation/bloc/lesson_bloc.dart';
import 'presentation/bloc/formula_bloc.dart';
import 'domain/usecases/get_elements.dart';
import 'domain/usecases/get_lessons.dart';
import 'domain/usecases/get_formulas.dart';
import 'domain/repositories/element_repository.dart';
import 'domain/repositories/lesson_repository.dart';
import 'domain/repositories/formula_repository.dart';
import 'data/repositories/element_repository_impl.dart';
import 'data/repositories/lesson_repository_impl.dart';
import 'data/repositories/formula_repository_impl.dart';
import 'data/datasources/element_remote_data_source.dart';
import 'data/datasources/element_local_data_source.dart';
import 'data/datasources/element_bundled_data_source.dart';
import 'data/datasources/lesson_remote_data_source.dart';
import 'data/datasources/lesson_local_provider.dart';
import 'data/datasources/formula_remote_data_source.dart';
import 'data/datasources/lesson_local_data_source.dart';

import 'presentation/bloc/mine_bloc.dart';
import 'domain/usecases/get_mines.dart';
import 'domain/repositories/mine_repository.dart';
import 'data/repositories/mine_repository_impl.dart';
import 'data/datasources/mine_remote_data_source.dart';
import 'data/datasources/auth_remote_data_source.dart';
import 'data/datasources/reference_remote_data_source.dart';
import 'data/datasources/document_remote_data_source.dart';
import 'data/datasources/chemical_reactions_remote_data_source.dart';
import 'core/auth/auth_session.dart';
import 'core/services/document_download_service.dart';
import 'core/services/app_foreground_time_service.dart';
import 'core/services/learning_progress_service.dart';

// Lab Works
import 'presentation/bloc/lab_work_bloc.dart';
import 'domain/usecases/get_lab_works.dart';
import 'domain/usecases/get_lab_work_detail.dart';
import 'domain/repositories/lab_work_repository.dart';
import 'data/repositories/lab_work_repository_impl.dart';
import 'data/datasources/lab_work_remote_datasource.dart';

final sl = GetIt.instance;

Future<void> init() async {
  //! Features
  // Bloc
  sl.registerFactory(() => ElementBloc(getElements: sl()));
  sl.registerFactory(() => LessonBloc(getLessons: sl()));
  sl.registerFactory(() => MineBloc(getMines: sl()));
  sl.registerFactory(() => FormulaBloc(getFormulas: sl()));
  sl.registerFactory(() => LabWorkBloc(
        getLabWorks: sl(),
        getLabWorkDetail: sl(),
      ));

  // Use cases
  sl.registerLazySingleton(() => GetElementsUseCase(sl()));
  sl.registerLazySingleton(() => GetLessonsUseCase(sl()));
  sl.registerLazySingleton(() => GetMinesUseCase(sl()));
  sl.registerLazySingleton(() => GetFormulasUseCase(sl()));
  sl.registerLazySingleton(() => GetLabWorksUseCase(sl()));
  sl.registerLazySingleton(() => GetLabWorkDetailUseCase(sl()));

  // Repository
  sl.registerLazySingleton<ElementRepository>(
    () => ElementRepositoryImpl(
          bundledDataSource: sl(),
          remoteDataSource: sl(),
          localDataSource: sl(),
        ),
  );
  sl.registerLazySingleton<LessonRepository>(
    () => LessonRepositoryImpl(
          remoteDataSource: sl(),
          localDataSource: sl(),
        ),
  );
  sl.registerLazySingleton<MineRepository>(
    () => MineRepositoryImpl(remoteDataSource: sl()),
  );
  sl.registerLazySingleton<FormulaRepository>(
    () => FormulaRepositoryImpl(remoteDataSource: sl()),
  );
  sl.registerLazySingleton<LabWorkRepository>(
    () => LabWorkRepositoryImpl(remoteDataSource: sl()),
  );

  // Data sources
  sl.registerLazySingleton<ElementBundledDataSource>(
    () => ElementBundledDataSourceImpl(),
  );
  sl.registerLazySingleton<ElementRemoteDataSource>(
    () => ElementRemoteDataSourceImpl(dio: sl<DioClient>().dio),
  );
  sl.registerLazySingleton<ElementLocalDataSource>(
    () => ElementLocalDataSourceImpl(),
  );
  sl.registerLazySingleton<LessonLocalDataSource>(() => createLessonLocalDataSource());
  sl.registerLazySingleton<LessonRemoteDataSource>(
    () => LessonRemoteDataSourceImpl(dio: sl<DioClient>().dio),
  );
  sl.registerLazySingleton<MineRemoteDataSource>(
    () => MineRemoteDataSourceImpl(dio: sl<DioClient>().dio),
  );
  sl.registerLazySingleton<FormulaRemoteDataSource>(
    () => FormulaRemoteDataSourceImpl(dio: sl<DioClient>().dio),
  );
  sl.registerLazySingleton<LabWorkRemoteDataSource>(
    () => LabWorkRemoteDataSourceImpl(dio: sl<DioClient>().dio),
  );
  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(dio: sl<DioClient>().dio),
  );
  sl.registerLazySingleton<ReferenceRemoteDataSource>(
    () => ReferenceRemoteDataSourceImpl(dio: sl<DioClient>().dio),
  );
  sl.registerLazySingleton<AuthSession>(
    () => AuthSession(
      prefs: sl(),
      dioClient: sl(),
      authRemote: sl(),
    ),
  );
  sl.registerLazySingleton<DocumentRemoteDataSource>(
    () => DocumentRemoteDataSourceImpl(dio: sl<DioClient>().dio),
  );
  sl.registerLazySingleton<DocumentDownloadService>(
    () => DocumentDownloadService(
      dio: sl<DioClient>().dio,
      prefs: sl(),
    ),
  );

  sl.registerLazySingleton<ChemicalReactionsRemoteDataSource>(
    () => ChemicalReactionsRemoteDataSourceImpl(dio: sl<DioClient>().dio),
  );

  //! Core
  sl.registerLazySingleton(() => DioClient(sl()));
  sl.registerLazySingleton(() => LocaleService());
  sl.registerLazySingleton(() => ThemeService());

  //! External
  final sharedPreferences = await SharedPreferences.getInstance();
  sl.registerLazySingleton(() => sharedPreferences);
  sl.registerLazySingleton<AppForegroundTimeService>(
    () => AppForegroundTimeService(prefs: sl()),
  );
  sl.registerLazySingleton<LearningProgressService>(
    () => LearningProgressService(prefs: sl()),
  );
  sl.registerLazySingleton(() => Dio());
}
