import 'package:flutter/material.dart';

/// "Caderno" palette. Light theme only.
abstract final class Caderno {
  static const paper = Color(0xFFF5F0E6);
  static const paper2 = Color(0xFFEDE6D8);
  static const card = Color(0xFFFFFDF8);
  static const ink = Color(0xFF1D2626);
  static const ink2 = Color(0xFF56605E);
  static const muted = Color(0xFF8A918C);
  static const line = Color(0xFFDCD4C4);
  static const dots = Color(0xFFC9C0AE);
  static const brand = Color(0xFF0E6E64);
  static const brandInk = Color(0xFFFFFFFF);
  static const brandSoft = Color(0xFFD3E9E4);
  static const honey = Color(0xFFD99A1E);
  static const honeyInk = Color(0xFF8A6200);
  static const honeySoft = Color(0xFFF7E6BF);
  static const error = Color(0xFFB8402F);
  static const tile = Color(0xFFE6DFCF);
  static const scrim = Color(0x611D2626);

  /// Fixed tones a floating word can take, from darker to lighter.
  static const tones = [
    Color(0xFF1D2626),
    Color(0xFF0E6E64),
    Color(0xFF56605E),
    Color(0xFF3E8C82),
    Color(0xFF8A918C),
    Color(0xFF9C7A3C),
  ];

  /// Book serif for words, wordmark and headings.
  static const serif = 'Iowan Old Style';
  static const serifFallback = [
    'Palatino Linotype',
    'Palatino',
    'Book Antiqua',
    'Georgia',
    'Noto Serif',
    'serif',
  ];

  static TextStyle serifStyle({
    double? size,
    FontWeight? weight,
    Color? color,
    double? height,
    double? letterSpacing,
    List<Shadow>? shadows,
  }) {
    return TextStyle(
      fontFamily: serif,
      fontFamilyFallback: serifFallback,
      fontSize: size,
      fontWeight: weight,
      color: color,
      height: height,
      letterSpacing: letterSpacing,
      shadows: shadows,
    );
  }

  static ThemeData theme() {
    final scheme = ColorScheme.fromSeed(seedColor: brand).copyWith(
      primary: brand,
      onPrimary: brandInk,
      primaryContainer: brandSoft,
      onPrimaryContainer: brand,
      secondary: ink2,
      secondaryContainer: line,
      surface: paper,
      onSurface: ink,
      onSurfaceVariant: ink2,
      outline: line,
      outlineVariant: line,
      error: error,
      scrim: ink,
    );
    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: paper,
      dividerColor: line,
    );
  }
}
