import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/theme/colors.dart';
import '../../core/localization/app_localizations.dart';
import '../../injection_container.dart';
import '../bloc/lab_work_bloc.dart';
import '../widgets/module_menu_list_cards.dart';
import 'element_info_page.dart';
import 'alkali_metals_list_page.dart';
import 'periodic_table_page.dart';
import 'formula_calculator_page.dart';
import 'lessons_page.dart';
import 'chemical_reactions_page.dart';
import 'quiz_list_page.dart';
import 'interesting_tasks_page.dart';
import 'natural_resources_map_page.dart';
import 'regional_minerals_page.dart';
import 'lab_works_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  /// Geografiya bilan bir xil kartochka tuzilishi; ranglar Kimyo (binafsha) brendi.
  static const _accent = AppColors.primaryPurple;
  static const _iconBg = AppColors.iconBackground;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor:
          isDark ? AppColors.scaffoldBackgroundDark : AppColors.scaffoldBackground,
      appBar: AppBar(
        title: Text(context.tr('tab_kimyo')),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ModuleExpandableListCard(
            title: context.tr('menu_elements'),
            icon: Icons.grid_view_rounded,
            accentColor: _accent,
            iconBackgroundLight: _iconBg,
            children: [
              ModuleMenuSubItem(
                title: context.tr('menu_elements_sub'),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ElementInfoPage()),
                ),
              ),
              ModuleMenuSubItem(
                title: context.tr('menu_alkali_metals'),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AlkaliMetalsListPage()),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ModuleExpandableListCard(
            title: context.tr('menu_periodic_table'),
            icon: Icons.grid_on_rounded,
            accentColor: _accent,
            iconBackgroundLight: _iconBg,
            children: [
              ModuleMenuSubItem(
                title: context.tr('periodic_interaktiv'),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const PeriodicTablePage()),
                ),
              ),
              ModuleMenuSubItem(
                title: context.tr('menu_natural_resources_map'),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const NaturalResourcesMapPage()),
                ),
              ),
              ModuleMenuSubItem(
                title: context.tr('menu_regional_minerals'),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const RegionalMineralsPage()),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ModuleExpandableListCard(
            title: context.tr('menu_formulas'),
            icon: Icons.calculate_rounded,
            accentColor: _accent,
            iconBackgroundLight: _iconBg,
            children: [
              ModuleMenuSubItem(
                title: context.tr('formula_calculate'),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const FormulaCalculatorPage()),
                ),
              ),
              ModuleMenuSubItem(
                title: context.tr('menu_formulas_sub'),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ChemicalReactionsPage()),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ModuleExpandableListCard(
            title: context.tr('menu_lessons'),
            icon: Icons.assignment_rounded,
            accentColor: _accent,
            iconBackgroundLight: _iconBg,
            children: [
              ModuleMenuSubItem(
                title: context.tr('menu_theory'),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const LessonsPage(type: 'theory')),
                ),
              ),
              ModuleMenuSubItem(
                title: context.tr('menu_lab'),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const LessonsPage(type: 'lab')),
                ),
              ),
              ModuleMenuSubItem(
                title: context.tr('menu_projects'),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const InterestingTasksPage(
                      key: ValueKey('interesting_tasks_project'),
                      listKind: InterestingTasksListKind.project,
                    ),
                  ),
                ),
              ),
              ModuleMenuSubItem(
                title: context.tr('periodic_qiziqarli'),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const InterestingTasksPage(
                      key: ValueKey('interesting_tasks_interesting'),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ModuleNavListCard(
            title: context.tr('menu_quiz'),
            icon: Icons.quiz_rounded,
            accentColor: _accent,
            iconBackgroundLight: _iconBg,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const QuizListPage()),
            ),
          ),
          const SizedBox(height: 12),
          ModuleNavListCard(
            title: context.tr('menu_lab_works'),
            icon: Icons.science_outlined,
            accentColor: _accent,
            iconBackgroundLight: _iconBg,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => BlocProvider(
                  create: (_) => sl<LabWorkBloc>(),
                  child: const LabWorksPage(),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
