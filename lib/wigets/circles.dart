import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:letraco/main_page_controller.dart';
import 'package:letraco/wigets/circle.dart';

class LettersCircles extends StatelessWidget {
  const LettersCircles({
    super.key,
    required this.size,
    required this.controller,
  });

  static const double circleSize = 80;
  static const double circleMargin = 5;

  final Size size;
  final GameController controller;

  @override
  Widget build(BuildContext context) {
    final halfWidth = size.width * .5 - circleSize * .5;
    const height = circleSize * .8 + 20;

    final letters = <Widget>[];
    final mainLetterCircle = Circle(
      x: height,
      y: halfWidth,
      mainLetter: controller.mandatory,
      isMainButton: true,
      controller: controller,
    );

    final numberOfLetters = controller.letters.length;
    final divisionAngle = 360 / numberOfLetters;
    for (var i = 0; i < numberOfLetters; i++) {
      final rad = i * divisionAngle * (math.pi / 180);
      final widget = Circle(
        x: math.sin(rad) * (circleSize + circleMargin) + height,
        y: math.cos(rad) * (circleSize + circleMargin) + halfWidth,
        mainLetter: controller.letters[i],
        controller: controller,
      );
      letters.add(widget);
    }
    return SizedBox(
      height: size.height * .3,
      child: Stack(
        fit: StackFit.expand,
        children: [
          mainLetterCircle,
          ...letters,
        ],
      ),
    );
  }
}
