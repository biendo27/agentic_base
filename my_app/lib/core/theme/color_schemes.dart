import 'package:flutter/material.dart';

abstract class AppColorSchemes {
  static const _seedColor = Color(0xFF6750A4);

  static final light = ColorScheme.fromSeed(
    seedColor: _seedColor,
  );

  static final dark = ColorScheme.fromSeed(
    seedColor: _seedColor,
    brightness: Brightness.dark,
  );
}
