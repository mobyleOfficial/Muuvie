import 'package:flutter/painting.dart';

/// Colors of the star map. Space stays dark in both themes; [highlight] marks
/// the selected planet together with a thicker ring and a bigger size, so the
/// selection never relies on color alone.
class UniversePalette {
  final Color space;
  final Color starGlow;
  final Color orbit;
  final Color route;
  final Color planetRing;
  final Color placeholder;
  final Color highlight;

  const UniversePalette({
    required this.highlight,
    this.space = const Color(0xFF05060F),
    this.starGlow = const Color(0xFFFFC870),
    this.orbit = const Color(0x33FFFFFF),
    this.route = const Color(0x66FFC870),
    this.planetRing = const Color(0xCCFFFFFF),
    this.placeholder = const Color(0xFF2A2D45),
  });
}
