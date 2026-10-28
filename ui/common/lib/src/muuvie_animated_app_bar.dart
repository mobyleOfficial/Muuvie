import 'package:flutter/material.dart';

class MuuvieAnimatedAppBar extends StatelessWidget {
  final String? title;
  final Widget? titleWidget;
  final Widget? leading;
  final List<Widget>? actions;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final bool visible;
  final bool centerTitle;
  final Duration animationDuration;

  static const _defaultDuration = Duration(milliseconds: 300);

  const MuuvieAnimatedAppBar({
    super.key,
    this.title,
    this.titleWidget,
    this.leading,
    this.actions,
    this.backgroundColor,
    this.foregroundColor,
    this.visible = true,
    this.centerTitle = false,
    this.animationDuration = _defaultDuration,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveBg =
        backgroundColor ?? Theme.of(context).colorScheme.surface;
    final effectiveFg =
        foregroundColor ?? Theme.of(context).colorScheme.onSurface;
    final hasLeading = leading != null;

    return ClipRect(
      child: AnimatedAlign(
        duration: animationDuration,
        curve: Curves.easeInOut,
        alignment: Alignment.topCenter,
        heightFactor: visible ? 1.0 : 0.0,
        child: AnimatedContainer(
          duration: animationDuration,
          curve: Curves.easeInOut,
          color: effectiveBg,
          height: kToolbarHeight,
          child: Row(
            children: [
              AnimatedContainer(
                duration: animationDuration,
                curve: Curves.easeInOut,
                width: hasLeading ? 48.0 : 16.0,
                child: hasLeading
                    ? IconTheme(
                        data: IconThemeData(color: effectiveFg),
                        child: leading!,
                      )
                    : null,
              ),
              Expanded(
                child: titleWidget != null
                    ? titleWidget!
                    : AnimatedAlign(
                        duration: animationDuration,
                        curve: Curves.easeInOut,
                        alignment: centerTitle
                            ? Alignment.center
                            : Alignment.centerLeft,
                        child: AnimatedSwitcher(
                          duration: animationDuration,
                          transitionBuilder: (child, animation) {
                            final slide =
                                Tween<Offset>(
                                  begin: const Offset(0, 0.3),
                                  end: Offset.zero,
                                ).animate(
                                  CurvedAnimation(
                                    parent: animation,
                                    curve: Curves.easeOut,
                                  ),
                                );
                            return FadeTransition(
                              opacity: animation,
                              child: SlideTransition(
                                position: slide,
                                child: child,
                              ),
                            );
                          },
                          child: Text(
                            title ?? '',
                            key: ValueKey<String>(title ?? ''),
                            style: Theme.of(context).textTheme.titleLarge
                                ?.copyWith(color: effectiveFg),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
              ),
              if (actions != null)
                ...actions!.map(
                  (action) => IconTheme(
                    data: IconThemeData(color: effectiveFg),
                    child: action,
                  ),
                )
              else
                const SizedBox(width: 16),
            ],
          ),
        ),
      ),
    );
  }
}
