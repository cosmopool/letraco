import 'package:letraco/game_controller.dart';

sealed class Event {}

class Empty extends Event {}

/// Result of checking a word. The input is already cleared when it is emitted,
/// so the next letter starts a new word while the result is still on screen.
sealed class CheckResult extends Event {
  CheckResult(this.word);

  final String word;
}

/// The word is not in the game's list.
class Miss extends CheckResult {
  Miss(super.word);
}

/// The word has fewer than [GameController.minimumWordLength] letters.
class TooShort extends CheckResult {
  TooShort(super.word);
}

/// The word does not use the mandatory letter.
class MissingMandatory extends CheckResult {
  MissingMandatory(super.word);
}

/// The word was found before.
class AlreadyFound extends CheckResult {
  AlreadyFound(super.word);
}

class Found extends CheckResult {
  Found(super.word)
    : assert(word.isNotEmpty),
      assert(
        word.length >= GameController.minimumWordLength &&
            word.length <= GameController.maximumWordLength,
      );
}

class DeleteLetter extends Event {
  DeleteLetter(this.word);

  final String word;
}

class AddLetter extends Event {
  AddLetter(this.word) : assert(word.isNotEmpty);

  final String word;
}

class ClearLetters extends Event {}

class ReachedMaximumLetters extends Event {
  ReachedMaximumLetters(this.word) : assert(word.isNotEmpty);

  final String word;
}

class SwitchWordsVisibility extends Event {
  SwitchWordsVisibility(this.show);

  final bool show;
}

class Loading extends Event {}

class Loaded extends Event {
  Loaded(this.game);

  final Game game;
}

class Generating extends Loading {}

class Generated extends Loaded {
  Generated(super.game);
}

class NoGameToLoad extends Event {}

/// The outer letters changed places.
class Shuffled extends Event {}

class NoGameAvailable extends Event {}

class Saving extends Event {}

class Saved extends Event {}

class ErrorSaving extends Event {}
