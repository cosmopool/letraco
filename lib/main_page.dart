import 'package:flutter/material.dart';
import 'package:letraco/events.dart';
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
  void initState() {
    if (controller.game == null) controller.loadGame();

    controller.events.stream.listen((event) {
      _showSnackbarOnEvent(event);
      _scrollToCard(event);
      _showSplashOnLoading(event);
    });

    super.initState();
  }

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

  /// Display a snackbar as feedback whenever a [Miss] event is received
  void _showSnackbarOnEvent(Event event) {
    // dismiss snack bar is user start adding letters
    if (event is AddLetter) {
      return ScaffoldMessenger.of(context).hideCurrentSnackBar();
    }

    final content = switch (event) {
      Miss() => 'Essa palavra não está na lista, tente outra!',
      Empty() => 'Utilize as letras para escrever uma palavra!',
      _ => null
    };
    if (content == null) return;

    final safeArea = MediaQuery.of(context).padding.top;
    final snackbar = SnackBar(
      content: Text(content),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      duration: const Duration(seconds: 2),
      margin: EdgeInsets.only(
        bottom: MediaQuery.of(context).size.height - safeArea - 58,
        right: 8,
        left: 8,
      ),
    );

    ScaffoldMessenger.of(context).showSnackBar(snackbar);
  }

  void _scrollToCard(Event event) {
    if (event is! GoToCard) return;

    scrollController.animateTo(
      event.offset,
      duration: const Duration(milliseconds: 100),
      curve: Curves.linear,
    );
  }

  void _showSplashOnLoading(Event event) {
    if (event is Loading) Navigator.of(context).pushNamed('/splash');
  }
}
