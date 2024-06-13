import 'package:flutter/material.dart';
import 'package:letraco/main_page_controller.dart';
import 'package:letraco/wigets/circles.dart';
import 'package:letraco/wigets/input_word.dart';
import 'package:letraco/wigets/progress_bar.dart';
import 'package:letraco/wigets/word_list.dart';

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

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final colors = Theme.of(context).colorScheme;

    final inputWord = InputWord(height: circleSize, controller: controller);

    final wordList = WordList(
      size: size,
      controller: controller,
      scrollController: scrollController,
      showAllWords: showAllWords,
    );

    final restart = IconButton(
      onPressed: controller.restart,
      icon: const Icon(Icons.restart_alt),
    );

    final showAllWordsButton = IconButton(
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
          showAllWordsButton,
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
