import 'dart:math';

import 'package:letraco/alphabet.dart';
import 'package:letraco/words.dart';

class GameController {
  List<String> _letters = [];
  List<String> _hidden = [];
  List<String> _visible = [];
  String _mandatory = '';

  List<String> get letters => _letters;
  List<String> get hidden => _hidden;
  List<String> get visible => _visible;
  String get mandatory => _mandatory;

  List<String> get allWords {
    final w = [...hidden, ...visible];
    _groupByLength(w);
    return w;
  }

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
        var letter =
            consonantsNormalMode[Random().nextInt(consonantsNormalMode.length)];
        while (letters.contains(letter)) {
          letter = consonantsNormalMode[
              Random().nextInt(consonantsNormalMode.length)];
        }
        letters.add(letter);
      }
    }

    for (var i = 0; i < letters.length; i++) {
      letters[i] = letters[i];
    }

    return letters;
  }

  static List<String> _getDeniedLetters(List<String> allowedLetters) {
    final alphabet = [...consonants, ...vowels];
    final r = <String>[];
    for (var l in alphabet) {
      final letter = l;
      if (allowedLetters.contains(letter)) continue;
      r.add(letter);
    }
    return r;
  }

  static List<String> _getWords(List<String> deniedLetters, String mandatory) {
    final words = <String>[];
    for (var i = 0; i < dicio.length; i++) {
      final word = dicio[i];
      if (!word.contains(mandatory)) continue;
      bool wordIsDenied = false;
      for (var deniedLetter in deniedLetters) {
        if (word.contains(deniedLetter)) {
          wordIsDenied = true;
          break;
        }
      }

      if (wordIsDenied) continue;
      words.add(word);
    }
    return words;
  }

  bool foundWord(String word) {
    if (!hidden.contains(word)) return false;
    hidden.remove(word);
    visible.add(word);
    return true;
  }

  bool isVisible(String word) {
    return visible.contains(word);
  }

  static void _groupByLength(List<String> list) {
    list.sort((a, b) => a.compareTo(b));
    Map<int, List<String>> map = {};
    final res = <String>[];
    for (var word in list) {
      final key = word.length;
      if (!map.containsKey(key)) map[key] = <String>[];
      map[key]!.add(word);
    }
    final keys = map.keys.toList();
    keys.sort((a, b) => a.compareTo(b));
    for (var key in keys) {
      res.addAll(map[key]!);
    }
    for (var i = 0; i < list.length; i++) {
      list[i] = res[i];
    }
  }

  static (List<String>, List<String>, String) _init() {
    final letters = _sortLetters();
    final mandatory = letters.first;
    final denied = _getDeniedLetters(letters);
    final words = _getWords(denied, mandatory);
    _groupByLength(words);
    print(words);
    return (letters.sublist(1), words, mandatory);
  }

  void restart() {
    final (letters, words, mandatory) = _init();
    _letters = letters;
    _hidden = words;
    _visible = [];
    _mandatory = mandatory;
  }

  void shuffle() {
    _letters.shuffle();
  }

  GameController._({
    required List<String> letters,
    required String mandatory,
    required List<String> hidden,
    required List<String> visible,
  })  : _letters = letters,
        _mandatory = mandatory,
        _hidden = hidden,
        _visible = visible;

  factory GameController.init() {
    final (letters, words, mandatory) = _init();
    return GameController._(
      letters: letters,
      mandatory: mandatory,
      hidden: words,
      visible: [],
    );
  }
}
