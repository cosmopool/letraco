import 'package:flutter_test/flutter_test.dart';
import 'package:letraco/events.dart';
import 'package:letraco/game_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Center R, outer E H A L O C. Fillers make the game big enough to save.
Game buildGame({List<String> found = const ['HORA']}) {
  return Game(
    mandatory: 'R',
    letters: ['E', 'H', 'A', 'L', 'O', 'C'],
    hidden: ['CARO', 'ACOLHER', ...List.generate(50, (i) => 'RRR$i')],
    visible: [...found],
  );
}

Future<Event> check(GameController controller, String word) async {
  final next = controller.stream.firstWhere((e) => e is CheckResult);
  for (final letter in word.split('')) {
    controller.addLetter(letter);
  }
  controller.checkInput();
  return next;
}

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  test('a new word is found and moves to the end of the found list', () async {
    final controller = GameController(buildGame());
    final event = await check(controller, 'CARO');
    expect(event, isA<Found>());
    expect(controller.game!.visible, ['HORA', 'CARO']);
    expect(controller.game!.hidden, isNot(contains('CARO')));
  });

  test('a word under 4 letters is too short', () async {
    final event = await check(GameController(buildGame()), 'ARO');
    expect(event, isA<TooShort>());
  });

  test('a word without the center letter is missing it', () async {
    final event = await check(GameController(buildGame()), 'CHALE');
    expect(event, isA<MissingMandatory>());
  });

  test('a word found before is already found', () async {
    final event = await check(GameController(buildGame()), 'HORA');
    expect(event, isA<AlreadyFound>());
  });

  test('a word out of the list is a miss', () async {
    final event = await check(GameController(buildGame()), 'ROLHA');
    expect(event, isA<Miss>());
  });

  test('the input is cleared once checked', () async {
    final controller = GameController(buildGame());
    await check(controller, 'ROLHA');
    final next = controller.stream.firstWhere((e) => e is AddLetter);
    controller.addLetter('C');
    expect((await next as AddLetter).word, 'C');
  });

  test('a pangram uses all seven letters', () {
    final game = buildGame();
    expect(game.isPangram('ACOLHER'), isTrue);
    expect(game.isPangram('CARO'), isFalse);
  });
}
