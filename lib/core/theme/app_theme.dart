/// Islamic-inspired theme for Quran & Hadith App
/// Colors inspired by traditional Islamic art: deep greens, golds, warm neutrals

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants/app_constants.dart';

class AppTheme {
  // Islamic Color Palette
  static const Color _primaryGreen = Color(0xFF006D4C); // Deep Islamic Green
  static const Color _primaryGreenLight = Color(0xFF1A8A6B);
  static const Color _primaryGreenDark = Color(0xFF004D35);
  static const Color _secondaryGold = Color(0xFFD4A843); // Islamic Gold
  static const Color _secondaryGoldLight = Color(0xFFE8C56D);
  static const Color _secondaryGoldDark = Color(0xFFB89038);

  // Light Theme Colors
  static const Color _lightSurface = Color(0xFFFAFAF8);
  static const Color _lightBackground = Color(0xFFF5F5F0);
  static const Color _lightCardBackground = Color(0xFFFFFFFF);
  static const Color _lightDivider = Color(0xFFE8E8E0);
  static const Color _lightTextPrimary = Color(0xFF1A1A1A);
  static const Color _lightTextSecondary = Color(0xFF666666);
  static const Color _lightTextHint = Color(0xFF999999);

  // Dark Theme Colors
  static const Color _darkSurface = Color(0xFF1C1C1C);
  static const Color _darkBackground = Color(0xFF121212);
  static const Color _darkCardBackground = Color(0xFF1E1E1E);
  static const Color _darkDivider = Color(0xFF333333);
  static const Color _darkTextPrimary = Color(0xFFFFFFFF);
  static const Color _darkTextSecondary = Color(0xFFBBBBBB);
  static const Color _darkTextHint = Color(0xFF888888);

  /// Light Theme
  static ThemeData get lightTheme {
    final colorScheme = ColorScheme.light(
      primary: _primaryGreen,
      onPrimary: Colors.white,
      primaryContainer: _primaryGreenLight.withValues(alpha: 0.15),
      onPrimaryContainer: _primaryGreenDark,
      secondary: _secondaryGold,
      onSecondary: Colors.white,
      secondaryContainer: _secondaryGoldLight.withValues(alpha: 0.15),
      onSecondaryContainer: _secondaryGoldDark,
      tertiary: _primaryGreen,
      onTertiary: Colors.white,
      surface: _lightSurface,
      onSurface: _lightTextPrimary,
      surfaceContainerHighest: _lightCardBackground,
      surfaceContainerHigh: _lightBackground,
      surfaceContainer: _lightCardBackground,
      surfaceContainerLow: _lightSurface,
      surfaceContainerLowest: Colors.white,
      error: const Color(0xFFC62828),
      onError: Colors.white,
      outline: _lightDivider,
      outlineVariant: _lightDivider.withValues(alpha: 0.5),
      shadow: Colors.black.withValues(alpha: 0.08),
      scrim: Colors.black.withValues(alpha: 0.5),
      inverseSurface: _darkSurface,
      onInverseSurface: _darkTextPrimary,
      inversePrimary: _primaryGreenLight,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      brightness: Brightness.light,
      scaffoldBackgroundColor: _lightBackground,
      fontFamily: GoogleFonts.notoSansArabic().fontFamily,
      textTheme: _buildTextTheme(isDark: false),
      appBarTheme: _buildAppBarTheme(colorScheme, isDark: false),
      cardTheme: _buildCardTheme(colorScheme, isDark: false),
      elevatedButtonTheme: _buildElevatedButtonTheme(colorScheme),
      filledButtonTheme: _buildFilledButtonTheme(colorScheme),
      outlinedButtonTheme: _buildOutlinedButtonTheme(colorScheme),
      textButtonTheme: _buildTextButtonTheme(colorScheme),
      inputDecorationTheme: _buildInputDecorationTheme(colorScheme, isDark: false),
      bottomNavigationBarTheme: _buildBottomNavTheme(colorScheme, isDark: false),
      navigationBarTheme: _buildNavigationBarTheme(colorScheme, isDark: false),
      tabBarTheme: _buildTabBarTheme(colorScheme),
      chipTheme: _buildChipTheme(colorScheme, isDark: false),
      dividerTheme: _buildDividerTheme(colorScheme, isDark: false),
      listTileTheme: _buildListTileTheme(colorScheme, isDark: false),
      dialogTheme: _buildDialogTheme(colorScheme, isDark: false),
      bottomSheetTheme: _buildBottomSheetTheme(colorScheme, isDark: false),
      snackBarTheme: _buildSnackBarTheme(colorScheme),
      floatingActionButtonTheme: _buildFABTheme(colorScheme),
      progressIndicatorTheme: _buildProgressIndicatorTheme(colorScheme),
      sliderTheme: _buildSliderTheme(colorScheme),
      switchTheme: _buildSwitchTheme(colorScheme),
      checkboxTheme: _buildCheckboxTheme(colorScheme),
      radioTheme: _buildRadioTheme(colorScheme),
      tooltipTheme: _buildTooltipTheme(colorScheme, isDark: false),
      popupMenuTheme: _buildPopupMenuTheme(colorScheme, isDark: false),
      extensions: [
        _QuranHadithThemeExtension.light(),
      ],
    );
  }

  /// Dark Theme
  static ThemeData get darkTheme {
    final colorScheme = ColorScheme.dark(
      primary: _primaryGreenLight,
      onPrimary: Colors.black,
      primaryContainer: _primaryGreenDark.withValues(alpha: 0.3),
      onPrimaryContainer: _primaryGreenLight,
      secondary: _secondaryGoldLight,
      onSecondary: Colors.black,
      secondaryContainer: _secondaryGoldDark.withValues(alpha: 0.3),
      onSecondaryContainer: _secondaryGoldLight,
      tertiary: _primaryGreenLight,
      onTertiary: Colors.black,
      surface: _darkSurface,
      onSurface: _darkTextPrimary,
      surfaceContainerHighest: _darkCardBackground,
      surfaceContainerHigh: _darkBackground,
      surfaceContainer: _darkCardBackground,
      surfaceContainerLow: _darkSurface,
      surfaceContainerLowest: _darkBackground,
      error: const Color(0xFFEF5350),
      onError: Colors.black,
      outline: _darkDivider,
      outlineVariant: _darkDivider.withValues(alpha: 0.5),
      shadow: Colors.black.withValues(alpha: 0.3),
      scrim: Colors.black.withValues(alpha: 0.7),
      inverseSurface: _lightSurface,
      onInverseSurface: _lightTextPrimary,
      inversePrimary: _primaryGreen,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: _darkBackground,
      fontFamily: GoogleFonts.notoSansArabic().fontFamily,
      textTheme: _buildTextTheme(isDark: true),
      appBarTheme: _buildAppBarTheme(colorScheme, isDark: true),
      cardTheme: _buildCardTheme(colorScheme, isDark: true),
      elevatedButtonTheme: _buildElevatedButtonTheme(colorScheme),
      filledButtonTheme: _buildFilledButtonTheme(colorScheme),
      outlinedButtonTheme: _buildOutlinedButtonTheme(colorScheme),
      textButtonTheme: _buildTextButtonTheme(colorScheme),
      inputDecorationTheme: _buildInputDecorationTheme(colorScheme, isDark: true),
      bottomNavigationBarTheme: _buildBottomNavTheme(colorScheme, isDark: true),
      navigationBarTheme: _buildNavigationBarTheme(colorScheme, isDark: true),
      tabBarTheme: _buildTabBarTheme(colorScheme),
      chipTheme: _buildChipTheme(colorScheme, isDark: true),
      dividerTheme: _buildDividerTheme(colorScheme, isDark: true),
      listTileTheme: _buildListTileTheme(colorScheme, isDark: true),
      dialogTheme: _buildDialogTheme(colorScheme, isDark: true),
      bottomSheetTheme: _buildBottomSheetTheme(colorScheme, isDark: true),
      snackBarTheme: _buildSnackBarTheme(colorScheme),
      floatingActionButtonTheme: _buildFABTheme(colorScheme),
      progressIndicatorTheme: _buildProgressIndicatorTheme(colorScheme),
      sliderTheme: _buildSliderTheme(colorScheme),
      switchTheme: _buildSwitchTheme(colorScheme),
      checkboxTheme: _buildCheckboxTheme(colorScheme),
      radioTheme: _buildRadioTheme(colorScheme),
      tooltipTheme: _buildTooltipTheme(colorScheme, isDark: true),
      popupMenuTheme: _buildPopupMenuTheme(colorScheme, isDark: true),
      extensions: [
        _QuranHadithThemeExtension.dark(),
      ],
    );
  }

  static TextTheme _buildTextTheme({required bool isDark}) {
    final primaryColor = isDark ? _darkTextPrimary : _lightTextPrimary;
    final secondaryColor = isDark ? _darkTextSecondary : _lightTextSecondary;
    final hintColor = isDark ? _darkTextHint : _lightTextHint;

    return TextTheme(
      // Display styles - for large headings
      displayLarge: GoogleFonts.amiri(
        fontSize: 57,
        fontWeight: FontWeight.w400,
        letterSpacing: -0.25,
        color: primaryColor,
        height: 1.12,
      ),
      displayMedium: GoogleFonts.amiri(
        fontSize: 45,
        fontWeight: FontWeight.w400,
        letterSpacing: 0,
        color: primaryColor,
        height: 1.16,
      ),
      displaySmall: GoogleFonts.amiri(
        fontSize: 36,
        fontWeight: FontWeight.w400,
        letterSpacing: 0,
        color: primaryColor,
        height: 1.22,
      ),

      // Headline styles - for section headers
      headlineLarge: GoogleFonts.amiri(
        fontSize: 32,
        fontWeight: FontWeight.w700,
        letterSpacing: 0,
        color: primaryColor,
        height: 1.25,
      ),
      headlineMedium: GoogleFonts.amiri(
        fontSize: 28,
        fontWeight: FontWeight.w600,
        letterSpacing: 0,
        color: primaryColor,
        height: 1.29,
      ),
      headlineSmall: GoogleFonts.amiri(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        letterSpacing: 0,
        color: primaryColor,
        height: 1.33,
      ),

      // Title styles - for card titles, list items
      titleLarge: GoogleFonts.notoSansArabic(
        fontSize: 22,
        fontWeight: FontWeight.w600,
        letterSpacing: 0,
        color: primaryColor,
        height: 1.27,
      ),
      titleMedium: GoogleFonts.notoSansArabic(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.15,
        color: primaryColor,
        height: 1.50,
      ),
      titleSmall: GoogleFonts.notoSansArabic(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.1,
        color: primaryColor,
        height: 1.43,
      ),

      // Body styles - for main content
      bodyLarge: GoogleFonts.notoSansArabic(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.15,
        color: primaryColor,
        height: 1.50,
      ),
      bodyMedium: GoogleFonts.notoSansArabic(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.25,
        color: primaryColor,
        height: 1.43,
      ),
      bodySmall: GoogleFonts.notoSansArabic(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.4,
        color: secondaryColor,
        height: 1.33,
      ),

      // Label styles - for buttons, chips, captions
      labelLarge: GoogleFonts.notoSansArabic(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.1,
        color: primaryColor,
        height: 1.43,
      ),
      labelMedium: GoogleFonts.notoSansArabic(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.5,
        color: primaryColor,
        height: 1.33,
      ),
      labelSmall: GoogleFonts.notoSansArabic(
        fontSize: 11,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.5,
        color: hintColor,
        height: 1.45,
      ),
    ).apply(
      bodyColor: primaryColor,
      displayColor: primaryColor,
    );
  }

  static AppBarTheme _buildAppBarTheme(ColorScheme colorScheme, {required bool isDark}) {
    return AppBarTheme(
      centerTitle: true,
      elevation: 0,
      scrolledUnderElevation: 1,
      backgroundColor: colorScheme.surface,
      foregroundColor: colorScheme.onSurface,
      surfaceTintColor: colorScheme.surfaceTint,
      shadowColor: colorScheme.shadow,
      titleTextStyle: GoogleFonts.amiri(
        fontSize: 22,
        fontWeight: FontWeight.w600,
        color: colorScheme.onSurface,
        letterSpacing: 0,
      ),
      toolbarTextStyle: GoogleFonts.notoSansArabic(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        color: colorScheme.onSurface,
      ),
      iconTheme: IconThemeData(
        color: colorScheme.onSurface,
        size: 24,
      ),
      actionsIconTheme: IconThemeData(
        color: colorScheme.onSurface,
        size: 24,
      ),
    );
  }

  static CardThemeData _buildCardTheme(ColorScheme colorScheme, {required bool isDark}) {
    return CardThemeData(
      color: colorScheme.surfaceContainerHigh,
      surfaceTintColor: colorScheme.surfaceTint,
      shadowColor: colorScheme.shadow,
      elevation: isDark ? 2 : 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.radiusLG),
        side: BorderSide(
          color: colorScheme.outlineVariant,
          width: 0.5,
        ),
      ),
      margin: const EdgeInsets.symmetric(
        horizontal: AppConstants.spacingMD,
        vertical: AppConstants.spacingXS,
      ),
    );
  }

  static ElevatedButtonThemeData _buildElevatedButtonTheme(ColorScheme colorScheme) {
    return ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        elevation: 0,
        shadowColor: colorScheme.shadow,
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        disabledBackgroundColor: colorScheme.primary.withValues(alpha: 0.3),
        disabledForegroundColor: colorScheme.onPrimary.withValues(alpha: 0.5),
        padding: const EdgeInsets.symmetric(
          horizontal: AppConstants.spacingLG,
          vertical: AppConstants.spacingMD,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.radiusMD),
        ),
        textStyle: GoogleFonts.notoSansArabic(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.1,
        ),
      ).copyWith(
        overlayColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.pressed)) {
            return colorScheme.primary.withValues(alpha: 0.1);
          }
          if (states.contains(WidgetState.hovered)) {
            return colorScheme.primary.withValues(alpha: 0.05);
          }
          return null;
        }),
      ),
    );
  }

  static FilledButtonThemeData _buildFilledButtonTheme(ColorScheme colorScheme) {
    return FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        padding: const EdgeInsets.symmetric(
          horizontal: AppConstants.spacingLG,
          vertical: AppConstants.spacingMD,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.radiusMD),
        ),
        textStyle: GoogleFonts.notoSansArabic(
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  static OutlinedButtonThemeData _buildOutlinedButtonTheme(ColorScheme colorScheme) {
    return OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: colorScheme.primary,
        side: BorderSide(color: colorScheme.primary, width: 1.5),
        padding: const EdgeInsets.symmetric(
          horizontal: AppConstants.spacingLG,
          vertical: AppConstants.spacingMD,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.radiusMD),
        ),
        textStyle: GoogleFonts.notoSansArabic(
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  static TextButtonThemeData _buildTextButtonTheme(ColorScheme colorScheme) {
    return TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: colorScheme.primary,
        padding: const EdgeInsets.symmetric(
          horizontal: AppConstants.spacingMD,
          vertical: AppConstants.spacingSM,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.radiusSM),
        ),
        textStyle: GoogleFonts.notoSansArabic(
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  static InputDecorationTheme _buildInputDecorationTheme(ColorScheme colorScheme, {required bool isDark}) {
    return InputDecorationTheme(
      filled: true,
      fillColor: colorScheme.surfaceContainerHighest,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppConstants.spacingMD,
        vertical: AppConstants.spacingMD,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppConstants.radiusMD),
        borderSide: BorderSide(color: colorScheme.outline),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppConstants.radiusMD),
        borderSide: BorderSide(color: colorScheme.outlineVariant),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppConstants.radiusMD),
        borderSide: BorderSide(color: colorScheme.primary, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppConstants.radiusMD),
        borderSide: BorderSide(color: colorScheme.error),
      ),
      disabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppConstants.radiusMD),
        borderSide: BorderSide(color: colorScheme.outlineVariant),
      ),
      labelStyle: GoogleFonts.notoSansArabic(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: colorScheme.onSurfaceVariant,
      ),
      hintStyle: GoogleFonts.notoSansArabic(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
      ),
      errorStyle: GoogleFonts.notoSansArabic(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: colorScheme.error,
      ),
      floatingLabelStyle: GoogleFonts.notoSansArabic(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: colorScheme.primary,
      ),
      prefixIconColor: colorScheme.onSurfaceVariant,
      suffixIconColor: colorScheme.onSurfaceVariant,
    );
  }

  static BottomNavigationBarThemeData _buildBottomNavTheme(ColorScheme colorScheme, {required bool isDark}) {
    return BottomNavigationBarThemeData(
      backgroundColor: colorScheme.surface,
      selectedItemColor: colorScheme.primary,
      unselectedItemColor: colorScheme.onSurfaceVariant,
      type: BottomNavigationBarType.fixed,
      elevation: 8,
      selectedLabelStyle: GoogleFonts.notoSansArabic(
        fontSize: 12,
        fontWeight: FontWeight.w600,
      ),
      unselectedLabelStyle: GoogleFonts.notoSansArabic(
        fontSize: 12,
        fontWeight: FontWeight.w400,
      ),
      showSelectedLabels: true,
      showUnselectedLabels: true,
      landscapeLayout: BottomNavigationBarLandscapeLayout.spread,
    );
  }

  static NavigationBarThemeData _buildNavigationBarTheme(ColorScheme colorScheme, {required bool isDark}) {
    return NavigationBarThemeData(
      backgroundColor: colorScheme.surface,
      surfaceTintColor: colorScheme.surfaceTint,
      indicatorColor: colorScheme.primaryContainer,
      labelTextStyle: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return GoogleFonts.notoSansArabic(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: colorScheme.onPrimaryContainer,
          );
        }
        return GoogleFonts.notoSansArabic(
          fontSize: 12,
          fontWeight: FontWeight.w400,
          color: colorScheme.onSurfaceVariant,
        );
      }),
      iconTheme: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return IconThemeData(
            color: colorScheme.onPrimaryContainer,
            size: 24,
          );
        }
        return IconThemeData(
          color: colorScheme.onSurfaceVariant,
          size: 24,
        );
      }),
      height: 70,
      elevation: 4,
    );
  }

  static TabBarThemeData _buildTabBarTheme(ColorScheme colorScheme) {
    return TabBarThemeData(
      labelColor: colorScheme.primary,
      unselectedLabelColor: colorScheme.onSurfaceVariant,
      indicatorColor: colorScheme.primary,
      indicatorSize: TabBarIndicatorSize.label,
      dividerColor: Colors.transparent,
      labelStyle: GoogleFonts.notoSansArabic(
        fontSize: 14,
        fontWeight: FontWeight.w600,
      ),
      unselectedLabelStyle: GoogleFonts.notoSansArabic(
        fontSize: 14,
        fontWeight: FontWeight.w400,
      ),
      overlayColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.pressed)) {
          return colorScheme.primary.withValues(alpha: 0.1);
        }
        return null;
      }),
    );
  }

  static ChipThemeData _buildChipTheme(ColorScheme colorScheme, {required bool isDark}) {
    return ChipThemeData(
      backgroundColor: colorScheme.surfaceContainerHighest,
      disabledColor: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
      selectedColor: colorScheme.primaryContainer,
      secondarySelectedColor: colorScheme.secondaryContainer,
      padding: const EdgeInsets.symmetric(
        horizontal: AppConstants.spacingMD,
        vertical: AppConstants.spacingXS,
      ),
      labelStyle: GoogleFonts.notoSansArabic(
        fontSize: 13,
        fontWeight: FontWeight.w500,
        color: colorScheme.onSurface,
      ),
      secondaryLabelStyle: GoogleFonts.notoSansArabic(
        fontSize: 13,
        fontWeight: FontWeight.w500,
        color: colorScheme.onSecondaryContainer,
      ),
      brightness: isDark ? Brightness.dark : Brightness.light,
      elevation: 0,
      pressElevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.radiusFull),
        side: BorderSide(color: colorScheme.outlineVariant),
      ),
      selectedShadowColor: colorScheme.primary.withValues(alpha: 0.2),
    );
  }

  static DividerThemeData _buildDividerTheme(ColorScheme colorScheme, {required bool isDark}) {
    return DividerThemeData(
      color: colorScheme.outlineVariant,
      thickness: 0.5,
      space: AppConstants.spacingMD,
      indent: 0,
      endIndent: 0,
    );
  }

  static ListTileThemeData _buildListTileTheme(ColorScheme colorScheme, {required bool isDark}) {
    return ListTileThemeData(
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppConstants.spacingMD,
        vertical: AppConstants.spacingXS,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.radiusMD),
      ),
      tileColor: Colors.transparent,
      selectedTileColor: colorScheme.primaryContainer,
      iconColor: colorScheme.onSurfaceVariant,
      textColor: colorScheme.onSurface,
      titleTextStyle: GoogleFonts.notoSansArabic(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        color: colorScheme.onSurface,
      ),
      subtitleTextStyle: GoogleFonts.notoSansArabic(
        fontSize: 13,
        fontWeight: FontWeight.w400,
        color: colorScheme.onSurfaceVariant,
      ),
      leadingAndTrailingTextStyle: GoogleFonts.notoSansArabic(
        fontSize: 13,
        fontWeight: FontWeight.w400,
        color: colorScheme.onSurfaceVariant,
      ),
      minLeadingWidth: 40,
      horizontalTitleGap: AppConstants.spacingMD,
      minVerticalPadding: AppConstants.spacingSM,
    );
  }

  static DialogThemeData _buildDialogTheme(ColorScheme colorScheme, {required bool isDark}) {
    return DialogThemeData(
      backgroundColor: colorScheme.surface,
      surfaceTintColor: colorScheme.surfaceTint,
      shadowColor: colorScheme.shadow,
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.radiusLG),
      ),
      titleTextStyle: GoogleFonts.amiri(
        fontSize: 22,
        fontWeight: FontWeight.w600,
        color: colorScheme.onSurface,
      ),
      contentTextStyle: GoogleFonts.notoSansArabic(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: colorScheme.onSurface,
      ),
    );
  }

  static BottomSheetThemeData _buildBottomSheetTheme(ColorScheme colorScheme, {required bool isDark}) {
    return BottomSheetThemeData(
      backgroundColor: colorScheme.surface,
      surfaceTintColor: colorScheme.surfaceTint,
      shadowColor: colorScheme.shadow,
      elevation: 8,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppConstants.radiusLG),
        ),
      ),
      modalBackgroundColor: colorScheme.surface,
      dragHandleColor: colorScheme.onSurfaceVariant,
      showDragHandle: true,
    );
  }

  static SnackBarThemeData _buildSnackBarTheme(ColorScheme colorScheme) {
    return SnackBarThemeData(
      backgroundColor: colorScheme.inverseSurface,
      contentTextStyle: GoogleFonts.notoSansArabic(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: colorScheme.onInverseSurface,
      ),
      actionTextColor: colorScheme.secondary,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.radiusMD),
      ),
      behavior: SnackBarBehavior.floating,
      elevation: 4,
      padding: const EdgeInsets.symmetric(
        horizontal: AppConstants.spacingMD,
        vertical: AppConstants.spacingSM,
      ),
    );
  }

  static FloatingActionButtonThemeData _buildFABTheme(ColorScheme colorScheme) {
    return FloatingActionButtonThemeData(
      backgroundColor: colorScheme.primary,
      foregroundColor: colorScheme.onPrimary,
      elevation: 4,
      focusElevation: 6,
      hoverElevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.radiusLG),
      ),
      extendedIconLabelSpacing: AppConstants.spacingSM,
    );
  }

  static ProgressIndicatorThemeData _buildProgressIndicatorTheme(ColorScheme colorScheme) {
    return ProgressIndicatorThemeData(
      color: colorScheme.primary,
      linearTrackColor: colorScheme.primaryContainer,
      circularTrackColor: colorScheme.primaryContainer,
    );
  }

  static SliderThemeData _buildSliderTheme(ColorScheme colorScheme) {
    return SliderThemeData(
      activeTrackColor: colorScheme.primary,
      inactiveTrackColor: colorScheme.primaryContainer,
      thumbColor: colorScheme.primary,
      overlayColor: colorScheme.primary.withValues(alpha: 0.15),
      valueIndicatorColor: colorScheme.primary,
      valueIndicatorTextStyle: GoogleFonts.notoSansArabic(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: colorScheme.onPrimary,
      ),
      trackHeight: 4,
      thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 10),
      overlayShape: const RoundSliderOverlayShape(overlayRadius: 20),
    );
  }

  static SwitchThemeData _buildSwitchTheme(ColorScheme colorScheme) {
    return SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return colorScheme.primary;
        }
        return colorScheme.outline;
      }),
      trackColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return colorScheme.primaryContainer;
        }
        return colorScheme.surfaceContainerHighest;
      }),
      trackOutlineColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return colorScheme.primary;
        }
        return colorScheme.outlineVariant;
      }),
    );
  }

  static CheckboxThemeData _buildCheckboxTheme(ColorScheme colorScheme) {
    return CheckboxThemeData(
      fillColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return colorScheme.primary;
        }
        return Colors.transparent;
      }),
      checkColor: WidgetStateProperty.all(colorScheme.onPrimary),
      side: BorderSide(color: colorScheme.outline, width: 2),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.radiusSM),
      ),
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );
  }

  static RadioThemeData _buildRadioTheme(ColorScheme colorScheme) {
    return RadioThemeData(
      fillColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return colorScheme.primary;
        }
        return colorScheme.outline;
      }),
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );
  }

  static TooltipThemeData _buildTooltipTheme(ColorScheme colorScheme, {required bool isDark}) {
    return TooltipThemeData(
      decoration: BoxDecoration(
        color: colorScheme.inverseSurface,
        borderRadius: BorderRadius.circular(AppConstants.radiusSM),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      textStyle: GoogleFonts.notoSansArabic(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: colorScheme.onInverseSurface,
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: AppConstants.spacingMD,
        vertical: AppConstants.spacingSM,
      ),
      preferBelow: true,
      verticalOffset: AppConstants.spacingSM,
    );
  }

  static PopupMenuThemeData _buildPopupMenuTheme(ColorScheme colorScheme, {required bool isDark}) {
    return PopupMenuThemeData(
      color: colorScheme.surface,
      surfaceTintColor: colorScheme.surfaceTint,
      shadowColor: colorScheme.shadow,
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.radiusMD),
      ),
      labelTextStyle: GoogleFonts.notoSansArabic(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: colorScheme.onSurface,
      ),
    );
  }
}

/// Custom theme extension for Quran/Hadith specific colors
class _QuranHadithThemeExtension extends ThemeExtension<_QuranHadithThemeExtension> {
  final Color bismillahColor;
  final Color ayahNumberColor;
  final Color sajdahColor;
  final Color juzMarkerColor;
  final Color bookmarkColor;
  final Color hadithGradeSahih;
  final Color hadithGradeHasan;
  final Color hadithGradeDaif;
  final Color searchHighlightColor;
  final Gradient quranGradient;
  final Gradient hadithGradient;

  const _QuranHadithThemeExtension({
    required this.bismillahColor,
    required this.ayahNumberColor,
    required this.sajdahColor,
    required this.juzMarkerColor,
    required this.bookmarkColor,
    required this.hadithGradeSahih,
    required this.hadithGradeHasan,
    required this.hadithGradeDaif,
    required this.searchHighlightColor,
    required this.quranGradient,
    required this.hadithGradient,
  });

  factory _QuranHadithThemeExtension.light() {
    return const _QuranHadithThemeExtension(
      bismillahColor: Color(0xFF006D4C),
      ayahNumberColor: Color(0xFFD4A843),
      sajdahColor: Color(0xFFC62828),
      juzMarkerColor: Color(0xFF1565C0),
      bookmarkColor: Color(0xFFD4A843),
      hadithGradeSahih: Color(0xFF2E7D32),
      hadithGradeHasan: Color(0xFF1565C0),
      hadithGradeDaif: Color(0xFFC62828),
      searchHighlightColor: Color(0xFFFFF3B0),
      quranGradient: LinearGradient(
        colors: [Color(0xFF006D4C), Color(0xFF004D35)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      hadithGradient: LinearGradient(
        colors: [Color(0xFFD4A843), Color(0xFFB89038)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
    );
  }

  factory _QuranHadithThemeExtension.dark() {
    return const _QuranHadithThemeExtension(
      bismillahColor: Color(0xFF1A8A6B),
      ayahNumberColor: Color(0xFFE8C56D),
      sajdahColor: Color(0xFFEF5350),
      juzMarkerColor: Color(0xFF64B5F6),
      bookmarkColor: Color(0xFFE8C56D),
      hadithGradeSahih: Color(0xFF66BB6A),
      hadithGradeHasan: Color(0xFF42A5F5),
      hadithGradeDaif: Color(0xFFEF5350),
      searchHighlightColor: Color(0xFF3D3D20),
      quranGradient: LinearGradient(
        colors: [Color(0xFF004D35), Color(0xFF003322)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      hadithGradient: LinearGradient(
        colors: [Color(0xFFB89038), Color(0xFF8B6D28)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
    );
  }

  @override
  _QuranHadithThemeExtension copyWith({
    Color? bismillahColor,
    Color? ayahNumberColor,
    Color? sajdahColor,
    Color? juzMarkerColor,
    Color? bookmarkColor,
    Color? hadithGradeSahih,
    Color? hadithGradeHasan,
    Color? hadithGradeDaif,
    Color? searchHighlightColor,
    Gradient? quranGradient,
    Gradient? hadithGradient,
  }) {
    return _QuranHadithThemeExtension(
      bismillahColor: bismillahColor ?? this.bismillahColor,
      ayahNumberColor: ayahNumberColor ?? this.ayahNumberColor,
      sajdahColor: sajdahColor ?? this.sajdahColor,
      juzMarkerColor: juzMarkerColor ?? this.juzMarkerColor,
      bookmarkColor: bookmarkColor ?? this.bookmarkColor,
      hadithGradeSahih: hadithGradeSahih ?? this.hadithGradeSahih,
      hadithGradeHasan: hadithGradeHasan ?? this.hadithGradeHasan,
      hadithGradeDaif: hadithGradeDaif ?? this.hadithGradeDaif,
      searchHighlightColor: searchHighlightColor ?? this.searchHighlightColor,
      quranGradient: quranGradient ?? this.quranGradient,
      hadithGradient: hadithGradient ?? this.hadithGradient,
    );
  }

  @override
  _QuranHadithThemeExtension lerp(ThemeExtension<_QuranHadithThemeExtension>? other, double t) {
    if (other is! _QuranHadithThemeExtension) return this;
    return _QuranHadithThemeExtension(
      bismillahColor: Color.lerp(bismillahColor, other.bismillahColor, t)!,
      ayahNumberColor: Color.lerp(ayahNumberColor, other.ayahNumberColor, t)!,
      sajdahColor: Color.lerp(sajdahColor, other.sajdahColor, t)!,
      juzMarkerColor: Color.lerp(juzMarkerColor, other.juzMarkerColor, t)!,
      bookmarkColor: Color.lerp(bookmarkColor, other.bookmarkColor, t)!,
      hadithGradeSahih: Color.lerp(hadithGradeSahih, other.hadithGradeSahih, t)!,
      hadithGradeHasan: Color.lerp(hadithGradeHasan, other.hadithGradeHasan, t)!,
      hadithGradeDaif: Color.lerp(hadithGradeDaif, other.hadithGradeDaif, t)!,
      searchHighlightColor: Color.lerp(searchHighlightColor, other.searchHighlightColor, t)!,
      quranGradient: Gradient.lerp(quranGradient, other.quranGradient, t)!,
      hadithGradient: Gradient.lerp(hadithGradient, other.hadithGradient, t)!,
    );
  }
}

/// Extension to easily access the custom theme
extension QuranHadithTheme on ThemeData {
  _QuranHadithThemeExtension get quranHadith => extension<_QuranHadithThemeExtension>()!;
}