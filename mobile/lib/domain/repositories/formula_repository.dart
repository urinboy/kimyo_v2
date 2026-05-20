import 'package:dartz/dartz.dart';
import '../entities/formula.dart';

abstract class FormulaRepository {
  Future<Either<Exception, List<FormulaEntity>>> getAllFormulas();
}
