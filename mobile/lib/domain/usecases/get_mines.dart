import 'package:dartz/dartz.dart';
import '../entities/mine.dart';
import '../repositories/mine_repository.dart';

class GetMinesUseCase {
  final MineRepository repository;

  GetMinesUseCase(this.repository);

  Future<Either<Exception, List<MineEntity>>> call() async {
    return await repository.getAllMines();
  }
}
