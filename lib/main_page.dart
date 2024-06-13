import 'package:flutter/material.dart';
import 'package:letraco/main_page_controller.dart';
import 'package:letraco/wigets/circles.dart';
import 'package:letraco/wigets/progress_bar.dart';
import 'package:letraco/wigets/word_card.dart';

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

  Widget _words(Size size, ColorScheme colors) {
    final rows = <Widget>[];
    List<Widget> cards = [];
    for (var i = 0; i < controller.allWords.length; i++) {
      final word = controller.allWords[i];
      if (i % 3 != 0) {
        cards.add(
          WordCard(
            word: word,
            visible: showAllWords || controller.isVisible(word),
            size: size,
          ),
        );
        continue;
      }
      final row = Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: cards,
      );
      rows.add(row);
      cards = [];
      cards.add(
        WordCard(
          word: word,
          visible: showAllWords || controller.isVisible(word),
          size: size,
        ),
      );
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

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            topButtons,
            Center(child: inputWord),
            LettersCircles(size: size, controller: controller),
            buttons,
            ProgressBar(size: size, controller: controller),
            Expanded(child: wordList),
          ],
        ),
      ),
    );
  }
}
