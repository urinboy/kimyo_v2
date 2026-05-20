import 'package:flutter/material.dart';
import '../../core/localization/app_localizations.dart';
import '../../core/theme/colors.dart';

class AuthorPage extends StatelessWidget {
  const AuthorPage({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(context.tr('settings_author')),
        backgroundColor: AppColors.primaryOrange,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header Section
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 16),
              decoration: BoxDecoration(
                color: AppColors.primaryOrange,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(40),
                  bottomRight: Radius.circular(40),
                ),
              ),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: const CircleAvatar(
                      radius: 60,
                      backgroundImage: AssetImage('assets/images/AUTOR.png'),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    context.tr('author_name'),
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      context.tr('author_role'),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Asosiy ma'lumotlar
                  _buildSectionHeader(context, Icons.person_outline_rounded, context.tr('author_main_info')),
                  _buildInfoCard(context, [
                    {'label': context.tr('author_birth_date'), 'value': '26.04.1981'},
                    {'label': context.tr('author_birth_place'), 'value': 'Qonliko\'l tumani'},
                    {'label': context.tr('author_nationality'), 'value': context.tr('author_qoraqalpoq')},
                    {'label': context.tr('author_education'), 'value': context.tr('author_higher')},
                    {'label': context.tr('author_specialty'), 'value': context.tr('author_chemistry')},
                    {'label': context.tr('author_languages'), 'value': context.tr('author_lang_list')},
                  ]),

                  const SizedBox(height: 24),
                  // Hozirgi ish joyi
                  _buildSectionHeader(context, Icons.business_center_outlined, context.tr('author_current_job')),
                  _buildInfoCard(context, [
                    {'label': context.tr('author_position'), 'value': context.tr('author_senior_teacher')},
                    {'label': context.tr('author_org'), 'value': context.tr('author_uni')},
                    {'label': context.tr('author_dept'), 'value': context.tr('author_dept_name')},
                    {'label': context.tr('author_start_date'), 'value': context.tr('author_start_val')},
                  ]),

                  const SizedBox(height: 24),
                  // Mehnat faoliyati
                  _buildSectionHeader(context, Icons.history_rounded, context.tr('author_experience')),
                  _buildTimelineCard(context, [
                    {
                      'years': '2006-2015',
                      'desc': 'Shumanay tumani 7-son maktab o\'qituvchisi',
                      'isLast': false
                    },
                    {
                      'years': '2015-2023',
                      'desc': 'Shumanay tumani XTB tabiiy fanlar metodisti',
                      'isLast': false
                    },
                    {
                      'years': '2023 (iyun-sentabr)',
                      'desc': '3-son maktab direktor o\'rinbosari',
                      'isLast': false
                    },
                    {
                      'years': '2023-2025',
                      'desc': 'Nukus Konchilik instituti, kimyo fani stajyor o\'qituvchisi',
                      'isLast': false
                    },
                    {
                      'years': '2025-${context.tr('author_present')}',
                      'desc': 'Nukus davlat texnika universiteti katta o\'qituvchisi',
                      'isLast': true
                    },
                  ]),

                  const SizedBox(height: 24),
                  // Qo'shimcha ma'lumotlar
                  _buildSectionHeader(context, Icons.info_outline_rounded, context.tr('author_additional')),
                  _buildInfoCard(context, [
                    {'label': context.tr('author_degree'), 'value': context.tr('author_none')},
                    {'label': context.tr('author_title'), 'value': context.tr('author_none')},
                    {'label': context.tr('author_awards'), 'value': context.tr('author_none')},
                    {'label': context.tr('author_deputy'), 'value': context.tr('author_none')},
                  ]),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, IconData icon, String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 8, bottom: 12),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primaryOrange, size: 24),
          const SizedBox(width: 12),
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(BuildContext context, List<Map<String, String>> items) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(16),
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
      child: Column(
        children: items.asMap().entries.map((entry) {
          final index = entry.key;
          final item = entry.value;
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: Text(
                        item['label']!,
                        style: TextStyle(
                          color: isDark ? Colors.white54 : AppColors.textSecondary,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 3,
                      child: Text(
                        item['value']!,
                        style: TextStyle(
                          color: isDark ? Colors.white : AppColors.textPrimary,
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              if (index < items.length - 1)
                Divider(height: 1, color: isDark ? Colors.white10 : Colors.black12),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildTimelineCard(BuildContext context, List<Map<String, dynamic>> items) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(20),
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
      child: Column(
        children: items.map((item) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: item['isLast'] ? AppColors.primaryOrange : AppColors.primaryOrange.withOpacity(0.3),
                      shape: BoxShape.circle,
                    ),
                  ),
                  if (!item['isLast'])
                    Container(
                      width: 2,
                      height: 60,
                      color: AppColors.primaryOrange.withOpacity(0.2),
                    ),
                ],
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item['years'],
                      style: TextStyle(
                        color: item['isLast'] ? AppColors.primaryOrange : AppColors.textSecondary,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item['desc'],
                      style: TextStyle(
                        color: isDark ? Colors.white : AppColors.textPrimary,
                        fontSize: 14,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }
}
