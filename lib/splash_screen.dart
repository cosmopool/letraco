import 'dart:async';
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:letraco/brand_mark.dart';
import 'package:letraco/events.dart';
import 'package:letraco/game_controller.dart';
import 'package:letraco/theme.dart';
import 'package:letraco/wigets/logo.dart';

/// Opening animation, laid over the game screen.
///
/// Its first frame is the system splash: the icon at 288 dp in the middle of
/// the paper. The "L" and the "ç" come forward, the far letters leave the back
/// of the icon and spell "Letraço" with them, and the name flies to the
/// header while the paper fades into the game underneath. If the game is not
/// ready when the name is spelled, the animation holds there, with a blinking
/// caret, until it is.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key, required this.controller});

  final GameController controller;

  /// Route that keeps the game screen painted underneath and has no
  /// transition of its own: the animation is the transition.
  static Route<void> route(GameController controller, RouteSettings settings) {
    // the header logo appears only when the splash hands over to it
    Logo.reveal.value = 0;
    return PageRouteBuilder<void>(
      settings: settings,
      opaque: false,
      transitionDuration: Duration.zero,
      reverseTransitionDuration: Duration.zero,
      pageBuilder: (context, _, __) => SplashScreen(controller: controller),
    );
  }

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

/// Story time, in seconds, of each beat.
abstract final class _Beat {
  static const spellStart = .10;
  static const spelled = .58;
  static const gate = .62; // holds here until the game is loaded
  static const landed = 1.10;
  // as the name lands, its letters fade out and the header logo fades in
  // under them; the paper gives way to the game at the same time
  static const swapFrom = .98;
  static const swapTo = 1.28;
  static const paperFrom = 1.0;
  static const paperTo = 1.32;
  static const end = 1.36;
  static const reducedEnd = .45;
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final GameController controller = widget.controller;
  late final StreamSubscription<Event> _sub;
  late final Ticker _ticker;
  final _repaint = _Repaint();

  double _now = 0;
  double? _loadedAt;
  bool _done = false;
  bool _reduced = false;

  /// Story time and how long it has been held at the gate.
  double tg = 0;
  double held = 0;
  double released = double.infinity;

  @override
  void initState() {
    super.initState();
    _sub = controller.stream.listen(_onEvent);
    if (controller.game != null) _loadedAt = 0;
    _ticker = createTicker(_tick)..start();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _reduced = MediaQuery.of(context).disableAnimations;
  }

  @override
  void dispose() {
    // never leave the header logo hidden
    if (Logo.reveal.value != 1) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Logo.reveal.value = 1;
      });
    }
    _sub.cancel();
    _ticker.dispose();
    _repaint.dispose();
    super.dispose();
  }

  void _onEvent(Event event) {
    if (event is NoGameToLoad) return controller.newGame();
    if (event is Loaded) _loadedAt ??= _now;
  }

  void _tick(Duration elapsed) {
    _now = elapsed.inMicroseconds / 1e6;
    final gate = _reduced ? 0.0 : _Beat.gate;
    final loaded = _loadedAt ?? double.infinity;
    if (_now < gate || loaded <= gate) {
      tg = _now;
      held = 0;
      released = double.infinity;
    } else if (_now < loaded) {
      tg = gate;
      held = _now - gate;
      released = double.infinity;
    } else {
      tg = _now - (loaded - gate);
      held = loaded - gate;
      released = _now - loaded;
    }
    Logo.reveal.value = _reduced
        ? _Curve.eio(_Curve.seg(tg, 0, .4))
        : _Curve.seg(tg, _Beat.swapFrom, _Beat.swapTo);
    _repaint.tick();
    if (mounted) setState(() {});
    if (!_done && tg >= (_reduced ? _Beat.reducedEnd : _Beat.end)) {
      _done = true;
      _ticker.stop();
      final navigator = Navigator.of(context);
      if (navigator.canPop()) {
        navigator.pop();
      } else {
        navigator.pushReplacementNamed('/');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final waiting = _Curve.seg(held, .6, .9) * _releaseFade;
    final center = media.size.center(Offset.zero);
    return Material(
      type: MaterialType.transparency,
      child: Stack(
        children: [
          Positioned.fill(
            child: CustomPaint(
              painter: _SplashPainter(
                this,
                safeTop: media.padding.top,
                reduced: _reduced,
                // the header logo follows the system font size, the icon not
                headerSize: MediaQuery.textScalerOf(
                  context,
                ).scale(Logo.textSize),
              ),
            ),
          ),
          if (waiting > 0)
            Positioned(
              left: 0,
              right: 0,
              top: center.dy + 34,
              child: Opacity(
                opacity: waiting,
                child: Text(
                  'Espalhando as palavras…',
                  textAlign: TextAlign.center,
                  style: Caderno.serifStyle(
                    size: 14,
                    color: Caderno.muted,
                  ).copyWith(fontStyle: FontStyle.italic),
                ),
              ),
            ),
        ],
      ),
    );
  }

  double get _releaseFade =>
      released == double.infinity ? 1 : 1 - _Curve.seg(released, 0, .18);
}

class _Repaint extends ChangeNotifier {
  void tick() => notifyListeners();
}

abstract final class _Curve {
  static double seg(double t, double a, double b) =>
      ((t - a) / (b - a)).clamp(0.0, 1.0);

  /// Ease in and out (cubic).
  static double eio(double x) =>
      x < .5 ? 4 * x * x * x : 1 - math.pow(-2 * x + 2, 3) / 2;

  /// Ease out (cubic).
  static double eo(double x) => 1 - math.pow(1 - x, 3).toDouble();
}

/// Where a letter is: glyph origin (left, baseline) and font size.
class _Pose {
  const _Pose(this.x, this.y, this.size);

  final double x;
  final double y;
  final double size;

  _Pose lerp(_Pose to, double t) => _Pose(
    ui.lerpDouble(x, to.x, t)!,
    ui.lerpDouble(y, to.y, t)!,
    ui.lerpDouble(size, to.size, t)!,
  );
}

class _SplashPainter extends CustomPainter {
  _SplashPainter(
    this.state, {
    required this.safeTop,
    required this.reduced,
    required this.headerSize,
  }) : super(repaint: state._repaint);

  final _SplashScreenState state;
  final double safeTop;
  final bool reduced;

  /// Font size of the header logo's name, after the system text scale.
  final double headerSize;

  static const _composed = 46.0;

  /// Name in the header logo of the game screen: after the icon, 20 px from
  /// the left, centered in a 48 px row that starts 14 px under the safe area.
  static const _headerLeft = 20.0 + Logo.iconSize + Logo.gap;
  static const _headerRowTop = 14.0;
  static const _headerRowHeight = kMinInteractiveDimension;

  static TextStyle _style(double size, {double letterSpacing = 0}) {
    return Caderno.serifStyle(
      size: size,
      weight: FontWeight.w700,
      height: 1,
      letterSpacing: letterSpacing,
    );
  }

  /// Left edge of each letter inside the name, and the name's width.
  static (List<double>, double) _offsets(TextStyle style) {
    final offsets = <double>[];
    const name = BrandMark.name;
    for (var i = 0; i <= name.length; i++) {
      final painter = TextPainter(
        text: TextSpan(text: name.substring(0, i), style: style),
        textDirection: TextDirection.ltr,
      )..layout();
      offsets.add(painter.width);
      painter.dispose();
    }
    return (offsets.sublist(0, name.length), offsets.last);
  }

  @override
  void paint(Canvas canvas, Size size) {
    final tg = state.tg;
    final center = size.center(Offset.zero);
    const k = BrandMark.splashSize / BrandMark.canvas;

    // the paper gives way to the game screen underneath
    final paper = reduced
        ? 1 - _Curve.eio(_Curve.seg(tg, 0, .4))
        : 1 - _Curve.eo(_Curve.seg(tg, _Beat.paperFrom, _Beat.paperTo));
    canvas.drawRect(
      Offset.zero & size,
      Paint()..color = Caderno.paper.withValues(alpha: paper),
    );

    _Pose icon(MarkLetter m) => _Pose(
      center.dx + (m.x - BrandMark.canvas / 2) * k,
      center.dy + (m.y - BrandMark.canvas / 2) * k,
      m.size * k,
    );

    if (reduced) {
      for (var i = 0; i < BrandMark.name.length; i++) {
        final m = BrandMark.letterOf(i);
        _letter(
          canvas,
          m.char,
          icon(m),
          m.color,
          m.opacity * paper,
          m.blur * k,
        );
      }
      return;
    }

    final (compOff, compWidth) = _offsets(_style(_composed));
    final headerStyle = _style(headerSize, letterSpacing: Logo.letterSpacing);
    final (headerOff, _) = _offsets(headerStyle);
    final (lineHeight, baseline) = _line(headerStyle);
    final headerBaseline =
        safeTop +
        _headerRowTop +
        (_headerRowHeight - lineHeight) / 2 +
        baseline;

    final spell = _Curve.eio(_Curve.seg(tg, _Beat.spellStart, _Beat.spelled));
    final fly = _Curve.eio(_Curve.seg(tg, _Beat.gate, _Beat.landed));
    final out = 1 - _Curve.seg(tg, _Beat.swapFrom, _Beat.swapTo);

    for (var i = 0; i < BrandMark.name.length; i++) {
      final m = BrandMark.letterOf(i);
      final composed = _Pose(
        center.dx - compWidth / 2 + compOff[i],
        center.dy + _composed * .34,
        _composed,
      );
      final header = _Pose(
        _headerLeft + headerOff[i],
        headerBaseline,
        headerSize,
      );
      final Color color;
      double opacity = 1, blur = 0, a = spell;
      if (m == BrandMark.initial || m == BrandMark.cedilla) {
        // the ç stays teal, as in the header logo
        color = m.color;
      } else {
        // the far letters leave the back of the icon one after the other
        final order = const [0, 0, 1, 2, 3, 0, 4][i];
        a = _Curve.eio(_Curve.seg(tg, .10 + order * .035, .52 + order * .015));
        opacity = ui.lerpDouble(m.opacity, 1, a)!;
        blur = ui.lerpDouble(m.blur * k, 0, a)!;
        color = Color.lerp(Caderno.muted, Caderno.ink, a)!;
      }
      final pose = icon(m).lerp(composed, a).lerp(header, fly);
      _letter(canvas, m.char, pose, color, opacity * out, blur);
    }

    // holding for a slow game: a caret blinks after the name
    if (state.held > 0) {
      final fade = state._releaseFade;
      final on = state.released == double.infinity
          ? (state.held % 1 < .5 ? 1.0 : 0.0)
          : 1.0;
      final caret = _Curve.seg(state.held, .25, .4) * fade * on;
      if (caret > 0) {
        final x = center.dx + compWidth / 2 + 5;
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromLTWH(x, center.dy - 22, 2.5, 40),
            const Radius.circular(1.25),
          ),
          Paint()..color = Caderno.brand.withValues(alpha: caret),
        );
      }
    }
  }

  /// Height of a line of the name and the distance to its baseline.
  static (double, double) _line(TextStyle style) {
    final painter = TextPainter(
      text: TextSpan(text: BrandMark.name, style: style),
      textDirection: TextDirection.ltr,
    )..layout();
    final line = (
      painter.height,
      painter.computeDistanceToActualBaseline(TextBaseline.alphabetic),
    );
    painter.dispose();
    return line;
  }

  void _letter(
    Canvas canvas,
    String char,
    _Pose pose,
    Color color,
    double opacity,
    double blur,
  ) {
    if (opacity <= 0) return;
    final paint = Paint()..color = color.withValues(alpha: opacity * color.a);
    if (blur > .05) paint.maskFilter = MaskFilter.blur(BlurStyle.normal, blur);
    final painter = TextPainter(
      text: TextSpan(
        text: char,
        style: _style(pose.size).copyWith(foreground: paint),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    final top =
        pose.y -
        painter.computeDistanceToActualBaseline(TextBaseline.alphabetic);
    painter.paint(canvas, Offset(pose.x, top));
    painter.dispose();
  }

  @override
  bool shouldRepaint(_SplashPainter oldDelegate) =>
      oldDelegate.safeTop != safeTop ||
      oldDelegate.reduced != reduced ||
      oldDelegate.headerSize != headerSize;
}
