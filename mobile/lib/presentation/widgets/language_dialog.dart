import 'package:flutter/material.dart';
import '../../core/localization/locale_service.dart';
import '../../core/localization/app_localizations.dart';
import '../../core/theme/colors.dart';
import 'language_flag.dart';

class LanguageDialog extends StatelessWidget {
  const LanguageDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final currentLang = LocaleService().locale.value.languageCode;

    return AlertDialog(
      backgroundColor: isDark ? AppColors.cardDark : Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      title: Text(
        context.tr('lang_select'),
        style: TextStyle(
          color: isDark ? Colors.white : AppColors.textPrimary,
          fontWeight: FontWeight.bold,
          fontSize: 20,
        ),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildLanguageOption(context, 'O\'zbek', 'uz', currentLang, isDark),
          _buildLanguageOption(context, 'Русский', 'ru', currentLang, isDark),
          _buildLanguageOption(context, 'English', 'en', currentLang, isDark),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(
            context.tr('cancel'),
            style: TextStyle(
              color: AppColors.activeBlue,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLanguageOption(
    BuildContext context,
    String name,
    String code,
    String currentCode,
    bool isDark,
  ) {
    final isSelected = code == currentCode;

    return InkWell(
      onTap: () {
        LocaleService().setLocale(code);
        Navigator.pop(context);
      },
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
        child: Row(
          children: [
            LanguageFlag(
              langCode: code,
              width: 32,
              height: 22,
              borderRadius: BorderRadius.circular(3),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                name,
                style: TextStyle(
                  fontSize: 16,
                  color: isDark ? Colors.white : AppColors.textPrimary,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ),
            if (isSelected)
              Icon(Icons.check_circle_rounded, color: AppColors.activeBlue, size: 22),
          ],
        ),
      ),
    );
  }
}
