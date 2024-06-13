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
  final controller = GameController.init();
  String wordText = '';
  bool showAllWords = false;

  void updateWordText() {
    wordText = controller.text;
    setState(() {});
  }

  void checkInputWord() {
    final offset = controller.checkInput();
    if (offset == null) return;
    scrollController.animateTo(
      offset,
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOut,
    );
  }

  @override
  void initState() {
    controller.addListener(updateWordText);
    super.initState();
  }

  @override
  void dispose() {
    controller.removeListener(updateWordText);
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

  Widget _inputWord(BuildContext context) {
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
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: children,
    );
  }

  Widget _wordCard(String word, bool visible, Size size, ColorScheme colors) {
    final text = visible || showAllWords ? word : '${word.length} letras';
    final style = TextStyle(
      color: visible ? colors.onSurface : colors.outlineVariant,
      fontSize: 12,
      fontWeight: visible ? FontWeight.w600 : FontWeight.w500,
    );
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
    final borderColor = visible ? colors.primary : colors.outlineVariant;
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

  Widget _progressBar(ColorScheme colors, Size size) {
    final allWords = controller.allWords.length;
    final visible = controller.visible.length;
    const vertical = 5.0;
    const horizontal = 24.0;
    const indicatorWidth = 30.0;
    const padding =
        EdgeInsets.symmetric(horizontal: horizontal, vertical: vertical);
    const border = BorderRadius.all(Radius.circular(20));
    final maxBarWidth = size.width - 2 * indicatorWidth - 2 * horizontal;

    final background = Container(
      width: maxBarWidth,
      decoration: BoxDecoration(
        borderRadius: border,
        color: colors.secondaryContainer,
      ),
    );
    final foreground = Container(
      width: (visible / allWords) * maxBarWidth,
      decoration: BoxDecoration(
        borderRadius: border,
        color: colors.primary,
      ),
    );
    final progressBar = SizedBox(
      height: 10,
      child: Stack(
        children: [
          background,
          foreground,
        ],
      ),
    );

    const indicatorStyle = TextStyle(fontWeight: FontWeight.w700);
    final indicators = Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        SizedBox(
          width: indicatorWidth,
          child: Text(
            visible.toString(),
            style: indicatorStyle,
            textAlign: TextAlign.center,
          ),
        ),
        progressBar,
        SizedBox(
          width: indicatorWidth,
          child: Text(
            allWords.toString(),
            style: indicatorStyle,
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );

    return Padding(
      padding: padding,
      child: Column(children: [
        // progressBar,
        indicators,
      ],),
    );
  }

  Widget _words(Size size, ColorScheme colors) {
    final rows = <Widget>[];
    List<Widget> cards = [];
    for (var i = 0; i < controller.allWords.length; i++) {
      final word = controller.allWords[i];
      if (i % 3 != 0) {
        cards.add(_wordCard(word, controller.isVisible(word), size, colors));
        continue;
      }
      final row = Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: cards,
      );
      rows.add(row);
      cards = [];
      cards.add(_wordCard(word, controller.isVisible(word), size, colors));
    }

    if (cards.isNotEmpty) {
      while (cards.length % 3 != 0) {
        cards.add(SizedBox(width: size.width * .22 + 10));
      }
      final row = Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: cards,
      );
      rows.add(row);
    }

    return ListView(
      controller: scrollController,
      children: rows,
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final colors = Theme.of(context).colorScheme;

    final inputWord = SizedBox(
      height: circleSize,
      child: _inputWord(context),
    );

    final circles = _circles(size);

    final wordList = _words(size, colors);

    final restart = IconButton(
      onPressed: controller.restart,
      icon: const Icon(Icons.restart_alt),
    );

    final pick = IconButton(
      onPressed: () {
        showAllWords = !showAllWords;
        setState(() {});
      },
      icon: const Icon(Icons.remove_red_eye_rounded),
    );

    final topButtons = SizedBox(
      height: circleSize / 2,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          pick,
          restart,
        ],
      ),
    );
    final check = ElevatedButton(
      onPressed: checkInputWord,
      child: const Text('Checar'),
    );
    final shuffle = IconButton(
      onPressed: controller.shuffle,
      icon: const Icon(Icons.restart_alt),
    );
    final delete = ElevatedButton(
      onPressed: controller.deleteLetter,
      onLongPress: controller.cleanInputWord,
      child: Text('Deletar', style: TextStyle(color: colors.onSurface)),
    );

    final buttons = SizedBox(
      height: circleSize,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          delete,
          shuffle,
          check,
        ],
      ),
    );

    final progressBar = _progressBar(colors, size);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            topButtons,
            Center(child: inputWord),
            circles,
            buttons,
            progressBar,
            Expanded(child: wordList),
          ],
        ),
      ),
    );
  }
}
