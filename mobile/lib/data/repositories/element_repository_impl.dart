import 'package:dartz/dartz.dart';

import '../../domain/repositories/element_repository.dart';
import '../datasources/element_bundled_data_source.dart';
import '../datasources/element_local_data_source.dart';
import '../datasources/element_remote_data_source.dart';

class ElementRepositoryImpl implements ElementRepository {
  final ElementBundledDataSource bundledDataSource;
  final ElementRemoteDataSource remoteDataSource;
  final ElementLocalDataSource localDataSource;

  ElementRepositoryImpl({
    required this.bundledDataSource,
    required this.remoteDataSource,
    required this.localDataSource,
  });

  @override
  Future<Either<Exception, ElementsOutcome>> getAllElements() async {
    try {
      final bundled = await bundledDataSource.loadBundledElements();
      if (bundled.isNotEmpty) {
        return Right((elements: bundled, fromCache: false));
      }
    } catch (_) {
      // Asset yo‘q / buzilgan — quyida API va disk kesh.
    }

    try {
      final elements = await remoteDataSource.getAllElements();
      await localDataSource.saveElements(elements);
      return Right((elements: elements, fromCache: false));
    } catch (e) {
      final cached = await localDataSource.loadElements();
      if (cached != null && cached.isNotEmpty) {
        return Right((elements: cached, fromCache: true));
      }
      return Left(Exception(_userReadableError(e)));
    }
  }

  String _userReadableError(Object e) {
    final s = e.toString();
    if (s.contains('SocketException') || s.contains('Network')) {
      return 'Internet aloqasi yo‘q. Maʼlumotlar yuklanmadi va qurilmada saqlangan nusxa ham topilmadi.';
    }
    return s.replaceFirst('Exception: ', '').replaceFirst('DioException [unknown]: ', '');
  }
}
