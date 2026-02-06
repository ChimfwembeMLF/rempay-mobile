import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppSpacing {
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 16.0;
  static const double lg = 24.0;
  static const double xl = 32.0;
  static const double xxl = 48.0;

  static const EdgeInsets paddingXs = EdgeInsets.all(xs);
  static const EdgeInsets paddingSm = EdgeInsets.all(sm);
  static const EdgeInsets paddingMd = EdgeInsets.all(md);
  static const EdgeInsets paddingLg = EdgeInsets.all(lg);
  static const EdgeInsets paddingXl = EdgeInsets.all(xl);

  static const EdgeInsets horizontalXs = EdgeInsets.symmetric(horizontal: xs);
  static const EdgeInsets horizontalSm = EdgeInsets.symmetric(horizontal: sm);
  static const EdgeInsets horizontalMd = EdgeInsets.symmetric(horizontal: md);
  static const EdgeInsets horizontalLg = EdgeInsets.symmetric(horizontal: lg);
  static const EdgeInsets horizontalXl = EdgeInsets.symmetric(horizontal: xl);

  static const EdgeInsets verticalXs = EdgeInsets.symmetric(vertical: xs);
  static const EdgeInsets verticalSm = EdgeInsets.symmetric(vertical: sm);
  static const EdgeInsets verticalMd = EdgeInsets.symmetric(vertical: md);
  static const EdgeInsets verticalLg = EdgeInsets.symmetric(vertical: lg);
  static const EdgeInsets verticalXl = EdgeInsets.symmetric(vertical: xl);
}

class AppRadius {
  static const double sm = 12.0;
  static const double md = 20.0;
  static const double lg = 28.0;
  static const double xl = 32.0;
}

extension TextStyleContext on BuildContext {
  TextTheme get textStyles => Theme.of(this).textTheme;
}

extension TextStyleExtensions on TextStyle {
  TextStyle get bold => copyWith(fontWeight: FontWeight.bold);
  TextStyle get semiBold => copyWith(fontWeight: FontWeight.w600);
  TextStyle get medium => copyWith(fontWeight: FontWeight.w500);
  TextStyle get normal => copyWith(fontWeight: FontWeight.w400);
  TextStyle get light => copyWith(fontWeight: FontWeight.w300);
  TextStyle withColor(Color color) => copyWith(color: color);
  TextStyle withSize(double size) => copyWith(fontSize: size);
}

class AppColors {
  // Brand Colors - Sleek Teal/Slate
  static const primary = Color(0xFF2A9D8F); // Teal
  static const secondary = Color(0xFF264653); // Dark Slate
  static const accent = Color(0xFFE9C46A); // Soft Gold
  static const action = Color(0xFFE76F51); // Burnt Sienna for actions

  // Light Mode Specifics
  static const lightBackground = Color(0xFFF4F7F6); // Very light grey-teal
  static const lightSurface = Color(0xFFFFFFFF);
  static const lightTextPrimary = Color(0xFF1D3557);
  static const lightTextSecondary = Color(0xFF457B9D);
  static const lightBorder = Color(0xFFE0E7EA);
  
  // Dark Mode Specifics
  static const darkBackground = Color(0xFF121212);
  static const darkSurface = Color(0xFF1E1E1E);
  static const darkTextPrimary = Color(0xFFEDF2F4);
  static const darkTextSecondary = Color(0xFFA8DADC);
  static const darkBorder = Color(0xFF2D2D2D);

  // Status Colors
  static const success = Color(0xFF2A9D8F);
  static const warning = Color(0xFFE9C46A);
  static const error = Color(0xFFE63946);
  static const info = Color(0xFF457B9D);
}

class FontSizes {
  static const double displayLarge = 48.0;
  static const double displayMedium = 40.0;
  static const double displaySmall = 32.0;
  static const double headlineLarge = 28.0;
  static const double headlineMedium = 24.0;
  static const double headlineSmall = 20.0;
  static const double titleLarge = 18.0;
  static const double titleMedium = 16.0;
  static const double titleSmall = 14.0;
  static const double bodyLarge = 16.0;
  static const double bodyMedium = 14.0;
  static const double bodySmall = 12.0;
  static const double labelLarge = 14.0;
  static const double labelSmall = 10.0;
}

ThemeData get lightTheme => ThemeData(
  useMaterial3: true,
  brightness: Brightness.light,
  scaffoldBackgroundColor: AppColors.lightBackground,
  primaryColor: AppColors.primary,
  colorScheme: const ColorScheme.light(
    primary: AppColors.primary,
    onPrimary: Colors.white,
    secondary: AppColors.secondary,
    onSecondary: Colors.white,
    surface: AppColors.lightSurface,
    onSurface: AppColors.lightTextPrimary,
    error: AppColors.error,
    onError: Colors.white,
    outline: AppColors.lightBorder,
  ),
  appBarTheme: AppBarTheme(
    backgroundColor: AppColors.lightBackground,
    foregroundColor: AppColors.lightTextPrimary,
    elevation: 0,
    centerTitle: false,
    titleTextStyle: GoogleFonts.outfit(
      fontSize: FontSizes.headlineSmall,
      fontWeight: FontWeight.w600,
      color: AppColors.lightTextPrimary,
    ),
  ),
  cardTheme: CardThemeData(
    elevation: 0,
    color: AppColors.lightSurface,
    margin: EdgeInsets.zero,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(AppRadius.md),
      side: const BorderSide(color: Colors.transparent),
    ),
  ),
  textTheme: _buildTextTheme(AppColors.lightTextPrimary, AppColors.lightTextSecondary),
  iconTheme: const IconThemeData(
    color: AppColors.secondary,
    size: 24,
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: AppColors.primary,
      foregroundColor: Colors.white,
      elevation: 0,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      textStyle: GoogleFonts.outfit(
        fontSize: FontSizes.titleMedium,
        fontWeight: FontWeight.w600,
      ),
    ),
  ),
  dividerTheme: const DividerThemeData(
    color: AppColors.lightBorder,
    thickness: 1,
    space: 24,
  ),
);

ThemeData get darkTheme => ThemeData(
  useMaterial3: true,
  brightness: Brightness.dark,
  scaffoldBackgroundColor: AppColors.darkBackground,
  primaryColor: AppColors.primary,
  colorScheme: const ColorScheme.dark(
    primary: AppColors.primary,
    onPrimary: Colors.white,
    secondary: AppColors.secondary,
    onSecondary: Colors.white,
    surface: AppColors.darkSurface,
    onSurface: AppColors.darkTextPrimary,
    error: AppColors.error,
    onError: Colors.white,
    outline: AppColors.darkBorder,
  ),
  appBarTheme: AppBarTheme(
    backgroundColor: AppColors.darkBackground,
    foregroundColor: AppColors.darkTextPrimary,
    elevation: 0,
    centerTitle: false,
    titleTextStyle: GoogleFonts.outfit(
      fontSize: FontSizes.headlineSmall,
      fontWeight: FontWeight.w600,
      color: AppColors.darkTextPrimary,
    ),
  ),
  cardTheme: CardThemeData(
    elevation: 0,
    color: AppColors.darkSurface,
    margin: EdgeInsets.zero,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(AppRadius.md),
      side: const BorderSide(color: AppColors.darkBorder),
    ),
  ),
  textTheme: _buildTextTheme(AppColors.darkTextPrimary, AppColors.darkTextSecondary),
  iconTheme: const IconThemeData(
    color: AppColors.darkTextPrimary,
    size: 24,
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: AppColors.primary,
      foregroundColor: Colors.white,
      elevation: 0,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      textStyle: GoogleFonts.outfit(
        fontSize: FontSizes.titleMedium,
        fontWeight: FontWeight.w600,
      ),
    ),
  ),
  dividerTheme: const DividerThemeData(
    color: AppColors.darkBorder,
    thickness: 1,
    space: 24,
  ),
);

TextTheme _buildTextTheme(Color primaryColor, Color secondaryColor) {
  return TextTheme(
    displayLarge: GoogleFonts.outfit(
      fontSize: FontSizes.displayLarge,
      fontWeight: FontWeight.bold,
      color: primaryColor,
    ),
    displayMedium: GoogleFonts.outfit(
      fontSize: FontSizes.displayMedium,
      fontWeight: FontWeight.bold,
      color: primaryColor,
    ),
    headlineLarge: GoogleFonts.outfit(
      fontSize: FontSizes.headlineLarge,
      fontWeight: FontWeight.w600,
      color: primaryColor,
    ),
    headlineMedium: GoogleFonts.outfit(
      fontSize: FontSizes.headlineMedium,
      fontWeight: FontWeight.w600,
      color: primaryColor,
    ),
    titleLarge: GoogleFonts.outfit(
      fontSize: FontSizes.titleLarge,
      fontWeight: FontWeight.w600,
      color: primaryColor,
    ),
    titleMedium: GoogleFonts.outfit(
      fontSize: FontSizes.titleMedium,
      fontWeight: FontWeight.w500,
      color: primaryColor,
    ),
    bodyLarge: GoogleFonts.dmSans( // Using DM Sans for body text for readability
      fontSize: FontSizes.bodyLarge,
      fontWeight: FontWeight.normal,
      color: primaryColor,
      height: 1.5,
    ),
    bodyMedium: GoogleFonts.dmSans(
      fontSize: FontSizes.bodyMedium,
      fontWeight: FontWeight.normal,
      color: secondaryColor,
      height: 1.5,
    ),
    bodySmall: GoogleFonts.dmSans(
      fontSize: FontSizes.bodySmall,
      fontWeight: FontWeight.normal,
      color: secondaryColor,
    ),
    labelLarge: GoogleFonts.outfit(
      fontSize: FontSizes.labelLarge,
      fontWeight: FontWeight.w600,
      color: primaryColor,
    ),
  );
}
