import 'package:letraco/game_controller.dart';

extension Sorting on List<String> {
  /// Group by length and sort a list alphabetically
  /// Divide list into chunks of equal length and sort them alphabetically
  /// This implementation use insertion sort algorithm
  void sortWords() => GameController.sortWords(this);
}
