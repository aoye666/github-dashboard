import 'package:flutter/material.dart';

/// 应用主题 - 浅绿色主色调 + 毛玻璃效果
class AppTheme {
  // ============ 主色调 ============
  static const Color primaryGreen = Color(0xFF4CAF50);
  static const Color lightGreen = Color(0xFF81C784);
  static const Color darkGreen = Color(0xFF388E3C);
  static const Color accentGreen = Color(0xFFA5D6A7);
  
  // ============ 背景色 ============
  static const Color darkBg = Color(0xFF0F1A14);
  static const Color darkSurface = Color(0xFF1A2B22);
  static const Color lightBg = Color(0xFFF0F5F2);
  static const Color lightSurface = Color(0xFFFFFFFF);
  
  // ============ 毛玻璃参数 ============
  static const double glassBlur = 20.0;
  static const double glassOpacity = 0.15;
  static const double glassBorderOpacity = 0.2;
  static const double glassSaturate = 1.8;

  // ============ 深色主题 ============
  static ThemeData get darkTheme => ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: ColorScheme.dark(
      primary: primaryGreen,
      secondary: lightGreen,
      surface: darkSurface,
      background: darkBg,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: Colors.white,
      onBackground: Colors.white,
    ),
    scaffoldBackgroundColor: darkBg,
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: TextStyle(
        fontFamily: 'SpaceGrotesk',
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: Colors.white,
      ),
    ),
    textTheme: TextTheme(
      displayLarge: TextStyle(fontFamily: 'SpaceGrotesk', fontWeight: FontWeight.w700, fontSize: 32),
      displayMedium: TextStyle(fontFamily: 'SpaceGrotesk', fontWeight: FontWeight.w700, fontSize: 28),
      headlineLarge: TextStyle(fontFamily: 'SpaceGrotesk', fontWeight: FontWeight.w700, fontSize: 24),
      headlineMedium: TextStyle(fontFamily: 'SpaceGrotesk', fontWeight: FontWeight.w600, fontSize: 20),
      titleLarge: TextStyle(fontFamily: 'SpaceGrotesk', fontWeight: FontWeight.w600, fontSize: 18),
      titleMedium: TextStyle(fontFamily: 'SpaceGrotesk', fontWeight: FontWeight.w500, fontSize: 16),
      bodyLarge: TextStyle(fontFamily: 'SpaceGrotesk', fontWeight: FontWeight.w400, fontSize: 16),
      bodyMedium: TextStyle(fontFamily: 'SpaceGrotesk', fontWeight: FontWeight.w400, fontSize: 14),
      labelLarge: TextStyle(fontFamily: 'SpaceGrotesk', fontWeight: FontWeight.w500, fontSize: 14),
    ),
    cardTheme: CardTheme(
      color: Colors.white.withOpacity(0.06),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.white.withOpacity(0.1)),
      ),
    ),
    iconTheme: IconThemeData(color: primaryGreen),
    dividerTheme: DividerThemeData(
      color: Colors.white.withOpacity(0.1),
      thickness: 1,
    ),
  );

  // ============ 浅色主题 ============
  static ThemeData get lightTheme => ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorScheme: ColorScheme.light(
      primary: darkGreen,
      secondary: primaryGreen,
      surface: lightSurface,
      background: lightBg,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: Colors.black87,
      onBackground: Colors.black87,
    ),
    scaffoldBackgroundColor: lightBg,
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: TextStyle(
        fontFamily: 'SpaceGrotesk',
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: Colors.black87,
      ),
    ),
    textTheme: TextTheme(
      displayLarge: TextStyle(fontFamily: 'SpaceGrotesk', fontWeight: FontWeight.w700, fontSize: 32),
      displayMedium: TextStyle(fontFamily: 'SpaceGrotesk', fontWeight: FontWeight.w700, fontSize: 28),
      headlineLarge: TextStyle(fontFamily: 'SpaceGrotesk', fontWeight: FontWeight.w700, fontSize: 24),
      headlineMedium: TextStyle(fontFamily: 'SpaceGrotesk', fontWeight: FontWeight.w600, fontSize: 20),
      titleLarge: TextStyle(fontFamily: 'SpaceGrotesk', fontWeight: FontWeight.w600, fontSize: 18),
      titleMedium: TextStyle(fontFamily: 'SpaceGrotesk', fontWeight: FontWeight.w500, fontSize: 16),
      bodyLarge: TextStyle(fontFamily: 'SpaceGrotesk', fontWeight: FontWeight.w400, fontSize: 16),
      bodyMedium: TextStyle(fontFamily: 'SpaceGrotesk', fontWeight: FontWeight.w400, fontSize: 14),
      labelLarge: TextStyle(fontFamily: 'SpaceGrotesk', fontWeight: FontWeight.w500, fontSize: 14),
    ),
    cardTheme: CardTheme(
      color: Colors.white.withOpacity(0.7),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.black.withOpacity(0.05)),
      ),
    ),
    iconTheme: IconThemeData(color: darkGreen),
    dividerTheme: DividerThemeData(
      color: Colors.black.withOpacity(0.08),
      thickness: 1,
    ),
  );

  // ============ 装饰方法 ============
  
  /// 毛玻璃卡片装饰
  static BoxDecoration glassDecoration({bool isDark = true, double borderRadius = 16}) {
    return BoxDecoration(
      color: isDark 
        ? Colors.white.withOpacity(glassOpacity)
        : Colors.white.withOpacity(0.6),
      borderRadius: BorderRadius.circular(borderRadius),
      border: Border.all(
        color: isDark 
          ? Colors.white.withOpacity(glassBorderOpacity)
          : Colors.black.withOpacity(0.06),
      ),
      boxShadow: [
        BoxShadow(
          color: isDark 
            ? Colors.black.withOpacity(0.3)
            : Colors.black.withOpacity(0.08),
          blurRadius: 20,
          offset: Offset(0, 8),
        ),
      ],
    );
  }

  /// 渐变背景装饰
  static BoxDecoration gradientDecoration({bool isDark = true}) {
    return BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: isDark
          ? [Color(0xFF0F1A14), Color(0xFF1A2B22), Color(0xFF0D1910)]
          : [Color(0xFFF0F5F2), Color(0xFFE8F0EA), Color(0xFFF5FAF7)],
      ),
    );
  }
  
  /// 发光效果装饰
  static BoxDecoration glowDecoration({bool isDark = true}) {
    return BoxDecoration(
      color: primaryGreen.withOpacity(0.1),
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: primaryGreen.withOpacity(0.3)),
      boxShadow: [
        BoxShadow(
          color: primaryGreen.withOpacity(isDark ? 0.2 : 0.15),
          blurRadius: 20,
          spreadRadius: 0,
        ),
      ],
    );
  }
}
