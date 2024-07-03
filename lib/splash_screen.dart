import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:letraco/events.dart';
import 'package:letraco/game_controller.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({
    super.key,
    required this.controller,
    this.firstTimeInitializing = false,
  });

  final GameController controller;
  final bool firstTimeInitializing;

  static const minimumDurationInSecs = 2;

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  static const firstSectionMin = 0.0;
  static const firstSectionMax = 100.0;
  static const dotSize = 55.56;
  static const logoSize = 100;
  static const verticalWidth = 38.0;
  static const spaceBetween = logoSize - verticalWidth - dotSize;

  final init = DateTime.now();
  int get timePassed => DateTime.now().difference(init).inSeconds;

  // animation
  late final _startController = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 1),
  );
  late final _startAnimation = Tween<double>(
    begin: firstSectionMin,
    end: firstSectionMax,
  ).animate(
    CurvedAnimation(
      parent: _startController,
      curve: Curves.elasticOut,
    ),
  );

  @override
  void initState() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);

    _startController.addListener(() {
      setState(() {});
    });

    widget.controller.events.stream.listen((event) {
      _dismissSplashWhenGameIsLoaded(event);
    });

    _startController.forward();
    super.initState();
  }

  @override
  void dispose() {
    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.manual,
      overlays: SystemUiOverlay.values,
    );
    _startController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final bg = Container(color: colors.surface);

    final size = MediaQuery.of(context).size;
    const halfLogoSize = logoSize / 2;
    final centerWidth = size.width / 2;
    final centerHeight = size.height / 2;

    final progressIndicator = Positioned(
      top: centerHeight + halfLogoSize + 50,
      left: (size.width * 0.2) / 2,
      child: SizedBox(
        height: 5,
        width: size.width * 0.8,
        child: LinearProgressIndicator(
          color: colors.onPrimary,
          backgroundColor: colors.secondary,
        ),
      ),
    );

    final dot = Positioned(
      left: normalize(
        _startAnimation.value,
        0,
        firstSectionMax,
        (centerWidth + halfLogoSize - dotSize),
      ),
      bottom: centerHeight - (dotSize / 2) + spaceBetween,
      child: Container(
        height: dotSize,
        width: dotSize,
        decoration: BoxDecoration(
          color: colors.primary,
          borderRadius: BorderRadius.circular(dotSize / 2),
        ),
      ),
    );

    final lColor = colors.secondary;
    final vertical = Positioned(
      left: centerWidth - halfLogoSize,
      bottom: centerHeight - halfLogoSize,
      child: Container(
        width: verticalWidth,
        height: _startAnimation.value,
        color: lColor,
      ),
    );

    final hPos = _startAnimation.value / firstSectionMax * 72.22;
    final horizontal = Positioned(
      left: centerWidth - halfLogoSize,
      bottom: centerHeight - halfLogoSize,
      child: Container(
        width: hPos,
        height: 22,
        color: lColor,
      ),
    );

    return Stack(
      children: [
        bg,
        dot,
        vertical,
        horizontal,
        if (_startController.status == AnimationStatus.completed)
          progressIndicator,
      ],
    );
  }

  /// Wait for at least [SplashScreen.minimumDurationInSecs] before dismiss
  Future<void> _waitForDismiss() async {
    while (timePassed <= SplashScreen.minimumDurationInSecs) {
      await Future.delayed(const Duration(milliseconds: 100));
    }
  }

  Future<void> _dismissSplashWhenGameIsLoaded(Event event) async {
    if (event is NoGameToLoad) return widget.controller.newGame();

    if (event is! Loaded) return;

    await _waitForDismiss();
    if (!mounted) return;
    if (!widget.firstTimeInitializing) return Navigator.of(context).pop();

    unawaited(
      Navigator.of(context).pushReplacementNamed('/', arguments: event.game),
    );
  }
}

/// Normalize a value in a dataset to a new range between 0 and [newMax]
/// The formula:
/// newValue = ([value] – [min]) / ([max] – [min]) * [newMax]
/// [min] is the minimum value found in dataset
/// [max] is the mxnimum value found in dataset
double normalize(double value, double min, double max, double newMax) {
  return (value - min) / (max - min) * newMax;
}
