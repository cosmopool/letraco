import 'dart:async';
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:letraco/definitions.dart';
import 'package:letraco/events.dart';
import 'package:letraco/game_controller.dart';
import 'package:letraco/theme.dart';

/// The sky of found words. They float at their own depth, the typed word
/// lives in the middle, and the line of recent words sits at the bottom.
class Sky extends StatefulWidget {
  const Sky({
    super.key,
    required this.controller,
    required this.onOpenGlossary,
  });

  final GameController controller;
  final VoidCallback onOpenGlossary;

  /// Height kept free at the bottom for the line of recent words.
  static const footer = 44.0;

  @override
  State<Sky> createState() => _SkyState();
}

enum _Result { good, bad, dup }

/// Floating sizes: [_near] px far … [_near] + [_farSpan] px near, [_front] px
/// when tapped. The typed word is [_typedSize] px; words are measured at
/// [_baseSize] px and scaled.
const _near = 12.0;
const _farSpan = 16.0;
const _front = 30.0;
const _typedSize = 46.0;
const _baseSize = 32.0;

/// Height of the typed letters row and of the feedback line under it.
const _lettersHeight = 58.0;
const _feedbackHeight = 28.0;

class _SkyState extends State<Sky> with TickerProviderStateMixin {
  late final GameController controller = widget.controller;
  late final StreamSubscription<Event> _sub;
  final _random = math.Random();

  // floating words
  final _floaters = <_Floater>[];
  final _frame = _Frame();
  late final Ticker _ticker;
  Duration _elapsed = Duration.zero;
  Duration _last = Duration.zero;
  Size _size = Size.zero;
  bool _seeded = false;
  bool _still = false;
  _Floater? _frontFloater;

  // typed word
  String _typed = '';
  _Result? _result;
  bool _flown = false;
  _Feedback? _feedback;
  String _toastText = '';
  Timer? _pending;
  late final _blink = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1000),
  )..repeat();
  late final _hop = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 760),
  );
  late final _shake = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 300),
  );
  late final _gone = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 450),
  );
  late final _toast = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1600),
  );
  late final _wave = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 750),
  );

  // meaning card over a floating word
  _Floater? _tipFor;
  Timer? _tipTimer;

  // line of recent words: bumps when a word is found
  int _footBump = 0;

  @override
  void initState() {
    super.initState();
    _ticker = createTicker(_tick)..start();
    _sub = controller.stream.listen(_onEvent);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _still = MediaQuery.of(context).disableAnimations;
  }

  @override
  void dispose() {
    _sub.cancel();
    _pending?.cancel();
    _tipTimer?.cancel();
    _ticker.dispose();
    _frame.dispose();
    for (final c in [_blink, _hop, _shake, _gone, _toast, _wave]) {
      c.dispose();
    }
    super.dispose();
  }

  Game? get _game => controller.game;

  // ---------------------------------------------------------------- events

  void _onEvent(Event event) {
    if (!mounted) return;
    switch (event) {
      case AddLetter(:final word):
        _hideTip();
        if (_result != null) _reset(notify: false);
        setState(() {
          _typed = word;
          _feedback = _Feedback.count(word.length);
        });
        _sendWave();
      case DeleteLetter(:final word):
        if (_result != null) return;
        setState(() {
          _typed = word;
          _feedback = word.isEmpty ? null : _Feedback.count(word.length);
        });
      case ClearLetters():
        if (_result != null) return;
        setState(() {
          _typed = '';
          _feedback = null;
        });
      case ReachedMaximumLetters():
        setState(() => _feedback = const _Feedback.error('Máximo de 8 letras'));
      case TooShort(:final word):
        _bad(word, 'Curta demais — mínimo 4 letras');
      case MissingMandatory(:final word):
        _bad(word, 'Falta o ${_game?.mandatory ?? ''}, a letra do centro');
      case Miss(:final word):
        _bad(word, 'Não está na lista');
      case AlreadyFound(:final word):
        _duplicate(word);
      case Found(:final word):
        _found(word);
      case Loaded():
        _hideTip();
        _reset(notify: false);
        setState(() {
          _floaters.clear();
          _frontFloater = null;
          _seeded = false;
        });
      default:
        break;
    }
  }

  void _bad(String word, String message) {
    _pending?.cancel();
    setState(() {
      _typed = word;
      _result = _Result.bad;
      _feedback = _Feedback.error(message);
    });
    _shake.forward(from: 0);
    _buzzTwice();
    _leave(const Duration(milliseconds: 650));
  }

  void _duplicate(String word) {
    _pending?.cancel();
    setState(() {
      _typed = word;
      _result = _Result.dup;
      _feedback = const _Feedback.neutral('Já encontrada');
    });
    final floater = _floaterOf(word);
    if (floater != null) _bringFront(floater);
    _leave(const Duration(milliseconds: 650));
  }

  void _found(String word) {
    _pending?.cancel();
    final game = _game;
    final lower = word.toLowerCase();
    final meaning = meaningOf(word);
    setState(() {
      _typed = word;
      _result = _Result.good;
      _feedback = meaning == null ? null : _Feedback.found(lower, meaning);
      _toastText = game != null && game.isPangram(word)
          ? 'Pangrama!'
          : word.length >= 6
          ? 'Ótima!'
          : 'Boa!';
      _footBump++;
    });
    _hop.forward(from: 0);
    _toast.forward(from: 0);
    HapticFeedback.lightImpact();
    // the word takes off into the sky; its meaning lingers a moment
    _pending = Timer(const Duration(milliseconds: 650), () {
      if (!mounted) return;
      _flyIn(word);
      setState(() => _flown = true);
      _pending = Timer(const Duration(milliseconds: 900), _fadeAndReset);
    });
  }

  /// After a result the word leaves; the next letter starts a new one.
  void _leave(Duration delay) {
    _pending?.cancel();
    _pending = Timer(delay, _fadeAndReset);
  }

  void _fadeAndReset() {
    if (!mounted) return;
    _gone.forward(from: 0).whenComplete(() {
      if (mounted && _gone.value == 1) _reset();
    });
  }

  void _reset({bool notify = true}) {
    _pending?.cancel();
    _pending = null;
    _gone.value = 0;
    _hop.value = 0;
    _shake.value = 0;
    _typed = '';
    _result = null;
    _flown = false;
    _feedback = null;
    if (notify) setState(() {});
  }

  Future<void> _buzzTwice() async {
    await HapticFeedback.mediumImpact();
    await Future<void>.delayed(const Duration(milliseconds: 80));
    await HapticFeedback.mediumImpact();
  }

  void _submitTyped() {
    if (_typed.isEmpty || _result != null) return;
    controller.checkInput();
  }

  // -------------------------------------------------------------- geometry

  double get _skyHeight => math.max(0, _size.height - Sky.footer);
  double get _centerY => _skyHeight / 2;

  String _measured = '';
  double _measuredWidth = 0;

  /// Area the typed word and its feedback occupy; null when nothing is typed.
  Rect? _keepOut() {
    if (_typed.isEmpty || _size.isEmpty) return null;
    if (_typed != _measured) {
      final painter = TextPainter(
        text: TextSpan(text: _typed, style: _typedStyle(Caderno.ink)),
        textDirection: TextDirection.ltr,
      )..layout();
      _measured = _typed;
      _measuredWidth = painter.width;
      painter.dispose();
    }
    final cx = _size.width / 2;
    final half = math.max(_measuredWidth / 2 + 6, 90.0);
    return Rect.fromLTRB(
      cx - half - 18,
      _centerY - _lettersHeight / 2 - 14,
      cx + half + 18,
      _centerY + _lettersHeight / 2 + _feedbackHeight + 10,
    );
  }

  // --------------------------------------------------------- floating words

  void _seed(Size size) {
    _size = size;
    if (_seeded || size.isEmpty) return;
    final game = _game;
    if (game == null) return;
    _seeded = true;
    final placed = <Rect>[];
    for (final word in game.visible) {
      _floaters.add(_makeFloater(word.toLowerCase(), game, placed));
    }
  }

  /// A spot anywhere in the sky that overlaps the words already placed the
  /// least, at a random depth.
  _Floater _makeFloater(String word, Game game, List<Rect> placed) {
    final floater = _Floater(
      word: word,
      tone: game.isPangram(word.toUpperCase())
          ? Caderno.honey
          : Caderno.tones[_hash(word) % Caderno.tones.length],
    );
    final w = _size.width, h = _skyHeight - 6;
    final ww = floater.base * 24 / _baseSize + 14;
    const hh = 24 * 1.15 + 6;
    final widest = floater.base * (_near + _farSpan) / _baseSize;
    var best = double.infinity;
    var spot = Offset.zero;
    for (var k = 0; k < 300 && best > 0; k++) {
      final x = 8 + _random.nextDouble() * math.max(1, w - 16 - widest);
      final y = 6 + _random.nextDouble() * math.max(1, h - hh - 6);
      final rect = Rect.fromLTWH(x, y, ww, hh);
      var area = 0.0;
      for (final r in placed) {
        final o = rect.intersect(r);
        if (o.width > 0 && o.height > 0) area += o.width * o.height;
      }
      if (area < best) {
        best = area;
        spot = Offset(x, y);
      }
    }
    placed.add(Rect.fromLTWH(spot.dx, spot.dy, ww, hh));

    final z = _random.nextDouble();
    final heading = _random.nextDouble() * math.pi * 2;
    final start = math.asin(z * 2 - 1);
    return floater
      ..x = spot.dx + 7
      ..y = spot.dy + 3
      ..z = z
      // half of the words start getting closer, the other half farther
      ..phase = _random.nextBool() ? start : math.pi - start
      ..speed = 2 * math.pi / (25000 + _random.nextDouble() * 20000)
      ..vx = math.cos(heading) * 8
      ..vy = math.sin(heading) * 8
      ..heading = heading;
  }

  /// A fresh find starts exactly where it was typed, at the typed size, and
  /// shrinks into its own depth.
  void _flyIn(String word) {
    final game = _game;
    if (game == null || _size.isEmpty) return;
    final floater = _makeFloater(word.toLowerCase(), game, []);
    final t = _elapsed.inMicroseconds / 1000;
    floater
      ..phase -= t * floater.speed
      ..boost = _typedSize / (_near + floater.z * _farSpan)
      ..boost0 = floater.boost
      ..vx = 0
      ..vy = 0;
    final s = _scaleOf(floater);
    floater
      ..x = _size.width / 2 - floater.base * s / 2
      ..y = _centerY - floater.height * s / 2;
    _floaters.add(floater);
  }

  _Floater? _floaterOf(String word) {
    final lower = word.toLowerCase();
    for (final f in _floaters) {
      if (f.word == lower) return f;
    }
    return null;
  }

  double _scaleOf(_Floater f) {
    final px = identical(f, _frontFloater) ? _front : _near + f.z * _farSpan;
    return px / _baseSize * (f.boost == 0 ? 1 : f.boost);
  }

  /// Each typed letter sends a wave out from the word: nearer words get
  /// pushed harder, and a little later the farther they are.
  void _sendWave() {
    final k = _keepOut();
    if (k == null) return;
    _wave.forward(from: 0);
    final now = _elapsed;
    for (final f in _floaters) {
      final s = _scaleOf(f);
      final dx = f.x + f.base * s / 2 - k.center.dx;
      final dy = (f.y + f.height * s / 2 - k.center.dy) * 1.6;
      final dist = math.max(1, math.sqrt(dx * dx + dy * dy));
      final power = 50 * math.exp(-dist / 150) * (.6 + f.z * .6);
      f.kick = _Kick(
        at: now + Duration(microseconds: (dist * 1400).round()),
        vx: dx / dist * power,
        vy: dy / dist * power * .8,
      );
    }
  }

  void _tick(Duration elapsed) {
    final dt = math.min(.05, (elapsed - _last).inMicroseconds / 1e6);
    _last = elapsed;
    _elapsed = elapsed;
    if (_floaters.isEmpty || _size.isEmpty) {
      if (_wave.isAnimating) _frame.tick();
      return;
    }
    final t = elapsed.inMicroseconds / 1000;
    final w = _size.width, h = _skyHeight;
    final k = _keepOut();
    final damp = math.pow(.55, dt).toDouble();
    final frames = dt * 60;

    for (final f in _floaters) {
      final front = identical(f, _frontFloater);
      final target = front
          ? 1.0
          : _still
          ? f.z
          : .5 + .5 * math.sin(t * f.speed + f.phase);
      final before = _scaleOf(f);
      final ease = front ? .18 : .03;
      f.z += (target - f.z) * (1 - math.pow(1 - ease, frames));
      if (f.boost != 0) {
        f.boost += (1 - f.boost) * (1 - math.pow(1 - .025, frames));
        if ((f.boost - 1).abs() < .005) f.boost = 0;
      }
      final s = _scaleOf(f);
      final ww = f.base * s, hh = f.height * s;
      // grow and shrink around the word's center
      f.x += f.base * (before - s) / 2;
      f.y += f.height * (before - s) / 2;

      if (!_still) {
        // wander: a slowly turning heading, faster when near
        f.heading += (_random.nextDouble() - .5) * 1.6 * dt;
        final cruise = 6 + f.z * 10;
        f.vx += (math.cos(f.heading) * cruise - f.vx) * .6 * dt;
        f.vy += (math.sin(f.heading) * cruise * .7 - f.vy) * .6 * dt;
      }
      final kick = f.kick;
      if (kick != null && elapsed >= kick.at) {
        f.vx += kick.vx;
        f.vy += kick.vy;
        f.kick = null;
      }
      if (k != null && f.boost == 0) {
        // stay out from behind the typed word
        final ox = math.min(f.x + ww, k.right) - math.max(f.x, k.left);
        final oy = math.min(f.y + hh, k.bottom) - math.max(f.y, k.top);
        if (ox > 0 && oy > 0) {
          final mx = f.x + ww / 2 - k.center.dx;
          final my = f.y + hh / 2 - k.center.dy;
          if (my.abs() * 2.2 > mx.abs()) {
            f.vy += (my < 0 ? -1 : 1) * math.min(oy, 40) * dt;
          } else {
            f.vx += (mx < 0 ? -1 : 1) * math.min(ox, 40) * dt;
          }
        }
      }
      // fast motion fades out with damping; cruising speed is kept
      if (math.sqrt(f.vx * f.vx + f.vy * f.vy) > 18) {
        f.vx *= damp;
        f.vy *= damp;
      }
      f.x += f.vx * dt;
      f.y += f.vy * dt;
      // soft walls
      if (f.x < 4) {
        f.x = 4;
        f.vx = f.vx.abs() * .5;
        f.heading = math.pi - f.heading;
      }
      if (f.x + ww > w - 4) {
        f.x = w - 4 - ww;
        f.vx = -f.vx.abs() * .5;
        f.heading = math.pi - f.heading;
      }
      if (f.y < 2) {
        f.y = 2;
        f.vy = f.vy.abs() * .5;
        f.heading = -f.heading;
      }
      if (f.y + hh > h) {
        f.y = h - hh;
        f.vy = -f.vy.abs() * .5;
        f.heading = -f.heading;
      }
    }

    // words at a similar depth nudge each other apart; others pass through
    for (var i = 0; i < _floaters.length; i++) {
      for (var j = i + 1; j < _floaters.length; j++) {
        final a = _floaters[i], b = _floaters[j];
        if ((a.z - b.z).abs() > .3) continue;
        final sa = _scaleOf(a), sb = _scaleOf(b);
        final ox =
            math.min(a.x + a.base * sa, b.x + b.base * sb) - math.max(a.x, b.x);
        final oy =
            math.min(a.y + a.height * sa, b.y + b.height * sb) -
            math.max(a.y, b.y);
        if (ox > 0 && oy > 0) {
          final push = math.min(ox, oy) * 6 * dt;
          final up = a.y + a.height * sa / 2 < b.y + b.height * sb / 2;
          final dir = up ? -1 : 1;
          a.vy += dir * push;
          b.vy -= dir * push;
        }
      }
    }
    _frame.tick();
  }

  /// Opacity, blur and color of a floating word for this frame.
  _Look _lookOf(_Floater f) {
    final front = identical(f, _frontFloater);
    if (front) return _Look(Caderno.ink, .9, 0, true);
    final z = f.z;
    // 1 just found … 0 settled
    final fresh = f.boost == 0 ? 0.0 : (f.boost - 1) / (f.boost0 - 1);
    var clear = 1.0;
    if (_typed.isEmpty) {
      // words fade as they pass the empty caret
      final s = _scaleOf(f);
      final dx = f.x + f.base * s / 2 - _size.width / 2;
      final dy = (f.y + f.height * s / 2 - _centerY) * 1.8;
      final dist = math.sqrt(dx * dx + dy * dy);
      clear = ((dist - 40) / 90).clamp(.08, 1.0);
    }
    // never as solid as the typed word
    final base = .26 + z * .56;
    final opacity = (base + (1 - base) * fresh) * clear;
    final blur = z < .3 ? (.3 - z) * 5 * (1 - fresh) : 0.0;
    return _Look(f.tone, opacity, blur, false);
  }

  _Floater? _hitFloater(Offset p) {
    final order = _paintOrder();
    for (var i = order.length - 1; i >= 0; i--) {
      final f = order[i];
      final s = _scaleOf(f);
      final rect = Rect.fromLTWH(f.x, f.y, f.base * s, f.height * s);
      if (rect.inflate(6).contains(p)) return f;
    }
    return null;
  }

  List<_Floater> _paintOrder() {
    final list = [..._floaters]..sort((a, b) => a.z.compareTo(b.z));
    final front = _frontFloater;
    if (front != null && list.remove(front)) list.add(front);
    return list;
  }

  /// Tapping a floating word pulls it to the nearest depth, in ink.
  void _bringFront(_Floater f) {
    _frontFloater = f;
    _showTip(f);
  }

  void _showTip(_Floater f) {
    _tipTimer?.cancel();
    if (meaningOf(f.word) == null) {
      _hideTip();
      return;
    }
    setState(() => _tipFor = f);
    _tipTimer = Timer(const Duration(seconds: 5), _hideTip);
  }

  void _hideTip() {
    _tipTimer?.cancel();
    if (_tipFor != null && mounted) setState(() => _tipFor = null);
  }

  // ----------------------------------------------------------------- build

  TextStyle _typedStyle(Color color) {
    return Caderno.serifStyle(
      size: _typedSize,
      weight: FontWeight.w600,
      color: color,
      height: 1,
      letterSpacing: _typedSize * .04,
      shadows: const [
        Shadow(color: Caderno.paper, blurRadius: 4),
        Shadow(color: Caderno.paper, blurRadius: 12),
        Shadow(color: Caderno.paper, blurRadius: 20),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        _seed(constraints.biggest);
        return Listener(
          onPointerDown: (e) {
            if (_tipFor != null && _hitFloater(e.localPosition) == null) {
              _hideTip();
            }
          },
          child: Stack(
            clipBehavior: Clip.hardEdge,
            children: [
              Positioned.fill(
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTapUp: (details) {
                    final f = _hitFloater(details.localPosition);
                    if (f != null) _bringFront(f);
                  },
                  child: CustomPaint(painter: _SkyPainter(this)),
                ),
              ),
              _buildTyped(),
              _buildTip(),
              Positioned(
                left: 20,
                right: 20,
                bottom: 0,
                child: _RecentLine(
                  game: _game,
                  bump: _footBump,
                  onOpen: widget.onOpenGlossary,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTyped() {
    final top = _centerY - _lettersHeight / 2;
    final empty = _typed.isEmpty;
    final mandatory = _game?.mandatory ?? '';

    final Widget feedback;
    if (empty) {
      feedback = _Feedback.hint(mandatory).build();
    } else {
      feedback = _feedback?.build() ?? const SizedBox.shrink();
    }

    final letters = <Widget>[];
    for (var i = 0; i < _typed.length; i++) {
      final letter = _typed[i];
      final color = switch (_result) {
        _Result.good => Caderno.brand,
        _Result.bad => Caderno.error,
        _Result.dup => Caderno.muted,
        null => letter == mandatory ? Caderno.brand : Caderno.ink,
      };
      letters.add(
        _TypedLetter(
          key: ValueKey('$i$letter'),
          index: i,
          hop: _result == _Result.good ? _hop : null,
          child: Text(letter, style: _typedStyle(color)),
        ),
      );
    }
    if (_result == null) {
      letters.add(_Caret(blink: _blink, empty: empty));
    }

    Widget row = Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: letters,
    );
    row = AnimatedBuilder(
      animation: _shake,
      builder: (context, child) => Transform.translate(
        offset: Offset(_shakeOffset(_shake.value), 0),
        child: child,
      ),
      child: Visibility(
        visible: !_flown,
        maintainSize: true,
        maintainAnimation: true,
        maintainState: true,
        child: row,
      ),
    );
    if (!empty) {
      row = GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: _submitTyped,
        child: row,
      );
    }

    final block = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Center(
          child: SizedBox(height: _lettersHeight, child: row),
        ),
        IgnorePointer(
          child: SizedBox(
            height: _feedbackHeight,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 6, 24, 0),
              child: feedback,
            ),
          ),
        ),
      ],
    );

    return Positioned(
      left: 0,
      right: 0,
      top: top,
      child: IgnorePointer(
        ignoring: empty,
        child: AnimatedBuilder(
          animation: _gone,
          builder: (context, child) {
            final g = Curves.easeIn.transform(_gone.value);
            Widget out = Opacity(
              opacity: 1 - g,
              child: Transform.scale(scale: 1 - .14 * g, child: child),
            );
            if (g > 0) {
              out = ImageFiltered(
                imageFilter: ui.ImageFilter.blur(sigmaX: 4 * g, sigmaY: 4 * g),
                child: out,
              );
            }
            return out;
          },
          child: Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.topCenter,
            children: [
              block,
              Positioned(
                top: -34,
                child: IgnorePointer(
                  child: _Toast(animation: _toast, text: _toastText),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// The meaning card above the tapped word; it follows the word.
  Widget _buildTip() {
    final f = _tipFor;
    final meaning = f == null ? null : meaningOf(f.word);
    if (f == null || meaning == null) return const SizedBox.shrink();
    return AnimatedBuilder(
      animation: _frame,
      builder: (context, child) {
        final s = _scaleOf(f);
        final cx = (f.x + f.base * s / 2).clamp(130.0, _size.width - 130);
        return Positioned(
          left: cx - 120,
          width: 240,
          bottom: _size.height - f.y + 10,
          child: child!,
        );
      },
      child: IgnorePointer(
        child: Align(
          alignment: Alignment.bottomCenter,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Caderno.ink,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: '${f.word} ',
                    style: Caderno.serifStyle(
                      size: 15,
                      weight: FontWeight.w700,
                    ),
                  ),
                  TextSpan(text: meaning),
                ],
              ),
              style: const TextStyle(
                color: Caderno.paper,
                fontSize: 13,
                height: 1.35,
              ),
            ),
          ),
        ),
      ),
    );
  }

  static double _shakeOffset(double t) {
    const keys = [0.0, -8.0, 8.0, -5.0, 3.0, 0.0];
    final pos = t * (keys.length - 1);
    final i = pos.floor().clamp(0, keys.length - 2);
    return ui.lerpDouble(keys[i], keys[i + 1], pos - i)!;
  }

  static int _hash(String word) {
    var h = 0;
    for (final c in word.codeUnits) {
      h = (h * 31 + c) % 100000;
    }
    return h;
  }
}

class _Frame extends ChangeNotifier {
  void tick() => notifyListeners();
}

class _Kick {
  _Kick({required this.at, required this.vx, required this.vy});

  final Duration at;
  final double vx;
  final double vy;
}

class _Look {
  _Look(this.color, this.opacity, this.blur, this.front);

  final Color color;
  final double opacity;
  final double blur;
  final bool front;
}

class _Floater {
  _Floater({required this.word, required this.tone}) {
    final painter = TextPainter(
      text: TextSpan(text: word, style: _style(Caderno.ink, front: false)),
      textDirection: TextDirection.ltr,
    )..layout();
    base = painter.width;
    height = painter.height;
    painter.dispose();
  }

  final String word;
  final Color tone;

  /// Width and height at [_baseSize].
  late final double base;
  late final double height;

  double x = 0, y = 0, vx = 0, vy = 0, heading = 0;

  /// Depth: 0 far … 1 near.
  double z = 0;
  double phase = 0;

  /// Radians per millisecond of the depth cycle.
  double speed = 0;

  /// Extra scale of a fresh find; 0 once it settled.
  double boost = 0;
  double boost0 = 1;
  _Kick? kick;

  String? _key;
  TextPainter? _painter;

  static TextStyle _style(Color color, {required bool front, Paint? paint}) {
    return Caderno.serifStyle(
      size: _baseSize,
      weight: front ? FontWeight.w700 : FontWeight.w600,
      color: paint == null ? color : null,
      shadows: front
          ? const [
              Shadow(color: Caderno.paper, blurRadius: 10),
              Shadow(color: Caderno.paper, blurRadius: 22),
            ]
          : null,
    ).copyWith(foreground: paint);
  }

  /// Painter for this look; rebuilt only when the look changes enough.
  TextPainter painterFor(_Look look, double scale) {
    final alpha = (look.opacity.clamp(0.0, 1.0) * 50).round() / 50;
    final sigma = (look.blur * 4).round() / 4 / scale;
    final key = '${look.color.toARGB32()}|$alpha|$sigma|${look.front}';
    if (key == _key && _painter != null) return _painter!;
    final paint = Paint()..color = look.color.withValues(alpha: alpha);
    if (sigma > 0) paint.maskFilter = MaskFilter.blur(BlurStyle.normal, sigma);
    _painter?.dispose();
    _painter = TextPainter(
      text: TextSpan(
        text: word,
        style: _style(look.color, front: look.front, paint: paint),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    _key = key;
    return _painter!;
  }
}

class _SkyPainter extends CustomPainter {
  _SkyPainter(this.state) : super(repaint: state._frame);

  final _SkyState state;

  @override
  void paint(Canvas canvas, Size size) {
    for (final f in state._paintOrder()) {
      final s = state._scaleOf(f);
      final look = state._lookOf(f);
      if (look.opacity <= 0) continue;
      canvas
        ..save()
        ..translate(f.x, f.y)
        ..scale(s);
      f.painterFor(look, s).paint(canvas, Offset.zero);
      canvas.restore();
    }

    // the wave a typed letter sends out
    final wave = state._wave;
    final k = state._keepOut();
    if (wave.isAnimating && k != null) {
      final t = const Cubic(.2, .7, .3, 1).transform(wave.value);
      canvas.drawCircle(
        k.center,
        10 * (1 + 23 * t),
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2
          ..color = Caderno.brand.withValues(alpha: .35 * (1 - t)),
      );
    }

    // words fade into the paper above the line of recent words
    final fadeTop = size.height - 64;
    canvas.drawRect(
      Rect.fromLTWH(0, fadeTop, size.width, 64),
      Paint()
        ..shader = ui.Gradient.linear(
          Offset(0, fadeTop),
          Offset(0, size.height),
          [Caderno.paper.withValues(alpha: 0), Caderno.paper],
        ),
    );
  }

  @override
  bool shouldRepaint(_SkyPainter oldDelegate) => oldDelegate.state != state;
}

/// One letter of the typed word: it slides in, and hops on a find.
class _TypedLetter extends StatelessWidget {
  const _TypedLetter({
    super.key,
    required this.index,
    required this.hop,
    required this.child,
  });

  final int index;
  final AnimationController? hop;
  final Widget child;

  static const _overshoot = Cubic(.34, 1.56, .64, 1);

  @override
  Widget build(BuildContext context) {
    final entered = TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 120),
      curve: Curves.easeOut,
      builder: (context, v, child) => Opacity(
        opacity: v,
        child: Transform.translate(
          offset: Offset(0, 8 * (1 - v)),
          child: child,
        ),
      ),
      child: child,
    );
    final hop = this.hop;
    if (hop == null) return entered;
    return AnimatedBuilder(
      animation: hop,
      builder: (context, child) {
        final ms = hop.value * 760 - index * 40;
        final t = (ms / 420).clamp(0.0, 1.0);
        final up = t < .4
            ? _overshoot.transform(t / .4)
            : 1 - Curves.easeIn.transform((t - .4) / .6);
        return Transform.translate(offset: Offset(0, -10 * up), child: child);
      },
      child: entered,
    );
  }
}

class _Caret extends StatelessWidget {
  const _Caret({required this.blink, required this.empty});

  final Animation<double> blink;
  final bool empty;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: blink,
      builder: (context, _) => Container(
        width: empty ? 3 : 2,
        height: empty ? 48 : 40,
        margin: EdgeInsets.only(left: empty ? 0 : 4, bottom: empty ? 5 : 9),
        color: blink.value < .5 ? Caderno.brand : Colors.transparent,
      ),
    );
  }
}

class _Toast extends StatelessWidget {
  const _Toast({required this.animation, required this.text});

  final Animation<double> animation;
  final String text;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        final t = animation.value;
        if (t == 0 || t == 1) return const SizedBox.shrink();
        final opacity = t < .15
            ? t / .15
            : t < .75
            ? 1.0
            : 1 - (t - .75) / .25;
        final dy = t < .15
            ? 8 * (1 - t / .15)
            : t < .75
            ? 0.0
            : -8 * (t - .75) / .25;
        return Opacity(
          opacity: opacity,
          child: Transform.translate(offset: Offset(0, dy), child: child),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
        decoration: BoxDecoration(
          color: Caderno.honeySoft,
          borderRadius: BorderRadius.circular(99),
        ),
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 13.5,
            fontWeight: FontWeight.w600,
            color: Caderno.honeyInk,
          ),
        ),
      ),
    );
  }
}

/// The line under the typed word.
class _Feedback {
  const _Feedback.neutral(this.text)
    : kind = _FeedbackKind.neutral,
      word = null;

  const _Feedback.error(this.text) : kind = _FeedbackKind.error, word = null;

  _Feedback.count(int n)
    : text = n == 1 ? '1 letra' : '$n letras',
      kind = _FeedbackKind.neutral,
      word = null;

  const _Feedback.found(this.word, this.text) : kind = _FeedbackKind.found;

  const _Feedback.hint(this.word) : kind = _FeedbackKind.hint, text = '';

  final _FeedbackKind kind;
  final String text;
  final String? word;

  static const _glow = [
    Shadow(color: Caderno.paper, blurRadius: 5),
    Shadow(color: Caderno.paper, blurRadius: 10),
  ];

  Widget build() {
    final span = switch (kind) {
      _FeedbackKind.neutral => TextSpan(
        text: text,
        style: const TextStyle(color: Caderno.muted),
      ),
      _FeedbackKind.error => TextSpan(
        text: text,
        style: const TextStyle(
          color: Caderno.error,
          fontWeight: FontWeight.w500,
        ),
      ),
      _FeedbackKind.found => TextSpan(
        style: Caderno.serifStyle(
          color: Caderno.ink2,
          size: 14,
        ).copyWith(fontStyle: FontStyle.italic),
        children: [
          TextSpan(
            text: word,
            style: const TextStyle(
              fontStyle: FontStyle.normal,
              fontWeight: FontWeight.w700,
              color: Caderno.brand,
            ),
          ),
          TextSpan(text: ' · $text'),
        ],
      ),
      _FeedbackKind.hint => TextSpan(
        style: const TextStyle(color: Caderno.muted),
        children: [
          const TextSpan(text: 'Toque nas letras · toda palavra usa o '),
          TextSpan(
            text: word,
            style: const TextStyle(
              color: Caderno.brand,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    };
    return Text.rich(
      span,
      textAlign: TextAlign.center,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: const TextStyle(fontSize: 13.5, shadows: _glow),
    );
  }
}

enum _FeedbackKind { neutral, error, found, hint }

/// The three most recent words under a hairline, newest first, and the way
/// into the glossário. Tap it, or drag it up, to open.
class _RecentLine extends StatefulWidget {
  const _RecentLine({
    required this.game,
    required this.bump,
    required this.onOpen,
  });

  final Game? game;
  final int bump;
  final VoidCallback onOpen;

  @override
  State<_RecentLine> createState() => _RecentLineState();
}

class _RecentLineState extends State<_RecentLine> {
  double _drag = 0;

  @override
  Widget build(BuildContext context) {
    final found = widget.game?.visible ?? const <String>[];
    final recent = found.reversed.take(3).map((w) => w.toLowerCase()).toList();

    final words = <InlineSpan>[];
    for (var i = 0; i < recent.length; i++) {
      if (i > 0) {
        words.add(
          const TextSpan(
            text: '  ·  ',
            style: TextStyle(color: Caderno.muted),
          ),
        );
      }
      words.add(
        TextSpan(
          text: recent[i],
          style: TextStyle(color: i == 0 ? Caderno.brand : Caderno.ink),
        ),
      );
    }

    // a new word pushes the line in from the left
    final line = TweenAnimationBuilder<double>(
      key: ValueKey(widget.bump),
      tween: Tween(begin: widget.bump == 0 ? 1 : 0, end: 1),
      duration: const Duration(milliseconds: 450),
      curve: const Cubic(.2, .8, .2, 1),
      builder: (context, v, child) =>
          Transform.translate(offset: Offset(-22 * (1 - v), 0), child: child),
      child: Text.rich(
        TextSpan(children: words),
        maxLines: 1,
        overflow: TextOverflow.clip,
        softWrap: false,
        style: Caderno.serifStyle(
          size: 16,
          weight: FontWeight.w600,
          height: 1.2,
        ),
      ),
    );

    return Semantics(
      button: true,
      label: 'Abrir glossário',
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: widget.onOpen,
        onVerticalDragStart: (_) => _drag = 0,
        onVerticalDragUpdate: (d) {
          _drag -= d.delta.dy;
          if (_drag > 24) {
            _drag = -double.infinity;
            widget.onOpen();
          }
        },
        child: Container(
          height: Sky.footer,
          padding: const EdgeInsets.only(top: 10, bottom: 4),
          decoration: const BoxDecoration(
            border: Border(top: BorderSide(color: Caderno.line)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(child: ClipRect(child: line)),
              const SizedBox(width: 10),
              Text(
                'Glossário · ${found.length}',
                style: const TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                  color: Caderno.brand,
                ),
              ),
              const SizedBox(width: 6),
              const Icon(
                Icons.chevron_right_rounded,
                size: 18,
                color: Caderno.brand,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
