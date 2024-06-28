import 'package:flutter/material.dart';
import 'package:letraco/game_controller.dart';
import 'package:letraco/wigets/word_card.dart';

class WordList extends StatelessWidget {
  const WordList({
    super.key,
    required this.size,
    required this.showAllWords,
    required this.controller,
    required this.scrollController,
  });

  final Size size;
  final bool showAllWords;
  final GameController controller;
  final ScrollController scrollController;

  @override
  Widget build(BuildContext context) {
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
        cards.add(const SizedBox(width: WordCard.width));
      }

      final row = Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: cards,
      );
      rows.add(row);
    }

    return ConstrainedBox(
      constraints: const BoxConstraints(
        minWidth: (WordCard.width + 10) * 3,
        maxWidth: (WordCard.width + 10) * 4,
      ),
      child: ListView(
        controller: scrollController,
        children: rows,
      ),
    );
  }
}
