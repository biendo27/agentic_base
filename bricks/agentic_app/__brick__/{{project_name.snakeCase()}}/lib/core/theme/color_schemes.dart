import 'package:flutter/material.dart';

abstract class AppColorSchemes {
  static const seed = Color(0xFF{{primary_color}});

  static ColorScheme resolve(Brightness brightness) => ColorScheme.fromSeed(
    seedColor: seed,
    brightness: brightness,
    dynamicSchemeVariant: DynamicSchemeVariant.tonalSpot,
  );

  static final light = resolve(Brightness.light);

  static final dark = resolve(Brightness.dark);
}
