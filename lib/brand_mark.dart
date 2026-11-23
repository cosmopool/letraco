import 'package:flutter/material.dart';
import 'package:letraco/theme.dart';

/// One letter of the app icon, in the 108 × 108 dp adaptive icon canvas.
///
/// [x] and [y] are the glyph origin: left edge of the advance, on the
/// baseline. [blur] is a gaussian deviation in canvas units.
class MarkLetter {
  const MarkLetter(
    this.char,
    this.x,
    this.y,
    this.size,
    this.color, {
    this.opacity = 1,
    this.blur = 0,
  });

  final String char;
  final double x;
  final double y;
  final double size;
  final Color color;
  final double opacity;
  final double blur;
}

/// The app icon: a near "L", the "ç" in its corner, and the rest of the name
/// far behind them.
///
/// Same layout as `assets/images/foreground.png` (exported from
/// `proposta_icone_splash_3.html` with Noto Serif bold, the serif Android
/// uses), so the splash can start from the exact system splash frame.
abstract final class BrandMark {
  /// Side of the adaptive icon canvas, in dp.
  static const canvas = 108.0;

  /// Side the Android 12+ system splash draws the icon foreground at, in dp.
  static const splashSize = 288.0;

  static const initial = MarkLetter('L', 35.36, 78, 57.34, Caderno.ink);
  static const cedilla = MarkLetter('ç', 52.53, 65.28, 28.67, Caderno.brand);

  /// The other letters of "Letraço", far behind: smaller, paler, softer.
  static const far = [
    MarkLetter('e', 45.41, 32.65, 13, Caderno.muted, opacity: .58, blur: .3),
    MarkLetter('t', 66.77, 33.65, 11.5, Caderno.muted, opacity: .5, blur: .45),
    MarkLetter('r', 62.26, 43.1, 12, Caderno.muted, opacity: .54, blur: .4),
    MarkLetter('a', 74.53, 39.27, 10.5, Caderno.muted, opacity: .44, blur: .6),
    MarkLetter('o', 34.09, 31.95, 9, Caderno.muted, opacity: .36, blur: .8),
  ];

  /// The icon letter each letter of [name] starts from.
  static const name = 'Letraço';
  static MarkLetter letterOf(int index) {
    if (index == 0) return initial;
    if (index == 5) return cedilla;
    return far.firstWhere((m) => m.char == name[index]);
  }
}
