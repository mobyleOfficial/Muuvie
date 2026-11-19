import 'package:flutter/material.dart';

/// Scrollable column for the auth forms: fills the screen so the [footer]
/// rests at the bottom, and scrolls when the keyboard takes the space.
class AuthFormLayout extends StatelessWidget {
  static const double _maxWidth = 440;

  final List<Widget> children;
  /// Rests at the bottom of the screen, under the form.
  final Widget? footer;

  const AuthFormLayout({
    super.key,
    required this.children,
    this.footer,
  });

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) => SingleChildScrollView(
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minHeight: constraints.maxHeight,
            maxWidth: _maxWidth,
          ),
          child: IntrinsicHeight(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ...children,
                const Spacer(),
                if (footer case final footer?)
                  Padding(
                    padding: const EdgeInsets.only(top: 16, bottom: 8),
                    child: footer,
                  ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}
