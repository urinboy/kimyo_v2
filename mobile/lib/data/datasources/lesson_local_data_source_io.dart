import 'dart:convert';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

import '../models/lesson_model.dart';
import 'lesson_local_data_source.dart';

class LessonLocalDataSourceImpl implements LessonLocalDataSource {
  Database? _db;

  Future<Database> _database() async {
    if (_db != null) return _db!;
    final dir = await getApplicationSupportDirectory();
    final path = p.join(dir.path, 'lessons_offline.db');
    _db = await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
CREATE TABLE lessons (
  id INTEGER PRIMARY KEY NOT NULL,
  sort_order INTEGER NOT NULL,
  payload TEXT NOT NULL,
  synced_at INTEGER NOT NULL
)
''');
      },
    );
    return _db!;
  }

  @override
  Future<void> replaceAll(List<LessonModel> lessons) async {
    final db = await _database();
    final batch = db.batch();
    batch.delete('lessons');
    if (lessons.isEmpty) {
      await batch.commit(noResult: true);
      return;
    }
    final now = DateTime.now().millisecondsSinceEpoch;
    for (final l in lessons) {
      batch.insert(
        'lessons',
        {
          'id': l.id,
          'sort_order': l.order,
          'payload': jsonEncode(l.toJson()),
          'synced_at': now,
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
    await batch.commit(noResult: true);
  }

  @override
  Future<void> upsertLesson(LessonModel lesson) async {
    final db = await _database();
    await db.insert(
      'lessons',
      {
        'id': lesson.id,
        'sort_order': lesson.order,
        'payload': jsonEncode(lesson.toJson()),
        'synced_at': DateTime.now().millisecondsSinceEpoch,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  @override
  Future<List<LessonModel>?> loadAllOrdered() async {
    final db = await _database();
    final rows = await db.query('lessons', orderBy: 'sort_order ASC');
    if (rows.isEmpty) return null;
    try {
      return rows
          .map((r) => LessonModel.fromJson(jsonDecode(r['payload']! as String) as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return null;
    }
  }

  @override
  Future<LessonModel?> loadOne(int id) async {
    final db = await _database();
    final rows = await db.query('lessons', where: 'id = ?', whereArgs: [id], limit: 1);
    if (rows.isEmpty) return null;
    try {
      return LessonModel.fromJson(jsonDecode(rows.first['payload']! as String) as Map<String, dynamic>);
    } catch (_) {
      return null;
    }
  }
}
