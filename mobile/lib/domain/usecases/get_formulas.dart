import 'package:dartz/dartz.dart';
import '../entities/formula.dart';
import '../repositories/formula_repository.dart';

class GetFormulasUseCase {
  final FormulaRepository repository;

  GetFormulasUseCase(this.repository);

  Future<Either<Exception, List<FormulaEntity>>> call() async {
    return await repository.getAllFormulas();
  }
}
