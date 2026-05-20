import 'package:dio/dio.dart';
import '../models/user_model.dart';

class AuthResult {
  const AuthResult({required this.user, required this.token});

  final UserModel user;
  final String token;
}

/// Laravel API: `/api/v1/mobile/auth/*` (Dio [baseUrl] allaqachon `.../api/v1`)
abstract class AuthRemoteDataSource {
  Future<AuthResult> register({
    required String name,
    required String username,
    String? phone,
    required String district,
    required int schoolNumber,
    required String password,
    required String passwordConfirmation,
  });
  Future<AuthResult> login({required String login, required String password});
  Future<void> logout();
  Future<UserModel> me();
  Future<UserModel> updateProfile({
    required String name,
    String? phone,
    int? schoolId,
    String? grade,
  });

  Future<void> changePassword({
    required String currentPassword,
    required String password,
    required String passwordConfirmation,
  });
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  AuthRemoteDataSourceImpl({required this.dio});

  final Dio dio;

  @override
  Future<AuthResult> register({
    required String name,
    required String username,
    String? phone,
    required String district,
    required int schoolNumber,
    required String password,
    required String passwordConfirmation,
  }) async {
    final response = await dio.post(
      '/mobile/auth/register',
      data: <String, dynamic>{
        'name': name,
        'username': username,
        if (phone != null && phone.isNotEmpty) 'phone': phone,
        'district': district,
        'school_number': schoolNumber,
        'password': password,
        'password_confirmation': passwordConfirmation,
      },
    );
    if (response.statusCode == 201) {
      final d = _unwrap(response.data) as Map<String, dynamic>;
      return _fromAuthData(d);
    }
    throw StateError('register unexpected ${response.statusCode}');
  }

  @override
  Future<AuthResult> login({required String login, required String password}) async {
    final response = await dio.post(
      '/mobile/auth/login',
      data: {
        'login': login,
        'password': password,
      },
    );
    if (response.statusCode == 200) {
      final d = _unwrap(response.data) as Map<String, dynamic>;
      return _fromAuthData(d);
    }
    throw StateError('login unexpected ${response.statusCode}');
  }

  @override
  Future<void> logout() async {
    await dio.post('/mobile/auth/logout');
  }

  @override
  Future<UserModel> me() async {
    final response = await dio.get('/mobile/auth/me');
    if (response.statusCode == 200) {
      final d = _unwrap(response.data) as Map<String, dynamic>;
      return UserModel.fromJson(d['user'] as Map<String, dynamic>);
    }
    throw StateError('me unexpected ${response.statusCode}');
  }

  @override
  Future<UserModel> updateProfile({
    required String name,
    String? phone,
    int? schoolId,
    String? grade,
  }) async {
    final response = await dio.put(
      '/mobile/auth/profile',
      data: <String, dynamic>{
        'name': name,
        'phone': phone ?? '',
        'school_id': schoolId,
        'grade': grade,
      },
    );
    if (response.statusCode == 200) {
      final d = _unwrap(response.data) as Map<String, dynamic>;
      return UserModel.fromJson(d['user'] as Map<String, dynamic>);
    }
    throw StateError('updateProfile unexpected ${response.statusCode}');
  }

  @override
  Future<void> changePassword({
    required String currentPassword,
    required String password,
    required String passwordConfirmation,
  }) async {
    final response = await dio.put(
      '/mobile/auth/password',
      data: <String, dynamic>{
        'current_password': currentPassword,
        'password': password,
        'password_confirmation': passwordConfirmation,
      },
    );
    if (response.statusCode == 200) {
      final raw = response.data;
      if (raw is Map && raw['status'] == 'success') return;
    }
    throw StateError('changePassword unexpected ${response.statusCode}');
  }

  static dynamic _unwrap(dynamic raw) {
    if (raw is Map && raw['data'] != null) return raw['data'];
    return raw;
  }

  static AuthResult _fromAuthData(Map<String, dynamic> d) {
    return AuthResult(
      user: UserModel.fromJson(d['user'] as Map<String, dynamic>),
      token: d['token'] as String,
    );
  }
}

/// Login/register'dan keladigan foydalanuvchi xatolar
String? formatAuthDioError(DioException e) {
  final code = e.response?.statusCode;
  final data = e.response?.data;
  if (data is! Map) {
    if (e.type == DioExceptionType.connectionError ||
        e.type == DioExceptionType.connectionTimeout) {
      return null;
    }
    return e.message;
  }
  if (code == 401) {
    final inner = data['data'];
    if (inner is Map && inner['message'] is String) return inner['message'] as String;
  }
  if (code == 403) {
    final inner = data['data'];
    if (inner is Map && inner['message'] is String) return inner['message'] as String;
  }
  if (code == 400 || code == 422) {
    final inner = data['data'];
    if (inner is Map) {
      final parts = <String>[];
      for (final e in inner.entries) {
        final v = e.value;
        if (v is List) {
          parts.addAll(v.map((x) => x.toString()));
        } else {
          parts.add(v.toString());
        }
      }
      if (parts.isNotEmpty) return parts.join('\n');
    }
  }
  return e.message;
}
