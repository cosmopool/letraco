import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:letraco/game_controller.dart';
import 'package:letraco/main_page.dart';
import 'package:letraco/theme.dart';
import 'package:letraco/wigets/glossary.dart';
import 'package:letraco/wigets/logo.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'check_input_test.dart' show buildGame;

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  Future<GameController> pumpGame(WidgetTester tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final controller = GameController(buildGame());
    await tester.pumpWidget(
      MaterialApp(
        theme: Caderno.theme(),
        home: MainPage(controller: controller),
      ),
    );
    await tester.pump(const Duration(milliseconds: 100));
    return controller;
  }

  testWidgets('shows progress in words, no points or level', (tester) async {
    await pumpGame(tester);
    expect(find.byType(Logo), findsOneWidget);
    expect(find.textContaining('de 53 palavras'), findsOneWidget);
    expect(find.textContaining('pts'), findsNothing);
    expect(find.text('Glossário · 1'), findsOneWidget);
  });

  testWidgets('typing and sending a new word finds it', (tester) async {
    final controller = await pumpGame(tester);
    for (final letter in ['C', 'A', 'R', 'O']) {
      await tester.tap(find.text(letter));
      await tester.pump(const Duration(milliseconds: 50));
    }
    expect(find.text('4 letras'), findsOneWidget);
    await tester.tap(find.byIcon(Icons.check_rounded));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));
    expect(controller.game!.visible, contains('CARO'));
    expect(find.text('Boa!'), findsOneWidget);
    await tester.pump(const Duration(seconds: 3));
    expect(find.text('Glossário · 2'), findsOneWidget);
  });

  testWidgets('the glossário lists found words and what is missing', (
    tester,
  ) async {
    await pumpGame(tester);
    await tester.tap(find.text('Glossário · 1'));
    await tester.pump(const Duration(milliseconds: 600));
    expect(find.text('Glossário'), findsOneWidget);
    expect(
      find.descendant(
        of: find.byType(Glossary),
        matching: find.text('1 de 53 palavras'),
      ),
      findsOneWidget,
    );
    expect(find.text('4 LETRAS'), findsOneWidget);
    expect(find.textContaining('hora', findRichText: true), findsWidgets);
    expect(
      find.textContaining('Faltam 11 palavras', findRichText: true),
      findsOneWidget,
    );
    expect(
      find.textContaining('Falta 1 palavra', findRichText: true),
      findsOneWidget,
    );
  });
}
