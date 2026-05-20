import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Yuklash / geografiya mavzusi tugatilgani va faollik jurnalidagi yozuvlar.
class LearningProgressService extends ChangeNotifier {
  LearningProgressService({required this.prefs}) {
    _restore();
  }

  final SharedPreferences prefs;

  static const _kChem = 'learning_chem_completed_ids';
  static const _kGeo = 'learning_geo_completed_ids';
  static const _kLog = 'learning_activity_log_v1';

  final Set<int> _chemistryLessonIds = {};
  final Set<String> _geographyTopicIds = {};
  final List<StudyActivityRecord> _log = [];

  static const maxLogEntries = 50;

  int get chemistryCompletedCount => _chemistryLessonIds.length;
  int get geographyCompletedCount => _geographyTopicIds.length;

  /// Jami yakunlangan “dars” (Kimyo API darslari + geografiya mavzulari).
  int get totalCompletedCount =>
      chemistryCompletedCount + geographyCompletedCount;

  List<StudyActivityRecord> get activityLogNewestFirst =>
      List<StudyActivityRecord>.unmodifiable(_log.reversed);

  bool isChemistryComplete(int lessonId) =>
      _chemistryLessonIds.contains(lessonId);
  bool isGeographyTopicComplete(String topicId) =>
      _geographyTopicIds.contains(topicId);

  /// Birinchi marta yakunlangan bo‘lsa `true`.
  bool tryCompleteChemistryLesson(int lessonId, String localizedTitle) {
    if (!_chemistryLessonIds.add(lessonId)) return false;
    _pushLog(kind: StudyActivityKind.chemistry, title: localizedTitle);
    _persistChem();
    _persistLog();
    notifyListeners();
    return true;
  }

  bool tryCompleteGeographyTopic(String topicId, String localizedTitle) {
    if (!_geographyTopicIds.add(topicId)) return false;
    _pushLog(kind: StudyActivityKind.geography, title: localizedTitle);
    _persistGeo();
    _persistLog();
    notifyListeners();
    return true;
  }

  void _pushLog({
    required StudyActivityKind kind,
    required String title,
  }) {
    final record = StudyActivityRecord(
      at: DateTime.now().toUtc(),
      kind: kind,
      title: title,
    );
    _log.add(record);
    while (_log.length > maxLogEntries) {
      _log.removeAt(0);
    }
  }

  void _restore() {
    _restoreIntSet(_kChem, _chemistryLessonIds);
    _restoreStringSet(_kGeo, _geographyTopicIds);
    final raw = prefs.getString(_kLog);
    if (raw == null || raw.isEmpty) return;
    try {
      final list = jsonDecode(raw) as List<dynamic>;
      _log.clear();
      for (final item in list) {
        final m = item as Map<String, dynamic>;
        _log.add(StudyActivityRecord.fromJson(m));
      }
    } catch (_) {
      _log.clear();
    }
  }

  void _restoreIntSet(String key, Set<int> out) {
    out.clear();
    final s = prefs.getString(key);
    if (s == null || s.isEmpty) return;
    for (final part in s.split(',')) {
      final v = int.tryParse(part.trim());
      if (v != null) out.add(v);
    }
  }

  void _restoreStringSet(String key, Set<String> out) {
    out.clear();
    final s = prefs.getString(key);
    if (s == null || s.isEmpty) return;
    for (final part in s.split(',')) {
      final t = part.trim();
      if (t.isNotEmpty) out.add(t);
    }
  }

  void _persistChem() =>
      prefs.setString(_kChem, _chemistryLessonIds.join(','));
  void _persistGeo() =>
      prefs.setString(_kGeo, _geographyTopicIds.join(','));

  void _persistLog() {
    final encoded = jsonEncode(_log.map((e) => e.toJson()).toList());
    prefs.setString(_kLog, encoded);
  }

  bool get achievementFirstLessonUnlocked => totalCompletedCount >= 1;
  bool get achievementChemistry10Unlocked => chemistryCompletedCount >= 10;
  bool get achievementGeography10Unlocked => geographyCompletedCount >= 10;
  bool get achievementStudent50Unlocked => totalCompletedCount >= 50;
  bool get achievementChampion100Unlocked => totalCompletedCount >= 100;
}

enum StudyActivityKind { chemistry, geography }

class StudyActivityRecord {
  const StudyActivityRecord({
    required this.at,
    required this.kind,
    required this.title,
  });

  final DateTime at;
  final StudyActivityKind kind;
  final String title;

  Map<String, dynamic> toJson() => {
        'at': at.toIso8601String(),
        'kind': kind.name,
        'title': title,
      };

  factory StudyActivityRecord.fromJson(Map<String, dynamic> m) {
    return StudyActivityRecord(
      at: DateTime.tryParse(m['at'] as String? ?? '')?.toUtc() ??
          DateTime.fromMillisecondsSinceEpoch(0, isUtc: true),
      kind: StudyActivityKind.values.firstWhere(
        (v) => v.name == (m['kind'] as String?),
        orElse: () => StudyActivityKind.chemistry,
      ),
      title: m['title'] as String? ?? '',
    );
  }
}
