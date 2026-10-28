import 'package:flutter/material.dart';

/// A titled block of the movie detail, so every section shares the same
/// heading, spacing and optional trailing action.
class MovieSection extends StatelessWidget {
  final String title;
  final Widget child;

  /// A text action at the end of the heading, like "Ver todas".
  final String? actionLabel;
  final VoidCallback? onAction;

  /// False for content that scrolls sideways and pads itself.
  final bool padContent;

  const MovieSection({
    super.key,
    required this.title,
    required this.child,
    this.actionLabel,
    this.onAction,
    this.padContent = true,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final actionLabel = this.actionLabel;

    return Padding(
      padding: const EdgeInsets.only(top: 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(
              left: 16,
              right: actionLabel == null ? 16 : 4,
            ),
            child: SizedBox(
              height: 40,
              child: Row(
                children: [
                  Expanded(
                    child: Semantics(
                      header: true,
                      child: Text(
                        title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                  if (actionLabel != null)
                    TextButton(onPressed: onAction, child: Text(actionLabel)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 4),
          padContent
              ? Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: child,
                )
              : child,
        ],
      ),
    );
  }
}
