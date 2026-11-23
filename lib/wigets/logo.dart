import 'package:flutter/material.dart';
import 'package:letraco/theme.dart';

/// A letter of the long logo, in units where the name's font size is 100.
///
/// [x] and [y] are the glyph origin (left edge of the advance, baseline),
/// relative to the origin of the word.
class LogoGlyph {
  const LogoGlyph(
    this.char,
    this.x,
    this.y,
    this.size, {
    this.color = Caderno.ink,
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

/// Long logo, "L grande com eco": the name with a big near L, "etraço" at
/// the normal size with a teal ç, and the icon's far letters echoed above, in
/// the L's corner.
///
/// Layout exported from `proposta_logo_longa.html` (proposal 7), measured
/// with Noto Serif bold, the serif Android uses.
class Logo extends StatelessWidget {
  const Logo({super.key});

  /// Font size of "etraço" in the header.
  static const nameSize = 24.0;

  /// Opacity of the logo. The splash hides it and fades it in while its own
  /// letters fade out on top, so the two never need to line up exactly.
  static final reveal = ValueNotifier<double>(1);

  /// "Letraço": the L at 1.4× the name, the L→e pair closed to 0.04 em.
  static const word = [
    LogoGlyph('L', 0, 0, 140),
    LogoGlyph('e', 88.2, 0, 100),
    LogoGlyph('t', 144.4, 0, 100),
    LogoGlyph('r', 183.9, 0, 100),
    LogoGlyph('a', 235.2, 0, 100),
    LogoGlyph('ç', 294.2, 0, 100, color: Caderno.brand),
    LogoGlyph('o', 345.9, 0, 100),
  ];

  /// The icon's far letters, 2.77× their icon size, above "etr".
  static const echo = [
    LogoGlyph(
      'e',
      144.55,
      -92.34,
      36,
      color: Caderno.muted,
      opacity: .58,
      blur: .83,
    ),
    LogoGlyph(
      't',
      203.7,
      -89.57,
      31.85,
      color: Caderno.muted,
      opacity: .5,
      blur: 1.25,
    ),
    LogoGlyph(
      'r',
      191.21,
      -63.4,
      33.23,
      color: Caderno.muted,
      opacity: .54,
      blur: 1.11,
    ),
    LogoGlyph(
      'a',
      225.19,
      -74.01,
      29.08,
      color: Caderno.muted,
      opacity: .44,
      blur: 1.66,
    ),
    LogoGlyph(
      'o',
      113.2,
      -94.28,
      24.92,
      color: Caderno.muted,
      opacity: .36,
      blur: 2.22,
    ),
  ];

  /// Ink box of the whole mark (word and echo), in the same units.
  static const _left = 2.8;
  static const _top = -112.14;
  static const _right = 402.9;
  static const _bottom = 24.0;

  static const _unit = nameSize / 100;

  /// Size the logo takes.
  static const size = Size((_right - _left) * _unit, (_bottom - _top) * _unit);

  /// Origin (left, baseline) and font size of letter [index] of "Letraço",
  /// measured from the logo's top-left corner. The splash lands there.
  static (Offset, double) letter(int index) {
    final g = word[index];
    return (
      Offset((g.x - _left) * _unit, (g.y - _top) * _unit),
      g.size * _unit,
    );
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<double>(
      valueListenable: reveal,
      builder: (context, opacity, child) =>
          Opacity(opacity: opacity, child: child),
      child: Semantics(
        label: 'Letraço',
        excludeSemantics: true,
        child: const CustomPaint(size: size, painter: _LogoPainter()),
      ),
    );
  }
}

class _LogoPainter extends CustomPainter {
  const _LogoPainter();

  static const _unit = Logo._unit;

  @override
  void paint(Canvas canvas, Size size) {
    for (final g in [...Logo.echo, ...Logo.word]) {
      final paint = Paint()..color = g.color.withValues(alpha: g.opacity);
      final blur = g.blur * _unit;
      if (blur >= .35) {
        paint.maskFilter = MaskFilter.blur(BlurStyle.normal, blur);
      }
      final painter = TextPainter(
        text: TextSpan(
          text: g.char,
          style: Caderno.serifStyle(
            size: g.size * _unit,
            weight: FontWeight.w700,
            height: 1,
          ).copyWith(foreground: paint),
        ),
        textDirection: TextDirection.ltr,
        textScaler: TextScaler.noScaling,
      )..layout();
      final baseline = painter.computeDistanceToActualBaseline(
        TextBaseline.alphabetic,
      );
      painter.paint(
        canvas,
        Offset(
          (g.x - Logo._left) * _unit,
          (g.y - Logo._top) * _unit - baseline,
        ),
      );
      painter.dispose();
    }
  }

  @override
  bool shouldRepaint(_LogoPainter oldDelegate) => false;
}
