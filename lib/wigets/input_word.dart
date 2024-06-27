import 'package:flutter/material.dart';
import 'package:letraco/main_page_controller.dart';

final wordFound = ValueNotifier<bool>(false);

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
  _refreshState() => setState(() {});

  @override
  void initState() {
    super.initState();
    wordFound.addListener(_refreshState);
  }

  @override
  void dispose() {
    super.dispose();
    wordFound.removeListener(_refreshState);
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return ValueListenableBuilder(
      valueListenable: wordFound,
      builder: (context, value, child) {
        final children = <Widget>[];
        for (var i = 0; i < widget.controller.text.length; i++) {
          final letter = widget.controller.text[i];
          final defaultStyle = TextStyle(
            fontSize: 40,
            fontWeight: FontWeight.w300,
            color: letter == widget.controller.mandatory
                ? colors.primary
                : colors.onSecondaryContainer,
          );
          final foundStyle = defaultStyle.copyWith(
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
          final t = AnimatedDefaultTextStyle(
            duration: const Duration(milliseconds: 400),
            curve: Curves.easeOut,
            style: wordFound.value ? foundStyle : defaultStyle,
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
