import 'dart:async';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:letraco/alphabet.dart';
import 'package:letraco/database/database_datasource.dart';
import 'package:letraco/events.dart';
import 'package:letraco/wigets/word_card.dart';
import 'package:letraco/words.dart';

typedef VoidCallBack = FutureOr<void> Function();

class Game {
  Game({
    required this.mandatory,
    required this.letters,
    required this.hidden,
    required this.visible,
  });

  final String mandatory;
  final List<String> letters;
  final List<String> hidden;
  final List<String> visible;

  List<String> get allWords {
    final w = [...hidden, ...visible];
    w.sort((a, b) => a.length.compareTo(b.length));
    return w;
  }
}

class GameController {
  GameController([this._game]);

  /// Minimum number of words a game must have
  static const minimumWordCount = 50;

  /// Minimum word length permited in a game
  static const minimumWordLength = 4;

  /// Maximum word length permited in a game
  static const maximumWordLength = 8;

  /// Number of letters that a player have to compose words.
  /// One of these letters is [mandatory]
  static const numberOfLetters = 7;

  final events = StreamController<Event>.broadcast();
  bool _showAllWords = false;
  String _inputWord = '';
  Game? _game;

  Game? get game => _game;
  Stream<Event> get stream => events.stream;

  void _emitEvent(Event event) {
    if (kDebugMode) print(event);
    events.add(event);
  }

  void newGame() {
    // if (kDebugMode) debugPrint('Generating a new game');
    _emitEvent(Generating());
    final (letters, words, mandatory) = _generateGame();
    assert(letters.length >= numberOfLetters - 1);
    assert(words.length >= minimumWordCount);
    assert(mandatory.length == 1);

    _game = Game(
      mandatory: mandatory,
      letters: letters,
      hidden: words,
      visible: [],
    );
    saveGame();
    _emitEvent(Generated(_game!));
  }

  /// Create a instance of [GameController] from a previouly saved game
  Future<void> loadGame() async {
    // if (kDebugMode) debugPrint('Start loading game');
    _emitEvent(Loading());
    final (hidden, visible, letters, mandatory) = await SharedPrefs.loadGame();
    if (hidden.isEmpty ||
        visible.isEmpty ||
        letters.isEmpty ||
        mandatory.length != 1) {
      _emitEvent(NoGameToLoad());
      return;
    }

    assert(hidden.isNotEmpty || visible.isNotEmpty);
    assert(hidden.length + visible.length >= minimumWordCount);

    _game = Game(
      mandatory: mandatory,
      letters: letters,
      hidden: hidden,
      visible: visible,
    );
    _emitEvent(Loaded(_game!));
  }

  Future<void> saveGame() async {
    if (_game == null) {
      debugPrint('No game to save');
      return;
    }
    _emitEvent(Saving());
    final saved = await SharedPrefs.saveGame(
      hidden: _game!.hidden,
      visible: _game!.visible,
      letters: _game!.letters,
      mandatory: _game!.mandatory,
    );
    if (saved) return _emitEvent(Saved());
    _emitEvent(ErrorSaving());
  }

  void switchWordsVisibility() {
    _showAllWords = !_showAllWords;
    _emitEvent(SwitchWordsVisibility(_showAllWords));
  }

  static List<String> _sortLetters() {
    // if (kDebugMode) debugPrint('Sorting letters');
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
    // if (kDebugMode) debugPrint('Calculating denied letters');
    final alphabet = {...consonants, ...vowels};
    final deniedLetters = alphabet.difference(allowedLetters.toSet());
    return deniedLetters.toList();
  }

  static List<String> _getWords(List<String> deniedLetters, String mandatory) {
    // if (kDebugMode) debugPrint('Calculating words');
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

  bool isVisible(String word) => _game != null && _game!.visible.contains(word);

  /// Divide [list] into chunks of equal length and sort them alphabetically
  static void groupByLengthAndSortAlphabetically(List<String> list) {
    assert(list.isNotEmpty);
    assert(list.length >= minimumWordCount);

    // group words by length
    Map<int, List<String>> map = {};
    for (var word in list) {
      final key = word.length;
      if (!map.containsKey(key)) map[key] = <String>[];
      map[key]!.add(word);
    }

    // sort each word group alphabetically
    map.forEach((_, list) => list.sort((a, b) => a.compareTo(b)));

    // sort length groups in ascending order
    final keys = map.keys.toList();
    keys.sort((a, b) => a.compareTo(b));

    // cleaning list
    list.removeRange(0, list.length - 1);

    // writing the final sorted words in list
    for (var key in keys) {
      list.addAll(map[key]!);
    }
  }

  static (List<String>, List<String>, String) _generateGame([int tries = 0]) {
    // if (kDebugMode) debugPrint('Generating game');
    tries++;
    // if (kDebugMode) debugPrint('Trying to generate game ($tries) times');
    final letters = _sortLetters();
    final mandatory = letters.first;
    final denied = _getDeniedLetters(letters);
    final words = _getWords(denied, mandatory);
    if (words.length < minimumWordCount) return _generateGame(tries);
    groupByLengthAndSortAlphabetically(words);
    if (kDebugMode) debugPrint(words.toString());
    assert(words.length >= 10);
    assert(mandatory.length == 1);
    assert(letters.length == 7);
    return (letters.sublist(1), words, mandatory);
  }

  void restart() {
    // if (kDebugMode) debugPrint('Restarting game');
    final (letters, words, mandatory) = _generateGame();
    if (_game != null) {
      assert(
        words
            .toSet()
            .difference({..._game!.hidden, ..._game!.visible}).isNotEmpty,
      );
      assert(letters.toSet().difference(_game!.letters.toSet()).isNotEmpty);
    }
    _game = Game(
      mandatory: mandatory,
      letters: letters,
      hidden: words,
      visible: [],
    );
    saveGame();
    clearInputWord();
  }

  void shuffle() {
    // if (kDebugMode) debugPrint('Shuffleing letters');
    _game?.letters.shuffle();
    _emitEvent(Shuffled());
  }

  void addLetter(String letter) {
    assert(letter.length == 1);

    if (letter.isEmpty) return;
    _inputWord += letter;
    _emitEvent(AddLetter(_inputWord));
  }

  void deleteLetter() {
    if (_inputWord.isEmpty) return;
    _inputWord = _inputWord.substring(0, _inputWord.length - 1);
    _emitEvent(DeleteLetter(_inputWord));
  }

  void clearInputWord() {
    _inputWord = '';
    _emitEvent(ClearLetters());
  }

  /// Check if a word exists in [hidden] list and emmits a [Event]
  ///
  /// When the word exists, it will emit a [Found] event with [_inputWord] and a
  /// offset to be used to scroll to the word and removes from [hidden] and
  /// adds to [visible].
  ///
  /// When the word does not exists, it will emit a [Miss] event.
  void checkInput() async {
    if (_game == null) return _emitEvent(NoGameAvailable());
    if (_inputWord.isEmpty) return _emitEvent(Empty());

    final indexOf = _game!.allWords.indexOf(_inputWord);
    if (indexOf == -1) {
      clearInputWord();
      return _emitEvent(Miss());
    }

    // if new word was found, save the game
    unawaited(saveGame());

    assert(_game!.hidden.isNotEmpty);
    _game!.hidden.remove(_inputWord);
    if (!_game!.visible.contains(_inputWord)) _game!.visible.add(_inputWord);

    const cardHeight = WordCard.height + WordCard.verticalPadding;
    final offset = cardHeight * (indexOf / 3).floorToDouble();
    _emitEvent(GoToCard(offset));
    // wait for scroll animation to finish
    await Future.delayed(const Duration(milliseconds: 100));

    _emitEvent(Found(_inputWord));

    // wait for card splash animation to finish to signal the clearInputWord
    await Future.delayed(const Duration(seconds: 1), () {
      clearInputWord();
    });
  }
}
