import 'package:flutter_test/flutter_test.dart';
import 'package:letraco/game_controller.dart';

void main() {
  test('sort alphabetically', () {
    final list = ['c', 'b', 'a'];
    GameController.sortWords(list);
    expect(list.length, 3);
    expect(list, ['a', 'b', 'c']);
  });

  test('sort by length', () {
    final list = ['c', 'aaaa', 'bb', 'ddd'];
    GameController.sortWords(list);
    expect(list.length, 4);
    expect(list, ['c', 'bb', 'ddd', 'aaaa']);
  });

  test('sort by length and alphabetically', () {
    final list = ['c', 'bb', 'a', 'b', 'aa', 'aaa'];
    GameController.sortWords(list);
    expect(list.length, 6);
    expect(list, ['a', 'b', 'c', 'aa', 'bb', 'aaa']);
  });
}
