import 'package:flutter/material.dart';
import 'package:letraco/theme.dart';

/// Header logo: the app icon and the name, with the "ç" in teal.
class Logo extends StatelessWidget {
  const Logo({super.key});

  static const iconSize = 30.0;
  static const gap = 10.0;
  static const textSize = 22.0;
  static const letterSpacing = -.2;

  /// Opacity of the logo. The splash hides it and fades it in while its own
  /// letters fade out on top, so the two never need to line up exactly.
  static final reveal = ValueNotifier<double>(1);

  /// Style of the name; the splash lands its letters on it.
  static TextStyle style({Color color = Caderno.ink}) => Caderno.serifStyle(
    size: textSize,
    weight: FontWeight.w700,
    height: 1,
    letterSpacing: letterSpacing,
    color: color,
  );

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<double>(
      valueListenable: reveal,
      builder: (context, opacity, child) =>
          Opacity(opacity: opacity, child: child),
      child: _mark(),
    );
  }

  Widget _mark() {
    return Semantics(
      label: 'Letraço',
      excludeSemantics: true,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.asset(
              'assets/images/icon.png',
              width: iconSize,
              height: iconSize,
              filterQuality: FilterQuality.medium,
            ),
          ),
          const SizedBox(width: gap),
          Text.rich(
            TextSpan(
              children: [
                const TextSpan(text: 'Letra'),
                TextSpan(
                  text: 'ç',
                  style: style(color: Caderno.brand),
                ),
                const TextSpan(text: 'o'),
              ],
            ),
            style: style(),
          ),
        ],
      ),
    );
  }
}
