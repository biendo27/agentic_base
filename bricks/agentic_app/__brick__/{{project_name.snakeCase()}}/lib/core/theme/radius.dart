import 'package:flutter/material.dart';

abstract class AppRadius {
  static const double checkbox = 2;
  static const double field = 4;
  static const double chip = 8;
  static const double card = 12;
  static const double medium = 16;
  static const double large = 28;
  static const double full = 999;

  static const double sm = field;
  static const double md = card;
  static const double lg = medium;
  static const double xl = large;

  static final BorderRadius checkboxAll = BorderRadius.circular(checkbox);
  static final BorderRadius fieldAll = BorderRadius.circular(field);
  static final BorderRadius chipAll = BorderRadius.circular(chip);
  static final BorderRadius cardAll = BorderRadius.circular(card);
  static final BorderRadius mediumAll = BorderRadius.circular(medium);
  static final BorderRadius largeAll = BorderRadius.circular(large);
  static final BorderRadius fullAll = BorderRadius.circular(full);

  static final BorderRadius smAll = fieldAll;
  static final BorderRadius mdAll = cardAll;
  static final BorderRadius lgAll = mediumAll;
  static final BorderRadius xlAll = largeAll;
}
