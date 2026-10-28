import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:common/src/theme/muuvie_colors.dart';

/// Mascot (cow) illustrations shipped in `assets/illustrations/`.
enum MuuvieIllustration {
  movies('movies'),
  search('search'),
  error('error'),
  maratona('maratona'),
  cineclube('cineclube'),
  ranking('ranking'),
  sleeping('sleeping'),
  welcome('welcome'),
  signup('signup'),
  onboardingWelcome('onboarding_welcome'),
  onboardingShelves('onboarding_shelves'),
  onboardingLogs('onboarding_logs'),
  onboardingProgramacao('onboarding_programacao'),
  onboardingSocial('onboarding_social'),
  onboardingImport('onboarding_import'),
  onboardingSuggestions('onboarding_suggestions');

  const MuuvieIllustration(this.fileName);

  final String fileName;

  String get assetPath => 'assets/illustrations/$fileName.svg';
}

/// Renders a [MuuvieIllustration], recolouring it to the current theme so it
/// reads on both light and dark surfaces.
///
/// The SVGs are drawn with fixed colours that act as roles: ink (`primary`)
/// for outlines, spots and eyes, ink on background (`#1A1C1F`, the same
/// black) for lines drawn straight on the page such as the tail, hooves and
/// "zzz", paper (`neutral`) for fills and `onSecondaryContainer` for details
/// drawn over pink. In dark mode the cow stays white with black spots, like
/// the app icon, and only the ink on background turns light so it does not
/// vanish. Pinks, gold and pure white highlights are never recoloured.
class MuuvieIllustrationView extends StatelessWidget {
  final MuuvieIllustration illustration;
  final double height;

  const MuuvieIllustrationView({
    super.key,
    required this.illustration,
    this.height = 160,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = colorScheme.brightness == Brightness.dark;

    return ExcludeSemantics(
      child: SvgPicture.asset(
        illustration.assetPath,
        package: 'common',
        height: height,
        colorMapper: _ThemeColorMapper(
          ink: isDark ? MuuvieColors.primary : colorScheme.onSurface,
          inkOnBackground: colorScheme.onSurface,
          paper: isDark ? colorScheme.onSurface : colorScheme.surface,
          onPink: isDark
              ? MuuvieColors.onSecondaryContainer
              : colorScheme.onSurface,
        ),
      ),
    );
  }
}

/// Mascot artwork shipped by another package, drawn in its original light
/// colours. For art that always sits on a light background of its own, such
/// as a vaquinha on its pastel circle, where the theme must not recolour it.
class MuuvieMascotArt extends StatelessWidget {
  final String assetPath;
  final String package;
  final double size;

  const MuuvieMascotArt({
    super.key,
    required this.assetPath,
    required this.package,
    required this.size,
  });

  @override
  Widget build(BuildContext context) => ExcludeSemantics(
    child: SvgPicture.asset(
      assetPath,
      package: package,
      width: size,
      height: size,
    ),
  );
}

class _ThemeColorMapper extends ColorMapper {
  static final int _inkRole = MuuvieColors.primary.toARGB32();
  static const int _inkOnBackgroundRole = 0xFF1A1C1F;
  static final int _paperRole = MuuvieColors.neutral.toARGB32();
  static final int _onPinkRole = MuuvieColors.onSecondaryContainer.toARGB32();

  final Color ink;
  final Color inkOnBackground;
  final Color paper;
  final Color onPink;

  const _ThemeColorMapper({
    required this.ink,
    required this.inkOnBackground,
    required this.paper,
    required this.onPink,
  });

  @override
  Color substitute(
    String? id,
    String elementName,
    String attributeName,
    Color color,
  ) {
    final role = color.toARGB32();
    if (role == _inkRole) return ink;
    if (role == _inkOnBackgroundRole) return inkOnBackground;
    if (role == _paperRole) return paper;
    if (role == _onPinkRole) return onPink;
    return color;
  }

  @override
  bool operator ==(Object other) =>
      other is _ThemeColorMapper &&
      other.ink == ink &&
      other.inkOnBackground == inkOnBackground &&
      other.paper == paper &&
      other.onPink == onPink;

  @override
  int get hashCode => Object.hash(ink, inkOnBackground, paper, onPink);
}
