import 'package:flutter/material.dart';

abstract class AppColorSchemes {
  static const _seedColor = Color(0xFF{{primary_color}});

  static final light = ColorScheme.fromSeed(
    seedColor: _seedColor,
  );

  static final dark = ColorScheme.fromSeed(
    seedColor: _seedColor,
    brightness: Brightness.dark,
  );
}
