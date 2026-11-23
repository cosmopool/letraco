import 'dart:async';

import 'package:flutter/material.dart';
import 'package:letraco/events.dart';
import 'package:letraco/game_controller.dart';
import 'package:letraco/theme.dart';

/// Play row: Embaralhar and Apagar on the left, the hive of letters in the
/// middle, Enviar on the right at the height of Apagar.
class PlayRow extends StatelessWidget {
  const PlayRow({super.key, required this.controller});

  final GameController controller;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(10, 4, 10, 26),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 70,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ActionButton(
                  tooltip: 'Embaralhar',
                  icon: Icons.sync_rounded,
                  onTap: controller.shuffle,
                ),
                const SizedBox(height: 10),
                DeleteButton(controller: controller),
              ],
            ),
          ),
          const SizedBox(width: 6),
          Hive(controller: controller),
          const SizedBox(width: 6),
          SizedBox(
            width: 70,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 50),
                ActionButton(
                  tooltip: 'Enviar',
                  icon: Icons.check_rounded,
                  iconSize: 26,
                  onTap: controller.checkInput,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Round, thin outline, transparent, grey icon, no label.
class ActionButton extends StatefulWidget {
  const ActionButton({
    super.key,
    required this.tooltip,
    required this.icon,
    this.iconSize = 22,
    this.onTap,
    this.onPointerDown,
    this.onPointerUp,
  });

  final String tooltip;
  final IconData icon;
  final double iconSize;
  final VoidCallback? onTap;
  final VoidCallback? onPointerDown;
  final VoidCallback? onPointerUp;

  @override
  State<ActionButton> createState() => _ActionButtonState();
}

class _ActionButtonState extends State<ActionButton> {
  bool _down = false;

  void _press(bool down) => setState(() => _down = down);

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: widget.tooltip,
      child: Listener(
        onPointerDown: (_) {
          _press(true);
          widget.onPointerDown?.call();
        },
        onPointerUp: (_) {
          _press(false);
          widget.onPointerUp?.call();
        },
        onPointerCancel: (_) => _press(false),
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: widget.onTap,
          child: AnimatedScale(
            scale: _down ? .9 : 1,
            duration: const Duration(milliseconds: 120),
            child: Container(
              width: 46,
              height: 40,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Caderno.line, width: 1.5),
              ),
              child: Icon(
                widget.icon,
                size: widget.iconSize,
                color: Caderno.ink2,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Tap deletes the last letter; holding for 450 ms clears the word.
class DeleteButton extends StatefulWidget {
  const DeleteButton({super.key, required this.controller});

  final GameController controller;

  @override
  State<DeleteButton> createState() => _DeleteButtonState();
}

class _DeleteButtonState extends State<DeleteButton> {
  static const holdToClear = Duration(milliseconds: 450);
  Timer? _hold;

  @override
  void dispose() {
    _hold?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ActionButton(
      tooltip: 'Apagar (segure para limpar)',
      icon: Icons.backspace_outlined,
      onPointerDown: () {
        _hold?.cancel();
        _hold = Timer(holdToClear, () {
          _hold = null;
          widget.controller.clearInputWord();
        });
      },
      onPointerUp: () {
        final hold = _hold;
        if (hold == null) return;
        hold.cancel();
        _hold = null;
        widget.controller.deleteLetter();
      },
    );
  }
}

/// Seven hexagons: the mandatory letter in the middle, the other six around.
class Hive extends StatefulWidget {
  const Hive({super.key, required this.controller});

  final GameController controller;

  static const width = 196.0;
  static const height = 204.0;
  static const tileWidth = 76.0;
  static const tileHeight = 66.0;

  @override
  State<Hive> createState() => _HiveState();
}

class _HiveState extends State<Hive> with SingleTickerProviderStateMixin {
  static const _hx = 60.0;
  static const _hy = 69.0;

  /// Top-left offset of each outer slot, relative to the center tile.
  static const _slots = [
    Offset(0, -_hy),
    Offset(_hx, -_hy / 2),
    Offset(_hx, _hy / 2),
    Offset(0, _hy),
    Offset(-_hx, _hy / 2),
    Offset(-_hx, -_hy / 2),
  ];

  late final _pulse = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 400),
  );
  late final StreamSubscription<Event> _sub;

  @override
  void initState() {
    super.initState();
    _sub = widget.controller.stream.listen((event) {
      if (event is MissingMandatory) _pulseTwice();
      if (event is Shuffled || event is Loaded) setState(() {});
    });
  }

  Future<void> _pulseTwice() async {
    for (var i = 0; i < 2 && mounted; i++) {
      await _pulse.forward(from: 0);
    }
    if (mounted) _pulse.value = 0;
  }

  @override
  void dispose() {
    _sub.cancel();
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final game = widget.controller.game;
    if (game == null) {
      return const SizedBox(width: Hive.width, height: Hive.height);
    }

    final center = HexKey(
      letter: game.mandatory,
      isCenter: true,
      onTap: () => widget.controller.addLetter(game.mandatory),
    );

    return SizedBox(
      width: Hive.width,
      height: Hive.height,
      child: Stack(
        children: [
          Positioned(
            left: _hx,
            top: _hy,
            child: AnimatedBuilder(
              animation: _pulse,
              builder: (context, child) {
                // up and back: 1 → 1.08 → 1
                final t = 1 - (2 * _pulse.value - 1).abs();
                return Transform.scale(scale: 1 + .08 * t, child: child);
              },
              child: center,
            ),
          ),
          for (var i = 0; i < game.letters.length; i++)
            AnimatedPositioned(
              key: ValueKey(game.letters[i]),
              duration: const Duration(milliseconds: 320),
              curve: Curves.easeInOutCubic,
              left: _hx + _slots[i].dx,
              top: _hy + _slots[i].dy,
              child: HexKey(
                letter: game.letters[i],
                onTap: () => widget.controller.addLetter(game.letters[i]),
              ),
            ),
        ],
      ),
    );
  }
}

class HexKey extends StatefulWidget {
  const HexKey({
    super.key,
    required this.letter,
    required this.onTap,
    this.isCenter = false,
  });

  final String letter;
  final bool isCenter;
  final VoidCallback onTap;

  @override
  State<HexKey> createState() => _HexKeyState();
}

class _HexKeyState extends State<HexKey> {
  bool _down = false;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: widget.isCenter
          ? 'Letra ${widget.letter}, obrigatória'
          : 'Letra ${widget.letter}',
      child: GestureDetector(
        onTapDown: (_) => setState(() => _down = true),
        onTapUp: (_) => setState(() => _down = false),
        onTapCancel: () => setState(() => _down = false),
        onTap: widget.onTap,
        child: AnimatedScale(
          scale: _down ? .9 : 1,
          duration: const Duration(milliseconds: 100),
          child: ClipPath(
            clipper: const HexagonClipper(),
            child: Container(
              width: Hive.tileWidth,
              height: Hive.tileHeight,
              alignment: Alignment.center,
              color: widget.isCenter ? Caderno.brand : Caderno.tile,
              child: Text(
                widget.letter,
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w700,
                  height: 1,
                  color: widget.isCenter ? Caderno.brandInk : Caderno.ink,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Flat-top hexagon filling its box.
class HexagonClipper extends CustomClipper<Path> {
  const HexagonClipper();

  @override
  Path getClip(Size size) {
    final w = size.width, h = size.height;
    return Path()
      ..moveTo(w * .25, 0)
      ..lineTo(w * .75, 0)
      ..lineTo(w, h / 2)
      ..lineTo(w * .75, h)
      ..lineTo(w * .25, h)
      ..lineTo(0, h / 2)
      ..close();
  }

  @override
  bool shouldReclip(HexagonClipper oldClipper) => false;
}
