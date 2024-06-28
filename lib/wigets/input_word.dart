import 'package:flutter/material.dart';
import 'package:letraco/events.dart';
import 'package:letraco/game_controller.dart';

class InputWord extends StatefulWidget {
  const InputWord({
    super.key,
    required this.height,
    required this.controller,
  });

  final double height;
  final GameController controller;

  @override
  State<InputWord> createState() => _InputWordState();
}

class _InputWordState extends State<InputWord> {
  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return StreamBuilder<Event>(
      stream: widget.controller.events.stream,
      builder: (context, snapshot) {
        late final String word;
        final data = snapshot.data;
        switch (data) {
          case Found():
            word = data.word;
            break;
          case AddLetter():
            word = data.word;
            break;
          case DeleteLetter():
            word = data.word;
            break;
          default:
            word = '';
        }

        final foundStyle = TextStyle(
          fontSize: 40,
          fontWeight: FontWeight.bold,
          color: colors.primary,
          shadows: <Shadow>[
            Shadow(
              offset: const Offset(1, 1),
              blurRadius: 40,
              color: colors.secondary.withOpacity(.15),
            ),
          ],
        );

        final children = <Widget>[];
        for (var i = 0; i < word.length; i++) {
          final letter = word[i];
          final defaultStyle = TextStyle(
            fontSize: 40,
            fontWeight: FontWeight.w300,
            color: letter == widget.controller.mandatory
                ? colors.primary
                : colors.onSecondaryContainer,
          );

          final t = AnimatedDefaultTextStyle(
            duration: const Duration(milliseconds: 400),
            curve: Curves.easeOut,
            style: snapshot.data is Found ? foundStyle : defaultStyle,
            child: Text(letter),
          );
          children.add(t);
        }

        return SizedBox(
          height: widget.height,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: children,
          ),
        );
      },
    );
  }
}
