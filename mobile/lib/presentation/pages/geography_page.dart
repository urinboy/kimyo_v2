import 'package:flutter/material.dart';
import '../../core/theme/colors.dart';
import '../../core/localization/app_localizations.dart';
import '../widgets/module_menu_list_cards.dart';
import 'geography_quiz_list_page.dart';
import 'geography_republic_info_page.dart';
import 'geography_karakalpak_info_page.dart';
import 'geography_borders_page.dart';
import 'geography_climate_regional_page.dart';
import 'geography_weather_page.dart';
import 'geography_rocks_page.dart';
import 'geography_minerals_page.dart';
import 'geography_relief_page.dart';
import 'geography_phenomena_page.dart';

class GeographyPage extends StatelessWidget {
  const GeographyPage({super.key});

  static const _accent = AppColors.primaryBlue;
  static const _iconBg = AppColors.iconBackgroundBlue;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor:
          isDark ? AppColors.scaffoldBackgroundDark : AppColors.scaffoldBackground,
      appBar: AppBar(
        title: Text(
          context.tr('tab_geografiya'),
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        backgroundColor: AppColors.primaryBlue,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ModuleExpandableListCard(
            title: context.tr('geo_map'),
            icon: Icons.public_rounded,
            accentColor: _accent,
            iconBackgroundLight: _iconBg,
            children: [
              ModuleMenuSubItem(
                title: context.tr('geo_map_sub1'),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const GeographyRepublicInfoPage()),
                ),
              ),
              ModuleMenuSubItem(
                title: context.tr('geo_map_sub_karakalpak'),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const GeographyKarakalpakInfoPage()),
                ),
              ),
              ModuleMenuSubItem(
                title: context.tr('geo_map_sub2'),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const GeographyBordersPage()),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ModuleExpandableListCard(
            title: context.tr('geo_landscapes'),
            icon: Icons.terrain_rounded,
            accentColor: _accent,
            iconBackgroundLight: _iconBg,
            children: [
              ModuleMenuSubItem(
                title: context.tr('geo_land_sub1'),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const GeographyReliefPage()),
                ),
              ),
              ModuleMenuSubItem(
                title: context.tr('geo_land_sub2'),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const GeographyPhenomenaPage()),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ModuleExpandableListCard(
            title: context.tr('geo_geology'),
            icon: Icons.layers_rounded,
            accentColor: _accent,
            iconBackgroundLight: _iconBg,
            children: [
              ModuleMenuSubItem(
                title: context.tr('geo_geology_sub1'),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const GeographyRocksPage()),
                ),
              ),
              ModuleMenuSubItem(
                title: context.tr('geo_geology_sub2'),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const GeographyMineralsPage()),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ModuleExpandableListCard(
            title: context.tr('geo_climate'),
            icon: Icons.wb_sunny_rounded,
            accentColor: _accent,
            iconBackgroundLight: _iconBg,
            children: [
              ModuleMenuSubItem(
                title: context.tr('geo_climate_sub1'),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const GeographyClimateRegionalPage()),
                ),
              ),
              ModuleMenuSubItem(
                title: context.tr('geo_climate_sub2'),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const GeographyWeatherPage()),
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
              MaterialPageRoute(builder: (_) => const GeographyQuizListPage()),
            ),
          ),
        ],
      ),
    );
  }
}
