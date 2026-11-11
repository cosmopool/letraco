import 'package:flutter_test/flutter_test.dart';
import 'package:letraco/word_frequency.dart';
import 'package:letraco/words.dart';

void main() {
  test('every word has a frequency at the same index', () {
    expect(frequency.length, dicio.length);
    expect(frequency[dicio.indexOf('ABACATE')], 3.3);
  });
}
