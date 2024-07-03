import 'package:flutter/material.dart';
import 'package:letraco/game_controller.dart';

class ProgressBar extends StatefulWidget {
  const ProgressBar({
    super.key,
    required this.controller,
    required this.size,
  });

  final Size size;
  final GameController controller;

  @override
  State<ProgressBar> createState() => _ProgressBarState();
}

class _ProgressBarState extends State<ProgressBar> {
  late final controller = widget.controller;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Object>(
      stream: widget.controller.events.stream,
      builder: (context, snapshot) {
        final game = controller.game;
        if (game == null) return const CircularProgressIndicator();

        final colors = Theme.of(context).colorScheme;
        final allWords = game.allWords.length;
        final visible = game.visible.length;
        const vertical = 5.0;
        const horizontal = 24.0;
        const indicatorWidth = 30.0;
        const padding =
            EdgeInsets.symmetric(horizontal: horizontal, vertical: vertical);
        const border = BorderRadius.all(Radius.circular(20));
        final maxBarWidth =
            widget.size.width - 2 * indicatorWidth - 2 * horizontal;

        final background = Container(
          width: maxBarWidth,
          decoration: BoxDecoration(
            borderRadius: border,
            color: colors.secondaryContainer,
          ),
        );
        final foreground = Container(
          width: (visible / allWords) * maxBarWidth,
          decoration: BoxDecoration(
            borderRadius: border,
            color: colors.primary,
          ),
        );
        final progressBar = SizedBox(
          height: 10,
          child: Stack(
            children: [
              background,
              foreground,
            ],
          ),
        );

        const indicatorStyle = TextStyle(fontWeight: FontWeight.w700);
        final indicators = Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            SizedBox(
              width: indicatorWidth,
              child: Text(
                visible.toString(),
                style: indicatorStyle,
                textAlign: TextAlign.center,
              ),
            ),
            progressBar,
            SizedBox(
              width: indicatorWidth,
              child: Text(
                allWords.toString(),
                style: indicatorStyle,
                textAlign: TextAlign.center,
              ),
            ),
          ],
        );

        return Padding(
          padding: padding,
          child: indicators,
        );
      },
    );
  }
}
