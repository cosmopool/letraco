import 'package:letraco/game_controller.dart';

sealed class Event {}

class Empty extends Event {}

class Miss extends Event {}

class Found extends Event {
  Found(this.word)
      : assert(word.isNotEmpty),
        assert(
          word.length >= GameController.minimumWordLength &&
              word.length <= GameController.maximumWordLength,
        );

  final String word;
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

class SwitchWordsVisibility extends Event {
  SwitchWordsVisibility(this.show);

  final bool show;
}

class GoToCard extends Event {
  GoToCard(this.offset) : assert(offset > 0);

  final double offset;
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

class Shuffled extends Event {}

class NoGameAvailable extends Event {}

class Saving extends Event {}

class Saved extends Event {}

class ErrorSaving extends Event {}
