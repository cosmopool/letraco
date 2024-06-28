import 'dart:async';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:letraco/alphabet.dart';
import 'package:letraco/events.dart';
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

  /// Minimum word length permited in a game
  static const minimumWordLength = 4;

  /// Maximum word length permited in a game
  static const maximumWordLength = 8;

  final events = StreamController<Event>.broadcast();
  bool _showAllWords = false;
  List<String> _letters = [];
  List<String> _hidden = [];
  List<String> _visible = [];
  String _mandatory = '';
  String _inputWord = '';

  bool get showAllWords => _showAllWords;
  List<String> get letters => _letters;
  List<String> get hidden => _hidden;
  List<String> get visible => _visible;
  String get mandatory => _mandatory;

  List<String> get allWords {
    final w = [...hidden, ...visible];
    _groupByLength(w);
    return w;
  }

  void switchWordsVisibility() {
    _showAllWords = !_showAllWords;
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
      if (word.length > maximumWordLength) continue;
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
    if (words.length < minimumWordCount) return _generateGame(tries);
    if (kDebugMode) debugPrint(words.toString());
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

  void shuffle() => _letters.shuffle();

  void addLetter(String letter) {
    assert(letter.length == 1);

    if (letter.isEmpty) return;
    _inputWord += letter;
    events.add(AddLetter(_inputWord));
  }

  void deleteLetter() {
    if (_inputWord.isEmpty) return;
    _inputWord = _inputWord.substring(0, _inputWord.length - 1);
    events.add(DeleteLetter(_inputWord));
  }

  void clearInputWord() {
    _inputWord = '';
    events.add(ClearLetters());
  }

  /// Check if a word exists in [hidden] list and emmits a [Event]
  ///
  /// When the word exists, it will emit a [Found] event with [_inputWord] and a
  /// offset to be used to scroll to the word and removes from [hidden] and
  /// adds to [visible].
  ///
  /// When the word does not exists, it will emit a [Miss] event.
  void checkInput() async {
    final word = _inputWord;
    final indexOf = allWords.indexOf(word);
    if (indexOf == -1) return events.add(Miss());

    assert(hidden.isNotEmpty);
    hidden.remove(word);
    if (!visible.contains(word)) visible.add(word);

    const cardHeight = WordCard.height + WordCard.verticalPadding;
    final offset = cardHeight * (indexOf / 3).floorToDouble();
    events.add(Found(_inputWord, offset));

    return await Future.delayed(const Duration(seconds: 1), () {
      return clearInputWord();
    });
  }
}
