import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:letraco/database/database_datasource.dart';
import 'package:letraco/game_controller.dart';
import 'package:letraco/splash_screen.dart';
import 'package:letraco/wigets/logo.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.resetStatic();
    SharedPrefs.reset();
    SharedPreferences.setMockInitialValues({
      'hiddenWords': ['CARO', ...List.generate(50, (i) => 'RRR$i')],
      'visibleWords': ['HORA'],
      'letters': ['E', 'H', 'A', 'L', 'O', 'C'],
      'mandatory': 'R',
    });
  });

  Future<void> pumpFor(WidgetTester tester, Duration total) async {
    for (
      var t = Duration.zero;
      t < total;
      t += const Duration(milliseconds: 50)
    ) {
      await tester.pump(const Duration(milliseconds: 50));
    }
  }

  testWidgets('the splash holds until the game loads, then leaves', (
    tester,
  ) async {
    final controller = GameController();
    await tester.pumpWidget(
      MaterialApp(
        home: const Scaffold(body: Text('jogo')),
        initialRoute: '/initialSplash',
        onGenerateRoute: (settings) => settings.name == '/initialSplash'
            ? SplashScreen.route(controller, settings)
            : null,
      ),
    );

    await pumpFor(tester, const Duration(seconds: 3));
    expect(find.byType(SplashScreen), findsOneWidget);
    expect(find.text('Espalhando as palavras…'), findsOneWidget);
    expect(Logo.reveal.value, 0);

    await tester.runAsync(controller.loadGame);
    await pumpFor(tester, const Duration(seconds: 2));
    expect(find.byType(SplashScreen), findsNothing);
    expect(find.text('jogo'), findsOneWidget);
    expect(Logo.reveal.value, 1);
  });
}
