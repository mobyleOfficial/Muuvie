import 'package:common/common.dart';
import 'package:flutter/material.dart';

/// Full-width primary action. While [isLoading] the label stays in place
/// (invisible, still read by screen readers) so the button keeps its size.
class AuthSubmitButton extends StatelessWidget {
  final String label;
  final bool isLoading;
  final VoidCallback onPressed;

  const AuthSubmitButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return FilledButton(
      onPressed: isLoading ? null : onPressed,
      style: FilledButton.styleFrom(
        minimumSize: const Size.fromHeight(56),
        shape: const RoundedRectangleBorder(
          borderRadius: MuuvieRadius.largeAll,
        ),
        textStyle: Theme.of(
          context,
        ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
        disabledBackgroundColor: colorScheme.primary.withValues(alpha: 0.7),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Opacity(opacity: isLoading ? 0 : 1, child: Text(label)),
          if (isLoading)
            SizedBox.square(
              dimension: 22,
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                color: colorScheme.onPrimary,
              ),
            ),
        ],
      ),
    );
  }
}
