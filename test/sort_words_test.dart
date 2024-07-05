import 'package:flutter_test/flutter_test.dart';
import 'package:letraco/core/extensions.dart';

void main() {
  test('sort alphabetically', () {
    final list = ['c', 'b', 'a'];
    list.sortWords();
    expect(list.length, 3);
    expect(list, ['a', 'b', 'c']);
  });

  test('sort by length', () {
    final list = ['c', 'aaaa', 'bb', 'ddd'];
    list.sortWords();
    expect(list.length, 4);
    expect(list, ['c', 'bb', 'ddd', 'aaaa']);
  });

  test('sort by length and alphabetically', () {
    final list = ['c', 'bb', 'a', 'b', 'aa', 'aaa'];
    list.sortWords();
    expect(list.length, 6);
    expect(list, ['a', 'b', 'c', 'aa', 'bb', 'aaa']);
  });
}
