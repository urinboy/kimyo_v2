import 'package:dartz/dartz.dart';
import '../entities/mine.dart';

abstract class MineRepository {
  Future<Either<Exception, List<MineEntity>>> getAllMines();
}
