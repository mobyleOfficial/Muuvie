import 'package:common/common.dart';
import 'package:flutter/material.dart';

/// Mascot under a soft pink spotlight, then the headline and subtitle.
/// The mascot folds away while the keyboard is open to keep the fields
/// in view.
class AuthHeader extends StatelessWidget {
  static const double _illustrationHeight = 150;
  static const _foldDuration = Duration(milliseconds: 250);

  final MuuvieIllustration illustration;
  final String title;
  final String subtitle;

  const AuthHeader({
    super.key,
    required this.illustration,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isKeyboardOpen = MediaQuery.viewInsetsOf(context).bottom > 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AnimatedSize(
          duration: _foldDuration,
          curve: Curves.easeInOut,
          child: isKeyboardOpen
              ? const SizedBox(width: double.infinity, height: 24)
              : Padding(
                  padding: const EdgeInsets.only(top: 16, bottom: 20),
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: RadialGradient(
                        radius: 0.6,
                        colors: [
                          colorScheme.secondaryContainer,
                          colorScheme.secondaryContainer.withValues(alpha: 0),
                        ],
                      ),
                    ),
                    child: MuuvieIllustrationView(
                      illustration: illustration,
                      height: _illustrationHeight,
                    ),
                  ),
                ),
        ),
        Semantics(
          header: true,
          child: Text(
            title,
            textAlign: TextAlign.center,
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.w800,
              color: colorScheme.onSurface,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          subtitle,
          textAlign: TextAlign.center,
          style: theme.textTheme.bodyLarge?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}
