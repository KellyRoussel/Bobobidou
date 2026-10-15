import 'package:flutter/material.dart';

import '../../theme/bobo_tokens.dart';

/// How strongly an ingredient is linked to pain episodes, relative to the
/// most frequent one. Always shown with its word, never by color alone.
enum Severity {
  low('severity_low', BoboColors.lagon, BoboColors.lagonTendre, Color(0xFF23697D)),
  moderate('severity_moderate', BoboColors.soleil, BoboColors.soleilTendre, Color(0xFF8A5A00)),
  elevated('severity_elevated', BoboColors.corail, BoboColors.corailTendre, BoboColors.corailProfond),
  high('severity_high', BoboColors.corailProfond, BoboColors.corailTendre, BoboColors.corailProfond);

  const Severity(this.labelKey, this.fill, this.tint, this.text);

  final String labelKey;
  /// Bars and marks.
  final Color fill;
  /// Badge backgrounds.
  final Color tint;
  /// Text on [tint].
  final Color text;

  /// [ratio] is the ingredient's count divided by the highest count.
  static Severity of(double ratio) {
    if (ratio > 0.75) return Severity.high;
    if (ratio > 0.5) return Severity.elevated;
    if (ratio > 0.25) return Severity.moderate;
    return Severity.low;
  }
}
