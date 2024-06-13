import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:letraco/alphabet.dart';
import 'package:letraco/words.dart';

typedef VoidCallBack = void Function();

class GameController {
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

  List<String> _letters = [];
  List<String> _hidden = [];
  List<String> _visible = [];
  String _mandatory = '';
  String _inputWord = '';
  final List<VoidCallBack> _listeners = [];

  List<String> get letters => _letters;
  List<String> get hidden => _hidden;
  List<String> get visible => _visible;
  String get mandatory => _mandatory;
  String get text => _inputWord;

  set text(String newText) {
    _inputWord = newText;
    notify();
  }

  List<String> get allWords {
    final w = [...hidden, ...visible];
    _groupByLength(w);
    return w;
  }

  // ignore: avoid_function_literals_in_foreach_calls
  void notify() => _listeners.forEach((callback) => callback());
  void addListener(VoidCallBack fn) => _listeners.add(fn);
  void removeListener(VoidCallBack fn) => _listeners.remove(fn);

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

  bool isVisible(String word) => visible.contains(word);

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
    if (kDebugMode) debugPrint(words.toString());
    return (letters.sublist(1), words, mandatory);
  }

  void restart() {
    final (letters, words, mandatory) = _init();
    _letters = letters;
    _hidden = words;
    _visible = [];
    _mandatory = mandatory;
    cleanInputWord();
  }

  void shuffle() {
    _letters.shuffle();
    notify();
  }

  void deleteLetter() {
    if (text.isEmpty) return;
    text = text.substring(0, text.length - 1);
  }

  void cleanInputWord() => text = '';

  double? checkInput() {
    final word = text;
    final indexOf = allWords.indexOf(word);
    text = '';
    if (indexOf == -1) return null;
    hidden.remove(word);
    visible.add(word);
    final offset = (allWords.length / 3) * indexOf / 3 - 30;
    return offset;
  }
}
