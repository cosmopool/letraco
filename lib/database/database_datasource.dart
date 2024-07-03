import 'dart:async';

import 'package:letraco/game_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';

typedef GameState = (List<String>, List<String>, List<String>, String);

class SharedPrefs {
  static SharedPreferences? _db;
  static const kHidden = 'hiddenWords';
  static const kVisible = 'visibleWords';
  static const kLetters = 'letters';
  static const kMandatory = 'mandatory';

  static Future<SharedPreferences> getInstance() async {
    if (_db != null) return _db!;
    final instance = await SharedPreferences.getInstance();
    _db = instance;
    return _db!;
  }

  static Future<GameState> loadGame() async {
    final instance = await getInstance();
    final hidden = instance.getStringList(kHidden) ?? [];
    final visible = instance.getStringList(kVisible) ?? [];
    final letters = instance.getStringList(kLetters) ?? [];
    final mandatory = instance.getString(kMandatory) ?? '';
    return (hidden, visible, letters, mandatory);
  }

  static Future<void> saveGame({
    required List<String> hidden,
    required List<String> visible,
    required List<String> letters,
    required String mandatory,
  }) async {
    assert(mandatory.length == 1);
    assert(letters.length == GameController.numberOfLetters - 1);
    assert(!letters.contains(mandatory));
    assert(hidden.length + visible.length >= GameController.minimumWordCount);

    final instance = await getInstance();
    await instance.setStringList(kHidden, hidden);
    await instance.setStringList(kVisible, visible);
    await instance.setStringList(kLetters, letters);
    await instance.setString(kMandatory, mandatory);
  }
}
