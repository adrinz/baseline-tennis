import 'package:baseline/theme/baseline_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

ThemeData buildBaselineTheme() {
  const line = BaselineColors.line;
  const ink = BaselineColors.ink;
  const fairway = BaselineColors.fairway;
  const night = BaselineColors.nightCourt;
  const ball = BaselineColors.ball;

  const textTheme = TextTheme(
    displayLarge: TextStyle(
      fontFamily: 'Barlow Condensed',
      fontSize: 40,
      height: 1.05,
      fontWeight: FontWeight.w600,
      letterSpacing: -0.5,
      color: ink,
    ),
    headlineMedium: TextStyle(
      fontFamily: 'Barlow Condensed',
      fontSize: 28,
      height: 1.1,
      fontWeight: FontWeight.w600,
      letterSpacing: -0.3,
      color: ink,
    ),
    headlineSmall: TextStyle(
      fontFamily: 'Barlow Condensed',
      fontSize: 24,
      height: 1.15,
      fontWeight: FontWeight.w600,
      color: ink,
    ),
    titleLarge: TextStyle(
      fontFamily: 'Source Sans 3',
      fontSize: 20,
      height: 1.25,
      fontWeight: FontWeight.w600,
      color: ink,
    ),
    titleMedium: TextStyle(
      fontFamily: 'Source Sans 3',
      fontSize: 17,
      height: 1.3,
      fontWeight: FontWeight.w600,
      color: ink,
    ),
    bodyLarge: TextStyle(
      fontFamily: 'Source Sans 3',
      fontSize: 17,
      height: 1.45,
      color: ink,
    ),
    bodyMedium: TextStyle(
      fontFamily: 'Source Sans 3',
      fontSize: 15,
      height: 1.4,
      color: ink,
    ),
    bodySmall: TextStyle(
      fontFamily: 'Source Sans 3',
      fontSize: 13,
      height: 1.35,
      fontWeight: FontWeight.w500,
      color: BaselineColors.muted,
    ),
    labelLarge: TextStyle(
      fontFamily: 'Source Sans 3',
      fontSize: 17,
      height: 1.2,
      fontWeight: FontWeight.w600,
      letterSpacing: 0.1,
      color: ink,
    ),
    labelMedium: TextStyle(
      fontFamily: 'Barlow Condensed',
      fontSize: 13,
      height: 1.2,
      fontWeight: FontWeight.w600,
      letterSpacing: 1.4,
      color: BaselineColors.muted,
    ),
  );

  return ThemeData(
    useMaterial3: true,
    fontFamily: 'Source Sans 3',
    brightness: Brightness.light,
    scaffoldBackgroundColor: line,
    extensions: const [BaselineColors()],
    colorScheme: const ColorScheme.light(
      primary: fairway,
      onPrimary: line,
      secondary: night,
      onSecondary: line,
      tertiary: ball,
      onTertiary: ink,
      surface: line,
      onSurface: ink,
      error: BaselineColors.clayDeep,
      onError: line,
    ),
    textTheme: textTheme,
    appBarTheme: const AppBarTheme(
      backgroundColor: line,
      foregroundColor: ink,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
      systemOverlayStyle: SystemUiOverlayStyle.dark,
    ),
    dividerColor: ink.withValues(alpha: 0.16),
    progressIndicatorTheme: const ProgressIndicatorThemeData(
      color: fairway,
      linearTrackColor: BaselineColors.track,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: BaselineColors.card,
      hintStyle: const TextStyle(color: BaselineColors.muted),
      labelStyle: const TextStyle(color: ink, fontWeight: FontWeight.w600),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: ink.withValues(alpha: 0.16)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: ink.withValues(alpha: 0.16)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: fairway, width: 2),
      ),
    ),
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.all(BaselineColors.card),
      trackColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) return fairway;
        return BaselineColors.track;
      }),
    ),
  );
}

abstract final class BaselineType {
  static const eyebrow = TextStyle(
    fontFamily: 'Barlow Condensed',
    fontSize: 13,
    fontWeight: FontWeight.w600,
    letterSpacing: 1.4,
    color: BaselineColors.muted,
  );

  static const eyebrowFairway = eyebrow;

  static const eyebrowOnNight = TextStyle(
    fontFamily: 'Barlow Condensed',
    fontSize: 13,
    fontWeight: FontWeight.w600,
    letterSpacing: 1.4,
    color: BaselineColors.ball,
  );

  static const cardTitle = TextStyle(
    fontFamily: 'Source Sans 3',
    fontSize: 17,
    height: 1.3,
    fontWeight: FontWeight.w600,
    color: BaselineColors.ink,
  );

  static const cardBody = TextStyle(
    fontFamily: 'Source Sans 3',
    fontSize: 17,
    height: 1.45,
    color: BaselineColors.ink,
  );

  static const cardMuted = TextStyle(
    fontFamily: 'Source Sans 3',
    fontSize: 13,
    height: 1.35,
    fontWeight: FontWeight.w500,
    color: BaselineColors.muted,
  );
}
