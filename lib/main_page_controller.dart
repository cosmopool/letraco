import 'dart:async';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:letraco/alphabet.dart';
import 'package:letraco/wigets/word_card.dart';
import 'package:letraco/words.dart';

typedef VoidCallBack = FutureOr<void> Function();

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
    final (letters, words, mandatory) = _generateGame();
    return GameController._(
      letters: letters,
      mandatory: mandatory,
      hidden: words,
      visible: [],
    );
  }

  /// Minimum number of words a game must have
  static const minimumWordCount = 50;

  bool _showAllWords = false;
  List<String> _letters = [];
  List<String> _hidden = [];
  List<String> _visible = [];
  String _mandatory = '';
  String _inputWord = '';
  final List<VoidCallBack> _listeners = [];

  bool get showAllWords => _showAllWords;
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

  void switchWordsVisibility() {
    _showAllWords = !_showAllWords;
    notify();
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

  /// Returns all letters from [alphabet] that were not selected in this game.
  /// We call [allowedLetters] the ones that were selected in this game.
  /// We call [deniedLetters] all the remaining ones in the alphabet.
  static List<String> _getDeniedLetters(List<String> allowedLetters) {
    final alphabet = {...consonants, ...vowels};
    final deniedLetters = alphabet.difference(allowedLetters.toSet());
    return deniedLetters.toList();
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
    assert(list.isNotEmpty);
    assert(list.length >= minimumWordCount);
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

  static (List<String>, List<String>, String) _generateGame([int tries = 0]) {
    tries++;
    if (kDebugMode) debugPrint('Trying to generate game ($tries) times');
    final letters = _sortLetters();
    final mandatory = letters.first;
    final denied = _getDeniedLetters(letters);
    final words = _getWords(denied, mandatory);
    if (kDebugMode) debugPrint(words.toString());
    if (words.length < minimumWordCount) return _generateGame(tries);
    _groupByLength(words);
    assert(words.length >= 10);
    assert(mandatory.length == 1);
    assert(letters.length == 7);
    return (letters.sublist(1), words, mandatory);
  }

  void restart() {
    final (letters, words, mandatory) = _generateGame();
    assert(words.toSet().difference({..._hidden, ..._visible}).isNotEmpty);
    assert(letters.toSet().difference(_letters.toSet()).isNotEmpty);
    _letters = letters;
    _hidden = words;
    _visible = [];
    _mandatory = mandatory;
    clearInputWord();
  }

  void shuffle() {
    _letters.shuffle();
    notify();
  }

  void deleteLetter() {
    if (text.isEmpty) return;
    text = text.substring(0, text.length - 1);
  }

  void clearInputWord() => text = '';

  double? checkInput() {
    final word = text;
    final indexOf = allWords.indexOf(word);
    if (indexOf == -1) return null;
    assert(hidden.isNotEmpty);
    hidden.remove(word);
    if (!visible.contains(word)) visible.add(word);
    const cardHeight = WordCard.height + WordCard.verticalPadding;
    final offset = (cardHeight) * (indexOf / 3).floorToDouble();
    return offset;
  }
}
