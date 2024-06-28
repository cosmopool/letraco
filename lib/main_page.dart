import 'package:flutter/material.dart';
import 'package:letraco/game_controller.dart';
import 'package:letraco/instructions_page.dart';
import 'package:letraco/wigets/circles.dart';
import 'package:letraco/wigets/drawer.dart';
import 'package:letraco/wigets/input_word.dart';
import 'package:letraco/wigets/progress_bar.dart';
import 'package:letraco/wigets/word_list.dart';

class MainPage extends StatefulWidget {
  const MainPage({
    super.key,
    required this.controller,
  });
  final GameController controller;

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  static const double circleSize = 80;

  late final controller = widget.controller;
  final scrollController = ScrollController();
  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final colors = Theme.of(context).colorScheme;

    final menuDrawer = IconButton(
      onPressed: () {
        scaffoldKey.currentState?.openDrawer();
      },
      icon: const Icon(Icons.menu),
    );

    final showInstructionsButton = IconButton(
      onPressed: () => Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => const InstructionsPage(showClose: false),
        ),
      ),
      icon: const Icon(Icons.help_outline_rounded),
    );

    final check = ElevatedButton(
      onPressed: controller.checkInput,
      child: const Text('Checar'),
    );
    final shuffle = IconButton(
      onPressed: controller.shuffle,
      icon: const Icon(Icons.shuffle_rounded),
    );
    final delete = ElevatedButton(
      onPressed: controller.deleteLetter,
      onLongPress: controller.clearInputWord,
      child: Text('Deletar', style: TextStyle(color: colors.onSurface)),
    );

    final buttons = ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: (120 + 10) * 4),
      child: SizedBox(
        height: circleSize,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            delete,
            shuffle,
            check,
          ],
        ),
      ),
    );

    return Scaffold(
      key: scaffoldKey,
      drawer: CustomDrawer(controller: controller),
      body: SafeArea(
        child: Column(
          children: [
            SizedBox(
              height: circleSize / 2,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  showInstructionsButton,
                  menuDrawer,
                ],
              ),
            ),
            Center(
              child: InputWord(height: circleSize, controller: controller),
            ),
            LettersCircles(size: size, controller: controller),
            buttons,
            ProgressBar(size: size, controller: controller),
            Expanded(
              child: WordList(
                size: size,
                controller: controller,
                scrollController: scrollController,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
