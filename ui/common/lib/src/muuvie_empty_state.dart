import 'package:flutter/material.dart';

class MuuvieEmptyState extends StatelessWidget {
  final String title;
  final String message;
  final VoidCallback? action;
  final String? actionLabel;

  const MuuvieEmptyState({
    super.key,
    required this.title,
    required this.message,
    this.action,
    this.actionLabel,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
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
