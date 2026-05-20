import 'package:equatable/equatable.dart';

class LessonLabItemEntity extends Equatable {
  final int id;
  final int lessonId;
  final String category; // equipment | reagent | element | vessel
  final String name;
  final String? formula;
  final String? quantity;
  final String? unit;
  final String? notes;
  final int sortOrder;
  final bool isRequired;
  final bool isActive;

  const LessonLabItemEntity({
    required this.id,
    required this.lessonId,
    required this.category,
    required this.name,
    this.formula,
    this.quantity,
    this.unit,
    this.notes,
    required this.sortOrder,
    required this.isRequired,
    required this.isActive,
  });

  @override
  List<Object?> get props => [
        id,
        lessonId,
        category,
        name,
        formula,
        quantity,
        unit,
        notes,
        sortOrder,
        isRequired,
        isActive,
      ];
}
