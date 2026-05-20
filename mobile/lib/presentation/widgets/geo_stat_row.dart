import 'package:flutter/material.dart';
import '../../core/theme/colors.dart';

/// «Asosiy ko'rsatkichlar» kartasidagi bitta qator (teal nuqta + label / qiymat).
class GeoStatRow extends StatelessWidget {
  const GeoStatRow({
    super.key,
    required this.label,
    required this.value,
    required this.secondary,
    required this.primaryText,
    this.isLast = false,
  });

  final String label;
  final String value;
  final Color secondary;
  final Color primaryText;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: 12, bottom: isLast ? 4 : 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 6, right: 12),
            child: Container(
              width: 7,
              height: 7,
              decoration: const BoxDecoration(
                color: AppColors.primaryCyan,
                shape: BoxShape.circle,
              ),
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 13,
                    height: 1.3,
                    color: secondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 15,
                    height: 1.35,
                    fontWeight: FontWeight.w600,
                    color: primaryText,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

Widget geoStatDivider(bool isDark) {
  return Divider(
    height: 1,
    thickness: 1,
    color: isDark
        ? Colors.white.withValues(alpha: 0.08)
        : AppColors.primaryCyan.withValues(alpha: 0.12),
  );
}
