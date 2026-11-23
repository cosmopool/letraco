import 'package:flutter_test/flutter_test.dart';
import 'package:letraco/database/database_datasource.dart';
import 'package:letraco/game_controller.dart';
import 'package:letraco/main.dart';
import 'package:letraco/main_page.dart';
import 'package:letraco/splash_screen.dart';
import 'package:letraco/wigets/logo.dart';
import 'package:letraco/wigets/sky.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Regression: opening the app got stuck on the loading splash.
void main() {
  setUp(() {
    SharedPreferences.resetStatic();
    SharedPrefs.reset();
  });

  Future<void> openApp(WidgetTester tester) async {
    await tester.pumpWidget(GameApp(controller: GameController()));
    // generating a new game takes real time, so wait on the wall clock
    final clock = Stopwatch()..start();
    while (clock.elapsed < const Duration(seconds: 5)) {
      await tester.pump(const Duration(milliseconds: 100));
    }
  }

  void expectGameScreen() {
    expect(find.byType(SplashScreen, skipOffstage: false), findsNothing);
    expect(find.byType(MainPage), findsOneWidget);
    expect(find.byType(Sky), findsOneWidget);
    expect(Logo.reveal.value, 1);
  }

  final savedGame = <String, Object>{
    'hiddenWords': ['CARO', ...List.generate(50, (i) => 'RRR$i')],
    'letters': ['E', 'H', 'A', 'L', 'O', 'C'],
    'mandatory': 'R',
  };

  testWidgets('a saved game with found words opens the game', (tester) async {
    SharedPreferences.setMockInitialValues({
      ...savedGame,
      'visibleWords': ['HORA'],
    });
    await openApp(tester);
    expectGameScreen();
    expect(
      find.textContaining('Glossário · 1', findRichText: true),
      findsOneWidget,
    );
  });

  testWidgets('a saved game with no found words opens a game', (tester) async {
    SharedPreferences.setMockInitialValues({
      ...savedGame,
      'visibleWords': <String>[],
    });
    await openApp(tester);
    expectGameScreen();
  });

  testWidgets('no saved game opens a new game', (tester) async {
    SharedPreferences.setMockInitialValues({});
    await openApp(tester);
    expectGameScreen();
    expect(
      find.textContaining('Glossário · 0', findRichText: true),
      findsOneWidget,
    );
  });
}
