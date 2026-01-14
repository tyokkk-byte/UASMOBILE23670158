import 'package:flutter/material.dart';

// CALM PROFESSIONAL PALETTE - Black/White/Orange
class AppColors {
  // Primary - Warm Orange (not too bright)
  static const primary = Color(0xFFFF8C42); // Soft Orange
  static const primaryDark = Color(0xFFE67E22); // Darker Orange
  static const primaryLight = Color(0xFFFFB380); // Light Orange
  
  // Neutral - Black & White
  static const black = Color(0xFF1A1A1A); // Not pure black
  static const blackSoft = Color(0xFF2D2D2D);
  static const white = Color(0xFFFFFFFF);
  static const offWhite = Color(0xFFFAFAFA);
  
  // Grays - Calm tones
  static const gray900 = Color(0xFF1A1A1A);
  static const gray800 = Color(0xFF2D2D2D);
  static const gray700 = Color(0xFF404040);
  static const gray600 = Color(0xFF757575);
  static const gray500 = Color(0xFF9E9E9E);
  static const gray400 = Color(0xFFBDBDBD);
  static const gray300 = Color(0xFFE0E0E0);
  static const gray200 = Color(0xFFEEEEEE);
  static const gray100 = Color(0xFFF5F5F5);
  
  // Functional Colors (subtle)
  static const success = Color(0xFF4CAF50); // Soft green
  static const error = Color(0xFFE57373); // Soft red
  static const warning = Color(0xFFFFB74D); // Soft amber
  static const info = Color(0xFF64B5F6); // Soft blue
  
  // Backgrounds
  static const background = Color(0xFFFAFAFA);
  static const surface = Color(0xFFFFFFFF);
  static const surfaceLight = Color(0xFFF5F5F5);
  
  // Text
  static const textPrimary = Color(0xFF1A1A1A);
  static const textSecondary = Color(0xFF757575);
  static const textTertiary = Color(0xFF9E9E9E);
  static const textWhite = Color(0xFFFFFFFF);
}

// CLEAN TYPOGRAPHY
class AppTextStyles {
  static const displayLarge = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.w800,
    color: AppColors.textPrimary,
    height: 1.2,
    letterSpacing: -0.5,
  );
  
  static const displayMedium = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
    height: 1.2,
  );
  
  static const headlineLarge = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
    height: 1.3,
  );
  
  static const titleLarge = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
    height: 1.4,
  );
  
  static const titleMedium = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
    height: 1.4,
  );
  
  static const bodyLarge = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
    height: 1.6,
  );
  
  static const bodyMedium = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
    height: 1.5,
  );
  
  static const labelLarge = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
    letterSpacing: 0.3,
  );
  
  static const labelMedium = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    color: AppColors.textSecondary,
    letterSpacing: 0.3,
  );
  
  // Legacy
  static const title = titleLarge;
  static const subtitle = titleMedium;
  static const body = bodyMedium;
}

// SPACING
class AppSpacing {
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 16.0;
  static const double lg = 24.0;
  static const double xl = 32.0;
  static const double xxl = 48.0;
}

// BORDER RADIUS  
class AppRadius {
  static const double sm = 8.0;
  static const double md = 12.0;
  static const double lg = 16.0;
  static const double xl = 24.0;
}

// SUBTLE SHADOWS
class AppShadows {
  static const small = [
    BoxShadow(
      color: Color(0x08000000),
      blurRadius: 8,
      offset: Offset(0, 2),
    ),
  ];
  
  static const medium = [
    BoxShadow(
      color: Color(0x0D000000),
      blurRadius: 16,
      offset: Offset(0, 4),
    ),
  ];
  
  static const large = [
    BoxShadow(
      color: Color(0x14000000),
      blurRadius: 24,
      offset: Offset(0, 8),
    ),
  ];
}

class AppPadding {
  static const double small = 8.0;
  static const double medium = 16.0;
  static const double large = 24.0;
}
