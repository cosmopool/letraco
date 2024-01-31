import 'dart:math';

import 'package:letraco/alphabet.dart';

class GameController {
  final List<String> letters;
  final String mainLetter;

  static List<String> _sortLetters() {
    const numberOfLetters = 7;
    final letters = <String>[];

    for (var i = 1; i <= numberOfLetters; i++) {
      if (i % 2 == 0) {
        var letter = vowels[Random().nextInt(vowels.length)];
        while (letters.contains(letter)) {
          letter = vowels[Random().nextInt(vowels.length)];
        }
        letters.add(letter);
      } else {
        var letter = consonants[Random().nextInt(consonants.length)];
        while (letters.contains(letter)) {
          letter = consonants[Random().nextInt(consonants.length)];
        }
        letters.add(letter);
      }
    }

    return letters;
  }

  GameController._({
    required this.letters,
    required this.mainLetter,
  });

  factory GameController.init() {
    final letters = _sortLetters();
    final mainLetter = letters.first;
    return GameController._(
      letters: letters.sublist(1),
      mainLetter: mainLetter,
    );
  }
}
