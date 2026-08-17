// lib/core/theme/app_theme.dart
// 妈祖红 + 米白 + 金箔黄 主调

import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // 主色
  static const Color mazuRed = Color(0xFFB83C2C);
  static const Color mazuRedDark = Color(0xFF8C2E22);
  static const Color goldYellow = Color(0xFFD4A24C);
  static const Color inkBlack = Color(0xFF2A2722);
  static const Color riceWhite = Color(0xFFF8F4EC);
  static const Color riceWhiteDark = Color(0xFFEDE5D3);

  // 辅色
  static const Color warningRed = Color(0xFFC44545);
  static const Color hintYellow = Color(0xFFD9A23B);
  static const Color successGreen = Color(0xFF5A7A3F);
  static const Color gray = Color(0xFF8A857A);
  static const Color lightGray = Color(0xFFD8D2C5);

  // 暗色主题专用
  static const Color darkBg = Color(0xFF1A1714);          // 玄夜黑
  static const Color darkSurface = Color(0xFF25211C);
  static const Color darkSurfaceAlt = Color(0xFF2E2924);
  static const Color darkDivider = Color(0xFF3A342D);
  static const Color darkText = Color(0xFFE8DFCF);
  static const Color darkTextMuted = Color(0xFF9A9080);

  // 等级色
  static const Color levelUpperUpper = Color(0xFFD4A24C);   // 上上 - 金
  static const Color levelUpper = Color(0xFFC0904A);        // 上中 - 暗金
  static const Color levelMidUpper = Color(0xFFA7A050);     // 中上 - 黄绿
  static const Color levelMid = Color(0xFF8A857A);          // 中中 - 灰
  static const Color levelMidLower = Color(0xFFA8836A);     // 中下 - 棕
  static const Color levelLowerUpper = Color(0xFF8B5A3C);   // 下上 - 暗棕
  static const Color levelLower = Color(0xFFA04E3F);        // 下中 - 暗红
  static const Color levelLowerLower = Color(0xFF6B2C2C);   // 下下 - 深红
}

class AppTheme {
  AppTheme._();

  static ThemeData get light {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      primaryColor: AppColors.mazuRed,
      scaffoldBackgroundColor: AppColors.riceWhite,
      colorScheme: const ColorScheme.light(
        primary: AppColors.mazuRed,
        onPrimary: Colors.white,
        secondary: AppColors.goldYellow,
        onSecondary: AppColors.inkBlack,
        surface: AppColors.riceWhite,
        onSurface: AppColors.inkBlack,
        error: AppColors.warningRed,
        onError: Colors.white,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.riceWhite,
        foregroundColor: AppColors.inkBlack,
        elevation: 0,
        centerTitle: true,
      ),
      textTheme: _textTheme,
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.mazuRed,
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 56),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.1,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.inkBlack,
          minimumSize: const Size(double.infinity, 48),
          side: const BorderSide(color: AppColors.lightGray, width: 1.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.lightGray),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.lightGray),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.mazuRed, width: 2),
        ),
        labelStyle: const TextStyle(color: AppColors.gray),
        hintStyle: const TextStyle(color: AppColors.gray),
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.lightGray,
        thickness: 1,
        space: 1,
      ),
      cardTheme: CardThemeData(
        color: Colors.white,
        elevation: 2,
        shadowColor: Colors.black.withOpacity(0.06),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }

  /// 玄夜黑（暗色主题）
  static ThemeData get dark {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      primaryColor: AppColors.mazuRed,
      scaffoldBackgroundColor: AppColors.darkBg,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.mazuRed,
        onPrimary: Colors.white,
        secondary: AppColors.goldYellow,
        onSecondary: AppColors.inkBlack,
        surface: AppColors.darkSurface,
        onSurface: AppColors.darkText,
        error: AppColors.warningRed,
        onError: Colors.white,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.darkBg,
        foregroundColor: AppColors.darkText,
        elevation: 0,
        centerTitle: true,
      ),
      textTheme: _textThemeDark,
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.mazuRed,
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 56),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.1,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.darkText,
          minimumSize: const Size(double.infinity, 48),
          side: const BorderSide(color: AppColors.darkDivider, width: 1.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.darkSurfaceAlt,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.darkDivider),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.darkDivider),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.mazuRed, width: 2),
        ),
        labelStyle: const TextStyle(color: AppColors.darkTextMuted),
        hintStyle: const TextStyle(color: AppColors.darkTextMuted),
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.darkDivider,
        thickness: 1,
        space: 1,
      ),
      cardTheme: CardThemeData(
        color: AppColors.darkSurface,
        elevation: 2,
        shadowColor: Colors.black.withOpacity(0.4),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      iconTheme: const IconThemeData(color: AppColors.darkText),
    );
  }

  static TextTheme get _textTheme {
    // 标题/正文统一用寒蝉锦书宋（ChillJinshuSong）—— 中文宋体，古典感
    // 见 pubspec.yaml 中注册的 fonts
    final textSerif = const TextStyle(
      fontFamily: 'ChillJinshuSong',
      color: AppColors.inkBlack,
    );

    return TextTheme(
      displayLarge: textSerif.copyWith(fontSize: 36, fontWeight: FontWeight.w700),
      displayMedium: textSerif.copyWith(fontSize: 32, fontWeight: FontWeight.w700),
      displaySmall: textSerif.copyWith(fontSize: 28, fontWeight: FontWeight.w700),
      headlineLarge: textSerif.copyWith(fontSize: 28, fontWeight: FontWeight.w600),
      headlineMedium: textSerif.copyWith(fontSize: 24, fontWeight: FontWeight.w600),
      headlineSmall: textSerif.copyWith(fontSize: 20, fontWeight: FontWeight.w600),
      titleLarge: textSerif.copyWith(fontSize: 20, fontWeight: FontWeight.w600),
      titleMedium: textSerif.copyWith(fontSize: 18, fontWeight: FontWeight.w600),
      titleSmall: textSerif.copyWith(fontSize: 16, fontWeight: FontWeight.w500),
      bodyLarge: textSerif.copyWith(fontSize: 18),
      bodyMedium: textSerif.copyWith(fontSize: 16),
      bodySmall: textSerif.copyWith(fontSize: 14, color: AppColors.gray),
      labelLarge: textSerif.copyWith(fontSize: 16, fontWeight: FontWeight.w600),
      labelMedium: textSerif.copyWith(fontSize: 14),
      labelSmall: textSerif.copyWith(fontSize: 12, color: AppColors.gray),
    );
  }

  static TextTheme get _textThemeDark {
    final textSerif = const TextStyle(
      fontFamily: 'ChillJinshuSong',
      color: AppColors.darkText,
    );

    return TextTheme(
      displayLarge: textSerif.copyWith(fontSize: 36, fontWeight: FontWeight.w700),
      displayMedium: textSerif.copyWith(fontSize: 32, fontWeight: FontWeight.w700),
      displaySmall: textSerif.copyWith(fontSize: 28, fontWeight: FontWeight.w700),
      headlineLarge: textSerif.copyWith(fontSize: 28, fontWeight: FontWeight.w600),
      headlineMedium: textSerif.copyWith(fontSize: 24, fontWeight: FontWeight.w600),
      headlineSmall: textSerif.copyWith(fontSize: 20, fontWeight: FontWeight.w600),
      titleLarge: textSerif.copyWith(fontSize: 20, fontWeight: FontWeight.w600),
      titleMedium: textSerif.copyWith(fontSize: 18, fontWeight: FontWeight.w600),
      titleSmall: textSerif.copyWith(fontSize: 16, fontWeight: FontWeight.w500),
      bodyLarge: textSerif.copyWith(fontSize: 18),
      bodyMedium: textSerif.copyWith(fontSize: 16),
      bodySmall: textSerif.copyWith(fontSize: 14, color: AppColors.darkTextMuted),
      labelLarge: textSerif.copyWith(fontSize: 16, fontWeight: FontWeight.w600),
      labelMedium: textSerif.copyWith(fontSize: 14),
      labelSmall: textSerif.copyWith(fontSize: 12, color: AppColors.darkTextMuted),
    );
  }
}
