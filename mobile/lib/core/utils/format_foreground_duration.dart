import 'package:flutter/widgets.dart';

import '../localization/app_localizations.dart';

/// Umumiy soniyalardan profil uchun qisqa yozuv (UZ/RU/EN kalitlari).
String formatForegroundDuration(BuildContext context, int totalSeconds) {
  if (totalSeconds <= 0) return context.tr('profile_activity_time_empty');

  final h = totalSeconds ~/ 3600;
  final m = (totalSeconds % 3600) ~/ 60;
  final s = totalSeconds % 60;

  if (h > 0) {
    if (m > 0) {
      return '$h ${context.tr('time_unit_hour')} $m ${context.tr('time_unit_minute')}';
    }
    return '$h ${context.tr('time_unit_hour')}';
  }
  if (m > 0) {
    return '$m ${context.tr('time_unit_minute')}';
  }
  return '$s ${context.tr('time_unit_second')}';
}
