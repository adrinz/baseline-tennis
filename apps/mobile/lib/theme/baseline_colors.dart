import 'package:flutter/material.dart';

/// Brand tokens from the design system.
///
/// Night court is chrome (welcome, tab bar, hero cards), not the page.
/// Cream (`line`) is the page. The ball marks the next action on a dark surface.
class BaselineColors extends ThemeExtension<BaselineColors> {
  const BaselineColors();

  static const nightCourt = Color(0xFF10211C);
  static const fairway = Color(0xFF1F7A4D);
  static const ball = Color(0xFFE4F56A);
  static const clay = Color(0xFFC46B4A);
  static const line = Color(0xFFF4F1EA);
  static const ink = Color(0xFF14211C);
  static const muted = Color(0xFF5E6B66);
  static const card = Color(0xFFFFFCF7);
  static const mist = Color(0xFFC3CFC8);
  static const track = Color(0xFFE3E6E1);
  static const fairwayPressed = Color(0xFF18643F);
  static const clayDeep = Color(0xFF7A3424);
  static const nightRaised = Color(0xFF173028);
  static const nightGlow = Color(0xFF1F4A3B);
  static const fairwaySoft = Color(0xFFE2F0E7);
  static const claySoft = Color(0xFFF7E6DD);
  static const ballSoft = Color(0xFFF3F9C8);

  @override
  BaselineColors copyWith() => const BaselineColors();

  @override
  BaselineColors lerp(ThemeExtension<BaselineColors>? other, double t) => this;
}

abstract final class BaselineShadows {
  static final card = [
    BoxShadow(
      color: BaselineColors.nightCourt.withValues(alpha: 0.06),
      blurRadius: 18,
      offset: const Offset(0, 8),
    ),
    BoxShadow(
      color: BaselineColors.nightCourt.withValues(alpha: 0.04),
      blurRadius: 3,
      offset: const Offset(0, 1),
    ),
  ];

  static final lift = [
    BoxShadow(
      color: BaselineColors.nightCourt.withValues(alpha: 0.28),
      blurRadius: 28,
      offset: const Offset(0, 14),
    ),
  ];
}

/// Minimum interactive size. 48dp sits above the 44pt floor.
const double kMinTapTarget = 48;
