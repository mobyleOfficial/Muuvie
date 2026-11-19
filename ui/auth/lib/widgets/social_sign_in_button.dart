import 'package:common/common.dart';
import 'package:flutter/material.dart';
import 'package:auth/auth.dart';

/// "Continuar com Apple / Google". Apple's button is black (white in dark
/// mode), as Apple's guidelines ask; Google's is outlined.
class SocialSignInButton extends StatelessWidget {
  final OAuthProvider provider;
  final String label;
  final bool isLoading;

  /// Null while another sign-in is running.
  final VoidCallback? onPressed;

  const SocialSignInButton({
    super.key,
    required this.provider,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final textStyle = theme.textTheme.titleMedium?.copyWith(
      fontWeight: FontWeight.w600,
    );
    const shape = RoundedRectangleBorder(borderRadius: MuuvieRadius.largeAll);
    const minimumSize = Size.fromHeight(56);

    final content = Stack(
      alignment: Alignment.center,
      children: [
        // Kept in place while loading so the button keeps its size and its
        // label is still read by screen readers.
        Opacity(
          opacity: isLoading ? 0 : 1,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(switch (provider) {
                OAuthProvider.apple => Icons.apple,
                OAuthProvider.google => Icons.g_mobiledata,
              }, size: 26),
              const SizedBox(width: 8),
              Flexible(child: Text(label, overflow: TextOverflow.ellipsis)),
            ],
          ),
        ),
        if (isLoading)
          const SizedBox.square(
            dimension: 22,
            child: CircularProgressIndicator(strokeWidth: 2.5),
          ),
      ],
    );

    return switch (provider) {
      OAuthProvider.apple => FilledButton(
        onPressed: onPressed,
        style: FilledButton.styleFrom(
          minimumSize: minimumSize,
          shape: shape,
          textStyle: textStyle,
          backgroundColor: isDark ? Colors.white : Colors.black,
          foregroundColor: isDark ? Colors.black : Colors.white,
          disabledBackgroundColor: (isDark ? Colors.white : Colors.black)
              .withValues(alpha: 0.6),
          disabledForegroundColor: isDark ? Colors.black : Colors.white,
        ),
        child: content,
      ),
      OAuthProvider.google => OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          minimumSize: minimumSize,
          shape: shape,
          textStyle: textStyle,
        ),
        child: content,
      ),
    };
  }
}
