import 'package:flutter/widgets.dart';

import '../localization/app_localizations.dart';

/// Ishlab chiqarish tarixini qarshi yozuv uchun: Bugun HH:mm / Kecha HH:mm / N kun oldin.
String formatRelativeActivitySubtitle(BuildContext context, DateTime atUtc) {
  final lang = Localizations.localeOf(context).languageCode;
  final local = atUtc.toLocal();
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final day = DateTime(local.year, local.month, local.day);
  final diffDays = today.difference(day).inDays;

  String twoDig(int v) => v.toString().padLeft(2, '0');
  final timeStr = '${twoDig(local.hour)}:${twoDig(local.minute)}';

  if (diffDays <= 0) {
    return '${context.tr('activity_when_today')}, $timeStr';
  }
  if (diffDays == 1) {
    return '${context.tr('activity_when_yesterday')}, $timeStr';
  }

  switch (lang) {
    case 'ru':
      return _ruDaysAgo(diffDays);
    case 'en':
      return diffDays == 1 ? '1 day ago' : '$diffDays days ago';
    default:
      return '$diffDays ${context.tr('activity_days_ago_suffix')}';
  }
}

String _ruDaysAgo(int n) {
  final mod10 = n % 10;
  final mod100 = n % 100;
  String word;
  if (mod100 >= 11 && mod100 <= 14) {
    word = 'дней назад';
  } else if (mod10 == 1) {
    word = 'день назад';
  } else if (mod10 >= 2 && mod10 <= 4) {
    word = 'дня назад';
  } else {
    word = 'дней назад';
  }
  return '$n $word';
}
