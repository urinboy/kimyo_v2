import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../data/datasources/auth_remote_data_source.dart';
import '../../data/models/user_model.dart';
import '../network/dio_client.dart';

class AuthSession extends ChangeNotifier {
  AuthSession({
    required this.prefs,
    required this.dioClient,
    required this.authRemote,
  });

  static const _kToken = 'auth_token';
  static const _kUserJson = 'auth_user_json';
  static const _kOnboardingLang = 'onboarding_lang_done';

  final SharedPreferences prefs;
  final DioClient dioClient;
  final AuthRemoteDataSource authRemote;

  String? _token;
  UserModel? _user;

  String? get token => _token;
  UserModel? get currentUser => _user;
  bool get isLoggedIn => _token != null;

  /// Til tanlash o'tkazilmagan foydalanuvchi — splash keyin alohida ekran
  bool get languageOnboardingDone {
    final explicit = prefs.getBool(_kOnboardingLang);
    if (explicit == true) return true;
    if (explicit == false) return false;
    if (_token != null) return true;
    // Eski o'rnatmalar: sozlamalarda allaqachon til saqlangan bo'lsa, onboardingni o'tkazamiz
    return prefs.getString('language_code') != null;
  }

  Future<void> load() async {
    _token = prefs.getString(_kToken);
    final u = prefs.getString(_kUserJson);
    if (u != null) {
      try {
        _user = UserModel.fromJson(
          Map<String, dynamic>.from(
            (jsonDecode(u) as Map).map((a, b) => MapEntry(a as String, b)),
          ),
        );
      } catch (_) {
        _user = null;
      }
    }
    if (_token != null) {
      dioClient.setAuthToken(_token!);
    } else {
      dioClient.clearAuthToken();
    }
  }

  /// Server tokenni yangilaydi
  Future<void> tryValidateOrClear() async {
    if (_token == null) return;
    try {
      _user = await authRemote.me();
      await _persistUser(_user!);
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        await _clearAllLocal();
      }
    } catch (_) {
      if (kDebugMode) rethrow;
    }
  }

  void markLanguageOnboardingComplete() {
    prefs.setBool(_kOnboardingLang, true);
    notifyListeners();
  }

  Future<void> updateProfile({
    required String name,
    String? phone,
    int? schoolId,
    String? grade,
  }) async {
    _user = await authRemote.updateProfile(
      name: name,
      phone: phone,
      schoolId: schoolId,
      grade: grade,
    );
    await _persistUser(_user!);
    notifyListeners();
  }

  Future<void> setSessionFromAuthResult(AuthResult r) async {
    _token = r.token;
    _user = r.user;
    await prefs.setString(_kToken, r.token);
    await _persistUser(r.user);
    dioClient.setAuthToken(r.token);
    notifyListeners();
  }

  Future<void> _persistUser(UserModel u) async {
    await prefs.setString(_kUserJson, jsonEncode(u.toJson()));
  }

  /// API logout + tozalash
  Future<void> signOut() async {
    if (_token != null) {
      try {
        await authRemote.logout();
      } on DioException catch (_) {
        // token eskirganda ham lokal tozalansin
      } catch (_) {}
    }
    await _clearAllLocal();
  }

  /// Faqat lokal
  Future<void> _clearAllLocal() async {
    _token = null;
    _user = null;
    await prefs.remove(_kToken);
    await prefs.remove(_kUserJson);
    dioClient.clearAuthToken();
    notifyListeners();
  }
}
