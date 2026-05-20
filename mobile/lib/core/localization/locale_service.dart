import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/toast_util.dart';

class LocaleService {
  static final LocaleService _instance = LocaleService._internal();
  factory LocaleService() => _instance;
  LocaleService._internal();

  final ValueNotifier<Locale> locale = ValueNotifier(const Locale('uz'));

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    final langCode = prefs.getString('language_code') ?? 'uz';
    locale.value = Locale(langCode);
  }

  Future<void> setLocale(String langCode) async {
    locale.value = Locale(langCode);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('language_code', langCode);

    ToastUtil.showInfo(_getLangMsg(langCode));
  }

  /// Birinchi marta til tanlash: toast ko'rsatilmaydi
  Future<void> setLocaleFromOnboarding(String langCode) async {
    locale.value = Locale(langCode);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('language_code', langCode);
  }

  String _getLangMsg(String langCode) {
    switch (langCode) {
      case 'ru': return 'Язык изменен';
      case 'en': return 'Language changed';
      default: return 'Til o\'zgartirildi';
    }
  }

  String get currentLanguageName {
    switch (locale.value.languageCode) {
      case 'ru': return 'Русский';
      case 'en': return 'English';
      default: return 'O\'zbek';
    }
  }
}
