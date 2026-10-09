import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:common/src/muuvie_animated_app_bar.dart';
import 'package:common/src/muuvie_close_button.dart';

/// Base scaffold for full-screen modal screens that hide the bottom navbar.
///
/// Provides the standard modal layout:
///   SafeArea → ColoredBox → Column [ MuuvieAnimatedAppBar, Expanded(body) ]
///
/// The [MuuvieCloseButton] leading widget is included by default;
/// override [leading] to replace it or set it to `null` to remove it.
///
/// Colors default to black background / white foreground (the standard
/// modal style used across the app). Override [backgroundColor] and
/// [foregroundColor] if a specific modal needs different colors.
class MuuvieModalScreen extends StatelessWidget {
  /// Static text title — ignored when [titleWidget] is provided.
  final String? title;

  /// Custom title widget (e.g. a search field). Takes precedence over [title].
  final Widget? titleWidget;

  /// Leading widget in the AppBar. Defaults to [MuuvieCloseButton].
  /// Pass `null` to remove the leading area entirely.
  final Widget? leading;

  /// Whether to use the default [MuuvieCloseButton] when [leading] is null.
  /// Set to `false` if the modal should have no leading widget at all.
  final bool showCloseButton;

  /// Custom callback for the default close button.
  /// Only used when [leading] is not provided and [showCloseButton] is true.
  final VoidCallback? onClose;

  /// Trailing action widgets in the AppBar.
  final List<Widget>? actions;

  /// AppBar and status-bar background color.
  /// Defaults to [Colors.black] — the standard modal style.
  final Color backgroundColor;

  /// AppBar foreground (icons/text) color.
  /// Defaults to [Colors.white] — the standard modal style.
  final Color foregroundColor;

  /// The main content below the AppBar.
  final Widget body;

  /// Whether to center the title text.
  final bool centerTitle;

  /// Whether the AppBar is visible. Useful for scroll-to-hide behavior.
  final bool appBarVisible;

  const MuuvieModalScreen({
    super.key,
    this.title,
    this.titleWidget,
    this.leading,
    this.showCloseButton = true,
    this.onClose,
    this.actions,
    this.backgroundColor = Colors.black,
    this.foregroundColor = Colors.white,
    this.centerTitle = false,
    this.appBarVisible = true,
    required this.body,
  });

  @override
  Widget build(BuildContext context) {
    final isDark =
        ThemeData.estimateBrightnessForColor(backgroundColor) ==
            Brightness.dark;

    final effectiveLeading =
        leading ??
        (showCloseButton ? MuuvieCloseButton(onPressed: onClose) : null);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: (isDark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark)
          .copyWith(statusBarColor: Colors.transparent),
      child: Scaffold(
        backgroundColor: backgroundColor,
        body: SafeArea(
          child: ColoredBox(
            color: Theme.of(context).colorScheme.surface,
            child: Column(
              children: [
                MuuvieAnimatedAppBar(
                  visible: appBarVisible,
                  leading: effectiveLeading,
                  title: title,
                  titleWidget: titleWidget,
                  actions: actions,
                  backgroundColor: backgroundColor,
                  foregroundColor: foregroundColor,
                  centerTitle: centerTitle,
                ),
                Expanded(child: body),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
