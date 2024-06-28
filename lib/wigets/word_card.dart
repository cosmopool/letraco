import 'package:flutter/material.dart';
import 'package:letraco/events.dart';

class WordCard extends StatefulWidget {
  const WordCard({
    super.key,
    required this.size,
    required this.visible,
    required this.word,
    required this.stream,
  });

  final Size size;
  final bool visible;
  final String word;
  final Stream<Event> stream;

  static const width = 120.0;
  static const height = 40.0;
  static const borderRadius = 20.0;
  static const verticalPadding = 8.0;

  @override
  State<WordCard> createState() => _WordCardState();
}

class _WordCardState extends State<WordCard> {
  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final text = widget.visible ? widget.word : '${widget.word.length} letras';
    final style = TextStyle(
      color: widget.visible ? colors.onSurface : colors.outlineVariant,
      fontSize: 12,
      fontWeight: widget.visible ? FontWeight.w600 : FontWeight.w500,
    );
    final borderColor = widget.visible ? colors.primary : colors.outlineVariant;

    const paddingBetweenCards =
        EdgeInsets.symmetric(vertical: WordCard.verticalPadding / 2);
    const borderRadius =
        BorderRadius.all(Radius.circular(WordCard.borderRadius));

    final card = Padding(
      padding: paddingBetweenCards,
      child: Container(
        height: WordCard.height,
        width: WordCard.width,
        decoration: BoxDecoration(
          border: Border.all(color: borderColor, width: 1.5),
          borderRadius: borderRadius,
        ),
        child: Center(
          child: Text(text, style: style, textAlign: TextAlign.center),
        ),
      ),
    );

    return StreamBuilder<Event>(
      stream: widget.stream,
      builder: (context, snapshot) {
        final event = snapshot.data;
        if (event is! Found) return card;
        if (event.word != widget.word) return card;

        return TweenAnimationBuilder(
          tween: Tween(begin: 0, end: WordCard.width),
          duration: const Duration(seconds: 1),
          curve: Curves.easeInOutCirc,
          builder: (context, animationValue, _) {
            final splash = Padding(
              padding: paddingBetweenCards,
              child: CustomPaint(
                painter: SlpashPainter(
                  colorScheme: colors,
                  step: animationValue.toDouble(),
                ),
              ),
            );

            return Stack(
              children: [
                splash,
                card,
              ],
            );
          },
        );
      },
    );
  }
}

class SlpashPainter extends CustomPainter {
  SlpashPainter({
    required this.step,
    required this.colorScheme,
  });

  final double step;
  final ColorScheme colorScheme;

  @override
  void paint(Canvas canvas, Size size) {
    final color = colorScheme.primary;
    const rect = Rect.fromLTWH(0, 0, WordCard.width, WordCard.height);
    const center = Offset(WordCard.width / 2, WordCard.height / 2);
    final radius = step * 2.5;
    final outerCircle = Rect.fromCircle(center: center, radius: radius);
    final innerCircle = Rect.fromCircle(center: center, radius: radius / 5);

    final hole = Path.combine(
      PathOperation.difference,
      Path()..addRect(rect),
      Path()
        ..addOval(outerCircle)
        ..close(),
    );

    final ring = Path.combine(
      PathOperation.difference,
      Path()
        ..addOval(outerCircle)
        ..close(),
      Path()
        ..addOval(innerCircle)
        ..close(),
    );

    canvas.clipRRect(RRect.fromRectAndRadius(rect, const Radius.circular(33)));
    canvas.drawPath(hole, Paint()..color = color.withOpacity(.7));
    canvas.drawPath(ring, Paint()..color = color.withOpacity(0.5));
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}
