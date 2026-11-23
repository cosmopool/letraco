import 'package:flutter/material.dart';
import 'package:letraco/definitions.dart';
import 'package:letraco/game_controller.dart';
import 'package:letraco/theme.dart';

/// Opens the glossário: every found word, grouped by length.
Future<void> showGlossary(BuildContext context, GameController controller) {
  final top = MediaQuery.of(context).padding.top;
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: false,
    backgroundColor: Caderno.card,
    barrierColor: Caderno.scrim,
    constraints: BoxConstraints(
      maxHeight: MediaQuery.of(context).size.height - top - 104,
    ),
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
    ),
    builder: (context) => Glossary(controller: controller),
  );
}

class Glossary extends StatelessWidget {
  const Glossary({super.key, required this.controller});

  final GameController controller;

  @override
  Widget build(BuildContext context) {
    final game = controller.game;
    if (game == null) return const SizedBox.shrink();
    final found = game.visible;
    final total = game.allWords.length;
    final newest = found.isEmpty ? null : found.last;

    final sections = <Widget>[];
    for (
      var n = GameController.minimumWordLength;
      n <= GameController.maximumWordLength;
      n++
    ) {
      final all = game.allWords.where((w) => w.length == n).toList();
      if (all.isEmpty) continue;
      final got = found.where((w) => w.length == n).toList()..sort();
      final missing = game.showAllWords
          ? (all.where((w) => !found.contains(w)).toList()..sort())
          : const <String>[];
      sections.add(
        _Section(
          length: n,
          found: got,
          total: all.length,
          newest: newest,
          game: game,
          revealed: missing,
          first: sections.isEmpty,
        ),
      );
    }

    return SizedBox(
      height: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(top: 10, bottom: 8),
              decoration: BoxDecoration(
                color: Caderno.line,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 8, 14),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Glossário',
                        style: Caderno.serifStyle(
                          size: 26,
                          weight: FontWeight.w700,
                          height: 1.1,
                          color: Caderno.ink,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${found.length} de $total palavras',
                        style: const TextStyle(
                          fontSize: 12.5,
                          color: Caderno.muted,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  tooltip: 'Fechar',
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close_rounded, color: Caderno.ink),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 40),
              children: sections,
            ),
          ),
        ],
      ),
    );
  }
}

/// A brand rule, "N letras · f de t", the words found as entries, and how
/// many are still missing.
class _Section extends StatelessWidget {
  const _Section({
    required this.length,
    required this.found,
    required this.total,
    required this.newest,
    required this.game,
    required this.revealed,
    required this.first,
  });

  final int length;
  final List<String> found;
  final int total;
  final String? newest;
  final Game game;

  /// Missing words, shown only by the debug "show all words" switch.
  final List<String> revealed;
  final bool first;

  @override
  Widget build(BuildContext context) {
    const label = TextStyle(
      fontSize: 11,
      fontWeight: FontWeight.w600,
      letterSpacing: 1.1,
      color: Caderno.muted,
    );
    final left = total - found.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          margin: EdgeInsets.only(top: first ? 2 : 22),
          padding: const EdgeInsets.fromLTRB(2, 10, 2, 4),
          decoration: const BoxDecoration(
            border: Border(top: BorderSide(color: Caderno.brand, width: 2)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('$length LETRAS', style: label),
              Text('${found.length} DE $total', style: label),
            ],
          ),
        ),
        for (final word in found)
          _Entry(
            word: word,
            pangram: game.isPangram(word),
            newest: word == newest,
          ),
        for (final word in revealed) _Entry(word: word, revealed: true),
        const SizedBox(height: 14),
        _Missing(left: left),
      ],
    );
  }
}

class _Entry extends StatelessWidget {
  const _Entry({
    required this.word,
    this.pangram = false,
    this.newest = false,
    this.revealed = false,
  });

  final String word;
  final bool pangram;
  final bool newest;

  /// A missing word shown by the debug switch.
  final bool revealed;

  @override
  Widget build(BuildContext context) {
    final meaning = meaningOf(word);
    final color = revealed
        ? Caderno.dots
        : pangram
        ? Caderno.honey
        : Caderno.brand;
    final tag = pangram
        ? const _Tag('pangrama', Caderno.honeySoft, Caderno.honeyInk)
        : newest
        ? const _Tag('nova', Caderno.brandSoft, Caderno.brand)
        : null;

    final text = Text.rich(
      TextSpan(
        style: Caderno.serifStyle(size: 15, height: 1.4, color: Caderno.ink2),
        children: [
          TextSpan(
            text: word.toLowerCase(),
            style: Caderno.serifStyle(
              size: 18,
              weight: FontWeight.w700,
              color: color,
            ),
          ),
          if (meaning != null) TextSpan(text: '  $meaning'),
          if (tag != null)
            WidgetSpan(
              alignment: PlaceholderAlignment.middle,
              child: Padding(
                padding: const EdgeInsets.only(left: 8),
                child: tag,
              ),
            ),
        ],
      ),
    );

    final row = Container(
      padding: const EdgeInsets.fromLTRB(2, 9, 2, 10),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Caderno.dots, width: .8)),
      ),
      child: text,
    );
    if (!newest) return row;

    // the newest entry starts lit and fades back to the page
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 1, end: 0),
      duration: const Duration(milliseconds: 1600),
      curve: const Interval(.3, 1, curve: Curves.easeOut),
      builder: (context, v, child) => DecoratedBox(
        decoration: BoxDecoration(
          color: Caderno.brandSoft.withValues(alpha: v),
        ),
        child: child,
      ),
      child: row,
    );
  }
}

class _Tag extends StatelessWidget {
  const _Tag(this.text, this.background, this.color);

  final String text;
  final Color background;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(99),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 10.5,
          fontWeight: FontWeight.w600,
          letterSpacing: .4,
          color: color,
        ),
      ),
    );
  }
}

/// What is still missing in the section: a soft brand band with the count in
/// the book serif.
class _Missing extends StatelessWidget {
  const _Missing({required this.left});

  final int left;

  @override
  Widget build(BuildContext context) {
    const style = TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w600,
      color: Caderno.brand,
    );
    final number = Caderno.serifStyle(
      size: 20,
      weight: FontWeight.w700,
      height: 1,
    );
    final spans = left == 0
        ? const [TextSpan(text: 'Todas achadas')]
        : [
            TextSpan(text: left == 1 ? 'Falta ' : 'Faltam '),
            TextSpan(text: '$left', style: number),
            TextSpan(text: left == 1 ? ' palavra' : ' palavras'),
          ];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: left == 0 ? null : Caderno.brandSoft,
        border: left == 0
            ? Border.all(color: Caderno.brandSoft, width: 1.5)
            : null,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text.rich(
        TextSpan(children: spans),
        textAlign: TextAlign.center,
        style: style,
      ),
    );
  }
}
