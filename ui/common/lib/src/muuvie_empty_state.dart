import 'package:flutter/material.dart';

import 'package:common/src/muuvie_illustration.dart';

class MuuvieEmptyState extends StatelessWidget {
  final String title;
  final String message;
  final VoidCallback? action;
  final String? actionLabel;

  /// Mascot illustration shown above the title. Pass `null` where vertical
  /// space is tight (bottom sheets, pickers) to render the copy only.
  final MuuvieIllustration? illustration;

  const MuuvieEmptyState({
    super.key,
    required this.title,
    required this.message,
    this.action,
    this.actionLabel,
    this.illustration = MuuvieIllustration.sleeping,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    // Non-primary scroll so short containers (collapsed tabs, small phones)
    // scroll the content instead of overflowing, without hijacking the
    // parent's PrimaryScrollController.
    return Center(
      child: SingleChildScrollView(
        primary: false,
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (illustration case final illustration?) ...[
              MuuvieIllustrationView(illustration: illustration),
              const SizedBox(height: 16),
            ],
            Text(
              title,
              style: textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: colorScheme.onSurface,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            if (action != null) ...[
              const SizedBox(height: 24),
              FilledButton.tonal(
                onPressed: action,
                child: Text(actionLabel ?? ''),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
