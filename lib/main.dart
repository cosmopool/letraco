import 'package:flutter/material.dart';
import 'package:letraco/game_controller.dart';
import 'package:letraco/instructions_page.dart';
import 'package:letraco/main_page.dart';
import 'package:letraco/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(GameApp(controller: GameController()));
}

class GameApp extends StatelessWidget {
  const GameApp({
    super.key,
    required this.controller,
  });

  final GameController controller;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Letraço',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.teal,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      themeMode: ThemeMode.system,
      initialRoute: '/initialSplash',
      home: MainPage(controller: controller),
      routes: <String, WidgetBuilder>{
        '/instructions': (context) => const InstructionsPage(),
        '/splash': (context) => SplashScreen(controller: controller),
        '/initialSplash': (context) => SplashScreen(
              controller: controller,
              firstTimeInitializing: true,
            ),
      },
    );
  }
}
