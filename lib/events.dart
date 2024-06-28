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
  GoToCard(this.offset);

  final double offset;
}
