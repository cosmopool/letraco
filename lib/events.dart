sealed class Event {}

class WordInexistet extends Event {}

class WordFound extends Event {
  WordFound(this.word, this.offset)
      : assert(word.isNotEmpty),
        assert(word.length >= 4),
        assert(word.length <= 8);

  final String word;
  final double offset;
}
