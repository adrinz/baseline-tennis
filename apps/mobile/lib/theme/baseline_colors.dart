import 'package:flutter/material.dart';

/// Brand tokens from the design system.
///
/// Night court is chrome (welcome, tab bar, paywall), not the page.
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

  @override
  BaselineColors copyWith() => const BaselineColors();

  @override
  BaselineColors lerp(ThemeExtension<BaselineColors>? other, double t) => this;
}

/// Minimum interactive size. 48dp sits above the 44pt floor.
const double kMinTapTarget = 48;
