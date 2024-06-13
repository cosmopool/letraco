import 'package:flutter/material.dart';
import 'package:letraco/main_page_controller.dart';

class InputWord extends StatelessWidget {
  const InputWord({
    super.key,
    required this.height,
    required this.controller,
  });

  final double height;
  final GameController controller;

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.primary;
    final children = <Widget>[];
    for (var i = 0; i < controller.text.length; i++) {
      final letter = controller.text[i];
      final t = Text(
        letter,
        style: TextStyle(
          fontSize: 30,
          fontWeight: FontWeight.w300,
          color: letter == controller.mandatory ? color : null,
        ),
      );
      children.add(t);
    }

    return SizedBox(
      height: height,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: children,
      ),
    );
  }
}
