import 'package:flutter/material.dart';

/// App-wide color constants for consistent theming
class AppColors {
  // Background colors
  static const Color background = Color(0xFF0F111A);
  static const Color backgroundDark = Color(0xFF0B0D14);
  static const Color backgroundDarker = Color(0xFF0D0D17);
  static const Color cardBackground = Color(0xFF1B1E2B);
  static const Color cardBackgroundAlt = Color(0xFF1E1E1E);
  static const Color cardBackgroundDark = Color(0xFF161A26);
  static const Color cardBackgroundDarker = Color(0xFF1A1A2E);
  static const Color cardBackgroundLight = Color(0xFF121225);

  // Accent colors
  static const Color primary = Color(0xFF8A8AFF);
  static const Color primaryAlt = Color(0xFF6C63FF);
  static const Color accentPurple = Color(0xFF6366F1);
  static const Color accentOrange = Color(0xFFE67E22);

  // Text colors
  static const Color textPrimary = Colors.white;
  static const Color textSecondary = Colors.grey;
  static const Color textMuted = Colors.white70;
  static const Color textHint = Colors.white38;
  static const Color textHintDark = Colors.white24;

  // Status colors
  static const Color error = Color(0xFFFF6B6B);
  static const Color success = Colors.green;
  static const Color successLight = Colors.greenAccent;
  static const Color favorite = Colors.pink;
  static const Color favoriteAlt = Color(0xFFFF5252);

  // Utility colors
  static const Color star = Colors.orange;
  static const Color divider = Colors.white10;
}

/// App-wide text styles
class AppTextStyles {
  static const TextStyle headingLarge = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
  );

  static const TextStyle headingMedium = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
  );

  static const TextStyle headingSmall = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
  );

  static const TextStyle titleLarge = TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
  );

  static const TextStyle titleMedium = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
  );

  static const TextStyle titleSmall = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
  );

  static const TextStyle bodyLarge = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w500,
    color: AppColors.textPrimary,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: AppColors.textPrimary,
  );

  static const TextStyle bodySmall = TextStyle(
    fontSize: 12,
    color: AppColors.textSecondary,
  );

  static const TextStyle caption = TextStyle(
    fontSize: 11,
    color: AppColors.textSecondary,
  );
}

/// Recipe categories
class AppCategories {
  static const List<String> all = [
    'All',
    'Breakfast',
    'Lunch',
    'Dinner',
    'Dessert',
    'Snack',
  ];

  static const List<String> difficulties = [
    'Easy',
    'Medium',
    'Hard',
  ];
}

/// App constants
class AppConstants {
  static const String appName = 'CookBook';
  static const String appVersion = '1.0.0';
}
