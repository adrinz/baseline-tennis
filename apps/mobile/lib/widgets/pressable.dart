import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// A light tick on taps. Failures on platforms without haptics are ignored.
void tapFeedback() {
  unawaited(HapticFeedback.selectionClick().catchError((_) {}));
}

void successFeedback() {
  unawaited(HapticFeedback.mediumImpact().catchError((_) {}));
}

/// Shrinks its child slightly while a finger is down.
///
/// Uses a raw pointer listener, so it never competes with taps or scrolls.
class PressScale extends StatefulWidget {
  const PressScale({
    super.key,
    required this.child,
    this.enabled = true,
    this.scale = 0.97,
  });

  final Widget child;
  final bool enabled;
  final double scale;

  @override
  State<PressScale> createState() => _PressScaleState();
}

class _PressScaleState extends State<PressScale> {
  var _down = false;

  void _set(bool value) {
    if (_down == value || !mounted) return;
    setState(() => _down = value);
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      behavior: HitTestBehavior.translucent,
      onPointerDown: (_) => _set(true),
      onPointerUp: (_) => _set(false),
      onPointerCancel: (_) => _set(false),
      child: AnimatedScale(
        scale: _down && widget.enabled ? widget.scale : 1,
        duration: const Duration(milliseconds: 110),
        curve: Curves.easeOut,
        child: widget.child,
      ),
    );
  }
}
