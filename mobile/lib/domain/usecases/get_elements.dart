import 'package:dartz/dartz.dart';

import '../repositories/element_repository.dart';

class GetElementsUseCase {
  final ElementRepository repository;

  GetElementsUseCase(this.repository);

  Future<Either<Exception, ElementsOutcome>> call() async {
    return repository.getAllElements();
  }
}
