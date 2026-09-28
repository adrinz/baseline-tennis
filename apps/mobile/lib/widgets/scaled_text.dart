import 'package:flutter/material.dart';

/// Body and title text that follows the system text size from [MediaQuery].
class ScaledText extends StatelessWidget {
  const ScaledText(
    this.data, {
    super.key,
    this.style,
    this.maxLines,
    this.textAlign,
  });

  final String data;
  final TextStyle? style;
  final int? maxLines;
  final TextAlign? textAlign;

  @override
  Widget build(BuildContext context) {
    return Text(
      data,
      style: style,
      maxLines: maxLines,
      overflow: maxLines == null ? null : TextOverflow.ellipsis,
      textAlign: textAlign,
      textScaler: MediaQuery.textScalerOf(context),
    );
  }
}
