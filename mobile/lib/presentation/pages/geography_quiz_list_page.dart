import 'package:flutter/material.dart';
import '../../core/theme/colors.dart';
import '../../core/localization/app_localizations.dart';
import 'quiz_page.dart';
import '../widgets/geography_topic_complete_bar.dart';

class GeographyQuizListPage extends StatelessWidget {
  const GeographyQuizListPage({super.key});

  static const List<Map<String, dynamic>> _quizzes = [
    {
      'id': 'siyosiy_xarita',
      'title': {
        'uz': 'Siyosiy xarita',
        'ru': 'Политическая карта',
        'en': 'Political map',
      },
      'questions': 10,
      'icon': Icons.map_rounded,
    },
    {
      'id': 'qitalar',
      'title': {
        'uz': 'Qit\'alar',
        'ru': 'Континенты',
        'en': 'Continents',
      },
      'questions': 10,
      'icon': Icons.public_rounded,
    },
    {
      'id': 'poytaxtlar',
      'title': {
        'uz': 'Poytaxtlar',
        'ru': 'Столицы',
        'en': 'Capitals',
      },
      'questions': 10,
      'icon': Icons.location_city_rounded,
    },
    {
      'id': 'iqlim_obhavo',
      'title': {
        'uz': 'Iqlim va ob-havo',
        'ru': 'Климат и погода',
        'en': 'Climate and weather',
      },
      'questions': 10,
      'icon': Icons.wb_sunny_outlined,
    },
    {
      'id': 'tog_jinslari',
      'title': {
        'uz': 'Tog\' jinslari',
        'ru': 'Горные породы',
        'en': 'Rocks & ranges',
      },
      'questions': 10,
      'icon': Icons.landscape_rounded,
    },
    {
      'id': 'foydali_qazilmalar',
      'title': {
        'uz': 'Foydali qazilmalar',
        'ru': 'Полезные ископаемые',
        'en': 'Mineral resources',
      },
      'questions': 10,
      'icon': Icons.diamond_outlined,
    },
    {
      'id': 'relyef_turlari',
      'title': {
        'uz': 'Relyef turlari',
        'ru': 'Виды рельефа',
        'en': 'Relief types',
      },
      'questions': 10,
      'icon': Icons.landscape_outlined,
    },
    {
      'id': 'tabiiy_hodisalar',
      'title': {
        'uz': 'Tabiiy hodisalar',
        'ru': 'Природные явления',
        'en': 'Natural phenomena',
      },
      'questions': 10,
      'icon': Icons.storm_outlined,
    },
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final lang = context.locale.languageCode;

    return Scaffold(
      backgroundColor: isDark ? AppColors.scaffoldBackgroundDark : const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: Text(context.tr('menu_quiz')),
        centerTitle: true,
        backgroundColor: AppColors.primaryCyan,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        itemCount: _quizzes.length + 1,
        itemBuilder: (context, index) {
          if (index == _quizzes.length) {
            return const GeographyTopicCompleteBar(
              topicId: 'geo_quizzes_hub',
              titleTrKey: 'menu_quiz',
              dense: true,
            );
          }
          return _buildQuizCard(
            context,
            _quizzes[index],
            isDark,
            lang,
          );
        },
      ),
    );
  }

  Widget _buildQuizCard(
    BuildContext context,
    Map<String, dynamic> quiz,
    bool isDark,
    String lang,
  ) {
    final title = (quiz['title'] as Map)[lang] as String? ??
        (quiz['title'] as Map)['uz'] as String;
    final questionCount = quiz['questions'] as int;

    final questionLabel = lang == 'ru'
        ? '$questionCount вопросов'
        : (lang == 'en' ? '$questionCount questions' : '$questionCount ta savol');

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => QuizPage(
              title: title,
              category: quiz['id'] as String,
            ),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: isDark ? AppColors.cardDark : Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: isDark
                  ? Colors.black.withValues(alpha:0.2)
                  : Colors.black.withValues(alpha:0.06),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: isDark
                      ? AppColors.primaryCyan.withValues(alpha:0.2)
                      : AppColors.primaryCyan.withValues(alpha:0.12),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  quiz['icon'] as IconData,
                  color: AppColors.primaryCyan,
                  size: 26,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: isDark ? Colors.white : AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      questionLabel,
                      style: TextStyle(
                        fontSize: 13,
                        color: isDark ? Colors.white54 : AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                color: isDark ? Colors.white38 : Colors.black38,
                size: 24,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
