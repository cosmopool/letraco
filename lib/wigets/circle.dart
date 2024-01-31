import 'package:flutter/material.dart';

class Circle extends StatelessWidget {
  final String mainLetter;
  final double circleSize;
  final Color? backgroundColor;
  final double x;
  final double y;
  final TextEditingController controller;

  const Circle({
    super.key,
    required this.mainLetter,
    required this.x,
    required this.y,
    this.circleSize = 80,
    this.backgroundColor,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final bgColor = backgroundColor ?? colors.surfaceVariant;
    final luminance = bgColor.computeLuminance();
    final style = TextStyle(
      fontSize: circleSize * .4,
      fontWeight: FontWeight.w700,
      color: luminance > 0.3 ? colors.onSurface : colors.surface,
    );
    const borderRadius = BorderRadius.all(Radius.circular(100));

    return Positioned(
      top: x,
      left: y,
      child: Material(
        borderRadius: borderRadius,
        color: bgColor,
        child: InkWell(
          borderRadius: borderRadius,
          onTap: () {
            controller.text += mainLetter;
          },
          child: SizedBox(
            height: circleSize,
            width: circleSize,
            child: Center(
              child: Text(mainLetter.toUpperCase(), style: style),
            ),
          ),
        ),
      ),
    );
  }
}
