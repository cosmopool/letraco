sealed class Event {}

class Miss extends Event {}

class Found extends Event {
  Found(this.word, this.offset)
      : assert(word.isNotEmpty),
        assert(word.length >= 4),
        assert(word.length <= 8);

  final String word;
  final double offset;
}
