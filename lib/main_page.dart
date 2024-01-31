import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:letraco/main_page_controller.dart';
import 'package:letraco/wigets/circle.dart';

class MainPage extends StatefulWidget {
  const MainPage({
    super.key,
    required this.title,
  });

  final String title;

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  static const double circleSize = 80;
  static const double circleMargin = 5;

  final controller = GameController.init();
  final textController = TextEditingController();
  final wordText = ValueNotifier<String>('');

  void updateWordText() {
    wordText.value = textController.text;
    setState(() {});
  }

  @override
  void initState() {
    textController.addListener(updateWordText);
    super.initState();
  }

  @override
  void dispose() {
    textController.removeListener(updateWordText);
    textController.dispose();
    super.dispose();
  }

  Widget _circles(Size size) {
    final halfWidth = size.width * .5 - circleSize * .5;
    final halfHeight = size.height * .3 - circleSize * .5;

    final letters = <Widget>[];
    final mainLetterCircle = Circle(
      x: halfHeight,
      y: halfWidth,
      mainLetter: controller.mainLetter,
      backgroundColor: Theme.of(context).colorScheme.primary,
      controller: textController,
    );

    final divisionAngle = 360 / controller.letters.length;
    for (var i = 0; i < controller.letters.length; i++) {
      final rad = i * divisionAngle * (math.pi / 180);
      final widget = Circle(
        x: math.sin(rad) * (circleSize + circleMargin) + halfHeight,
        y: math.cos(rad) * (circleSize + circleMargin) + halfWidth,
        mainLetter: controller.letters[i].toUpperCase(),
        controller: textController,
      );
      letters.add(widget);
    }

    return Stack(
      children: [
        mainLetterCircle,
        ...letters,
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final word = Text(wordText.value);
    final circles = _circles(size);
    final deleteBtn = ElevatedButton(
      onPressed: () {},
      child: const Text('Delete'),
    );
    final buttons = Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        deleteBtn,
      ],
    );

    return Scaffold(
      body: ValueListenableBuilder(
        valueListenable: wordText,
        builder: (BuildContext context, value, Widget? child) {
          return SafeArea(
            child: Column(
              children: [
                word,
                Expanded(flex: 2, child: circles),
                buttons,
                const Expanded(child: SizedBox.shrink()),
              ],
            ),
          );
        },
      ),
    );
  }
}
