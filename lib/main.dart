import 'package:flutter/material.dart';
import 'package:letraco/instructions_page.dart';
import 'package:letraco/main_page.dart';
import 'package:letraco/game_controller.dart';

void main() {
  runApp(GameApp());
}

class GameApp extends StatelessWidget {
  GameApp({super.key});

  final controller = GameController.init();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Letraço',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
        useMaterial3: true,
      ),
      home: MainPage(controller: controller),
      routes: <String, WidgetBuilder>{
        '/instructions': (BuildContext context) => const InstructionsPage(),
      },
    );
  }
}
