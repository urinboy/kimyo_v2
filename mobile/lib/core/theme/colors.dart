import 'package:flutter/material.dart';

class AppColors {
  // Legacy Colors from Image
  static const Color primaryPurple = Color(0xFF9C27B0);
  static const Color activeBlue = Color(0xFF03A9F4);
  
  // Light Theme
  static const Color scaffoldBackground = Color(0xFFF5F5F5);
  static const Color cardWhite = Colors.white;
  
  // Dark Theme
  static const Color scaffoldBackgroundDark = Color(0xFF121212);
  static const Color cardDark = Color(0xFF1E1E1E);
  
  static const Color iconBackground = Color(0xFFF3E5F5);
  static const Color iconBackgroundDark = Color(0xFF2C1A2E); // Darker purple tint
  
  // Text Colors
  static const Color textPrimary = Color(0xFF212121);
  static const Color textSecondary = Color(0xFF757575);
  static const Color textPrimaryDark = Colors.white;
  static const Color textSecondaryDark = Color(0xFFB0B0B0);
  
  // Keep some v2 accents for "Premium" feel
  static const Color primaryGreen = Color(0xFF10B981);
  static const Color solidPurple = Color(0xFFA855F7);
  
  // Geography Tab Colors
  static const Color primaryCyan = Color(0xFF00BCD4);
  static const Color iconBackgroundCyan = Color(0xFFE0F7FA);

  // Documents Tab Colors
  static const Color primaryBlue = Color(0xFF2196F3);
  static const Color iconBackgroundBlue = Color(0xFFE3F2FD);
  static const Color iconGreen = Color(0xFF4CAF50);
  static const Color iconBackgroundGreen = Color(0xFFE8F5E9);

  // Settings Tab Colors
  static const Color primaryOrange = Color(0xFFFFA000);
  static const Color iconBackgroundOrange = Color(0xFFFFF3E0);
  static const Color iconBackgroundYellow = Color(0xFFFFFDE7);
  static const Color iconYellow = Color(0xFFFBC02D);

  // Profile Tab Colors
  static const Color primaryGreenProfile = Color(0xFF4CAF50);
  static const Color iconBackgroundGreenProfile = Color(0xFFE8F5E9);
  static const Color iconRed = Color(0xFFE57373);
  static const Color iconBackgroundRed = Color(0xFFFFEBEE);

  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFFA855F7),
      Color(0xFF7E22CE),
    ],
  );

  static const LinearGradient glassGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0x26FFFFFF),
      Color(0x0DFFFFFF),
    ],
  );
}
