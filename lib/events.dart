import 'package:letraco/game_controller.dart';

sealed class Event {}

class Miss extends Event {}

class Found extends Event {
  Found(this.word, this.offset)
      : assert(word.isNotEmpty),
        assert(
          word.length >= GameController.minimumWordLength &&
              word.length <= GameController.maximumWordLength,
        );

  final String word;
  final double offset;
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

class ShowAllWords extends Event {}
