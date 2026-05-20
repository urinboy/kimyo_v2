import 'package:dio/dio.dart';

/// Mobil reference API — maktab va sinf ro'yxati (`/mobile/reference/*`).
class MobileSchoolListItem {
  const MobileSchoolListItem({
    required this.id,
    required this.name,
    this.shortName,
    this.city,
    this.region,
  });

  final int id;
  final String name;
  final String? shortName;
  final String? city;
  final String? region;

  String get displayLine {
    final b = StringBuffer(name.trim());
    final c = city?.trim();
    if (c != null && c.isNotEmpty) {
      b.write(' ($c)');
    }
    return b.toString();
  }

  factory MobileSchoolListItem.fromJson(Map<String, dynamic> json) {
    return MobileSchoolListItem(
      id: json['id'] is int ? json['id'] as int : int.parse('${json['id']}'),
      name: (json['name'] as String?)?.trim() ?? '',
      shortName: json['short_name'] as String?,
      city: json['city'] as String?,
      region: json['region'] as String?,
    );
  }
}

abstract class ReferenceRemoteDataSource {
  Future<List<MobileSchoolListItem>> fetchSchools();
  Future<List<String>> fetchGradeLabels();
  Future<MobileSchoolListItem> createSchool({
    required String name,
    String? city,
    String? shortName,
  });
  Future<String> createGradeLabel({required String label});
}

class ReferenceRemoteDataSourceImpl implements ReferenceRemoteDataSource {
  ReferenceRemoteDataSourceImpl({required this.dio});

  final Dio dio;

  static Map<String, dynamic> _unwrapData(dynamic raw) {
    if (raw is! Map) {
      throw StateError('JSend map kutilgan edi');
    }
    if (raw['status'] != 'success') {
      throw StateError('JSend status success emas');
    }
    final data = raw['data'];
    if (data is! Map<String, dynamic>) {
      throw StateError('JSend data map emas');
    }
    return data;
  }

  @override
  Future<List<MobileSchoolListItem>> fetchSchools() async {
    final res = await dio.get<Map<String, dynamic>>('/mobile/reference/schools');
    final data = _unwrapData(res.data);
    final list = data['schools'];
    if (list is! List) return [];
    return list
        .map((e) => MobileSchoolListItem.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList();
  }

  @override
  Future<List<String>> fetchGradeLabels() async {
    final res = await dio.get<Map<String, dynamic>>('/mobile/reference/grades');
    final data = _unwrapData(res.data);
    final list = data['grades'];
    if (list is! List) return [];
    final labels = <String>[];
    for (final e in list) {
      if (e is Map && e['label'] is String) {
        labels.add((e['label'] as String).trim());
      }
    }
    return labels;
  }

  @override
  Future<MobileSchoolListItem> createSchool({
    required String name,
    String? city,
    String? shortName,
  }) async {
    final res = await dio.post<Map<String, dynamic>>(
      '/mobile/reference/schools',
      data: <String, dynamic>{
        'name': name,
        if (city != null && city.isNotEmpty) 'city': city,
        if (shortName != null && shortName.isNotEmpty) 'short_name': shortName,
        'is_active': true,
      },
    );
    if (res.statusCode == 201) {
      final data = _unwrapData(res.data);
      final school = data['school'];
      if (school is Map<String, dynamic>) {
        return MobileSchoolListItem.fromJson(school);
      }
    }
    throw StateError('createSchool unexpected ${res.statusCode}');
  }

  @override
  Future<String> createGradeLabel({required String label}) async {
    final res = await dio.post<Map<String, dynamic>>(
      '/mobile/reference/grades',
      data: <String, dynamic>{'label': label.trim()},
    );
    if (res.statusCode == 201) {
      final data = _unwrapData(res.data);
      final g = data['grade'];
      if (g is Map && g['label'] is String) {
        return (g['label'] as String).trim();
      }
    }
    throw StateError('createGrade unexpected ${res.statusCode}');
  }
}
