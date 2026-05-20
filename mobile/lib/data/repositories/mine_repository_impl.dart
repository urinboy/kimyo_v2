import 'package:dartz/dartz.dart';
import '../../domain/entities/mine.dart';
import '../../domain/repositories/mine_repository.dart';
import '../datasources/mine_remote_data_source.dart';

class MineRepositoryImpl implements MineRepository {
  final MineRemoteDataSource remoteDataSource;

  MineRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Exception, List<MineEntity>>> getAllMines() async {
    try {
      final remoteMines = await remoteDataSource.getAllMines();
      return Right(remoteMines);
    } catch (e) {
      return Left(Exception(e.toString()));
    }
  }
}
