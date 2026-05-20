import 'package:flutter/material.dart';
import '../localization/app_localizations.dart';
import '../localization/locale_service.dart';
import '../utils/toast_util.dart';

class ThemeService {
  static final ThemeService _instance = ThemeService._internal();
  factory ThemeService() => _instance;
  ThemeService._internal();

  final ValueNotifier<ThemeMode> themeMode = ValueNotifier(ThemeMode.light);

  void toggleTheme(bool isDark) {
    themeMode.value = isDark ? ThemeMode.dark : ThemeMode.light;
    
    ToastUtil.showInfo(
      isDark ? _getThemeMsg(true) : _getThemeMsg(false),
      isDark: isDark,
    );
  }

  String _getThemeMsg(bool isDark) {
    final langCode = LocaleService().locale.value.languageCode;
    if (isDark) {
      switch (langCode) {
        case 'ru': return 'Темная тема включена';
        case 'en': return 'Dark mode enabled';
        default: return 'Qorong\'i tema yoqildi';
      }
    } else {
      switch (langCode) {
        case 'ru': return 'Светлая тема включена';
        case 'en': return 'Light mode enabled';
        default: return 'Yorug\' tema yoqildi';
      }
    }
  }
}
