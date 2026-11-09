import 'package:flutter/painting.dart';

/// Colors of the star map. Space stays dark in both themes; [highlight] marks
/// the selected planet together with a thicker ring and a bigger size, so the
/// selection never relies on color alone. The viewer's state is a badge
/// whose glyph (a check, a bookmark) says what the color says.
class UniversePalette {
  final Color space;
  final Color starGlow;
  final Color orbit;
  final Color route;
  final Color planetRing;
  final Color placeholder;
  final Color highlight;
  final Color watchedBadge;
  final Color watchlistBadge;
  final Color badgeGlyph;

  /// Laid over the planets a filter leaves out.
  final Color fade;

  /// Faint cloud colors, picked per chunk.
  final List<Color> nebulae;

  const UniversePalette({
    required this.highlight,
    this.space = const Color(0xFF05060F),
    this.starGlow = const Color(0xFFFFC870),
    this.orbit = const Color(0x33FFFFFF),
    this.route = const Color(0x66FFC870),
    this.planetRing = const Color(0xCCFFFFFF),
    this.placeholder = const Color(0xFF2A2D45),
    this.watchedBadge = const Color(0xFF2E9E5B),
    this.watchlistBadge = const Color(0xFFE0A030),
    this.badgeGlyph = const Color(0xFF05060F),
    this.fade = const Color(0xC005060F),
    this.nebulae = const [
      Color(0x1A6A4CFF),
      Color(0x1A2F8FFF),
      Color(0x14C0508A),
      Color(0x1430B5A0),
    ],
  });
}
