import 'package:flutter/material.dart';
import '../../core/localization/app_localizations.dart';
import '../../core/theme/colors.dart';
import 'geography_political_map_page.dart';
import '../widgets/geography_topic_complete_bar.dart';
import '../widgets/geo_stat_row.dart';

/// O'zbekiston Respublikasi — «Respublikamiz» ma'lumotlari (QKR sahifasi bilan bir xil layout).
class GeographyRepublicInfoPage extends StatelessWidget {
  const GeographyRepublicInfoPage({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final secondary = isDark ? Colors.white60 : AppColors.textSecondary;
    final primaryText = isDark ? Colors.white70 : AppColors.textPrimary;

    return Scaffold(
      appBar: AppBar(
        title: Text(context.tr('geo_republic_title')),
        centerTitle: true,
        backgroundColor: AppColors.primaryCyan,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.location_city_rounded,
                  color: AppColors.primaryCyan, size: 22),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  context.tr('geo_republic_capital'),
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    height: 1.35,
                    color: AppColors.primaryCyan,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            context.tr('geo_republic_lead'),
            style: TextStyle(
              fontSize: 16,
              height: 1.55,
              color: primaryText,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            context.tr('geo_karakalpak_section_title'),
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
            decoration: BoxDecoration(
              color: isDark
                  ? AppColors.cardDark
                  : AppColors.primaryCyan.withValues(alpha: 0.07),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.08)
                    : AppColors.primaryCyan.withValues(alpha: 0.22),
              ),
            ),
            child: Column(
              children: [
                GeoStatRow(
                  label: context.tr('geo_stat_area'),
                  value: context.tr('geo_republic_v_area'),
                  secondary: secondary,
                  primaryText: primaryText,
                ),
                geoStatDivider(isDark),
                GeoStatRow(
                  label: context.tr('geo_stat_pop'),
                  value: context.tr('geo_republic_v_pop'),
                  secondary: secondary,
                  primaryText: primaryText,
                ),
                geoStatDivider(isDark),
                GeoStatRow(
                  label: context.tr('geo_stat_languages'),
                  value: context.tr('geo_republic_v_lang'),
                  secondary: secondary,
                  primaryText: primaryText,
                ),
                geoStatDivider(isDark),
                GeoStatRow(
                  label: context.tr('geo_stat_currency'),
                  value: context.tr('geo_republic_v_currency'),
                  secondary: secondary,
                  primaryText: primaryText,
                ),
                geoStatDivider(isDark),
                GeoStatRow(
                  label: context.tr('geo_republic_admin_label'),
                  value: context.tr('geo_republic_v_admin'),
                  secondary: secondary,
                  primaryText: primaryText,
                  isLast: true,
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const GeographyPoliticalMapPage(),
                  ),
                );
              },
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primaryCyan,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
              ),
              child: Text(
                context.tr('geo_republic_btn_map'),
                style:
                    const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
              ),
            ),
          ),
          const GeographyTopicCompleteBar(
            topicId: 'geo_republic',
            titleTrKey: 'geo_republic_title',
          ),
        ],
      ),
    );
  }
}
