import 'package:flutter/material.dart';

class MuuvieSubmissionBanner extends StatelessWidget {
  final String reviewTitle;
  final bool isError;
  final VoidCallback? onTap;
  final VoidCallback? onDismiss;

  const MuuvieSubmissionBanner({
    super.key,
    required this.reviewTitle,
    this.isError = false,
    this.onTap,
    this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Semantics(
      label: isError
          ? 'Submission failed for $reviewTitle. Tap to retry.'
          : 'Submitting $reviewTitle',
      button: isError,
      child: InkWell(
        onTap: isError ? onTap : null,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          color: isError
              ? colorScheme.errorContainer
              : colorScheme.surfaceContainerHighest,
          child: Row(
            children: [
              if (isError)
                Icon(Icons.error_outline, size: 20, color: colorScheme.error)
              else
                SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: colorScheme.primary,
                  ),
                ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      isError ? 'Submission failed' : 'Submitting review...',
                      style: textTheme.labelSmall?.copyWith(
                        color: isError
                            ? colorScheme.error
                            : colorScheme.onSurfaceVariant,
                      ),
                    ),
                    Text(
                      reviewTitle,
                      style: textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: isError
                            ? colorScheme.onErrorContainer
                            : colorScheme.onSurface,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              if (isError) ...[
                const SizedBox(width: 8),
                Tooltip(
                  message: 'Dismiss',
                  child: IconButton(
                    icon: Icon(
                      Icons.close,
                      size: 18,
                      color: colorScheme.onErrorContainer,
                    ),
                    onPressed: onDismiss,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(
                      minWidth: 48,
                      minHeight: 48,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
