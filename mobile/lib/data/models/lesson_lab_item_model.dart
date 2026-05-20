import '../../domain/entities/lesson_lab_item.dart';

class LessonLabItemModel extends LessonLabItemEntity {
  const LessonLabItemModel({
    required super.id,
    required super.lessonId,
    required super.category,
    required super.name,
    super.formula,
    super.quantity,
    super.unit,
    super.notes,
    required super.sortOrder,
    required super.isRequired,
    required super.isActive,
  });

  factory LessonLabItemModel.fromJson(Map<String, dynamic> json) {
    return LessonLabItemModel(
      id: json['id'] is String ? int.parse(json['id']) : json['id'],
      lessonId: json['lesson_id'] is String
          ? int.parse(json['lesson_id'])
          : json['lesson_id'],
      category: json['category'] ?? 'equipment',
      name: json['name'] ?? '',
      formula: json['formula'] as String?,
      quantity: json['quantity'] as String?,
      unit: json['unit'] as String?,
      notes: json['notes'] as String?,
      sortOrder: json['sort_order'] is String
          ? int.parse(json['sort_order'])
          : (json['sort_order'] ?? 0),
      isRequired:
          json['is_required'] == 1 || json['is_required'] == true || json['is_required'] == '1',
      isActive:
          json['is_active'] == 1 || json['is_active'] == true || json['is_active'] == '1',
    );
  }
}
