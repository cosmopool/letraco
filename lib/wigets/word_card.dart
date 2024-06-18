import 'package:flutter/material.dart';

class WordCard extends StatelessWidget {
  const WordCard({
    super.key,
    required this.size,
    required this.visible,
    required this.word,
  });

  final Size size;
  final bool visible;
  final String word;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    final text = visible ? word : '${word.length} letras';
    final style = TextStyle(
      color: visible ? colors.onSurface : colors.outlineVariant,
      fontSize: 12,
      fontWeight: visible ? FontWeight.w600 : FontWeight.w500,
    );

    final content = Center(
      child: Text(
        text,
        style: style,
        textAlign: TextAlign.center,
      ),
    );

    final borderColor = visible ? colors.primary : colors.outlineVariant;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Container(
        height: 40,
        width: 100,
        decoration: BoxDecoration(
          border: Border.all(color: borderColor, width: 1.5),
          borderRadius: const BorderRadius.all(Radius.circular(20)),
        ),
        child: content,
      ),
    );
  }
}
