import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:letraco/game_controller.dart';
import 'package:letraco/wigets/letter_circle.dart';

class LettersCircles extends StatefulWidget {
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
  State<LettersCircles> createState() => _LettersCirclesState();
}

class _LettersCirclesState extends State<LettersCircles> {
  // subtract the mandatory letter
  static const numberOfLetters = GameController.numberOfLetters - 1;
  static const divisionAngle = 360 / numberOfLetters;

  late final controller = widget.controller;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Object>(
      stream: controller.stream,
      builder: (context, snapshot) {
        final game = controller.game;
        if (game == null) return const CircularProgressIndicator();

        final halfWidth =
            widget.size.width * .5 - LettersCircles.circleSize * .5;
        const height = LettersCircles.circleSize * .8 + 20;

        final letters = <Widget>[];
        final mainLetterCircle = LetterCircle(
          x: height,
          y: halfWidth,
          letter: game.mandatory,
          isMainButton: true,
          controller: controller,
        );

        for (var i = 0; i < numberOfLetters; i++) {
          final rad = i * divisionAngle * (math.pi / 180);
          final circle = LetterCircle(
            x: math.sin(rad) *
                    (LettersCircles.circleSize + LettersCircles.circleMargin) +
                height,
            y: math.cos(rad) *
                    (LettersCircles.circleSize + LettersCircles.circleMargin) +
                halfWidth,
            letter: game.letters[i],
            controller: controller,
          );
          letters.add(circle);
        }

        return SizedBox(
          height: widget.size.height * .3,
          child: Stack(
            fit: StackFit.expand,
            children: [
              mainLetterCircle,
              ...letters,
            ],
          ),
        );
      },
    );
  }
}
