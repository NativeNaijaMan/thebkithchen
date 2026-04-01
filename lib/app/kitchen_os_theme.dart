import 'package:flutter/material.dart';

/// Design tokens from `documentation/DesignLanguage.md`.
abstract final class KitchenOsColors {
  static const Color countertopOffWhite = Color(0xFFF4F5F7);
  static const Color receiptWhite = Color(0xFFFFFFFF);
  static const Color terminalCharcoal = Color(0xFF2B2D42);
  static const Color yolkYellow = Color(0xFFFF9F1C);
  static const Color mintAppliance = Color(0xFFA8DADC);
  static const Color panicRed = Color(0xFFE63946);
  static const Color bsodBlue = Color(0xFF1D3557);
  static const Color successGreen = Color(0xFF2A9D8F);
}

/// Space Mono per Design Language (local fonts in pubspec).
ThemeData buildKitchenOsTheme() {
  const mono = 'SpaceMono';
  return ThemeData(
    useMaterial3: true,
    fontFamily: mono,
    scaffoldBackgroundColor: KitchenOsColors.countertopOffWhite,
    colorScheme: ColorScheme.light(
      primary: KitchenOsColors.yolkYellow,
      onPrimary: KitchenOsColors.terminalCharcoal,
      secondary: KitchenOsColors.mintAppliance,
      onSecondary: KitchenOsColors.terminalCharcoal,
      surface: KitchenOsColors.receiptWhite,
      onSurface: KitchenOsColors.terminalCharcoal,
      error: KitchenOsColors.panicRed,
      onError: KitchenOsColors.receiptWhite,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: KitchenOsColors.bsodBlue,
      foregroundColor: KitchenOsColors.receiptWhite,
      elevation: 0,
      centerTitle: false,
      titleTextStyle: TextStyle(
        fontFamily: mono,
        fontWeight: FontWeight.w700,
        fontSize: 20,
        letterSpacing: 1.5,
        color: KitchenOsColors.receiptWhite,
      ),
    ),
    textTheme: const TextTheme(
      headlineLarge: TextStyle(
        fontFamily: mono,
        fontWeight: FontWeight.w700,
        fontSize: 32,
        letterSpacing: 1.5,
      ),
      headlineMedium: TextStyle(
        fontFamily: mono,
        fontWeight: FontWeight.w400,
        fontSize: 24,
      ),
      titleLarge: TextStyle(
        fontFamily: mono,
        fontWeight: FontWeight.w700,
        fontSize: 18,
      ),
      bodyLarge: TextStyle(
        fontFamily: mono,
        fontWeight: FontWeight.w400,
        fontSize: 16,
      ),
      bodySmall: TextStyle(
        fontFamily: mono,
        fontWeight: FontWeight.w400,
        fontSize: 10,
      ),
      labelLarge: TextStyle(
        fontFamily: mono,
        fontWeight: FontWeight.w700,
        fontSize: 18,
      ),
    ),
  );
}
