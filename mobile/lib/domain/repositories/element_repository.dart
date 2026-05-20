import 'package:dartz/dartz.dart';

import '../entities/element.dart';

typedef ElementsOutcome = ({List<ElementEntity> elements, bool fromCache});

abstract class ElementRepository {
  Future<Either<Exception, ElementsOutcome>> getAllElements();
}
