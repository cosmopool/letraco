import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:letraco/events.dart';
import 'package:letraco/game_controller.dart';
import 'package:letraco/theme.dart';
import 'package:letraco/wigets/drawer.dart';
import 'package:letraco/wigets/glossary.dart';
import 'package:letraco/wigets/hive.dart';
import 'package:letraco/wigets/sky.dart';

/// Game screen: header, progress, the sky of found words and the hive.
class MainPage extends StatefulWidget {
  const MainPage({super.key, required this.controller});

  final GameController controller;

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  late final controller = widget.controller;
  final scaffoldKey = GlobalKey<ScaffoldState>();
  late final StreamSubscription<Event> _sub;
  bool _glossaryOpen = false;

  @override
  void initState() {
    super.initState();
    // The initial splash route covers loading; pushing another splash here
    // on Loading would leave it on screen for good, since it starts listening
    // only after the game was loaded.
    _sub = controller.events.stream.listen((event) {
      if (!mounted) return;
      if (event is Found || event is Loaded) setState(() {});
    });
    if (controller.game == null) controller.loadGame();
  }

  @override
  void dispose() {
    _sub.cancel();
    super.dispose();
  }

  Future<void> _openGlossary() async {
    if (_glossaryOpen) return;
    _glossaryOpen = true;
    await showGlossary(context, controller);
    _glossaryOpen = false;
  }

  /// Letters of the game, Backspace and Enter work like the buttons.
  KeyEventResult _onKey(FocusNode node, KeyEvent event) {
    if (event is KeyUpEvent) return KeyEventResult.ignored;
    final key = event.logicalKey;
    if (key == LogicalKeyboardKey.enter ||
        key == LogicalKeyboardKey.numpadEnter) {
      controller.checkInput();
      return KeyEventResult.handled;
    }
    if (key == LogicalKeyboardKey.backspace) {
      controller.deleteLetter();
      return KeyEventResult.handled;
    }
    final game = controller.game;
    final letter = event.character?.toUpperCase();
    if (game == null || letter == null || event is KeyRepeatEvent) {
      return KeyEventResult.ignored;
    }
    if (letter == game.mandatory || game.letters.contains(letter)) {
      controller.addLetter(letter);
      return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  }

  @override
  Widget build(BuildContext context) {
    final game = controller.game;
    final found = game?.visible.length ?? 0;
    final total = game?.allWords.length ?? 0;

    final header = Padding(
      padding: const EdgeInsets.fromLTRB(20, 14, 10, 4),
      child: Row(
        children: [
          Expanded(
            child: Text(
              'Letraço',
              style: Caderno.serifStyle(
                size: 22,
                weight: FontWeight.w700,
                height: 1,
                letterSpacing: -.2,
                color: Caderno.ink,
              ),
            ),
          ),
          IconButton(
            tooltip: 'Menu',
            onPressed: () => scaffoldKey.currentState?.openDrawer(),
            icon: const Icon(Icons.menu_rounded, color: Caderno.ink),
          ),
        ],
      ),
    );

    final progress = Padding(
      padding: const EdgeInsets.fromLTRB(20, 2, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: SizedBox(
              height: 6,
              child: TweenAnimationBuilder<double>(
                tween: Tween(end: total == 0 ? 0 : found / total),
                duration: const Duration(milliseconds: 600),
                curve: const Cubic(.2, .8, .2, 1),
                builder: (context, value, _) => LinearProgressIndicator(
                  value: value,
                  minHeight: 6,
                  color: Caderno.brand,
                  backgroundColor: Caderno.line,
                ),
              ),
            ),
          ),
          const SizedBox(height: 6),
          Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: '$found',
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    color: Caderno.ink,
                  ),
                ),
                TextSpan(text: ' de $total palavras'),
              ],
            ),
            style: const TextStyle(fontSize: 12.5, color: Caderno.ink2),
          ),
        ],
      ),
    );

    return Focus(
      autofocus: true,
      onKeyEvent: _onKey,
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: Caderno.paper,
        drawer: CustomDrawer(controller: controller),
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              header,
              progress,
              const SizedBox(height: 4),
              Expanded(
                child: Sky(
                  controller: controller,
                  onOpenGlossary: _openGlossary,
                ),
              ),
              PlayRow(controller: controller),
            ],
          ),
        ),
      ),
    );
  }
}
