import 'package:flutter/widgets.dart';

/// Corner radius tokens. Same values the theme already uses for cards (12),
/// dialogs (16) and tags (20), named so new components stay consistent.
abstract final class MuuvieRadius {
  static const double small = 8;
  static const double medium = 12;
  static const double large = 16;
  static const double pill = 20;

  static const BorderRadius smallAll = BorderRadius.all(Radius.circular(small));
  static const BorderRadius mediumAll = BorderRadius.all(
    Radius.circular(medium),
  );
  static const BorderRadius largeAll = BorderRadius.all(Radius.circular(large));
  static const BorderRadius pillAll = BorderRadius.all(Radius.circular(pill));
}
