import 'package:flutter/material.dart';
import 'package:letraco/main_page_controller.dart';

class Circle extends StatelessWidget {
  const Circle({
    super.key,
    required this.mainLetter,
    required this.x,
    required this.y,
    this.circleSize = 80,
    this.isMainButton = false,
    required this.controller,
  });

  final String mainLetter;
  final double circleSize;
  final bool isMainButton;
  final double x;
  final double y;
  final GameController controller;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final bgColor =
        isMainButton ? colors.primary : colors.surfaceContainerHighest;
    final style = TextStyle(
      fontSize: circleSize * .4,
      fontWeight: FontWeight.w700,
      color: isMainButton ? colors.onPrimary : colors.onSurface,
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
