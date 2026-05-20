import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../injection_container.dart';
import '../bloc/lesson_bloc.dart';
import '../bloc/lesson_event.dart';
import '../bloc/lesson_state.dart';
import '../../core/theme/colors.dart';
import '../../core/localization/app_localizations.dart';
import '../../domain/entities/lesson.dart';
import '../../core/utils/lesson_content_preview.dart';
import 'lesson_details_page.dart';

class LessonsPage extends StatelessWidget {
  final String type;

  const LessonsPage({super.key, required this.type});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    String appBarTitle = '';
    IconData typeIcon = Icons.book_outlined;

    if (type == 'theory') {
      appBarTitle = context.tr('menu_theory');
      typeIcon = Icons.bubble_chart_rounded;
    } else if (type == 'lab') {
      appBarTitle = context.tr('menu_lab');
      typeIcon = Icons.science_rounded;
    }

    return BlocProvider(
      create: (_) => sl<LessonBloc>()..add(LoadLessonsEvent()),
      child: Scaffold(
        appBar: AppBar(
          title: Text(appBarTitle),
          centerTitle: true,
        ),
        body: BlocBuilder<LessonBloc, LessonState>(
          builder: (context, state) {
            if (state is LessonLoading) {
              return const Center(child: CircularProgressIndicator(color: AppColors.primaryPurple));
            } else if (state is LessonLoaded) {
              final filteredLessons = state.lessons.where((l) => l.type == type).toList();
              
              if (filteredLessons.isEmpty) {
                return Center(child: Text(context.tr('no_results')));
              }

              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: filteredLessons.length,
                itemBuilder: (context, index) {
                  final lesson = filteredLessons[index];
                  final title = lesson.getTitle(context.locale.languageCode).toLowerCase();
                  
                  IconData lessonIcon = typeIcon;
                  Color iconBgColor = isDark ? AppColors.iconBackgroundDark : AppColors.iconBackground;

                  if (title.contains('atom')) lessonIcon = Icons.bubble_chart_rounded;
                  else if (title.contains('bog\'lanish') || title.contains('связь') || title.contains('bonding')) lessonIcon = Icons.link_rounded;
                  else if (title.contains('valent')) lessonIcon = Icons.format_list_numbered_rounded;
                  else if (title.contains('oksidlanish') || title.contains('окисления') || title.contains('oxidation')) lessonIcon = Icons.trending_up_rounded;
                  else if (title.contains('kislota') || title.contains('кислот') || title.contains('acid')) lessonIcon = Icons.science_rounded;
                  else if (title.contains('asos') || title.contains('основан') || title.contains('base')) lessonIcon = Icons.water_drop_rounded;
                  else if (title.contains('tuzlar eritmalari') || title.contains('растворы солей') || title.contains('salt solutions')) {
                    lessonIcon = Icons.science_rounded;
                    if (!isDark) iconBgColor = const Color(0xFFFFEBEE); 
                  }
                  else if (title.contains('natriy') || title.contains('натрий') || title.contains('sodium')) {
                    lessonIcon = Icons.science_rounded;
                    if (!isDark) iconBgColor = const Color(0xFFFFF9C4); 
                  }
                  else if (title.contains('metallar namunalari') || title.contains('образцов металлов') || title.contains('metal samples')) {
                    lessonIcon = Icons.science_rounded;
                    if (!isDark) iconBgColor = const Color(0xFFE0F2F1); 
                  }
                  else if (title.contains('vodorod') || title.contains('водород') || title.contains('hydrogen')) {
                    lessonIcon = Icons.science_rounded;
                    if (!isDark) iconBgColor = const Color(0xFFE3F2FD); 
                  }
                  else if (title.contains('kislorod') || title.contains('кислород') || title.contains('oxygen')) {
                    lessonIcon = Icons.science_rounded;
                    if (!isDark) iconBgColor = const Color(0xFFE3F2FD); 
                  }
                  else if (title.contains('karbonat') || title.contains('карбонат') || title.contains('carbon')) {
                    lessonIcon = Icons.science_rounded;
                    if (!isDark) iconBgColor = const Color(0xFFF5F5F5); 
                  }
                  else if (title.contains('ammiak') || title.contains('аммиак') || title.contains('ammonia')) {
                    lessonIcon = Icons.science_rounded;
                    if (!isDark) iconBgColor = const Color(0xFFE8F5E9); 
                  }
                  else if (title.contains('mis sulfat') || title.contains('медного купороса') || title.contains('copper sulfate')) {
                    lessonIcon = Icons.science_rounded;
                    if (!isDark) iconBgColor = const Color(0xFFE1F5FE); 
                  }
                  else if (title.contains('neytrallanish') || title.contains('нейтрализация') || title.contains('neutralization')) {
                    lessonIcon = Icons.science_rounded;
                    if (!isDark) iconBgColor = const Color(0xFFF3E5F5); 
                  }
                  else if (title.contains('temir') || title.contains('желез') || title.contains('iron')) {
                    lessonIcon = Icons.science_rounded;
                    if (!isDark) iconBgColor = const Color(0xFFFFF3E0); 
                  }
                  else if (title.contains('kraxmal') || title.contains('крахмал') || title.contains('starch')) {
                    lessonIcon = Icons.science_rounded;
                    if (!isDark) iconBgColor = const Color(0xFFE8EAF6); 
                  }
                  else if (title.contains('ishqoriy metallar') || title.contains('щелочные металлы') || title.contains('alkali metals')) {
                    lessonIcon = Icons.auto_awesome_rounded;
                  }
                  else if (title.contains('tuz') || title.contains('сол') || title.contains('salt')) lessonIcon = Icons.grid_view_rounded;
                  else if (title.contains('oksid') || title.contains('оксид') || title.contains('oxide')) lessonIcon = Icons.radio_button_unchecked_rounded;
                  else if (title.contains('dissotsiatsiya') || title.contains('диссоциация') || title.contains('dissociation')) lessonIcon = Icons.tune_rounded;

                  return _buildLessonCard(context, lesson, lessonIcon, isDark, iconBgColor);
                },
              );
            } else if (state is LessonError) {
              return Center(child: Text('Xatolik: ${state.message}'));
            }
            return const SizedBox();
          },
        ),
      ),
    );
  }

  Widget _buildLessonCard(BuildContext context, LessonEntity lesson, IconData icon, bool isDark, Color iconBgColor) {
    final preview =
        lessonContentPreview(lesson.getContent(context.locale.languageCode));

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: isDark ? Colors.black.withOpacity(0.2) : Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => LessonDetailsPage(lesson: lesson),
            ),
          );
        },
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 54,
                height: 54,
                decoration: BoxDecoration(
                  color: iconBgColor,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(icon, color: AppColors.primaryPurple, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      lesson.getTitle(context.locale.languageCode),
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: isDark ? Colors.white : AppColors.textPrimary,
                      ),
                    ),
                    if (preview.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        preview,
                        style: TextStyle(
                          fontSize: 12,
                          height: 1.35,
                          color: isDark ? Colors.white54 : AppColors.textSecondary,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                color: isDark ? Colors.white24 : AppColors.textSecondary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
