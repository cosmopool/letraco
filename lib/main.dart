import 'package:flutter/material.dart';
import 'package:letraco/instructions_page.dart';
import 'package:letraco/main_page.dart';
import 'package:letraco/main_page_controller.dart';

void main() {
  runApp(const GameApp());
}

class GameApp extends StatelessWidget {
  const GameApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Letraço',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
        useMaterial3: true,
      ),
      home: MainPage(controller: GameController.init()),
      routes: <String, WidgetBuilder>{
        '/instructions': (BuildContext context) => const InstructionsPage(),
      },
    );
  }
}
