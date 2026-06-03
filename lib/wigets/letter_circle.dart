import 'package:flutter/material.dart';
import 'package:letraco/events.dart';
import 'package:letraco/game_controller.dart';

class LetterCircle extends StatefulWidget {
  const LetterCircle({
    super.key,
    required this.letter,
    required this.x,
    required this.y,
    this.circleSize = 80,
    this.isMainButton = false,
    required this.controller,
  }) : assert(letter.length == 1);

  final String letter;
  final double circleSize;
  final bool isMainButton;
  final double x;
  final double y;
  final GameController controller;

  @override
  State<LetterCircle> createState() => _LetterCircleState();
}

class _LetterCircleState extends State<LetterCircle>
    with SingleTickerProviderStateMixin {
  double opacity = 1;
  late final _animationController = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 500),
  );

  late final _animation = CurvedAnimation(
    parent: _animationController,
    curve: Curves.easeOutSine,
  );

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final bgColor =
        widget.isMainButton ? colors.primary : colors.surfaceContainerHighest;
    final style = TextStyle(
      fontSize: widget.circleSize * .4,
      fontWeight: FontWeight.w700,
      color: widget.isMainButton ? colors.onPrimary : colors.onSurface,
    );
    const borderRadius = BorderRadius.all(Radius.circular(100));

    return StreamBuilder<Object>(
      stream: widget.controller.stream,
      builder: (context, snapshot) {
        final _ = switch (snapshot.data) {
          ShuffleStart() => _animationController
              .forward(from: 0)
              .then((_) => widget.controller.shuffleEnd()),
          ShuffleEnd() => _animationController.reverse(from: 1),
          null => null,
          _ => null,
        };
        return AnimatedBuilder(
          animation: _animation,
          builder: (context, _) {
            return Positioned(
              top: widget.x,
              left: widget.y,
              child: Material(
                borderRadius: borderRadius,
                color: bgColor,
                child: InkWell(
                  borderRadius: borderRadius,
                  onTap: () => widget.controller.addLetter(widget.letter),
                  child: SizedBox(
                    height: widget.circleSize,
                    width: widget.circleSize,
                    child: Center(
                      child: Opacity(
                        opacity: widget.isMainButton ? 1 : 1 - _animation.value,
                        child: Text(widget.letter.toUpperCase(), style: style),
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
