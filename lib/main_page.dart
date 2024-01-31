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

  final scrollController = ScrollController();
  final textController = TextEditingController();
  final controller = GameController.init();
  final wordText = ValueNotifier<String>('');

  void updateWordText() {
    wordText.value = textController.text;
    setState(() {});
  }

  void checkInput() {
    final word = textController.text;
    final found = controller.foundWord(word);
    if (found) foundWord(word);
  }

  void foundWord(String word) {
    textController.text = '';
    final indexOf = controller.allWords.indexOf(word);
    final offset = (controller.allWords.length / 3) * indexOf / 3 - 30;
    scrollController.animateTo(
      offset,
      duration: const Duration(milliseconds: 100),
      curve: Curves.easeIn,
    );
  }

  @override
  void initState() {
    textController.addListener(updateWordText);
    textController.addListener(checkInput);
    super.initState();
  }

  @override
  void dispose() {
    textController.removeListener(updateWordText);
    textController.removeListener(checkInput);
    textController.dispose();
    super.dispose();
  }

  Widget _circles(Size size) {
    final halfWidth = size.width * .5 - circleSize * .5;
    const height = circleSize * .8 + 20;

    final letters = <Widget>[];
    final mainLetterCircle = Circle(
      x: height,
      y: halfWidth,
      mainLetter: controller.mandatory,
      backgroundColor: Theme.of(context).colorScheme.primary,
      controller: textController,
    );

    final divisionAngle = 360 / controller.letters.length;
    for (var i = 0; i < controller.letters.length; i++) {
      final rad = i * divisionAngle * (math.pi / 180);
      final widget = Circle(
        x: math.sin(rad) * (circleSize + circleMargin) + height,
        y: math.cos(rad) * (circleSize + circleMargin) + halfWidth,
        mainLetter: controller.letters[i],
        controller: textController,
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

  Widget _inputWord(BuildContext context) {
    final color = Theme.of(context).colorScheme.primary;
    final children = <Widget>[];
    for (var i = 0; i < textController.text.length; i++) {
      final letter = textController.text[i];
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
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: children,
    );
  }

  Widget _wordCard(String word, bool visible, Size size, ColorScheme colors) {
    final text = visible ? word : '${word.length} Palavras';
    final style = TextStyle(
        color: visible ? colors.onSurface : colors.secondary, fontSize: 12);
    final content = Padding(
      padding: const EdgeInsets.all(5),
      child: SizedBox(
        width: size.width * .22,
        height: size.width * .05,
        child: Text(
          text,
          style: style,
          textAlign: TextAlign.center,
        ),
      ),
    );
    final borderColor = visible ? colors.primary : colors.surfaceVariant;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: borderColor, width: 1.5),
          borderRadius: const BorderRadius.all(Radius.circular(20)),
        ),
        child: content,
      ),
    );
  }

  void _onCleanPressed() => textController.text = '';

  void _onDeletePressed() {
    final text = textController.text;
    textController.text = text.substring(0, text.length - 1);
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final colors = Theme.of(context).colorScheme;

    final word = SizedBox(
      height: circleSize,
      child: _inputWord(context),
    );

    final circles = _circles(size);

    final asdf = <Widget>[];
    List<Widget> row = [];
    for (var i = 0; i < controller.allWords.length; i++) {
      final word = controller.allWords[i];
      if (i % 3 != 0) {
        row.add(_wordCard(word, controller.isVisible(word), size, colors));
        continue;
      }
      final r = Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: row,
      );
      asdf.add(r);
      row = [];
      row.add(_wordCard(word, controller.isVisible(word), size, colors));
    }
    final words = ListView(
      controller: scrollController,
      children: asdf,
    );

    final clean = ElevatedButton(
      onPressed: _onCleanPressed,
      child: const Text('Limpar'),
    );
    final delete = ElevatedButton(
      onPressed: _onDeletePressed,
      child: const Text('Deletar'),
    );

    final buttons = SizedBox(
      height: circleSize,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          delete,
          clean,
        ],
      ),
    );

    return Scaffold(
      body: ValueListenableBuilder(
        valueListenable: wordText,
        builder: (BuildContext context, value, Widget? child) {
          return SafeArea(
            child: Column(
              children: [
                Center(child: word),
                circles,
                buttons,
                Expanded(child: words),
              ],
            ),
          );
        },
      ),
    );
  }
}
