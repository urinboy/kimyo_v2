import 'package:dartz/dartz.dart';
import '../../domain/entities/formula.dart';
import '../../domain/repositories/formula_repository.dart';
import '../datasources/formula_remote_data_source.dart';

class FormulaRepositoryImpl implements FormulaRepository {
  final FormulaRemoteDataSource remoteDataSource;

  FormulaRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Exception, List<FormulaEntity>>> getAllFormulas() async {
    try {
      final formulas = await remoteDataSource.getAllFormulas();
      return Right(formulas);
    } catch (e) {
      return Left(Exception(e.toString()));
    }
  }
}
